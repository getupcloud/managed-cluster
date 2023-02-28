VERSION_TXT          := version.txt
FILE_VERSION         := $(shell cat $(VERSION_TXT))
VERSION              := $(FILE_VERSION)
RELEASE              := v$(VERSION)
ARCH                 := $(shell uname -m | tr '[:upper:]' '[:lower:]')

IMAGE_HOST           ?= ghcr.io
IMAGE_NAME           ?= getupcloud/managed-cluster
IMAGE_BASE            = $(addsuffix /,$(IMAGE_HOST))$(IMAGE_NAME)-base
IMAGE                 = $(addsuffix /,$(IMAGE_HOST))$(IMAGE_NAME)

GIT_COMMIT           ?= $(shell git log --pretty=format:"%h" -n 1)
DOCKERFILE           := Dockerfile.centos8
DOCKERFILE_BASE      := Dockerfile.centos8.base.$(ARCH)
DOCKER_BUILD_OPTIONS  = --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(VERSION) --build-arg RELEASE=$(RELEASE)

SEMVER_REGEX := ^([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+[0-9A-Za-z-]+)?$
SHELL         = /bin/bash

.ONESHELL:
.EXPORT_ALL_VARIABLES:

default: build

define print_targets =
Targets:$(shell $(MAKE) -p null | grep '^$(1):' | tail -n1 | cut -d: -f2-)
endef

null:

help:
	@echo Target:
	@echo '  build:              Create docker image (default). $(call print_targets,build)'
	@echo '  fmt:                Run terraform fmt. $(call print_targets,fmt)'
	@echo '  import:             Download terraform variables from cluster repositories. $(call print_targets,import)'
	@echo '  modules:            Create templates/variables-modules-merge.tf.json. $(call print_targets,modules)'
	@echo '  release:            Release a new version (source only). $(call print_targets,release)'
	@echo '  local-release:      Build locally and release a new version. $(call print_targets,local-release)'
	@echo '  test:               Run all tests from ./tests. $(call print_targets,test)'
	@echo '  test-iter:          Iterable tests. $(call print_targets,test-iter)'
	@echo '  test-help:          Show test options. $(call print_targets,test-help)'
	@echo '  push-git:           Push code to github'
	@echo '  push-image:         Push image to $(IMAGE_HOST)'
	@echo '  show-modules-vars:  Print modules.* from all manifests'

CLUSTER_TYPES := $(shell ls -1 templates/*/main.tf | awk -F/ '{print $$2}')

define CLUSTER_REPO_template =
	modules=$$(hcl2json < templates/$(1)/main.tf  | jq '.module|keys|.[]' -r 2>/dev/null) || true
	if [ -n "$$modules" ]; then
		for module in $$modules; do
			source=$$(hcl2json < templates/$(1)/main.tf  | jq ".module.$$module[0].source" -r)
			#echo ./root/usr/local/bin/urlparse "$$source" "{query[ref]}"
			#echo ./root/usr/local/bin/urlparse "$$source" "https://{netloc}{path}/raw"

			base_url=$$(./root/usr/local/bin/urlparse "$$source" "https://{netloc}{path}/raw")
			ref=$$(./root/usr/local/bin/urlparse "$$source" "{query[ref]}")
			for i in provider cluster; do
				url=$$base_url/$${ref:-main}/variables-$$i.tf
				file=templates/$(1)/variables-$$i.tf
				echo -n "Downloading: $(1) $$url"
				curl --fail -sL $$url -o $$file && printf "\r[    OK    ]" || printf "\r[ NotFound ]"
				echo
			done
		done
	fi;
endef

import:
	@$(foreach i,$(CLUSTER_TYPES),$(call CLUSTER_REPO_template,$(i)))

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

build: modules build-base
	docker build -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE):$(RELEASE) .
	#buildah bud -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE):$(RELEASE) .

build-base: check-version $(DOCKERFILE)
	docker build -f $(DOCKERFILE_BASE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE_BASE):$(RELEASE) .
	#buildah bud -f $(DOCKERFILE_BASE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE_BASE):$(RELEASE) .

print-release:
	@echo $(RELEASE)

# Build and release from CI/CD (github actions for now)
release: fmt lint check-git update-version tag-git push-git

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
	git commit -m "Built release v$(VERSION)" $(VERSION_TXT) $(DOCKERFILE_BASE) $(DOCKERFILE)
	git tag $(RELEASE)

tag-image:
	docker tag $(IMAGE):$(RELEASE) $(IMAGE):latest
	docker tag $(IMAGE_BASE):$(RELEASE) $(IMAGE_BASE):latest

push: push-git push-image

push-git:
	git push origin main:release-$(RELEASE)
	git push origin main
	git push --tags

push-image:
	docker push $(IMAGE):$(RELEASE)
	docker push $(IMAGE):latest
	docker push $(IMAGE_BASE):$(RELEASE)
	docker push $(IMAGE_BASE):latest

.PHONY: $(DOCKERFILE)

$(DOCKERFILE):
	sed -i -e "s|FROM .*|FROM $(IMAGE_BASE):$(RELEASE)|" $(DOCKERFILE)

fmt:
	terraform fmt -recursive

install: PIP_INSTALL=giturlparse python-hcl2==3.0.5
install:
	if [ -e /etc/debian_version ]; then
		apt install -y jq python3-pip rsync
	elif [ -e /etc/redhat-release ]; then
		yum install -y jq python3-pip rsync
	elif [ -d /Applications ]; then
		brew install jq
	fi
	for pkg in $(PIP_INSTALL); do
		pip3 install $$pkg || pip install $$pkg
	done
	curl -skL https://github.com/mikefarah/yq/releases/download/v4.18.1/yq_linux_amd64 > /usr/local/bin/yq
	chmod +x /usr/local/bin/yq
	curl -skL https://github.com/tmccombs/hcl2json/releases/download/v0.3.4/hcl2json_linux_amd64 > /usr/local/bin/hcl2json
	chmod +x /usr/local/bin/hcl2json

#test: TEST_BRANCH = $(shell git branch --show-current)
test: DEFAULT_TEST_PARAMS = ## --branch $(TEST_BRANCH)
test: VERSION := $(FILE_VERSION)-$(GIT_COMMIT)-test
test: RELEASE := v$(FILE_VERSION)-$(GIT_COMMIT)-test
test: lint
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
