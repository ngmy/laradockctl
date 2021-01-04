#!/bin/bash
#
# The laradockctl command to execute a Composer command.

set -Ceuo pipefail

local NAME='workspace:composer'
local DESCRIPTION='Execute a Composer command'

handle() {
  docker-compose exec -u laradock workspace composer "$@"
}
