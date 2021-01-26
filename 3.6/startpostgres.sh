#!/bin/bash

service postgresql start
tail -f /var/log/postgresql/postgresql-12-main.log