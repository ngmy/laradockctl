#!/bin/bash
#
# The laradockctl command to list commands.

set -Ceuo pipefail

local NAME='list'
local DESCRIPTION='List commands'

handle() {
  list
}
