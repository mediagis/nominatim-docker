# Nominatim Docker

Run [http://wiki.openstreetmap.org/wiki/Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) in a docker container. Clones the current master and builds it. This is always the latest version, be cautious as it may be unstable.

Uses Ubuntu 14.04 and PostgreSQL 9.3

# Country
It downloads Europe/Monacco (latest) from geofabrik.de.

If a different country should be used you can set `PBF_DATA` on build.

# Building

To rebuild the image locally execute

```
docker build -t nominatim .
```

# Running

To run the container execute.

```
docker run --restart=always -d -p 8080:8080 --name nominatim-monacco nominatim
```

If this succeeds, open [http://localhost:8080/](http:/localhost:8080) in a web browser
