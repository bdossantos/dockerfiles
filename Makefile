CWD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PATH := $(HOME)/.local/bin:$(HOME)/bin:/usr/local/bin:/bin:$(PATH)
SHELL := /usr/bin/env bash

.DEFAULT_GOAL := help

export PATH

help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

bundle-install: ## Install ruby dependencies
	$(info --> Run `bundle install`)
	@bundle install

docker-build: ## Build all Dockerfiles
	$(info --> Run docker-build)
	@docker-compose build --force-rm

dockerfile-lint: ## Run hadolint on Dockerfile(s)
	$(info --> Run dockerfile-lint)
	@$(CWD)/scripts/dockerfile-lint

install: pip-install bundle-install ## Install all the things

pip-install: ## Install pip dependencies
	$(info --> Install ansible via `pip`)
	@pip install --user -r requirements.txt

pre-commit: ## Run pre-commit tests
	$(info --> Run pre-commit)
	@pre-commit run --all-files

serverspec: ## Run serverspec
	$(info --> Run serverspec)
	@find . -type f -name '*_spec.rb' | xargs -n 1 -P 1 bundle exec rspec

shellcheck: ## Run shellcheck on /scripts directory
	$(info --> Run shellsheck)
	@find scripts/ -type f | xargs -n 1 shellcheck

test: ## Run tests suite
	@$(MAKE) pre-commit shellcheck dockerfile-lint serverspec
