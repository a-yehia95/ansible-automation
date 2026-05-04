---
# ==============================================================================
# Quick Reference - Common Ansible Commands
# ==============================================================================

## Initial Deployment
# Full cluster deployment (all phases)
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini

# Dry-run (no changes, just preview)
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --check

# Deploy specific phase
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags phase1
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags phase5

# Deploy specific role
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags common
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags loadbalancer

## Validation
# Validate cluster deployment
ansible-playbook validate-cluster.yml -i inventory/hosts.ini

# Test connectivity
ansible all -i inventory/hosts.ini -m ping

# Gather facts from all nodes
ansible all -i inventory/hosts.ini -m setup -a "filter=ansible_os_family"

## Troubleshooting
# Run command on specific host
ansible masters -i inventory/hosts.ini -m command -a "kubectl get nodes"

# Check systemd service status
ansible masters -i inventory/hosts.ini -m systemd -a "name=kubelet state=started"

# Tail kubelet logs
ansible masters[0] -i inventory/hosts.ini -m command -a "journalctl -u kubelet -f"

# Check firewall rules
ansible loadbalancers -i inventory/hosts.ini -m command -a "firewall-cmd --list-all"

## Maintenance
# Restart kubelet on all nodes
ansible k8s_nodes -i inventory/hosts.ini -m service -a "name=kubelet state=restarted"

# Update cluster (change kubernetes_version in group_vars/all.yml first)
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags phase3

## SSH Direct Access
# SSH into first master
ssh root@master01

# SSH into specific worker
ssh root@worker01

# Copy file to nodes
scp file.txt root@master01:/tmp/

# Get kubeconfig (from controller machine)
scp root@master01:/etc/kubernetes/admin.conf ./kubeconfig

## kubectl Commands (run on any master node)
# Check cluster status
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A

# Monitor pod/node status
kubectl get pods -A -w
kubectl top nodes
kubectl top pods -A

# Describe problematic resources
kubectl describe node <node-name>
kubectl describe pod <pod-name> -n <namespace>

# View logs
kubectl logs -n <namespace> <pod-name>
kubectl logs -n <namespace> <pod-name> -c <container> -f

# Get kubeconfig for external use
kubectl config view --raw > kubeconfig
