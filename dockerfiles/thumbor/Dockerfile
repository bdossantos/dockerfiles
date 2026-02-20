# Build
FROM python:3.13-trixie@sha256:a7394c629de7c2a0d1cebf36149724fcaf4d71929f69432f1e18520c95af7853 AS build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  VERSION=7.7.7

# hadolint ignore=DL3013,DL3042
RUN set -x \
  && mkdir "$PYTHONUSERBASE" /etc/thumbor \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential=12.12 \
  ca-certificates=20250419 \
  cairosvg=2.7.1-2 \
  ffmpeg=7:7.1.3-0+deb13u1 \
  graphicsmagick=1.4+really1.3.45+hg17696-1 \
  libavif-dev=1.2.1-1.2 \
  libcairo2-dev=1.18.4-1+b1 \
  libcurl4-openssl-dev=8.14.1-2+deb13u2 \
  libgraphicsmagick++1-dev=1.4+really1.3.45+hg17696-1 \
  libjpeg-dev=1:2.1.5-4 \
  libopencv-dev=4.10.0+dfsg-5 \
  libpng-dev=1.6.48-1+deb13u3 \
  libssl-dev=3.5.4-1~deb13u2 \
  libtiff5-dev=4.7.0-3+deb13u1 \
  webp=1.5.0-0.1 \
  && python -m pip install --upgrade pip \
  && pip install \
  --no-cache-dir \
  --prefix="${PYTHONUSERBASE}" \
  cairosvg==2.7.1 \
  numpy==1.26.4 \
  opencv-python-headless==4.11.0.86 \
  pillow==10.4.0 \
  pillow-avif-plugin==1.5.2 \
  pycurl==7.45.6 \
  remotecv==5.1.9 \
  tc_prometheus==4.0.0 \
  thumbor-plugins-gifv==0.1.5 \
  thumbor-plugins==0.2.4 \
  thumbor=="${VERSION}" \
  && thumbor-config > /etc/thumbor/thumbor.conf \
  && chown 65534:65534 /etc/thumbor/thumbor.conf \
  && chmod 0444 /etc/thumbor/thumbor.conf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM python:3.13-trixie@sha256:a7394c629de7c2a0d1cebf36149724fcaf4d71929f69432f1e18520c95af7853

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
  ca-certificates=20250419 \
  cairosvg=2.7.1-2 \
  ffmpeg=7:7.1.3-0+deb13u1 \
  gifsicle=1.96-1 \
  graphicsmagick=1.4+really1.3.45+hg17696-1 \
  libavif16=1.2.1-1.2 \
  libcurl4t64=8.14.1-2+deb13u2 \
  libjpeg-turbo-progs=1:2.1.5-4 \
  webp=1.5.0-0.1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build /etc/thumbor/thumbor.conf /etc/thumbor/thumbor.conf

USER 65534:65534

EXPOSE 8000/tcp 8888/tcp

ENTRYPOINT ["thumbor"]
