# VMware Ansible - Project Structure Summary

## 📁 Complete Directory Tree

```
VMware-Ansible/
│
├── 📄 README.md                    # Main project documentation
├── 📄 master.yml                   # Master orchestration playbook
├── 📄 ansible.cfg                  # Ansible configuration
├── 📄 requirements.yml             # Ansible collection/role dependencies
├── 📄 requirements.txt             # Python package dependencies
├── 📄 setup.sh                     # Automated setup script
├── 📄 .gitignore                   # Git exclusions
├── 📄 .vault_pass.example          # Vault password template
│
├── 📂 inventory/
│   └── 📄 hosts                    # vCenter and infrastructure inventory
│
├── 📂 group_vars/
│   ├── 📄 vmware_infrastructure.yml        # Global VMware configuration
│   └── 📂 vmware_infrastructure/
│       └── 📄 vault.yml                    # Encrypted credentials (VAULT)
│
├── 📂 roles/
│   │
│   ├── 📂 foundation/              # Day 0: Infrastructure Foundation
│   │   │
│   │   ├── 📂 datacenter/          # Manage vSphere Datacenters
│   │   │   ├── 📂 tasks/
│   │   │   │   └── 📄 main.yml     # Create/manage datacenters
│   │   │   ├── 📂 vars/
│   │   │   │   └── 📄 main.yml     # Configuration state
│   │   │   ├── 📂 handlers/
│   │   │   │   └── 📄 main.yml     # Event handlers
│   │   │   └── 📂 templates/       # Jinja2 templates (if needed)
│   │   │
│   │   ├── 📂 cluster/             # Configure Clusters (DRS, HA)
│   │   │   ├── 📂 tasks/
│   │   │   │   └── 📄 main.yml     # Cluster setup, DRS, HA config
│   │   │   ├── 📂 vars/
│   │   │   │   └── 📄 main.yml     # DRS/HA settings
│   │   │   ├── 📂 handlers/
│   │   │   │   └── 📄 main.yml     # Cluster event handlers
│   │   │   └── 📂 templates/
│   │   │
│   │   ├── 📂 folders/             # VM Folder Hierarchy
│   │   │   ├── 📂 tasks/
│   │   │   │   └── 📄 main.yml     # Create folder structures
│   │   │   ├── 📂 vars/
│   │   │   │   └── 📄 main.yml     # Folder configuration
│   │   │   ├── 📂 handlers/
│   │   │   │   └── 📄 main.yml     # Folder event handlers
│   │   │   └── 📂 templates/
│   │   │
│   │   └── 📂 dvs/                 # Distributed Virtual Switches
│   │       ├── 📂 tasks/
│   │       │   └── 📄 main.yml     # Create DVS and port groups
│   │       ├── 📂 vars/
│   │       │   └── 📄 main.yml     # Network settings
│   │       ├── 📂 handlers/
│   │       │   └── 📄 main.yml     # Network event handlers
│   │       └── 📂 templates/       # DVS configurations
│   │           └── 📄 dvs.conf.j2  # DVS config template
│   │
│   ├── 📂 provisioning/            # Day 1: VM Provisioning
│   │   │
│   │   ├── 📂 vm_clone/            # Clone VMs from Templates
│   │   │   ├── 📂 tasks/
│   │   │   │   └── 📄 main.yml     # Clone logic + validation
│   │   │   ├── 📂 vars/
│   │   │   │   └── 📄 main.yml     # Clone defaults
│   │   │   ├── 📂 handlers/
│   │   │   │   └── 📄 main.yml     # Post-clone events
│   │   │   └── 📂 templates/
│   │   │
│   │   ├── 📂 customization/       # Guest OS Customization
│   │   │   ├── 📂 tasks/
│   │   │   │   └── 📄 main.yml     # IP, hostname, DNS config
│   │   │   ├── 📂 vars/
│   │   │   │   └── 📄 main.yml     # Customization defaults
│   │   │   ├── 📂 handlers/
│   │   │   │   └── 📄 main.yml     # Customization events
│   │   │   └── 📂 templates/
│   │   │       ├── 📄 linux_custom.j2   # Linux customization
│   │   │       └── 📄 windows_custom.j2 # Windows customization
│   │   │
│   │   └── 📂 hardware/            # Hardware Adjustments
│   │       ├── 📂 tasks/
│   │       │   └── 📄 main.yml     # CPU, RAM, disk adjustments
│   │       ├── 📂 vars/
│   │       │   └── 📄 main.yml     # Hardware defaults
│   │       ├── 📂 handlers/
│   │       │   └── 📄 main.yml     # Capacity recalc events
│   │       └── 📂 templates/
│   │
│   └── 📂 administration/          # Day 2: Operations & Administration
│       │
│       ├── 📂 snapshots/           # Snapshot Lifecycle
│       │   ├── 📂 tasks/
│       │   │   └── 📄 main.yml     # Create/remove/revert snapshots
│       │   ├── 📂 vars/
│       │   │   └── 📄 main.yml     # Retention policies
│       │   ├── 📂 handlers/
│       │   │   └── 📄 main.yml     # Storage update events
│       │   └── 📂 templates/
│       │
│       ├── 📂 power_management/    # VM Power Control
│       │   ├── 📂 tasks/
│       │   │   └── 📄 main.yml     # On/off/restart logic
│       │   ├── 📂 vars/
│       │   │   └── 📄 main.yml     # Power settings
│       │   ├── 📂 handlers/
│       │   │   └── 📄 main.yml     # State tracking events
│       │   └── 📂 templates/
│       │
│       ├── 📂 host_maintenance/    # Host Maintenance & vMotion
│       │   ├── 📂 tasks/
│       │   │   └── 📄 main.yml     # Maintenance mode + evacuation
│       │   ├── 📂 vars/
│       │   │   └── 📄 main.yml     # Timeout settings
│       │   ├── 📂 handlers/
│       │   │   └── 📄 main.yml     # vMotion tracking events
│       │   └── 📂 templates/
│       │
│       └── 📂 reporting/           # Infrastructure Reporting
│           ├── 📂 tasks/
│           │   └── 📄 main.yml     # Report generation
│           ├── 📂 vars/
│           │   └── 📄 main.yml     # Report format/location
│           ├── 📂 handlers/
│           │   └── 📄 main.yml     # Report archival events
│           └── 📂 templates/
│               ├── 📄 vm_report.j2
│               ├── 📄 host_report.j2
│               └── 📄 snapshot_report.j2
│
├── 📂 playbooks/                   # Main Orchestration Playbooks
│   │
│   ├── 📂 day0/                    # Day 0: Foundation Setup
│   │   └── 📄 foundation.yml       # Datacenter/Cluster/DVS orchestration
│   │
│   ├── 📂 day1/                    # Day 1: VM Provisioning
│   │   └── 📄 provision.yml        # Clone/Customize/Hardware orchestration
│   │
│   └── 📂 day2/                    # Day 2: Administration
│       └── 📄 admin.yml            # Snapshots/Power/Maintenance/Reports
│
├── 📂 library/                     # Custom Ansible Modules
│   └── [Custom VMware modules - optional]
│
├── 📂 filter_plugins/              # Custom Jinja2 Filters
│   └── [Custom filters - optional]
│
├── 📂 vault/                       # Vault-encrypted files
│   └── [Sensitive configuration files]
│
├── 📂 docs/                        # Documentation
│   ├── 📄 QUICK_START.md           # 5-minute setup guide
│   ├── 📄 EXAMPLES.md              # Scenario examples
│   ├── 📄 ARCHITECTURE.md          # Architecture & design patterns
│   └── 📄 PROJECT_STRUCTURE.md     # This file
│
├── 📂 logs/                        # Playbook execution logs
│   └── 📄 ansible.log              # Execution history
│
└── 📂 facts/                       # Ansible facts cache
    └── [Cached host facts]

```

## 📊 File Counts Summary

| Component | Count | Purpose |
|-----------|-------|---------|
| **Roles** | 10 | Modular infrastructure tasks |
| **Playbooks** | 4 | Day 0/1/2 orchestration + master |
| **Tasks** | 40+ | Individual automation steps |
| **Handlers** | 10 | Event-driven operations |
| **Variable Files** | 12 | Configuration management |
| **Documentation** | 5 | README, QUICK_START, EXAMPLES, ARCHITECTURE, PROJECT_STRUCTURE |
| **Config Files** | 4 | ansible.cfg, requirements.yml, requirements.txt, .gitignore |
| **Total YAML** | 50+ | Lines of production automation code: 5000+ |

## 🎯 Key Features by Location

### Security
- `group_vars/vmware_infrastructure/vault.yml` - Encrypted credentials
- `.vault_pass` - Vault password (one-per-environment)
- `ansible.cfg` - Vault configuration

### Configuration
- `group_vars/vmware_infrastructure.yml` - Global settings
- `inventory/hosts` - vCenter endpoint
- `roles/*/vars/main.yml` - Role-specific defaults

### Automation
- `playbooks/day0/foundation.yml` - Infrastructure setup
- `playbooks/day1/provision.yml` - VM deployment
- `playbooks/day2/admin.yml` - Operations management
- `master.yml` - Complete orchestration

### Documentation
- `README.md` - Comprehensive reference (800+ lines)
- `docs/QUICK_START.md` - 5-minute getting started
- `docs/EXAMPLES.md` - Real-world scenarios
- `docs/ARCHITECTURE.md` - Design patterns

## 🚀 Execution Flow

```
User runs playbook
    ↓
Ansible loads ansible.cfg
    ↓
Inventory resolved (inventory/hosts)
    ↓
Variables loaded (group_vars)
    ↓
Vault decrypted (.vault_pass → vault.yml)
    ↓
Playbook executed (day0/day1/day2)
    ↓
Roles applied in sequence
    ↓
Tasks executed with error handling
    ↓
Handlers triggered on changes
    ↓
Reports generated in /tmp/vmware_reports/
    ↓
Logs written to logs/ansible.log
```

## 💾 Data Flow

```
Input Variables
    ↓
Jinja2 Templates (roles/*/templates/)
    ↓
VMware Modules (community.vmware)
    ↓
vCenter API Calls
    ↓
vSphere Infrastructure Changes
    ↓
Fact Gathering (vmware_*_info modules)
    ↓
Report Generation (CSV, JSON, HTML)
    ↓
Output to /tmp/vmware_reports/
```

---

For navigation help:
- **Getting Started**: Read [README.md](../README.md)
- **Quick Setup**: Follow [QUICK_START.md](QUICK_START.md)
- **Examples**: Check [EXAMPLES.md](EXAMPLES.md)
- **Design**: Review [ARCHITECTURE.md](ARCHITECTURE.md)
