VERSION_TXT          := version.txt
FILE_VERSION         := $(shell cat $(VERSION_TXT))
VERSION              ?= $(FILE_VERSION)
RELEASE              ?= v$(VERSION)
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

.EXPORT_ALL_VARIABLES:

default: build

check-version:
	@if ! [[ "$(VERSION)" =~ $(SEMVER_REGEX) ]]; then \
		echo Invalid semantic version: $(VERSION) >&2; \
		exit 1; \
	fi

build: build-base
	docker build . -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE):$(RELEASE)

build-base: check-version $(DOCKERFILE)
	docker build . -f $(DOCKERFILE_BASE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE_BASE):$(RELEASE)

print-release:
	@echo $(RELEASE)

release: fmt build check-git tag push
	@echo Finished $(RELEASE) release

check-git:
	@if git status --porcelain | grep '^[^?]' -q | grep -v version.txt; then \
		echo Git has uncommited files. Please fix and try again; \
		exit 1; \
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

install:
	if [ -e /etc/debian_version ]; then \
		apt install -y jq python3-pip rsync; \
	fi
	if [ -e /etc/redhat-release ]; then \
		yum install -y jq python3-pip rsync; \
	fi
	if [ -d /Applications ]; then \
		brew install jq; \
	fi
	pip3 install giturlparse || pip install giturlparse
	curl -skL https://github.com/mikefarah/yq/releases/download/v4.18.1/yq_linux_amd64 > /usr/local/bin/yq
	chmod +x /usr/local/bin/yq
	curl -skL https://github.com/tmccombs/hcl2json/releases/download/v0.3.4/hcl2json_linux_amd64 > /usr/local/bin/hcl2json
	chmod +x /usr/local/bin/hcl2json

test: TEST_BRANCH = $(shell git branch --show-current)
test: DEFAULT_TEST_PARAMS = --branch $(TEST_BRANCH)
test: VERSION := $(FILE_VERSION)-$(GIT_COMMIT)-test
test: RELEASE := v$(FILE_VERSION)-$(GIT_COMMIT)-test
test: lint
test:
	@cd tests && ./test $(DEFAULT_TEST_PARAMS) $(TEST_PARAMS)

test-help:
	@echo Usage: make test TEST_PARAMS="..."
	@echo
	@cd tests && ./test --help
	@echo
	@echo Targets: test, test-{type}, test-iter

test-%:
	make test TEST_PARAMS="--types $(subst test-,,$@) $(TEST_PARAMS)"

test-iter:
	make test TEST_PARAMS="-i $(TEST_PARAMS)"

lint:
	for dir in templates/ templates/*/; do echo tflint $$dir && tflint $$dir; done

