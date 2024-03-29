FROM debian:10.8-slim

ENV \
  DEBIAN_FRONTEND=noninteractive \
  GOOGLE_APPLICATION_CREDENTIALS=/secrets/key.json \
  VERSION=0.32.0

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="gcsfuse" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.usage="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="gcsfuse" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.title="gcsfuse" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="gcsfuse" \
  org.opencontainers.image.version="$VERSION"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20200601~deb10u2 \
    curl=7.64.0-4+deb10u2 \
    gnupg=2.2.12-1+deb10u1 \
  # grab package from latest ubuntu lts apt repo cuz debian one is outdated ...
  && echo "deb http://packages.cloud.google.com/apt gcsfuse-bionic main" \
    | tee /etc/apt/sources.list.d/gcsfuse.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key add - \
  && apt-get update \
  && apt-get install -y --no-install-recommends gcsfuse="$VERSION" \
  && mkdir -p /mnt/gcs \
  && chown 65534:65534 /mnt/gcs \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /usr/src/* \
    /var/cache/debconf \
    /var/lib/apt/lists/*

USER 65534:65534

ENTRYPOINT ["/usr/bin/gcsfuse"]
CMD ["--help"]
