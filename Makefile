FILE_VERSION         := $(shell cat version.txt)
VERSION              ?= $(FILE_VERSION)

IMAGE_HOST           ?= ghcr.io
IMAGE_NAME           ?= getupcloud/managed-cluster
IMAGE_BASE            = $(addsuffix /,$(IMAGE_HOST))$(IMAGE_NAME)-base
IMAGE                 = $(addsuffix /,$(IMAGE_HOST))$(IMAGE_NAME)

GIT_COMMIT           ?= $(shell git log --pretty=format:"%h" -n 1)
DOCKERFILE           := Dockerfile.centos8
DOCKER_BUILD_OPTIONS  = --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(VERSION)

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
	docker build . -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE):$(VERSION)

build-base: check-version $(DOCKERFILE)
	docker build . -f $(DOCKERFILE).base $(DOCKER_BUILD_OPTIONS) -t $(IMAGE_BASE):$(VERSION)

tag:
	docker tag $(IMAGE):$(VERSION) $(IMAGE):latest

push: tag
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

$(DOCKERFILE): version.txt
	sed -i -e "s|FROM .*|FROM $(IMAGE_BASE):$(VERSION)|" $(DOCKERFILE)

fmt:
	terraform fmt -recursive

install:
	if [ -e /etc/debian_version ]; then \
		apt install -y make jq python3-pip; \
	fi
	if [ -e /etc/redhat-release ]; then \
		yum install -y make jq python3-pip; \
	fi
	pip3 install --user giturlparse || pip install --user giturlparse

test: TEST_PARAMS=--branch remotes/origin/$(shell git branch --show-current)
test: VERSION=$(FILE_VERSION)-$(GIT_COMMIT)
test: IMAGE_HOST=
test:
	cd tests && ./test $(TEST_PARAMS)
