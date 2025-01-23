# Build
FROM golang:1.20-bookworm AS builder

ENV VERSION=v1.4.0

# hadolint ignore=DL3003
RUN set -x \
  && git clone https://github.com/jusbrasil/pingdom-exporter \
  && cd /go/pingdom-exporter \
  && git checkout "tags/${VERSION}" \
  && make

# Run
FROM debian:12-slim

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="pingdom-exporter" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/jusbrasil/pingdom-exporter" \
  org.label-schema.usage="https://github.com/jusbrasil/pingdom-exporter" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="pingdom-exporter" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/jusbrasil/pingdom-exporter" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/jusbrasil/pingdom-exporter" \
  org.opencontainers.image.title="pingdom-exporter" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="pingdom-exporter" \
  org.opencontainers.image.version="$VERSION"

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20230311 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder \
  /go/pingdom-exporter/bin/pingdom-exporter \
  /usr/local/bin/pingdom-exporter

USER 65534:65534

ENTRYPOINT ["/usr/local/bin/pingdom-exporter"]
