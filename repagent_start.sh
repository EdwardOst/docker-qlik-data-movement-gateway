#!/usr/bin/env bash

cd ~
if [ -f "registration.txt" ]; then
  /opt/qlik/gateway/movement/bin/repagent start
  while :
  do
    sleep 600
  done
else
  /opt/qlik/gateway/movement/bin/agentctl qcs get_registration > registration.txt
  echo "You must use the key below to register the data movement gateway in the lik Cloud before re-starting this container."
  cat registration.txt
fi

