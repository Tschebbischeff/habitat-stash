#!/usr/bin/env bash

SOURCE_PATH="$1"

export NEXTCLOUD_MYSQL_PASSWORD_HASH="$(cat "/run/secrets/NEXTCLOUD_MYSQL_PASSWORD_HASH")"

envsubst <"$SOURCE_PATH/provisioning/nextcloud/.dbinit.sql" >"$SOURCE_PATH/provisioning/nextcloud/.dbinit.sql.tmp" \
&& \
mv "$SOURCE_PATH/provisioning/nextcloud/.dbinit.sql.tmp" "$SOURCE_PATH/provisioning/nextcloud/.dbinit.sql"