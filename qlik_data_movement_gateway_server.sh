#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"


qlik_data_movement_gateway_server() {

  docker run -d --name "${qlik_data_movement_gateway_container_name}" "${qlik_data_movement_gateway_image}:${qlik_data_movement_gateway_tag}"

  docker exec "${qlik_data_movement_gateway_container_name}" "/root/${qlik_package_version}/opt/qlik/gateway/movement/bin/agentctl qcs get_registration"

  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      config | download | build | setup | run | server)
        set -- qlik_data_movement_gateway_"$1" "${@:2}"
        "$@"
        result=$?
      ;;
      *)
        printf "unknown subcommand(s): %s\n" "${*}"
        result=1
    esac
    return ${result}
  else
    return 0
  fi

}
