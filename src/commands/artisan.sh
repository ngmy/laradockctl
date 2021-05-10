#!/bin/bash
#
# The laradockctl command to execute an Artisan command in the workspace container.

set -Ceuo pipefail

local NAME='artisan'
local DESCRIPTION='Execute an Artisan command in the workspace container'

handle() {
  docker-compose exec -u laradock workspace php artisan "$@"
}
