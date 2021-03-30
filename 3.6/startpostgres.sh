#!/bin/bash

gpasswd -a postgres ssl-cert

echo 'startlololXX'

chown -R postgres:postgres /var/run/postgresql 
chown -R postgres:postgres /var/log/postgresql
chown -R postgres:postgres /etc/postgresql
chmod 600 /etc/ssl/private/ssl-cert-snakeoil.key
chown postgres:ssl-cert /etc/ssl/private/
chown postgres:postgres /etc/ssl/private/ssl-cert-snakeoil.key

service postgresql start
tail -f /var/log/postgresql/postgresql-12-main.log