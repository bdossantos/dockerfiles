#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

function _reload() {
  kill -HUP "$(cat /run/nginx.pid)"
  kill -USR2 "$(cat /run/php-fpm.pid)"
}

cd /

trap _reload SIGHUP

exec "$@"
