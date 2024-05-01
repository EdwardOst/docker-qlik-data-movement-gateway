#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"

function qlik_data_movement_gateway_build() {

  printf "build:\n"

  if ! [ -f "${qlik_data_movement_gateway_package}" ]; then
    printf "Error: qlik data movement gateway package '%s' not found.  Use qlik_data_movement_gateway_download to get the package.\n" \
      "${qlik_data_movement_gateway_package}"
    return 1
  fi

#  local -r qlik_data_movement_gateway_version=$(rpm -q --queryformat='%{VERSION}.%{RELEASE}' qlik-data-gateway-data-movement.rpm 2>/dev/null)
#  printf "Qlik Data Movement Gateway Version: %s\n" "${qlik_data_movement_gateway_version}"

  docker build --no-cache -t "${qlik_data_movement_gateway_image}:${qlik_data_movement_gateway_tag}"  \
    --build-arg base_image="${qlik_data_movement_gateway_base_image}" \
    --build-arg base_tag="${qlik_data_movement_gateway_base_tag}" \
    --build-arg qlik_package="${qlik_data_movement_gateway_package}" \
    --build-arg qlik_package_version="${qlik_data_movement_gateway_package_version}" \
    --build-arg qlik_package_platform="${qlik_data_movement_gateway_package_platform}" \
    --build-arg user="${qlik_data_movement_gateway_user}" \
    --build-arg password="${qlik_data_movement_gateway_password}" \
    --build-arg dnf_command="${qlik_data_movement_gateway_dnf_command}" \
    --build-arg qlik_tenant="${qlik_data_movement_gateway_tenant}" -f "${qlik_data_movement_gateway_dockerfile}" .

  declare -r build_status=$?

  if [ ${build_status} -ne 0 ]; then
    printf "Error: docker build command failed with status %s\n" "${build_status}" >&2
    return ${build_status}
  fi


  if [ $# -gt 0 ]; then
    qlik_data_movement_gateway "${@}"
    return $?
  else
    return 0
  fi
}
