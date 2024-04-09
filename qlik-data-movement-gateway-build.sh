#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik-data-movement-gateway-config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik-data-movement-gateway-config.sh"

function qlik_data_movement_gateway_build() {

  if ! [ -f qlik-data-gateway-data-movement.rpm ]; then
    echo "Error: qlik-data-gateway-data-movement.rpm not found.  Use qlik_data_movement_gateway_download to download the rpm."
    return 1
  fi

  local -r qlik_data_movement_gateway_version=$(rpm -q --queryformat='%{VERSION}.%{RELEASE}' qlik-data-gateway-data-movement.rpm 2>/dev/null)
  # echo "Qlik Data Movement Gateway Version: ${qlik_data_movement_gateway_version}"

  docker build -t "${qlik_data_movement_gateway_image}:${qlik_data_movement_gateway_tag}"  \
    --build-arg base_image="${qlik_data_movement_gateway_base_image}" \
    --build-arg base_tag="${qlik_data_movement_gateway_base_tag}" \
    --build-arg qlik_data_movement_gateway_rpm_version="${qlik_data_movement_gateway_version}" \
    "${@}" .

  declare -r build_status=$?

  if [ ${build_status} -ne 0 ]; then
    echo "docker build command failed with status ${build_status}" >&2
    return ${build_status}
  fi



  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      config | setup | server)
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
