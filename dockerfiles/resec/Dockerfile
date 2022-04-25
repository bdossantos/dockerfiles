# Build
FROM golang:1.16-bullseye as builder

ENV VERSION=v1.1.2

# hadolint ignore=DL3003
# FIXME: `git checkout "tags/${VERSION}"`
RUN set -x \
  && git clone https://github.com/seatgeek/resec \
  && cd /go/resec \
  && git checkout "tags/v.1.1.2" \
  && env CGO_ENABLED=0 GOOS=linux go build -ldflags="-X 'main.Version=${VERSION}'" -o build/resec

# Run
FROM debian:11-slim

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="resec" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/seatgeek/resec" \
  org.label-schema.usage="https://github.com/seatgeek/resec" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="resec" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/seatgeek/resec" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/seatgeek/resec" \
  org.opencontainers.image.title="resec" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="resec" \
  org.opencontainers.image.version="$VERSION"

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20210119 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder \
  /go/resec/build/resec \
  /usr/local/bin/resec

USER nobody:nogroup

ENTRYPOINT ["/usr/local/bin/resec"]
