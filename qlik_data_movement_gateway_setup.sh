#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


qlik_data_movement_gateway_setup() {

  docker pull "${qlik_data_movement_gateway_image}/${qlik_data_movement_gateway_tag}"

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
