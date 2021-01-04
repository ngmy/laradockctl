#!/bin/bash
#
# The laradockctl command to execute an Artisan command.

set -Ceuo pipefail

local NAME='laravel:artisan'
local DESCRIPTION='Execute an Artisan command'

handle() {
  docker-compose exec -u laradock workspace php artisan "$@"
}
