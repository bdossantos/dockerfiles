# Build
FROM golang:1.24-trixie@sha256:5835f052b784aa39f2fe9070def3568605c8bc3fcd810f10402066348b61e716 AS builder

ENV VERSION=v1.5.2

# hadolint ignore=DL3003
# FIXME: `git checkout "tags/${VERSION}"`
RUN set -x \
  && git clone https://github.com/Aireuropa/resec \
  && cd /go/resec \
  && git checkout "tags/${VERSION}" \
  && env CGO_ENABLED=0 GOOS=linux go build -ldflags="-X 'main.Version=${VERSION}'" -a -installsuffix cgo -o build/resec  .

# Run
FROM debian:13-slim@sha256:f6e2cfac5cf956ea044b4bd75e6397b4372ad88fe00908045e9a0d21712ae3ba

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="resec" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/Aireuropa/resec" \
  org.label-schema.usage="https://github.com/Aireuropa/resec" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="resec" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/Aireuropa/resec" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/Aireuropa/resec" \
  org.opencontainers.image.title="resec" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="resec" \
  org.opencontainers.image.version="$VERSION"

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20250419 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder \
  /go/resec/build/resec \
  /usr/local/bin/resec

USER 65534:65534

ENTRYPOINT ["/usr/local/bin/resec"]
