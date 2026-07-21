#!/bin/bash -ex

OSMFILE=${PROJECT_DIR}/data.osm.pbf

CURL=("curl" "-L" "-A" "${USER_AGENT}" "--fail-with-body")

SCP='sshpass -p DMg5bmLPY7npHL2Q scp -o StrictHostKeyChecking=no u355874-sub1@u355874-sub1.your-storagebox.de'

# Check if THREADS is not set or is empty
if [ -z "$THREADS" ]; then
  THREADS=$(nproc)
fi

# we re-host the files on a Hetzner storage box because inconsiderate users eat up all of
# nominatim.org's bandwidth
# https://github.com/mediagis/nominatim-docker/issues/416

# https://nominatim.org/release-docs/5.3/admin/Import/#wikipediawikidata-rankings
if [ "$IMPORT_WIKIPEDIA" = "true" ]; then
  echo "Downloading Wikipedia importance dump"
  ${SCP}:wikimedia-importance.csv.gz ${PROJECT_DIR}/wikimedia-importance.csv.gz
elif [ -f "$IMPORT_WIKIPEDIA" ]; then
  # use local file if asked
  ln -s "$IMPORT_WIKIPEDIA" ${PROJECT_DIR}/wikimedia-importance.csv.gz
else
  echo "Skipping optional Wikipedia importance import"
fi;

if [ "$IMPORT_SECONDARY_WIKIPEDIA" = "true" ]; then
  echo "Downloading Wikipedia secondary importance dump"
  ${SCP}:wikimedia-secondary-importance.sql.gz ${PROJECT_DIR}/secondary_importance.sql.gz
elif [ -f "$IMPORT_SECONDARY_WIKIPEDIA" ]; then
  # use local file if asked
  ln -s "$IMPORT_SECONDARY_WIKIPEDIA" ${PROJECT_DIR}/secondary_importance.sql.gz
else
  echo "Skipping optional Wikipedia secondary importance import"
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
  ${SCP}:tiger2024-nominatim-preprocessed.csv.tar.gz ${PROJECT_DIR}/tiger-nominatim-preprocessed.csv.tar.gz
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
if [ ! -f /var/lib/postgresql/16/main/PG_VERSION ]; then
  chown postgres:postgres /var/lib/postgresql/16/main
  sudo -u postgres /usr/lib/postgresql/16/bin/initdb -D /var/lib/postgresql/16/main
fi

# temporarily enable unsafe import optimization config
cp /etc/postgresql/16/main/conf.d/postgres-import.conf.disabled /etc/postgresql/16/main/conf.d/postgres-import.conf

sudo service postgresql start && \
sudo -E -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -E -u postgres createuser -s nominatim && \
sudo -E -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -E -u postgres createuser -SDR www-data && \

sudo -E -u postgres psql postgres -tAc "ALTER USER nominatim WITH ENCRYPTED PASSWORD '$NOMINATIM_PASSWORD'" && \
sudo -E -u postgres psql postgres -tAc "ALTER USER \"www-data\" WITH ENCRYPTED PASSWORD '${NOMINATIM_PASSWORD}'"

chown -R nominatim:nominatim ${PROJECT_DIR}

cd ${PROJECT_DIR}

psql_true() {
  case "$1" in
    t | true) return 0 ;;
    *) return 1 ;;
  esac
}

# Fail closed: never map probe errors to empty/"fresh" (that would DROP DATABASE).
psql_scalar() {
  sudo -E -u postgres psql -d nominatim -Atqc "$1"
}

# Prints "exists" or "missing". Returns 1 on query failure (caller must not treat as missing).
probe_nominatim_db() {
  local out
  out="$(sudo -E -u postgres psql -d postgres -Atqc \
    "SELECT 1 FROM pg_database WHERE datname = 'nominatim'")" || return 1
  if [ "${out}" = "1" ]; then
    echo "exists"
  else
    echo "missing"
  fi
}

flatnode_nonempty() {
  local f="${NOMINATIM_FLATNODE_FILE:-}"
  if [ -z "${f}" ] && [ -d "${PROJECT_DIR}/flatnode" ]; then
    f="${PROJECT_DIR}/flatnode/flatnode.file"
  fi
  [ -n "${f}" ] && [ -f "${f}" ] && [ -s "${f}" ]
}

# True when Tiger address rows are already present (never treat probe errors as "missing").
tiger_data_present() {
  local has_rel has_rows
  has_rel="$(psql_scalar "SELECT to_regclass('public.location_property_tiger') IS NOT NULL")" || return 1
  if ! psql_true "${has_rel}"; then
    return 1
  fi
  has_rows="$(psql_scalar "SELECT EXISTS (SELECT 1 FROM location_property_tiger LIMIT 1)")" || return 1
  psql_true "${has_rows}"
}

# Detect --continue checkpoint from DB state (see nominatim_db/clicmd/setup.py).
# Prints one of: done|load-data|indexing|db-postprocess|fresh
# Returns 1 (fail closed) when resume would be destructive or ambiguous.
detect_continue_at() {
  local db_state
  db_state="$(probe_nominatim_db)" || {
    echo "Failed to query whether nominatim database exists; refusing DROP" >&2
    return 1
  }
  if [ "${db_state}" = "missing" ]; then
    echo "fresh"
    return 0
  fi

  local has_place_rel has_place has_placex_rel placex_loaded indexing_started has_pending \
    has_props_rel has_version has_postcode_rel has_postcodes

  # Missing place relation (createdb/pre-osm2pgsql) is fresh — not a probe failure.
  has_place_rel="$(psql_scalar "SELECT to_regclass('public.place') IS NOT NULL")"
  if ! psql_true "${has_place_rel}"; then
    echo "fresh"
    return 0
  fi

  has_place="$(psql_scalar "SELECT COALESCE((SELECT true FROM place LIMIT 1), false)")"
  if ! psql_true "${has_place}"; then
    # No successful osm2pgsql output — safe to DROP + re-import.
    echo "fresh"
    return 0
  fi

  # place has rows but placex is missing: mid-osm2pgsql / pre-table-setup.
  # --continue load-data does not re-run osm2pgsql and will fail; do not DROP.
  has_placex_rel="$(psql_scalar "SELECT to_regclass('public.placex') IS NOT NULL")"
  if ! psql_true "${has_placex_rel}"; then
    echo "place has rows but placex is missing (likely mid-osm2pgsql); refusing auto-resume/DROP" >&2
    echo "Restore a consistent DB or wipe the Postgres volume (and flatnode, if used) for a fresh import" >&2
    return 1
  fi

  # placex exists but empty: load-data was interrupted (or never started after create_tables).
  placex_loaded="$(psql_scalar "SELECT EXISTS (SELECT 1 FROM placex LIMIT 1)")"
  if ! psql_true "${placex_loaded}"; then
    echo "load-data"
    return 0
  fi

  has_props_rel="$(psql_scalar "SELECT to_regclass('public.nominatim_properties') IS NOT NULL")"
  if psql_true "${has_props_rel}"; then
    has_version="$(psql_scalar \
      "SELECT EXISTS (SELECT 1 FROM nominatim_properties WHERE property = 'database_version')")"
    if psql_true "${has_version}"; then
      echo "done"
      return 0
    fi
  fi

  # indexed_status: 0 = indexed; >0 = pending (load_data insert triggers set 1)
  indexing_started="$(psql_scalar \
    "SELECT EXISTS (SELECT 1 FROM placex WHERE indexed_status = 0 LIMIT 1)")"
  if ! psql_true "${indexing_started}"; then
    # Placex loaded but no indexed row yet: postcodes window or very early indexing.
    # NEVER map this to load-data — Nominatim --continue load-data truncates placex.
    has_postcode_rel="$(psql_scalar "SELECT to_regclass('public.location_postcodes') IS NOT NULL")"
    if psql_true "${has_postcode_rel}"; then
      has_postcodes="$(psql_scalar "SELECT EXISTS (SELECT 1 FROM location_postcodes LIMIT 1)")"
      if psql_true "${has_postcodes}"; then
        # Postcodes have committed; safe to resume indexing (matches Nominatim FAQ).
        echo "indexing"
        return 0
      fi
    fi
    echo "Ambiguous pre-index state (placex loaded, no indexed rows, postcodes empty/missing); refusing destructive --continue load-data" >&2
    echo "If postcodes finished, run: nominatim import --continue indexing" >&2
    echo "If still in load-data/postcodes with empty placex expected, wipe volumes for a fresh import" >&2
    return 1
  fi

  has_pending="$(psql_scalar \
    "SELECT EXISTS (SELECT 1 FROM placex WHERE indexed_status > 0 LIMIT 1)")"
  if psql_true "${has_pending}"; then
    echo "indexing"
    return 0
  fi

  echo "db-postprocess"
}

stage="$(detect_continue_at)"
echo "Detected import stage: ${stage}"

case "${stage}" in
  done)
    echo "Import already complete; skipping fresh import / continue"
    ;;
  fresh)
    if flatnode_nonempty; then
      echo "Stage is fresh but flatnode file is non-empty; refusing DROP DATABASE"
      echo "Wipe the flatnode volume or restore a consistent database before retrying"
      exit 1
    fi
    sudo -E -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
    if [ "$REVERSE_ONLY" = "true" ]; then
      sudo -E -u nominatim nominatim import --osm-file $OSMFILE --threads $THREADS --reverse-only
    else
      sudo -E -u nominatim nominatim import --osm-file $OSMFILE --threads $THREADS
    fi
    ;;
  load-data | indexing | db-postprocess)
    /app/import-continue.sh "${stage}"
    ;;
  *)
    echo "Unhandled import stage '${stage}'; refusing DROP"
    exit 1
    ;;
esac

# Tiger runs after nominatim import finalize. On stage=done, still import when archive
# is present and Tiger rows are missing (crash between import complete and Tiger).
if [ -f tiger-nominatim-preprocessed.csv.tar.gz ]; then
  if [ "${stage}" = "done" ] && tiger_data_present; then
    echo "Tiger address data already present; skipping Tiger import"
  else
    echo "Importing Tiger address data"
    sudo -E -u nominatim nominatim add-data --tiger-data tiger-nominatim-preprocessed.csv.tar.gz
  fi
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
rm /etc/postgresql/16/main/conf.d/postgres-import.conf

echo "Deleting downloaded dumps in ${PROJECT_DIR}"
rm -f ${PROJECT_DIR}/*sql.gz
rm -f ${PROJECT_DIR}/*csv.gz
# Keep Tiger archive until rows exist so a done-path recovery cannot delete it unapplied.
if [ -f ${PROJECT_DIR}/tiger-nominatim-preprocessed.csv.tar.gz ]; then
  if tiger_data_present; then
    rm -f ${PROJECT_DIR}/tiger-nominatim-preprocessed.csv.tar.gz
  else
    echo "Leaving Tiger archive in place; Tiger data not loaded yet"
  fi
fi

if [ "$PBF_URL" != "" ]; then
  rm -f ${OSMFILE}
fi
