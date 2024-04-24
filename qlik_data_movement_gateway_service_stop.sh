#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


qlik_data_movement_gateway_service_stop() {

  printf "service.stop:\n"

  docker exec "${qlik_data_movement_gateway_container_name}" /opt/qlik/gateway/movement/bin/repagent stop

  if [ $# -gt 0 ]; then
    qlik_data_movement_gateway "${@}"
    return $?
  else
    return 0
  fi
}
