#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
# shellcheck disable=SC2034
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"


# initialze all shell variables as local to a containing function
# and then chain subsequent function calls

qlik_data_movement_gateway() {

  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      config | download | build | setup | server)
        set -- qlik_data_movement_gateway_"$1" "${@:2}"
        "$@"
        result=$?
      ;;
      *)
        printf "unknown subcommand(s): %s\n" "${*}"
        result=1
    esac
    return ${result}
  else
    printf "Usage: qlik_data_movement_gateway [ command ]\nCommmand: [ config | download | build | setup | server ...]\nMultiple commands can be issued in one call.\n"
    return 0
  fi

}
