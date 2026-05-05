# Nominatim Docker

An alternative Docker image for [Nominatim](https://github.com/openstreetmap/Nominatim) based on the [nominatim-docker](https://github.com/mediagis/nominatim-docker) project.

- Bring-your-own-database
- arm64 and x86 compatible image

## Quick Start

To get started, a mostly-complete docker-compose example is provided in the [`deploy/`](./deploy) directory.

```yaml
volumes:
  nominatim:
  pg:

services:
  nominatim:
    image: ghcr.io/frozenbug-dev/nominatim:5.3.2
    container_name: nominatim
    ports:
      - 8080:8080
    volumes:
      - nominatim:/nominatim
    depends_on:
      nominatim-postgres:
        condition: service_healthy
    environment:
      # for larger imports make sure to tune postgres!
      PBF_URL: https://download.geofabrik.de/europe/monaco-latest.osm.pbf
      REPLICATION_URL: https://download.geofabrik.de/europe/monaco-updates/
      IMPORT_STYLE: full
      # these are required because the script uses psql to create the `nominatim` database
      PGHOST: ${PGHOST}
      PGDATABASE: ${PGDATABASE}
      PGUSER: ${PGUSER}
      PGPASSWORD: ${PGPASSWORD}
      NOMINATIM_PASSWORD: ${PGPASSWORD}
      # the DSN is used by nominatim itself internally and needs to exist. in the future I might
      # make this simpler
      NOMINATIM_DATABASE_DSN: "host=${PGHOST} dbname=${PGDATABASE} user=${PGUSER} password=${PGPASSWORD}"
      NOMINATIM_TOKENIZER: icu

  nominatim-postgres:
    image: postgis/postgis:18-3.6
    # or use the following image for arm-based systems
    # image: docker.io/imresamu/postgis:18-3.6
    volumes:
      - pg:/var/lib/postgresql
      # use the conf in deploy/ and tune the settings based on your system configuration
      # https://nominatim.org/release-docs/latest/admin/Installation/#tuning-the-postgresql-database
      - ./postgresql.conf:/etc/postgresql/postgresql.conf
    environment:
      POSTGRES_USER: ${PGUSER}
      POSTGRES_PASSWORD: ${PGPASSWORD}
      POSTGRES_DB: ${PGDATABASE}
    command: postgres -c 'config_file=/etc/postgresql/postgresql.conf'
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${PGUSER} -d postgres"]
      interval: 10s
      timeout: 10s
      retries: 10
```

After the import is complete, you can access the Nominatim API at `http://localhost:8080/search?q=avenue%20pasteur`.

> [!note]
> Work in progress.

---

> [!note]
> Many thanks to the contributors to the original [nominatim-docker](https://github.com/mediagis/nominatim-docker) project without whom this project probably wouldn't exit.
> This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
