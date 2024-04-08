#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway.sh"


qlik_data_movement_gateway_server() {

  # run qlik_data_movement_gateway as a temporary container in a terminal mapping port QLIK_DATA_MOVEMENT_GATEWAY_CONTAINER_PORT
  # to a host port QLIK_DATA_MOVEMENT_GATEWAY_HOST_PORT

  # docker run --name ${QLIK_DATA_MOVEMENT_GATEWAY_CONTAINER_NAME} --rm -it --network=${QLIK_DATA_MOVEMENT_GATEWAY_NETWORK}
  #   -p ${QLIK_DATA_MOVEMENT_GATEWAY_HOST_PORT}:${QLIK_DATA_MOVEMENT_GATEWAY__CONTAINER_PORT}
  #   -v ${QLIK_DATA_MOVEMENT_GATEWAY_VOLUME}:/opt/qlik_data_movement_gateway
  #   edwardost/qlik_data_movement_gateway:${QLIK_DATA_MOVEMENT_GATEWAY_VERSION}

  # run in daemon mode and keep the container rather than removing it
 docker run --name "${qlik_data_movement_gateway_container_name}" \
    ${qlik_data_movement_gateway_host_port:+ -p "${qlik_data_movement_gateway_host_port}":"${qlik_data_movement_gateway_container_port}"} \
    -v "${qlik_data_movement_gateway_volume}":/opt/qlik_data_movement_gateway \
    ${qlik_data_movement_gateway_network:+ --network="${qlik_data_movement_gateway_network}"} \
    -d --restart unless-stopped \
    edwardost/qlik_data_movement_gateway:"${qlik_data_movement_gateway_version}"

  if [ $# -gt 0 ]; then
    case $1 in
      setup | server)
        set -- qlik_data_movement_gateway_"$1" "${@:2}"
      ;;
    esac
  fi

  "$@"
}
