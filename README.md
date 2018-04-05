# Dockerfiles

[![Build Status](https://travis-ci.org/bdossantos/dockerfiles.svg?branch=master)](https://travis-ci.org/bdossantos/dockerfiles)

Some Dockerfiles.

## Requirements

* hadolint
* pre-commit
* shellcheck
* ruby
  * bundler
  * serverspec

## Installation

```bash
make install docker-build
docker-compose up
```

## Test

```bash
make install test
```
