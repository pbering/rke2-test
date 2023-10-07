#!/bin/bash
set -euxo pipefail

rke2_version="${1}"
rke2_token="${2}"
rke2_server="${3}"

# create rke2 config
install -d -m 755 /etc/rancher/rke2
install /dev/null -m 600 /etc/rancher/rke2/config.yaml
cat >>/etc/rancher/rke2/config.yaml <<EOF
server: $rke2_server
token: $rke2_token
EOF

# install rke2 agent
export INSTALL_RKE2_VERSION="$rke2_version"
export INSTALL_RKE2_TYPE="agent"
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-agent.service
systemctl start rke2-agent.service
