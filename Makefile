VERSION_TXT          := version.txt
DISTRO               ?= ubuntu
FILE_VERSION         := $(shell cat $(VERSION_TXT))
VERSION              := $(FILE_VERSION)
RELEASE              := v$(VERSION)
ARCH                 := $(shell uname -m | tr '[:upper:]' '[:lower:]')

IMAGE_HOST           ?= ghcr.io
IMAGE_NAME           ?= getupcloud/managed-cluster
IMAGE                 = $(addsuffix /,$(IMAGE_HOST))$(IMAGE_NAME)

GIT_COMMIT           ?= $(shell git log --pretty=format:"%h" -n 1)
DOCKERFILE           := Dockerfile.$(DISTRO)
DOCKER_BUILD_OPTIONS  = --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(VERSION) --build-arg RELEASE=$(RELEASE)

SEMVER_REGEX := ^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+[0-9A-Za-z-]+)?$
SHELL         = /bin/bash

COLOR_GREEN  := $(shell tput setaf 2)
COLOR_RESET  := $(shell tput sgr0)

.ONESHELL:
.EXPORT_ALL_VARIABLES:

default: image

null:

help:
	@echo Target:
	@echo '  image:                    Build docker image (default).'
	@echo '  fmt:                      Run terraform fmt.'
	@echo '  update-cluster-versions   Update templates/*/main.tf versions from terraform-cluster-* repositories.'
	@echo '  import-cluster-variables  Download terraform variables from cluster repositories.'
	@echo '  modules:                  Create templates/variables-modules-merge.tf.json.'
	@echo '  release:                  Release a new version (source only).'
	@echo '  local-release:            Build locally and release a new version.'
	@echo '  test:                     Run all tests from ./tests.'
	@echo '  test-iter:                Iterable tests.'
	@echo '  test-help:                Show test options.'
	@echo '  push-git:                 Push code to github'
	@echo '  push-image:               Push image to $(IMAGE_HOST)'
	@echo '  show-modules-vars:        Print modules.* from all manifests'

CLUSTER_TYPES := $(shell ls -1 templates/*/main.tf | awk -F/ '{print $$2}')

define IMPORT_CLUSTER_VARIABLES_template =
	modules=$$(hcl2json < templates/$(1)/main.tf  | jq '.module|keys|.[]' -r 2>/dev/null) || true
	if [ -n "$$modules" ]; then
		for module in $$modules; do
			source=$$(hcl2json < templates/$(1)/main.tf  | jq ".module.$$module[0].source" -r)
			base_url=$$(./root/usr/local/bin/urlparse "$$source" "https://{netloc}{path}/raw")
			ref=$$(./root/usr/local/bin/urlparse "$$source" "{query[ref]}")
			for i in provider cluster; do
				url=$$base_url/$${ref:-main}/variables-$$i.tf
				file=templates/$(1)/variables-$$i.tf
				md5_old=$$(md5sum $$file 2>/dev/null || true)
				echo -n ">Downloading: $(1) $$url"
				if ! curl --fail -sL $$url -o $$file; then
					printf "\r[ Not Found ] $$url"
				else
					md5_new=$$(md5sum $$file)
					if [ "$$md5_old" != "$$md5_new" ]; then
						printf "\r[  $(COLOR_GREEN)Changed$(COLOR_RESET)  ]"
					else
						printf "\r[ Unchanged ]"
					fi
				fi
				echo
			done
		done
	fi;
endef

import-cluster-variables:
	@$(foreach i,$(CLUSTER_TYPES),$(call IMPORT_CLUSTER_VARIABLES_template,$(i)))

define UPDATE_CLUSTER_VERSION_template =
	modules=$$(hcl2json < templates/$(1)/main.tf  | jq '.module|keys|.[]' -r 2>/dev/null) || true
	if [ -n "$$modules" ]; then
		for module in $$modules; do
			source=$$(hcl2json < templates/$(1)/main.tf  | jq ".module.$$module[0].source" -r)
			url=$$(./root/usr/local/bin/urlparse "$$source" "https://{netloc}{path}/raw/refs/heads/main/version.txt")
			ref=$$(./root/usr/local/bin/urlparse "$$source" "{query[ref]}")
			if ! new_ver=$$(curl --fail -sL "$$url"); then
				printf "\r[ Not Found ] $$url\n"
				exit 1
			fi
			[ "$${ref:0:1}" == v ] && cur_ver="$${ref:1}" || cur_ver="$$ver"
			if [ "$$cur_ver" != "$$new_ver" ]; then
				printf "\r[  $(COLOR_GREEN)Changed$(COLOR_RESET)  ] $(1): $$cur_ver -> $$new_ver\n"
				sed -i -e "/.*source\s\?=/s|?ref=v\?[a-zA-Z0-9\.\-]\+|?ref=v$$new_ver|" templates/$(1)/main.tf
			else
				printf "\r[ Unchanged ] $(1): $$cur_ver\n"
			fi
		done
	fi;
endef

update-cluster-versions:
	@$(foreach i,$(CLUSTER_TYPES),$(call UPDATE_CLUSTER_VERSION_template,$(i)))

check-version:
	@if ! [[ "$(VERSION)" =~ $(SEMVER_REGEX) ]]; then \
		echo Invalid semantic version: $(VERSION) >&2; \
		exit 1; \
	fi

modules: templates/variables-modules-merge.tf.json
templates/variables-modules-merge.tf.json: templates/variables-modules.tf
	./root/usr/local/bin/make-modules $< > $@

show-modules-vars:
	grep 'modules\.[^[:space:],)}]\+' -r templates/*/manifests  templates/manifests/ -oh | sort -u

image: modules
	docker build -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE):$(RELEASE) .
	docker tag $(IMAGE):$(RELEASE) $(IMAGE):latest
	#buildah bud -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE):$(RELEASE) .

print-release:
	@echo $(RELEASE)

# Build and release from CI/CD (github actions for now)
release: fmt check-git update-version
	$(MAKE) git-release image image-push

git-release: tag-git push-git
	@echo Finished $(RELEASE) release

# Locally build and release (manual process)
local-release: fmt check-git update-version
	$(MAKE) build-release

check-git:
	@if git status --porcelain | grep '^\s*[^?]' | grep -qv version.txt; then
		git status
		echo -e "\n>>> Tree is not clean. Please commit and try again <<<\n"
		exit 1
	fi

update-version:
	[ -n "$$BUILD_VERSION" ] || read -e -i "$(FILE_VERSION)" -p "New version: " BUILD_VERSION
	echo $$BUILD_VERSION > $(VERSION_TXT)

build-release: check-tag build tag push
	@echo Finished $(RELEASE) release

check-tag:
	@if git tag -l | grep -q '^$(RELEASE)$$'; then
		echo Git tag already exists: $(RELEASE)
		exit 1
	fi

tag: tag-git tag-image

tag-git:
	git commit -m "Built release v$(VERSION)" $(VERSION_TXT)
	git tag $(RELEASE)

tag-image:
	docker tag $(IMAGE):$(RELEASE) $(IMAGE):latest

push: push-git push-image

push-git git-push:
	git push origin main:release-$(RELEASE)
	git push origin main
	git push --tags

push-image image-push:
	docker push $(IMAGE):$(RELEASE)
	docker push $(IMAGE):latest

fmt:
	terraform fmt -recursive

install: PIP_INSTALL=giturlparse python-hcl2==3.0.5
install:
	set -x
	if [ -e /etc/debian_version ]; then
		apt install -y jq python3-pip rsync
	elif [ -e /etc/redhat-release ]; then
		yum install -y jq python3-pip rsync
	elif [ -d /Applications ]; then
		brew install jq
	fi
	for pkg in $(PIP_INSTALL); do
		pip3 install --break-system-packages $$pkg || pip install --break-system-packages $$pkg
	done
	curl -skL https://github.com/mikefarah/yq/releases/download/v4.18.1/yq_linux_amd64 > /usr/local/bin/yq
	chmod +x /usr/local/bin/yq
	curl -skL https://github.com/tmccombs/hcl2json/releases/download/v0.3.4/hcl2json_linux_amd64 > /usr/local/bin/hcl2json
	chmod +x /usr/local/bin/hcl2json

#test: TEST_BRANCH = $(shell git branch --show-current)
test: DEFAULT_TEST_PARAMS = ## --branch $(TEST_BRANCH)
test: VERSION := $(FILE_VERSION)-$(GIT_COMMIT)-test
test: RELEASE := v$(FILE_VERSION)-$(GIT_COMMIT)-test
test: # lint
test:
	cd tests
	./test $(DEFAULT_TEST_PARAMS) $(TEST_PARAMS)

test-help:
	@echo Usage: make test TEST_PARAMS="..."
	@echo
	@cd tests && ./test --help
	@echo
	@echo Targets: test, test-{type}, test-iter

test-%:
	$(MAKE) test TEST_PARAMS="--plans tests/test_02_cluster-types --cluster-types $(subst test-,,$@) $(TEST_PARAMS)"

test-iter:
	$(MAKE) test TEST_PARAMS="-i $(TEST_PARAMS)"

lint:
	@for dir in templates/ templates/*/ templates/providers/*/; do
		if [ "$$dir" == templates/providers/ ]; then
			continue
		fi
		echo tflint $$dir && tflint $$dir
	done
