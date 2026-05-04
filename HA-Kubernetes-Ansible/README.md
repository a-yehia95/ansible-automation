# HA Kubernetes Cluster Deployment with Ansible

A production-grade Ansible automation solution for deploying a Highly Available Kubernetes cluster on RHEL 9.7 using kubeadm.

## 📋 Overview

This project provides a complete, modular Ansible-based solution to deploy a 3-Master + 2-Worker Kubernetes cluster with:

- **High Availability**: HAProxy + Keepalived for API Server load balancing
- **Container Runtime**: CRI-O (production-ready alternative to Docker)
- **CNI**: Calico for pod networking
- **Operating System**: RHEL 9.7 with security hardening
- **Best Practices**: Idempotent, error-handled, production-ready playbooks

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│           Kubernetes HA Cluster (RHEL 9.7)              │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Load Balancer Layer (HAProxy + Keepalived)      │   │
│  │  Virtual IP: {{ control_plane_vip }}                 │
│  │  Port: 6443 (Kubernetes API)                    │   │
│  └──────────────────────────────────────────────────┘   │
│                      ▲                                    │
│         ┌────────────┼────────────┐                      │
│         │            │            │                      │
│    ┌────▼─┐      ┌───▼──┐     ┌──▼───┐                  │
│    │Master│      │Master│     │Master│                  │
│    │ 01   │      │  02  │     │ 03   │                  │
│    │10.0. │      │10.0. │     │10.0. │                  │
│    │0.101 │      │0.102 │     │0.103 │                  │
│    └──────┘      └──────┘     └──────┘                  │
│       etcd cluster (3 nodes)                             │
│                                                           │
│    ┌──────────┐              ┌──────────┐              │
│    │ Worker01 │              │ Worker02 │              │
│    │10.0.0.201│              │10.0.0.202│              │
│    └──────────┘              └──────────┘              │
│                                                           │
│    Pod Network: {{ pod_network_cidr }}                    │
│    Service Network: {{ service_network_cidr }}            │
│    CNI: Calico (VXLAN)                                 │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## 📦 Directory Structure

```
HA-Kubernetes-Ansible/
├── ansible.cfg                         # Ansible configuration
├── requirements.yml                    # Collections requirements
├── deploy-ha-k8s.yml                  # Main deployment playbook
├── inventory/
│   ├── hosts.ini                       # Inventory (hosts/groups)
│   └── group_vars/
│       ├── all.yml                     # Global variables
│       ├── masters.yml                 # Master node variables
│       ├── workers.yml                 # Worker node variables
│       └── loadbalancers.yml           # Load balancer variables
├── roles/
│   ├── common/                         # OS preparation & hardening
│   │   ├── tasks/
│   │   │   ├── main.yml
│   │   │   ├── selinux.yml
│   │   │   ├── sysctl.yml
│   │   │   ├── swap.yml
│   │   │   ├── firewall.yml
│   │   │   └── packages.yml
│   │   └── handlers/
│   ├── loadbalancer/                   # HAProxy + Keepalived
│   │   ├── tasks/main.yml
│   │   ├── templates/
│   │   │   ├── haproxy.cfg.j2
│   │   │   └── keepalived.conf.j2
│   │   └── handlers/main.yml
│   ├── crio/                           # CRI-O container runtime
│   │   ├── tasks/main.yml
│   │   └── handlers/main.yml
│   ├── kubernetes/                     # kubeadm, kubelet, kubectl
│   │   ├── tasks/main.yml
│   │   └── handlers/main.yml
│   ├── kubeadm-init/                   # First master initialization
│   │   ├── tasks/main.yml
│   │   └── templates/
│   │       ├── kubeadm-config.yaml.j2
│   │       └── calico-installation.yaml.j2
│   ├── kubeadm-master-join/            # Additional masters join
│   │   └── tasks/main.yml
│   ├── kubeadm-worker-join/            # Worker nodes join
│   │   └── tasks/main.yml
│   └── calico/                         # Calico CNI (optional)
│       └── tasks/main.yml
├── docs/                               # Documentation
│   ├── TROUBLESHOOTING.md
│   ├── NETWORKING.md
│   └── ADVANCED.md
└── README.md                           # This file
```

## 🚀 Quick Start

### Prerequisites

- **Control Machine**: Ansible 2.12+ installed
- **Target Nodes**: 
  - RHEL 9.7 minimal installation
  - SSH access to all nodes (root preferred)
  - Network connectivity between all nodes
  - At least 2 CPU cores and 2GB RAM per node

### Installation Steps

#### 1. Prepare Inventory

Edit `inventory/hosts.ini` and update:
- Master node IPs (10.0.0.101, 10.0.0.102, 10.0.0.103)
- Worker node IPs (10.0.0.201, 10.0.0.202)
- Control plane VIP (10.0.0.100)
- Ansible credentials

```bash
# Example:
[masters]
master01 ansible_host=10.0.0.101
master02 ansible_host=10.0.0.102
master03 ansible_host=10.0.0.103

[workers]
worker01 ansible_host=10.0.0.201
worker02 ansible_host=10.0.0.202
```

#### 2. Install Collections

```bash
ansible-galaxy install -r requirements.yml
```

#### 3. Deploy Cluster

```bash
# Full deployment
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini

# Deploy specific phase (e.g., Phase 1 - Common preparation)
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags phase1

# Dry run (check mode)
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --check
```

#### 4. Verify Deployment

```bash
# SSH into any master node
ssh root@master01

# Check cluster status
kubectl get nodes
kubectl get pods -A
kubectl cluster-info
```

## 📝 Deployment Phases

### Phase 1: Common OS Preparation
- Update packages and install dependencies
- Configure SELinux (permissive mode)
- Load kernel modules (br_netfilter, overlay)
- Configure sysctl parameters (IP forwarding, net.bridge settings)
- Disable swap
- Configure firewall (firewalld) with Kubernetes ports
- Set up time synchronization (chrony)

### Phase 2: CRI-O Installation
- Install CRI-O container runtime
- Configure systemd cgroups driver
- Enable and start CRI-O service

### Phase 3: Kubernetes Tools Installation
- Add Kubernetes package repository
- Install kubeadm, kubelet, kubectl
- Configure kubelet for systemd cgroups

### Phase 4: Load Balancer Configuration
- Install HAProxy (load balancing)
- Install Keepalived (virtual IP failover)
- Deploy HAProxy configuration (round-robin to 3 masters)
- Deploy Keepalived configuration (priority-based VRRP)
- Open firewall ports for HAProxy/Keepalived

### Phase 5: First Master Initialization
- Create kubeadm configuration (with HA endpoint)
- Run `kubeadm init` on master01
- Extract certificate key and join tokens
- Set up kubectl access
- Deploy Calico CNI

### Phase 6: Additional Masters Join
- Retrieve join information from master01
- Run `kubeadm join --control-plane` on master02 and master03
- Set up kubectl access on additional masters

### Phase 7: Worker Nodes Join
- Retrieve join information from master01
- Run `kubeadm join` on worker nodes
- Wait for nodes to become ready

### Phase 8: Cluster Verification
- Verify all nodes are ready
- Display cluster information and health status

## 🔐 Security Considerations

- SELinux set to permissive (can be changed to enforcing after testing)
- Firewall restricted to Kubernetes ports
- Swap disabled (Kubernetes requirement)
- Network policies can be deployed separately
- RBAC enabled by default
- Pod Security Policies can be configured in group_vars

## 📊 Variables Reference

### Global Variables (all.yml)
- `kubernetes_version`: Version of Kubernetes to deploy (default: 1.28.0)
- `crio_version`: CRI-O version (default: 1.28.0)
- `cluster_name`: Name of the cluster (default: ha-k8s-cluster)
- `pod_network_cidr`: Pod network CIDR (default: 10.244.0.0/16)
- `service_network_cidr`: Service network CIDR (default: 10.96.0.0/12)
- `control_plane_vip`: Virtual IP for HA (default: 10.0.0.100)

### Master Variables (masters.yml)
- `keepalived_priority`: Priority for VRRP election (master01: 100, master02: 90, master03: 80)

### Load Balancer Variables (loadbalancers.yml)
- `haproxy_listen_port`: HAProxy listen port (default: 6443)
- `haproxy_timeout_connect`: Connection timeout (default: 5000ms)

## 🧪 Testing & Verification

### Test Deployment Connectivity
```bash
# Ping all nodes
ansible all -i inventory/hosts.ini -m ping

# Check Ansible facts
ansible all -i inventory/hosts.ini -m setup -a "filter=ansible_os_family"
```

### Test Kubernetes Cluster
```bash
# On any master node
kubectl get nodes -o wide
kubectl get pods -A
kubectl get services -A
kubectl get componentstatuses

# Deploy test pod
kubectl run test-pod --image=nginx --restart=Never
kubectl get pods
kubectl delete pod test-pod
```

### Load Balancer Health Check
```bash
# On load balancer nodes
systemctl status haproxy
systemctl status keepalived
ip addr show  # Check VIP assignment
curl -k https://10.0.0.100:6443/version  # Test API
```

## 🐛 Troubleshooting

### Node Not Ready
```bash
# Check kubelet logs
journalctl -u kubelet -f

# Check node events
kubectl describe node <node-name>

# Restart kubelet
systemctl restart kubelet
```

### VIP Not Responding
```bash
# Check Keepalived status
systemctl status keepalived
journalctl -u keepalived -f

# Verify VIP assignment
ip addr show
ping 10.0.0.100
```

### Calico Pods Not Running
```bash
# Check operator status
kubectl get pods -n tigera-operator

# Check Calico logs
kubectl logs -n calico-system -l k8s-app=calico-node

# Verify networking
kubectl get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")]}'
```

## 🔄 Idempotency & Replayability

All playbooks are designed to be idempotent. Running the same playbook multiple times should:
- Not make changes on already configured systems
- Report `changed: false` for unchanged tasks
- Be safe to re-run without data loss

```bash
# Safe to run multiple times
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini
```

## 📚 Advanced Topics

### Upgrade Kubernetes Version
Edit `group_vars/all.yml` and update `kubernetes_version`:
```yaml
kubernetes_version: 1.29.0  # Update to new version
```

Then run:
```bash
# Upgrade will happen on next playbook run (not implemented yet)
# Manual steps required per node
```

### Add New Worker Node
1. Add node to `[workers]` group in inventory
2. Run Phase 3 and Phase 7:
```bash
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags "phase3,phase7"
```

### Custom Network Configuration
Edit `group_vars/all.yml`:
```yaml
pod_network_cidr: 172.16.0.0/16      # Change pod CIDR
service_network_cidr: 172.30.0.0/16  # Change service CIDR
```

## 🤝 Contributing

Improvements and bug reports are welcome. Please ensure:
- Playbooks remain idempotent
- Changes are tested on RHEL 9.7
- Code follows Ansible best practices

## 📄 License

This project is provided as-is for educational and production use.

## 🆘 Support

For issues and questions:
1. Check `docs/TROUBLESHOOTING.md`
2. Review Kubernetes documentation: https://kubernetes.io/docs/
3. Review kubeadm documentation: https://kubernetes.io/docs/reference/setup-tools/kubeadm/

---

**Last Updated**: May 2, 2026  
**Tested on**: RHEL 9.7 (Plow)  
**Kubernetes Version**: 1.28.0+  
**Ansible Version**: 2.12+
