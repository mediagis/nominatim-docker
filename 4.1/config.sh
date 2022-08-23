CONFIG_FILE=${PROJECT_DIR}/.env


if [[ "$PBF_URL" = "" && "$PBF_PATH" = "" ]]  ||  [[ "$PBF_URL" != "" && "$PBF_PATH" != "" ]]; then
    echo "You need to specify either the PBF_URL or PBF_PATH environment variable"
    echo "docker run -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf ..."
    echo "docker run -e PBF_PATH=/nominatim/data/monaco-latest.osm.pbf ..."
    exit 1
fi

if [ "$REPLICATION_URL" != "" ]; then
    sed -i "s|__REPLICATION_URL__|$REPLICATION_URL|g" ${CONFIG_FILE}
fi

# Use the specified replication update and recheck interval values if either or both are numbers, or use the default values

reg_num='^[0-9]+$'
if [[ $REPLICATION_UPDATE_INTERVAL =~ $reg_num ]]; then
    if [ "$REPLICATION_URL" = "" ]; then
        echo "You need to specify the REPLICATION_URL variable in order to set a REPLICATION_UPDATE_INTERVAL"
        exit 1
    fi
    sed -i "s/NOMINATIM_REPLICATION_UPDATE_INTERVAL=86400/NOMINATIM_REPLICATION_UPDATE_INTERVAL=$REPLICATION_UPDATE_INTERVAL/g" ${CONFIG_FILE}
fi
if [[ $REPLICATION_RECHECK_INTERVAL =~ $reg_num ]]; then
    if [ "$REPLICATION_URL" = "" ]; then
        echo "You need to specify the REPLICATION_URL variable in order to set a REPLICATION_RECHECK_INTERVAL"
        exit 1
    fi
    sed -i "s/NOMINATIM_REPLICATION_RECHECK_INTERVAL=900/NOMINATIM_REPLICATION_RECHECK_INTERVAL=$REPLICATION_RECHECK_INTERVAL/g" ${CONFIG_FILE}
fi

# PostgreSQL Tuning

if [ ! -z "$POSTGRES_SHARED_BUFFERS" ]; then sed -i "s/shared_buffers = 2GB/shared_buffers = $POSTGRES_SHARED_BUFFERS/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_MAINTENANCE_WORK_MEM" ]; then sed -i "s/maintenance_work_mem = 10GB/maintenance_work_mem = $POSTGRES_MAINTENANCE_WORK_MEM/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_AUTOVACUUM_WORK_MEM" ]; then sed -i "s/autovacuum_work_mem = 2GB/autovacuum_work_mem = $POSTGRES_AUTOVACUUM_WORK_MEM/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_WORK_MEM" ]; then sed -i "s/work_mem = 50MB/work_mem = $POSTGRES_WORK_MEM/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_EFFECTIVE_CACHE_SIZE" ]; then sed -i "s/effective_cache_size = 24GB/effective_cache_size = $POSTGRES_EFFECTIVE_CACHE_SIZE/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_SYNCHRONOUS_COMMIT" ]; then sed -i "s/synchronous_commit = off/synchronous_commit = $POSTGRES_SYNCHRONOUS_COMMIT/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_MAX_WAL_SIZE" ]; then sed -i "s/max_wal_size = 1GB/max_wal_size = $POSTGRES_MAX_WAL_SIZE/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_CHECKPOINT_TIMEOUT" ]; then sed -i "s/checkpoint_timeout = 10min/checkpoint_timeout = $POSTGRES_CHECKPOINT_TIMEOUT/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_CHECKPOINT_COMPLETION_TARGET" ]; then sed -i "s/checkpoint_completion_target = 0.9/checkpoint_completion_target = $POSTGRES_CHECKPOINT_COMPLETION_TARGET/g" /etc/postgresql/14/main/conf.d/postgres-tuning.conf; fi


# import style tuning

if [ ! -z "$IMPORT_STYLE" ]; then
  sed -i "s|__IMPORT_STYLE__|${IMPORT_STYLE}|g" ${CONFIG_FILE}
else
  sed -i "s|__IMPORT_STYLE__|full|g" ${CONFIG_FILE}
fi

# if flatnode directory was created by volume / mount, use flatnode files

if [ -d "${PROJECT_DIR}/flatnode" ]; then sed -i 's\^NOMINATIM_FLATNODE_FILE=$\NOMINATIM_FLATNODE_FILE="/nominatim/flatnode/flatnode.file"\g' ${CONFIG_FILE}; fi

# enable use of optional TIGER address data

if [ "$IMPORT_TIGER_ADDRESSES" = "true" ] || [ -f "$IMPORT_TIGER_ADDRESSES" ]; then
  echo NOMINATIM_USE_US_TIGER_DATA=yes >> ${CONFIG_FILE}
fi
