#!/bin/bash
set -Ceuo pipefail

local NAME='my:destroy'
local DESCRIPTION='Destory my development environment'

handle() {
  docker-compose down -v

  # Remove data in data directories
  while read -r directory; do
    local yn
    read -u 1 -p "Do you want to remove data in ${directory}? (y/N)" yn
    if [[ "${yn}" == 'y' ]]; then
      sudo rm -rf "${directory}"/*
    fi
  done < <(echo -n "${LARADOCKCTL_DATA_DIRECTORY:-}" | xargs -d ',' -I {} echo {})
}
