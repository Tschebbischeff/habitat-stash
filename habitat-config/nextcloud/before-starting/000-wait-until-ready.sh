#!/usr/bin/env bash

echo "Waiting for NextCloud status to be ready..."
checkAgain="1"
while [ "$checkAgain" -ne "0" ]; do
    php occ status --no-interaction | grep -Pq 'installed: true'
    checkAgain="$?"
done
echo "Ready!"
exit 0