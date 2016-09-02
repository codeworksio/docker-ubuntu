ifdef GITHUB_ACCOUNT
	OWNER := $(GITHUB_ACCOUNT)
else
	OWNER := $(USER)
endif
NAME := $(subst docker-,,$(shell basename $(shell dirname $(realpath  $(lastword $(MAKEFILE_LIST))))))
IMAGE :=  $(OWNER)/$(NAME)

all: help

help:
	@echo
	@echo "Usage:"
	@echo
	@echo "    make build|push APT_PROXY=url"
	@echo "    make test|prune"
	@echo

build:
	@docker build \
		--build-arg APT_PROXY=${APT_PROXY} \
		--build-arg VERSION=$(shell cat VERSION) \
		--build-arg BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg VCS_REF=$(shell git rev-parse --short HEAD) \
		--build-arg VCS_URL=$(shell git config --get remote.origin.url) \
		--tag $(IMAGE):$(shell cat VERSION) \
		--rm .
	@docker tag $(IMAGE):$(shell cat VERSION) $(IMAGE):latest

push:
	@docker push $(IMAGE):$(shell cat VERSION)
	@docker push $(IMAGE):latest
	@curl --request POST "https://hooks.microbadger.com/images/stefaniuk/ubuntu/YVVi9RhnoYFbOQ9RqDwj-7o7m00="

test:
	@docker run --interactive --tty --rm \
		--name $(NAME) \
		--hostname $(NAME) \
		$(IMAGE) \
		ps aux

prune:
	@docker rmi $(IMAGE):$(shell cat VERSION) > /dev/null 2>&1 ||:
	@docker rmi $(IMAGE):latest > /dev/null 2>&1 ||:
