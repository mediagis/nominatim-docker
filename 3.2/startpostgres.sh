#!/bin/bash

service postgresql start
tail -f /var/log/postgresql/postgresql-10-main.log