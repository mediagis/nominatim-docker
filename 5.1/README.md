# Nominatim Docker (Nominatim version 5.1)

## Table of contents

  - [Automatic import](#automatic-import)
  - [Configuration](#configuration)
    - [General Parameters](#general-parameters)
    - [PostgreSQL Tuning](#postgresql-tuning)
    - [Import Style](#import-style)
    - [Flatnode files](#flatnode-files)
    - [Configuration Example](#configuration-example)
  - [Persistent container data](#persistent-container-data)
  - [OpenStreetMap Data Extracts](#openstreetmap-data-extracts)
  - [Updating the database](#updating-the-database)
  - [Custom PBF Files](#custom-pbf-files)
  - [Importance Dumps, Postcode Data, and Tiger Addresses](#importance-dumps-postcode-data-and-tiger-addresses)
  - [Development](#development)
  - [Docker Compose](#docker-compose)
  - [Assorted use cases documented in issues](#assorted-use-cases-documented-in-issues)

---

## Automatic import

Download the required data, initialize the database and start nominatim in one go

```sh
docker run -it \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -p 8080:8080 \
  --name nominatim \
  mediagis/nominatim:5.1
```

Port 8080 is the nominatim HTTP API port and 5432 is the Postgres port, which you may or may not want to expose.

If you want to check that your data import was successful, you can use the API with the following URL: http://localhost:8080/search.php?q=avenue%20pasteur

## Configuration

### General Parameters

The following environment variables are available for configuration:

- `PBF_URL`: Which [OSM extract](#openstreetmap-data-extracts) to download and import. It cannot be used together with `PBF_PATH`.
  Check [https://download.geofabrik.de](https://download.geofabrik.de) 
  Since the download speed is restricted at Geofabrik, there is a recommended list of mirrors for importing the full planet at [OSM Wiki](https://wiki.openstreetmap.org/wiki/Planet.osm#Planet.osm_mirrors).
  At the mirror sites you can find the folder /planet which contains the planet-latest.osm.pbf
  and often a `/replication` folder for the `REPLICATION_URL`.
- `PBF_PATH`: Which [OSM extract](#openstreetmap-data-extracts) to import from the .pbf file inside the container. It cannot be used together with `PBF_URL`.
- `REPLICATION_URL`: Where to get updates from. For example Geofabrik's update for the Europe extract are available at `https://download.geofabrik.de/europe-updates/`
Other places at Geofabrik follow the pattern `https://download.geofabrik.de/$CONTINENT/$COUNTRY-updates/`
 
- `REPLICATION_UPDATE_INTERVAL`: How often upstream publishes diffs (in seconds, default: `86400`). _Requires `REPLICATION_URL` to be set._
- `REPLICATION_RECHECK_INTERVAL`: How long to sleep if no update found yet (in seconds, default: `900`). _Requires `REPLICATION_URL` to be set._
- `UPDATE_MODE`: How to run replication to [update nominatim data](https://nominatim.org/release-docs/5.1/admin/Update/#updating-nominatim). Options: `continuous`/`once`/`catch-up`/`none` (default: `none`)
- `FREEZE`: Freeze database and disable dynamic updates to save space. (default: `false`)
- `REVERSE_ONLY`: If you only want to use the Nominatim database for reverse lookups. (default: `false`)
- `IMPORT_WIKIPEDIA`: Whether to download and import the Wikipedia importance dumps (`true`) or path to importance dump in the container. Importance dumps improve the scoring of results. On a beefy 10 core server, this takes around 5 minutes. (default: `false`)
- `IMPORT_US_POSTCODES`: Whether to download and import the US postcode dump (`true`) or path to US postcode dump in the container. (default: `false`)
- `IMPORT_GB_POSTCODES`: Whether to download and import the GB postcode dump (`true`) or path to GB postcode dump in the container. (default: `false`)
- `IMPORT_TIGER_ADDRESSES`: Whether to download and import the Tiger address data (`true`) or path to a preprocessed Tiger address set in the container. (default: `false`)
- `THREADS`: How many threads should be used to import (default: number of processing units available to the current process via `nproc`)
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
- `POSTGRES_CHECKPOINT_COMPLETION_TARGET` (default: `0.9`)

See https://nominatim.org/release-docs/5.1/admin/Installation/#tuning-the-postgresql-database for more details on those settings.

### Import Style

The import style can be modified through an environment variable :

- `IMPORT_STYLE` (default: `full`)

Available options are :

- `admin`: Only import administrative boundaries and places.
- `street`: Like the admin style but also adds streets.
- `address`: Import all data necessary to compute addresses down to house number level.
- `full`: Default style that also includes points of interest.
- `extratags`: Like the full style but also adds most of the OSM tags into the extratags column.

See https://nominatim.org/release-docs/5.1/admin/Import/#filtering-imported-data for more details on those styles.

### Flatnode files

In addition you can also mount a volume / bind-mount on `/nominatim/flatnode` (see: Persistent container data) to use flatnode storage. This is advised for bigger imports (Europe, North America etc.), see: https://nominatim.org/release-docs/5.1/admin/Import/#flatnode-files. If the mount is available for the container, the flatnode configuration is automatically set and used.
  
```sh
docker run -it \
  -v nominatim-flatnode:/nominatim/flatnode \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -p 8080:8080 \
  --name nominatim \
  mediagis/nominatim:5.1
```

### Configuration Example

Here you can find a [configuration example](example.md) for all flags you can use for the container creation.


## Persistent container data

If you want to keep your imported data across deletion and recreation of your container, make the following folder a volume:

- `/var/lib/postgresql/16/main` is the storage location of the Postgres database & holds the state about whether the import was successful
- `/nominatim/flatnode` is the storage location of the flatnode file.

So if you want to be able to kill your container and start it up again with all the data still present use the following command:

```sh
docker run -it --shm-size=1g \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -e IMPORT_WIKIPEDIA=false \
  -e NOMINATIM_PASSWORD=very_secure_password \
  -v nominatim-data:/var/lib/postgresql/16/main \
  -p 8080:8080 \
  --name nominatim \
  mediagis/nominatim:5.1
```

## OpenStreetMap Data Extracts

Nominatim imports OpenStreetMap (OSM) data extracts. The source of the data can be specified with one of the following environment variables:

- `PBF_URL` variable specifies the URL. The data is downloaded during initialization, imported and removed from disk afterwards. The data extracts can be freely downloaded, e.g., from [Geofabrik's server](https://download.geofabrik.de).
- `PBF_PATH` variable specifies the path to the mounted OSM extracts data inside the container. No .pbf file is removed after initialization.

It is not possible to define both `PBF_URL` and `PBF_PATH` sources.

The replication update can be performed only via HTTP.

A sample of `PBF_PATH` variable usage is:

```sh
docker run -it \
  -e PBF_PATH=/nominatim/data/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -p 8080:8080 \
  -v /osm-maps/data:/nominatim/data \
  --name nominatim \
  mediagis/nominatim:5.1
```

where the _/osm-maps/data/_ directory contains _monaco-latest.osm.pbf_ file that is mounted and available in container: _/nominatim/data/monaco-latest.osm.pbf_

## Updating the database

Full documentation for Nominatim update available [here](https://nominatim.org/release-docs/5.1/admin/Update/). For a list of other methods see the output of:

```sh
docker exec -it nominatim sudo -u nominatim nominatim replication --help
```

The following command will keep updating the database forever:

```sh
docker exec -it nominatim sudo -u nominatim nominatim replication --project-dir /nominatim
```

If there are no updates available this process will sleep for 15 minutes and try again.

## Custom PBF Files

If you want your Nominatim container to host multiple areas from Geofabrik, you can use a tool, such as [Osmium](https://osmcode.org/osmium-tool/manual.html), to merge multiple PBF files into one.

```sh
docker run -it \
  -e PBF_PATH=/nominatim/data/merged.osm.pbf \
  -p 8080:8080 \
  -v /osm-maps/data:/nominatim/data \
  --name nominatim \
  mediagis/nominatim:5.1
```

where the _/osm-maps/data/_ directory contains _merged.osm.pbf_ file that is mounted and available in container: _/nominatim/data/merged.osm.pbf_

## Importance Dumps, Postcode Data, and Tiger Addresses

Including the Wikipedia importance dumps, postcode files, and Tiger address data can improve results. These can be automatically downloaded by setting the appropriate options (see above) to `true`. Alternatively, they can be imported from local files by specifying a file path (relative to the container), similar to how `PBF_PATH` is used. For example:

```sh
docker run -it \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e IMPORT_WIKIPEDIA=/nominatim/extras/wikimedia-importance.csv.gz \
  -p 8080:8080 \
  -v /osm-maps/extras:/nominatim/extras \
  --name nominatim \
  mediagis/nominatim:5.1
```

Where the path to the importance dump is given relative to the container. (The file does not need to be named `wikimedia-importance.sql.gz`.) The same works for `IMPORT_US_POSTCODES` and `IMPORT_GB_POSTCODES`.

For more information about the Tiger address file, see [Installing TIGER housenumber data for the US](https://nominatim.org/release-docs/5.1/customize/Tiger/).

## Development

If you want to work on the Docker image you can use the following command to build a local
image and run the container with

```sh
docker build -t nominatim . && \
docker run -it \
    -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
    -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
    -p 8080:8080 \
    --name nominatim \
    nominatim
```

## Docker Compose

In addition, we also provide a basic `contrib/docker-compose.yml` template which you use as a starting point and adapt to your needs. Use this template to set the environment variables, mounts, etc. as needed.

Besides the basic docker-compose.yml, there are also some advanced YAML configurations available in the `contrib` folder.
These files follow the naming convention of `docker-compose-*.yml` and contain comments about the specific use case.

## Assorted use cases documented in issues

- [Using an external Postgres database](https://github.com/mediagis/nominatim-docker/issues/245#issuecomment-1072205751)
  - [Using Amazon's RDS](https://github.com/mediagis/nominatim-docker/issues/378#issuecomment-1278653770)
- [Hardware sizing for importing the entire planet](https://github.com/mediagis/nominatim-docker/discussions/265)
- [Upgrading Nominatim](https://github.com/mediagis/nominatim-docker/discussions/317)
- [Using Nominatim UI](https://github.com/mediagis/nominatim-docker/discussions/486#discussioncomment-7239861)

