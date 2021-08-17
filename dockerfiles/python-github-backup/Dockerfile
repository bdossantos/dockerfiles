# build
FROM python:3.9.6-slim-bullseye as build

ENV \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

RUN set -x \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      github-backup==0.40.0 \
  && mkdir -p /data

# Run
FROM python:3.9.6-slim-bullseye

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
COPY --from=build --chown=nobody:nogroup /data /data

VOLUME /data

USER nobody:nogroup

ENTRYPOINT ["github-backup"]
CMD ["--help"]
