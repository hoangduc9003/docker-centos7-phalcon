#!/bin/bash
echo "Start php-fpm"
php-fpm -D

echo "Reload nginx"
nginx -g "daemon off;"

tail -f /dev/null