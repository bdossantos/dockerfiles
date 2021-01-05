# Build
FROM python:3.9.1-slim-buster as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  THUMBOR_VERSION=7.0.0a5

RUN set -x \
  && mkdir "$PYTHONUSERBASE" /etc/thumbor \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential=12.6 \
    ca-certificates=20200601~deb10u1 \
    ffmpeg=7:4.1.6-1~deb10u1 \
    graphicsmagick=1.4+really1.3.35-1~deb10u1 \
    libboost-python-dev=1.67.0.1 \
    libcurl4-openssl-dev=7.64.0-4+deb10u1 \
    libgraphicsmagick++1-dev=1.4+really1.3.35-1~deb10u1 \
    libjpeg-dev=1:1.5.2-2+deb10u1 \
    libopencv-dev=3.2.0+dfsg-6 \
    libpng-dev=1.6.36-6 \
    libssl-dev=1.1.1d-0+deb10u4 \
    libtiff5-dev=4.1.0+git191117-2~deb10u1 \
    webp=0.6.1-2 \
  && python -m pip install --upgrade pip \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      graphicsmagick-engine==0.1.1 \
      opencv-engine==1.0.1 \
      opencv-python-headless==4.4.0.46 \
      pillow==7.2.0 \
      pycurl==7.43.0.6 \
      remotecv==3.0.0 \
      tc_prometheus==0.1.1 \
      thumbor-plugins==0.2.4 \
      thumbor=="${THUMBOR_VERSION}" \
  && thumbor-config > /etc/thumbor/thumbor.conf \
  && chown nobody.nogroup /etc/thumbor/thumbor.conf \
  && chmod 0444 /etc/thumbor/thumbor.conf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM python:3.9.1-slim-buster

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PYTHONUSERBASE=/app \
  PATH=$PATH:/app/bin/

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20200601~deb10u1 \
    ffmpeg=7:4.1.6-1~deb10u1 \
    gifsicle=1.91-5 \
    graphicsmagick=1.4+really1.3.35-1~deb10u1 \
    libjpeg-turbo-progs=1:1.5.2-2+deb10u1 \
    libcurl4=7.64.0-4+deb10u1 \
    webp=0.6.1-2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build /etc/thumbor/thumbor.conf /etc/thumbor/thumbor.conf

USER nobody:nogroup

EXPOSE 8000/tcp 8888/tcp

ENTRYPOINT ["thumbor"]
