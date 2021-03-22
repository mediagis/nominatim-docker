# Nominatim Docker (Nominatim version 3.6)


## Automatic import

Download the required data, initialize the database and start nominatim in one go

```
  docker run -it --rm \
    -e PBF_URL=http://download.geofabrik.de/europe/monaco-latest.osm.pbf \
    -e REPLICATION_URL=http://download.geofabrik.de/europe/monaco-updates/ \
    -e IMPORT_WIKIPEDIA=true \
    -p 8080:8080 \
    --name nominatim \
    stadtnavi/nominatim:3.6
```

The port 8080 is the nominatim HTTP API port and 5432 is the Postgres port, which you may or may not want to expose.

If you want to check that your data import was sucessful, you can use the API with the following URL: http://localhost:8080/search.php?q=avenue%20pasteur

## Configuration

The the environment variables are available:

  - `PBF_URL`: Which OSM extract to download. Check https://download.geofabrik.de
  - `REPLICATION_URL`: Where to get updates from. Also availble from Geofabrik.
  - `IMPORT_WIKIPEDIA`: Whether to import the Wikipedia importance dumps, which improve scoring of results. On a beefy 10 core server this takes around 5 minutes. (default: `true`)
  - `IMPORT_US_POSTCODES`: Whether to import the US postcode dump. (default: `false`)
  - `IMPORT_GB_POSTCODES`: Whether to import the GB postcode dump. (default: `false`)
  - `THREADS`: How many treads should be used to import (default: `16`)
  - `NOMINATIM_PASSWORD`: The password to connect to the database with (default: `qaIACxO6wMR3`)

## Password

In order to override the default password for the database access use the environment variable `NOMINATIM_PASSWORD`. An example is given in the
next section.

## Persistent container data

There are two folders inside the contain the can be persisted across container creation and removal.

- `/app/src` holds the state about whether the import was succesful and general nominatim config
- `/var/lib/postgresql/12/main` is the storage location of the Postgres database

So if you want to be able to kill your container and start it up again with all the data still present use the following command:

```
  docker run -it --rm \
    -e PBF_URL=http://download.geofabrik.de/europe/monaco-latest.osm.pbf \
    -e REPLICATION_URL=http://download.geofabrik.de/europe/monaco-updates/ \
    -e IMPORT_WIKIPEDIA=false \
    -e NOMINATIM_PASSWORD=very_secure_password \
    -v nominatim-config:/app/src \
    -v nominatim-postgres:/var/lib/postgresql/12/main \
    -p 8080:8080 \
    --name nominatim \
    stadtnavi/nominatim:3.6
```

## Updating the database

Full documentation for Nominatim update available [here](https://github.com/openstreetmap/Nominatim/blob/master/docs/admin/Import-and-Update.md#updates). For a list of other methods see the output of:
```
docker exec -it nominatim sudo -u nominatim ./src/build/utils/update.php --help
```

The following command will keep updating the database forever:

```
docker exec -it nominatim sudo -u nominatim ./src/build/utils/update.php --import-osmosis-all
```

If there are no updates available this process will sleep for 15 minutes and try again.

## Development

If you want to work on the Docker image you can use the following command to build an local
image and run the container with

```
docker build -t nominatim . && \
docker run -it --rm \
    -e PBF_URL=http://download.geofabrik.de/europe/monaco-latest.osm.pbf \
    -e REPLICATION_URL=http://download.geofabrik.de/europe/monaco-updates/ \
    -p 8080:8080 \
    --name nominatim \
    nominatim
```
