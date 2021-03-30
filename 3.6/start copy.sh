#!/bin/bash

gpasswd -a postgres ssl-cert # Add this

chown -R postgres:postgres /var/run/postgresql # Add this
chown -R postgres:postgres /var/log/postgresql # Add this
chown -R postgres:postgres /etc/postgresql # Add this
chmod 600 /etc/ssl/private/ssl-cert-snakeoil.key # Add this
chown postgres:ssl-cert /etc/ssl/private/ # Add this
chown postgres:postgres /etc/ssl/private/ssl-cert-snakeoil.key # Add this

stopServices() {
        service apache2 stop
        service postgresql stop
}
trap stopServices TERM

/app/src/build/utils/setup.php --setup-website

service postgresql start
service apache2 start

# fork a process and wait for it
tail -f /var/log/postgresql/postgresql-12-main.log &
wait