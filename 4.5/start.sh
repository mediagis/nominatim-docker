#!/bin/bash -ex

tailpid=0
replicationpid=0
GUNICORN_PID_FILE=/tmp/gunicorn.pid
# send gunicorn logs straight to the console without buffering: https://stackoverflow.com/questions/59812009
export PYTHONUNBUFFERED=1

stopServices() {
  service postgresql stop
  # Check if the replication process is active
  if [ $replicationpid -ne 0 ]; then
    echo "Shutting down replication process"
    kill $replicationpid
  fi
  kill $tailpid
  cat $GUNICORN_PID_FILE | sudo xargs kill

  # Force exit code 0 to signal a successful shutdown to Docker
  exit 0
}
trap stopServices SIGTERM TERM INT

/app/config.sh

if id nominatim >/dev/null 2>&1; then
  echo "user nominatim already exists"
else
  useradd -m -p ${NOMINATIM_PASSWORD} nominatim
fi

IMPORT_FINISHED=/var/lib/postgresql/16/main/import-finished

if [ ! -f ${IMPORT_FINISHED} ]; then
  /app/init.sh
  touch ${IMPORT_FINISHED}
else
  chown -R nominatim:nominatim ${PROJECT_DIR}
fi

service postgresql start

cd ${PROJECT_DIR} && sudo -E -u nominatim nominatim refresh --website --functions

# start continous replication process
if [ "$REPLICATION_URL" != "" ] && [ "$FREEZE" != "true" ]; then
  # run init in case replication settings changed
  sudo -E -u nominatim nominatim replication --project-dir ${PROJECT_DIR} --init
  if [ "$UPDATE_MODE" == "continuous" ]; then
    echo "starting continuous replication"
    sudo -E -u nominatim nominatim replication --project-dir ${PROJECT_DIR} &> /var/log/replication.log &
    replicationpid=${!}
  elif [ "$UPDATE_MODE" == "once" ]; then
    echo "starting replication once"
    sudo -E -u nominatim nominatim replication --project-dir ${PROJECT_DIR} --once &> /var/log/replication.log &
    replicationpid=${!}
  elif [ "$UPDATE_MODE" == "catch-up" ]; then
    echo "starting replication once in catch-up mode"
    sudo -E -u nominatim nominatim replication --project-dir ${PROJECT_DIR} --catch-up &> /var/log/replication.log &
    replicationpid=${!}
  else
    echo "skipping replication"
  fi
fi

# fork a process and wait for it
tail -Fv /var/log/postgresql/postgresql-16-main.log &
tailpid=${!}

if [ "$ENABLE_WARMUP" = "true" ] || [ -z "$ENABLE_WARMUP" ]; then
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
else
  echo "skipping database warmup"
fi

echo "--> Nominatim is ready to accept requests"

cd "$PROJECT_DIR"
sudo -u nominatim gunicorn \
  --bind :8080 \
  --pid $GUNICORN_PID_FILE \
  --workers 4 \
  --daemon \
  --enable-stdio-inheritance \
  --worker-class uvicorn.workers.UvicornWorker \
  nominatim_api.server.falcon.server:run_wsgi

wait