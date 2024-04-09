#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
# shellcheck disable=SC2034
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik-data-movement-gateway-config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik-data-movement-gateway-config.sh"

qlik_data_movement_gateway_download() {

#  local -r github_token="${1:-${github_token?' github token argument required to download qlik data movement gateway from github'}}"

  local token
  case "${1}" in
    -t=*|--token=*)
      token="${1#*=}"
      shift  1
      ;;
  esac
  local -r github_token="${token:-${github_token?' token argument or github_token global var required to download qlik data movement gateway from github'}}"

  local -r download_url=$(curl -s -H "Authorization: Bearer ${github_token}" "https://api.github.com/repos/${qlik_data_movement_gateway_organization}/${qlik_data_movement_gateway_repo}/contents/${qlik_data_movement_gateway_file}" | jq -r ".download_url" )
  curl -sLJ -o "${qlik_data_movement_gateway_file}" -H "Authorization: Bearer ${github_token}" "${download_url}"
}
