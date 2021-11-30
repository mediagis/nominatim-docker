# Nominatim Docker

100% working container for [Nominatim](https://github.com/openstreetmap/Nominatim).

![GitHub Workflow Status](https://img.shields.io/github/workflow/status/mediagis/nominatim-docker/CI?style=flat-square) ![Github All Contributors](https://img.shields.io/github/all-contributors/mediagis/nominatim-docker?style=flat-square) ![Docker Pulls](https://img.shields.io/docker/pulls/mediagis/nominatim?style=flat-square)

# How to use
Clone repository

  ```
  # git clone git@github.com:mediagis/nominatim-docker.git
  # cd nominatim-docker/<version>
  ```
See relevant installation instructions for each version in the <version>/README.md

# Supported tags and respective `Dockerfile` links #

- [`4.0.1`, `4.0`  (*4.0/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/4.0)
- [`3.7.2`, `3.7`  (*3.7/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.7)

# Deprecated tags and respective `Dockerfile` links #

- [`3.6.0`, `3.6`  (*3.6/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.6)
- [`3.5.2`, `3.5`  (*3.5/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.5)
- [`3.4.2`, `3.4`  (*3.4/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.4)
- [`3.3.1`, `3.3`  (*3.3/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.3)
- [`3.2.1`, `3.2`  (*3.2/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.2)
- [`3.1.0`, `3.1`  (*3.1/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.1)
- [`3.0.1`, `3.0`  (*3.0/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/3.0)
- [`2.5.1`, `2.5`  (*2.5/Dockerfile*)](https://github.com/mediagis/nominatim-docker/tree/master/2.5)



**Caution:** When you upgrade to another version (e.g. 3.4 to 3.5) there may be major version changes like Postgres and data incompatiblity. See the relevant instructions for each version. Also check the Nominatim migration guide [https://www.nominatim.org/release-docs/latest/admin/Migration/](https://www.nominatim.org/release-docs/latest/admin/Migration/).

The latest version uses Ubuntu 20.04 and PostgreSQL 12.



# Contributors

Thanks goes to these wonderful people ([emoji key](https://allcontributors.org/docs/en/emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tr>
    <td align="center"><a href="https://www.linkedin.com/in/winsent/"><img src="https://avatars.githubusercontent.com/u/2316328?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Andrew</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=winsento" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=winsento" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/dlucia"><img src="https://avatars3.githubusercontent.com/u/1665623?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Donato Lucia</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=dlucia" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/geomark"><img src="https://avatars1.githubusercontent.com/u/1500692?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Georgios Markakis</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=geomark" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/philipkozeny"><img src="https://avatars1.githubusercontent.com/u/16721635?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Philip Kozeny</b></sub></a><br /><a href="#infra-philipkozeny" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=philipkozeny" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=philipkozeny" title="Tests">⚠️</a> <a href="https://github.com/mediagis/nominatim-docker/pulls?q=is%3Apr+reviewed-by%3Aphilipkozeny" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=philipkozeny" title="Documentation">📖</a></td>
    <td align="center"><a href="https://www.therek.net/"><img src="https://avatars2.githubusercontent.com/u/89052?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Cezary Morga</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=therek" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/thomasnordquist"><img src="https://avatars0.githubusercontent.com/u/7721625?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Thomas Nordquist</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=thomasnordquist" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://keybase.io/davkorss"><img src="https://avatars0.githubusercontent.com/u/5597595?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Andrey Ruíz</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=davkorss" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/UntitleDude"><img src="https://avatars2.githubusercontent.com/u/14983691?v=4?s=100" width="100px;" alt=""/><br /><sub><b>UntitleDude</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=UntitleDude" title="Code">💻</a></td>
    <td align="center"><a href="https://www.linkedin.com/in/jmcker"><img src="https://avatars3.githubusercontent.com/u/25001741?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Jack McKernan</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=jmcker" title="Code">💻</a></td>
    <td align="center"><a href="https://twitter.com/mtmthemovie"><img src="https://avatars1.githubusercontent.com/u/3727288?v=4?s=100" width="100px;" alt=""/><br /><sub><b>mtmail</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=mtmail" title="Documentation">📖</a> <a href="#question-mtmail" title="Answering Questions">💬</a> <a href="https://github.com/mediagis/nominatim-docker/pulls?q=is%3Apr+reviewed-by%3Amtmail" title="Reviewed Pull Requests">👀</a></td>
    <td align="center"><a href="https://angel.co/eSlider"><img src="https://avatars3.githubusercontent.com/u/1188335?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Andrey Oblivantsev</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=eSlider" title="Code">💻</a></td>
    <td align="center"><a href="https://www.linkedin.com/in/simoneromano92/"><img src="https://avatars2.githubusercontent.com/u/6860423?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Simone</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=sromano1992" title="Code">💻</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/DuncanMackintosh"><img src="https://avatars0.githubusercontent.com/u/4966417?v=4?s=100" width="100px;" alt=""/><br /><sub><b>DuncanMackintosh</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=DuncanMackintosh" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=DuncanMackintosh" title="Documentation">📖</a></td>
    <td align="center"><a href="http://iiroalhonen.com"><img src="https://avatars2.githubusercontent.com/u/18322926?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Iiro Alhonen</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=Iikeli" title="Documentation">📖</a></td>
    <td align="center"><a href="https://www.ufoproger.ru"><img src="https://avatars3.githubusercontent.com/u/212711?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mikhail Snetkov</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=ufoproger" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/FritschAuctores"><img src="https://avatars2.githubusercontent.com/u/43264099?v=4?s=100" width="100px;" alt=""/><br /><sub><b>FritschAuctores</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=FritschAuctores" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/rebos"><img src="https://avatars.githubusercontent.com/u/490798?v=4?s=100" width="100px;" alt=""/><br /><sub><b>rebos</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=rebos" title="Code">💻</a></td>
    <td align="center"><a href="https://leonard.io/blog/"><img src="https://avatars.githubusercontent.com/u/151346?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Leonard Ehrenfried</b></sub></a><br /><a href="#infra-leonardehrenfried" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=leonardehrenfried" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=leonardehrenfried" title="Tests">⚠️</a> <a href="https://github.com/mediagis/nominatim-docker/pulls?q=is%3Apr+reviewed-by%3Aleonardehrenfried" title="Reviewed Pull Requests">👀</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=leonardehrenfried" title="Documentation">📖</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://roelandtn.frama.io/"><img src="https://avatars.githubusercontent.com/u/17683898?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nicolas Roelandt</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=Bakaniko" title="Documentation">📖</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=Bakaniko" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=Bakaniko" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/Sacerdoss"><img src="https://avatars.githubusercontent.com/u/22632241?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Sacerdoss</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=Sacerdoss" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/sake"><img src="https://avatars.githubusercontent.com/u/154311?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Tobias Wich</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=sake" title="Documentation">📖</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=sake" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/aclowkey"><img src="https://avatars.githubusercontent.com/u/2061017?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Alex Chaplianka</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=aclowkey" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/gmalenko"><img src="https://avatars.githubusercontent.com/u/6521413?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Idris Hayward</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=gmalenko" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/karlvr"><img src="https://avatars.githubusercontent.com/u/1086005?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Karl von Randow</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=karlvr" title="Documentation">📖</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/mlechner"><img src="https://avatars.githubusercontent.com/u/1194826?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Marco Lechner</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=mlechner" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/mattegawel"><img src="https://avatars.githubusercontent.com/u/14986712?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Mateusz Gaweł</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=mattegawel" title="Code">💻</a></td>
    <td align="center"><a href="http://www.forum-software.org/"><img src="https://avatars.githubusercontent.com/u/1044941?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Nicolas Ternisien</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=lastnico" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/oschlueter"><img src="https://avatars.githubusercontent.com/u/10252511?v=4?s=100" width="100px;" alt=""/><br /><sub><b>oschlueter</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=oschlueter" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/timnon"><img src="https://avatars.githubusercontent.com/u/5597397?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Tim Nonner</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=timnon" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/thlor"><img src="https://avatars.githubusercontent.com/u/6570020?v=4?s=100" width="100px;" alt=""/><br /><sub><b>thlor</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=thlor" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=thlor" title="Documentation">📖</a></td>
  </tr>
  <tr>
    <td align="center"><a href="https://github.com/mogita"><img src="https://avatars.githubusercontent.com/u/1173069?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Yun Wang</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=mogita" title="Documentation">📖</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=mogita" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Stefanic"><img src="https://avatars.githubusercontent.com/u/4499284?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Stefanic</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=Stefanic" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=Stefanic" title="Documentation">📖</a></td>
    <td align="center"><a href="https://github.com/xpoinsard"><img src="https://avatars.githubusercontent.com/u/6130463?v=4?s=100" width="100px;" alt=""/><br /><sub><b>xpoinsard</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=xpoinsard" title="Documentation">📖</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=xpoinsard" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/Bartizan"><img src="https://avatars.githubusercontent.com/u/6322553?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Bartizan</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=Bartizan" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=Bartizan" title="Documentation">📖</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=Bartizan" title="Tests">⚠️</a></td>
    <td align="center"><a href="https://github.com/galewis2"><img src="https://avatars.githubusercontent.com/u/62433564?v=4?s=100" width="100px;" alt=""/><br /><sub><b>galewis2</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=galewis2" title="Code">💻</a></td>
    <td align="center"><a href="https://github.com/TurtIeSocks"><img src="https://avatars.githubusercontent.com/u/58572875?v=4?s=100" width="100px;" alt=""/><br /><sub><b>Derick M.</b></sub></a><br /><a href="https://github.com/mediagis/nominatim-docker/commits?author=TurtIeSocks" title="Code">💻</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=TurtIeSocks" title="Documentation">📖</a> <a href="https://github.com/mediagis/nominatim-docker/commits?author=TurtIeSocks" title="Tests">⚠️</a></td>
  </tr>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
