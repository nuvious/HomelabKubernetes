#!/bin/bash
set -x
fail_count=0
removal_playbooks=("k3s-remove.yml" "microk8s-remove.yml")
config_copy=("/root/k3s-config" "/root/k8s-config")
post_install_delays=("5m" "5m" "15m")
deploy_playbooks=("k3s-deploy.yml" "microk8s-deploy.yml")
inventory_files=("hosts/x86-kube.yml" "hosts/rpi-kube.yml" "hosts/rpi-kube-tpi2.yml")
node_count=("3" "3" "4")

# First remove all clusters from all inventories
for playbook in ${removal_playbooks[@]}; do
    for inventory in ${inventory_files[@]}; do
        ansible-playbook -i $inventory $removal_playbooks
    done
done

for j in {0..2}; do
    inventory="${inventory_files[$j]}"
    post_install_delay="${post_install_delays[$j]}"
    node_count="${node_count[$j]}"
    for i in {0..1}; do
        ansible-playbook -i $inventory "${deploy_playbooks[$i]}"
        sudo bash -c "mv ${config_copy[$i]}  $HOME/.kube/config && chown $USER:$USER $HOME/.kube/config"
        sleep $post_install_delay

        success=1
        for k in {0..10}; do
            if [ `kubectl get nodes | grep Ready | wc -l`  -eq "$node_count" ]
            then
                success=0
                break
            else
                sleep $post_install_delay
            fi
        done
        fail_count=$((fail_count+success))
        sleep $post_install_delay
        ansible-playbook -i $inventory "${removal_playbooks[$i]}"
    done
done

echo "Test completed with $fail_count failures."
