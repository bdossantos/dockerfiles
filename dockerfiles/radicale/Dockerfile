# build
FROM python:3.12-slim-bookworm as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  VERSION=3.2.0

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
      git+https://github.com/Unrud/RadicaleInfCloud \
      "Radicale[bcrypt] @ https://github.com/Kozea/Radicale/archive/v${VERSION}.tar.gz" \
      passlib[bcrypt] \
      pytz \
  && mkdir -p /config /data

COPY radicale.cfg /config/radicale.cfg

RUN chmod 0750 /data /config \
  && chmod 0444 /config/radicale.cfg \
  && touch /config/users \
  && chown -R 65534:65534 /config /data

# Run
FROM python:3.12-slim-bookworm

ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="radicale" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.usage="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="radicale" \
  org.label-schema.version="$VERSION" \
  org.opencontainers.image.created="$BUILD_DATE" \
  org.opencontainers.image.documentation="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.revision="$VCS_REF" \
  org.opencontainers.image.source="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.title="radicale" \
  org.opencontainers.image.url="https://github.com/bdossantos/dockerfiles" \
  org.opencontainers.image.vendor="radicale" \
  org.opencontainers.image.version="$VERSION"

ENV \
  DEBIAN_FRONTEND=noninteractive \
  GIT_COMMITTER_EMAIL=radicale@localhost \
  GIT_COMMITTER_NAME=Radicale \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

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

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
  CMD curl -s --fail http://127.0.0.1:5232/.web/ &>/dev/null || exit 1

USER 65534:65534

EXPOSE 5232/tcp

ENTRYPOINT ["radicale"]
CMD ["--config", "/config/radicale.cfg"]
