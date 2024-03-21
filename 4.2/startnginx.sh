#!/bin/bash
cp /data/local.php /app/src/build/settings/local.php

nginx -g "daemon off;"
tail -f /var/log/nginx/error.log