# build
FROM python:3.9.1-slim-buster as build

ENV \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

RUN set -x \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      github-backup==0.26.0 \
  && mkdir -p /data

# Run
FROM python:3.9.1-slim-buster

ENV \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build --chown=nobody:nogroup /data /data

VOLUME /data

USER nobody:nogroup

ENTRYPOINT ["github-backup"]
CMD ["--help"]
