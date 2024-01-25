# Build
FROM python:3.9-slim-bookworm as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=/app/bin/:/app/.venv/bin/:$PATH \
  PYTHONUSERBASE=/app \
  PYTHONDONTWRITEBYTECODE=1 \
  VERSION=2.4.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# hadolint ignore=DL3022
COPY --from=node:20-bookworm-slim /usr/local/ /usr/local/

# hadolint ignore=DL3013,DL3042
RUN set -x \
  && mkdir "$PYTHONUSERBASE" \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    automake \
    build-essential=12.9 \
    ca-certificates=20230311 \
    curl \
    default-libmysqlclient-dev \
    gettext \
    git \
    libleptonica-dev \
    libpq-dev  \
    libqpdf-dev \
    libtool \
    pkg-config \
    zlib1g-dev \
  && git clone https://github.com/agl/jbig2enc /tmp/jbig2enc \
  && pushd /tmp/jbig2enc \
  && ./autogen.sh \
  && ./configure \
  && make \
  && mkdir /usr/local/src/paperless-ngx \
  && curl -sSL "https://github.com/paperless-ngx/paperless-ngx/archive/refs/tags/v${VERSION}.tar.gz" \
    | tar -xzf - --strip-components 1 -C /usr/local/src/paperless-ngx \
  && pushd /usr/local/src/paperless-ngx/src-ui \
  && npm update npm --location=global \
  && npm ci \
  && ./node_modules/.bin/ng build --configuration production \
  && mv /usr/local/src/paperless-ngx/src/* /app/ \
  && mv /usr/local/src/paperless-ngx/Pipfile* /app/ \
  && mv /usr/local/src/paperless-ngx/gunicorn.conf.py /app/gunicorn.conf.py \
  && pushd /app \
  && python3 -m pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
    --upgrade \
    pipenv \
  && pipenv requirements > requirements.txt \
  && python3 -m pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
    -r requirements.txt \
  && python3 -W ignore::RuntimeWarning -m nltk.downloader -d '/tmp/nltk_data' snowball_data \
  && python3 -W ignore::RuntimeWarning -m nltk.downloader -d '/tmp/nltk_data' stopwords \
  && python3 -W ignore::RuntimeWarning -m nltk.downloader -d '/tmp/nltk_data' punkt \
  && python3 manage.py collectstatic --clear --no-input --link \
  && python3 manage.py compilemessages || true \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Run
FROM python:3.9-slim-bookworm

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
  PATH=/app/bin/:/app/.venv/bin/:$PATH \
  PYTHONUSERBASE=/app

ARG BUILD_DATE
ARG VCS_REF

# Packages need for running
ARG RUNTIME_PACKAGES="\
  # General utils
  curl \
  # Docker specific
  supervisor \
  # Timezones support
  tzdata \
  # fonts for text file thumbnail generation
  fonts-liberation \
  gettext \
  ghostscript \
  gnupg \
  icc-profiles-free \
  imagemagick \
  # Image processing
  liblept5 \
  liblcms2-2 \
  libtiff6 \
  libfreetype6 \
  libwebp7 \
  libopenjp2-7 \
  libimagequant0 \
  libraqm0 \
  libjpeg62-turbo \
  # PostgreSQL
  libpq5 \
  postgresql-client \
  # MySQL / MariaDB
  mariadb-client \
  # For Numpy
  libatlas3-base \
  # OCRmyPDF dependencies
  tesseract-ocr \
  tesseract-ocr-eng \
  tesseract-ocr-deu \
  tesseract-ocr-fra \
  tesseract-ocr-ita \
  tesseract-ocr-spa \
  unpaper \
  pngquant \
  # pikepdf / qpdf
  jbig2dec \
  libxml2 \
  libxslt1.1 \
  libgnutls30 \
  libqpdf29 \
  qpdf \
  # Mime type detection
  file \
  libmagic1 \
  media-types \
  zlib1g \
  # Barcode splitter
  libzbar0 \
  poppler-utils \
  # RapidFuzz on armv7
  libatomic1"

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
  && apt-get install --yes --quiet --no-install-recommends ${RUNTIME_PACKAGES} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  # GNUPG needs a home directory for some reason
  && usermod --home /dev/shm nobody

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build /tmp/jbig2enc/src/*.h /usr/local/include/
COPY --from=build /tmp/jbig2enc/src/.libs/libjbig2enc* /usr/local/lib/
COPY --from=build /tmp/jbig2enc/src/jbig2 /usr/local/bin/
COPY --from=build /tmp/nltk_data /usr/share/
COPY --from=build /usr/local/src/paperless-ngx/docker/imagemagick-policy.xml /etc/ImageMagick-6/policy.xml
COPY entrypoint.sh /entrypoint.sh
COPY copy-to-consumption-dir /app/copy-to-consumption-dir
COPY supervisord.conf /etc/supervisor/supervisord.conf

VOLUME ["/app/data", "/app/media","/app/consume", "/app/export", "/app/watch"]

HEALTHCHECK --interval=10s --timeout=5s --start-period=300s \
  CMD curl -s --fail http://127.0.0.1:8000 &>/dev/null || exit 1

WORKDIR /app

USER 65534:65534

EXPOSE 8000/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
