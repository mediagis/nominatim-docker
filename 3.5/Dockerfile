FROM ubuntu:focal

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get -y update -qq && \
    apt-get -y install locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get install -o APT::Install-Recommends="false" -o APT::Install-Suggests="false" -y \
    build-essential cmake g++ libboost-dev libboost-system-dev \
    libboost-filesystem-dev libexpat1-dev zlib1g-dev \
    libbz2-dev libpq-dev libproj-dev \
    postgresql-server-dev-12 postgresql-12-postgis-3 \
    postgresql-contrib postgresql-12-postgis-3-scripts \
    apache2 php php-pgsql libapache2-mod-php \
    php-intl python3-setuptools python3-dev python3-pip \
    python3-psycopg2 python3-tidylib git curl sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*

WORKDIR /app

# Configure postgres
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/12/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf

# Osmium install to run continuous updates
RUN pip3 install osmium

# Nominatim install
ENV NOMINATIM_VERSION v3.5.1
RUN git clone --recursive https://github.com/openstreetmap/Nominatim ./src
RUN cd ./src && git checkout tags/$NOMINATIM_VERSION && git submodule update --recursive --init && \
    mkdir build && cd build && cmake .. && make -j`nproc`

# Apache configure
COPY local.php /app/src/build/settings/local.php
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf

# Load initial data
ARG with_postcodes_gb
ARG with_postcodes_us
RUN if [ "$with_postcodes_gb" = "" ]; then echo "Skipping optional GB postcode file"; else echo "Downloading optional GB postcode file"; curl http://www.nominatim.org/data/gb_postcode_data.sql.gz > /app/src/data/gb_postcode_data.sql.gz; fi;
RUN if [ "$with_postcodes_us" = "" ]; then echo "Skipping optional US postcode file"; else echo "Downloading optional US postcode file"; curl http://www.nominatim.org/data/us_postcode_data.sql.gz > /app/src/data/us_postcode_data.sql.gz; fi;
RUN curl http://www.nominatim.org/data/country_grid.sql.gz > /app/src/data/country_osm_grid.sql.gz
RUN chmod o=rwx /app/src/build

EXPOSE 5432
EXPOSE 8080

COPY start.sh /app/start.sh
COPY startapache.sh /app/startapache.sh
COPY startpostgres.sh /app/startpostgres.sh
COPY init.sh /app/init.sh


