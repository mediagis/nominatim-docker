#!/bin/bash -ex

stopServices() {
  service apache2 stop
  service postgresql stop
}
trap stopServices TERM

/app/config.sh

if id nominatim >/dev/null 2>&1; then
  echo "user nominatim already exists"
else
  useradd -m -p ${NOMINATIM_PASSWORD} nominatim
fi

IMPORT_FINISHED=/var/lib/postgresql/12/main/import-finished
TOKENIZER_DIR=${PROJECT_DIR}/tokenizer

if [ ! -f ${IMPORT_FINISHED} ]; then
  /app/init.sh
  touch ${IMPORT_FINISHED}
else
  chown -R nominatim:nominatim ${PROJECT_DIR}
fi

if [ ! -d ${TOKENIZER_DIR} ]; then
  echo "No tokenizer configuration found. Copying from persistent volume into project directory."
  cp -r /var/lib/postgresql/12/main/tokenizer ${TOKENIZER_DIR}
  chown -R nominatim:nominatim ${PROJECT_DIR}
fi

service postgresql start

cd ${PROJECT_DIR} && sudo -u nominatim nominatim refresh --website

service apache2 start

# fork a process and wait for it
tail -f /var/log/postgresql/postgresql-12-main.log &
wait
