#!/bin/bash
#
# The laradockctl command to view Laravel logs.

set -Ceuo pipefail

local NAME='laravel:logs'
local DESCRIPTION='View Laravel logs'

handle() {
  docker-compose exec workspace tail "$@" storage/logs/laravel.log
}
