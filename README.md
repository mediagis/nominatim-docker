# Nominatim Docker
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors)

100% working container for [Nominatim](https://github.com/openstreetmap/Nominatim).

[![](https://images.microbadger.com/badges/image/mediagis/nominatim.svg)](https://microbadger.com/images/mediagis/nominatim "Get your own image badge on microbadger.com")
# Supported tags and respective `Dockerfile` links #

- [`3.4.0`, `3.4`  (*3.4/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.4)
- [`3.3.0`, `3.3`  (*3.3/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.3)
- [`3.2.0`, `3.2`  (*3.2/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.2)
- [`3.1.0`, `3.1`  (*3.1/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.1)
- [`3.0.1`, `3.0`  (*3.0/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.0)
- [`2.5.0`, `2.5`, `latest`  (*2.5/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/2.5)

Run [http://wiki.openstreetmap.org/wiki/Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) in a docker container. Clones the current master and builds it. This is always the latest version, be cautious as it may be unstable.

Uses Ubuntu 19.10 and PostgreSQL 11.3

# Country
To check that everything is set up correctly, download and load to Postgres PBF file with minimal size - Europe/Monacco (latest) from geofabrik.de.

If a different country should be used you can set `PBF_DATA` on build.

1. Clone repository

  ```
  # git clone git@github.com:mediagis/nominatim-docker.git
  # cd nominatim-docker/<version>
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
  Alternatively you could set a different CONST_Replication_Url on build tim by setting DYN_REPL_URL as build-arg. See "Build".

4. Build

  ```
  docker build -t nominatim .
  ```

  with build-arg:
  ```
   docker build --build-arg DYN_REP_URL=http://download.geofabrik.de/europe/germany-updates PBF_DATA=http://download.geofabrik.de/europe/germany-latest.osm.pbf -t nominatim .
   ```
5. Run

  ```
  docker run --restart=always -d -p 8080:8080 --name nominatim-monacco nominatim
  ```
See relevant installation instructions for each version

## Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/dlucia"><img src="https://avatars3.githubusercontent.com/u/1665623?v=4" width="100px;" alt="Donato Lucia"/><br /><sub><b>Donato Lucia</b></sub></a><br /><a href="#infra-dlucia" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=dlucia" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/geomark"><img src="https://avatars1.githubusercontent.com/u/1500692?v=4" width="100px;" alt="Georgios Markakis"/><br /><sub><b>Georgios Markakis</b></sub></a><br /><a href="#infra-geomark" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=geomark" title="Code">💻</a></td>
    <td align="center"><a href="http://www.symvaro.com"><img src="https://avatars1.githubusercontent.com/u/16721635?v=4" width="100px;" alt="Philip Kozeny"/><br /><sub><b>Philip Kozeny</b></sub></a><br /><a href="#infra-philipkozeny" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=philipkozeny" title="Code">💻</a></td>
  </tr>
</table>

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
