#!/bin/sh

set -e

groupmod -o -g "$(id -g)" nogroup
usermod -o -u "$(id -u)" nobody
chown -R nobody.nogroup /data
exec su-exec nobody.nogroup "$@"
