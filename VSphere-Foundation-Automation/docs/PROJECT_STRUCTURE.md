# Project Structure Documentation

## Directory Overview

```
VSphere-Foundation-Automation/
```

### Root Level Files

| File | Purpose |
|------|---------|
| `ansible.cfg` | Ansible configuration settings |
| `requirements.yml` | Galaxy collection dependencies |
| `.gitignore` | Git ignore patterns |
| `.vault_pass.example` | Vault password template |
| `README.md` | Main documentation (this file) |

### Playbooks Directory

**Location**: `playbooks/`

#### Master Playbook

- **File**: `master.yml`
- **Purpose**: Orchestrates entire lifecycle (Day 0 → Day 1 → Day 2)
- **Entry Point**: Main execution playbook
- **Usage**: `ansible-playbook playbooks/master.yml`

#### Day 0 Playbook

- **File**: `playbooks/day0/foundation.yml`
- **Purpose**: Infrastructure foundation creation
- **Includes Roles**:
  - vcenter_init
  - datacenter_config
  - cluster_management
  - esxi_host_management
  - datastore_management

#### Day 1 Playbook

- **File**: `playbooks/day1/provision.yml`
- **Purpose**: VM and network provisioning
- **Includes Roles**:
  - resource_pool_management
  - network_config
  - vm_provisioning

#### Day 2 Playbook

- **File**: `playbooks/day2/admin.yml`
- **Purpose**: Ongoing VM administration
- **Includes Roles**:
  - vm_lifecycle
  - vm_snapshots

### Roles Directory

**Location**: `roles/`

Each role follows standard Ansible structure with:
- `tasks/main.yml` - Role tasks
- `defaults/main.yml` - Default variables
- `vars/` - Role-specific variables
- `handlers/` - Event handlers
- `templates/` - Jinja2 templates
- `files/` - Static files

#### Role Descriptions

| Role | Purpose | Tags |
|------|---------|------|
| `vcenter_init` | Validate vCenter connectivity | vcenter_init, init |
| `datacenter_config` | Create datacenters | datacenter_config, day0 |
| `cluster_management` | Create & configure clusters | cluster_management, day0 |
| `esxi_host_management` | Add & manage ESXi hosts | esxi_host_management, day0 |
| `datastore_management` | Configure datastores | datastore_management, day0 |
| `resource_pool_management` | Create resource pools | resource_pool_management, day1 |
| `network_config` | Configure vDS & port groups | network_config, day1 |
| `vm_provisioning` | Clone & configure VMs | vm_provisioning, day1 |
| `vm_lifecycle` | Manage VM power & updates | vm_lifecycle, day2 |
| `vm_snapshots` | Manage VM snapshots | vm_snapshots, day2 |

### Inventory Directory

**Location**: `inventory/`

```
inventory/
├── hosts                              # Static inventory file
├── group_vars/
│   └── vcenter_servers/
│       ├── main.yml                  # Main configuration (DAY 0/1/2)
│       └── vault.yml                 # Encrypted credentials
└── host_vars/
    └── vcenter01/
        └── config.yml                # Host-specific config (optional)
```

#### hosts File

Defines inventory groups:
- `[vcenter_servers]` - vCenter hosts
- `[day0_operations]` - Hosts for Day 0
- `[day1_operations]` - Hosts for Day 1
- `[day2_operations]` - Hosts for Day 2
- `[production]` - Production environment
- `[staging]` - Staging environment
- `[development]` - Development environment

#### group_vars/vcenter_servers/main.yml

Master configuration file containing:
- **vCenter Connection Settings**
  - vcenter_hostname
  - vcenter_port
  - vcenter_username
  - vcenter_validate_certs

- **Day 0 Configuration** (day0_config)
  - Datacenters
  - Clusters (HA/DRS)
  - ESXi Hosts
  - Datastores (VMFS/NFS)
  - Resource Pools

- **Day 1 Configuration** (day1_config)
  - VM Templates
  - Virtual Machines (to provision)
  - Network configuration

- **Day 2 Configuration** (day2_config)
  - Snapshot policies
  - Maintenance windows
  - Monitoring settings
  - Tags & categories

- **Network Configuration**
  - vDistributed Switches (vDS)
  - Port Groups
  - VLANs

- **Security & Compliance**
  - Audit logging
  - Encryption settings
  - Backup configuration

#### group_vars/vcenter_servers/vault.yml

Encrypted file containing sensitive data:
- `vault_vcenter_password` - vCenter credentials
- `vault_esxi_password` - ESXi host credentials
- `vault_nfs_username` - NFS credentials (optional)
- `vault_db_password` - Database credentials (optional)

### Plugins Directory

**Location**: `filter_plugins/`

Custom Jinja2 filters for:
- Data transformation
- Formatting
- Calculations
- Validation

### Library Directory

**Location**: `library/`

Custom Ansible modules for:
- Advanced operations
- Third-party integrations
- Custom logic

### Documentation Directory

**Location**: `docs/`

Additional documentation:
- `SETUP_GUIDE.md` - Detailed setup instructions
- `EXAMPLES.md` - Use case examples
- `TROUBLESHOOTING.md` - Common issues and solutions
- `ARCHITECTURE.md` - Detailed architecture guide

### Logs Directory

**Location**: `logs/` (auto-created)

Contains:
- `ansible.log` - Main execution log
- `execution_*.log` - Per-execution logs
- `execution_report_*.html` - HTML execution reports

---

## Configuration Files Explanation

### ansible.cfg

Controls Ansible behavior:
- Inventory location
- Roles path
- Plugin locations
- SSH settings
- Connection timeouts
- Logging level

### requirements.yml

Specifies Galaxy collections to install:
- `vmware.rest` - VMware REST API collection (REQUIRED)
- `ansible.posix` - POSIX utilities
- `community.general` - General utilities
- `ansible.utils` - Utilities collection

Install with:
```bash
ansible-galaxy collection install -r requirements.yml
```

### .gitignore

Prevents sensitive files from being committed:
- `vault_pass` - Vault password file
- `*.retry` - Ansible retry files
- `inventory/group_vars/*/vault.yml` - Vault files
- `logs/` - Execution logs
- `.vscode/` - IDE settings
- `__pycache__/` - Python cache

---

## File Size and Scope

### Code Statistics

| Component | Files | Lines | Purpose |
|-----------|-------|-------|---------|
| Playbooks | 4 | ~150 | Orchestration |
| Roles | 10 | ~1500 | Task implementation |
| Inventory | 3 | ~600 | Configuration |
| Config | 3 | ~150 | Settings |
| Docs | 1 | ~1000 | Documentation |
| **Total** | **21** | **~3400** | **Complete project** |

---

## Variable Precedence

Variables are resolved in this order (highest to lowest):
1. Command-line variables (`-e`)
2. Play variables
3. Task variables
4. `group_vars/vcenter_servers/vault.yml` (encrypted)
5. `group_vars/vcenter_servers/main.yml`
6. Role defaults (`roles/*/defaults/main.yml`)
7. Ansible defaults

---

## Tagging Strategy

### Available Tags

**By Day**:
- `day0` - Day 0 operations
- `day1` - Day 1 operations
- `day2` - Day 2 operations

**By Operation**:
- `foundation` - Infrastructure foundation
- `provisioning` - VM provisioning
- `administration` - VM management

**By Role**:
- `vcenter_init` - vCenter initialization
- `datacenter_config` - Datacenter configuration
- `cluster_management` - Cluster management
- etc.

**By Function**:
- `*_query` - Information gathering
- `*_create` - Resource creation
- `*_update` - Resource updates
- `*_delete` - Resource deletion

### Tag Usage Examples

```bash
# Run all Day 0 operations
ansible-playbook master.yml --tags day0

# Run only cluster creation
ansible-playbook master.yml --tags cluster_create

# Skip snapshot operations
ansible-playbook master.yml --skip-tags snapshot_delete
```

---

## Environment-Specific Configurations

### Multiple Environments

Create separate group_vars for each environment:

```
inventory/group_vars/
├── vcenter_servers/
│   ├── main.yml              # Base configuration
│   └── vault.yml             # Base credentials
├── production/
│   ├── main.yml              # Production overrides
│   └── vault.yml             # Production credentials
├── staging/
│   ├── main.yml              # Staging overrides
│   └── vault.yml             # Staging credentials
└── development/
    ├── main.yml              # Development overrides
    └── vault.yml             # Development credentials
```

Usage:
```bash
# Run against production
ansible-playbook master.yml -i inventory/hosts --limit production

# Run against staging
ansible-playbook master.yml -i inventory/hosts --limit staging
```

---

## Execution Flow

1. **Pre-tasks**: Display context
2. **vcenter_init role**: Validate connectivity
3. **Day 0 operations**: Foundation (if tagged)
4. **Day 1 operations**: Provisioning (if tagged)
5. **Day 2 operations**: Administration (if tagged)
6. **Post-tasks**: Summary and reporting

---

## Extension Points

### Adding Custom Roles

1. Create new role directory: `roles/my_custom_role/`
2. Add tasks/main.yml with tasks
3. Add defaults/main.yml with variables
4. Include in playbook: `- include_role: name: my_custom_role`

### Adding Custom Filters

1. Create file: `filter_plugins/my_filters.py`
2. Define filter functions
3. Use in templates: `{{ value | my_filter }}`

### Adding Custom Modules

1. Create file: `library/my_module.py`
2. Implement module logic
3. Use in plays: `my_module: param1=value1`

---

## Summary

This project structure provides:
- ✅ Clear separation of concerns
- ✅ Scalable architecture
- ✅ Secure credential management
- ✅ Comprehensive documentation
- ✅ Production-ready code
- ✅ Easy customization and extension
