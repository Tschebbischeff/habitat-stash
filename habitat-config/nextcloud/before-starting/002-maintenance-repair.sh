#!/usr/bin/env bash

php occ maintenance:repair --include-expensive
exit "$?"