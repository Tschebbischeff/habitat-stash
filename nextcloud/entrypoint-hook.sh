#!/bin/sh

if [ -n "$NEXTCLOUD_MAP_SECRETS" ]; then
    printf '%s\n' "$NEXTCLOUD_MAP_SECRETS" | tr ',' '\n' | while IFS= read -r sourcePath || [ -n "$sourcePath" ]; do
        sourcePath=$(echo "$sourcePath" | awk '{gsub(/^[ \t]+|[ \t]+$/, ""); print}')
        { [ -n "$sourcePath" ] && [ -f "$sourcePath" ]; } || continue
        targetDir="$(dirname "$sourcePath")/.www-data"
        if [ ! -d "$targetDir" ]; then
            mkdir -p "$targetDir" && \
            chown www-data:www-data "$targetDir" && \
            chmod 755 "$targetDir"
        fi
        targetPath="$targetDir/$(basename "$sourcePath")"
        cp "$sourcePath" "$targetPath" && \
        chown www-data:www-data "$targetPath" && \
        chmod 400 "$targetPath"
    done
fi

exec "$@"