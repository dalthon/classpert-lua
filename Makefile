IMAGE_NAME := classpert/lua
WORKDIR    := /course
DOCKER_RUN := docker run -it --rm -v `pwd`:$(WORKDIR) $(IMAGE_NAME)
SHELL      := /bin/bash

default: help

help:
	@printf "List of make tasks:\n\n"
	@grep -E '^[%a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

build: ## Builds docker image
	docker build -t $(IMAGE_NAME) .

lua: ## Runs interactive lua shell
	$(DOCKER_RUN)

shell: ## Runs shell
	$(DOCKER_RUN) $(SHELL)

lesson-%: ## Task lesson-01-02, executes "lua lessons/lesson_01/02_something.lua"
	@$(DOCKER_RUN) sh -c "echo $* | sed -En \"s/(\d+)-(\d+)/ls lessons\/lesson_\1\/\2\*/p\" | xargs -I {} sh -c \"{}\" | xargs -I {} echo \">> lua {}\""
	@$(DOCKER_RUN) sh -c "echo $* | sed -En \"s/(\d+)-(\d+)/ls lessons\/lesson_\1\/\2\*/p\" | xargs -I {} sh -c \"{}\" | xargs lua"

.PHONY: build lua shell
