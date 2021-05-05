#!/bin/bash
set -Ceuo pipefail

local NAME='my:phive'
local DESCRIPTION='Execute a PHIVE command'

handle() {
  local phive_args=''
  if [ -n "${LARADOCKCTL_PHIVE_HOME:-}" ]; then
    phive_args="--home ${LARADOCKCTL_PHIVE_HOME}"
  fi
  docker-compose exec -T -u laradock workspace phive ${phive_args} "$@"
}
