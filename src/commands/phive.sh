#!/bin/bash
#
# The laradockctl command to execute a PHIVE command in the workspace container.

set -Ceuo pipefail

local NAME='phive'
local DESCRIPTION='Execute a PHIVE command in the workspace container'

handle() {
  local phive_args=''
  if [ -n "${LARADOCKCTL_PHIVE_HOME_DIR_CONTAINER:-}" ]; then
    phive_args="--home ${LARADOCKCTL_PHIVE_HOME_DIR_CONTAINER}"
  fi
  docker-compose exec -T -u laradock workspace phive ${phive_args} "$@"
}
