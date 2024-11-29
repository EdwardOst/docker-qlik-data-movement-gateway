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


  # IMAGE CONFIGURATION

  # gateway_type must be one of [ instance | instance-rpm | instance-minimal | service ]
  # instance gateways do not use systemctl and run in an image derived ubi8-standard
  # service gateways use systemctl and run in an image derived from ubi8-init
  local -r qlik_data_movement_gateway_type="${qlik_data_movement_gateway_type:-instance}"
  if [ ! "${qlik_data_movement_gateway_type}" = "instance" ] \
     && [ ! "${qlik_data_movement_gateway_type}" = "instance-rpm" ] \
     && [ ! "${qlik_data_movement_gateway_type}" = "instance-minimal" ] \
     && [ ! "${qlik_data_movement_gateway_type}" = "service" ]; then
    printf "  ERROR: Invalid gateway type.  Gateway type must be one of [ instance | service ] but qlik_data_movement_gateway_type=%s\n" "${qlik_data_movement_gateway_type}"
    return 1
  fi

  local -A qlik_data_movement_gateway_type_dockerfile=([instance]="dockerfile" \
                                                       [instance-rpm]="dockerfile-rpm" \
                                                       [instance-minimal]="dockerfile-minimal" \
                                                       [service]="dockerfile-init")
  local -A qlik_data_movement_gateway_type_build_target=([instance]="gateway_instance" \
                                                         [instance-rpm]="gateway_instance" \
                                                         [instance-minimal]="gateway_instance" \
                                                         [service]="gateway_service")
  local -A qlik_data_movement_gateway_type_image=([instance]="${qlik_data_movement_gateway_operator}/qlik-data-movement-gateway" \
                                                  [instance-rpm]="${qlik_data_movement_gateway_operator}/qlik-data-movement-gateway-rpm" \
                                                  [instance-minimal]="${qlik_data_movement_gateway_operator}/qlik-data-movement-gateway-minimal" \
                                                  [service]="${qlik_data_movement_gateway_operator}/qlik-data-movement-gateway-init")
  local -A qlik_data_movement_gateway_type_base_image=([instance]="${qlik_data_movement_gateway_operator}/ubi8" \
                                                       [instance-rpm]="${qlik_data_movement_gateway_operator}/ubi8" \
                                                       [instance-minimal]="${qlik_data_movement_gateway_operator}/ubi8-minimal" \
                                                       [service]="${qlik_data_movement_gateway_operator}/ubi8-init")
  local -A qlik_data_movement_gateway_type_base_tag=([instance]="8.9-1160" \
                                                     [instance-rpm]="8.9-1160" \
                                                     [instance-minimal]="8.9-1161" \
                                                     [service]="8.9-7")
  local -A qlik_data_movement_gateway_type_dnf_command=([instance]="dnf" \
                                                     [instance-rpm]="dnf" \
                                                     [instance-minimal]="microdnf" \
                                                     [service]="dnf")

  # gateway image and tag
  local -r qlik_data_movement_gateway_image="${qlik_data_movement_gateway_image:-${qlik_data_movement_gateway_type_image[${qlik_data_movement_gateway_type}]}}"
  local -r qlik_data_movement_gateway_tag="${qlik_data_movement_gateway_tag:-${qlik_data_movement_gateway_package_version}}"

  # base image and tag
  local -r qlik_data_movement_gateway_base_image="${qlik_data_movement_gateway_base_image:-${qlik_data_movement_gateway_type_base_image[${qlik_data_movement_gateway_type}]}}"
  local -r qlik_data_movement_gateway_base_tag="${qlik_data_movement_gateway_base_tag:-${qlik_data_movement_gateway_type_base_tag[${qlik_data_movement_gateway_type}]}}"

  # builder image and tag
  local -r qlik_data_movement_gateway_builder_image="${qlik_data_movement_gateway_builder_image:-${qlik_data_movement_gateway_operator}/ubi8}"
  local -r qlik_data_movement_gateway_builder_tag="${qlik_data_movement_gateway_builder_tag:-8.9-1160}"

  # dockerfile and stage target
  local -r qlik_data_movement_gateway_dockerfile="${qlik_data_movement_gateway_dockerfile:-${qlik_data_movement_gateway_type_dockerfile[${qlik_data_movement_gateway_type}]}}"
  local -r qlik_data_movement_gateway_build_target="${qlik_data_movement_gateway_build_target:-${qlik_data_movement_gateway_type_build_target[${qlik_data_movement_gateway_type}]}}"

  local -r qlik_data_movement_gateway_user="${qlik_data_movement_gateway_user:-qlik}"
  local -r qlik_data_movement_gateway_password="${qlik_data_movement_gateway_password:-qlik123}"

  local -r qlik_data_movement_gateway_dnf_command="${qlik_data_movement_gateway_dnf_command:-${qlik_data_movement_gateway_type_dnf_command[${qlik_data_movement_gateway_type}]}}"


  # CONTAINER CONFIGURATION

  # name of gateway container
  local -r qlik_data_movement_gateway_container_name="${qlik_data_movement_gateway_container_name:-qlik-data-movement-gateway}"

  # data volume used by gateway image
  local -r qlik_data_movement_gateway_volume="${qlik_data_movement_gateway_volume:-qlik-data-movement-gateway-data}"

  # network on which gateway container will be deployed
  local -r qlik_data_movement_gateway_network="${qlik_data_movement_gateway_network:-qmi_default}"


  # APPLICATION CONFIGURATION

  # qlik cloud tenant
  local -r qlik_data_movement_gateway_tenant="${qlik_data_movement_gateway_tenant:-obd}"

  # userid and password for replicate web gui
  local -r qlik_data_movement_gateway_replicate_user="${qlik_data_movement_gateway_replicate_user:-admin}"
  # password must be 16 digits and have lowercase, uppercase, and digits
  local -r qlik_data_movement_gateway_replicate_password="${qlik_data_movement_gateway_replicate_password:-Qlik_replicate_123}"

  # The replicate web ui is exposed on 3552 by default (rport) within the container.
  # This setting determines the host port on which it rport is exposed.  It defaults to 3552.
  # It can mapped to a different port by just overriding with a valid value.
  # If set to dynamic then a host port will be dynamically selected and the container must be inspected to determine the value.
  # If set to disabled the port will not be mapped to a host port.
  local -r qlik_data_movement_gateway_host_replicate_port="${qlik_data_movement_gateway_host_replicate_port:-3552}"

  # DRIVERS

  # mysql
  local -r qlik_data_movement_gateway_mysql_odbc_url="${qlik_data_movement_gateway_mysql_odbc_url:-https://dev.mysql.com/get/Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.32-1.el8.x86_64.rpm}"
  local -r qlik_data_movement_gateway_mysql_jdbc_url="${qlik_data_movement_gateway_mysql_jdbc_url:-https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.33/mysql-connector-j-8.0.33.jar}"

  # snowflake
  local -r qlik_data_movement_gateway_snowflake_odbc_url="${qlik_data_movement_gateway_snowflake_odbc_url:-https://sfc-repo.snowflakecomputing.com/odbc/linux/3.1.1/snowflake-odbc-3.1.1.x86_64.rpm}"
  local -r qlik_data_movement_gateway_snowflake_jdbc_url="${qlik_data_movement_gateway_snowflake_jdbc_url:-https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.14.5/snowflake-jdbc-3.14.5.jar}"


  if [ -n "${output_file}" ]; then
    cat > "${output_file}"  <<EOF
qlik_data_movement_gateway_type="${qlik_data_movement_gateway_type}"
qlik_data_movement_gateway_dockerfile="${qlik_data_movement_gateway_dockerfile}"

qlik_data_movement_gateway_image="${qlik_data_movement_gateway_image}"
qlik_data_movement_gateway_tag="${qlik_data_movement_gateway_tag}"
qlik_data_movement_gateway_base_image="${qlik_data_movement_gateway_base_image}"
qlik_data_movement_gateway_base_tag="${qlik_data_movement_gateway_base_tag}"
qlik_data_movement_gateway_builder_image="${qlik_data_movement_gateway_builder_image}"
qlik_data_movement_gateway_builder_tag="${qlik_data_movement_gateway_builder_tag}"

qlik_data_movement_gateway_build_target="${qlik_data_movement_gateway_build_target}"
qlik_data_movement_gateway_tenant="${qlik_data_movement_gateway_tenant}"

qlik_data_movement_gateway_organization="${qlik_data_movement_gateway_organization}"
qlik_data_movement_gateway_repo="${qlik_data_movement_gateway_repo}"
qlik_data_movement_gateway_operator="${qlik_data_movement_gateway_operator}"
qlik_data_movement_gateway_package_version="${qlik_data_movement_gateway_package_version}"
qlik_data_movement_gateway_package_platform="${qlik_data_movement_gateway_package_platform}"
qlik_data_movement_gateway_package="${qlik_data_movement_gateway_package}"
qlik_data_movement_gateway_user="${qlik_data_movement_gateway_user}"
qlik_data_movement_gateway_dnf_command="${qlik_data_movement_gateway_dnf_command}"
qlik_data_movement_gateway_container_name="${qlik_data_movement_gateway_container_name}"
qlik_data_movement_gateway_volume="${qlik_data_movement_gateway_volume}"
qlik_data_movement_gateway_network="${qlik_data_movement_gateway_network}"
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
