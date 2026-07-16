#!/usr/bin/env bash

php occ status --no-interaction | grep -Pq 'installed: true'
exit "$?"