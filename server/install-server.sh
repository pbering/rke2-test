#!/bin/bash
set -euxo pipefail

rke2_command="$1"
rke2_version="$2"
rke2_token="$3"
rke2_server="$4"

# create rke2 config
install -d -m 755 /etc/rancher/rke2
install /dev/null -m 600 /etc/rancher/rke2/config.yaml

if [ "$rke2_command" != 'cluster-init' ]; then
  cat >>/etc/rancher/rke2/config.yaml <<EOF
server: $rke2_server
token: $rke2_token
EOF
fi
  cat >>/etc/rancher/rke2/config.yaml <<EOF
write-kubeconfig-mode: '0644'
tls-san:
 - server.$(hostname --domain)
 - $(hostname --fqdn)
cni: calico
token: $rke2_token
EOF

# install rke2 server
export INSTALL_RKE2_VERSION="$rke2_version"
export INSTALL_RKE2_TYPE="server"
curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service
systemctl start rke2-server.service

# symlink utilities and setup the environment variables to use them
ln -fs /var/lib/rancher/rke2/bin/{kubectl,crictl,ctr} /usr/local/bin/
cat >/etc/profile.d/01-rke2.sh <<'EOF'
export CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock
export CONTAINERD_NAMESPACE=k8s.io
export CRI_CONFIG_FILE=/var/lib/rancher/rke2/agent/etc/crictl.yaml
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
EOF
source /etc/profile.d/01-rke2.sh

# wait for this node to be ready.
$SHELL -c 'node_name=$(hostname); echo "waiting for node $node_name to be ready..."; while [ -z "$(kubectl get nodes $node_name | grep -E "$node_name\s+Ready\s+")" ]; do sleep 3; done; echo "node ready!"'

# wait for kube-dns to be running.
$SHELL -c 'echo "waiting for kube-dns to be running"; while [ -z "$(kubectl get pods --selector k8s-app=kube-dns --namespace kube-system | grep -E "\s+Running\s+")" ]; do sleep 3; done; echo "kube-dns running!"'

# show info
kubectl get nodes -o wide
kubectl get pods -A -o wide