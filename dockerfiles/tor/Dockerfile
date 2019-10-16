# Build
FROM debian:10.0-slim as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  TOR_VERSION=0.4.1.6 \
  TORSOCKS_VERSION=2.3.0

# hadolint ignore=DL3008
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    autoconf=2.69-11 \
    automake=1:1.16.1-4 \
    build-essential=12.6 \
    ca-certificates=20190110 \
    dirmngr=2.2.12-1+deb10u1 \
    gnupg=2.2.12-1+deb10u1 \
    libevent-2.1-6=2.1.8-stable-4 \
    libevent-dev=2.1.8-stable-4 \
    libssl-dev=1.1.1d-0+deb10u2 \
    libtool=2.4.6-9 \
    make=4.2.1-1.2 \
    net-tools=1.60+git20180626.aebd88e-1 \
    openssl=1.1.1d-0+deb10u2 \
    pwgen=2.08-1 \
    wget=1.20.1-1.1 \
    zlib1g-dev=1:1.2.11.dfsg-1 \
    zlib1g=1:1.2.11.dfsg-1 \
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
  && apt-get autoremove -y \
  && apt-get clean \
  && apt-get autoclean \
  && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* \
    /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb \
    /var/cache/apt/*.bin

# Geoip
FROM debian:10.0-slim as geoip

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    tor-geoipdb=0.3.5.8-1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM debian:10.0-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20190110 \
    libevent-2.1-6=2.1.8-stable-4 \
    libssl-dev=1.1.1d-0+deb10u2 \
    openssl=1.1.1d-0+deb10u2 \
    wget=1.20.1-1.1 \
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

USER nobody

ENTRYPOINT ["/usr/local/bin/tor"]
CMD ["--defaults-torrc", "/usr/local/etc/tor/torrc.sample", "-f", "/etc/tor/torrc"]
