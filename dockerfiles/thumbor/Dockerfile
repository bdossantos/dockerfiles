# Build
FROM python:2.7.16-slim-buster as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  THUMBOR_VERSION=6.7.0

RUN set -x \
  && mkdir "$PYTHONUSERBASE" /etc/thumbor \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential=12.6 \
    ca-certificates=20190110 \
    ffmpeg=7:4.1.4-1~deb10u1 \
    graphicsmagick=1.4~hg15978-1 \
    libboost-python-dev=1.67.0.1 \
    libcurl4-openssl-dev=7.64.0-4 \
    libgraphicsmagick++1-dev=1.4~hg15978-1 \
    libjpeg-dev=1:1.5.2-2 \
    libopencv-dev=3.2.0+dfsg-6 \
    libpng-dev=1.6.36-6 \
    libssl-dev=1.1.1d-0+deb10u2 \
    libtiff5-dev=4.0.10-4 \
    webp=0.6.1-2 \
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
FROM python:2.7.16-slim-buster

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PYTHONUSERBASE=/app \
  PATH=$PATH:/app/bin/

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20190110 \
    ffmpeg=7:4.1.4-1~deb10u1 \
    gifsicle=1.91-5 \
    graphicsmagick=1.4~hg15978-1 \
    libjpeg-turbo-progs=1:1.5.2-2+b1 \
    webp=0.6.1-2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build /etc/thumbor/thumbor.conf /etc/thumbor/thumbor.conf

USER nobody

EXPOSE 8888/tcp

ENTRYPOINT ["thumbor"]
