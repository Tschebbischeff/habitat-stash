[![License: AGPL-3.0](https://img.shields.io/badge/License-AGPL--3.0-blue?style=flat)](./LICENSE)
![Development: Prototyping](https://img.shields.io/badge/Development-Prototyping-orange?style=flat)
![Version](https://img.shields.io/badge/dynamic/json?label=Version&color=yellow&style=flat&url=https%3A%2F%2Fraw.githubusercontent.com%2Ftschebbischeff%2Fhabitat-stash%2Frefs%2Fheads%2Fmain%2Fmetadata.json&query=%24.version)

# Habitat: Stash

> [!CAUTION]
> **🚧 This project is currently under heavy development, any information may be subject to change. 🚧**

Habitat provides modular functionality for deployment on home lab devices. \
Each of the modules is designed as an opinionated docker stack that can be deployed on its own or together with other modules by sharing the same docker network.

## Available Modules

 - **[Path](https://github.com/Tschebbischeff/habitat-path)** \
 Network routing and reverse proxy
 - **[Scent](https://github.com/Tschebbischeff/habitat-scent)** \
 Identity provider, LDAP directory and access control
 - **[Vista](https://github.com/Tschebbischeff/habitat-vista)** \
 Central dashboards and device entry points
 - **[Chatter](https://github.com/Tschebbischeff/habitat-chatter)** \
 Message queue for realtime communication between modules
 - **[Hoard](https://github.com/Tschebbischeff/habitat-hoard)** \
 Time-series database and persistent storage
 - **[Vigil](https://github.com/Tschebbischeff/habitat-vigil)** \
 Device monitoring, visualization and alerting
 - **[Sight](https://github.com/Tschebbischeff/habitat-sight)** \
 Real-time video streaming
 - **[Stash](https://github.com/Tschebbischeff/habitat-stash)** \
 Nextcloud

## Our Principles

![TODO](https://img.shields.io/badge/TODO-Coming_Soon_(TM)-red?style=flat)

## Module Features

[![Media MTX](https://img.shields.io/badge/Media_MTX-_?style=flat&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9IiMxQTY1QjciIHN0cm9rZS13aWR0aD0iMiIgc3Ryb2tlLWxpbmVjYXA9InJvdW5kIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBjbGFzcz0ibHVjaWRlIGx1Y2lkZS1jYW1lcmEtaWNvbiBsdWNpZGUtY2FtZXJhIj48cGF0aCBkPSJNMTMuOTk3IDRhMiAyIDAgMCAxIDEuNzYgMS4wNWwuNDg2LjlBMiAyIDAgMCAwIDE4LjAwMyA3SDIwYTIgMiAwIDAgMSAyIDJ2OWEyIDIgMCAwIDEtMiAySDRhMiAyIDAgMCAxLTItMlY5YTIgMiAwIDAgMSAyLTJoMS45OTdhMiAyIDAgMCAwIDEuNzU5LTEuMDQ4bC40ODktLjkwNEEyIDIgMCAwIDEgMTAuMDA0IDR6Ii8+PGNpcmNsZSBjeD0iMTIiIGN5PSIxMyIgcj0iMyIvPjwvc3ZnPg==&logoColor=1A65B7&logoSize=auto&color=gray&labelColor=gray)](https://mediamtx.org/)

 - **Cross-Module Video Streaming** \
 Publish and Subscribe to video feeds via multiple connection protocols

### Planned
 - **Extended Configuration** \
 Definition of custom video sources

## Getting Started

### Requirements

 - [![Habitat-Module: Path](https://img.shields.io/badge/Habitat--Module-Path-_?style=flat&color=gray&labelColor=gray)](https://github.com/Tschebbischeff/habitat-path)

### Configuration

> [!IMPORTANT]
> All habitat modules are designed to be controlled exclusively with environment variables and secrets. \
> Refer to the configuration section of each module for an overview of how to configure it. \
> **This section describes how to configure the module without the help of the [Habitat Deployment Service](https://github.com/Tschebbischeff/habitat). \
> It is highly recommended to use the deployment service for ease of use and skip to the lists of environment variables and secrets for this module.**

 - [List of environment variables](#environment-variables)
 - [List of secrets](#secrets)

#### Shell Exports

The existing [.env](./.env) file contains sane defaults for most necessary environment variables and is designed to let you overwrite any of those environment variables via exports from your shell before running the application.

*Example:*
```sh
export APP_HOST="my-habitat.example.com"
export APP_MODULES="path,scent,vista,chatter,hoard,vigil,sight,stash"
export APP_SESSION_ID="$(cat /proc/sys/kernel/random/uuid)"
export APP_NAME_LABEL="MyHabitat"
export TIMEZONE="Europe/London"
export SECRETS_DIR="/run/secrets"
docker compose up
```

#### Repository _.env File

You can also create the file `_.env` in the root directory of the cloned repository and instruct docker compose to use this file instead via the `--env-file` argument, i.e `docker compose --env-file "./_.env" up` ([Compose documentation](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/)).

> [!TIP]
> The file `_.env` is included in [.gitignore](./.gitignore) and is guaranteed to not interfere with future updates via `git pull`.

> [!IMPORTANT]
> *If this method is used you need to define **all** necessary environment variables from the [.env](./.env) file, as docker compose will not use that file as a fallback, it is therefore recommended to copy the current `.env` file and replace all variable values.*

*Example:* [See .env](./.env)

#### Local .env File

It is also possible to create a `.env` file in an unrelated directory ([Compose documentation](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/#local-env-file-versus-project-directory-env-file)).

> [!NOTE]
> In this case you need to set the additional variable `COMPOSE_FILE` to the path of the repository's compose file and all variables inside the [.env](./.env) file will be loaded as fallback, if your own `.env` file does not define them.

> [!NOTE]
> You do not need to instruct docker compose to use this file as long as you run `docker compose up` from the directory containing your `.env` file.

*Example:*
```sh
# /path/to/your/.env
COMPOSE_FILE="/path/to/repository/compose.yml"
APP_HOST="my-habitat.example.com"
APP_MODULES="path,scent,vista,chatter,hoard,vigil,sight,stash"
APP_SESSION_ID="$(cat /proc/sys/kernel/random/uuid)"
APP_NAME_LABEL="MyHabitat"
TIMEZONE="Europe/Madrid"
SECRETS_DIR="/run/secrets"
```

### Environment Variables

At build-time Docker requires the following environment variables to be populated:

| Name | Description | Example | Default |
| :-- | :-- | :-- | :-- |
| `APP_HOST` | The main URL the device will be reachable at. | `my-habitat.example.com` | *Empty* |
| `APP_MODULES` | A comma separated list of module names that are started in the same docker namespace (same project name) as this module. | `path,scent,vista,chatter,hoard,vigil,sight,stash` | *Empty* |
| `APP_SESSION_ID` | A session ID used for synchronization of configuration between modules, should change every time all modules are restarted in unison and remain unchanged if a single module is restarted without being updated. | `$(cat /proc/sys/kernel/random/uuid)` | *Empty* |
| `APP_NETWORK_POOL` | The pool of IP addresses for the module containers, must match pool of all other modules in the same application. | `172.19.0.0/16` | `172.18.0.0/16` |
| `APP_NAME_HOST` | The prefix for all docker networks and containers, that this application will create. Also used as the internal hostname within all containers. | `my-habitat` | `habitat` |
| `APP_NAME_LABEL` | The human readable name of the device. | `My Habitat` | `Habitat` |
| `TIMEZONE` | Timezone identifier passed on to containers. | `Europe/Paris` | `Europe/Berlin` |
| `VOLUME_DIR` | The directory in which [bind mounts](https://docs.docker.com/engine/storage/bind-mounts/) are placed *(Currently only named volumes are used)*. | `/path/to/my/volumes` | `./volumes` |
| `ENV_DIR` | The directory in which .env files for containers can be placed to override the default runtime config. | `/path/to/my/env` | `./env.d` |
| `SECRETS_DIR` | The directory in which files containing secrets for containers are placed. | `/run/secret` | `./secrets` |

### Secrets

*This module does not require any secrets.*

<!--
> [!NOTE]
> All secrets are expected to be files within a single folder, each file containing the value of the secret. \
> This folder can be set via environment variable (`SECRETS_DIR`) itself and defaults to `./.secrets` (git-ignored folder). \
> All secrets must be present at run-time.

| (File) Name | Description | Documentation / How to Obtain |
| :-- | :-- | :-- |
|  | This module does not require any secrets |  |
-->

### Run the Application

 - Run `docker compose up` from the root directory of the repository or from the directory containing your `.env` file
 - Run `docker compose logs` and wait for the application to finish first-time setup and settle

## Acknowledgments and Licensing

This project is licensed under the [GNU Affero General Public License v3.0 (AGPL-3.0)](./LICENSE).

Copyright (c) 2026, [Tschebbischeff](https://github.com/Tschebbischeff). \
All rights reserved to the extent permitted by the AGPLv3.

For third-party license details and attribution, please see [Third-Party Licenses](./THIRD-PARTY-LICENSES.md).
