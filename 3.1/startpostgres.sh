#!/bin/bash

service postgresql start
tail -f /var/log/postgresql/postgresql-9.5-main.log