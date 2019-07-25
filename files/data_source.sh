#!/bin/bash
set -eu -o pipefail


eval "$(jq -r '@sh "export ssh_user=\(.ssh_user) ssh_key=\(.ssh_key) ssh_pass=\(.ssh_pass) bootstrap_node_ip=\(.bootstrap_node_ip) fe_details=\(.fe_details)"')"

ssh-keyscan -H ${bootstrap_node_ip} >> ~/.ssh/known_hosts 2>/dev/null

if [[ ! -z "${ssh_key}" ]]; then
  ssh -i ${ssh_key} ${ssh_user}@${bootstrap_node_ip} "sudo cat ${fe_details} | jq '.'"
else
  if ! hash sshpass; then
    echo "must install sshpass"
    exit 1
  else
    sshpass -p ${ssh_pass} ssh ${ssh_user}@${bootstrap_node_ip} "sudo cat ${fe_details} | jq '.'"
  fi
fi
