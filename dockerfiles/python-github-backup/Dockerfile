# build
FROM python:3.10-slim-bullseye as build

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
FROM python:3.10-slim-bullseye

ENV \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git=1:2.30.2-1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build --chown=65534:65534 /data /data

VOLUME /data

USER 65534:65534

ENTRYPOINT ["github-backup"]
CMD ["--help"]
