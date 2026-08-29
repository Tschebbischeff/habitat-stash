#!/usr/bin/env bash

MANDATORY_CUSTOM_APPS="oidc_login,notify_push"

inArray() {
    local search="$1"; shift
    for item in "$@"; do
        [[ "$item" == "$search" ]] && return 0
    done
    return 1
}

NEXTCLOUD_CUSTOM_APPS="$MANDATORY_CUSTOM_APPS,$NEXTCLOUD_CUSTOM_APPS"
declare -a APP_CONFIG
mapfile -t APP_CONFIG < <(printf "%s" "$NEXTCLOUD_CUSTOM_APPS" | sed -E 's/([^\\]|^),/\1\n/g')
for i in "${!APP_CONFIG[@]}"; do
    APP_CONFIG[i]="$(echo "${APP_CONFIG[i]}" | grep -Po '^[ \t]*\K.*[^ \t]')"
done

APP_ARGS_WHITELIST=( \
    "groups" \
    "force"
)
declare -a APP_LIST
declare -a APP_ARGS
for appConfig in "${APP_CONFIG[@]}"; do
    [ -n "$appConfig" ] || continue
    APP_LIST[${#APP_LIST[@]}]="$(echo "$appConfig" | grep -Po '^[^\[]*')"
    appArgsStr=""
    appArgs="$(echo "$appConfig" | grep -Po '^[^\[]*\K.*$')"
    while [ -n "$appArgs" ]; do
        arg="$(echo "$appArgs" | grep -Po '^\[?\K[^\]]*')"
        argName="$(echo "$arg" | grep -Po '^[^=]*')"
        argValue="$(echo "$arg" | grep -Po '^[^=]*=\K.*$')"
        if inArray "$argName" "${APP_ARGS_WHITELIST[@]}"; then
            if [ -z "$argValue" ]; then
                appArgsStr="${appArgsStr:+${appArgsStr}$'\n'}$(printf -- '--%s' "$argName")"
            else
                appArgsStr="${appArgsStr:+${appArgsStr}$'\n'}$(printf -- '--%s\n%s' "$argName" "$argValue")"
            fi
        fi
        appArgs="$(echo "$appArgs" | grep -Po '^\[?[^\]]*\]\K.*')"
    done
    APP_ARGS[${#APP_ARGS[@]}]="$appArgsStr"
done

declare -a INSTALLED_APPS
mapfile -t INSTALLED_APPS < <(php occ app:list --no-interaction --no-warnings --shipped=false --enabled --output=plain | grep -Po ' *- *\K[^:]*')

for appId in "${!APP_LIST[@]}"; do
    app="${APP_LIST[$appId]}"
    declare -a appArgs
    mapfile -t appArgs < <(printf "%s" "${APP_ARGS[$appId]}" | grep -Po '^[ \t]*\K[^ \t]*')
    if ! inArray "$app" "${INSTALLED_APPS[@]}"; then
        echo "Installing custom app '$app'..."
        php occ app:install --no-interaction "$app"
    else
        echo "Updating custom app '$app'..."
        php occ app:update --no-interaction "$app"
    fi
    if [ "${#appArgs[@]}" -gt "0" ]; then
        echo "Setting app arguments for '$app': ${appArgs[*]}"
        php occ app:enable --no-interaction "${appArgs[@]}" "$app"
    fi
    unset appArgs
done

for app in "${INSTALLED_APPS[@]}"; do
    [ -n "$app" ] || continue
    if ! inArray "$app" "${APP_LIST[@]}"; then
        echo "Uninstalling custom app '$app'..."
        php occ app:remove --no-interaction "$app"
    fi
done