#!/bin/bash
#
# laradockctl helper functions.

set -Ceuo pipefail

#######################################
# Print out the error message.
# Globals:
#   None
# Arguments:
#   $1 Error message to print out
# Outputs:
#   Writes location to stderr
# Returns
#   0
#######################################
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
  return 0
}

#######################################
# Get the script name.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes name to stdout
# Returns
#   0
#######################################
script_name() {
  echo "$(basename "$0")"
  return 0
}

#######################################
# Get this script directory.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Writes location to stdout
# Returns
#   0
#######################################
script_dir() {
  echo "$(cd "$(dirname "$0")" && pwd)"
  return 0
}

#######################################
# Print out the error message.
# Globals:
#   None
# Arguments:
#   Error message to print out
# Outputs:
#   Writes location to stdout
# Returns
#   0 if key exists.
#   1 if key not exists.
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
# Color text.
# Globals:
#   None
# Arguments:
#   $1 Text.
#   $2 A color name.
# Outputs:
#   Writes colored text to stdout.
# Returns
#   0
#######################################
color_text() {
  local -r TEXT="$1"
  local -r COLOR_NAME="$2"
  declare -A colors
  _provide_color_name_to_value colors
  tput setaf "${colors["${COLOR_NAME}"]}"
  echo -en "${TEXT}"
  tput sgr0
  return 0
}

#######################################
# Color a text background.
# Globals:
#   None
# Arguments:
#   $1 Text.
#   $2 A color name.
# Outputs:
#   Writes text in colored background to stdout.
# Returns
#   0
#######################################
color_background() {
  local -r TEXT="$1"
  local -r COLOR_NAME="$2"
  declare -A colors
  _provide_color_name_to_value colors
  tput setab "${colors["${COLOR_NAME}"]}"
  echo -en "${TEXT}"
  tput sgr0
  return 0
}

#######################################
# Provides an associative array of a color name to value.
# Globals:
#   None
# Arguments:
#   $1 An associative array to provide.
# Outputs:
#   None
# Returns
#   0
#######################################
_provide_color_name_to_value() {
  declare -rn INTEREST="$1"
  INTEREST=(
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
