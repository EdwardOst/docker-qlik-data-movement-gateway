organization="EdwardOst"
repo="qlik-releases"
file="qlik-data-gateway-data-movement.rpm"

download_url=$(curl -s -H "Authorization: Bearer ${token}" "https://api.github.com/repos/${organization}/${repo}/contents/${file}" | jq -r ".download_url" )
echo "debug: download_url=${download_url}"
curl -sLJ -o "${file}" -H "Authorization: Bearer ${token}" "${download_url}"

