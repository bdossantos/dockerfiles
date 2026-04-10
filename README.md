# Dockerfiles

[![CI](https://github.com/bdossantos/dockerfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/bdossantos/dockerfiles/actions/workflows/ci.yml)
[![CD](https://github.com/bdossantos/dockerfiles/actions/workflows/cd.yml/badge.svg)](https://github.com/bdossantos/dockerfiles/actions/workflows/cd.yml)

A collection of production-ready, security-hardened Dockerfiles using
multi-stage builds, pinned dependencies, and non-root users.

## Available Images

| Image | Description |
|-------|-------------|
| [anki](dockerfiles/anki) | [Anki](https://apps.ankiweb.net/) sync server for flashcard synchronization |
| [dnscrypt-proxy](dockerfiles/dnscrypt-proxy) | [DNSCrypt](https://dnscrypt.info/) proxy with encrypted DNS support |
| [paperless-ngx](dockerfiles/paperless-ngx) | [Paperless-ngx](https://docs.paperless-ngx.com/) document management system |
| [php-lol](dockerfiles/php-lol) | PHP-FPM with Nginx and common extensions (8.1, 8.2, 8.3, 8.4) |
| [pingdom-exporter](dockerfiles/pingdom-exporter) | Prometheus exporter for Pingdom metrics |
| [pint](dockerfiles/pint) | [Pint](https://cloudflare.github.io/pint/) – Prometheus rule linter by Cloudflare |
| [python-github-backup](dockerfiles/python-github-backup) | [python-github-backup](https://github.com/josegonzalez/python-github-backup) – GitHub repository backup tool |
| [radicale](dockerfiles/radicale) | [Radicale](https://radicale.org/) CalDAV/CardDAV server |
| [resec](dockerfiles/resec) | [Resec](https://github.com/YotpoLtd/resec) – Redis high-availability agent using Consul |
| [thumbor](dockerfiles/thumbor) | [Thumbor](https://www.thumbor.org/) smart image cropping and resizing service |
| [tor](dockerfiles/tor) | [Tor](https://www.torproject.org/) anonymity network daemon |
| [twemproxy](dockerfiles/twemproxy) | [Twemproxy](https://github.com/twitter/twemproxy) (nutcracker) – Memcached/Redis proxy |

## Requirements

- [Docker](https://docs.docker.com/get-docker/) (with Compose)
- [hadolint](https://github.com/hadolint/hadolint) – Dockerfile linter
- [dive](https://github.com/wagoodman/dive) – Docker image layer analyzer
- [container-structure-test](https://github.com/GoogleContainerTools/container-structure-test) – container test framework
- [shellcheck](https://www.shellcheck.net/) – shell script linter
- [pre-commit](https://pre-commit.com/) – git hook framework
- Python 3 (for the virtual environment)

## Quick Start

Install dependencies, build all images, and start services:

```bash
make install
make docker-build
docker-compose up
```

### Building a Single Image

```bash
docker-compose build <service>
```

## Testing

Run the full test suite (pre-commit, shellcheck, hadolint, container-structure-test, dive):

```bash
make test
```

Run individual checks:

```bash
make dockerfile-lint          # Lint all Dockerfiles with hadolint
make container-structure-test # Run container structure tests
make shellcheck               # Lint shell scripts
make pre-commit               # Run pre-commit hooks
make dive                     # Analyze image layers
```

Test a single image:

```bash
./bin/container-structure-test test \
  --image bdossantos/<service> \
  --config tests/<service>.yaml
```

## Project Structure

```
dockerfiles/
├── dockerfiles/
│   └── <service>/
│       ├── Dockerfile
│       └── ...                          # service-specific config
├── tests/
│   └── <service>.yaml                   # container-structure-test config
├── scripts/
│   ├── changelog                        # changelog generator
│   ├── container-structure-test-install  # install test framework
│   ├── dive                             # dive analyzer
│   └── dockerfile-lint                  # hadolint wrapper
├── docker-compose.yml                   # development composition
├── docker-compose.ci.yml                # CI composition
└── Makefile                             # build automation
```

## Available Make Targets

Run `make help` to list all targets:

```
changelog                      Generate CHANGELOG.md
container-structure-test       Run container-structure-test
container-structure-test-install Install container-structure-test
dive                           Run dive
docker-build                   Build all Dockerfiles
dockerfile-lint                Run hadolint on Dockerfile(s)
install                        Install all the things
pip-install                    Install pip dependencies
pre-commit                     Run pre-commit tests
shellcheck                     Run shellcheck on /scripts directory
test                           Run tests suite
venv                           Create python virtualenv if not exists
```

## Design Principles

- **Pinned versions** – base images, system packages, and application
  dependencies are version-pinned for reproducibility
- **Multi-stage builds** – separate build and runtime stages to minimize
  image size
- **Non-root by default** – services run as UID/GID `65534` (nobody/nogroup)
- **Read-only containers** – images are compatible with `read_only: true`
- **Minimal attack surface** – only essential runtime packages are installed
