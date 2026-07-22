#!/usr/bin/env bash

php occ maintenance:update:htaccess
if ! grep -q "Strict-Transport-Security" /var/www/html/.htaccess; then
    echo -e '\nHeader always set Strict-Transport-Security "max-age=15552000; includeSubDomains; preload"' >>"/var/www/html/.htaccess"
fi