# Build
FROM debian:11-slim as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  TORSOCKS_VERSION=2.3.0 \
  VERSION=0.4.6.7

# hadolint ignore=DL3008
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    autoconf=2.69-14 \
    automake=1:1.16.3-2 \
    build-essential=12.9 \
    ca-certificates=20210119 \
    dirmngr=2.2.27-2 \
    gnupg=2.2.27-2 \
    libevent-dev=2.1.12-stable-1 \
    libssl-dev=1.1.1k-1+deb11u1 \
    libtool=2.4.6-15 \
    make=4.3-4.1 \
    net-tools=1.60+git20181103.0eebece-1 \
    openssl=1.1.1k-1+deb11u1 \
    pwgen=2.08-2 \
    wget=1.21-1+b1 \
    zlib1g-dev=1:1.2.11.dfsg-2 \
  && mkdir -p /tmp/tor /tmp/torsocks /etc/tor \
  && apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

COPY ./torrc /etc/tor/torrc

WORKDIR /tmp/tor

RUN set -x \
  && wget -q "https://www.torproject.org/dist/tor-${VERSION}.tar.gz" \
    -O "tor-${VERSION}.tar.gz" \
  && wget -q "https://www.torproject.org/dist/tor-${VERSION}.tar.gz.asc" \
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
  && wget -q "https://github.com/dgoulet/torsocks/archive/v${TORSOCKS_VERSION}.tar.gz" \
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
FROM debian:11-slim as geoip

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    tor-geoipdb=0.4.5.10-1~deb11u1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM debian:11-slim

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
    ca-certificates=20210119 \
    libevent-2.1-7=2.1.12-stable-1 \
    libssl-dev=1.1.1k-1+deb11u1 \
    openssl=1.1.1k-1+deb11u1 \
    wget=1.21-1+b1 \
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

USER nobody:nogroup

ENTRYPOINT ["/usr/local/bin/tor"]
CMD ["--defaults-torrc", "/usr/local/etc/tor/torrc.sample", "-f", "/etc/tor/torrc"]
