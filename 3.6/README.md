# Nominatim Docker (Nominatim version 3.6)

## Automatic import

Download the required data, initialize the database and start nominatim in one go

```shell
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

The following environment variables are available for configuration:

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

See https://nominatim.org/release-docs/3.6.0/admin/Installation/#tuning-the-postgresql-database for more details on those settings.


The import style can be modified through an environment variable :

  - `IMPORT_STYLE` (default: `full`)

Available options are :

  - `admin`: Only import administrative boundaries and places.
  - `street`: Like the admin style but also adds streets.
  - `address`: Import all data necessary to compute addresses down to house number level.
  - `full`: Default style that also includes points of interest.
  - `extratags`: Like the full style but also adds most of the OSM tags into the extratags column.

See https://nominatim.org/release-docs/3.6.0/admin/Import/#filtering-imported-data for more details on those styles.


The following run parameters are available for configuration:

  - `shm-size`: Size of the tmpfs in Docker, for bigger imports (e.g. Europe) this needs to be set to at least 1GB or more. Half the size of your available RAM is recommended. (default: `64M`)


## Persistent container data

There is one folder the can be persisted across container creation and removal.

- `/var/lib/postgresql/12/main` is the storage location of the Postgres database & holds the state about whether the import was successful

So if you want to be able to kill your container and start it up again with all the data still present use the following command:

```shell
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

## Development

If you want to work on the Docker image you can use the following command to build a local
image and run the container with

```shell
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

You can start the image with a single command:

```shell
docker-compose up
```