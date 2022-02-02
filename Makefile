FILE_VERSION         := $(shell cat version.txt)
VERSION              ?= $(FILE_VERSION)
ARCH                 := $(shell uname -m | tr '[:upper:]' '[:lower:]')

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
	docker build . -f $(DOCKERFILE).base.$(ARCH) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE_BASE):$(VERSION)

release: check-git build tag push

check-git:
	@if git status --porcelain | grep . -q; then \
		echo Git has uncommited files. Please fix and try again; \
		exit 1; \
	fi

tag:
	git tag v$(VERSION)
	docker tag $(IMAGE):$(VERSION) $(IMAGE):latest
	docker tag $(IMAGE_BASE):$(VERSION) $(IMAGE_BASE):latest

push:
	git push --tags
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest
	docker push $(IMAGE_BASE):$(VERSION)
	docker push $(IMAGE_BASE):latest

$(DOCKERFILE): version.txt
	sed -i -e "s|FROM .*|FROM $(IMAGE_BASE):$(VERSION)|" $(DOCKERFILE)

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

test: TEST_BRANCH ?= remotes/origin/$(shell git branch --show-current)
test: DEFAULT_TEST_PARAMS=--branch $(TEST_BRANCH)
test: VERSION=$(FILE_VERSION)-$(GIT_COMMIT)
test: IMAGE_HOST=
test:
	cd tests && ./test $(DEFAULT_TEST_PARAMS) $(TEST_PARAMS)
