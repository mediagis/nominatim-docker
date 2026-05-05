# Nominatim Docker

An alternative Docker image for [Nominatim](https://github.com/openstreetmap/Nominatim) based on the [nominatim-docker](https://github.com/mediagis/nominatim-docker) project.

```bash
docker pull ghcr.io/frozenbug-dev/nominatim:5.3.2
```

- Bring-your-own-postgres
- Multi-arch (`arm64` and `x86`) Docker image
- Separate scripts for each stage of the process, allowing for more flexibility in deployment.
  - `serve` to run the API
  - `import` to start the initial import
  - `sync` to initiate the continous replication

## Quick Start

To get started, a mostly-complete docker-compose example is provided in the [`deploy/`](./deploy) directory. Make sure to update the database password in `.env` and the `PBF_URL` and `REPLICATION_URL` in the `compose.yaml` file.

```bash
# first run the import
docker compose up nominatim-import
# wait until it finishes
# depending on the size of your dataset, it can take hours

# at this point it's recommended to update your postgresql.conf
docker compose restart nominatim-postgres

# then start up the the API and the sync process
docker compose up -d
```

Now you can access the Nominatim API at `http://localhost:8080/search?q=avenue%20pasteur`.

---

> [!note]
> Many thanks to the contributors to the original [nominatim-docker](https://github.com/mediagis/nominatim-docker) project without whom this project probably wouldn't exit.
> This project follows the [all-contributors](https://github.com/all-contributors/all-contributors) specification. Contributions of any kind welcome!
