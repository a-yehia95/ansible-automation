# 📚 HA Kubernetes Cluster - Complete Index

## 🗂️ Navigation Guide

This is your complete reference for navigating the HA Kubernetes Ansible project.

---

## 📖 Documentation (Start Here!)

| Document | Purpose | Audience | Time |
|----------|---------|----------|------|
| [README.md](README.md) | Complete guide with architecture, deployment steps, and FAQ | Everyone | 15 min |
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | Overview of what was built and quick start | Project Managers | 5 min |
| [STRUCTURE.md](STRUCTURE.md) | File organization, phase diagrams, and project layout | Developers | 10 min |
| [QUICK_REFERENCE.md](QUICK_REFERENCE.md) | Common commands, troubleshooting, cheat sheet | Operators | 5 min |
| [INDEX.md](INDEX.md) | This file - Navigation guide | Everyone | 5 min |

---

## 🎯 Deployment Quick Path

### For First-Time Users
1. **Read**: [README.md](README.md) - Understand architecture (15 min)
2. **Edit**: `inventory/hosts.ini` - Configure your servers (10 min)
3. **Run**: `ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini` (30 min)
4. **Verify**: `ansible-playbook validate-cluster.yml -i inventory/hosts.ini` (5 min)
5. **Reference**: [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Next steps

### For Experienced Users
```bash
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini
# That's it! 8 phases run automatically
```

---

## 🔧 Configuration Files

### Essential Files (Must Update)
| File | Purpose | Action |
|------|---------|--------|
| `inventory/hosts.ini` | Define your cluster nodes | ⚠️ **UPDATE WITH YOUR SERVERS** |
| `inventory/group_vars/all.yml` | Kubernetes version, CIDR ranges | Review defaults (optional edit) |

### Important Files (Review)
| File | Purpose |
|------|---------|
| `ansible.cfg` | Ansible configuration |
| `requirements.yml` | Ansible collection dependencies |

### Generated/Template Files
| File | Purpose |
|------|---------|
| `roles/loadbalancer/templates/haproxy.cfg.j2` | HAProxy configuration template |
| `roles/loadbalancer/templates/keepalived.conf.j2` | Keepalived VRRP template |
| `roles/kubeadm-init/templates/kubeadm-config.yaml.j2` | kubeadm cluster config template |

---

## 🎭 Playbooks

### Main Playbooks

#### `deploy-ha-k8s.yml` ⭐ (Primary Entry Point)
**Purpose**: Complete HA Kubernetes cluster deployment  
**Usage**: `ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini`  
**Phases**: 8 (Validation → Init → Masters → Workers → Verification)  
**Duration**: ~30-45 minutes  
**Lines**: 300+  

Runs through all phases:
1. Phase 0: Validation
2. Phase 1: Common OS preparation
3. Phase 2: CRI-O runtime
4. Phase 3: Kubernetes tools
5. Phase 4: Load balancer
6. Phase 5: First master init
7. Phase 6: Master join
8. Phase 7: Worker join
9. Phase 8: Verification

#### `validate-cluster.yml`
**Purpose**: Verify cluster health and readiness  
**Usage**: `ansible-playbook validate-cluster.yml -i inventory/hosts.ini`  
**Duration**: ~2-3 minutes  

Checks:
- All nodes are ready
- All critical pods running
- Services available
- Calico CNI status
- Component status

---

## 👥 Roles Directory

### By Phase

| Phase | Role | Directory | Purpose |
|-------|------|-----------|---------|
| 1 | `common` | `roles/common/` | OS preparation & hardening |
| 2 | `crio` | `roles/crio/` | Container runtime setup |
| 3 | `kubernetes` | `roles/kubernetes/` | Install k8s tools |
| 4 | `loadbalancer` | `roles/loadbalancer/` | HAProxy + Keepalived HA |
| 5 | `kubeadm-init` | `roles/kubeadm-init/` | First master initialization |
| 6 | `kubeadm-master-join` | `roles/kubeadm-master-join/` | Additional masters join |
| 7 | `kubeadm-worker-join` | `roles/kubeadm-worker-join/` | Worker nodes join |
| 8 | `calico` | `roles/calico/` | CNI deployment (optional) |

### By Function

#### Infrastructure Setup
- `common` - OS preparation
- `loadbalancer` - HA load balancing

#### Runtime Setup
- `crio` - Container runtime
- `kubernetes` - Kubernetes tools

#### Cluster Bootstrapping
- `kubeadm-init` - Initialize cluster
- `kubeadm-master-join` - Add control plane nodes
- `kubeadm-worker-join` - Add data plane nodes
- `calico` - Network plugin

---

## 📁 Inventory Structure

### Host Groups
```
all
├── masters (3 nodes)
│   ├── master01
│   ├── master02
│   └── master03
├── workers (2 nodes)
│   ├── worker01
│   └── worker02
└── loadbalancers (runs on masters)
    ├── master01
    ├── master02
    └── master03

Special Groups:
├── k8s_nodes (all Kubernetes nodes)
├── k8s_masters (same as masters)
├── k8s_workers (same as workers)
├── master_init (master01 - for initialization)
└── masters_join (master02, master03 - for joining)
```

### Variables by Group

| Group | Variables File | Contents |
|-------|------------------|----------|
| all | `group_vars/all.yml` | Kubernetes version, CIDR, DNS, etc. |
| masters | `group_vars/masters.yml` | Master node roles, taints, kubelet labels |
| workers | `group_vars/workers.yml` | Worker node configuration |
| loadbalancers | `group_vars/loadbalancers.yml` | HAProxy, Keepalived settings |

---

## 🚀 Common Tasks

### Deploy the Cluster
```bash
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini
```

### Deploy Specific Phase
```bash
# Phase 1 only
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags phase1

# Multiple phases
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --tags phase1,phase2
```

### Dry-run (Check Mode)
```bash
ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --check
```

### Validate Cluster
```bash
ansible-playbook validate-cluster.yml -i inventory/hosts.ini
```

### Test Node Connectivity
```bash
ansible all -i inventory/hosts.ini -m ping
```

### Run Command on Specific Group
```bash
ansible masters -i inventory/hosts.ini -m command -a "kubectl get nodes"
ansible workers -i inventory/hosts.ini -m systemd -a "name=kubelet"
```

---

## 🔍 Key Files Explained

### `ansible.cfg`
```ini
[defaults]
inventory = inventory/hosts.ini    # Where hosts are defined
roles_path = roles/                # Where roles are stored
host_key_checking = False          # Don't verify SSH keys
gathering = smart                  # Gather facts efficiently
fact_caching = jsonfile            # Cache facts for performance
log_path = logs/ansible.log        # Where to log
```

### `inventory/hosts.ini`
```ini
[masters]
master01 ansible_host=10.0.0.101   # Node name and IP

[workers]
worker01 ansible_host=10.0.0.201   # Worker node IP

[all:vars]
kubernetes_version=1.28.0           # Global variables
control_plane_vip=10.0.0.100
```

### `inventory/group_vars/all.yml`
```yaml
# Global settings for all hosts
kubernetes_version: 1.28.0
pod_network_cidr: 10.244.0.0/16
service_network_cidr: 10.96.0.0/12
control_plane_vip: 10.0.0.100
```

---

## 📚 Role Structure

Each role follows this structure:
```
roles/<role-name>/
├── tasks/
│   ├── main.yml              # Primary task file
│   └── *.yml                 # Optional: split tasks
├── templates/
│   └── *.j2                  # Jinja2 configuration templates
├── handlers/
│   └── main.yml              # Service restart handlers
├── defaults/
│   └── main.yml              # Role default variables (optional)
└── vars/
    └── main.yml              # Role-specific variables (optional)
```

---

## 🎯 Understanding the Deployment Flow

```
User runs: ansible-playbook deploy-ha-k8s.yml
    ↓
ansible.cfg loads (inventory, roles path, etc.)
    ↓
inventory/hosts.ini loads (node definitions)
    ↓
group_vars/*.yml loads (variables for each group)
    ↓
Play 1: Phase 0 Validation (masters[0])
    ↓
Play 2: Phase 1 Common (k8s_nodes)
    ├─ calls role: common
    ├─ tasks/selinux.yml, sysctl.yml, swap.yml, etc.
    ↓
Play 3: Phase 2 CRI-O (k8s_nodes)
    ├─ calls role: crio
    ├─ tasks/main.yml
    ↓
Play 4: Phase 3 Kubernetes (k8s_nodes)
    ├─ calls role: kubernetes
    ├─ tasks/main.yml
    ↓
Play 5: Phase 4 LoadBalancer (loadbalancers)
    ├─ calls role: loadbalancer
    ├─ Deploy haproxy.cfg.j2 template
    ├─ Deploy keepalived.conf.j2 template
    ↓
Play 6: Phase 5 Master Init (master_init = master01)
    ├─ calls role: kubeadm-init
    ├─ Deploy kubeadm-config.yaml.j2 template
    ├─ kubeadm init
    ├─ Extract cert key and join tokens (saved in hostvars)
    ↓
Play 7: Phase 6 Master Join (masters_join = master02, master03)
    ├─ calls role: kubeadm-master-join
    ├─ Retrieve cert key from hostvars['master01']
    ├─ kubeadm join --control-plane
    ↓
Play 8: Phase 7 Worker Join (workers)
    ├─ calls role: kubeadm-worker-join
    ├─ Retrieve token from hostvars['master01']
    ├─ kubeadm join
    ↓
Play 9: Phase 8 Verification
    ├─ kubectl cluster-info
    ├─ kubectl get nodes
    ├─ Display final summary
```

---

## 🆘 Where to Find Help

| Issue | Solution |
|-------|----------|
| "How do I deploy?" | → [README.md - Quick Start](README.md#-quick-start) |
| "What was created?" | → [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) |
| "How is it organized?" | → [STRUCTURE.md](STRUCTURE.md) |
| "What's the command?" | → [QUICK_REFERENCE.md](QUICK_REFERENCE.md) |
| "Node not ready" | → [QUICK_REFERENCE.md - Troubleshooting](QUICK_REFERENCE.md) |
| "How do I customize?" | → [README.md - Advanced Topics](README.md#-advanced-topics) |
| "What variables can I change?" | → [README.md - Variables Reference](README.md#-variables-reference) |

---

## 📊 Project Statistics

- **Total Lines of Code**: 3000+
- **Playbooks**: 2
- **Roles**: 8
- **Task Files**: 12+
- **Handlers**: 6+
- **Templates**: 3
- **Documentation**: 5 files
- **Configuration Files**: 7

---

## ✅ Checklist for Getting Started

- [ ] Read README.md (understand architecture)
- [ ] Review inventory/hosts.ini (understand node layout)
- [ ] Edit inventory/hosts.ini (add your server IPs)
- [ ] Run: `ansible-galaxy install -r requirements.yml`
- [ ] Run: `ansible all -i inventory/hosts.ini -m ping` (test connectivity)
- [ ] Run: `ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --check` (dry-run)
- [ ] Run: `ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini` (deploy!)
- [ ] Run: `ansible-playbook validate-cluster.yml -i inventory/hosts.ini` (verify)
- [ ] SSH to master01: `ssh root@master01`
- [ ] Check cluster: `kubectl get nodes`
- [ ] Celebrate! 🎉

---

## 🎓 Learning Path

### Beginner
1. Read README.md
2. Understand inventory structure
3. Review group_vars
4. Run deployment
5. Check cluster status

### Intermediate
1. Understand role structure
2. Review individual task files
3. Modify variables
4. Run specific phases
5. Deploy to different environment

### Advanced
1. Customize roles
2. Add new roles
3. Integrate with CI/CD
4. Deploy with GitOps
5. Contribute improvements

---

## 📞 Support Reference

| Topic | File | Section |
|-------|------|---------|
| Architecture | README.md | Overview |
| Installation | README.md | Quick Start |
| Variables | README.md | Variables Reference |
| Troubleshooting | QUICK_REFERENCE.md | Troubleshooting |
| Commands | QUICK_REFERENCE.md | Common Ansible Commands |
| Organization | STRUCTURE.md | Project Structure |
| Summary | PROJECT_SUMMARY.md | Features & Statistics |

---

**Last Updated**: May 2, 2026  
**Project**: HA Kubernetes Cluster Ansible Automation  
**Status**: ✅ Production Ready  

🚀 **Ready to deploy? Start with [README.md](README.md)!**
