#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik-data-movement-gateway-config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik-data-movement-gateway-config.sh"


qlik_data_movement_gateway_setup() {

  docker pull "${qlik_data_movement_gateway_image}/${qlik_data_movement_gateway_tag}"

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
    local result=0
    case $1 in
      config | download | build | server)
        set -- qlik_data_movement_gateway_"$1" "${@:2}"
        "$@"
        result=$?
      ;;
      *)
        echo "unknown subcommand(s):" "${@}"
        result=1
    esac
    return ${result}
  else
    return 0
  fi

}
