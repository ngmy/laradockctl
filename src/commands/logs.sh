#!/bin/bash
#
# The laradockctl command to view application logs.

set -Ceuo pipefail

local NAME='logs'
local DESCRIPTION='View application logs'

handle() {
  # Laravel application logs
  if file_exists_in_workspace storage/logs/laravel.log; then
    docker-compose exec -u laradock workspace tail "$@" storage/logs/laravel.log
  fi
}
