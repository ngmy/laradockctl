#!/bin/bash
#
# The laradockctl command to execute a Composer command in the workspace container.

set -Ceuo pipefail

local NAME='composer'
local DESCRIPTION='Execute a Composer command in the workspace container'

handle() {
  docker-compose exec -u laradock workspace composer "$@"
}
