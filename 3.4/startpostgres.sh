#!/bin/bash

service postgresql start
tail -f /var/log/postgresql/postgresql-11-main.log