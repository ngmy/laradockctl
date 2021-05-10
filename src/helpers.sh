#!/bin/bash
#
# laradockctl helper functions.

set -Ceuo pipefail

#######################################
# Outputs the fully qualified path of the laradock directory.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   STDOUT The fully qualified path of the laradock directory
# Returns
#   None
#######################################
laradock_dir() {
  echo "$(script_dir)/../../laradock"
}

#######################################
# Outputs the fully qualified paths of all laradockctl command directories.
# Globals:
#   LARADOCKCTL_ADDITIONAL_COMMAND_DIRS
# Arguments:
#   None
# Outputs:
#   STDOUT The fully qualified paths of all laradockctl command directories
# Returns
#   None
#######################################
laradockctl_command_dirs() {
  local dirs
  dirs="$(script_dir)/../src/commands"
  if [ -n "${LARADOCKCTL_ADDITIONAL_COMMAND_DIRS:-}" ]; then
    dirs="${LARADOCKCTL_ADDITIONAL_COMMAND_DIRS}:${dirs}"
  fi
  echo "${dirs}"
}

#######################################
# Outputs the fully qualified path to the built-in laradockctl command directory.
# Globals:
#   None
# Arguments:
#   $1 The path relative to the build-in laradockctl command directory
# Outputs:
#   STDOUT The fully qualified path to the built-in laradockctl command directory
# Returns
#   None
#######################################
laradockctl_command_path() {
  local path=''
  if [ $# -eq 1 ]; then
    path="/$1"
  fi
  echo "$(script_dir)/../src/commands${path}"
}

#######################################
# Checks whether a file exists in the workspace container.
# Globals:
#   None
# Arguments:
#   $1 The fully qualified path or path relative to /var/www
# Outputs:
#   None
# Returns
#   0 If the file exists
#   1 If the file not exists
#######################################
file_exists_in_workspace() {
  local -r path="$1"
  docker-compose exec workspace bash -c "test -f ${path}"
}

#######################################
# Outputs the error message.
# Globals:
#   None
# Arguments:
#   $1 Error message to print out
# Outputs:
#   STDERR The erroe message
# Returns
#   0
#######################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  return 0
}

#######################################
# Outputs the base name of the laradockctl executable.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   STDOUT The base name of the laradockctl executable
# Returns
#   0
#######################################
script_basename() {
  echo "$(basename "$0")"
  return 0
}

#######################################
# Outputs the fully qualified path of the directory of the laradockctl executable.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   STDOUT The fully qualified path of the directory of the laradockctl executable
# Returns
#   0
#######################################
script_dir() {
  echo "$(cd "$(dirname "$0")" && pwd)"
  return 0
}

#######################################
# Checks if the given key or index exists in the array.
# Globals:
#   None
# Arguments:
#   $1 The reference to the array
#   $2 The key or index
# Outputs:
#   None
# Returns
#   0 If the key exists
#   1 If the key not exists
#######################################
array_key_exists() {
  declare -rn array_ref="$1"
  local key
  for key in "${!array_ref[@]}"; do
    if [[ "${key}" == "$2" ]]; then
      return 0
    fi
  done
  return 1
}

#######################################
# Colors text.
# Globals:
#   None
# Arguments:
#   $1 Text
#   $2 The color name
# Outputs:
#   STDOUT Colored text
# Returns
#   0
#######################################
color_text() {
  local -r text="$1"
  local -r color_name="$2"
  declare -A COLORS
  _provide_color_name_to_value COLORS
  tput setaf "${COLORS["${color_name}"]}"
  echo -en "${text}"
  tput sgr0
  return 0
}

#######################################
# Colors the text background.
# Globals:
#   None
# Arguments:
#   $1 Text
#   $2 The color name
# Outputs:
#   STDOUT Text with the colored background
# Returns
#   0
#######################################
color_background() {
  local -r text="$1"
  local -r color_name="$2"
  declare -A COLORS
  _provide_color_name_to_value COLORS
  tput setab "${COLORS["${color_name}"]}"
  echo -en "${text}"
  tput sgr0
  return 0
}

#######################################
# Provides an associative array of a color name to value.
# Globals:
#   None
# Arguments:
#   $1 The associative array to provide
# Outputs:
#   None
# Returns
#   0
#######################################
_provide_color_name_to_value() {
  declare -rn interest="$1"
  interest=(
    ['black']='0'
    ['red']='1'
    ['green']='2'
    ['yellow']='3'
    ['blue']='4'
    ['magenta']='5'
    ['cyan']='6'
    ['white']='7'
  )
  return 0
}
