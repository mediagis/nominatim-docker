ARG NOMINATIM_VERSION=4.5.0
ARG USER_AGENT=mediagis/nominatim-docker:${NOMINATIM_VERSION}

FROM ubuntu:24.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

WORKDIR /app

# Inspired by https://github.com/reproducible-containers/buildkit-cache-dance?tab=readme-ov-file#apt-get-github-actions
RUN  \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    # Keep downloaded APT packages in the docker build cache
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' >/etc/apt/apt.conf.d/keep-cache && \
    # Do not start daemons after installation.
    echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    # Install all required packages.
    && apt-get -y update -qq \
    && apt-get -y install \
        locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get -y install \
        -o APT::Install-Recommends="false" \
        -o APT::Install-Suggests="false" \
        # Build tools from sources. \
        build-essential \
        osm2pgsql \
        pkg-config \
        libicu-dev \
        python3-dev \
        python3-pip \
        # PostgreSQL.
        postgresql-contrib \
        postgresql-server-dev-16 \
        postgresql-16-postgis-3 \
        postgresql-16-postgis-3-scripts \
        # Misc.
        curl \
        sudo \
        sshpass \
        openssh-client


# Configure postgres.
RUN true \
    && echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/16/main/pg_hba.conf \
    && echo "listen_addresses='*'" >> /etc/postgresql/16/main/postgresql.conf

ARG NOMINATIM_VERSION
ARG USER_AGENT

# Osmium install to run continuous updates.
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked pip install --break-system-packages \
    nominatim-db==$NOMINATIM_VERSION \
    osmium \
    psycopg[binary] \
    falcon \
    uvicorn \
    gunicorn \
    nominatim-api

# Nominatim install.

RUN true \
    # Remove development and unused packages.
    && apt-get -y remove --purge --auto-remove \
        build-essential \
        postgresql-server-dev-16 \
    # Clear temporary files and directories.
    && rm -rf \
        /tmp/* \
        /var/tmp/* \
    && pip cache purge

# Postgres config overrides to improve import performance (but reduce crash recovery safety)
COPY conf.d/postgres-import.conf /etc/postgresql/16/main/conf.d/postgres-import.conf.disabled
COPY conf.d/postgres-tuning.conf /etc/postgresql/16/main/conf.d/

COPY config.sh /app/config.sh
COPY init.sh /app/init.sh
COPY start.sh /app/start.sh
COPY startpostgres.sh /app/startpostgres.sh

# Collapse image to single layer.
FROM scratch

COPY --from=build / /

# Please override this
ENV NOMINATIM_PASSWORD=qaIACxO6wMR3

ENV PROJECT_DIR=/nominatim

ARG USER_AGENT
ENV USER_AGENT=${USER_AGENT}

WORKDIR /app

EXPOSE 5432
EXPOSE 8080

COPY conf.d/env $PROJECT_DIR/.env

CMD ["/app/start.sh"]
