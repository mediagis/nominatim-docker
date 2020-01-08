# Nominatim Docker (Nominatim version 2.5)

1. Modify Dockerfile, set your url for PBF

  ```
  ENV PBF_DATA http://download.geofabrik.de/europe/monaco-latest.osm.pbf
  ```
2. Configure incremental update. By default CONST_Replication_Url configured for Monaco.
If you want a different update source, you will need to declare `CONST_Replication_Url` in local.php. Documentation [here] (https://github.com/openstreetmap/Nominatim/blob/master/docs/Import-and-Update.md#updates). For example, to use the daily country extracts diffs for Gemany from geofabrik add the following:
  ```
  @define('CONST_Replication_Url', 'http://download.geofabrik.de/europe/germany-updates');
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

You can run Docker image from docker hub.

```
docker run --restart=always -d -p 8080:8080 --name nominatim mediagis/nominatim:latest
```
Service will run on [http://localhost:8080/](http:/localhost:8080)

# Update

Full documentation for Nominatim update available [here](https://github.com/openstreetmap/Nominatim/blob/master/docs/Import-and-Update.md#updates). For a list of other methods see the output of:
  ```
  docker exec -it nominatim sudo -u nominatim ./src/build/utils/update.php --help
  ```

The following command will keep your database constantly up to date:
  ```
  docker exec -it nominatim sudo -u nominatim ./src/build/utils/update.php --import-osmosis-all
  ```
If you have imported multiple country extracts and want to keep them
up-to-date, have a look at the script in
[issue #60](https://github.com/openstreetmap/Nominatim/issues/60).
