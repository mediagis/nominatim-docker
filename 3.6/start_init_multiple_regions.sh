PGDIR=$1

rm -rf /data/$PGDIR && \
mkdir -p /data/$PGDIR && \

chown postgres:postgres /data/$PGDIR && \

export  PGDATA=/data/$PGDIR  && \
sudo -u postgres /usr/lib/postgresql/12/bin/initdb -D /data/$PGDIR && \
sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /data/$PGDIR start && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim && \
sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data && \
sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim" && \
useradd -m -p password1234 nominatim && \
chown -R nominatim:nominatim ./src && \
chown -R nominatim:nominatim ./nominatim && \
sudo -u nominatim sh ./src/build/utils/init_multiple_regions.sh && \
sudo -u nominatim ./src/build/utils/check_import_finished.php && \
sudo -u postgres /usr/lib/postgresql/12/bin/pg_ctl -D /data/$PGDIR stop && \
sudo chown -R postgres:postgres /data/$PGDIR