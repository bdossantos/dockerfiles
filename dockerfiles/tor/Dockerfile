# Build
FROM debian:12-slim as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  TORSOCKS_VERSION=v2.4.0 \
  VERSION=0.4.8.12

# hadolint ignore=DL3008
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    autoconf=2.71-3 \
    automake=1:1.16.5-1.3 \
    build-essential=12.9 \
    ca-certificates=20230311 \
    dirmngr=2.2.40-1.1 \
    gnupg=2.2.40-1.1 \
    libevent-dev=2.1.12-stable-8 \
    libssl-dev=3.0.15-1~deb12u1 \
    libtool-bin=2.4.7-7~deb12u1 \
    make=4.3-4.1 \
    net-tools=2.10-0.1 \
    openssl=3.0.15-1~deb12u1 \
    pwgen=2.08-2 \
    wget=1.21.3-1+b2 \
    zlib1g-dev=1:1.2.13.dfsg-1 \
  && mkdir -p /tmp/tor /tmp/torsocks /etc/tor \
  && apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

COPY ./torrc /etc/tor/torrc

WORKDIR /tmp/tor

RUN set -x \
  && wget -q "https://dist.torproject.org/tor-${VERSION}.tar.gz" \
    -O "tor-${VERSION}.tar.gz" \
  && wget -q "https://dist.torproject.org/tor-${VERSION}.tar.gz.sha256sum.asc" \
    -O "tor-${VERSION}.tar.gz.asc" \
  && tar -zxf "tor-${VERSION}.tar.gz" --strip-components=1 -C /tmp/tor \
  && ./configure \
  && make \
  && make install \
  && chown -R root.root /etc/tor \
  && chmod 0755 /etc/tor \
  && chmod 0444 /etc/tor/torrc

WORKDIR /tmp/torsocks

RUN set -x \
  && wget -q "https://gitlab.torproject.org/tpo/core/torsocks/-/archive/${TORSOCKS_VERSION}/torsocks-${TORSOCKS_VERSION}.tar.gz" \
    -O "torsocks-${TORSOCKS_VERSION}.tar.gz" \
  && tar -zxf "torsocks-${TORSOCKS_VERSION}.tar.gz" --strip-components=1 -C \
    '/tmp/torsocks' \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make install

WORKDIR /

RUN set -x \
  && apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean \
  && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* \
    /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb \
    /var/cache/apt/*.bin

# Geoip
FROM debian:12-slim as geoip

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    tor-geoipdb=0.4.7.16-1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="tor" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.usage="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="tor" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.title="tor" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="tor" \
  org.opencontainers.image.version="$VERSION"

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20230311 \
    libevent-2.1-7=2.1.12-stable-8 \
    libssl-dev=3.0.15-1~deb12u1 \
    openssl=3.0.15-1~deb12u1 \
    wget=1.21.3-1+b2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /etc/tor/torrc /etc/tor/torrc
COPY --from=build /usr/local/bin/tor /usr/local/bin/tor
COPY --from=build /usr/local/bin/tor-resolve /usr/local/bin/tor-resolve
COPY --from=build /usr/local/bin/torify /usr/local/bin/torify
COPY --from=build /usr/local/bin/torsocks /usr/local/bin/torsocks
COPY --from=build /usr/local/etc/tor/ /usr/local/etc/tor/
COPY --from=build /usr/local/lib/torsocks /usr/local/lib/torsocks
COPY --from=geoip /usr/share/tor/geoip /usr/share/tor/geoip
COPY --from=geoip /usr/share/tor/geoip6 /usr/share/tor/geoip6

EXPOSE 9050/tcp 9053/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD torify wget -q -O - https://check.torproject.org/ \
    | grep -q 'Congratulations. This browser is configured to use Tor.'

USER 65534:65534

ENTRYPOINT ["/usr/local/bin/tor"]
CMD ["--defaults-torrc", "/usr/local/etc/tor/torrc.sample", "-f", "/etc/tor/torrc"]
