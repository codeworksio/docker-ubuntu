ifdef GITHUB_ACCOUNT
	ACCOUNT := $(GITHUB_ACCOUNT)
else
	ACCOUNT := $(USER)
endif
CONTAINER := $(subst docker-,,$(shell basename $(shell dirname $(realpath  $(lastword $(MAKEFILE_LIST))))))
REPOSITORY :=  $(ACCOUNT)/$(CONTAINER)

all: help

help:
	@echo
	@echo "Usage:"
	@echo
	@echo "    make build|release|push|test|purge"
	@echo

build:
	@docker build --tag $(REPOSITORY) --rm .

release: build
	@docker build --tag $(REPOSITORY):$(shell cat VERSION) --rm .

push: release
	@docker push $(REPOSITORY):$(shell cat VERSION)

test:
	@docker run --interactive --tty --rm \
		--name $(CONTAINER) \
		--hostname $(CONTAINER) \
		$(REPOSITORY) \
		ps aux

purge:
	@docker rmi $(REPOSITORY) > /dev/null 2>&1 ||:
