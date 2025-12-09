# build
FROM python:3.10-slim-trixie@sha256:8769cc10045c67eac267537ff0950ce644eeebd9f0e88bec0604548a88f1f33d AS build

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
FROM python:3.10-slim-trixie@sha256:8769cc10045c67eac267537ff0950ce644eeebd9f0e88bec0604548a88f1f33d

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
