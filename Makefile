CWD := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PATH := $(HOME)/.local/bin:$(HOME)/bin:/usr/local/bin:/bin:$(PATH)
SHELL := /usr/bin/env bash
VIRTUALENV_DIR := $(CWD)/venv

.DEFAULT_GOAL := help

export PATH

help:
	@grep -E '^[a-zA-Z1-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

bundle-install: ## Install ruby dependencies
	$(info --> Run `bundle install`)
	@bundle install

changelog: ## Generate CHANGELOG.md
	$(info --> Generate CHANGELOG.md)
	@$(CWD)/scripts/changelog

dive: ## Run dive
	$(info --> Run `dive`)
	@awk '/image:/ { print $$2 }' docker-compose.ci.yml \
		| xargs -I % -n 1 -P 1 env CI=true dive %

docker-build: ## Build all Dockerfiles
	$(info --> Run docker-build)
	@docker-compose build --parallel --force-rm

dockerfile-lint: ## Run hadolint on Dockerfile(s)
	$(info --> Run dockerfile-lint)
	@$(CWD)/scripts/dockerfile-lint

install: venv pip-install bundle-install ## Install all the things

pip-install: ## Install pip dependencies
	$(info --> Install ansible via `pip`)
	@( \
		source $(VIRTUALENV_DIR)/bin/activate; \
		pip3 install wheel; \
		pip3 install virtualenv --upgrade; \
		pip3 install -r requirements.txt; \
	)

pre-commit: ## Run pre-commit tests
	$(info --> Run pre-commit)
	@source $(VIRTUALENV_DIR)/bin/activate && pre-commit run --all-files

serverspec: ## Run serverspec
	$(info --> Run serverspec)
	@find . -type f -name '*_spec.rb' \
		| xargs -n 1 -P 1 -I % bundle exec rspec %

shellcheck: ## Run shellcheck on /scripts directory
	$(info --> Run shellsheck)
	@find scripts/ -type f | xargs -n 1 shellcheck

test: ## Run tests suite
	@$(MAKE) pre-commit shellcheck dockerfile-lint serverspec dive

venv: ## Create python virtualenv if not exists
	@python3 -m venv $(VIRTUALENV_DIR)
