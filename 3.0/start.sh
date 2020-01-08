#!/bin/bash
service postgresql start
/usr/sbin/apache2ctl -D FOREGROUND
