FROM debian:9.5-slim as build

ENV \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  FIZZ_VERSION=v2018.11.05.00 \
  FOLLY_VERSION=v2018.11.05.00 \
  MCROUTER_VERSION=v0.38.0-release \
  WANGLE_VERSION=v2018.11.05.00

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    binutils-dev \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    libboost-all-dev \
    libboost-context-dev \
    libdouble-conversion-dev \
    libevent-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libjemalloc-dev \
    liblzma-dev \
    libsnappy-dev \
    libsodium-dev \
    libssl1.0-dev \
    libtool \
    pkg-config \
    python-dev \
    ragel \
    zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/folly

RUN curl -Ls "https://github.com/facebook/folly/archive/${FOLLY_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cmake configure . \
  && make \
  && make install

WORKDIR /usr/src/fizz

RUN curl -Ls "https://github.com/facebookincubator/fizz/archive/${FIZZ_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cd fizz \
  && cmake . \
  && make install

WORKDIR /usr/src/wangle

RUN curl -Ls "https://github.com/facebook/wangle/archive/${WANGLE_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cmake configure wangle \
  && make \
  && make install

WORKDIR /usr/src/mcrouter

RUN curl -Ls "https://github.com/facebook/mcrouter/archive/${MCROUTER_VERSION}.tar.gz" \
  | tar xvzf - --strip-components=1 \
  && cd mcrouter \
  && autoreconf --install \
  && ./configure \
  && make \
  && rm -rf /usr/src/*

# run
FROM debian:9.5-slim

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libssl1.0.2 \
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
