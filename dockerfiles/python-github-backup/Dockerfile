# build
FROM python:3.10-slim-trixie@sha256:420fbb0e468d3eaf0f7e93ea6f7a48792cbcadc39d43ac95b96bee2afe4367da AS build

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
FROM python:3.10-slim-trixie@sha256:420fbb0e468d3eaf0f7e93ea6f7a48792cbcadc39d43ac95b96bee2afe4367da

ENV \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git=1:2.47.2-0.2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build --chown=65534:65534 /data /data

VOLUME /data

USER 65534:65534

ENTRYPOINT ["github-backup"]
CMD ["--help"]
