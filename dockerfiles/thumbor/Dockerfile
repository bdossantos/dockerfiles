# Build
FROM python:3.11-slim-bookworm as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  VERSION=7.7.4

# hadolint ignore=DL3013,DL3042
RUN set -x \
  && mkdir "$PYTHONUSERBASE" /etc/thumbor \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential=12.9 \
    ca-certificates=20230311 \
    cairosvg=2.5.2-1.1+deb12u1 \
    ffmpeg=7:5.1.5-0+deb12u1 \
    graphicsmagick=1.4+really1.3.40-4 \
    libcairo2-dev=1.16.0-7 \
    libcurl4-openssl-dev=7.88.1-10+deb12u6 \
    libgraphicsmagick++1-dev=1.4+really1.3.40-4 \
    libjpeg-dev=1:2.1.5-2 \
    libopencv-dev=4.6.0+dfsg-12 \
    libpng-dev=1.6.39-2 \
    libssl-dev=3.0.13-1~deb12u1 \
    libtiff5-dev=4.5.0-6+deb12u1 \
    webp=1.2.4-0.2+deb12u1 \
  && python -m pip install --upgrade pip \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      cairosvg==2.7.1 \
      numpy==1.22.4 \
      opencv-python-headless==4.5.5.64 \
      pillow==10.0.1 \
      pycurl==7.45.2 \
      remotecv==5.1.5 \
      tc_prometheus==2.0.0 \
      thumbor-plugins-gifv==0.1.5 \
      thumbor-plugins==0.2.4 \
      thumbor=="${VERSION}" \
  && thumbor-config > /etc/thumbor/thumbor.conf \
  && chown 65534:65534 /etc/thumbor/thumbor.conf \
  && chmod 0444 /etc/thumbor/thumbor.conf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM python:3.11-slim-bookworm

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PYTHONUSERBASE=/app \
  PATH=$PATH:/app/bin/

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="thumbor" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.usage="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="thumbor" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.title="thumbor" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="thumbor" \
  org.opencontainers.image.version="$VERSION"

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20230311 \
    cairosvg=2.5.2-1.1+deb12u1 \
    ffmpeg=7:5.1.5-0+deb12u1 \
    gifsicle=1.93-2 \
    graphicsmagick=1.4+really1.3.40-4 \
    libjpeg-turbo-progs=1:2.1.5-2 \
    libcurl4=7.88.1-10+deb12u6 \
    webp=1.2.4-0.2+deb12u1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build /etc/thumbor/thumbor.conf /etc/thumbor/thumbor.conf

USER 65534:65534

EXPOSE 8000/tcp 8888/tcp

ENTRYPOINT ["thumbor"]
