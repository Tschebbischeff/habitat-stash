#!/usr/bin/env bash

read -r -d '' "MANDATORY_APP_CONFIG_SET" <<EOF || true
# appName[cfgName]=cfgValue
EOF

read -r -d '' "MANDATORY_APP_CONFIG_UNSET" <<EOF || true
EOF

NEXTCLOUD_APP_CONFIG_SET="$MANDATORY_APP_CONFIG_SET"$'\n'"$NEXTCLOUD_APP_CONFIG_SET"
NEXTCLOUD_APP_CONFIG_UNSET="$MANDATORY_APP_CONFIG_UNSET"$'\n'"$NEXTCLOUD_APP_CONFIG_UNSET"

declare -a CONFIG_SET
mapfile -t CONFIG_SET < <(printf "%s" "$NEXTCLOUD_APP_CONFIG_SET" | sed -E 's/([^\\]),/\1\n/g')
for i in "${!CONFIG_SET[@]}"; do
    CONFIG_SET[i]="$(echo "${CONFIG_SET[i]}" | grep -Po '^[ \t]*\K.*[^ \t]')"
done

declare -a CONFIG_UNSET
mapfile -t CONFIG_UNSET < <(printf "%s" "$NEXTCLOUD_APP_CONFIG_UNSET" | sed -E 's/([^\\]),/\1\n/g')
for i in "${!CONFIG_UNSET[@]}"; do
    CONFIG_UNSET[i]="$(echo "${CONFIG_UNSET[i]}" | grep -Po '^[ \t]*\K.*[^ \t]')"
done

for cfg in "${CONFIG_SET[@]}"; do
    [ -n "$cfg" ] || continue
    cfgName="$(echo "$cfg" | grep -Po '^[^ =]*')"
    cfgValue="$(echo "$cfg" | grep -Po '^[^ =]*( |=)\K.*$')"
    { [ -n "$cfgName" ] && [ "${cfgName:0:1}" != "#" ] && [ -n "$cfgValue" ]; } || continue
    cfgKeys="$(echo "$cfgName" | grep -Po '^[^[]*\[\K.*')"
    cfgNames=("$(echo "$cfgName" | grep -Po '^[^[]*')")
    while [ -n "$cfgKeys" ]; do
        cfgNames[${#cfgNames[@]}]="$(echo "$cfgKeys" | grep -Po '^\[?\K[^\]]*')"
        cfgKeys="$(echo "$cfgKeys" | grep -Po '^\[?[^\]]*\]\K.*')"
    done
    currentValue="$(php occ config:app:get --no-interaction --no-warnings --output=plain -- "${cfgNames[@]}")"
    currentValueObtained="$?"
    if [ "${cfgValue:0:1}" == "\"" ] && [ "${cfgValue: -1}" == "\"" ]; then
        [ "$currentValueObtained" -eq "0" ] && [ "${cfgValue:1:-1}" == "$currentValue" ] && continue
        php occ config:app:set --no-interaction --value="${cfgValue:1:-1}" --type=string -- "${cfgNames[@]}"
    else
        [ "$cfgValue" != "$currentValue" ] || continue
        if [ "$cfgValue" == "true" ] || [ "$cfgValue" == "false" ]; then
            php occ config:app:set --no-interaction --value="$cfgValue" --type=boolean -- "${cfgNames[@]}"
        elif [[ "$cfgValue" == *.* ]]; then
            php occ config:app:set --no-interaction --value="$cfgValue" --type=double -- "${cfgNames[@]}"
        else
            php occ config:app:set --no-interaction --value="$cfgValue" --type=integer -- "${cfgNames[@]}"
        fi
    fi
done

for cfgName in "${CONFIG_UNSET[@]}"; do
    [ -n "$cfgName" ] || continue
    cfgKeys="$(echo "$cfgName" | grep -Po '^[^[]*\[\K.*')"
    cfgNames=("$(echo "$cfgName" | grep -Po '^[^[]*')")
    while [ -n "$cfgKeys" ]; do
        cfgNames[${#cfgNames[@]}]="$(echo "$cfgKeys" | grep -Po '^\[?\K[^\]]*')"
        cfgKeys="$(echo "$cfgKeys" | grep -Po '^\[?[^\]]*\]\K.*')"
    done
    currentValue="$(php occ config:app:get --no-interaction --no-warnings --output=plain -- "${cfgNames[@]}")"
    [ -n "$currentValue" ] || continue
    php occ config:app:delete --no-interaction -- "${cfgNames[@]}"
done