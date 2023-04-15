# K3S and K8S Deployment Playbooks

This is just a set of ansible playbooks for deploying either k3s or k8s to
x86/amd64 or amd64 hosts.

## Pre-Requisites

- Kubectl
  - Install per official documentation [here](https://kubernetes.io/docs/tasks/tools/).
- Ansible
  - Install per official documentation [here](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
- Target Hosts
  - Must have a target user with sudo access
  - (Strongly Recommended) SSH keys onboarded to target user on target hosts

## K3S on x86/amd64

### Modify Hosts

These playbooks use the group names server and agent to distinguish between
server and agent nodes in the cluster. Create these groups in
`/etc/ansible/hosts` [per ansible documentation](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
or copy and rename hosts/example.yml and update accordingly. Here's an example:

```yaml
all:
  hosts:
    kube00:
      ansible_host: 192.168.1.60
      ansible_ssh_private_key_file: /home/k3s/.ssh/id_rsa
      ansible_user: k3s
    kube01:
      ansible_host: 192.168.1.61
      ansible_ssh_private_key_file: /home/k3s/.ssh/id_rsa
      ansible_user: k3s
    kube02:
      ansible_host: 192.168.1.62
      ansible_ssh_private_key_file: /home/k3s/.ssh/id_rsa
      ansible_user: k3s

server:
  hosts:
    kube00:

agent:
  hosts:
    kube01:
    kube02:

```

### Deploy

```bash
ansible-playbook -i hosts/example.yml k3s-deploy.yml
mkdir -p ~/.kube
mv ~/.kube/config ~/.kube/config_backup # If you have an existing kube config
sudo bash -c "mv /root/k3s-config $HOME/.kube/config && chown $USER:$USER $HOME/.kube/config"
```

You should be able to run `kubectl get nodes` to see your nodes after this

```bash
$ kubectl get nodes
NAME                   STATUS   ROLES                  AGE   VERSION
kube00   Ready    control-plane,master   45s   v1.25.5+k3s2
kube02   Ready    <none>                 25s   v1.25.5+k3s2
kube01   Ready    <none>                 22s   v1.25.5+k3s2
```

### Remove

```bash
ansible-playbook -i hosts/example.yml k3s-remove.yml
```

## K8S on x86/amd64

### Modify Hosts

These playbooks use the group names server and agent to distinguish between
server and agent nodes in the cluster. Create these groups in
`/etc/ansible/hosts` [per ansible documentation](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html)
or copy and rename hosts/example.yml and update accordingly. Here's an example:

```yaml
all:
  hosts:
    kube00:
      ansible_host: 192.168.1.60
      ansible_ssh_private_key_file: /home/k8s/.ssh/id_rsa
      ansible_user: k8s
    kube01:
      ansible_host: 192.168.1.61
      ansible_ssh_private_key_file: /home/k8s/.ssh/id_rsa
      ansible_user: k8s
    kube02:
      ansible_host: 192.168.1.62
      ansible_ssh_private_key_file: /home/k8s/.ssh/id_rsa
      ansible_user: k8s

server:
  hosts:
    kube00:

agent:
  hosts:
    kube01:
    kube02:

```

### Deploy

```bash
ansible-playbook -i hosts/example.yml k8s-deploy.yml
mkdir -p ~/.kube
mv ~/.kube/config ~/.kube/config_backup # If you have an existing kube config
sudo bash -c "mv /root/k8s-config $HOME/.kube/config && chown $USER:$USER $HOME/.kube/config"
```

You should be able to run `kubectl get nodes` to see your nodes after this:

```bash
$ kubectl get nodes
NAME                   STATUS   ROLES    AGE     VERSION
kube00.bearden.local   Ready    <none>   5m41s   v1.26.0
kube02.bearden.local   Ready    <none>   3m23s   v1.26.0
kube01.bearden.local   Ready    <none>   3m3s    v1.26.0
```

### Remove

```bash
ansible-playbook -i hosts/example.yml k8s-remove.yml
```

## Other Useful Playbooks Included

### Update Playbook

Just a simple playbook to update debian based distributions. Example usage:

```bash
# Will execute against 'all' in inventory
ansible-playbook -i hosts/hosts_file.yml site_update.yml

# Will execute against a specific group in inventory
ansible-playbook -i hosts/hosts_file.yml --extra-vars "hosts=creality" site_update.yml
```

## Misc Notes for Contributors

### File Structure

File structure derrived from the recommended
[Directory Layout](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html#directory-layout)
documentation from [Ansible Best Practices](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_best_practices.html#best-practices).
