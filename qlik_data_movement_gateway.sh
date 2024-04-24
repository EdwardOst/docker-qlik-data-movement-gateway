#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
# shellcheck disable=SC2034
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


# initialze all shell variables as local to a containing function
# and then chain subsequent function calls

qlik_data_movement_gateway() {

  if [ $# -gt 0 ]; then
    local result=0
    # if this is the first pass and config has not been called, then call it and chain subsequent function calls
    if [ -z "${qlik_data_movement_gateway_config_called}" ]; then
      # if config is being explicitly called as the first command then discard the extra explicit argument
      if [ "config" = "${1}" ]; then
        shift 1
      fi
      qlik_data_movement_gateway_config "${@}"
      result=$?
    # for subsequent subcommands invoke the explicit command or default to passing the argument to the assumed running container
    else
      case $1 in
        config | download | setup | build | init | registration | start | stop | service | shell)
          set -- "qlik_data_movement_gateway_$1" "${@:2}"
          "$@"
          result=$?
          ;;
        *)
          docker exec "${qlik_data_movement_gateway_container_name}" "${@}"
          result=$?
      esac
    fi
    return ${result}
  else
    printf "Usage: qlik_data_movement_gateway [ command ]\nCommmand: [ config | download | setup | build | init| registration | start | stop | service | shell | ...]\nMultiple commands can be issued in one call.\n"
    return 0
  fi

}


gateway() {
  qlik_data_movement_gateway "${@}"
}


qlik_gateway() {
  qlik_data_movement_gateway "${@}"
}
