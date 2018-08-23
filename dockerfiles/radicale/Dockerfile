FROM alpine:3.8

# hadolint ignore=DL3013
RUN apk add --no-cache --virtual=build-dependencies \
    gcc=6.4.0-r8 \
    libffi-dev=3.2.1-r4 \
    musl-dev=1.1.19-r10 \
    python3-dev=3.6.4-r1 \
  && apk add --no-cache \
    curl=7.61.0-r0 \
    git=2.18.0-r0 \
    python3=3.6.4-r1 \
    shadow=4.5-r0 \
    su-exec=0.2-r0 \
  && python3 -m pip install radicale==2.1.10 passlib[bcrypt] \
  && python3 -m pip install --upgrade git+https://github.com/Unrud/RadicaleInfCloud \
  && apk del --purge build-dependencies \
  && mkdir -p /config /data

COPY radicale.cfg /config/radicale.cfg
COPY entrypoint.sh /entrypoint.sh

RUN chmod 0750 /data /config \
  && chmod 0755 /entrypoint.sh \
  && chmod 0444 /config/radicale.cfg \
  && touch /config/users \
  && chown -R nobody.nogroup /config /data

VOLUME /data

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s \
  CMD curl -s --fail http://127.0.0.1:5232/.web/ &>/dev/null || exit 1

EXPOSE 5232/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["radicale", "--config", "/config/radicale.cfg"]
