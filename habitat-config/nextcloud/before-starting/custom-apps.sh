#!/usr/bin/env bash

MANDATORY_CUSTOM_APPS="oidc_login"

shopt -s extglob

inArray() {
    local search="$1"; shift
    for item in "$@"; do
        [[ "$item" == "$search" ]] && return 0
    done
    return 1
}

NEXTCLOUD_CUSTOM_APPS="$MANDATORY_CUSTOM_APPS,$NEXTCLOUD_CUSTOM_APPS"
declare -a REQ_APPS
mapfile -t REQ_APPS < <(printf "%s" "$NEXTCLOUD_CUSTOM_APPS" | sed -E 's/([^\\]),/\1\n/g')
for i in "${!REQ_APPS[@]}"; do
    REQ_APPS[i]="$(echo "${REQ_APPS[i]}" | grep -Po '^[ \t]*\K.*[^ \t]')"
done

declare -a INSTALLED_APPS
mapfile -t INSTALLED_APPS < <(php occ app:list --no-interaction --no-warnings --shipped=false --enabled --output=plain | grep -Po ' *- *\K[^:]*')

for app in "${REQ_APPS[@]}"; do
    [ -n "$app" ] || continue
    if ! inArray "$app" "${INSTALLED_APPS[@]}"; then
        echo "Installing custom app '$app'..."
        php occ app:install --no-interaction "$app"
    else
        echo "Updating custom app '$app'..."
        php occ app:update --no-interaction "$app"
    fi
done

for app in "${INSTALLED_APPS[@]}"; do
    [ -n "$app" ] || continue
    if ! inArray "$app" "${REQ_APPS[@]}"; then
        echo "Uninstalling custom app '$app'..."
        php occ app:remove --no-interaction "$app"
    fi
done