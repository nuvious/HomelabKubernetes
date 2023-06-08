#!/bin/bash
set -x
set -e
removal_playbooks=("microk8s-remove.yml" "k3s-remove.yml")
config_copy=(
    "/root/k8s-config"
    "/root/k3s-config"
)
post_install_delays=("5m" "5m" "15m")
deploy_playbooks=("microk8s-deploy.yml" "k3s-deploy.yml")
inventory_files=("hosts/x86-kube.yml" "hosts/rpi-kube.yml" "hosts/rpi-kube-tpi2.yml")

# First remove all clusters from all inventories
for playbook in ${removal_playbooks[@]}; do
    for inventory in ${inventory_files[@]}; do
        ansible-playbook -i $inventory $removal_playbooks
    done
done

for j in {0..2}; do
    inventory="${inventory_files[$j]}"
    post_install_delay="${post_install_delays[$j]}"
    for i in {0..1}; do
        ansible-playbook -i $inventory "${deploy_playbooks[$i]}"
        sudo bash -c "mv ${config_copy[$i]}  $HOME/.kube/config && chown $USER:$USER $HOME/.kube/config"
        sleep $post_install_delay

        set +e
        success=1
        for k in {0..10}; do
            if kubectl get nodes
            then
                success=0
                break
            else
                sleep $post_install_delay
            fi
        done
        set -e

        test $success -eq 0

        ansible-playbook -i $inventory "${removal_playbooks[$i]}"
    done
done
