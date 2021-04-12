#!/bin/bash -ex

DATA_DIR=/app/src/data
OSMFILE=${DATA_DIR}/data.osm.pbf


if [ "$IMPORT_WIKIPEDIA" = "true" ]; then
  echo "Downloading Wikipedia importance dump"
  curl https://www.nominatim.org/data/wikimedia-importance.sql.gz -o ${DATA_DIR}/wikimedia-importance.sql.gz
else
  echo "Skipping optional Wikipedia importance import"
fi;

if [ "$IMPORT_GB_POSTCODES" = "true" ]; then
  curl http://www.nominatim.org/data/gb_postcode_data.sql.gz -o ${DATA_DIR}/gb_postcode_data.sql.gz
else \
  echo "Skipping optional GB postcode import"
fi;

if [ "$IMPORT_US_POSTCODES" = "true" ]; then
  curl http://www.nominatim.org/data/us_postcode_data.sql.gz -o ${DATA_DIR}/us_postcode_data.sql.gz
else
  echo "Skipping optional US postcode import"
fi;


echo Downloading OSM extract from "$PBF_URL"
curl -L "$PBF_URL" --create-dirs -o $OSMFILE

# if we use a bind mount then the PG directory is empty and we have to create it
if [ ! -f /var/lib/postgresql/12/main/PG_VERSION ]; then
  chown postgres /var/lib/postgresql/12/main
  sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D /var/lib/postgresql/12/main
fi

sudo service postgresql start && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \

sudo -u postgres psql postgres -tAc "ALTER USER nominatim WITH ENCRYPTED PASSWORD '$NOMINATIM_PASSWORD'" && \
sudo -u postgres psql postgres -tAc "ALTER USER \"www-data\" WITH ENCRYPTED PASSWORD '${NOMINATIM_PASSWORD}'" && \

sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
chown -R nominatim:nominatim ./src && \
sudo -u nominatim ./src/build/utils/setup.php --osm-file $OSMFILE --all --threads $THREADS && \
sudo -u nominatim ./src/build/utils/check_import_finished.php && \
sudo -u nominatim ./src/build/utils/update.php --init-updates

sudo service postgresql stop

# Remove slightly unsafe postgres config overrides that made the import faster
rm /etc/postgresql/12/main/conf.d/postgres-import.conf

echo "Deleting downloaded dumps in ${DATA_DIR}"
rm ${DATA_DIR}/*sql.gz ${OSMFILE}
