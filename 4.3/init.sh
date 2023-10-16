#!/bin/bash -ex

OSMFILE=${PROJECT_DIR}/data.osm.pbf

CURL=("curl" "-L" "-A" "${USER_AGENT}" "--fail-with-body")

SCP='sshpass -p DMg5bmLPY7npHL2Q scp -o StrictHostKeyChecking=no u355874-sub1@u355874-sub1.your-storagebox.de'

# Check if THREADS is not set or is empty
if [ -z "$THREADS" ]; then
  THREADS=$(nproc)
fi

if [ "$IMPORT_WIKIPEDIA" = "true" ]; then
  echo "Downloading Wikipedia importance dump"
  ${SCP}:wikimedia-importance.sql.gz ${PROJECT_DIR}/wikimedia-importance.sql.gz
elif [ -f "$IMPORT_WIKIPEDIA" ]; then
  # use local file if asked
  ln -s "$IMPORT_WIKIPEDIA" ${PROJECT_DIR}/wikimedia-importance.sql.gz
else
  echo "Skipping optional Wikipedia importance import"
fi;

if [ "$IMPORT_GB_POSTCODES" = "true" ]; then
  ${SCP}:gb_postcodes.csv.gz ${PROJECT_DIR}/gb_postcodes.csv.gz
elif [ -f "$IMPORT_GB_POSTCODES" ]; then
  # use local file if asked
  ln -s "$IMPORT_GB_POSTCODES" ${PROJECT_DIR}/gb_postcodes.csv.gz
else \
  echo "Skipping optional GB postcode import"
fi;

if [ "$IMPORT_US_POSTCODES" = "true" ]; then
  ${SCP}:us_postcodes.csv.gz ${PROJECT_DIR}/us_postcodes.csv.gz
elif [ -f "$IMPORT_US_POSTCODES" ]; then
  # use local file if asked
  ln -s "$IMPORT_US_POSTCODES" ${PROJECT_DIR}/us_postcodes.csv.gz
else
  echo "Skipping optional US postcode import"
fi;

if [ "$IMPORT_TIGER_ADDRESSES" = "true" ]; then
  ${SCP}:tiger2021-nominatim-preprocessed.csv.tar.gz ${PROJECT_DIR}/tiger-nominatim-preprocessed.csv.tar.gz
elif [ -f "$IMPORT_TIGER_ADDRESSES" ]; then
  # use local file if asked
  ln -s "$IMPORT_TIGER_ADDRESSES" ${PROJECT_DIR}/tiger-nominatim-preprocessed.csv.tar.gz
else
  echo "Skipping optional Tiger addresses import"
fi

if [ "$PBF_URL" != "" ]; then
  echo Downloading OSM extract from "$PBF_URL"
  "${CURL[@]}" "$PBF_URL" -C - --create-dirs -o $OSMFILE
fi

if [ "$PBF_PATH" != "" ]; then
  echo Reading OSM extract from "$PBF_PATH"
  OSMFILE=$PBF_PATH
fi


# if we use a bind mount then the PG directory is empty and we have to create it
if [ ! -f /var/lib/postgresql/14/main/PG_VERSION ]; then
  chown postgres /var/lib/postgresql/14/main
  sudo -u postgres /usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/main
fi

# temporarily enable unsafe import optimization config
cp /etc/postgresql/14/main/conf.d/postgres-import.conf.disabled /etc/postgresql/14/main/conf.d/postgres-import.conf

sudo service postgresql start && \
sudo -E -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -E -u postgres createuser -s nominatim && \
sudo -E -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -E -u postgres createuser -SDR www-data && \

sudo -E -u postgres psql postgres -tAc "ALTER USER nominatim WITH ENCRYPTED PASSWORD '$NOMINATIM_PASSWORD'" && \
sudo -E -u postgres psql postgres -tAc "ALTER USER \"www-data\" WITH ENCRYPTED PASSWORD '${NOMINATIM_PASSWORD}'" && \

sudo -E -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"

chown -R nominatim:nominatim ${PROJECT_DIR}

cd ${PROJECT_DIR}

if [ "$REVERSE_ONLY" = "true" ]; then
  sudo -E -u nominatim nominatim import --osm-file $OSMFILE --threads $THREADS --reverse-only
else
  sudo -E -u nominatim nominatim import --osm-file $OSMFILE --threads $THREADS
fi

if [ -f tiger-nominatim-preprocessed.csv.tar.gz ]; then
  echo "Importing Tiger address data"
  sudo -E -u nominatim nominatim add-data --tiger-data tiger-nominatim-preprocessed.csv.tar.gz
fi

# Sometimes Nominatim marks parent places to be indexed during the initial
# import which leads to '123 entries are not yet indexed' errors in --check-database
# Thus another quick additional index here for the remaining places
sudo -E -u nominatim nominatim index --threads $THREADS

sudo -E -u nominatim nominatim admin --check-database

if [ "$REPLICATION_URL" != "" ]; then
  sudo -E -u nominatim nominatim replication --init
  if [ "$FREEZE" = "true" ]; then
    echo "Skipping freeze because REPLICATION_URL is not empty"
  fi
else
  if [ "$FREEZE" = "true" ]; then
    echo "Freezing database"
    sudo -E -u nominatim nominatim freeze
  fi
fi

export NOMINATIM_QUERY_TIMEOUT=600
export NOMINATIM_REQUEST_TIMEOUT=3600
if [ "$REVERSE_ONLY" = "true" ]; then
  sudo -H -E -u nominatim nominatim admin --warm --reverse
else
  sudo -H -E -u nominatim nominatim admin --warm
fi
export NOMINATIM_QUERY_TIMEOUT=10
export NOMINATIM_REQUEST_TIMEOUT=60

# gather statistics for query planner to potentially improve query performance
# see, https://github.com/osm-search/Nominatim/issues/1023
# and  https://github.com/osm-search/Nominatim/issues/1139
sudo -E -u nominatim psql -d nominatim -c "ANALYZE VERBOSE"

sudo service postgresql stop

# Remove slightly unsafe postgres config overrides that made the import faster
rm /etc/postgresql/14/main/conf.d/postgres-import.conf

echo "Deleting downloaded dumps in ${PROJECT_DIR}"
rm -f ${PROJECT_DIR}/*sql.gz
rm -f ${PROJECT_DIR}/*csv.gz
rm -f ${PROJECT_DIR}/tiger-nominatim-preprocessed.csv.tar.gz

if [ "$PBF_URL" != "" ]; then
  rm -f ${OSMFILE}
fi
