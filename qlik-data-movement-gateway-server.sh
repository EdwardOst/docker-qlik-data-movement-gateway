#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik-data-movement-gateway-config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik-data-movement-gateway-config.sh"


qlik_data_movement_gateway_server() {

  # run in daemon mode and keep the container rather than removing it
#  docker run --name "${qlik_data_movement_gateway_container_name}" \
#    -v "${qlik_data_movement_gateway_volume}":/opt/qlik_data_movement_gateway \
#    ${qlik_data_movement_gateway_network:+ --network="${qlik_data_movement_gateway_network}"} \
#    -d --restart unless-stopped \
#    "${qlik_data_movement_gateway_image}:${qlik_data_movement_gateway_tag}"

  docker run --name "${qlik_data_movement_gateway_container_name}" \
    -d \
    "${qlik_data_movement_gateway_image}:${qlik_data_movement_gateway_tag}"

  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      config | download | build | setup)
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
