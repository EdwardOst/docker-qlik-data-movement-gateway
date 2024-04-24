#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
# shellcheck disable=SC2034
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"


# initialze all shell variables as local to a containing function
# and then chain subsequent function calls

qlik_data_movement_gateway_config() {

  printf "config:\n"

  local output_file=""
  case "${1}" in
    -o|--output)
      output_file="/dev/stdin"
      shift  1
      ;;
    -o=*|--output=*)
      output_file="${1#*=}"
      shift  1
      ;;
  esac

  # TODO: add usage message


  # BUILD ENVIRONMENT CONFIGURATION

  # these settings specify where the data movement gateway rpm can be downloaded from
  # the default download function downloads from github
  local -r qlik_data_movement_gateway_organization="${qlik_data_movement_gateway_organization:-EdwardOst}"
  local -r qlik_data_movement_gateway_repo="${qlik_data_movement_gateway_repo:-qlik-releases}"
  local -r qlik_data_movement_gateway_operator="edwardost"

  local -r qlik_data_movement_gateway_package_version="${qlik_data_movement_gateway_package_version:-2023.11-4}"
  local -r qlik_data_movement_gateway_package_platform="${qlik_data_movement_gateway_package_platform:-x86_64}"
  local -r qlik_data_movement_gateway_package="${qlik_data_movement_gateway_package:-qlik-data-gateway-data-movement_${qlik_data_movement_gateway_package_version}_${qlik_data_movement_gateway_package_platform}.rpm}"

  local -r qlik_data_movement_gateway_dnf_command="microdnf"

  # IMAGE CONFIGURATION

  # gateway image and tag
  local -r qlik_data_movement_gateway_image="${qlik_data_movement_gateway_image:-${qlik_data_movement_gateway_operator}/qlik-data-movement-gateway}"
  local -r qlik_data_movement_gateway_tag="${qlik_data_movement_gateway_tag:-${qlik_data_movement_gateway_package_version}}"

  # base image and tag from which gateway image will be derived
  local -r qlik_data_movement_gateway_base_image="${qlik_data_movement_gateway_base_image:-${qlik_data_movement_gateway_operator}/ubi8-minimal}"
  local -r qlik_data_movement_gateway_base_tag="${qlik_data_movement_gateway_base_tag:-8.9-1161}"

  # CONTAINER CONFIGURATION

  # name of gateway container
  local -r qlik_data_movement_gateway_container_name="${qlik_data_movement_gateway_container_name:-qlik-data-movement-gateway}"

  # data volume used by gateway image
  local -r qlik_data_movement_gateway_volume="${qlik_data_movement_gateway_volume:-qlik-data-movement-gateway-data}"

  # network on which gateway container will be deployed
  local -r qlik_data_movement_gateway_network="${qlik_data_movement_gateway_network:-qlik-data-movement-gateway-network}"

  # APPLICATION CONFIGURATION

  # qlik cloud tenant
  local -r qlik_tenant="${qlik_tenant:-obd}"


  if [ -n "${output_file}" ]; then
    cat > "${output_file}"  <<EOF
qlik_data_movement_gateway_organization="${qlik_data_movement_gateway_organization}"
qlik_data_movement_gateway_repo="${qlik_data_movement_gateway_repo}"
qlik_data_movement_gateway_package_version="${qlik_data_movement_gateway_package_version}"
qlik_data_movement_gateway_package_platform="${qlik_data_movement_gateway_package_platform}"
qlik_data_movement_gateway_package="${qlik_data_movement_gateway_package}"
qlik_data_movement_gateway_image="${qlik_data_movement_gateway_image}"
qlik_data_movement_gateway_tag="${qlik_data_movement_gateway_tag}"
qlik_data_movement_gateway_base_image="${qlik_data_movement_gateway_base_image}"
qlik_data_movement_gateway_base_tag="${qlik_data_movement_gateway_base_tag}"
qlik_data_movement_gateway_container_name="${qlik_data_movement_gateway_container_name}"
qlik_data_movement_gateway_volume="${qlik_data_movement_gateway_volume}"
qlik_data_movement_gateway_network="${qlik_data_movement_gateway_network}"
qlik_tenant="${qlik_tenant}"
EOF
  fi

  # shellcheck disable=SC2034
  local -r qlik_data_movement_gateway_config_called=true
  while [ $# -gt 0 ] && [ "$1" = "config" ]; do
    shift 1
  done
  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      download | setup | build | init | registration | start | stop | shell | service)
        set -- "qlik_data_movement_gateway_$1" "${@:2}"
        "$@"
        result=$?
      ;;
      *)
        docker exec "${qlik_data_movement_gateway_container_name}" "${@}"
        result=$?
    esac
    return ${result}
  fi

}
