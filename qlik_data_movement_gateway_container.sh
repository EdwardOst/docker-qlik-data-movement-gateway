#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


qlik_data_movement_gateway_init() {

  printf "init:\n"

  if [ "${qlik_data_movement_gateway_type}" = "instance" ]; then
    docker run -d --init --network "${qlik_data_movement_gateway_network}" --name "${qlik_data_movement_gateway_container_name}" "${qlik_data_movement_gateway_image}:${qlik_data_movement_gateway_tag}"
  elif [ "${qlik_data_movement_gateway_type}" = "instance-rpm" ]; then
    docker run -d --init --network "${qlik_data_movement_gateway_network}" --name "${qlik_data_movement_gateway_container_name}" "${qlik_data_movement_gateway_image}:${qlik_data_movement_gateway_tag}"
  elif [ "${qlik_data_movement_gateway_type}" = "service" ]; then
    docker run -d --privileged --network "${qlik_data_movement_gateway_network}" --name "${qlik_data_movement_gateway_container_name}" "${qlik_data_movement_gateway_image}:${qlik_data_movement_gateway_tag}"
    # allow time so that registration and other exec commands will work against container
    sleep 3
    printf " DEBUG: executing init-start\n"
    docker exec "${qlik_data_movement_gateway_container_name}" /bin/bash -c /root/init-start.sh
  else
    printf "  ERROR: Invalid gateway type.  Gateway type must be one of [ instance | service ] but qlik_data_movement_gateway_type=%s\n" "${qlik_data_movement_gateway_type}"
    return 1
  fi

  if [ $# -gt 0 ]; then
    qlik_data_movement_gateway "${@}"
    return $?
  else
    return 0
  fi
}


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


qlik_data_movement_gateway_stop() {

  printf "stop:\n"

  docker stop "${qlik_data_movement_gateway_container_name}"

  if [ $# -gt 0 ]; then
    qlik_data_movement_gateway "${@}"
    return $?
  else
    return 0
  fi
}


qlik_data_movement_gateway_shell() {

  printf "shell:\n"

  docker exec -it "${qlik_data_movement_gateway_container_name}" /bin/bash

  return $?

}
