if [ "$PBF_URL" = "" ]; then
    echo "You need to specify the environment variable PBF_URL"
    echo "docker run -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf ..."
    exit 1
fi

if [ "$REPLICATION_URL" = "" ]; then
    echo "You need to specify the environment variable REPLICATION_URL"
    echo "docker run -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ ..."
    exit 1
else
    sed -i "s|__REPLICATION_URL__|$REPLICATION_URL|g" ${PROJECT_DIR}/.env
fi

# PostgreSQL Tuning

if [ ! -z "$POSTGRES_SHARED_BUFFERS" ]; then sed -i "s/shared_buffers = 2GB/shared_buffers = $POSTGRES_SHARED_BUFFERS/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_MAINTENANCE_WORK_MEM" ]; then sed -i "s/maintenance_work_mem = 10GB/maintenance_work_mem = $POSTGRES_MAINTENANCE_WORK_MEM/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_AUTOVACUUM_WORK_MEM" ]; then sed -i "s/autovacuum_work_mem = 2GB/autovacuum_work_mem = $POSTGRES_AUTOVACUUM_WORK_MEM/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_WORK_MEM" ]; then sed -i "s/work_mem = 50MB/work_mem = $POSTGRES_WORK_MEM/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_EFFECTIVE_CACHE_SIZE" ]; then sed -i "s/effective_cache_size = 24GB/effective_cache_size = $POSTGRES_EFFECTIVE_CACHE_SIZE/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_SYNCHRONOUS_COMMIT" ]; then sed -i "s/synchronous_commit = off/synchronous_commit = $POSTGRES_SYNCHRONOUS_COMMIT/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_MAX_WAL_SIZE" ]; then sed -i "s/max_wal_size = 1GB/max_wal_size = $POSTGRES_MAX_WAL_SIZE/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_CHECKPOINT_TIMEOUT" ]; then sed -i "s/checkpoint_timeout = 10min/checkpoint_timeout = $POSTGRES_CHECKPOINT_TIMEOUT/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi
if [ ! -z "$POSTGRES_CHECKPOINT_COMPLETITION_TARGET" ]; then sed -i "s/checkpoint_completion_target = 0.9/checkpoint_completion_target = $POSTGRES_CHECKPOINT_COMPLETITION_TARGET/g" /etc/postgresql/12/main/conf.d/postgres-tuning.conf; fi


# import style tuning

if [ ! -z "$IMPORT_STYLE" ]; then sed -i "s|import-full.style|import-${IMPORT_STYLE}.style|g" /app/src/build/settings/local.php; fi
