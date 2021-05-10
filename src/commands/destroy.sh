#!/bin/bash
#
# The laradockctl command to destory a development environment.

set -Ceuo pipefail

local NAME='destroy'
local DESCRIPTION='Destory a development environment'

handle() {
  docker-compose down -v

  local data_directory_path_host
  data_directory_path_host="$(grep DATA_PATH_HOST .env)"
  data_directory_path_host="${data_directory_path_host#*=}"
  data_directory_path_host="$(realpath "${data_directory_path_host}")"

  # Remove data in the data directory
  local yn
  read -p "Do you want to remove data in ${data_directory_path_host}? (y/N)" yn
  if [[ "${yn}" == 'y' ]]; then
    sudo rm -rf "${data_directory_path_host}"/*
  fi
}
