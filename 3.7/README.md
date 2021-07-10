# Nominatim Docker (Nominatim version 3.7)

## Automatic import

Download the required data, initialize the database and start nominatim in one go

```
docker run -it --rm \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -p 8080:8080 \
  --name nominatim \
  mediagis/nominatim:3.7
```

Port 8080 is the nominatim HTTP API port and 5432 is the Postgres port, which you may or may not want to expose.

If you want to check that your data import was successful, you can use the API with the following URL: http://localhost:8080/search.php?q=avenue%20pasteur

## Configuration

### General Parameters

The following environment variables are available for configuration:

  - `PBF_URL`: Which [OSM extract](#openstreetmap-data-extracts) to download and import. It cannot be used together with PBF_PATH. Check [https://download.geofabrik.de](https://download.geofabrik.de)
  - `PBF_PATH`: Which [OSM extract](#openstreetmap-data-extracts) to import from the .pbf file inside the container. It cannot be used together with PBF_URL.    
  - `REPLICATION_URL`: Where to get updates from. Also available from Geofabrik.
  - `REPLICATION_UPDATE_INTERVAL`: How often upstream publishes diffs (in seconds, default: `86400`)
  - `REPLICATION_RECHECK_INTERVAL`: How long to sleep if no update found yet (in seconds, default: `900`)
  - `IMPORT_WIKIPEDIA`: Whether to import the Wikipedia importance dumps, which improve the scoring of results. On a beefy 10 core server, this takes around 5 minutes. (default: `false`)
  - `IMPORT_US_POSTCODES`: Whether to import the US postcode dump. (default: `false`)
  - `IMPORT_GB_POSTCODES`: Whether to import the GB postcode dump. (default: `false`)
  - `THREADS`: How many threads should be used to import (default: `16`)
  - `NOMINATIM_PASSWORD`: The password to connect to the database with (default: `qaIACxO6wMR3`)

The following run parameters are available for configuration:

  - `shm-size`: Size of the tmpfs in Docker, for bigger imports (e.g. Europe) this needs to be set to at least 1GB or more. Half the size of your available RAM is recommended. (default: `64M`)

### PostgreSQL Tuning

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

See https://nominatim.org/release-docs/3.7.2/admin/Installation/#tuning-the-postgresql-database for more details on those settings.

### Import Style

The import style can be modified through an environment variable :

  - `IMPORT_STYLE` (default: `full`)

Available options are :

  - `admin`: Only import administrative boundaries and places.
  - `street`: Like the admin style but also adds streets.
  - `address`: Import all data necessary to compute addresses down to house number level.
  - `full`: Default style that also includes points of interest.
  - `extratags`: Like the full style but also adds most of the OSM tags into the extratags column.

See https://nominatim.org/release-docs/3.7.2/admin/Import/#filtering-imported-data for more details on those styles.

### Flatnode files

In addition you can also mount a volume / bind-mount on `/nominatim/flatnode` (see: Persistent container data) to use flatnode storage. This is advised for bigger imports (Europe, North America etc.), see: https://nominatim.org/release-docs/3.7.2/admin/Import/#flatnode-files. If the mount is available for the container, the flatnode configuration is automatically set and used.

## Persistent container data

If you want to keep your imported data across deletion and recreation of your container, make the following folder a volume:

- `/var/lib/postgresql/12/main` is the storage location of the Postgres database & holds the state about whether the import was successful
- `/nominatim/flatnode` is the storage location of the flatnode file.

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
  mediagis/nominatim:3.7
```

## OpenStreetMap Data Extracts

Nominatim imports OpenStreetMap (OSM) data extracts. The source of the data can be specified with one of environment variables:

- PBF_URL variable specifies the URL. The data is downloaded during initialization, imported and removed from disk afterwards. The data extracts can be freely downloaded, e.g., from [Geofabrik's server](https://download.geofabrik.de).
- PBF_PATH variable specifies the path to the mounted OSM extracts data inside the container. No .pbf file is removed after initialization.

It is not possible to define both PBF_URL and PBF_PATH sources.

The replication update can be performed only via HTTP.

A sample of PBF_PATH variable usage is:

``` sh
docker run -it --rm \
  -e PBF_PATH=/nominatim/data/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -p 8080:8080 \
  -v /osm-maps/data:/nominatim/data \
  --name nominatim \
  mediagis/nominatim:3.7
```

where the _/osm-maps/data/_ directory contains _monaco-latest.osm.pbf_ file that is mounted and available in container: _/nominatim/data/monaco-latest.osm.pbf_

## Updating the database

Full documentation for Nominatim update available [here](https://nominatim.org/release-docs/3.7.2/admin/Update/). For a list of other methods see the output of:
```
docker exec -it nominatim sudo -u nominatim nominatim replication --help
```

The following command will keep updating the database forever:

```
docker exec -it nominatim sudo -u nominatim nominatim replication --project-dir /nominatim
```

If there are no updates available this process will sleep for 15 minutes and try again.

## Development

If you want to work on the Docker image you can use the following command to build a local
image and run the container with

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
