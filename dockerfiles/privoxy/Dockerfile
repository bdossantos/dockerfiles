FROM debian:10.8-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20200601~deb10u2 \
    curl=7.64.0-4+deb10u2 \
    net-tools=1.60+git20180626.aebd88e-1 \
    privoxy=3.0.28-2+deb10u1 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb \
    /var/cache/apt/*.bin

COPY ./config /etc/privoxy/config
COPY ./user.action /etc/privoxy/user.action

RUN set -x \
  && chmod 0755 /etc/privoxy \
  && chmod 0444 /etc/privoxy/config /etc/privoxy/user.action

EXPOSE 8118/tcp

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD env ALL_PROXY=http://127.0.0.1:8118 curl -s -I http://p.p/

USER nobody:nogroup

ENTRYPOINT ["/usr/sbin/privoxy"]
CMD ["--no-daemon", "/etc/privoxy/config"]
