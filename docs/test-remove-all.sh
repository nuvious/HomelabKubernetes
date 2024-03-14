#!/bin/bash
set -x
set -e
removal_playbooks=("k3s-remove.yml" "microk8s-remove.yml")
config_copy=("/root/k3s-config" "/root/k8s-config")
post_install_delays=("5m" "5m" "15m")
inventory_files=("hosts/x86-kube.yml" "hosts/rpi-kube.yml" "hosts/rpi-kube-tpi2.yml")
node_count=("3" "3" "4")

# First remove all clusters from all inventories
for playbook in ${removal_playbooks[@]}; do
    for inventory in ${inventory_files[@]}; do
        ansible-playbook -i $inventory $removal_playbooks
    done
done
