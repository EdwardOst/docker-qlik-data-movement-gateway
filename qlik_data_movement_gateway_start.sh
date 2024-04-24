#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


qlik_data_movement_gateway_start() {

  docker exec "${qlik_data_movement_gateway_container_name}" /opt/qlik/gateway/movement/bin/repagent start

  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      config | download | build | setup | shell | server | start | stop)
        set -- qlik_data_movement_gateway_"$1" "${@:2}"
        "$@"
        result=$?
      ;;
      *)
        docker exec "${qlik_data_movement_gateway_container_name}" "${@}"
        result=1
    esac
    return ${result}
  else
    return 0
  fi

}
