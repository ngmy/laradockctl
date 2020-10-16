#!/bin/bash
#
# The laradockctl command to execute an NPM command.

set -Ceuo pipefail

local NAME='workspace:npm'
local DESCRIPTION='Execute an NPM command'

handle() {
  docker-compose exec workspace npm "$@"
}
