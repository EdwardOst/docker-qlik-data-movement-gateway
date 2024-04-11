#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
# shellcheck disable=SC2034
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik-data-movement-gateway-config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik-data-movement-gateway-config.sh"

qlik_data_movement_gateway_download() {

  local token
  case "${1}" in
    -t=*|--token=*)
      token="${1#*=}"
      shift  1
      ;;
  esac
  local -r github_token="${token:-${github_token?' --token=<github token> argument or github_token global var required to download qlik data movement gateway from github'}}"

  local -r download_url=$(curl -s -H "Authorization: Bearer ${github_token}" "https://api.github.com/repos/${qlik_data_movement_gateway_organization}/${qlik_data_movement_gateway_repo}/contents/${qlik_data_movement_gateway_package}" | jq -r ".download_url" )
  curl -sLJ -o "${qlik_data_movement_gateway_package}" -H "Authorization: Bearer ${github_token}" "${download_url}"

  # this must not be local
  # this will set the qlik_data_movement_gateway_version set in the outer scope of the qlik_data_movement_gateway_config
  #qlik_data_movement_gateway_version=$(rpm -q --queryformat='%{VERSION}.%{RELEASE}' qlik-data-gateway-data-movement.rpm 2>/dev/null)

}
