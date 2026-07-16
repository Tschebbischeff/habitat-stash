#!/usr/bin/env bash

cat >"$MANDATORY_SYSTEM_CONFIG_SET" <<EOF
oidc_login_provider_url="https://authelia.${APP_HOST}"
allow_user_to_change_display_name=false
EOF

cat >"$MANDATORY_SYSTEM_CONFIG_UNSET" <<EOF
EOF

shopt -s extglob

inArray() {
    local search="$1"; shift
    for item in "$@"; do
        [[ "$item" == "$search" ]] && return 0
    done
    return 1
}

NEXTCLOUD_SYSTEM_CONFIG_SET="$MANDATORY_SYSTEM_CONFIG_SET"$'\n'"$NEXTCLOUD_SYSTEM_CONFIG_SET"
NEXTCLOUD_SYSTEM_CONFIG_UNSET="$MANDATORY_SYSTEM_CONFIG_UNSET"$'\n'"$NEXTCLOUD_SYSTEM_CONFIG_UNSET"

declare -a CONFIG_SET
mapfile -t CONFIG_SET < <(printf "%s" "$NEXTCLOUD_SYSTEM_CONFIG_SET" | sed -E 's/([^\\]),/\1\n/g')
for i in "${!CONFIG_SET[@]}"; do
    CONFIG_SET[i]="${CONFIG_SET[i]##+[[:space:]]}"
    CONFIG_SET[i]="${CONFIG_SET[i]%%+[[:space:]]}"
done

declare -a CONFIG_UNSET
mapfile -t CONFIG_UNSET < <(printf "%s" "$NEXTCLOUD_SYSTEM_CONFIG_UNSET" | sed -E 's/([^\\]),/\1\n/g')
for i in "${!CONFIG_UNSET[@]}"; do
    CONFIG_UNSET[i]="${CONFIG_UNSET[i]##+[[:space:]]}"
    CONFIG_UNSET[i]="${CONFIG_UNSET[i]%%+[[:space:]]}"
done

for cfg in "${CONFIG_SET[@]}"; do
    [ -n "$cfg" ] || continue
    cfgName="$(echo "$cfg" | grep -Po '^[^ =]*')"
    cfgValue="$(echo "$cfg" | grep -Po '^[^ =]*( |=)\K.*$')"
    { [ -n "$cfgName" ] && [ -n "$cfgValue" ]; } || continue
    currentValue="$(php occ config:system:get "$cfgName" --no-interaction --no-warnings --output=plain)"
    [ "$cfgValue" != "$currentValue" ] || continue
    if [ "$cfgValue" == "true" ] || [ "$cfgValue" == "false" ]; then
        php occ config:system:set "$cfgName" --no-interaction "--value=$cfgValue" --type=boolean
    elif [ "${cfgValue:0:1}" == "\"" ]; then
        php occ config:system:set "$cfgName" --no-interaction "--value=$cfgValue" --type=string
    elif [[ "$cfgValue" == *.* ]]; then
        php occ config:system:set "$cfgName" --no-interaction "--value=$cfgValue" --type=double
    else
        php occ config:system:set "$cfgName" --no-interaction "--value=$cfgValue" --type=integer
    fi
done

for cfgName in "${CONFIG_UNSET[@]}"; do
    [ -n "$cfgName" ] || continue
    currentValue="$(php occ config:system:get "$cfgName" --no-interaction --no-warnings --output=plain)"
    [ -n "$currentValue" ] || continue
    php occ config:system:delete "$cfgName" --no-interaction
done