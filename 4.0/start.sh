#!/bin/bash -ex

stopServices() {
  service apache2 stop
  service postgresql stop
}
trap stopServices TERM

# Needed to create default .env file before calling /app/config.sh if /nominatim is a persistent volume
if [ ! -f ${PROJECT_DIR}/.env ]; then
  cat << EOT > ${PROJECT_DIR}/.env 
NOMINATIM_REPLICATION_URL=__REPLICATION_URL__
NOMINATIM_REPLICATION_UPDATE_INTERVAL=86400
NOMINATIM_REPLICATION_RECHECK_INTERVAL=900
NOMINATIM_IMPORT_STYLE=__IMPORT_STYLE__
NOMINATIM_DATABASE_MODULE_PATH=/usr/local/lib/nominatim/module/
NOMINATIM_FLATNODE_FILE=
NOMINATIM_LOG_FILE=
EOT
fi

/app/config.sh

if id nominatim >/dev/null 2>&1; then
  echo "user nominatim already exists"
else
  groupadd --gid 6000 nominatim
  useradd -m --uid 6000 --gid 6000 -p ${NOMINATIM_PASSWORD} nominatim
fi

IMPORT_FINISHED=/var/lib/postgresql/12/main/import-finished
TOKENIZER_DIR=${PROJECT_DIR}/tokenizer

if [ ! -f ${IMPORT_FINISHED} ]; then
  mkdir -p $(dirname ${NOMINATIM_INIT_LOG:-/var/log/nominatim/init.log})
  /app/init.sh > ${NOMINATIM_INIT_LOG:-/var/log/nominatim/init.log} 2>&1
  touch ${IMPORT_FINISHED}
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
fi

chown -R nominatim:nominatim ${PROJECT_DIR}

service postgresql start

cd ${PROJECT_DIR} && sudo -u nominatim nominatim refresh --website

# start replication on container (re)start
if [ "$REPLICATION_URL" != "" ]; then
  mkdir -p $(dirname ${NOMINATIM_REPLICATION_LOG:-/var/log/nominatim/replication.log})
  sudo -E -u nominatim nominatim replication > ${NOMINATIM_REPLICATION_LOG:-/var/log/nominatim/replication.log} 2>&1 &
  cat << EOT > /etc/logrotate.d/nominatim_replication
${NOMINATIM_REPLICATION_LOG:-/var/log/nominatim/replication.log} {
        weekly
        rotate 10
        size 50M
        copytruncate
        delaycompress
        compress
        notifempty
        missingok
        su root root
}
EOT
fi

if [ "$NOMINATIM_LOG_FILE" != "" ]; then
  # based on /etc/logrotate.d/apache2
  cat << EOT > /etc/logrotate.d/nominatim_query
${NOMINATIM_LOG_FILE:-/var/log/nominatim/query.log} {
	daily
	missingok
	rotate 15
	compress
	delaycompress
	notifempty
	create 644 www-data www-data
}
EOT
fi

service apache2 start

# fork a process and wait for it
tail -f /var/log/postgresql/postgresql-12-main.log &
wait
