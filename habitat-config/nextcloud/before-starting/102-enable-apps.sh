#!/usr/bin/env bash

inArray() {
    local search="$1"; shift
    for item in "$@"; do
        [[ "$item" == "$search" ]] && return 0
    done
    return 1
}

declare -a APP_CONFIG
mapfile -t APP_CONFIG < <(printf "%s" "$NEXTCLOUD_ENABLE_APPS" | sed -E 's/([^\\]|^),/\1\n/g')
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
        argName="$(echo "$arg" | grep -Po '^[^= "]*')"
        argValue="$(echo "$arg" | grep -Po '^[^=]*=\K[^"]*$')"
        if inArray "$argName" "${APP_ARGS_WHITELIST[@]}"; then
            if [ -z "$argValue" ]; then
                appArgsStr="$appArgsStr --$argName"
            else
                appArgsStr="$appArgsStr --$argName \"$argValue\""
            fi
        fi
        appArgs="$(echo "$appArgs" | grep -Po '^\[?[^\]]*\]\K.*')"
    done
    APP_ARGS[${#APP_ARGS[@]}]="$appArgsStr"
done

declare -a ENABLED_APPS
mapfile -t ENABLED_APPS < <(php occ app:list --no-interaction --no-warnings --enabled --output=plain | grep -Po ' *- *\K[^:]*')

for appId in "${!APP_LIST[@]}"; do
    app="${APP_LIST[$appId]}"
    appArgs="${APP_ARGS[$appId]}"
    doEnable=""
    if ! inArray "$app" "${ENABLED_APPS[@]}"; then
        echo "Enabling app '$app'..."
        doEnable="_"
    fi
    if [ -n "$appArgs" ]; then
        echo "Setting app arguments for '$app': $appArgs"
        doEnable="_"
    fi
    # shellcheck disable=SC2086  # Word-splitting is intentional
    [ -n "$doEnable" ] && php occ app:enable --no-interaction $appArgs "$app"
done

echo "test fixed command for calendar"
app="calendar"
appArgs=" --groups \"admin\" --groups \"app_calendar\""
php occ app:enable --no-interaction $appArgs "$app"
php occ app:enable --no-interaction --groups "admin" --groups "app_calendar" "calendar"