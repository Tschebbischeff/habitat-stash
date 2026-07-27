#!/usr/bin/env bash

PATCH_FILE="./custom_apps/oidc_login/appinfo/info.xml"

if [ -f "$PATCH_FILE" ]; then
    if cat "$PATCH_FILE" | grep -Pq 'nextcloud min-version="[0-9]*" max-version="33"'; then
        echo "Patching Nextcloud max version in '$PATCH_FILE'..."
        if sed -i -E 's/(<nextcloud +min-version="[0-9]*" +)max-version="33"( +\/?>)/\1max-version="34"\2/g' "$PATCH_FILE"; then
            echo "Successfully updated max version to 34."
        else
            echo "Error while patching!"
            exit 1
        fi
    else
        echo "OIDC Login app already patched."
    fi
else
    echo "Could not find file to patch: '$PATCH_FILE', ignoring this script!"
fi
exit 0