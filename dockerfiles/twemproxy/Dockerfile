FROM debian:9.5-slim as build

ENV TWEMPROXY_VESRION 0.4.1

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

WORKDIR /tmp

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
  && curl -qL "https://github.com/twitter/twemproxy/archive/v${TWEMPROXY_VESRION}.tar.gz" \
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
FROM debian:9.5-slim

COPY --from=build /usr/local/sbin/nutcracker /usr/local/sbin/nutcracker
COPY ./nutcracker.yml /etc/nutcracker.yml

EXPOSE 5000/tcp 22222/tcp

USER nobody

ENTRYPOINT ["/usr/local/sbin/nutcracker"]
CMD ["-c", "/etc/nutcracker.yml"]
