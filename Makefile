VERSION    := $(shell cat version.txt)
REPO_HOST  := ghcr.io
IMAGE      := $(REPO_HOST)/getupcloud/cluster
IMAGE_BASE := $(REPO_HOST)/getupcloud/cluster-base
IMAGE_USER := root
GIT_COMMIT := $(shell git log --pretty=format:"%h" -n 1)
DOCKERFILE := Dockerfile.centos8
DOCKER_BUILD_OPTIONS := --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(VERSION)

build: build-base version.txt
	docker build . -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE):$(VERSION)

build-base: $(DOCKERFILE) version.txt
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
	pip3 install --user giturlparser || pip install --user giturlparser
	sudo yum install jq || sudo apt install jq
