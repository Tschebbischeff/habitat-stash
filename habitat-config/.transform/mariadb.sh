#!/usr/bin/env bash

SOURCE_PATH="$1"

export NEXTCLOUD_MYSQL_PASSWORD_HASH="$(cat "/run/secrets/NEXTCLOUD_MYSQL_PASSWORD_HASH")"

find "$SOURCE_PATH" -type f -name '*.sql' | while read -r filePath; do
    if envsubst <"$filePath" >"$filePath.envsubst"; then
        mv "$filePath.envsubst" "$filePath"
    else
        rm "$filePath.envsubst" &>/dev/null
    fi
done