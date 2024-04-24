#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


qlik_data_movement_gateway_setup() {

  printf "setup:\n"

  # create a volume for the data directory
  docker volume create "${qlik_data_movement_gateway_volume}"

  # create a docker network if it does not already exist
  local docker_network_exists
  docker_network_exists=$( docker network ls -q -f name="${qlik_data_movement_gateway_network}" )
  if [ -z "${docker_network_exists}" ]; then
    printf "Creating docker network %s\n" "${qlik_data_movement_gateway_network}"
    docker network create "${qlik_data_movement_gateway_network}"
  else
    printf "Docker network %s(%s) already exists\n" "${qlik_data_movement_gateway_network}" "${docker_network_exists}"
  fi

  if [ $# -gt 0 ]; then
    qlik_data_movement_gateway "${@}"
    return $?
  else
    return 0
  fi
}
