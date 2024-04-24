#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


qlik_data_movement_gateway_start() {

  printf "start:\n"

  docker start "${qlik_data_movement_gateway_container_name}"

  if [ $# -gt 0 ]; then
    qlik_data_movement_gateway "${@}"
    return $?
  else
    return 0
  fi
}
