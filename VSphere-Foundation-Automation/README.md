# VMware vSphere Foundation Automation - Complete Guide

## 📋 Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Prerequisites](#prerequisites)
4. [Directory Structure](#directory-structure)
5. [Installation and Setup](#installation-and-setup)
6. [Configuration](#configuration)
7. [Execution](#execution)
8. [Use Cases](#use-cases)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)

---

## Project Overview

This Ansible project provides **production-ready automation** for managing the complete lifecycle of VMware vSphere Foundation environments using the **vmware.rest collection**.

### Key Features

✅ **Modular Architecture** - 8 specialized roles for different infrastructure layers
✅ **Day 0/1/2 Operations** - Complete foundation to administration lifecycle
✅ **vmware.rest Collection** - Modern REST API-based operations (no SSH to vCenter)
✅ **Vault Encryption** - Secure credential management
✅ **Idempotent Operations** - Safe to run multiple times
✅ **Comprehensive Logging** - Execution tracking and audit trails
✅ **Tag-based Execution** - Fine-grained control over operations
✅ **Multi-Environment Support** - Production, staging, development

---

## Architecture

### Deployment Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│ DAY 0: FOUNDATION - Infrastructure Setup                         │
├─────────────────────────────────────────────────────────────────┤
│ • Datacenter Creation                                            │
│ • Cluster Configuration (HA/DRS)                                 │
│ • ESXi Host Addition & Configuration                             │
│ • Datastore Management (VMFS/NFS)                                │
└─────────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│ DAY 1: PROVISIONING - VM and Network Setup                       │
├─────────────────────────────────────────────────────────────────┤
│ • Resource Pool Creation                                         │
│ • Distributed Virtual Switch (vDS) Configuration                 │
│ • Port Group Creation                                            │
│ • VM Cloning from Templates                                      │
│ • Hardware Configuration (CPU, Memory, Disks)                    │
│ • Network Interface Configuration                                │
└─────────────────────────────────────────────────────────────────┘
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│ DAY 2: ADMINISTRATION - Ongoing Management                       │
├─────────────────────────────────────────────────────────────────┤
│ • VM Lifecycle Management (Power, Update, Delete)                │
│ • Snapshot Management (Create, Revert, Delete)                   │
│ • VM Tagging                                                     │
│ • Resource Monitoring & Reporting                                │
│ • Maintenance & Updates                                          │
└─────────────────────────────────────────────────────────────────┘
```

### Role Hierarchy

```
vcenter_init (Foundation)
├── vcenter_init (vCenter connectivity)
└── day0/, day1/, day2/ operations

Day 0 Roles:
├── datacenter_config
├── cluster_management
├── esxi_host_management
└── datastore_management

Day 1 Roles:
├── resource_pool_management
├── network_config
└── vm_provisioning

Day 2 Roles:
├── vm_lifecycle
└── vm_snapshots
```

---

## Prerequisites

### Software Requirements

- **Ansible**: 2.13 or later
- **Python**: 3.8 or later
- **Collections**:
  - `vmware.rest >= 2.0.0`
  - `ansible.posix >= 1.5.0`
  - `community.general >= 7.0.0`

### VMware Requirements

- **vSphere**: 7.0 or later
- **vCenter**: Full administrative access
- **Network**: HTTP(S) connectivity to vCenter (port 443)

### System Requirements

- Linux/macOS/Windows (with WSL2) control node
- SSH access to ESXi hosts (optional, for advanced tasks)
- Adequate disk space for logs and fact caching

---

## Directory Structure

```
VSphere-Foundation-Automation/
├── ansible.cfg                              # Ansible configuration
├── requirements.yml                         # Galaxy collection dependencies
├── .gitignore                              # Git ignore rules
├── .vault_pass.example                     # Vault password template
│
├── playbooks/
│   ├── master.yml                          # Main orchestration playbook
│   ├── day0/
│   │   └── foundation.yml                  # Day 0 operations
│   ├── day1/
│   │   └── provision.yml                   # Day 1 operations
│   └── day2/
│       └── admin.yml                       # Day 2 operations
│
├── roles/
│   ├── vcenter_init/                       # vCenter initialization
│   │   ├── tasks/main.yml
│   │   ├── defaults/main.yml
│   │   └── handlers/
│   │
│   ├── datacenter_config/                  # Datacenter configuration
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   │
│   ├── cluster_management/                 # Cluster management
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   │
│   ├── esxi_host_management/               # ESXi host management
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   │
│   ├── datastore_management/               # Datastore management
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   │
│   ├── network_config/                     # Network configuration
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   │
│   ├── vm_provisioning/                    # VM provisioning
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   │
│   ├── resource_pool_management/           # Resource pool management
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   │
│   ├── vm_lifecycle/                       # VM lifecycle
│   │   ├── tasks/main.yml
│   │   └── defaults/main.yml
│   │
│   └── vm_snapshots/                       # VM snapshots
│       ├── tasks/main.yml
│       └── defaults/main.yml
│
├── inventory/
│   ├── hosts                               # Inventory file
│   ├── group_vars/
│   │   └── vcenter_servers/
│   │       ├── main.yml                    # vCenter configuration
│   │       └── vault.yml                   # Encrypted credentials
│   └── host_vars/
│
├── filter_plugins/                         # Custom Jinja2 filters
├── library/                                # Custom Ansible modules
│
├── docs/
│   ├── SETUP_GUIDE.md                      # Detailed setup guide
│   ├── EXAMPLES.md                         # Use case examples
│   └── TROUBLESHOOTING.md                  # Troubleshooting guide
│
└── logs/                                   # Execution logs (auto-created)
```

---

## Installation and Setup

### Step 1: Install Required Collections

```bash
# Install collections
ansible-galaxy collection install -r requirements.yml

# Verify installation
ansible-galaxy collection list | grep vmware
```

### Step 2: Set Up Ansible Vault

```bash
# Create vault password file
cp .vault_pass.example .vault_pass
# Edit with your secure password
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass

# Encrypt vault file
ansible-vault create inventory/group_vars/vcenter_servers/vault.yml
# Or edit existing:
ansible-vault edit inventory/group_vars/vcenter_servers/vault.yml
```

### Step 3: Configure Inventory

Edit `inventory/hosts` and update:

```yaml
[vcenter_servers]
vcenter01 ansible_host=vcenter.example.com ansible_user=administrator@vsphere.local
```

### Step 4: Configure vCenter Variables

Edit `inventory/group_vars/vcenter_servers/main.yml`:

```yaml
vcenter_hostname: "vcenter.example.com"
vcenter_port: 443
vcenter_username: "administrator@vsphere.local"
environment_name: "production"
datacenter_name: "Datacenter1"
cluster_name: "Cluster1"
```

### Step 5: Encrypt Credentials

Update `inventory/group_vars/vcenter_servers/vault.yml` with your credentials:

```yaml
vault_vcenter_password: "your-vcenter-password"
vault_esxi_password: "your-esxi-password"
```

---

## Configuration

### Main Configuration File

**File**: `inventory/group_vars/vcenter_servers/main.yml`

This file contains all operational configurations organized by lifecycle:

#### Day 0 Configuration

```yaml
day0_config:
  # Datacenter
  datacenter:
    name: "Datacenter1"
    description: "Production VMware vSphere Foundation"
    state: present

  # Clusters
  clusters:
    - name: "Cluster1"
      datacenter: "Datacenter1"
      ha_enabled: true
      drs_enabled: true
      drs_automation_level: "fullyAutomated"

  # Hosts
  hosts:
    - name: "esxi01.example.com"
      cluster: "Cluster1"
      username: "root"
      ntp_servers:
        - "ntp.example.com"

  # Datastores
  datastores:
    - name: "datastore-vmfs-01"
      datastore_type: "vmfs"
      datacenter: "Datacenter1"
```

#### Day 1 Configuration

```yaml
day1_config:
  # VM Templates
  vm_templates:
    - name: "Ubuntu-22.04-Template"
      cpu: 2
      memory_mb: 4096

  # Virtual Machines
  virtual_machines:
    - name: "webserver-01"
      template: "Ubuntu-22.04-Template"
      datacenter: "Datacenter1"
      cluster: "Cluster1"
      cpu: 4
      memory_mb: 8192
```

#### Day 2 Configuration

```yaml
day2_config:
  # Snapshot Policy
  snapshot_policy:
    enabled: true
    retention_days: 7
    frequency: "daily"

  # Maintenance Windows
  maintenance_windows:
    - name: "Monthly Patch Tuesday"
      day: "second_tuesday"
```

---

## Execution

### Basic Usage

#### Run Complete Lifecycle

```bash
# Run all days (0, 1, 2)
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass

# With verbose output
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  -v
```

#### Run Specific Day

```bash
# Day 0 only - Foundation
ansible-playbook playbooks/day0/foundation.yml \
  --vault-password-file .vault_pass

# Day 1 only - Provisioning
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass

# Day 2 only - Administration
ansible-playbook playbooks/day2/admin.yml \
  --vault-password-file .vault_pass
```

#### Run Specific Operations (Tags)

```bash
# Create datacenters only
ansible-playbook playbooks/master.yml \
  --tags datacenter_create \
  --vault-password-file .vault_pass

# Configure clusters with HA/DRS
ansible-playbook playbooks/master.yml \
  --tags cluster_config \
  --vault-password-file .vault_pass

# Provision VMs only
ansible-playbook playbooks/master.yml \
  --tags vm_clone,vm_power \
  --vault-password-file .vault_pass

# Create snapshots
ansible-playbook playbooks/master.yml \
  --tags snapshot_create \
  --vault-password-file .vault_pass
```

### Advanced Usage

#### Dry-Run (Check Mode)

```bash
# Preview changes without making them
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --check
```

#### Verbose Debugging

```bash
# Very verbose output for troubleshooting
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  -vvv
```

#### Limit to Specific Hosts

```bash
# Run only for specific vCenter
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  -i inventory/hosts \
  --limit vcenter01
```

### Environment Variables

```bash
# Set Ansible Vault password via environment
export ANSIBLE_VAULT_PASSWORD_FILE=./.vault_pass

# Then run without --vault-password-file:
ansible-playbook playbooks/master.yml
```

---

## Use Cases

### Use Case 1: New vSphere Foundation Deployment

**Objective**: Deploy a complete new vSphere environment

```bash
# 1. Run Day 0 - Create infrastructure
ansible-playbook playbooks/day0/foundation.yml \
  --vault-password-file .vault_pass

# 2. Run Day 1 - Provision VMs
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass

# 3. Verify in vSphere Client
```

### Use Case 2: Add Hosts to Existing Cluster

**Configuration in main.yml**:

```yaml
day0_config:
  hosts:
    - name: "esxi03.example.com"  # New host
      cluster: "Cluster1"
      username: "root"
```

**Execution**:

```bash
ansible-playbook playbooks/day0/foundation.yml \
  --tags host_add \
  --vault-password-file .vault_pass
```

### Use Case 3: Scale-Out VM Deployment

**Configuration in main.yml**:

```yaml
day1_config:
  virtual_machines:
    - name: "appserver-01"
      template: "CentOS-8-Template"
      cpu: 8
      memory_mb: 16384

    - name: "appserver-02"
      template: "CentOS-8-Template"
      cpu: 8
      memory_mb: 16384

    - name: "appserver-03"
      template: "CentOS-8-Template"
      cpu: 8
      memory_mb: 16384
```

**Execution**:

```bash
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass
```

### Use Case 4: Snapshot and Disaster Recovery

**Configuration in main.yml**:

```yaml
day2_config:
  snapshots_to_create:
    - vm_name: "webserver-01"
      snapshot_name: "pre-patch-snapshot"
      include_memory: false
      quiesce: true
```

**Execution**:

```bash
ansible-playbook playbooks/day2/admin.yml \
  --tags snapshot_create \
  --vault-password-file .vault_pass
```

---

## Troubleshooting

### Common Issues

#### 1. vCenter Connection Failure

**Error**:
```
Failed to connect to vCenter API
Status Code: N/A
```

**Solutions**:
- Verify vCenter hostname: `ping vcenter.example.com`
- Check vCenter is accessible: `curl -k https://vcenter.example.com/api/vcenter`
- Verify credentials in vault.yml
- Check firewall port 443 is open

**Debug Command**:
```bash
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --tags vcenter_init \
  -vvv
```

#### 2. Vault Password Issues

**Error**:
```
ERROR! Attempting to decrypt but no vault password supplied.
```

**Solutions**:
- Ensure .vault_pass file exists and contains password
- Use `--vault-password-file .vault_pass` flag
- Or set `export ANSIBLE_VAULT_PASSWORD_FILE=./.vault_pass`

#### 3. Collection Not Found

**Error**:
```
ERROR! couldn't resolve module/action 'vmware.rest.vcenter_vm_info'
```

**Solutions**:
```bash
# Install collections
ansible-galaxy collection install -r requirements.yml

# Verify installation
ansible-galaxy collection list
```

#### 4. Insufficient Permissions

**Error**:
```
Operation failed. Insufficient privileges.
```

**Solutions**:
- Verify vCenter user has Administrator role
- Check ESXi hosts allow vCenter user to manage hosts
- Verify firewall rules allow vCenter to ESXi communication

#### 5. Host Already Exists Error

**Error**:
```
The host is already a member of the cluster.
```

**Solutions**:
- Query existing hosts: `--tags host_query`
- Update inventory to skip already-added hosts
- Use `--check` mode to preview changes

### Debug Techniques

#### Enable Debug Output

```bash
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  -vvv 2>&1 | tee debug.log
```

#### Run Single Task

```bash
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --tags datacenter_query \
  -v
```

#### View Generated Variables

```bash
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --tags always \
  -v
```

### Check Logs

```bash
# View execution logs
ls -la logs/

# Check latest log
tail -f logs/ansible.log
```

---

## Best Practices

### 1. Inventory Management

✅ **DO**:
- Use meaningful host names
- Organize groups by environment (production, staging, dev)
- Use group_vars for common settings
- Use host_vars for host-specific settings

❌ **DON'T**:
- Hard-code credentials in playbooks
- Mix environments in same inventory
- Use generic host names like "host1"

### 2. Credential Management

✅ **DO**:
- Encrypt all sensitive data with Ansible Vault
- Use strong vault passwords (16+ characters)
- Store .vault_pass with restricted permissions (600)
- Rotate credentials regularly
- Store vault_pass in CI/CD secrets manager

❌ **DON'T**:
- Commit unencrypted credentials to git
- Share vault passwords in plain text
- Use same password for all environments
- Commit .vault_pass file to repository

### 3. Idempotency

✅ **DO**:
- Design playbooks to be idempotent
- Use appropriate state values (present/absent)
- Check for existing resources before creating
- Handle updates gracefully

❌ **DON'T**:
- Use raw shell commands without state checking
- Assume resources don't exist
- Force operations on already-configured resources

### 4. Error Handling

✅ **DO**:
- Use rescue/always blocks for cleanup
- Validate prerequisites before operations
- Log all significant events
- Provide meaningful error messages

❌ **DON'T**:
- Ignore failed tasks silently
- Skip validation steps
- Leave partial configurations on errors

### 5. Testing and Validation

✅ **DO**:
- Use `--check` mode before production runs
- Test in staging environment first
- Validate vCenter connectivity before operations
- Review log output after execution

❌ **DON'T**:
- Run directly in production without testing
- Skip check mode validation
- Deploy without snapshot backups
- Ignore warnings in output

### 6. Documentation

✅ **DO**:
- Document custom modifications
- Maintain change logs
- Document per-environment differences
- Add comments to complex plays

❌ **DON'T**:
- Leave configurations undocumented
- Modify without tracking changes
- Omit purpose of tasks/roles

### 7. Version Control

```bash
# Initialize git repository
git init
git add -A
git commit -m "Initial VMware vSphere Foundation Automation"

# Create branches per environment
git checkout -b production
git checkout -b staging
git checkout -b development
```

### 8. CI/CD Integration

Example GitLab CI configuration:

```yaml
# .gitlab-ci.yml
deploy_foundation:
  stage: deploy
  script:
    - ansible-playbook playbooks/day0/foundation.yml
      --vault-password-file $VAULT_PASS_FILE
  environment:
    name: production
  only:
    - main
```

---

## Support and Contribution

### Reporting Issues

When reporting issues, include:
- Ansible version: `ansible --version`
- vmware.rest version: `ansible-galaxy collection list`
- vSphere version
- Playbook tag or operation
- Error output (with sensitive data removed)
- Relevant logs

### Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -am 'Add feature'`
4. Push branch: `git push origin feature/my-feature`
5. Submit pull request

---

## License

This project is provided as-is for VMware vSphere automation.

---

## Appendix

### Useful vmware.rest Modules

- `vmware.rest.vcenter_host_info` - Query host information
- `vmware.rest.vcenter_vm_info` - Query VM information
- `vmware.rest.vcenter_cluster_info` - Query cluster information
- `vmware.rest.vcenter_datastore_info` - Query datastore information
- `vmware.rest.vcenter_vds_info` - Query vDS information

### Reference Documentation

- [vmware.rest Collection](https://docs.ansible.com/ansible/latest/collections/vmware/rest/)
- [vSphere REST API](https://vmware.github.io/vsphere-automation-sdk-rest/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

---

**Last Updated**: April 2026
**Version**: 1.0.0
**Status**: Production Ready
