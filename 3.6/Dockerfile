FROM ubuntu:focal AS build

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

WORKDIR /app

RUN true \
    # Do not start daemons after installation.
    && echo '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d \
    # Install all required packages.
    && apt-get -y update -qq \
    && apt-get -y install wget \
    && apt-get -y install \
        locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get -y install \
        -o APT::Install-Recommends="false" \
        -o APT::Install-Suggests="false" \
        # Build tools from sources.
        build-essential \
        g++ \
        cmake \
        libpq-dev \
        zlib1g-dev \
        libbz2-dev \
        libproj-dev \
        libexpat1-dev \
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        # PostgreSQL.
        postgresql-contrib \
        postgresql-server-dev-12 \
        postgresql-12-postgis-3 \
        postgresql-12-postgis-3-scripts \
        # PHP and Apache 2.
        php \
        php-intl \
        php-pgsql \
        apache2 \
        libapache2-mod-php \
        # Python 3.
        python3-dev \
        python3-pip \
        python3-tidylib \
        python3-psycopg2 \
        python3-setuptools \
        # Misc.
        git \
        curl \
        sudo

# Configure postgres.
RUN true \
    && echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/12/main/pg_hba.conf \
    && echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf

# Osmium install to run continuous updates.
RUN pip3 install osmium

# Nominatim install.
ENV NOMINATIM_VERSION v3.6.0

RUN true \
    && git clone \
        --config advice.detachedHead=false \
        --single-branch \
        --branch $NOMINATIM_VERSION \
        --depth 1 \
        --recursive \
        https://github.com/openstreetmap/Nominatim \
        src \
    && mkdir nominatim \
    && cd nominatim \
    && mkdir build \
    && mkdir update \
    && cd .. \
    && cd src \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j`nproc` \
    && chmod o=rwx .

RUN curl https://www.nominatim.org/data/country_grid.sql.gz > /app/src/data/country_osm_grid.sql.gz

RUN true \
    # Remove development and unused packages.
    && apt-get -y remove --purge \
        cpp-9 \
        gcc-9* \
        g++ \
        git \
        make \
        cmake* \
        llvm-10* \
        libc6-dev \
        linux-libc-dev \
        libclang-*-dev \
        build-essential \
        postgresql-server-dev-12 \
    && apt-get clean \
    # Clear temporary files and directories.
    && rm -rf \
        /tmp/* \
        /var/tmp/* \
        /root/.cache \
        /app/src/.git \
        /var/lib/apt/lists/*

# Apache configuration
COPY conf.d/local.php /app/src/build/settings/local.php
COPY conf.d/apache.conf /etc/apache2/sites-enabled/000-default.conf

# Postgres config overrides to improve import performance (but reduce crash recovery safety)
COPY conf.d/postgres-import.conf /etc/postgresql/12/main/conf.d/
COPY conf.d/postgres-tuning.conf /etc/postgresql/12/main/conf.d/

COPY config.sh /app/config.sh
COPY init.sh /app/init.sh
COPY start.sh /app/start.sh
COPY startapache.sh /app/startapache.sh
COPY startpostgres.sh /app/startpostgres.sh

# Collapse image to single layer.
FROM scratch

COPY --from=build / /

WORKDIR /app

EXPOSE 5432
EXPOSE 8080

# Please override this
ENV NOMINATIM_PASSWORD qaIACxO6wMR3
# how many threads should be use for importing
ENV THREADS=16

CMD /app/start.sh
