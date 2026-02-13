# GitHub Copilot Instructions for Dockerfiles Repository

## Repository Overview

This repository contains production-ready Dockerfiles for various applications including:
- Python-based services (anki, radicale, thumbor, python-github-backup)
- PHP services (php-lol with multiple versions: 8.1, 8.2, 8.3, 8.4)
- Networking tools (dnscrypt-proxy, tor, twemproxy)
- Infrastructure services (gcsfuse, resec, pingdom-exporter, paperless-ngx)
- Development tools (pint)

## Architecture Patterns

### Multi-Stage Builds
All Dockerfiles use multi-stage builds with two main stages:
1. **Build Stage**: Install build dependencies, compile/install software, configure directories
2. **Run Stage**: Minimal runtime image with only necessary dependencies

```dockerfile
# Build
FROM python:3.13-bookworm AS build
# ... build steps ...

# Run
FROM python:3.13-bookworm
# ... runtime setup ...
```

### Base Images
- **Python services**: Use `python:3.13-bookworm` with pinned SHA256 digest
- **PHP services**: Use `php:8.x-fpm-bookworm` with specific minor versions

## Security Best Practices

### 1. Pin All Versions
- Base images MUST use SHA256 digests: `python:3.13-bookworm@sha256:...`
- System packages MUST include full version with latest security patches (e.g., `curl=7.88.1-10+deb12u12`)
- Python packages MUST specify exact version: `thumbor==7.7.7`
- Always pin versions for reproducibility and security
- When updating, use the latest available security patch version at that time

### 2. Non-Root User
- All services run as user `65534:65534` (nobody/nogroup)
- Use `USER 65534:65534` directive before ENTRYPOINT
- Set ownership with `--chown=65534:65534` when copying files

### 3. Minimal Attack Surface
- Use `DEBIAN_FRONTEND=noninteractive` to avoid interactive prompts
- Clean up after installations: `apt-get clean && rm -rf /var/lib/apt/lists/*`
- Use `--no-install-recommends` for apt-get to minimize packages
- Separate build and runtime dependencies

### 4. Read-Only Containers
- Services should be compatible with `read_only: true` in docker-compose
- Store mutable data in volumes, not the container filesystem

## Standard Patterns

### Environment Variables
```dockerfile
ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  VERSION=x.y.z
```

### Python Application Structure
- Install to user base: `PYTHONUSERBASE=/app`
- Use pip with: `--no-cache-dir --prefix="${PYTHONUSERBASE}"`
- Add `/app/bin/` to PATH for executables

### Directory Structure
- `/config`: Configuration files (owned by 65534:65534, mode 0750 for dirs, 0444 for files)
- `/data`: Persistent data volumes (owned by 65534:65534, mode 0750)
- `/etc/<service>`: Service-specific config files

### OCI Labels
Include both legacy `org.label-schema.*` and modern `org.opencontainers.image.*` labels:
```dockerfile
LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="<service>" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.title="<service>" \
  org.opencontainers.image.version="$VERSION"
```

### Healthchecks
Include HEALTHCHECK directives where applicable:
```dockerfile
HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
  CMD curl -s --fail http://127.0.0.1:<port>/<path> &>/dev/null || exit 1
```

## Testing

### Linting with hadolint
- Run `make dockerfile-lint` to lint all Dockerfiles
- Use `# hadolint ignore=DL3xxx` comments for intentional exceptions
- Common exceptions used in this repository:
  - `DL3008`: We satisfy this by pinning all package versions
  - `DL3013`: We satisfy this by pinning all pip package versions
  - `DL3042`: Used for build caches to improve performance

### Container Testing with serverspec
- Each service has a corresponding `<service>_spec.rb` test file in `spec/`
- Tests verify:
  - File existence, ownership, permissions
  - SHA256 checksums for critical files
  - Configuration content
  - Service availability via HTTP checks
- Run tests with: `make serverspec`

### Image Efficiency with dive
- Analyzes layer efficiency and wasted space
- Run with: `make dive`
- Ensures multi-stage builds are effective

## Development Workflow

### Building Images
```bash
make install              # Install all dependencies
make docker-build         # Build all images in parallel
docker-compose up         # Start services
```

### Running Tests
```bash
make test                 # Run full test suite (pre-commit, shellcheck, hadolint, serverspec, dive)
make dockerfile-lint      # Lint Dockerfiles only
make serverspec          # Run serverspec tests only
```

### Pre-commit Hooks
The repository uses pre-commit hooks for:
- Detecting large files, merge conflicts, private keys
- YAML validation
- Trailing whitespace and end-of-file fixes

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/) format for all commit messages:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Common types:**
- `feat`: New feature or capability
- `fix`: Bug fix
- `docs`: Documentation changes
- `chore`: Maintenance tasks (dependencies, config)
- `refactor`: Code refactoring without feature changes
- `test`: Adding or updating tests
- `ci`: CI/CD configuration changes
- `perf`: Performance improvements
- `build`: Build system changes

**Examples:**
```
feat(radicale): add support for bcrypt password hashing
fix(thumbor): update to version 7.7.7 for security patches
docs: update README with new installation instructions
chore(deps): update python base image to 3.13-bookworm
ci: add CodeQL security scanning workflow
```

## Dockerfile Guidelines

### When Creating New Dockerfiles

1. **Follow the multi-stage pattern**: Separate build and runtime stages
2. **Pin everything**: Base images (with digest), system packages, application packages
3. **Security first**: 
   - Run as non-root user (65534:65534)
   - Set appropriate file permissions
   - Minimize installed packages
4. **Add tests**: Create corresponding `<service>_spec.rb` file
5. **Document**: Update README.md if adding new service
6. **Add to docker-compose**: Include service in docker-compose.yml

### When Updating Versions

1. **Update VERSION env var** in the Dockerfile
2. **Update base image digest** if needed
3. **Update system package versions** to latest security patches
4. **Update SHA256 checksums** in serverspec tests after rebuilding
5. **Test thoroughly**: Run full test suite

### Common Commands Pattern

Use `set -x` for debugging and command chaining:
```dockerfile
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    package1=version1 \
    package2=version2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
```

## File Organization

```
dockerfiles/
├── <service>/
│   ├── Dockerfile              # Main Dockerfile
│   ├── <service>.cfg           # Configuration files (if needed)
│   └── ...                     # Other service-specific files
├── spec/
│   ├── <service>_spec.rb       # Serverspec tests
│   └── spec_helper.rb          # Test helper
├── scripts/
│   ├── dockerfile-lint         # Linting script
│   ├── changelog               # Changelog generator
│   └── dive                    # Dive analyzer script
├── docker-compose.yml          # Development composition
├── docker-compose.ci.yml       # CI composition
└── Makefile                    # Build automation
```

## CI/CD

- GitHub Actions workflows in `.github/workflows/`
- `ci.yml`: Continuous Integration - runs tests on PRs
- `cd.yml`: Continuous Deployment - builds and publishes images
- Dependabot keeps dependencies updated

## Best Practices Summary

1. ✅ **Always** pin versions (base images, packages, dependencies)
2. ✅ **Always** use multi-stage builds
3. ✅ **Always** run as non-root user (65534:65534)
4. ✅ **Always** clean up after installations
5. ✅ **Always** set appropriate file permissions
6. ✅ **Always** add tests for new services
7. ✅ **Always** use `--no-install-recommends` with apt-get
8. ✅ **Never** run services as root
9. ✅ **Never** leave credentials or secrets in images
10. ✅ **Never** install unnecessary packages

## Useful Commands

```bash
# Full development cycle
make install docker-build test

# Build single service
docker-compose build <service>

# Test single service
bundle exec rspec spec/<service>_spec.rb

# Lint specific Dockerfile
hadolint dockerfiles/<service>/Dockerfile

# Check image efficiency
CI=true dive <image>
```
