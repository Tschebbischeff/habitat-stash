#!/usr/bin/env bash

inArray() {
    local search="$1"; shift
    for item in "$@"; do
        [[ "$item" == "$search" ]] && return 0
    done
    return 1
}

declare -a APP_LIST
mapfile -t APP_LIST < <(printf "%s" "$NEXTCLOUD_DISABLE_APPS" | sed -E 's/([^\\]),/\1\n/g')
for i in "${!APP_LIST[@]}"; do
    APP_LIST[i]="$(echo "${APP_LIST[i]}" | grep -Po '^[ \t]*\K.*[^ \t]')"
done

declare -a DISABLED_APPS
mapfile -t DISABLED_APPS < <(php occ app:list --no-interaction --no-warnings --disabled --output=plain | grep -Po ' *- *\K[^:]*')

for app in "${APP_LIST[@]}"; do
    [ -n "$app" ] || continue
    if ! inArray "$app" "${DISABLED_APPS[@]}"; then
        echo "Disabling app '$app'..."
        php occ app:disable --no-interaction "$app"
    fi
done