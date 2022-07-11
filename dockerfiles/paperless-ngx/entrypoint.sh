#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

initialize() {
  for dir in /app/export /app/data /app/data/index /app/data/log /app/media /app/media/documents /app/media/documents/originals /app/media/documents/thumbnails; do
    if [[ ! -d "$dir" ]]; then
      echo "Creating directory $dir"
      mkdir -p "$dir"
      chmod 755 "$dir"
      chown -R 65534:65534 "$dir"
    fi
  done
}

migrations() {
  (
    # flock is in place to prevent multiple containers from doing migrations
    # simultaneously. This also ensures that the db is ready when the command
    # of the current container starts.
    flock 200
    echo "Apply database migrations..."
    python3 manage.py migrate
  ) 200>/dev/shm/migration_lock
}

search_index() {
  index_version=1
  index_version_file="${PAPERLESS_DATA_DIR}/.index_version"

  if [[ -d "${PAPERLESS_DATA_DIR}" ]] && [[ (! -f "$index_version_file") || $(<"$index_version_file") != "$index_version" ]]; then
    echo "Search index out of date. Updating..."
    python3 manage.py document_index reindex
    echo $index_version >"$index_version_file"
  fi
}

assets() {
  python3 manage.py collectstatic --clear --no-input
}

initialize

migrations

search_index

assets

exec "$@"
