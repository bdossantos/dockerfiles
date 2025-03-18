# Build
FROM golang:1.20-bookworm AS builder

ENV VERSION=2.1.5

# hadolint ignore=DL3003
RUN set -x \
  && git clone https://github.com/DNSCrypt/dnscrypt-proxy \
  && cd /go/dnscrypt-proxy/dnscrypt-proxy \
  && git checkout "tags/${VERSION}" \
  && env CGO_ENABLED=0 GOOS=linux go build -ldflags='-s -w -extldflags "-static"'

WORKDIR /tmp
COPY domains-blocklist-local-additions.txt .
COPY domains-blocklist.conf .
COPY domains-time-restricted.txt .
COPY domains-allowlist.txt .

RUN set -x \
  && python3 /go/dnscrypt-proxy//utils/generate-domains-blocklist/generate-domains-blocklist.py \
    --config /tmp/domains-blocklist.conf \
    --allowlist /tmp/domains-allowlist.txt \
    --time-restricted /tmp/domains-time-restricted.txt \
    --timeout 120 \
    --output-file /etc/dnscrypt-proxy-blocklist.txt \
  && wget -q https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts \
    -O /etc/hosts.tmp

# Run
FROM debian:12-slim

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="dnscrypt-proxy" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/DNSCrypt/dnscrypt-proxy" \
  org.label-schema.usage="https://github.com/DNSCrypt/dnscrypt-proxy/wiki" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="DNSCrypt" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/DNSCrypt/dnscrypt-proxy/wiki" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/DNSCrypt/dnscrypt-proxy" \
  org.opencontainers.image.title="dnscrypt-proxy" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="DNSCrypt" \
  org.opencontainers.image.version="$VERSION"

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20230311 \
    dnsutils=1:9.18.33-1~deb12u2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder \
  /go/dnscrypt-proxy/dnscrypt-proxy/dnscrypt-proxy \
  /usr/local/bin/dnscrypt-proxy
COPY --from=builder \
  /etc/dnscrypt-proxy-blocklist.txt \
  /etc/dnscrypt-proxy-blocklist.txt
COPY --from=builder \
  /etc/hosts.tmp \
  /etc/hosts
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy.toml

RUN set -x \
  && chmod 0444 /etc/dnscrypt-proxy.toml /etc/dnscrypt-proxy-blocklist.txt

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD dig +time=5 +tries=1 @127.0.0.1 -p 53 localhost

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/local/bin/dnscrypt-proxy"]
CMD ["-config", "/etc/dnscrypt-proxy.toml"]
