# Dockerfiles

[![Build Status](https://github.com/bdossantos/dockerfiles/actions/workflows/cd.yml/badge.svg)](https://github.com/bdossantos/dockerfiles/actions/workflows/cd.yml)

Some Dockerfiles.

## Requirements

* docker
  * hadolint
  * dive
* pre-commit
* shellcheck
* container-structure-test

## Installation

```bash
make install docker-build
docker-compose up
```

## Test

```bash
make install test
```
