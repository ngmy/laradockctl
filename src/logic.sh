#!/bin/bash
#
# laradockctl business logic.

set -Ceuo pipefail

show_error() {
  local -r message="$1"
  local -r message_length="${#1}"
  echo -en "$(color_background "  $(printf "%-${message_length}s  ")" 'red')\n"
  echo -en "$(color_background "  ${message}  " 'red')\n"
  echo -en "$(color_background "  $(printf "%-${message_length}s  ")" 'red')\n"
}

#######################################
# Outputs the laradockctl logo.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   STDOUT The laradockctl logo
# Returns
#   None
#######################################
_logo() {
  cat << 'LOGO'
 _                     _            _        _   _ 
| |                   | |          | |      | | | |
| | __ _ _ __ __ _  __| | ___   ___| | _____| |_| |
| |/ _` | '__/ _` |/ _` |/ _ \ / __| |/ / __| __| |
| | (_| | | | (_| | (_| | (_) | (__|   < (__| |_| |
|_|\__,_|_|  \__,_|\__,_|\___/ \___|_|\_\___|\__|_|
LOGO
}

#######################################
# Outputs the laradockctl version.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   STDOUT The laradockctl version
# Returns
#   None
#######################################
version() {
  local -r app_name="$(color_text "$(script_basename)" 'green')"
  local -r version="$(color_text "$(git describe --tags --exact-match 2>/dev/null \
    || git rev-parse --short HEAD)" 'yellow')"
  local -r release_date="$(date -u -d "@$(git log -n1 --pretty=%ct HEAD)" '+%Y-%m-%d %H:%M:%S')"
  echo -en "${app_name} version ${version} ${release_date}\n"
}

#######################################
# Outputs laradockctl usage.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   STDOUT laradockctl usage
# Returns
#   None
#######################################
usage() {
  color_text 'Usage:\n' 'yellow'
  echo -en "  $(script_basename) [options] command\n" 1>&2
}

#######################################
# Outputs laradockctl options.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   STDOUT laradockctl options
# Returns
#   None
#######################################
_options() {
  declare -rA options=(
    ['--no-ansi']='Disable ANSI output'
    ['-V, --version']='Display this application version'
    ['-d, --docker-compose-command=DOCKER_COMPOSE_COMMAND']='Execute a Docker Compose command'
    ['-h, --help']='Display this help message'
  )
  local -r longest_option_name_length="$(get_longest_array_key_length options)"
  color_text 'Options:\n' 'yellow'
  for option in "${!options[@]}"; do
    local padded_option_name="$(printf "%-${longest_option_name_length}s" "${option}")"
    printf "  %s  %s\n" "$(color_text "${padded_option_name}" 'green')" "${options["${option}"]}"
  done | sort
}

_get_command_namespace() {
  local -r fq_command_name="$1"
  local -r command_name="${fq_command_name#*:}"
  local -r command_namespace_with_colon="${fq_command_name%"${command_name}"}"
  local -r command_namespace="${command_namespace_with_colon%:}"
  echo "${command_namespace:-_}"
}

_get_command_name() {
  local -r fq_command_name="$1"
  local -r command_name="${fq_command_name#*:}"
  echo "${command_name}"
}

_get_command_namespaces() {
  declare -A command_name_to_file
  _provide_command_name_to_file command_name_to_file
  declare -a command_namespaces
  local fq_command_namespace
  for fq_command_namespace in "${!command_name_to_file[@]}"; do
    command_namespaces+=("$(_get_command_namespace "${fq_command_namespace}")")
  done
  printf '%s\n' "${command_namespaces[@]}" | sort | uniq
}

_provide_command_namespace_to_names() {
  declare -n interest="$1"
  declare -A command_name_to_file
  _provide_command_name_to_file command_name_to_file
  local fq_command_namespace
  for fq_command_namespace in "${!command_name_to_file[@]}"; do
    local command_namespace
    command_namespace="$(_get_command_namespace "${fq_command_namespace}")"
    local command_name
    command_name="$(_get_command_name "${fq_command_namespace}")"
    interest["${command_namespace}"]+=" ${command_name}"
  done
}

#######################################
# Outputs laradockctl commands.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   STDOUT laradockctl commands
# Returns
#   None
#######################################
_commands() {
  declare -A command_name_to_file
  _provide_command_name_to_file command_name_to_file
  declare -A command_namespace_to_names
  _provide_command_namespace_to_names command_namespace_to_names
  color_text 'Commands:\n' 'yellow'
  local -r longest_command_name_length="$(get_longest_array_key_length command_name_to_file)"
  local command_namespace
  while read -r command_namespace; do
    if [[ "${command_namespace}" != '_' ]]; then
      color_text " ${command_namespace}\n" 'yellow'
    fi
    local -a command_names=(${command_namespace_to_names["${command_namespace}"]})
    local command_name
    for command_name in "${command_names[@]}"; do
      if [[ "${command_namespace}" == '_' ]]; then
        source "${command_name_to_file["${command_name}"]}"
      else
        source "${command_name_to_file["${command_namespace}:${command_name}"]}"
      fi
      local padded_command_name="$(printf "%-${longest_command_name_length}s" "${NAME}")"
      printf "  %s  %s\n" "$(color_text "${padded_command_name}" 'green')" "${DESCRIPTION}"
    done | sort
  done < <(_get_command_namespaces)
}

get_longest_array_key_length() {
  declare -rn array_ref="$1"
  local length=0
  local key
  for key in "${!array_ref[@]}"; do
    if [[ "${#key}" -gt "${length}" ]]; then
      length="${#key}"
    fi
  done
  echo "${length}"
}

get_longest_command_name_length() {
  declare -A command_name_to_file
  _provide_command_name_to_file command_name_to_file
  local length=0
  local name
  for name in "${!command_name_to_file[@]}"; do
    if [[ "${#name}" -gt "${length}" ]]; then
      length="${#name}"
    fi
  done
  echo "${length}"
}

_execute_command_in_laradock_dir() {
  (cd "$(laradock_dir)" && "$@")
}

_execute_laradockctl_command_in_laradock_dir() {
  declare -A command_name_to_file
  _provide_command_name_to_file command_name_to_file
  source "${command_name_to_file["$1"]}"
  _execute_command_in_laradock_dir 'handle' "${@:2}"
}

_execute_docker_compose_command_in_laradock_dir() {
  (cd "$(laradock_dir)" && eval "docker-compose $@")
}

execute_command() {
  declare -A command_name_to_file
  _provide_command_name_to_file command_name_to_file
  if array_key_exists command_name_to_file "$1"; then
    _execute_laradockctl_command_in_laradock_dir "${@}"
  else
    show_error "Command \"$1\" is not defined."
    echo -en '\n'
    _commands
    exit 1
  fi;
}

exit_with_undefined_option_error() {
  show_error "Option \"-$1\" is not defined."
  echo -en '\n'
  _options
  exit 1
}

# TODO: Interface design
#       Create a "help" command and the "--help" option displays the result of "help list"?
help() {
  _logo
  echo -en '\n'
  version
  echo -en '\n'
  usage
  echo -en '\n'
  _options
  echo -en '\n'
  _commands
}

list() {
  _logo
  echo -en '\n'
  version
  echo -en '\n'
  usage
  echo -en '\n'
  _options
  echo -en '\n'
  _commands
}

_find_command_files() {
  echo -n "$(laradockctl_command_dirs)" | xargs -d ':' -I {} find {} -name '*.sh'
}

_provide_command_name_to_file() {
  declare -n interest="$1"
  local command_file
  while read -r command_file; do
    source "${command_file}"
    if [ -z "${interest["${NAME}"]:-}" ]; then
      interest["${NAME}"]="${command_file}"
    fi
  done < <(_find_command_files)
}
