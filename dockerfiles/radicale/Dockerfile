# build
FROM python:3.9.1-slim-buster as build

ENV \
  DEBIAN_FRONTEND=noninteractive \
  PYTHONUSERBASE=/app \
  PATH=$PATH:/app/bin/

# hadolint ignore=DL3013
RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    git-core \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && pip install \
    --no-cache-dir \
    --prefix="${PYTHONUSERBASE}" \
      radicale==3.0.5 \
      passlib[bcrypt] \
      git+https://github.com/Unrud/RadicaleInfCloud \
  && mkdir -p /config /data

COPY radicale.cfg /config/radicale.cfg

RUN chmod 0750 /data /config \
  && chmod 0444 /config/radicale.cfg \
  && touch /config/users \
  && chown -R nobody.nogroup /config /data

# Run
FROM python:3.9.1-slim-buster

ENV \
  DEBIAN_FRONTEND=noninteractive \
  GIT_COMMITTER_EMAIL=radicale@localhost \
  GIT_COMMITTER_NAME=Radicale \
  PATH=$PATH:/app/bin/ \
  PYTHONUSERBASE=/app

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    curl \
    git-core \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build "$PYTHONUSERBASE" "$PYTHONUSERBASE"
COPY --from=build --chown=nobody:nogroup /config /config
COPY --from=build --chown=nobody:nogroup /data /data

VOLUME /data

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
  CMD curl -s --fail http://127.0.0.1:5232/.web/ &>/dev/null || exit 1

USER nobody:nogroup

EXPOSE 5232/tcp

ENTRYPOINT ["radicale"]
CMD ["--config", "/config/radicale.cfg"]
