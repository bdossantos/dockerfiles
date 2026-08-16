# Build
FROM debian:13-slim@sha256:4e401d95de7083948053197a9c3913343cd06b706bf15eb6a0c3ccd26f436a0e AS build

ENV MEMCACHED_PROXYLIBS_VERSION=e3c024fb0d020fee4b57a8e5a4694e74c05d85c6

RUN mkdir -p /usr/local/lib/memcached \
  && chmod 755 /usr/local/lib/memcached

ADD --chmod=644 \
  --checksum=sha256:97aa953893995971dd39b4a15ba2ddc58445d81ea8a40f2ef70e88d2078764e9 \
  https://raw.githubusercontent.com/memcached/memcached-proxylibs/${MEMCACHED_PROXYLIBS_VERSION}/lib/routelib/routelib.lua \
  /usr/local/lib/memcached/routelib.lua

# Run
# hadolint ignore=DL3006
FROM memcached:1.6.45-trixie@sha256:eeb9eaa939ffaa2304899674c9e88a9247ec8e5e40e424a892df7b09914bd2ec

ARG BUILD_DATE
ARG VCS_REF

ENV VERSION=1.6.45

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="memcached" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.usage="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="memcached" \
  org.label-schema.version="$VERSION"

# This image is based on the official memcached:1.6.45-trixie image which is
# compiled with --enable-proxy support.
#
# To boot the image in proxy mode using the embedded routelib:
#
#   docker run -v /path/to/proxy-config.lua:/etc/memcached/proxy.lua:ro \
#     bdossantos/memcached \
#     memcached -o proxy_config=/usr/local/lib/memcached/routelib.lua:/etc/memcached/proxy.lua
#
# For more information on memcached proxy configuration, see:
#   https://docs.memcached.org/features/proxy/install/
#   https://docs.memcached.org/features/proxy/

COPY --from=build --chown=65534:65534 /usr/local/lib/memcached /usr/local/lib/memcached

EXPOSE 11211

USER 65534:65534

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["memcached"]
