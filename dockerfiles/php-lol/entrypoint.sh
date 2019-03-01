#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

TMPDIR='/tmp'

# Set /dev/shm as TMP_DIR if container is read-only
if [[ ! -w "$TMPDIR" ]]; then
  TMPDIR='/dev/shm'
fi

export TMPDIR

mkdir -p /dev/shm/nginx/{client_temp,fastcgi_temp,proxy_temp,scgi_temp,uwsgi_temp}
chown -R www-data.www-data /dev/shm/nginx
chmod -R 07500 /dev/shm/nginx

cd /

exec "$@"
