# Nominatim Docker (Nominatim version 3.6)

<<<<<<< HEAD
## Automatic import

Download the required data, initialize the database and start nominatim in one go

```
docker run -it --rm \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -e IMPORT_WIKIPEDIA=true \
  -p 8080:8080 \
  --name nominatim \
  mediagis/nominatim:3.6
```

Port 8080 is the nominatim HTTP API port and 5432 is the Postgres port, which you may or may not want to expose.

If you want to check that your data import was successful, you can use the API with the following URL: http://localhost:8080/search.php?q=avenue%20pasteur

## Configuration
=======
1. Build
  ```
  docker build --pull --rm -t nominatim .
  ```
  See below for optional build arguments to include postcode data in your image.

2. Copy <your_country>.osm.pbf to a local directory (i.e. /home/me/nominatimdata)

3. Initialize Nominatim Database
  ```
  docker run -t -v /home/me/nominatimdata:/data nominatim  sh /app/init.sh /data/<your_country>.osm.pbf postgresdata 4
  ```
  Where 4 is the number of threads to use during import. In general the import of data in postgres is a very time consuming
  process that may take hours or days. If you run this process on a multiprocessor system make sure that it makes the best use
  of it. You can delete the /home/me/nominatimdata/<your_country>.osm.pbf once the import is finished.


4. After the import is finished the /home/me/nominatimdata/postgresdata folder will contain the full postgress binaries of
   a postgis/nominatim database. The easiest way to start the nominatim as a single node is the following:
   ```
   docker run --restart=always -p 6432:5432 -p 7070:8080 -d --name nominatim -v /home/me/nominatimdata/postgresdata:/var/lib/postgresql/12/main nominatim bash /app/start.sh
   ```
>>>>>>> 70c426a (Reset modified files)

The following environment variables are available for configuration:

<<<<<<< HEAD
- `PBF_URL`: Which OSM extract to download. Check https://download.geofabrik.de
- `REPLICATION_URL`: Where to get updates from. Also available from Geofabrik.
- `IMPORT_WIKIPEDIA`: Whether to import the Wikipedia importance dumps, which improve the scoring of results. On a beefy 10 core server, this takes around 5 minutes. (default: `false`)
- `IMPORT_US_POSTCODES`: Whether to import the US postcode dump. (default: `false`)
- `IMPORT_GB_POSTCODES`: Whether to import the GB postcode dump. (default: `false`)
- `THREADS`: How many threads should be used to import (default: `16`)
- `NOMINATIM_PASSWORD`: The password to connect to the database with (default: `qaIACxO6wMR3`)

The following environment variables are available to tune PostgreSQL:

- `POSTGRES_SHARED_BUFFERS` (default: `2GB`)
- `POSTGRES_MAINTENANCE_WORK_MEM` (default: `10GB`)
- `POSTGRES_AUTOVACUUM_WORK_MEM` (default: `2GB`)
- `POSTGRES_WORK_MEM` (default: `50MB`)
- `POSTGRES_EFFECTIVE_CACHE_SIZE` (default: `24GB`)
- `POSTGRES_SYNCHRONOUS_COMMIT` (default: `off`)
- `POSTGRES_MAX_WAL_SIZE` (default: `1GB`)
- `POSTGRES_CHECKPOINT_TIMEOUT` (default: `10min`)
- `POSTGRES_CHECKPOINT_COMPLETITION_TARGET` (default: `0.9`)
=======
   In order to set the  nominatib-db only node:

   ```
   docker run --restart=always -p 6432:5432 -d -v /home/me/nominatimdata/postgresdata:/var/lib/postgresql/12/main nominatim sh /app/startpostgres.sh
   ```
   After doing this create the /home/me/nominatimdata/conf folder and copy there the docker/local.php file. Then uncomment the following line:
>>>>>>> 70c426a (Reset modified files)

See https://nominatim.org/release-docs/3.6.0/admin/Installation/#tuning-the-postgresql-database for more details on those settings.

<<<<<<< HEAD
The import style can be modified through an environment variable :
=======
   You can start the  nominatib-rest only node with the following command:
>>>>>>> 70c426a (Reset modified files)

- `IMPORT_STYLE` (default: `full`)

<<<<<<< HEAD
Available options are :

- `admin`: Only import administrative boundaries and places.
- `street`: Like the admin style but also adds streets.
- `address`: Import all data necessary to compute addresses down to house number level.
- `full`: Default style that also includes points of interest.
- `extratags`: Like the full style but also adds most of the OSM tags into the extratags column.

See https://nominatim.org/release-docs/3.6.0/admin/Import/#filtering-imported-data for more details on those styles.
=======
6. Configure incremental update. By default CONST_Replication_Url configured for Monaco.
If you want a different update source, you will need to declare `CONST_Replication_Url` in local.php. Documentation [here] (https://github.com/openstreetmap/Nominatim/blob/master/docs/admin/Import-and-Update.md#updates). For example, to use the daily country extracts diffs for Gemany from geofabrik add the following:
  ```
  @define('CONST_Replication_Url', 'http://download.geofabrik.de/europe/germany-updates');
  ```

  Now you will have a fully functioning nominatim instance available at : [http://localhost:7070/](http://localhost:7070). Unlike the previous versions
  this one does not store data in the docker context and this results to a much slimmer docker image.
>>>>>>> 70c426a (Reset modified files)

The following run parameters are available for configuration:

- `shm-size`: Size of the tmpfs in Docker, for bigger imports (e.g. Europe) this needs to be set to at least 1GB or more. Half the size of your available RAM is recommended. (default: `64M`)

<<<<<<< HEAD
## Persistent container data

If you want to keep your imported data across deletion and recreation of your container, make the following folder a volume:
=======
These data files aren't downloaded by default, but you can add them with additional arguments at the build stage. To include the US postcode data file, add "--build-arg with_postcodes_us=1" to the command line in stage 1, above. To include GB postcodes, run with "--build-arg with_postcodes_gb=1". You can run with both at once if desired, eg:
  ```
  docker build --pull --rm -t nominatim --build-arg with_postcodes_us=1 --build-arg with_postcodes_gb=1 .
  ```
>>>>>>> 70c426a (Reset modified files)

- `/var/lib/postgresql/12/main` is the storage location of the Postgres database & holds the state about whether the import was successful

<<<<<<< HEAD
So if you want to be able to kill your container and start it up again with all the data still present use the following command:

```
docker run -it --rm --shm-size=1g \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -e IMPORT_WIKIPEDIA=false \
  -e NOMINATIM_PASSWORD=very_secure_password \
  -v nominatim-data:/var/lib/postgresql/12/main \
  -p 8080:8080 \
  --name nominatim \
  mediagis/nominatim:3.6
```

## Updating the database

Full documentation for Nominatim update available [here](https://nominatim.org/release-docs/3.6.0/admin/Update/). For a list of other methods see the output of:

```
docker exec -it nominatim sudo -u nominatim ./src/build/utils/update.php --help
```

The following command will keep updating the database forever:

```
docker exec -it nominatim sudo -u nominatim ./src/build/utils/update.php --import-osmosis-all
```

If there are no updates available this process will sleep for 15 minutes and try again.
=======
Full documentation for Nominatim update available [here](https://github.com/osm-search/Nominatim/blob/master/docs/admin/Update.md). For a list of other methods see the output of:
  ```
  docker exec -it nominatim sudo -u postgres ./src/build/utils/update.php --help
  ```

To initialise the updates run
  ```
  docker exec -it nominatim sudo -u postgres ./src/build/utils/update.php --init-updates
  ```

The following command will keep your database constantly up to date:
  ```
  docker exec -it nominatim sudo -u postgres ./src/build/utils/update.php --import-osmosis-all
  ```
If you have imported multiple country extracts and want to keep them
up-to-date, have a look at the script in
[issue #60](https://github.com/openstreetmap/Nominatim/issues/60).
>>>>>>> 70c426a (Reset modified files)

## Development

<<<<<<< HEAD
If you want to work on the Docker image you can use the following command to build a local
image and run the container with
=======
## Upgrade from 3.5.0 to  3.6.0
>>>>>>> 70c426a (Reset modified files)

<<<<<<< HEAD
```
docker build -t nominatim . && \
docker run -it --rm \
    -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
    -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
    -p 8080:8080 \
    --name nominatim \
    nominatim
```

## Docker Compose

In addition, we also provide a basic `contrib/docker-compose.yml` template which you use as a starting point and adapt to your needs. Use this template to set the environment variables, mounts, etc. as needed.
=======
# Docker image upgrade to 3.6 from <= 3.4

With 3.5 we have switched to Ubuntu 20.04 (LTS) which uses PostgreSQL 12. If you want to reuse your old data dictionary without importing the data again you have to make sure to migrate the data from PostgreSQL 11 to 12 with a command like ```pg_upgrade``` (see: [https://www.postgresql.org/docs/current/pgupgrade.html](https://www.postgresql.org/docs/current/pgupgrade.html)). 

<<<<<<< HEAD
You can try a script like [https://github.com/tianon/docker-postgres-upgrade](https://github.com/tianon/docker-postgres-upgrade) with some modifications.
>>>>>>> b836e40 (Reset 3.6 scripts and Readme)
=======
You can try a script like [https://github.com/tianon/docker-postgres-upgrade](https://github.com/tianon/docker-postgres-upgrade) with some modifications.
>>>>>>> 70c426a (Reset modified files)
