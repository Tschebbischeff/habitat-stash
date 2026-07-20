#!/bin/sh

mkdir -p /run/secrets/www-data
chown www-data:www-data /run/secrets/www-data
chmod 755 /run/secrets/www-data

[ -f "NEXTCLOUD_OAUTH_CLIENT_ID_FILE" ] && \
    cat "$NEXTCLOUD_OAUTH_CLIENT_ID_FILE" >/run/secrets/www-data/NEXTCLOUD_OAUTH_CLIENT_ID && \
    chown -R www-data:www-data /run/secrets/www-data/NEXTCLOUD_OAUTH_CLIENT_ID && \
    chmod 400 /run/secrets/www-data/NEXTCLOUD_OAUTH_CLIENT_ID

[ -f "NEXTCLOUD_OAUTH_CLIENT_SECRET_FILE" ] && \
    cat "$NEXTCLOUD_OAUTH_CLIENT_SECRET_FILE" >/run/secrets/www-data/NEXTCLOUD_OAUTH_CLIENT_SECRET && \
    chown -R www-data:www-data /run/secrets/www-data/NEXTCLOUD_OAUTH_CLIENT_SECRET && \
    chmod 400 /run/secrets/www-data/NEXTCLOUD_OAUTH_CLIENT_SECRET

exec "$@"