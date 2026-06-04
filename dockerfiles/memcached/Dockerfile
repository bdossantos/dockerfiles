# hadolint ignore=DL3006
FROM memcached:1.6.42-trixie@sha256:26983a43c9181d37d0f9b0d2cf49c3ccf02e5b816afb1f8ffff7f825e65bcdad

ARG BUILD_DATE
ARG VCS_REF

ENV VERSION=1.6.42

LABEL org.label-schema.build-date="$BUILD_DATE" \
  org.label-schema.name="memcached" \
  org.label-schema.schema-version="1.0" \
  org.label-schema.url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.usage="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vcs-ref="$VCS_REF" \
  org.label-schema.vcs-url="https://github.com/bdossantos/dockerfiles" \
  org.label-schema.vendor="memcached" \
  org.label-schema.version="$VERSION"

# This image is based on the official memcached:1.6.42-trixie image which is
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

ENV MEMCACHED_PROXYLIBS_VERSION=e3c024fb0d020fee4b57a8e5a4694e74c05d85c6

ADD --chmod=644 \
  --checksum=sha256:97aa953893995971dd39b4a15ba2ddc58445d81ea8a40f2ef70e88d2078764e9 \
  https://raw.githubusercontent.com/memcached/memcached-proxylibs/${MEMCACHED_PROXYLIBS_VERSION}/lib/routelib/routelib.lua \
  /usr/local/lib/memcached/routelib.lua

EXPOSE 11211

USER 65534:65534

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["memcached"]
