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

container-structure-test-install: ## Install container-structure-test
	$(info --> Install container-structure-test)
	@$(CWD)/scripts/container-structure-test-install

changelog: ## Generate CHANGELOG.md
	$(info --> Generate CHANGELOG.md)
	@$(CWD)/scripts/changelog

dive: ## Run dive
	$(info --> Run `dive`)
	@awk '/image:/ { print $$2 }' docker-compose.ci.yml \
		| sort -u \
		| xargs -I % -n 1 -P 1 env CI=true $(CWD)/scripts/dive %

docker-build: ## Build all Dockerfiles
	$(info --> Run docker-build)
	@docker compose -f docker-compose.ci.yml build --parallel --force-rm

dockerfile-lint: ## Run hadolint on Dockerfile(s)
	$(info --> Run dockerfile-lint)
	@$(CWD)/scripts/dockerfile-lint

install: venv pip-install container-structure-test-install ## Install all the things

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

container-structure-test: ## Run container-structure-test (tests/<service>.yaml against bdossantos/<service>)
	$(info --> Run container-structure-test)
	@for config in $(CWD)/tests/*.yaml; do \
		$(CWD)/bin/container-structure-test test --image "bdossantos/$$(basename "$$config" .yaml)" --config "$$config" || exit 1; \
	done

shellcheck: ## Run shellcheck on /scripts directory
	$(info --> Run shellsheck)
	@find scripts/ -type f | xargs -n 1 shellcheck

test: ## Run tests suite
	@$(MAKE) pre-commit shellcheck dockerfile-lint container-structure-test dive

venv: ## Create python virtualenv if not exists
	@python3 -m venv $(VIRTUALENV_DIR)
