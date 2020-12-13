# Build
FROM golang:1.14-buster as builder

ENV DNSCRYPT_PROXY_VERSION=2.0.44

RUN go get -d -v github.com/jedisct1/dnscrypt-proxy/dnscrypt-proxy

WORKDIR /go/src/github.com/jedisct1/dnscrypt-proxy/dnscrypt-proxy
RUN set -x \
  && git pull --quiet \
  && git checkout "tags/${DNSCRYPT_PROXY_VERSION}" \
  && env CGO_ENABLED=0 GOOS=linux go build -ldflags='-s -w -extldflags "-static"'

WORKDIR /tmp
COPY domains-blacklist-local-additions.txt .
COPY domains-blacklist.conf .
COPY domains-time-restricted.txt .
COPY domains-whitelist.txt .

RUN set -x \
  && python /go/src/github.com/jedisct1/dnscrypt-proxy/utils/generate-domains-blacklists/generate-domains-blacklist.py \
    --config /tmp/domains-blacklist.conf \
    --whitelist /tmp/domains-whitelist.txt \
    --time-restricted /tmp/domains-time-restricted.txt \
    --timeout 120 > /etc/dnscrypt-proxy-blacklist.txt \
  && wget -q https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts \
    -O /etc/hosts.tmp

# Run
FROM debian:10.7-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20200601~deb10u1 \
    dnsutils=1:9.11.5.P4+dfsg-5.1+deb10u2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder \
  /go/src/github.com/jedisct1/dnscrypt-proxy/dnscrypt-proxy/dnscrypt-proxy \
  /usr/local/bin/dnscrypt-proxy
COPY --from=builder \
  /etc/dnscrypt-proxy-blacklist.txt \
  /etc/dnscrypt-proxy-blacklist.txt
COPY --from=builder \
  /etc/hosts.tmp \
  /etc/hosts
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy.toml

RUN set -x \
  && chmod 0444 /etc/dnscrypt-proxy.toml /etc/dnscrypt-proxy-blacklist.txt

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD dig +time=5 +tries=1 @127.0.0.1 -p 53 localhost

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/local/bin/dnscrypt-proxy"]
CMD ["-config", "/etc/dnscrypt-proxy.toml"]
