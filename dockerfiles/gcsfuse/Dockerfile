FROM debian:10.0-slim

ENV \
  DEBIAN_FRONTEND=noninteractive \
  GCSFUSE_VERSION=0.28.1 \
  GOOGLE_APPLICATION_CREDENTIALS=/secrets/key.json

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20190110 \
    curl=7.64.0-4 \
    gnupg=2.2.12-1+deb10u1 \
  && echo "deb http://packages.cloud.google.com/apt gcsfuse-stretch main" \
    | tee /etc/apt/sources.list.d/gcsfuse.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key add - \
  && apt-get update \
  && apt-get install -y --no-install-recommends gcsfuse="$GCSFUSE_VERSION" \
  && mkdir -p /mnt/gcs \
  && chown nobody.nogroup /mnt/gcs \
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /usr/src/* \
    /var/cache/debconf \
    /var/lib/apt/lists/*

USER nobody

ENTRYPOINT ["/usr/bin/gcsfuse"]
CMD ["--help"]
