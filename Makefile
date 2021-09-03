VERSION := $(shell cat version.txt)
IMAGE := getupcloud/cluster:$(VERSION)
IMAGE_USER := root
GIT_COMMIT := $(shell git log --pretty=format:"%h" -n 1)
CLUSTERDIR := $(PWD)
DOCKERFILE := Dockerfile
DOCKER_BUILD_OPTIONS_DEFAULTS := --build-arg GIT_COMMIT=$(GIT_COMMIT) --build-arg VERSION=$(VERSION)
DOCKER_RUN_OPTIONS_DEFAULTS := --network host \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-it \
	--user $(IMAGE_USER) \
	-v $(CLUSTERDIR):/cluster
CMD :=

build image:
	docker build . -f $(DOCKERFILE) $(DOCKER_BUILD_OPTIONS_DEFAULTS) -t $(IMAGE)

run:
	docker run $(DOCKER_RUN_OPTIONS) $(DOCKER_RUN_OPTIONS_DEFAULTS) $(IMAGE) $(CMD)

fmt:
	terraform fmt -recursive
