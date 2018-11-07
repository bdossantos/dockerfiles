#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cd /

exec /usr/bin/supervisord -c /etc/supervisord.conf