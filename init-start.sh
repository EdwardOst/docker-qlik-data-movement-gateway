#!/usr/bin/env bash

set -euo pipefail

declare -r qlik_tenant="${QLIK_TENANT}"
declare -r qlik_package="${QLIK_PACKAGE}"

if [ ! -f "registration.txt" ]; then
  QLIK_CUSTOMER_AGREEMENT_ACCEPT=yes verbose=true debug=true rpm -ivh "${qlik_package}"
  cd /opt/qlik/gateway/movement/bin
  ./agentctl qcs set_config --tenant_url "${qlik_tenant}.us.qlikcloud.com"
  cd /opt/qlik/gateway/movement/drivers/bin
  ./install mysql -a
  ./install postgres -a
  ./install snowflake -a
  /opt/qlik/gateway/movement/bin/agentctl qcs get_registration | tee registration.txt
  systemctl enable repagent
  systemctl start repagent
fi

#/opt/qlik/gateway/movement/bin/repagent start
#while :
#do
#  sleep 600
#done

