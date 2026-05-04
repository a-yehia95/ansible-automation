# Storage Automation - Enterprise Storage Lifecycle Management

## 📋 Overview

This Ansible Automation Platform (AAP) repository provides **production-grade automation** for managing the complete lifecycle of enterprise storage arrays using industry-leading solutions:

- **Pure Storage FlashArray** (using `purestorage.flasharray` collection v1.18.0+)
- **Dell PowerStore** (using `dellemc.powerstore` collection v2.1.0+)

### Three-Lifecycle Model

```
┌─────────────────────────────────────────────────────────┐
│                  Storage Automation Lifecycle            │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  Day 1: Provisioning                                    │
│  ├─ Register ESXi/Linux host on array                   │
│  ├─ Create storage volumes/LUNs                         │
│  └─ Map volumes to hosts                                │
│                                                           │
│  Day 2: Operations                                       │
│  ├─ Create crash-consistent snapshots                   │
│  └─ Expand volumes (non-disruptive)                     │
│                                                           │
│  Day N: Decommissioning                                  │
│  ├─ Unmap volumes from hosts                            │
│  └─ Delete/Destroy volumes                              │
│     (Pure: destroy + eradicate)                         │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- Ansible Automation Platform (AAP 2.1+) with Execution Environment
- Python 3.7+
- Network access to storage arrays
- API tokens/credentials for storage arrays

### Installation (1 minute)

```bash
# 1. Install collections
ansible-galaxy install -r requirements.yml

# 2. Create vault file with credentials
ansible-vault create group_vars/vault.yml
# (Copy contents from group_vars/vault.yml.example and edit)

# 3. Update inventory with array IPs
vim inventory/hosts

# 4. Verify connectivity (optional)
ansible-inventory -i inventory/hosts --graph
```

### Usage Examples

#### Pure Storage - Day 1: Provision Volume

```bash
ansible-playbook pure_storage/playbooks/day1/provision.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars='
    volume_name=db-volume-01 \
    volume_size_gb=500 \
    host_iqn=iqn.1991-05.com.example:esx01 \
    host_name=esx-01'
```

#### Pure Storage - Day 2: Create Snapshot & Expand

```bash
# Create snapshot
ansible-playbook pure_storage/playbooks/day2/operations.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars='volume_name=db-volume-01 operation=snapshot'

# Expand volume
ansible-playbook pure_storage/playbooks/day2/operations.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars='volume_name=db-volume-01 operation=expand new_size_gb=1000'
```

#### Pure Storage - Day N: Decommission

```bash
ansible-playbook pure_storage/playbooks/dayN/decommission.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars='
    volume_name=db-volume-01 \
    host_name=esx-01 \
    confirm_decommission=yes \
    eradicate=yes'
```

#### Dell PowerStore - Day 1: Provision LUN

```bash
ansible-playbook dell_powerstore/playbooks/day1/provision.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars='
    lun_name=db-lun-01 \
    lun_size_mb=512000 \
    host_iqn=iqn.1991-05.com.example:esx01 \
    host_name=esx-01 \
    host_protocol=iSCSI'
```

#### Dell PowerStore - Day 2: Operations

```bash
# Create snapshot
ansible-playbook dell_powerstore/playbooks/day2/operations.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars='lun_name=db-lun-01 operation=snapshot'

# Expand LUN
ansible-playbook dell_powerstore/playbooks/day2/operations.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars='lun_name=db-lun-01 operation=expand new_size_mb=1048576'
```

#### Dell PowerStore - Day N: Decommission

```bash
ansible-playbook dell_powerstore/playbooks/dayN/decommission.yml \
  --vault-password-file ~/.vault_pass \
  --extra-vars='
    lun_name=db-lun-01 \
    host_name=esx-01 \
    confirm_decommission=yes'
```

---

## 📁 Project Structure

```
Storage-Automation/
├── ansible.cfg                    # Ansible platform configuration
├── requirements.yml               # Collections & dependencies
├── inventory/
│   └── hosts                      # Storage array inventory
├── group_vars/
│   ├── pure_storage_flasharray.yml
│   ├── dell_powerstore.yml
│   ├── vault.yml.example          # Credential template
│   └── vault.yml                  # Encrypted credentials (vault)
├── pure_storage/
│   └── playbooks/
│       ├── day1/provision.yml     # Host registration, volume creation, mapping
│       ├── day2/operations.yml    # Snapshots, volume expansion
│       └── dayN/decommission.yml  # Unmap, destroy, eradicate
├── dell_powerstore/
│   └── playbooks/
│       ├── day1/provision.yml     # Host registration, LUN creation, mapping
│       ├── day2/operations.yml    # Snapshots, LUN expansion
│       └── dayN/decommission.yml  # Unmap, delete
└── docs/                          # Additional documentation
```

---

## 🔐 Security & Credential Management

### Vault-Based Encryption

All sensitive credentials are encrypted using Ansible Vault:

```bash
# Create encrypted vault file
ansible-vault create group_vars/vault.yml

# Edit existing vault file
ansible-vault edit group_vars/vault.yml

# View vault contents (read-only)
ansible-vault view group_vars/vault.yml
```

### Vault Password Management

Create a password file (one per environment):

```bash
# Create vault password file
echo "your-vault-password" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Use in playbooks
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

### No-Log Protection

All tasks handling credentials use `no_log: true` to prevent logging sensitive data:

```yaml
- name: Create volume
  purestorage.flasharray.purefa_volume:
    api_token: "{{ pure_api_token }}"  # Never logged
    ...
  no_log: true  # Prevents credential exposure
```

---

## 🎯 Idempotency & Best Practices

### Idempotent Design

All playbooks are designed for safe repeated execution:

```
First Run:   Resources created → CHANGED=True
Second Run:  Resources exist → CHANGED=False
Third Run:   Resources exist → CHANGED=False
```

### Example: Volume Creation

```yaml
# Checking existing resources before creation ensures idempotency
- name: Check if volume exists
  purestorage.flasharray.purefa_volume_info:
    name: "{{ volume_name }}"
  register: volume_exists
  failed_when: false

- name: Create volume if not exists
  purestorage.flasharray.purefa_volume:
    name: "{{ volume_name }}"
    state: present
  when: volume_exists.failed  # Only create if volume doesn't exist
```

### Robust Error Handling

All playbooks implement comprehensive error handling:

```yaml
- name: Provision storage
  block:
    # Normal task execution
    - name: Create volume
      purestorage.flasharray.purefa_volume:
        ...

  rescue:
    # Error handling
    - name: Handle failure
      debug:
        msg: "Creation failed - diagnostic information"

  always:
    # Cleanup/logging
    - name: Log operation
      debug:
        msg: "Operation completed"
```

### Pre-Flight Validation

All playbooks validate required variables before execution:

```yaml
- name: Validate required variables
  assert:
    that:
      - volume_name is defined
      - volume_size_gb | int > 0
    fail_msg: "Missing required variables"
    success_msg: "All variables validated"
```

---

## 📊 Collection Versions & Requirements

### Required Collections

| Collection | Version | Purpose |
|-----------|---------|---------|
| `purestorage.flasharray` | >=1.18.0 | Pure Storage FlashArray management |
| `dellemc.powerstore` | >=2.1.0 | Dell PowerStore management |
| `community.general` | >=7.0.0 | General utilities |
| `ansible.builtin` | >=2.12.0 | Built-in modules |

### Installation

```bash
ansible-galaxy install -r requirements.yml

# Verify installation
ansible-galaxy collection list | grep -E 'purestorage\|dellemc'
```

---

## 🏗️ Architecture & Design

### Connection Model

All playbooks use `connection: local` for direct API communication:

```yaml
- name: Provision storage
  hosts: pure_storage_flasharray
  connection: local  # Runs on AAP controller, not SSH
  
  tasks:
    - name: Create volume
      purestorage.flasharray.purefa_volume:
        fa_url: "https://{{ inventory_hostname }}"  # API URL
        api_token: "{{ pure_api_token }}"           # Direct API auth
```

**Benefits:**
- No SSH required to storage arrays
- Faster API communication
- Credentials managed locally
- Support for self-signed SSL certificates

### Host/Volume Registration Flow

#### Pure Storage FlashArray

```
Host Registration
    ↓ (Register ESXi IQN)
Volume Creation
    ↓ (Create LUN on array)
Volume Mapping
    ↓ (Map LUN to registered host)
Host Discovery
    ↓ (ESXi automatically discovers LUN via iSCSI)
Ready for Use
```

#### Dell PowerStore

```
Host Creation
    ↓ (Register ESXi initiators)
LUN Creation
    ↓ (Create volume with thin/thick provisioning)
LUN Mapping
    ↓ (Add LUN to host mapping)
Host Discovery
    ↓ (ESXi automatically discovers LUN)
Ready for Use
```

---

## 📋 Variable Reference

### Pure Storage Variables

```yaml
# Authentication
pure_api_token: "token-from-vault"

# Array Information
pure_fb_url: "https://flasharray.example.com"
pure_api_version: "2.19"
validate_certs: false

# Host Configuration
pure_host_protocol: "iscsi"        # iscsi, fc, nvme
pure_host_personality: "linux"     # linux, vms, esx, etc.

# Volume Defaults
pure_volume_defaults:
  size_gb: 100
  overwrite: false
  thin_provisioning: true
  eradicate: false

# Snapshot Defaults
pure_snapshot_defaults:
  suffix: "-snap"
  eradicate: false
```

### Dell PowerStore Variables

```yaml
# Authentication
powerstore_rest_api_username: "admin"
powerstore_rest_api_password: "password-from-vault"

# Array Information
powerstore_rest_api_gateway: "192.168.1.100"
powerstore_rest_api_port: 443
powerstore_verify_ssl_certificate: false

# Host Configuration
powerstore_host_protocol: "iSCSI"  # iSCSI, FC, NVMe
powerstore_host_os_type: "Linux"   # Linux, Windows, ESXi

# Volume Defaults
powerstore_volume_defaults:
  size_mb: 102400
  provisioning_type: "thin"        # thin or thick
  description: "Created via Ansible"

# Snapshot Defaults
powerstore_snapshot_defaults:
  description: "Snapshot created via Ansible"
  expiration_time: null
```

---

## 🔍 Troubleshooting

### Issue: "Module not found" error

**Solution:** Install collections

```bash
ansible-galaxy install -r requirements.yml
```

### Issue: "API token authentication failed"

**Solution:** Verify vault credentials

```bash
# Check vault file is encrypted
file group_vars/vault.yml
# Should show: encrypted

# Verify password file
ls -la ~/.vault_pass

# Test playbook with verbose output
ansible-playbook playbook.yml -vvv --vault-password-file ~/.vault_pass
```

### Issue: "Volume already exists" but not in our system

**Solution:** Playbook is idempotent - this is expected

```
First run:   Volume created (CHANGED=True)
Second run:  Volume exists, skip creation (CHANGED=False)
```

### Issue: SSL certificate verification failures

**Solution:** Disable certificate verification for self-signed certs

```yaml
# In group_vars or playbook
validate_certs: false          # Pure Storage
powerstore_verify_ssl_certificate: false  # PowerStore
```

### Issue: Host not found when mapping volumes

**Solution:** Verify host registration completed first

```bash
# Check Pure Storage hosts
ansible-playbook pure_storage/playbooks/day1/provision.yml -vvv \
  --vault-password-file ~/.vault_pass
```

---

## 🎓 Advanced Usage

### Batch Operations

Provision multiple volumes in parallel:

```bash
for i in {1..5}; do
  ansible-playbook pure_storage/playbooks/day1/provision.yml \
    --vault-password-file ~/.vault_pass \
    --extra-vars="volume_name=web-vol-$i volume_size_gb=100" &
done
wait
```

### Multi-Array Operations

Deploy across multiple storage arrays:

```bash
# Provision on array1
ansible-playbook pure_storage/playbooks/day1/provision.yml \
  -i inventory/hosts \
  -l flasharray-prod01

# Then provision on array2
ansible-playbook pure_storage/playbooks/day1/provision.yml \
  -i inventory/hosts \
  -l flasharray-prod02
```

### Custom Playbooks

Extend with your own orchestration:

```yaml
---
- name: Provision Production Database Tier
  hosts: localhost
  
  tasks:
    - name: Create volumes
      include_tasks: pure_storage/playbooks/day1/provision.yml
      vars:
        volume_name: "prod-db-{{ item }}"
        volume_size_gb: 500
      loop:
        - vol1
        - vol2
        - vol3

    - name: Create snapshots
      include_tasks: pure_storage/playbooks/day2/operations.yml
      vars:
        volume_name: "prod-db-{{ item }}"
        operation: snapshot
      loop:
        - vol1
        - vol2
        - vol3
```

---

## 📞 Support & Documentation

### Collections Documentation

- **Pure Storage FlashArray**: https://github.com/Pure-Storage-Ansible/
- **Dell PowerStore**: https://github.com/dellemc/ansible-powerstore

### Ansible Documentation

- **Official Ansible**: https://docs.ansible.com/
- **Best Practices**: https://docs.ansible.com/ansible/latest/tips_tricks/

---

## ✅ Checklist for Deployment

- [ ] Install collections: `ansible-galaxy install -r requirements.yml`
- [ ] Create vault file: `ansible-vault create group_vars/vault.yml`
- [ ] Populate vault with credentials
- [ ] Update inventory with array IPs
- [ ] Verify connectivity to arrays
- [ ] Test Day 1 provisioning on non-production array
- [ ] Test Day 2 operations on test volume
- [ ] Test Day N decommissioning on test volume
- [ ] Document any customizations
- [ ] Set up logging/monitoring for playbook executions
- [ ] Schedule automated backups of vault passwords
- [ ] Create runbooks for team members

---

## 📝 License & Support

For issues, questions, or enhancements:

1. Check collection documentation
2. Review playbook comments and examples
3. Enable verbose logging: `-vvv` flag
4. Check Ansible logs in logs/ansible.log

---

**Last Updated:** 2026-04-27  
**Version:** 1.0.0  
**Status:** Production-Ready
