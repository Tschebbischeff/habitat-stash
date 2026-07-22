#!/usr/bin/env bash

read -r -d '' "DEFAULT_SYSTEM_CONFIG_SET" <<EOF || true
backgroundjobs_mode="cron"
skeletondirectory=""
allow_user_to_change_display_name=false
lost_password_link="disabled"
oidc_login_provider_url="https://authelia.${APP_HOST}"
oidc_login_client_id="$(cat "/run/secrets/.www-data/NEXTCLOUD_OAUTH_CLIENT_ID")"
oidc_login_client_secret="$(cat "/run/secrets/.www-data/NEXTCLOUD_OAUTH_CLIENT_SECRET")"
oidc_login_auto_redirect=true
oidc_login_logout_url="https://authelia.${APP_HOST}/logout?rd=https%3A%2F%2Fnextcloud.${APP_HOST}"
oidc_login_end_session_redirect=false
# oidc_login_default_quota="1000000000"
oidc_login_button_text="Log in with Authelia"
oidc_login_hide_password_form=true
oidc_login_use_id_token=false
oidc_login_attributes[id]="preferred_username"
oidc_login_attributes[name]="name"
oidc_login_attributes[mail]="email"
oidc_login_attributes[groups]="groups"
oidc_login_attributes[is_admin]="is_nextcloud_admin"
oidc_login_default_group="oidc"
oidc_login_use_external_storage=false
oidc_login_scope="openid profile email groups nextcloud_userinfo"
oidc_login_proxy_ldap=false
oidc_login_disable_registration=false
oidc_login_redir_fallback=false
oidc_login_tls_verify=true
oidc_create_groups=false
oidc_login_webdav_enabled=false
oidc_login_password_authentication=false
oidc_login_public_key_caching_time=86400
oidc_login_min_time_between_jwks_requests=10
oidc_login_well_known_caching_time=86400
oidc_login_update_avatar=false
oidc_login_skip_proxy=false
oidc_login_code_challenge_method="S256"
EOF

read -r -d '' "DEFAULT_SYSTEM_CONFIG_UNSET" <<EOF || true
EOF

NEXTCLOUD_SYSTEM_CONFIG_SET="$DEFAULT_SYSTEM_CONFIG_SET"$'\n'"$NEXTCLOUD_SYSTEM_CONFIG_SET"
NEXTCLOUD_SYSTEM_CONFIG_UNSET="$DEFAULT_SYSTEM_CONFIG_UNSET"$'\n'"$NEXTCLOUD_SYSTEM_CONFIG_UNSET"

declare -a CONFIG_SET
mapfile -t CONFIG_SET < <(printf "%s" "$NEXTCLOUD_SYSTEM_CONFIG_SET" | sed -E 's/([^\\]),/\1\n/g')
for i in "${!CONFIG_SET[@]}"; do
    CONFIG_SET[i]="$(echo "${CONFIG_SET[i]}" | grep -Po '^[ \t]*\K.*[^ \t]')"
done

declare -a CONFIG_UNSET
mapfile -t CONFIG_UNSET < <(printf "%s" "$NEXTCLOUD_SYSTEM_CONFIG_UNSET" | sed -E 's/([^\\]),/\1\n/g')
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
    currentValue="$(php occ config:system:get --no-interaction --no-warnings --output=plain -- "${cfgNames[@]}")"
    currentValueObtained="$?"
    if [ "${cfgValue:0:1}" == "\"" ] && [ "${cfgValue: -1}" == "\"" ]; then
        [ "$currentValueObtained" -eq "0" ] && [ "${cfgValue:1:-1}" == "$currentValue" ] && continue
        php occ config:system:set --no-interaction --value="${cfgValue:1:-1}" --type=string -- "${cfgNames[@]}"
    else
        [ "$cfgValue" != "$currentValue" ] || continue
        if [ "$cfgValue" == "true" ] || [ "$cfgValue" == "false" ]; then
            php occ config:system:set --no-interaction --value="$cfgValue" --type=boolean -- "${cfgNames[@]}"
        elif [[ "$cfgValue" == *.* ]]; then
            php occ config:system:set --no-interaction --value="$cfgValue" --type=double -- "${cfgNames[@]}"
        else
            php occ config:system:set --no-interaction --value="$cfgValue" --type=integer -- "${cfgNames[@]}"
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
    currentValue="$(php occ config:system:get --no-interaction --no-warnings --output=plain -- "${cfgNames[@]}")"
    [ -n "$currentValue" ] || continue
    php occ config:system:delete --no-interaction -- "${cfgNames[@]}"
done