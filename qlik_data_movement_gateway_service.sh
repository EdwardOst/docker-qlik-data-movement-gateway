#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


qlik_data_movement_gateway_service() {

  printf "service:\n"

  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      start)
        shift 1
        docker exec "${qlik_data_movement_gateway_container_name}" /opt/qlik/gateway/movement/bin/repagent start
        result=$?
        ;;
      stop)
        shift 1
        docker exec "${qlik_data_movement_gateway_container_name}" /opt/qlik/gateway/movement/bin/repagent stop
        result=$?
        ;;
      *)
        printf "Usage: qlik_data_movement_gateway service < start | stop > ...\nService subcommand is required and must be either 'start' or 'stop'.\n"
        result=1
    esac
  else
    printf "Usage: qlik_data_movement_gateway service < start | stop > ...\nService subcommand is required and must be either 'start' or 'stop'.\n"
    result=1
  fi

  if [ ! ${result} = 0 ]; then
    return ${result}
  fi

  if [ $# -gt 0 ]; then
    qlik_data_movement_gateway "${@}"
    return $?
  else
    return 0
  fi
}