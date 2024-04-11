#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
# shellcheck disable=SC2034
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"


# initialze all shell variables as local to a containing function
# and then chain subsequent function calls

qlik_data_movement_gateway_config() {

  # BUILD ENVIRONMENT CONFIGURATION

  # these settings specify where the data movement gateway rpm can be downloaded from
  # the default download function downloads from github
  local -r qlik_data_movement_gateway_organization="${qlik_data_movement_gateway_organization:-EdwardOst}"
  local -r qlik_data_movement_gateway_repo="${qlik_data_movement_gateway_repo:-qlik-releases}"

  # debian package for ubuntu
#  local -r qlik_data_movement_gateway_package_deb_version="2023.11-5"
#  local -r qlik_data_movement_gateway_package_deb_platform="amd64"
#  local -r qlik_data_movement_gateway_package_deb="${qlik_data_movement_gateway_package_deb:-qlik-data-gateway-data-movement_${qlik_data_movement_gateway_package_deb_version}_${qlik_data_movement_gateway_package_deb_platform}.deb}"

  # rpm package for redhat
  local -r qlik_data_movement_gateway_package_rpm_version="2023.11-4"
  local -r qlik_data_movement_gateway_package_rpm_platform="x86_64"
  local -r qlik_data_movement_gateway_package_rpm="${qlik_data_movement_gateway_package_rpm:-qlik-data-gateway-data-movement_${qlik_data_movement_gateway_package_rpm_version}_${qlik_data_movement_gateway_package_rpm_platform}.rpm}"

  local -r qlik_data_movement_gateway_package_version="${qlik_data_movement_gateway_package_rpm_version}"
  local -r qlik_data_movement_gateway_package_platform="${qlik_data_movement_gateway_package_rpm_platform}"
  local -r qlik_data_movement_gateway_package="${qlik_data_movement_gateway_package_rpm}"

#  local -r qlik_data_movement_gateway_version=$(rpm -q --queryformat='%{VERSION}.%{RELEASE}' qlik-data-gateway-data-movement.rpm 2>/dev/null)

  # IMAGE CONFIGURATION

  # image and tag of the gateway image
  local -r qlik_data_movement_gateway_image="${qlik_data_movement_gateway_image:-edwardost/qlik-data-movement-gateway}"
  local -r qlik_data_movement_gateway_tag="${qlik_data_movement_gateway_tag:-${qlik_data_movement_gateway_package_version}}"

  # image and tag of base image from which gateway image will be derived
# ubuntu
#  local -r qlik_data_movement_gateway_base_image="${qlik_data_movement_gateway_base_image-edwardost/ubuntu}"
#  local -r qlik_data_movement_gateway_base_tag="${qlik_data_movement_gateway_base_tag:-22.04}"
# redhat
  local -r qlik_data_movement_gateway_base_image="${qlik_data_movement_gateway_base_image:-redhat/ubi8-init}"
  local -r qlik_data_movement_gateway_base_tag="${qlik_data_movement_gateway_base_tag:-8.9-3}"

  # CONTAINER CONFIGURATION

  # name of gateway container
  local -r qlik_data_movement_gateway_container_name="${qlik_data_movement_gateway_container_name:-qlik_data_movement_gateway}"

  # data volume used by gateway image
  local -r qlik_data_movement_gateway_volume="${qlik_data_movement_gateway_volume:-qlik-data-movement-gateway-data}"

  # network on which gateway container will be deployed
  local -r qlik_data_movement_gateway_network="${qlik_data_movement_gateway_network:-qlik-data-movement-gateway-network}"

  # APPLICATION CONFIGURATION

  # qlik cloud tenant
  local -r qlik_tenant="${qlik_tenant:-obd}"


  # These shell variables in the host OS are mapped to environment variables in the docker image when the qlik-data-movement-gateway-server command invokes docker run.
  # The shell variables have the same name as the environment variables but are lowercase.

  # MYSQL_ROOT_PASSWORD
  # This variable is mandatory and specifies the password that will be set for the MySQL root superuser account.
  local mysql_root_password="${mysql_root_password:-tadmin}"

  # MYSQL_DATABASE
  # This variable is optional and allows you to specify the name of a database to be created on image startup.
  # If a user/password was supplied then that user will be granted superuser access (corresponding to GRANT ALL) to this database.
  local mysql_database="${mysql_database:-talend}"

  # MYSQL_USER, MYSQL_PASSWORD
  # These variables are optional, used in conjunction to create a new user and to set that user's password.
  # This user will be granted superuser permissions (see above) for the database specified by the MYSQL_DATABASE variable.
  # Both variables are required for a user to be created.
  local mysql_user="${mysql_user:-talend}"
  local mysql_password="${mysql_password:-talend123}"

  # get the ip address of the mysql container
  # not necessary if using a docker network
  # MYSQL_IP=$(docker inspect -f "{{.NetworkSettings.Networks.${mysql_network}.IPAddress}}" "${mysql_container_name}")

  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      download | build | setup | server)
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
