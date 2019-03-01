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

cd /

exec "$@"
