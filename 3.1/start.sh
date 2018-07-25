#!/bin/bash
service postgresql start
/usr/sbin/apache2ctl -D FOREGROUND
tail -f /var/log/postgresql/postgresql-9.5-main.log
