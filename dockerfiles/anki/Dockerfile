## build
FROM python:3.12-slim-bookworm as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  VERSION=23.12.1

# hadolint ignore=DL3013
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git=1:2.39.2-1.1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      anki==${VERSION} \
  && mkdir -p /config /data

RUN chmod 0750 /data /config \
  && touch /config/users \
  && chown -R 65534:65534 /config /data

# Run
FROM python:3.12-slim-bookworm

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="anki" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.usage="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="anki" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.title="anki" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="anki" \
  org.opencontainers.image.version="$VERSION"

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  SYNC_BASE=/data

# hadolint ignore=DL3008
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    curl=7.88.1-10+deb12u5 \
    git=1:2.39.2-1.1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build --chown=65534:65534 /config /config
COPY --from=build --chown=65534:65534 /data /data

VOLUME /data

#HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
#  CMD curl -s --fail http://127.0.0.1:5232/.web/ &>/dev/null || exit 1

USER 65534:65534

EXPOSE 8080/tcp

ENTRYPOINT ["python"]
CMD ["-m", "anki.syncserver"]
