# build
FROM python:3.10-slim-bookworm@sha256:eae406f018dd9c05687bdd6c13fe47443945c78e7c3320d57a5b3dfecc5d08b2 AS build

ENV \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app \
  VERSION=0.41.0

RUN set -x \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      "https://github.com/josegonzalez/python-github-backup/archive/refs/tags/${VERSION}.tar.gz" \
  && mkdir -p /data

# Run
FROM python:3.10-slim-bookworm@sha256:eae406f018dd9c05687bdd6c13fe47443945c78e7c3320d57a5b3dfecc5d08b2

ENV \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git=1:2.39.5-0+deb12u3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build --chown=65534:65534 /data /data

VOLUME /data

USER 65534:65534

ENTRYPOINT ["github-backup"]
CMD ["--help"]
