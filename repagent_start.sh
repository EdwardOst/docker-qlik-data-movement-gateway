#!/usr/bin/env bash

#shellcheck disable=SC2164
cd ~
if [ ! -f "registration.txt" ]; then
  /opt/qlik/gateway/movement/bin/agentctl qcs get_registration | tee registration.txt
fi

/opt/qlik/gateway/movement/bin/repagent start
while :
do
  sleep 600
done

