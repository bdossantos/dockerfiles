# Build
FROM golang:1.10 as builder

ENV DNSCRYPT_PROXY_VERSION=2.0.13

RUN go get -d -v github.com/jedisct1/dnscrypt-proxy/dnscrypt-proxy

WORKDIR /go/src/github.com/jedisct1/dnscrypt-proxy/dnscrypt-proxy
RUN set -x \
  && git pull --quiet \
  && git checkout "tags/${DNSCRYPT_PROXY_VERSION}" \
  && env CGO_ENABLED=0 GOOS=linux go build -ldflags='-s -w'

WORKDIR /tmp
COPY domains-blacklist-local-additions.txt .
COPY domains-blacklist.conf .
COPY domains-time-restricted.txt .
COPY domains-whitelist.txt .

RUN set -x \
  && python /go/src/github.com/jedisct1/dnscrypt-proxy/utils/generate-domains-blacklists/generate-domains-blacklist.py \
    --timeout 120 > /etc/dnscrypt-proxy-blacklist.txt \
  && wget -q https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts \
    -O /etc/hosts

# Run
FROM alpine:3.3

RUN set -x \
  && apk --no-cache add ca-certificates=20161130-r0 bind-tools=9.10.4_p8-r1

COPY --from=builder \
  /go/src/github.com/jedisct1/dnscrypt-proxy/dnscrypt-proxy/dnscrypt-proxy \
  /usr/local/bin/dnscrypt-proxy
COPY --from=builder \
  /etc/dnscrypt-proxy-blacklist.txt \
  /etc/dnscrypt-proxy-blacklist.txt
COPY --from=builder \
  /etc/hosts \
  /etc/hosts
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy.toml

RUN set -x \
  && setcap cap_net_bind_service=+pe /usr/local/bin/dnscrypt-proxy \
  && chmod 0444 /etc/dnscrypt-proxy.toml /etc/dnscrypt-proxy-blacklist.txt

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD dig +time=5 +tries=1 @127.0.0.1 -p 53 localhost

USER nobody

EXPOSE 53/tcp 53/udp

ENTRYPOINT ["/usr/local/bin/dnscrypt-proxy"]
CMD ["-config", "/etc/dnscrypt-proxy.toml"]
