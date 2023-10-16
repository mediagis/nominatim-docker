# Nominatim Docker (Nominatim version 4.3)

## Table of contents

  - [Automatic import](#automatic-import)
  - [Configuration](#configuration)
    - [General Parameters](#general-parameters)
    - [PostgreSQL Tuning](#postgresql-tuning)
    - [Import Style](#import-style)
    - [Flatnode files](#flatnode-files)
    - [Configuration Example](#config-example)
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
  mediagis/nominatim:4.3
```

Port 8080 is the nominatim HTTP API port and 5432 is the Postgres port, which you may or may not want to expose.

If you want to check that your data import was successful, you can use the API with the following URL: http://localhost:8080/search.php?q=avenue%20pasteur

## Configuration

### General Parameters

The following environment variables are available for configuration:

- `PBF_URL`: Which [OSM extract](#openstreetmap-data-extracts) to download and import. It cannot be used together with `PBF_PATH`.
  Check [https://download.geofabrik.de](https://download.geofabrik.de) 
  Since de DL speed is restrictet at Geofabrik, for importing the full planet there is a recommended list of mirrors at the [OSM Wiki](https://wiki.openstreetmap.org/wiki/Planet.osm#Planet.osm_mirrors).
  At the mirror sites you can find the folder /planet which contains the planet-latest.osm.pbf
  and mostly a /replication folder for the `REPLICATION_URL`.
- `PBF_PATH`: Which [OSM extract](#openstreetmap-data-extracts) to import from the .pbf file inside the container. It cannot be used together with `PBF_URL`.
- `REPLICATION_URL`: Where to get updates from. For exampe at Geofabrik under for example europe: https://download.geofabrik.de/europe-updates/
                     The Europe member countrys update path in in https://download.geofabrik.de/europe/
                    if only osm.pbf files visible delete at the end of the site URL the.html ...europe/ instad of ...europe.html          
                     Other map update paths like this example https://download.geofabrik.de/countryname-updates/ 
 
- `REPLICATION_UPDATE_INTERVAL`: How often upstream publishes diffs (in seconds, default: `86400`). _Requires `REPLICATION_URL` to be set._
- `REPLICATION_RECHECK_INTERVAL`: How long to sleep if no update found yet (in seconds, default: `900`). _Requires `REPLICATION_URL` to be set._
- `UPDATE_MODE`: How to run replication to [update nominatim data](https://nominatim.org/release-docs/4.3.0/admin/Update/#updating-nominatim). Options: `continuous`/`once`/`catch-up`/`none` (default: `none`)
- `FREEZE`: Freeze database and disable dynamic updates to save space. (default: `false`)
- `REVERSE_ONLY`: If you only want to use the Nominatim database for reverse lookups. (default: `false`)
- `IMPORT_WIKIPEDIA`: Whether to download and import the Wikipedia importance dumps (`true`) or path to importance dump in the container. Importance dumps improve the scoring of results. On a beefy 10 core server, this takes around 5 minutes. (default: `false`)
- `IMPORT_US_POSTCODES`: Whether to download and import the US postcode dump (`true`) or path to US postcode dump in the container. (default: `false`)
- `IMPORT_GB_POSTCODES`: Whether to download and import the GB postcode dump (`true`) or path to GB postcode dump in the container. (default: `false`)
- `IMPORT_TIGER_ADDRESSES`: Whether to download and import the Tiger address data (`true`) or path to a preprocessed Tiger address set in the container. (default: `false`)
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
- `POSTGRES_CHECKPOINT_COMPLETION_TARGET` (default: `0.9`)

See https://nominatim.org/release-docs/4.3.0/admin/Installation/#tuning-the-postgresql-database for more details on those settings.

### Import Style

The import style can be modified through an environment variable :

- `IMPORT_STYLE` (default: `full`)

Available options are :

- `admin`: Only import administrative boundaries and places.
- `street`: Like the admin style but also adds streets.
- `address`: Import all data necessary to compute addresses down to house number level.
- `full`: Default style that also includes points of interest.
- `extratags`: Like the full style but also adds most of the OSM tags into the extratags column.

See https://nominatim.org/release-docs/4.3.0/admin/Import/#filtering-imported-data for more details on those styles.

### Flatnode files

In addition you can also mount a volume / bind-mount on `/nominatim/flatnode` (see: Persistent container data) to use flatnode storage. This is advised for bigger imports (Europe, North America etc.), see: https://nominatim.org/release-docs/4.3.0/admin/Import/#flatnode-files. If the mount is available for the container, the flatnode configuration is automatically set and used.
  
```sh
docker run -it \
  -v nominatim-flatnode:/nominatim/flatnode \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -p 8080:8080 \
  --name nominatim \
  mediagis/nominatim:4.3
```

## Persistent container data

If you want to keep your imported data across deletion and recreation of your container, make the following folder a volume:

- `/var/lib/postgresql/14/main` is the storage location of the Postgres database & holds the state about whether the import was successful
- `/nominatim/flatnode` is the storage location of the flatnode file.

So if you want to be able to kill your container and start it up again with all the data still present use the following command:

```sh
docker run -it --shm-size=1g \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e REPLICATION_URL=https://download.geofabrik.de/europe/monaco-updates/ \
  -e IMPORT_WIKIPEDIA=false \
  -e NOMINATIM_PASSWORD=very_secure_password \
  -v nominatim-data:/var/lib/postgresql/14/main \
  -p 8080:8080 \
  --name nominatim \
  mediagis/nominatim:4.3
```
### Configuration Example

A setup example with almost all flag possibilities including a short explanation:

```sh

docker run -it \

	-v nominatim-flatnode:/nominatim/flatnode \
	#Sets the flatnode file, which is to reduce the load on the database when you plan to use multiple countrys together bigger than 6GB
	#and highly recommended if you want to import the World!
	
	-e POSTGRES_SHARED_BUFFERS=2GB \
	-e POSTGRES_MAINTAINENCE_WORK_MEM=10GB \
	-e POSTGRES_AUTOVACUUM_WORK_MEM=2GB \
	-e POSTGRES_WORK_MEM=50MB \
	-e POSTGRES_EFFECTIVE_CACHE_SIZE=24GB \
	-e POSTGRES_SYNCHRONOUS_COMMIT=off \
	-e POSTGRES_MAX_WAL_SIZE=1GB \
	-e POSTGRES_CHECKPOINT_TIMEOUT=10min \
	-e POSTGRES_CHECKPOINT_COMPLETITION_TARGET=0.9 \
	#PostgreSQL Tuning, without the need to edit the .conf after the setup(Nominatim default recommended values)

	-e PBF_URL=https://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/pbf/planet-latest.osm.pbf \
	#Sets the target for the initial file for the import. If the files aleready on the local System you use:
	#-e PBF_PATH=/path/to/your/planet-latest.osm.pbf 	PBF_URL cannot be used together with PBF_PATH!

	-e REPLICATION_URL=https://ftp5.gwdg.de/pub/misc/openstreetmap/planet.openstreetmap.org/replication/day/ \
	#Sets the Path, where Nominatim gets the map updates - the REPLICATION_URL is never a file.

	-e REPLICATION_UPDATE_INTERVAL=43200
	#How often upstream publishes diffs (in seconds, default: 86400). Requires REPLICATION_URL to be set.

	-e REPLICATION_RECHECK_INTERVAL=450 
	#How long to sleep if no update found yet (in seconds, default: 900). Requires REPLICATION_URL to be set.

	-e UPDATE_MODE=continuous/once/catch-up/none
	#Configures the way the map files will be updated (default: none)

	-e FREEZE=true/false
	#Disables the updates to save space for example (default: false)

	-e REVERSE_ONLY=True/false
	#If you only want to use the Nominatim database for reverse lookups. (default: false)

	-e IMPORT_WIKIPEDIA=true\false
	#When enabled additional Wikipedia Data will be loaded (default off)

	-e IMPORT_US_POSTCODES=true\false 
	#Whether to download and import the US postcode dump (true) or path to US postcode dump in the container. (default: false)

	-e IMPORT_GB_POSTCODES=true\false 
	#Whether to download and import the GB postcode dump (true) or path to GB postcode dump in the container. (default: false)

	-e IMPORT_STYLE=admin/street/address/full/extratags
	#Sets either an importfilter for a reduced data import or the full set and the full set with additional data(default: full):
	#admin: Only import administrative boundaries and places.
	#street: Like the admin style but also adds streets.
	#address: Import all data necessary to compute addresses down to house number level.
	#full: Default style that also includes points of interest.
	#extratags: Like the full style but also adds most of the OSM tags into the extratags column.
	
	-e IMPORT_TIGER_ADDRESSES=true\false 
	#Whether to download and import the Tiger address data (true) or path to a preprocessed Tiger address set in the container. (default: false)

	-e THREADS=10 \
	#Sets the used threads at the import (default 16)

	--shm-size=60g \
	#Sets the Docker tmpfs. Highly recommended for bigger imports like Europe. At least 1GB - ideally half of aviable RAM. 

	-e NOMINATIM_PASSWORD=supersafepassword
	#The password to connect to the database with (default: qaIACxO6wMR3)

	-p 8080:8080 \
	#Sets the ports of the container guest:host

	--name nominatim \
	#Sets the name of the container

	mediagis/nominatim:4.3 
	#Here you choose the Docker image and version
	
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
  mediagis/nominatim:4.3
```

where the _/osm-maps/data/_ directory contains _monaco-latest.osm.pbf_ file that is mounted and available in container: _/nominatim/data/monaco-latest.osm.pbf_

## Updating the database

Full documentation for Nominatim update available [here](https://nominatim.org/release-docs/4.3.0/admin/Update/). For a list of other methods see the output of:

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
  mediagis/nominatim:4.3
```

where the _/osm-maps/data/_ directory contains _merged.osm.pbf_ file that is mounted and available in container: _/nominatim/data/merged.osm.pbf_

## Importance Dumps, Postcode Data, and Tiger Addresses

Including the Wikipedia importance dumps, postcode files, and Tiger address data can improve results. These can be automatically downloaded by setting the appropriate options (see above) to `true`. Alternatively, they can be imported from local files by specifying a file path (relative to the container), similar to how `PBF_PATH` is used. For example:

```sh
docker run -it \
  -e PBF_URL=https://download.geofabrik.de/europe/monaco-latest.osm.pbf \
  -e IMPORT_WIKIPEDIA=/nominatim/extras/wikimedia-importance.sql.gz \
  -p 8080:8080 \
  -v /osm-maps/extras:/nominatim/extras \
  --name nominatim \
  mediagis/nominatim:4.3
```

Where the path to the importance dump is given relative to the container. (The file does not need to be named `wikimedia-importance.sql.gz`.) The same works for `IMPORT_US_POSTCODES` and `IMPORT_GB_POSTCODES`.

For more information about the Tiger address file, see [Installing TIGER housenumber data for the US](https://nominatim.org/release-docs/4.3.0/customize/Tiger/).

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

