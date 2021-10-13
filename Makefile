VERSION    := $(shell cat version.txt)
IMAGE      := getupcloud/cluster:$(VERSION)
IMAGE_BASE := getupcloud/cluster-base:$(VERSION)
IMAGE_USER := root
GIT_COMMIT := $(shell git log --pretty=format:"%h" -n 1)
DOCKERFILE := Dockerfile.centos8
DOCKER_BUILD_OPTIONS := --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(VERSION)

build: build-base
	docker build . -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS) -t $(IMAGE)

build-base:
	docker build . -f $(DOCKERFILE).base $(DOCKER_BUILD_OPTIONS) -t $(IMAGE_BASE)

fmt:
	terraform fmt -recursive
