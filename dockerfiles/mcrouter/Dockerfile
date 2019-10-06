FROM debian:10.1-slim as build

ENV \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  FBTHRIFT_VERSION=v2019.09.30.00 \
  FIZZ_VERSION=v2019.09.30.00 \
  FOLLY_VERSION=v2019.09.30.00 \
  MCROUTER_VERSION=v0.40.0 \
  WANGLE_VERSION=v2019.09.30.00

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    autoconf=2.69-11 \
    automake=1:1.16.1-4 \
    binutils-dev=2.31.1-16 \
    bison=2:3.3.2.dfsg-1 \
    build-essential=12.6 \
    ca-certificates=20190110 \
    cmake=3.13.4-1 \
    curl=7.64.0-4 \
    flex=2.6.4-6.2 \
    g++=4:8.3.0-1 \
    gcc=4:8.3.0-1 \
    git=1:2.20.1-2 \
    gnutls-bin=3.6.7-4 \
    libboost-all-dev=1.67.0.1 \
    libboost-context-dev=1.67.0.1 \
    libbz2-dev=1.0.6-9.1 \
    libdouble-conversion-dev=3.1.0-3 \
    libevent-dev=2.1.8-stable-4 \
    libgflags-dev=2.2.2-1 \
    libgoogle-glog-dev=0.3.5-1 \
    libgtest-dev=1.8.1-3 \
    libjemalloc-dev=5.1.0-3 \
    liblzma-dev=5.2.4-1 \
    libsnappy-dev=1.1.7-1 \
    libsodium-dev=1.0.17-1 \
    libssl-dev=1.1.1c-1 \
    libssl1.1=1.1.1c-1 \
    libtool=2.4.6-9 \
    libfmt-dev=5.2.1+ds-2 \
    openssl=1.1.1c-1 \
    pkg-config=0.29-6 \
    python-dev=2.7.16-1 \
    ragel=6.10-1 \
    zlib1g=1:1.2.11.dfsg-1 \
    zlib1g-dev=1:1.2.11.dfsg-1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/folly

RUN curl -Ls "https://github.com/facebook/folly/archive/${FOLLY_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cmake configure . \
  && make -j $(nproc) \
  && make install

WORKDIR /usr/src/fizz

RUN curl -Ls "https://github.com/facebookincubator/fizz/archive/${FIZZ_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cd fizz \
  && cmake . \
  && make -j $(nproc) \
  && make install

WORKDIR /usr/src/wangle

RUN curl -Ls "https://github.com/facebook/wangle/archive/${WANGLE_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cmake configure wangle \
  && make -j $(nproc) \
  && make install

WORKDIR /usr/src/fbthrift

RUN curl -Ls "https://github.com/facebook/fbthrift/archive/${FBTHRIFT_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cd build \
  && cmake -Dcompiler_only=ON .. \
  && make -j $(nproc) \
  && make install

WORKDIR /usr/src/mcrouter

RUN curl -Ls "https://github.com/facebook/mcrouter/archive/${MCROUTER_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cd mcrouter \
  && autoreconf --install \
  && LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/local/lib \
    ./configure --prefix=/usr/local/mcrouter \
  && make -j $(nproc) \
  && rm -rf /usr/src/*

#strip "$INSTALL_DIR"/bin/mcrouter
#strip "$INSTALL_DIR"/bin/mcpiper
#strip --strip-unneeded "$INSTALL_DIR"/lib/libfolly*.so

# run
FROM debian:10.0-slim

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libssl1.1 \
    libevent-2.0-5 \
    libgflags2v5 \
    libgoogle-glog0v5 \
    libboost-context1.62.0 \
    libboost-filesystem1.62.0 \
    libboost-program-options1.62.0 \
    libboost-system1.62.0 \
    libboost-regex1.62.0 \
    libboost-thread1.62.0 \
    libdouble-conversion1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /mcrouter/mcrouter/mcrouter /usr/local/bin/mcrouter

CMD ["/usr/local/bin/mcrouter"]
