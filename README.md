# Nominatim Docker

100% working container for [Nominatim](https://github.com/twain47/Nominatim).

[![](https://images.microbadger.com/badges/image/mediagis/nominatim.svg)](https://microbadger.com/images/mediagis/nominatim "Get your own image badge on microbadger.com")

# Supported tags and respective `Dockerfile` links #

- [`2.5.0`, `2.5`, `latest`  (*2.5/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/2.5)


Run [http://wiki.openstreetmap.org/wiki/Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) in a docker container. Clones the current master and builds it. This is always the latest version, be cautious as it may be unstable.

Uses Ubuntu 14.04 and PostgreSQL 9.3

# Country
To check that everything is set up correctly, download and load to Postgres PBF file with minimal size - Europe/Monacco (latest) from geofabrik.de.

If a different country should be used you can set `PBF_DATA` on build.

1. Clone repository

  ```
  # git clone git@github.com:mediagis/nominatim-docker.git
  # cd nominatim-docker/2.5
  ```

2. Modify Dockerfile, set your url for PBF

  ```
  ENV PBF_DATA http://download.geofabrik.de/europe/monaco-latest.osm.pbf
  ```
3. Configure incrimental update. By default CONST_Replication_Url configured for Monaco.
If you want a different update source, you will need to declare `CONST_Replication_Url` in local.php. Documentation [here] (https://github.com/twain47/Nominatim/blob/master/docs/Import_and_update.md#updates). For example, to use the daily country extracts diffs for Gemany from geofabrik add the following:
  ```
  @define('CONST_Replication_Url', 'http://download.geofabrik.de/europe/germany-updates');
  ```

4. Build 

  ```
  docker build -t nominatim .
  ```
5. Run

  ```
  docker run --restart=always -d -p 8080:8080 --name nominatim-monacco nominatim
  ```
  If this succeeds, open [http://localhost:8080/](http:/localhost:8080) in a web browser

# Running

You can run Docker image from docher hub.

```
docker run --restart=always -d -p 8080:8080 --name nominatim mediagis/nominatim:latest
```
Service will run on [http://localhost:8080/](http:/localhost:8080)

# Update

Full documentation for Nominatim update available [here](https://github.com/twain47/Nominatim/blob/master/docs/Import_and_update.md#updates). For a list of other methods see the output of:
  ```
  docker exec -it nominatim sudo -u nominatim ./src/utils/update.php --help
  ```

The following command will keep your database constantly up to date:
  ```
  docker exec -it nominatim sudo -u nominatim ./src/utils/update.php --import-osmosis-all --no-npi
  ```
If you have imported multiple country extracts and want to keep them
up-to-date, have a look at the script in
[issue #60](https://github.com/twain47/Nominatim/issues/60).
