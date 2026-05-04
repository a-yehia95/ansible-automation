# ==============================================================================
# Project Structure and File Organization
# ==============================================================================

HA-Kubernetes-Ansible/
│
├── 📄 README.md                          # Main documentation (START HERE)
├── 📄 QUICK_REFERENCE.md                 # Common commands and troubleshooting
├── 📄 STRUCTURE.md                       # This file - Project organization
│
├── 🔧 ansible.cfg                        # Ansible configuration
├── 📋 requirements.yml                   # Collection dependencies
│
├── 📋 deploy-ha-k8s.yml                  # ⭐ Main deployment playbook (ENTRY POINT)
├── 📋 validate-cluster.yml               # Cluster validation playbook
│
├── 📁 inventory/                         # Ansible inventory
│   ├── 📄 hosts.ini                      # Host definitions (UPDATE THIS)
│   └── 📁 group_vars/
│       ├── 📄 all.yml                    # Global variables for all hosts
│       ├── 📄 masters.yml                # Variables for master nodes
│       ├── 📄 workers.yml                # Variables for worker nodes
│       └── 📄 loadbalancers.yml          # Variables for load balancers
│
├── 📁 roles/                             # Ansible roles (reusable task collections)
│
│   ├── 📁 common/                        # Phase 1: OS Preparation
│   │   ├── 📁 tasks/
│   │   │   ├── 📄 main.yml               # Main task orchestrator
│   │   │   ├── 📄 selinux.yml            # SELinux configuration
│   │   │   ├── 📄 sysctl.yml             # Kernel parameters
│   │   │   ├── 📄 swap.yml               # Disable swap
│   │   │   ├── 📄 firewall.yml           # Firewall rules
│   │   │   └── 📄 packages.yml            # Package installation
│   │   └── 📁 handlers/
│   │       └── 📄 main.yml               # Event handlers
│   │
│   ├── 📁 crio/                          # Phase 2: CRI-O Container Runtime
│   │   ├── 📁 tasks/
│   │   │   └── 📄 main.yml               # CRI-O installation
│   │   └── 📁 handlers/
│   │       └── 📄 main.yml               # Service restart handlers
│   │
│   ├── 📁 kubernetes/                    # Phase 3: Kubernetes Tools
│   │   ├── 📁 tasks/
│   │   │   └── 📄 main.yml               # kubeadm/kubelet/kubectl install
│   │   └── 📁 handlers/
│   │       └── 📄 main.yml               # Kubelet restart handlers
│   │
│   ├── 📁 loadbalancer/                  # Phase 4: HA Load Balancing
│   │   ├── 📁 tasks/
│   │   │   └── 📄 main.yml               # HAProxy + Keepalived setup
│   │   ├── 📁 templates/
│   │   │   ├── 📄 haproxy.cfg.j2         # HAProxy configuration template
│   │   │   └── 📄 keepalived.conf.j2     # Keepalived configuration template
│   │   └── 📁 handlers/
│   │       └── 📄 main.yml               # Service restart handlers
│   │
│   ├── 📁 kubeadm-init/                  # Phase 5: First Master Init
│   │   ├── 📁 tasks/
│   │   │   └── 📄 main.yml               # kubeadm init execution
│   │   └── 📁 templates/
│   │       ├── 📄 kubeadm-config.yaml.j2 # kubeadm configuration
│   │       └── 📄 calico-installation.yaml.j2  # Calico CNI config
│   │
│   ├── 📁 kubeadm-master-join/           # Phase 6: Additional Masters Join
│   │   └── 📁 tasks/
│   │       └── 📄 main.yml               # kubeadm join --control-plane
│   │
│   ├── 📁 kubeadm-worker-join/           # Phase 7: Workers Join
│   │   └── 📁 tasks/
│   │       └── 📄 main.yml               # kubeadm join for workers
│   │
│   └── 📁 calico/                        # Phase 8: Calico CNI (Optional)
│       └── 📁 tasks/
│           └── 📄 main.yml               # Calico deployment
│
└── 📁 docs/                              # Additional documentation (future)
    ├── 📄 TROUBLESHOOTING.md             # Common issues and solutions
    ├── 📄 NETWORKING.md                  # Network configuration details
    └── 📄 ADVANCED.md                    # Advanced topics

═══════════════════════════════════════════════════════════════════════════════

## Quick Start Path

1️⃣  Read: README.md (overview and architecture)
2️⃣  Edit: inventory/hosts.ini (update your node IPs)
3️⃣  Run: ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini
4️⃣  Verify: ansible-playbook validate-cluster.yml -i inventory/hosts.ini
5️⃣  Access: kubectl get nodes

═══════════════════════════════════════════════════════════════════════════════

## Deployment Phases

┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 0: Validation                   [deploy-ha-k8s.yml lines: 1-50]      │
│ ✓ Display deployment parameters                                             │
│ ✓ Verify DNS resolution                                                     │
│ ✓ Confirm infrastructure readiness                                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: Common OS Preparation        [common/ role]                       │
│ ✓ Update packages                                                           │
│ ✓ Configure SELinux (permissive)                                            │
│ ✓ Load kernel modules (br_netfilter, overlay)                              │
│ ✓ Configure sysctl (IP forwarding, etc.)                                   │
│ ✓ Disable swap                                                              │
│ ✓ Configure firewall (firewalld)                                           │
│ ✓ Setup time sync (chrony)                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 2: CRI-O Installation            [crio/ role]                         │
│ ✓ Install CRI-O container runtime                                           │
│ ✓ Configure systemd cgroup driver                                           │
│ ✓ Enable and start CRI-O service                                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 3: Kubernetes Tools             [kubernetes/ role]                    │
│ ✓ Add Kubernetes repository                                                 │
│ ✓ Install kubeadm, kubelet, kubectl                                         │
│ ✓ Configure kubelet systemd override                                        │
│ ✓ Enable kubelet service                                                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 4: Load Balancer Config         [loadbalancer/ role]                  │
│ ✓ Install HAProxy (API server load balancing)                               │
│ ✓ Install Keepalived (VIP failover)                                         │
│ ✓ Deploy HAProxy configuration (round-robin to 3 masters)                  │
│ ✓ Deploy Keepalived configuration (VRRP, priority-based)                   │
│ ✓ Open firewall ports                                                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 5: First Master Initialization  [kubeadm-init/ role]                 │
│ ✓ Create kubeadm configuration (with HA endpoint)                           │
│ ✓ Execute: kubeadm init --upload-certs                                     │
│ ✓ Extract certificate key (for other masters)                              │
│ ✓ Extract bootstrap token (for nodes)                                       │
│ ✓ Setup kubectl access for root user                                        │
│ ✓ Deploy Calico CNI                                                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 6: Additional Masters Join      [kubeadm-master-join/ role]          │
│ ✓ Retrieve join info from master01                                          │
│ ✓ Execute: kubeadm join --control-plane on master02, master03              │
│ ✓ Wait for nodes to become ready                                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 7: Worker Nodes Join            [kubeadm-worker-join/ role]          │
│ ✓ Retrieve join info from master01                                          │
│ ✓ Execute: kubeadm join on worker01, worker02                              │
│ ✓ Wait for nodes to become ready                                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                        ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│ PHASE 8: Cluster Verification         [deploy-ha-k8s.yml final tasks]     │
│ ✓ Verify all nodes ready                                                    │
│ ✓ Display cluster information                                               │
│ ✓ Display cluster health                                                    │
│ ✓ Print final summary and next steps                                        │
└─────────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════════

## Idempotency & Safety

✅ All playbooks are IDEMPOTENT - safe to run multiple times
✅ All playbooks use HANDLERS for service restarts
✅ All playbooks include ERROR HANDLING with rescue blocks
✅ All playbooks use CHANGED_WHEN for proper state detection
✅ Test with: --check (dry-run mode)

Example:
  ansible-playbook deploy-ha-k8s.yml -i inventory/hosts.ini --check

═══════════════════════════════════════════════════════════════════════════════

## Key Files to Understand

1. ansible.cfg
   └─ Global Ansible configuration (inventory path, SSH settings, logging)

2. inventory/hosts.ini
   └─ Host and group definitions (⭐ UPDATE THIS WITH YOUR SERVERS)

3. inventory/group_vars/*.yml
   └─ Variables for different groups of hosts

4. deploy-ha-k8s.yml
   └─ Main orchestration playbook (entry point)

5. roles/*/tasks/main.yml
   └─ Role main task files (the actual work)

6. roles/*/templates/*.j2
   └─ Jinja2 templates (configs generated during deployment)

═══════════════════════════════════════════════════════════════════════════════
