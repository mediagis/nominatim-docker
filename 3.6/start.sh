#!/bin/bash -ex

stopServices() {
  service apache2 stop
  service postgresql stop
}
trap stopServices TERM

if [ "$PBF_URL" = "" ]; then
  echo "You need to specify the environment variable PBF_URL"
  echo "docker run -e PBF_URL=http://download.geofabrik.de/europe/monaco-latest.osm.pbf ..."
  exit 1
fi;

if [ "$REPLICATION_URL" = "" ]; then
  echo "You need to specify the environment variable REPLICATION_URL"
  echo "docker run -e REPLICATION_URL=http://download.geofabrik.de/europe/monaco-updates/ ..."
  exit 1
else
  sed -i "s|__REPLICATION_URL__|$REPLICATION_URL|g" /app/src/build/settings/local.php
fi;

if id nominatim >/dev/null 2>&1; then
  echo "user nominatim already exists"
else
  useradd -m -p ${NOMINATIM_PASSWORD} nominatim
fi

IMPORT_FINISHED=/var/lib/postgresql/12/main/import-finished

if [ ! -f ${IMPORT_FINISHED} ]; then
  /app/init.sh
  touch ${IMPORT_FINISHED}
fi

/app/src/build/utils/setup.php --setup-website

service postgresql start
service apache2 start

# fork a process and wait for it
tail -f /var/log/postgresql/postgresql-12-main.log &
wait
