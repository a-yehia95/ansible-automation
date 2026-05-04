# VMware Ansible Automation - Production-Grade Infrastructure Management

A comprehensive, modular Ansible project for end-to-end VMware vSphere automation, following Ansible and VMware best practices. This solution covers Day 0 (Foundation), Day 1 (Provisioning), and Day 2 (Administration) operations.

## Project Overview

This project provides production-ready automation for:

### Day 0: Foundation Infrastructure
- **Datacenters**: Create and manage vSphere datacenters
- **Clusters**: Configure clusters with DRS, HA, and failover policies
- **Folders**: Organize VM folder hierarchies
- **Distributed Virtual Switches (DVS)**: Create DVS switches and port groups

### Day 1: VM Provisioning
- **VM Cloning**: Clone VMs from templates (Linux & Windows)
- **Customization**: Apply IP, hostname, DNS configurations
- **Hardware Adjustments**: Configure CPU, RAM, disks
- **Placement**: Target specific datastore clusters and resource pools

### Day 2: Administration & Operations
- **Snapshot Management**: Create, remove, revert snapshots with retention policies
- **Power Management**: Control VM power states (on, off, restart)
- **Host Maintenance**: Manage maintenance mode with vMotion orchestration
- **Reporting**: Generate infrastructure inventory and capacity reports

## Project Structure

```
VMware-Ansible/
├── ansible.cfg                 # Ansible configuration
├── requirements.yml            # Collection/role dependencies
├── .gitignore                  # Version control exclusions
├── .vault_pass.example         # Vault password template
│
├── inventory/
│   └── hosts                   # vCenter inventory
│
├── group_vars/
│   ├── vmware_infrastructure.yml  # VMware config (all nodes)
│   └── vmware_infrastructure/
│       └── vault.yml           # Encrypted credentials (vault)
│
├── roles/
│   ├── foundation/
│   │   ├── datacenter/         # Datacenter management
│   │   ├── cluster/            # Cluster configuration
│   │   ├── folders/            # VM folder hierarchy
│   │   └── dvs/                # Distributed switches
│   │
│   ├── provisioning/
│   │   ├── vm_clone/           # Clone from templates
│   │   ├── customization/      # IP, hostname, DNS setup
│   │   └── hardware/           # CPU, RAM, disk adjustment
│   │
│   └── administration/
│       ├── snapshots/          # Snapshot operations
│       ├── power_management/   # Power state control
│       ├── host_maintenance/   # Maintenance mode
│       └── reporting/          # Infrastructure reports
│
├── playbooks/
│   ├── day0/
│   │   └── foundation.yml      # Day 0 orchestration
│   ├── day1/
│   │   └── provision.yml       # Day 1 orchestration
│   └── day2/
│       └── admin.yml           # Day 2 orchestration
│
├── library/                    # Custom modules (optional)
├── filter_plugins/             # Custom filters (optional)
├── vault/                      # Vault-encrypted secrets
├── docs/                       # Documentation
└── logs/                       # Execution logs

```

##  Prerequisites

### Software Requirements
- Ansible 2.9+ (recommended: 2.12+)
- Python 3.7+
- VMware community.vmware collection (4.3.0+)
- PyVmomi library (6.7+)

### vSphere Requirements
- vSphere 6.7+ / 7.0+
- vCenter Server with network access
- SSL certificate (self-signed acceptable with `validate_certs: no`)
- User account with appropriate permissions

### Installation

```bash
# Clone or download this project
cd VMware-Ansible

# Install dependencies
ansible-galaxy install -r requirements.yml

# Create Python virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\\Scripts\\activate

# Install required Python libraries
pip install -r requirements.txt
```

## 🔐 Security - Vault Setup

Sensitive credentials are stored in encrypted Ansible Vault files.

### Create Vault Password File

```bash
# Create .vault_pass file with your password
echo "your_secure_vault_password" > .vault_pass
chmod 600 .vault_pass

# Add to .gitignore (already done)
```

### Create Vault Encrypted Credentials

```bash
# Create encrypted vault file
ansible-vault create group_vars/vmware_infrastructure/vault.yml

# Add your vCenter credentials:
---
vault_vcenter_hostname: "vcenter.example.com"
vault_vcenter_username: "administrator@vsphere.local"
vault_vcenter_password: "your_password_here"
vault_ntp_server: "ntp.example.com"
vault_dns_servers:
  - 8.8.8.8
  - 8.8.4.4
```

### View/Edit Vault Files

```bash
# View encrypted file
ansible-vault view group_vars/vmware_infrastructure/vault.yml

# Edit encrypted file
ansible-vault edit group_vars/vmware_infrastructure/vault.yml
```

## ⚙️ Configuration

### Update Inventory

Edit `inventory/hosts` with your vCenter details:

```ini
[vmware_infrastructure]
vcenter01 ansible_host=vcenter.example.com
```

### Update VMware Settings

Edit `group_vars/vmware_infrastructure.yml` to customize:

- Datacenter names and settings
- Cluster names and DRS/HA policies
- VM folder hierarchy
- DVS switch and port group configurations
- Default VM provisioning settings
- Storage and network parameters

Example customization:

```yaml
# Clusters configuration
clusters:
  - name: "Production-Cluster"
    datacenter: "Primary-DC"
    enable_drs: true
    drs_automation_level: "fullyAutomated"
    enable_ha: true
    ha_failure_level: 2
```

## 🚀 Usage

### Day 0: Foundation Setup

Create foundational infrastructure:

```bash
# Full Day 0 setup
ansible-playbook playbooks/day0/foundation.yml --vault-password-file=.vault_pass

# Specific operation (tag filtering)
ansible-playbook playbooks/day0/foundation.yml --tags=datacenter
ansible-playbook playbooks/day0/foundation.yml --tags=cluster,dvs

# Verbose output for debugging
ansible-playbook playbooks/day0/foundation.yml --vault-password-file=.vault_pass -v
```

### Day 1: VM Provisioning

Provision new VMs from templates:

```bash
# Clone VM with minimal configuration
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file=.vault_pass \
  --extra-vars='vm_name=web-srv-01 vm_template=centos-9-base datacenter_name=Primary-DC'

# Clone with customization (IP, hostname, DNS)
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file=.vault_pass \
  --extra-vars='{
    "vm_name": "web-srv-01",
    "vm_template": "centos-9-base",
    "datacenter_name": "Primary-DC",
    "vm_hostname": "web-srv-01",
    "vm_domain": "example.com",
    "vm_ip_address": "192.168.1.100",
    "vm_netmask": "255.255.255.0",
    "vm_gateway": "192.168.1.1"
  }'

# Clone with hardware adjustment
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file=.vault_pass \
  --extra-vars='{
    "vm_name": "app-server-01",
    "vm_template": "ubuntu-22.04-base",
    "datacenter_name": "Primary-DC",
    "vm_cpu_count": 8,
    "vm_memory_gb": 16,
    "vm_disk_size_gb": 100
  }'

# Only customize without cloning
ansible-playbook playbooks/day1/provision.yml --tags=customization \
  --extra-vars='vm_name=web-srv-01 datacenter_name=Primary-DC vm_hostname=web-srv-01'

# Only adjust hardware
ansible-playbook playbooks/day1/provision.yml --tags=hardware \
  --extra-vars='vm_name=web-srv-01 datacenter_name=Primary-DC vm_cpu_count=8 vm_memory_gb=16'
```

### Day 2: Administration & Operations

#### Snapshot Management

```bash
# Create snapshot
ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
  --extra-vars='{
    "vm_name": "web-srv-01",
    "datacenter_name": "Primary-DC",
    "snapshot_state": "present",
    "snapshot_name": "before-maintenance",
    "snapshot_description": "Snapshot before OS update"
  }'

# List snapshots
ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
  --extra-vars='vm_name=web-srv-01 datacenter_name=Primary-DC snapshot_state=list'

# Revert to snapshot
ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
  --extra-vars='{
    "vm_name": "web-srv-01",
    "datacenter_name": "Primary-DC",
    "snapshot_state": "revert",
    "snapshot_name": "before-maintenance"
  }'

# Remove snapshot
ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
  --extra-vars='{
    "vm_name": "web-srv-01",
    "datacenter_name": "Primary-DC",
    "snapshot_state": "absent",
    "snapshot_name": "before-maintenance"
  }'
```

#### Power Management

```bash
# Power on VMs
ansible-playbook playbooks/day2/admin.yml --tags=power \
  --extra-vars='{
    "vm_names": ["web-srv-01", "web-srv-02"],
    "datacenter_name": "Primary-DC",
    "power_state": "powered_on"
  }'

# Power off VMs gracefully
ansible-playbook playbooks/day2/admin.yml --tags=power \
  --extra-vars='{
    "vm_names": ["web-srv-01"],
    "datacenter_name": "Primary-DC",
    "power_state": "powered_off",
    "force_shutdown": false
  }'

# Power off VMs (forced)
ansible-playbook playbooks/day2/admin.yml --tags=power \
  --extra-vars='{
    "vm_names": ["web-srv-01"],
    "datacenter_name": "Primary-DC",
    "power_state": "powered_off",
    "force_shutdown": true
  }'

# Restart VMs
ansible-playbook playbooks/day2/admin.yml --tags=power \
  --extra-vars='{
    "vm_names": ["web-srv-01"],
    "datacenter_name": "Primary-DC",
    "power_state": "restarted"
  }'
```

#### Host Maintenance

```bash
# Enter maintenance mode (evacuates VMs via vMotion)
ansible-playbook playbooks/day2/admin.yml --tags=maintenance \
  --extra-vars='{
    "cluster_name": "Prod-Cluster-1",
    "esxi_hosts": ["esxi1.example.com", "esxi2.example.com"],
    "maintenance_mode": "enter",
    "timeout_seconds": 600
  }'

# Exit maintenance mode
ansible-playbook playbooks/day2/admin.yml --tags=maintenance \
  --extra-vars='{
    "cluster_name": "Prod-Cluster-1",
    "esxi_hosts": ["esxi1.example.com"],
    "maintenance_mode": "exit"
  }'
```

#### Reporting

```bash
# Generate all reports
ansible-playbook playbooks/day2/admin.yml --tags=reporting \
  --vault-password-file=.vault_pass

# Reports are saved to /tmp/vmware_reports/ (configurable)
# - vm_inventory_*.csv
# - host_status_*.csv
# - snapshot_report_*.csv
# - datastore_report_*.csv
```

## 🔄 Idempotency

All playbooks are designed to be **idempotent** - running them multiple times produces the same result:

- Creating existing resources (datacenters, clusters, folders) skips creation
- Modifying VMs maintains current state if already at target state
- Operations track state changes via `changed` flag

Example - running foundation setup twice:

```bash
# First run: Creates infrastructure
ansible-playbook playbooks/day0/foundation.yml
# Output: ok=10 changed=7

# Second run: Verifies no changes needed
ansible-playbook playbooks/day0/foundation.yml
# Output: ok=10 changed=0 (idempotent)
```

## 📊 Tag Usage

Filter playbook execution with tags:

```bash
# Day 0 tags
--tags=datacenter              # Only datacenter operations
--tags=cluster                 # Only cluster operations
--tags=dvs                     # Only DVS operations
--tags=day0                    # All Day 0 operations

# Day 1 tags
--tags=clone                   # Only VM cloning
--tags=customization           # Only customization
--tags=hardware                # Only hardware adjustment
--tags=day1                    # All Day 1 operations

# Day 2 tags
--tags=snapshots               # Only snapshot operations
--tags=power                   # Only power management
--tags=maintenance             # Only host maintenance
--tags=reporting               # Only reporting
--tags=day2                    # All Day 2 operations
```

## 📝 Best Practices Demonstrated

✅ **Modular Role Structure**: Separate roles for each function
✅ **Vault Encryption**: Secure credential storage
✅ **Idempotent Operations**: Safe repeated execution
✅ **Comprehensive Tags**: Fine-grained execution control
✅ **delegate_to: localhost**: Proper task delegation for VMware modules
✅ **Error Handling**: Assertions and conditional execution
✅ **Documentation**: Inline comments and clear variable naming
✅ **Reporting**: Built-in infrastructure facts gathering
✅ **Multi-Environment**: Support for multiple datacenters/clusters
✅ **Extensibility**: Easy to add custom modules/filters

## 🐛 Troubleshooting

### Connection Issues

```bash
# Verify vCenter connectivity
ansible-playbook playbooks/day0/foundation.yml --tags=verify -v

# Check SSL certificate issues
# In group_vars/vmware_infrastructure.yml:
# validate_certs: no  # For self-signed certs
# validate_certs: yes # For trusted certs
```

### Vault Password Issues

```bash
# Interactive vault password prompt
ansible-playbook playbooks/day0/foundation.yml --ask-vault-pass

# Using vault ID
ansible-playbook playbooks/day0/foundation.yml --vault-id my-vault-id@prompt
```

### Debug Output

```bash
# Verbose output
ansible-playbook playbooks/day0/foundation.yml -v

# Extra verbose (shows all variable values)
ansible-playbook playbooks/day0/foundation.yml -vv

# Debug specific role
ansible-playbook playbooks/day0/foundation.yml --tags=datacenter -vvv
```

## 📖 Additional Resources

- [Ansible VMware Collection](https://docs.ansible.com/ansible/latest/collections/community/vmware/)
- [VMware vSphere API Reference](https://docs.vmware.com/en/VMware-vSphere/index.html)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/index.html)
- [community.vmware Documentation](https://github.com/ansible-collections/community.vmware)

## 📄 License

This project is provided as-is for educational and production use.

## 🤝 Contributing

To extend this project:

1. Add new roles in `roles/` directory following the structure
2. Create corresponding playbooks in `playbooks/`
3. Update inventory and group variables as needed
4. Document new functionality

## 📧 Support

For issues, questions, or suggestions:
- Review existing role documentation
- Check VMware collection examples
- Enable verbose output for debugging
- Review Ansible logs in `logs/` directory

---

**Last Updated**: 2024
**Version**: 1.0
**Status**: Production-Ready
