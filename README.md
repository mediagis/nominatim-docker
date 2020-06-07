# Nominatim Docker
[![All Contributors](https://img.shields.io/badge/all_contributors-3-orange.svg?style=flat-square)](#contributors)

100% working container for [Nominatim](https://github.com/openstreetmap/Nominatim).

[![](https://images.microbadger.com/badges/image/mediagis/nominatim.svg)](https://microbadger.com/images/mediagis/nominatim "Get your own image badge on microbadger.com")
# Supported tags and respective `Dockerfile` links #

- [`3.4.2`, `3.4`  (*3.4/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.4)
- [`3.3.1`, `3.3`  (*3.3/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.3)
- [`3.2.1`, `3.2`  (*3.2/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.2)
- [`3.1.0`, `3.1`  (*3.1/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.1)
- [`3.0.1`, `3.0`  (*3.0/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.0)
- [`2.5.1`, `2.5`, `latest`  (*2.5/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/2.5)

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
See relevant installation instructions for each version

## Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://github.com/dlucia"><img src="https://avatars3.githubusercontent.com/u/1665623?v=4" width="100px;" alt=""/><br /><sub><b>Donato Lucia</b></sub></a><br /><a href="#infra-dlucia" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=dlucia" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/geomark"><img src="https://avatars1.githubusercontent.com/u/1500692?v=4" width="100px;" alt=""/><br /><sub><b>Georgios Markakis</b></sub></a><br /><a href="#infra-geomark" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=geomark" title="Code">💻</a></td>
    <td align="center"><a href="http://www.symvaro.com"><img src="https://avatars1.githubusercontent.com/u/16721635?v=4" width="100px;" alt=""/><br /><sub><b>Philip Kozeny</b></sub></a><br /><a href="#infra-philipkozeny" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=philipkozeny" title="Code">💻</a></td>
    <td align="center"><a href="http://www.therek.net/"><img src="https://avatars2.githubusercontent.com/u/89052?v=4" width="100px;" alt=""/><br /><sub><b>Cezary Morga</b></sub></a><br /><a href="#infra-therek" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=therek" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/thomasnordquist"><img src="https://avatars0.githubusercontent.com/u/7721625?v=4" width="100px;" alt=""/><br /><sub><b>Thomas Nordquist</b></sub></a><br /><a href="#infra-thomasnordquist" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=thomasnordquist" title="Code">💻</a></td>
    <td align="center"><a href="https://keybase.io/davkorss"><img src="https://avatars0.githubusercontent.com/u/5597595?v=4" width="100px;" alt=""/><br /><sub><b>Andrey Ruíz</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=davkorss" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/UntitleDude"><img src="https://avatars2.githubusercontent.com/u/14983691?v=4" width="100px;" alt=""/><br /><sub><b>UntitleDude</b></sub></a><br /><a href="#infra-UntitleDude" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=UntitleDude" title="Code">💻</a></td>
  </tr>
</table>

<!-- markdownlint-enable -->
<!-- prettier-ignore-end -->
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
