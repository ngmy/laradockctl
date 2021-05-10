#!/bin/bash
#
# The laradockctl command to shut down a development environment.

set -Ceuo pipefail

local NAME='down'
local DESCRIPTION='Shut down a development environment'

handle() {
  docker-compose stop
}
