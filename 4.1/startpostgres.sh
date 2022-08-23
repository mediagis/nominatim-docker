#!/bin/bash

service postgresql start
tail -f /var/log/postgresql/postgresql-14-main.log
