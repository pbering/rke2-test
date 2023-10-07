#!/bin/bash
set -euxo pipefail

# set default editor
export EDITOR=nano

# ensure internet is reachable
serverAdr="github.com"

ping -c 1 $serverAdr > /dev/null 2>&1

while [ $? -ne 0 ]; do
  echo -e "\e[1A\e[K checking connection to ${serverAdr}..."
  sleep 1
  ping -c 1 $serverAdr > /dev/null 2>&1
done

echo "${serverAdr} reachable!"