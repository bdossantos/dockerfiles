FROM python:3.8-buster

ENV \
  GIT_COMMITTER_NAME=Radicale \
  GIT_COMMITTER_EMAIL=radicale@localhost

# hadolint ignore=DL3013
RUN set -x \
  && python3 -m pip install radicale==3.0.3 passlib[bcrypt] \
  && python3 -m pip install --upgrade git+https://github.com/Unrud/RadicaleInfCloud \
  && mkdir -p /config /data

COPY radicale.cfg /config/radicale.cfg

RUN chmod 0750 /data /config \
  && chmod 0444 /config/radicale.cfg \
  && touch /config/users \
  && chown -R nobody.nogroup /config /data

VOLUME /data

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
  CMD curl -s --fail http://127.0.0.1:5232/.web/ &>/dev/null || exit 1

EXPOSE 5232/tcp

USER nobody

ENTRYPOINT ["/usr/local/bin/radicale"]
CMD ["--config", "/config/radicale.cfg"]
