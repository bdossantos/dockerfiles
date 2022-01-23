# Build
FROM python:3.9-slim-bullseye as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  VERSION=7.0.2

# hadolint ignore=DL3013,DL3042
RUN set -x \
  && mkdir "$PYTHONUSERBASE" /etc/thumbor \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential=12.9 \
    ca-certificates=20210119 \
    ffmpeg=7:4.3.3-0+deb11u1 \
    graphicsmagick=1.4+really1.3.36+hg16481-2 \
    libboost-python-dev=1.74.0.3 \
    libcurl4-openssl-dev=7.74.0-1.3+deb11u1 \
    libgraphicsmagick++1-dev=1.4+really1.3.36+hg16481-2 \
    libjpeg-dev=1:2.0.6-4 \
    libpng-dev=1.6.37-3 \
    libssl-dev=1.1.1k-1+deb11u1 \
    libtiff5-dev=4.2.0-1 \
    webp=0.6.1-2.1 \
  && python -m pip install --upgrade pip \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      cairosvg==2.5.2 \
      pillow==8.4.0 \
      pycurl==7.44.1 \
      pyexiv2==2.7.1 \
      tc_prometheus==0.1.1 \
      thumbor-plugins==0.2.4 \
      thumbor=="${VERSION}" \
  && thumbor-config > /etc/thumbor/thumbor.conf \
  && chown nobody.nogroup /etc/thumbor/thumbor.conf \
  && chmod 0444 /etc/thumbor/thumbor.conf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM python:3.9-slim-bullseye

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
    ca-certificates=20210119 \
    ffmpeg=7:4.3.3-0+deb11u1 \
    gifsicle=1.92-2+b1 \
    graphicsmagick=1.4+really1.3.36+hg16481-2 \
    libjpeg-turbo-progs=1:2.0.6-4 \
    libcurl4=7.74.0-1.3+deb11u1 \
    webp=0.6.1-2.1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build /etc/thumbor/thumbor.conf /etc/thumbor/thumbor.conf

USER nobody:nogroup

EXPOSE 8000/tcp 8888/tcp

ENTRYPOINT ["thumbor"]
