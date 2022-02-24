#!/bin/bash -ex

stopServices() {
  service apache2 stop
  service postgresql stop
  sudo systemctl stop nominatim-updates
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
  # nominatim needs the tokenizer configuration in the project directory to start up
  # but when you start the container with an already imported DB then you don't have this config.
  # that's why we save it in /var/lib/postgresql and copy it back if we need it.
  # this is of course a terrible hack but there is hope that 4.1 provides a way to restore this
  # configuration cleanly.
  # More reading: https://github.com/mediagis/nominatim-docker/pull/274/
  echo "No tokenizer configuration found. Copying from persistent volume into project directory."
  cp -r /var/lib/postgresql/12/main/tokenizer ${TOKENIZER_DIR}
  chown -R nominatim:nominatim ${PROJECT_DIR}
fi

service postgresql start

cd ${PROJECT_DIR} && sudo -u nominatim nominatim refresh --website --functions

service apache2 start

sudo systemctl daemon-reload
sudo systemctl enable nominatim-updates
sudo systemctl start nominatim-updates

# fork a process and wait for it
tail -f /var/log/postgresql/postgresql-12-main.log &
wait
