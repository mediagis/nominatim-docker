#!/bin/bash

# Custom shim to start the nominatim Apache server based on config values from the ECS TaskDefinition
# $DB_IP must be injected as environment variable

mkdir /data

REPLICATION_URL="http://download.geofabrik.de/north-america-updates/"
DB_DSN="pgsql:host=$DB_IP;port=6432;user=nominatim;password=password1234;dbname=nominatim"

sed \
    -e "s,{DB_DSN},$DB_DSN,g" \
    -e "s,{REPLICATION_URL},$REPLICATION_URL,g" \
    < /app/src/build/settings/local.php \
    | tee /data/local.php

/app/startapache.sh

