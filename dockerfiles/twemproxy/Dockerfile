FROM debian:11-slim as build

ENV VERSION=0.5.0

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

WORKDIR /tmp

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    autoconf \
    automake \
    ca-certificates \
    file \
    g++ \
    gcc \
    libc-dev \
    libtool \
    make \
    pkg-config \
  && curl -qL "https://github.com/twitter/twemproxy/releases/download/${VERSION}/twemproxy-${VERSION}.tar.gz" \
    | tar xvzf - --strip-components=1 \
  && autoreconf -fvi \
  && ./configure \
  && make \
  && make install \
  && apt-get remove -y \
    autoconf \
    curl \
    file \
    g++ \
    gcc \
    libc-dev \
    make \
    pkg-config \
  && apt-get -y autoremove \
  && apt-get -y autoclean \
  && apt-get -y clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# run
FROM debian:11-slim

COPY --from=build /usr/local/sbin/nutcracker /usr/local/sbin/nutcracker
COPY ./nutcracker.yml /etc/nutcracker.yml

EXPOSE 5000/tcp 22222/tcp

USER nobody:nogroup

ENTRYPOINT ["/usr/local/sbin/nutcracker"]
CMD ["-c", "/etc/nutcracker.yml"]
