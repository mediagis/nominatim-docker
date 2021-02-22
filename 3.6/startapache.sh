#!/bin/bash
cp /data/local.php /app/src/build/settings/local.php
/app/src/build/utils/setup.php --setup-website

/usr/sbin/apache2ctl -D FOREGROUND
tail -f /var/log/apache2/error.log

