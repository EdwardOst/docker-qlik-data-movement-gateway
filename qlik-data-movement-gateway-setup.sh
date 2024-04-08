#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway.sh"


qlik_data_movement_gateway_setup() {

  docker pull qlik_data_movement_gateway/cloudbeaver:"${qlik_data_movement_gateway_version}"

  docker volume create "${qlik_data_movement_gateway_volume}"

  # create a docker network if it does not already exist
  local docker_network_exists
  docker_network_exists=$( docker network ls -q -f name="${qlik_data_movement_gateway_network}" )
  if [ -z "${docker_network_exists}" ]; then
    echo "Creating docker network ${qlik_data_movement_gateway_network}"
    docker network create "${qlik_data_movement_gateway_network}"
  else
    echo "Docker network ${qlik_data_movement_gateway_network}(${docker_network_exists}) already exists"
  fi

  if [ $# -gt 0 ]; then
    case $1 in
      setup | server)
        set -- qlik_data_movement_gateway_"$1" "${@:2}"
      ;;
    esac
  fi

  "$@"

}
