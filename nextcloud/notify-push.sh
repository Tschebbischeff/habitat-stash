#!/bin/sh

cd "/var/www/html" || exit 2

BINARY=$(find /var/www/html/custom_apps/notify_push/bin/ -type f -name "notify_push" 2>/dev/null | head -n 1)
[ -z "$BINARY" ] && echo "Binary for 'notify_push' not found. Waiting for app installation..."
while [ -z "$BINARY" ]; do
    sleep 5
    BINARY=$(find /var/www/html/custom_apps/notify_push/bin/ -type f -name "notify_push" 2>/dev/null | head -n 1)
done

if [ -x "$BINARY" ]; then
    echo "Starting 'notify_push'..."
    (
        PUSH_ENDPOINT="https://${OVERWRITEHOST}/push"
        while ! php -r '@fsockopen("127.0.0.1", 7867) or exit(1);' 2>/dev/null; do sleep 2; done
        currentValue="$(php occ config:app:get --no-interaction --no-warnings --output=plain -- "notify_push" "base_endpoint")"
        if [ "$currentValue" != "$PUSH_ENDPOINT" ]; then
            echo "Setting up 'notify_push' with '$PUSH_ENDPOINT'..."
            if php occ notify_push:setup --no-interaction "$PUSH_ENDPOINT"; then
                echo "Setup of 'notify_push' successful."
            else
                echo "Setup of 'notify_push' failed, see logs above."
            fi
        else
            echo "'notify_push' is already set up and appurl matches, nothing to do."
        fi
    ) &
    exec "$BINARY" "$@"
else
    echo "'$BINARY' is not executable!"
    sleep 10
    exit 1
fi