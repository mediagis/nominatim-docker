# Nominatim Docker

100% working container for [Nominatim](https://github.com/twain47/Nominatim).

Run [http://wiki.openstreetmap.org/wiki/Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) in a docker container. Clones the current master and builds it. This is always the latest version, be cautious as it may be unstable.

Uses Ubuntu 14.04 and PostgreSQL 9.3

# Country
To check that everything is set up correctly, download and load to Postgres PBF file with minimal size - Europe/Monacco (latest) from geofabrik.de.

If a different country should be used you can set `PBF_DATA` on build.

1. Clone repository

  ```
  # git clone git@github.com:cartography/nominatim-docker.git
  # cd nominatim-docker
  ```

2. Modify Dockerfile, set your url for PBF

  ```
  ENV PBF_DATA http://download.geofabrik.de/europe/monaco-latest.osm.pbf
  ```
3. Build 

  ```
  docker build -t nominatim .
  ```
4. Run

  ```
  docker run --restart=always -d -p 8080:8080 --name nominatim-monacco nominatim
  ```
  If this succeeds, open [http://localhost:8080/](http:/localhost:8080) in a web browser
# Running

You can run Docker image from docher hub.

```
docker run --restart=always -d -p 8080:8080 --name nominatim cartography/nominatim-docker
```
Service will run on [http://localhost:8080/](http:/localhost:8080)
