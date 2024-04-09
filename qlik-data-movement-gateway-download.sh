#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
# shellcheck disable=SC2034
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"


# initialze all shell variables as local to a containing function
# and then chain subsequent function calls

qlik_data_movement_gateway_download() {

  local -r github_token="${1:-${github_token?' github token argument required to download qlik data movement gateway from github'}}"

  local download_url
  download_url=$(curl -s -H "Authorization: Bearer ${github_token}" "https://api.github.com/repos/${qlik_data_movement_gateway_organization}/${qlik_data_movement_gateway_repo}/contents/${qlik_data_movement_gateway_file}" | jq -r ".download_url" )
  curl -sLJ -o "${qlik_data_movement_gateway_file}" -H "Authorization: Bearer ${github_token}" "${download_url}"
}
