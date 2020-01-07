FROM ubuntu:eoan

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get -y update -qq && \
    apt-get -y install locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get install -o APT::Install-Recommends="false" -o APT::Install-Suggests="false" -y \
        build-essential cmake g++ libboost-dev libboost-system-dev \
        libboost-filesystem-dev libexpat1-dev zlib1g-dev libxml2-dev\
        libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev \
        postgresql-server-dev-11 postgresql-11-postgis-2.5 postgresql-contrib-11 \
        apache2 php php-pgsql libapache2-mod-php php-pear php-db \
        php-intl git curl sudo \
        python3-pip libboost-python-dev \
        osmosis && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* /var/tmp/*

WORKDIR /app

# Configure postgres
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/11/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/11/main/postgresql.conf

# Nominatim install
ENV NOMINATIM_VERSION v3.4.1
RUN git clone --recursive https://github.com/openstreetmap/Nominatim ./src
RUN cd ./src && git checkout tags/$NOMINATIM_VERSION && git submodule update --recursive --init && \
    mkdir build && cd build && cmake .. && make

# Osmium install to run continuous updates
RUN pip3 install osmium

# Apache configure
COPY local.php /app/src/build/settings/local.php
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf

# Load initial data
RUN curl http://www.nominatim.org/data/country_grid.sql.gz > /app/src/data/country_osm_grid.sql.gz
RUN chmod o=rwx /app/src/build

EXPOSE 5432
EXPOSE 8080

COPY start.sh /app/start.sh
COPY startapache.sh /app/startapache.sh
COPY startpostgres.sh /app/startpostgres.sh
COPY init.sh /app/init.sh


