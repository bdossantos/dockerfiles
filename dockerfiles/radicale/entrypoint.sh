#!/bin/sh

set -e

chown -R nobody.nogroup /data

exec "$@"
