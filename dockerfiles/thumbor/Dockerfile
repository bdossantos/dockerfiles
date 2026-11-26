# Build
# Debian's own Python (3.13) is used here on purpose: it must match the ABI of
# the system Python shipped in gcr.io/distroless/python3-debian13.
FROM debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0 AS build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONPATH=/app/lib/python3.13/site-packages \
  VERSION=7.8.0

# hadolint ignore=DL3013,DL3042
RUN set -x \
  && mkdir /app /etc/thumbor \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential=12.12 \
  ca-certificates=20250419+deb13u1 \
  ffmpeg=7:7.1.5-0+deb13u1 \
  gifsicle=1.96-1 \
  libavif-dev=1.2.1-1.2 \
  libcairo2=1.18.4-1+b1 \
  libcairo2-dev=1.18.4-1+b1 \
  libcurl4-openssl-dev=8.14.1-2+deb13u7 \
  libjpeg-dev=1:2.1.5-4 \
  libjpeg-turbo-progs=1:2.1.5-4 \
  libopencv-dev=4.10.0+dfsg-5 \
  libpng-dev=1.6.48-1+deb13u6 \
  libssl-dev=3.5.9-1~deb13u1 \
  libtiff5-dev=4.7.0-3+deb13u3 \
  python3=3.13.5-1 \
  python3-dev=3.13.5-1 \
  python3-pip=25.1.1+dfsg-1 \
  && pip install \
  --break-system-packages \
  --ignore-installed \
  --no-cache-dir \
  --prefix=/app \
  cairosvg==2.9.1 \
  numpy==2.5.4 \
  opencv-python-headless==4.13.0.92 \
  pillow==12.3.0 \
  pillow-avif-plugin==1.6.0 \
  pycurl==7.49.0 \
  remotecv==5.2.0 \
  tc_prometheus==4.0.0 \
  thumbor-plugins-gifv==0.1.5 \
  thumbor-plugins==0.2.4 \
  thumbor=="${VERSION}" \
  && test -d "$PYTHONPATH" \
  && thumbor-config > /etc/thumbor/thumbor.conf \
  && chown 65534:65534 /etc/thumbor/thumbor.conf \
  && chmod 0444 /etc/thumbor/thumbor.conf \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Distroless has no package manager: copy the external binaries thumbor shells
# out to (jpegtran, gifsicle, ffmpeg) and every shared library they, the
# compiled Python extensions and libcairo (dlopen'ed by cairocffi) need into
# /rootfs. glibc itself is excluded, the distroless base provides it.
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -x \
  && mkdir /rootfs \
  && { \
  printf '%s\n' /usr/bin/ffmpeg /usr/bin/gifsicle /usr/bin/jpegtran; \
  find /usr/lib -name 'libcairo.so.2' -print; \
  find /app -type f -name '*.so*' -print; \
  } > /tmp/elf.list \
  && { xargs -a /tmp/elf.list ldd > /tmp/ldd.out 2>/dev/null || true; } \
  && ! grep 'not found' /tmp/ldd.out \
  && awk '/=> \//{print $3}' /tmp/ldd.out \
  | sed 's#^/lib/#/usr/lib/#' \
  | grep -Ev '^/app/|/(ld-linux[^/]*|libc|libm|libdl|libpthread|librt|libresolv|libutil|libnsl|libnss_[a-z]+)\.so' \
  | sort -u > /tmp/libs.list \
  && cat /tmp/libs.list /usr/bin/ffmpeg /usr/bin/gifsicle /usr/bin/jpegtran /etc/fonts/fonts.conf 2>/dev/null \
  | grep '^/' \
  | xargs -I{} cp -L --parents {} /rootfs/ \
  && test -x /rootfs/usr/bin/jpegtran

# Run
FROM gcr.io/distroless/python3-debian13:nonroot@sha256:72de1dda9d4c52c370e2ef2d93c28e3e1a8193c92058b7dfa42bace38a83d114

ENV \
  PYTHONPATH=/app/lib/python3.13/site-packages \
  PYTHONDONTWRITEBYTECODE=1

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

COPY --from=build /rootfs/ /
COPY --from=build /app /app
COPY --from=build /etc/thumbor/thumbor.conf /etc/thumbor/thumbor.conf

USER 65534:65534

EXPOSE 8000/tcp 8888/tcp

ENTRYPOINT ["/usr/bin/python3", "/app/bin/thumbor"]
