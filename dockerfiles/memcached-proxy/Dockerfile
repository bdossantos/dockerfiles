FROM memcached:1.6.42-trixie

# This image is based on the official memcached:1.6.42-trixie image which is
# compiled with --enable-proxy support.
#
# To boot the image in proxy mode:
#
#   docker run -v /path/to/proxy-config.lua:/etc/memcached/proxy.lua:ro \
#     bdossantos/memcached-proxy \
#     memcached -o proxy_config=/etc/memcached/proxy.lua
#
# For more information on memcached proxy configuration, see:
#   https://docs.memcached.org/features/proxy/install/
#   https://docs.memcached.org/features/proxy/

EXPOSE 11211

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["memcached"]
