FROM debian:9.7-slim as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  TOR_VERSION=0.3.5.7 \
  TORSOCKS_VERSION=2.3.0

ENV BUILD_DEPENDENCIES \
  autoconf=2.69-10 \
  automake=1:1.15-6 \
  build-essential=12.3 \
  libevent-dev=2.0.21-stable-3 \
  libssl-dev=1.1.0j-1~deb9u1 \
  make=4.1-9.1 \
  zlib1g-dev=1:1.2.8.dfsg-5

# hadolint ignore=DL3008
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20161130+nmu1+deb9u1 \
    dirmngr=2.1.18-8~deb9u3 \
    gnupg=2.1.18-8~deb9u3 \
    libevent-2.0-5=2.0.21-stable-3 \
    libssl1.1=1.1.0j-1~deb9u1 \
    libtool=2.4.6-2 \
    net-tools=1.60+git20161116.90da8a0-1 \
    openssl=1.1.0f-3+deb9u2 \
    pwgen=2.07-1.1+b1 \
    wget=1.18-5+deb9u2 \
    zlib1g=1:1.2.8.dfsg-5 \
    $BUILD_DEPENDENCIES \
  && mkdir -p /tmp/tor /tmp/torsocks /etc/tor \
  && apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean \
  && rm -rf /var/lib/apt/lists/*

COPY ./torrc /etc/tor/torrc

WORKDIR /tmp/tor

RUN set -x \
  && wget "https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz" \
    -O "tor-${TOR_VERSION}.tar.gz" \
  && wget "https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz.asc" \
    -O "tor-${TOR_VERSION}.tar.gz.asc" \
  && tar -zxf "tor-${TOR_VERSION}.tar.gz" --strip-components=1 -C /tmp/tor \
  && ./configure \
  && make \
  && make install \
  && chown -R root.root /etc/tor \
  && chmod 0755 /etc/tor \
  && chmod 0444 /etc/tor/torrc

WORKDIR /tmp/torsocks

RUN set -x \
  && wget "https://github.com/dgoulet/torsocks/archive/v${TORSOCKS_VERSION}.tar.gz" \
    -O "torsocks-${TORSOCKS_VERSION}.tar.gz" \
  && tar -zxf "torsocks-${TORSOCKS_VERSION}.tar.gz" --strip-components=1 -C \
    '/tmp/torsocks' \
  && ./autogen.sh \
  && ./configure \
  && make \
  && make install

WORKDIR /

RUN set -x \
  && apt-get purge -y $BUILD_DEPENDENCIES \
  && apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean \
  && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* \
    /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb \
    /var/cache/apt/*.bin

EXPOSE 9050/tcp 9053/udp

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD torify wget -q -O - https://check.torproject.org/ \
    | grep -q 'Congratulations. This browser is configured to use Tor.'

USER nobody

ENTRYPOINT ["/usr/local/bin/tor"]
CMD ["--defaults-torrc", "/usr/local/etc/tor/torrc.sample", "-f", "/etc/tor/torrc"]
