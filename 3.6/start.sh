#!/bin/bash -ex

stopServices() {
  service apache2 stop
  service postgresql stop
}
trap stopServices TERM


IMPORT_FINISHED=/app/src/data/import-finished

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
