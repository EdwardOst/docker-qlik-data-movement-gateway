#!/usr/bin/env bash

qlik_data_movement_gateway_script_path=$(readlink -e "${BASH_SOURCE[0]}")
# shellcheck disable=SC2034
qlik_data_movement_gateway_script_dir="${qlik_data_movement_gateway_script_path%/*}"

# shellcheck source=qlik_data_movement_gateway_config.sh
source "${qlik_data_movement_gateway_script_dir}/qlik_data_movement_gateway_config.sh"

qlik_data_movement_gateway_download() {
  local token
  case "${1}" in
    -t=*|--token=*)
      token="${1#*=}"
      shift  1
      ;;
  esac
  local -r github_token="${token:-${github_token}}"
  [ -z "${github_token}" ] && qlik_data_movement_gateway_download_usage && return 1

  local -r download_url=$(curl -s -H "Authorization: Bearer ${github_token}" "https://api.github.com/repos/${qlik_data_movement_gateway_organization}/${qlik_data_movement_gateway_repo}/contents/releases/${qlik_data_movement_gateway_package_version}/${qlik_data_movement_gateway_package}" | jq -r ".download_url" )
  echo "download_url=${download_url}"
  curl -sLJ -o "${qlik_data_movement_gateway_package}" -H "Authorization: Bearer ${github_token}" "${download_url}"

  if [ $# -gt 0 ]; then
    local result=0
    case $1 in
      config | download | build | setup | shell | server | start | stop)
        set -- qlik_data_movement_gateway_"$1" "${@:2}"
        "$@"
        result=$?
      ;;
      *)
        docker exec "${qlik_data_movement_gateway_container_name}" "${@}"
        result=1
    esac
    return ${result}
  else
    return 0
  fi

}


qlik_data_movement_gateway_download_usage() {
  printf "Usage: qlik_data_movement_gateway config download [-t | --token]=<github token>\nGithub token required.\n"
}
