# Build
FROM python:3.9-slim-bullseye as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  VERSION=1.7.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3013,DL3042
RUN set -x \
  && mkdir "$PYTHONUSERBASE" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    automake \
    build-essential=12.9 \
    ca-certificates=20210119 \
    curl \
    gettext \
    git \
    libleptonica-dev \
    libpq-dev  \
    libqpdf-dev \
    libtool \
    nodejs \
    npm \
    zlib1g-dev \
  && git clone https://github.com/agl/jbig2enc /tmp/jbig2enc \
  && pushd /tmp/jbig2enc \
  && ./autogen.sh \
  && ./configure \
  && make \
  && popd \
  && mkdir /usr/local/src/paperless-ngx \
  && curl -sSL "https://github.com/paperless-ngx/paperless-ngx/archive/refs/tags/v${VERSION}.tar.gz" \
    | tar -xzf - --strip-components 1 -C /usr/local/src/paperless-ngx \
  && pushd /usr/local/src/paperless-ngx/src-ui \
  && npm install \
  && ./node_modules/.bin/ng build --prod \
  && popd \
  && mv /usr/local/src/paperless-ngx/src/* /app/ \
  && mv /usr/local/src/paperless-ngx/gunicorn.conf.py /app/gunicorn.conf.py \
  && pushd /app \
  && python -m pip install --upgrade pip \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
    -r /usr/local/src/paperless-ngx/requirements.txt \
  && python3 manage.py collectstatic --clear --no-input \
  && python3 manage.py compilemessages \
  && popd \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM python:3.9-slim-bullseye

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PAPERLESS_CONSUMPTION_DIR=/app/consume \
  PAPERLESS_CONVERT_BINARY=/usr/bin/convert \
  PAPERLESS_CONVERT_MEMORY_LIMIT=256 \
  PAPERLESS_DATA_DIR=/app/data \
  PAPERLESS_GS_BINARY=/usr/bin/gs \
  PAPERLESS_MEDIA_ROOT=/app/media \
  PAPERLESS_OCR_LANGUAGE=fra+eng \
  PAPERLESS_OPTIMIZE_THUMBNAILS=true \
  PAPERLESS_OPTIPNG_BINARY=/usr/bin/optipng \
  PAPERLESS_STATICDIR=/app/static \
  PAPERLESS_TASK_WORKERS=2 \
  PAPERLESS_THREADS_PER_WORKER=1 \
  PAPERLESS_TIME_ZONE=Europe/Paris \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="paperless-ngx" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.usage="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="paperless-ngx" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.title="paperless-ngx" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="paperless-ngx" \
  org.opencontainers.image.version="$VERSION"

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    # See https://paperless-ngx.readthedocs.io/en/latest/setup.html#bare-metal-route
    # Basic dependencies
    curl \
    gettext \
    gnupg \
    imagemagick \
    inotify-tools \
    libpq5 \
    sqlite3 \
    supervisor \
    tzdata \
    # fonts for text file thumbnail generation
    fonts-liberation \
    # for Numpy
    libatlas-base-dev \
    libxslt1-dev \
    # thumbnail size reduction
    ghostscript \
    icc-profiles-free \
    libxml2 \
    optipng \
    pngquant \
    unpaper \
    # Mime type detection \
    zlib1g \
    # Mime type detection
    file \
    libmagic-dev \
    media-types \
    # OCRmyPDF dependencies
    liblept5 \
    qpdf \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-deu \
    tesseract-ocr-fra \
    tesseract-ocr-ita \
    tesseract-ocr-spa \
    # Barcode splitter \
    libzbar0 \
    poppler-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  # GNUPG needs a home directory for some reason
  && usermod --home /dev/shm nobody

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build /tmp/jbig2enc/src/*.h /usr/local/include/
COPY --from=build /tmp/jbig2enc/src/.libs/libjbig2enc* /usr/local/lib/
COPY --from=build /tmp/jbig2enc/src/jbig2 /usr/local/bin/
COPY --from=build /usr/local/src/paperless-ngx/docker/imagemagick-policy.xml /etc/ImageMagick-6/policy.xml
COPY entrypoint.sh /entrypoint.sh
COPY copy-to-consumption-dir /app/copy-to-consumption-dir
COPY supervisord.conf /etc/supervisor/supervisord.conf

VOLUME ["/app/data", "/app/media","/app/consume", "/app/export", "/app/watch"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=300s \
  CMD curl -s --fail http://127.0.0.1:8000 &>/dev/null || exit 1

WORKDIR /app

USER nobody:nogroup

EXPOSE 8000/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
