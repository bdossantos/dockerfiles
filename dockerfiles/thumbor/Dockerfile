# Build
FROM python:2.7.16-slim-stretch as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  THUMBOR_VERSION=6.7.0

RUN set -x \
  && mkdir "$PYTHONUSERBASE" /etc/thumbor \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential=12.3 \
    ca-certificates=20161130+nmu1+deb9u1 \
    ffmpeg=7:3.2.14-1~deb9u1 \
    graphicsmagick=1.3.30+hg15796-1~deb9u2 \
    libboost-python-dev=1.62.0.1 \
    libcurl4-openssl-dev=7.52.1-5+deb9u9 \
    libgraphicsmagick++1-dev=1.3.30+hg15796-1~deb9u2 \
    libjpeg-dev=1:1.5.1-2 \
    libopencv-dev=2.4.9.1+dfsg1-2 \
    libpng-dev=1.6.28-1+deb9u1 \
    libssl-dev=1.1.0j-1~deb9u1 \
    libtiff5-dev=4.0.8-2+deb9u4 \
    webp=0.5.2-1 \
  && python -m pip install --upgrade pip \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      graphicsmagick-engine==0.1.1 \
      opencv-engine==1.0.1 \
      opencv-python-headless==4.1.0.25 \
      remotecv==2.2.2 \
      thumbor-plugins==0.2.2 \
      thumbor=="${THUMBOR_VERSION}" \
  && thumbor-config > /etc/thumbor/thumbor.conf \
  && chown nobody.nogroup /etc/thumbor/thumbor.conf \
  && chmod 0444 /etc/thumbor/thumbor.conf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM python:2.7.16-slim-stretch

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PYTHONUSERBASE=/app \
  PATH=$PATH:/app/bin/

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20161130+nmu1+deb9u1 \
    ffmpeg=7:3.2.14-1~deb9u1 \
    graphicsmagick=1.3.30+hg15796-1~deb9u2 \
    libjpeg-turbo-progs=1:1.5.1-2 \
    webp=0.5.2-1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build /etc/thumbor/thumbor.conf /etc/thumbor/thumbor.conf

USER nobody

EXPOSE 8888/tcp

ENTRYPOINT ["thumbor"]
