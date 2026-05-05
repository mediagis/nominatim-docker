#!/bin/bash -e

. /app/config.sh
. /app/init.sh

PROJECT_DIR="${PROJECT_DIR:-/nominatim}"

create_user() {
  if ! id nominatim >/dev/null 2>&1; then
    useradd -m -p "${NOMINATIM_PASSWORD}" nominatim
  fi
}

cmd_import() {
  if [ -f "${PROJECT_DIR}/import-finished" ]; then
    echo "Import already finished. Skipping."
    exit 0
  fi
  if [ -z "$PBF_URL" ] && [ -z "$PBF_PATH" ]; then
    echo "PBF_URL or PBF_PATH is required for import" >&2
    exit 1
  fi
  if [ -n "$PBF_URL" ] && [ -n "$PBF_PATH" ]; then
    echo "Set only one of PBF_URL or PBF_PATH" >&2
    exit 1
  fi
  if [ -z "$NOMINATIM_DATABASE_DSN" ]; then
    echo "NOMINATIM_DATABASE_DSN is required" >&2
    exit 1
  fi

  apply_config
  create_user
  download_data
  setup_postgres
  import_data
  warmup_and_cleanup

  touch "${PROJECT_DIR}/import-finished"
  echo "Import completed successfully"
}

cmd_serve() {
  if [ ! -f "${PROJECT_DIR}/import-finished" ]; then
    echo "No import found. Run 'import' command first." >&2
    exit 1
  fi
  if [ -z "$NOMINATIM_DATABASE_DSN" ]; then
    echo "NOMINATIM_DATABASE_DSN is required" >&2
    exit 1
  fi

  apply_config
  create_user

  chown -R nominatim:nominatim "${PROJECT_DIR}"

  cd "${PROJECT_DIR}" && sudo -E -u nominatim nominatim refresh --website --functions

  if [ "$WARMUP_ON_STARTUP" = "true" ]; then
    export NOMINATIM_QUERY_TIMEOUT=600
    export NOMINATIM_REQUEST_TIMEOUT=3600
    if [ "$REVERSE_ONLY" = "true" ]; then
      echo "Warm database caches for reverse queries"
      sudo -H -E -u nominatim nominatim admin --warm --reverse > /dev/null
    else
      echo "Warm database caches for search and reverse queries"
      sudo -H -E -u nominatim nominatim admin --warm > /dev/null
    fi
    export NOMINATIM_QUERY_TIMEOUT=10
    export NOMINATIM_REQUEST_TIMEOUT=60
    echo "Warming finished"
  fi

  # send gunicorn logs straight to the console without buffering
  export PYTHONUNBUFFERED=1

  GUNICORN_PID_FILE=/tmp/gunicorn.pid
  trap 'kill $(cat $GUNICORN_PID_FILE) 2>/dev/null; exit 0' SIGTERM TERM INT

  if [ -z "$GUNICORN_WORKERS" ]; then
    GUNICORN_WORKERS=$(nproc)
  fi

  echo "Starting Gunicorn with $GUNICORN_WORKERS workers"
  echo "--> Nominatim is ready to accept requests"

  cd "$PROJECT_DIR"
  sudo -H -E -u nominatim gunicorn \
    --bind :8080 \
    --pid $GUNICORN_PID_FILE \
    --workers $GUNICORN_WORKERS \
    --enable-stdio-inheritance \
    --worker-class uvicorn.workers.UvicornWorker \
    nominatim_api.server.falcon.server:run_wsgi
}

cmd_sync() {
  if [ ! -f "${PROJECT_DIR}/import-finished" ]; then
    echo "No import found. Run 'import' command first." >&2
    exit 1
  fi
  if [ -z "$REPLICATION_URL" ]; then
    echo "REPLICATION_URL is required for sync" >&2
    exit 1
  fi
  if [ -z "$NOMINATIM_DATABASE_DSN" ]; then
    echo "NOMINATIM_DATABASE_DSN is required" >&2
    exit 1
  fi

  apply_config
  create_user

  sudo -E -u nominatim nominatim replication --project-dir "${PROJECT_DIR}" --init

  case "${UPDATE_MODE:-continuous}" in
    continuous)
      echo "Starting continuous replication"
      exec sudo -E -u nominatim nominatim replication --project-dir "${PROJECT_DIR}"
      ;;
    once)
      echo "Starting replication once"
      sudo -E -u nominatim nominatim replication --project-dir "${PROJECT_DIR}" --once
      ;;
    catch-up)
      echo "Starting replication once in catch-up mode"
      sudo -E -u nominatim nominatim replication --project-dir "${PROJECT_DIR}" --catch-up
      ;;
    *)
      echo "Unknown UPDATE_MODE: $UPDATE_MODE (expected: continuous, once, catch-up)" >&2
      exit 1
      ;;
  esac
}

case "${1:-serve}" in
  import)
    cmd_import
    ;;
  serve)
    cmd_serve
    ;;
  sync)
    cmd_sync
    ;;
  *)
    echo "Usage: entrypoint.sh {import|serve|sync}" >&2
    echo "  import  - Download OSM data and import into database" >&2
    echo "  serve   - Start the Nominatim API server (default)" >&2
    echo "  sync    - Run OSM replication updates" >&2
    exit 1
    ;;
esac
