# Pre-imported Nominatim Docker (Nominatim version 3.6)

Use this version if you need to deploy a Nominatim server on a
machine which has no access to the Internet or when a fast container
startup is required.
Settings cannot be changed when running the container, configuration is done
by editing the Dockerfile

## Building

The user is expected to build this container: no image is provided.

To do so, please edit the `Dockerfile` and set a password for the Postgres database
by replacing `<password>` and provide a link to the `osm.pbf` file where it says
`region`.

OSM extracts can be found at https://download.geofabrik.de/

Then, run `docker build -t image_name:image_tag .`

## Runnning

To run a container, port `8080` must be exposed:

`docker run -p 8080:8080 image_name:image_tag`

Upon running, check if everything is correct by visiting `http://localhost:8080/seach?q=<some_address_here>`
