#!/usr/bin/env bash

MANDATORY_CUSTOM_GROUPS=""

inArray() {
    local search="$1"; shift
    for item in "$@"; do
        [[ "$item" == "$search" ]] && return 0
    done
    return 1
}

NEXTCLOUD_CUSTOM_GROUPS="$MANDATORY_CUSTOM_GROUPS,$NEXTCLOUD_CUSTOM_GROUPS"
declare -a GROUP_LIST
mapfile -t GROUP_LIST < <(printf "%s" "$NEXTCLOUD_CUSTOM_GROUPS" | sed -E 's/([^\\]|^),/\1\n/g')
for i in "${!GROUP_LIST[@]}"; do
    GROUP_LIST[i]="$(echo "${GROUP_LIST[i]}" | grep -Po '^[ \t]*\K.*[^ \t]')"
done

declare -a EXISTING_GROUPS
mapfile -t EXISTING_GROUPS < <(php occ group:list --no-interaction --no-warnings --output=plain | grep -Po ' *- *\K[^:]*:' | grep -Po '[^:]*')

for group in "${GROUP_LIST[@]}"; do
    [ -n "$group" ] || continue
    if ! inArray "$group" "${EXISTING_GROUPS[@]}"; then
        echo "Creating custom group '$group'..."
        php occ group:add --no-interaction "$group"
    else
        echo "Group '$group' already exists..."
    fi
done

# for group in "${EXISTING_GROUPS[@]}"; do
#     [ -n "$group" ] || continue
#     if ! inArray "$group" "${GROUP_LIST[@]}"; then
#         echo "Removing custom group '$group'..."
#         php occ group:delete --no-interaction "$group"
#     fi
# done