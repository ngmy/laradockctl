#!/bin/bash
#
# The laradockctl command to execute an NPM command in the workspace container.

set -Ceuo pipefail

local NAME='npm'
local DESCRIPTION='Execute an NPM command in the workspace container'

handle() {
  docker-compose exec -u laradock workspace npm "$@"
}
