# Cisco Automation Framework - Comprehensive README
# ============================================================================

## Overview

This is an enterprise-grade Ansible framework for managing Cisco IOS, IOS-XE devices and Cisco Firepower appliances (managed via Firepower Management Center - FMC). The framework covers the complete lifecycle of network infrastructure management using Infrastructure as Code (IaC) principles.

## Architecture

### Project Structure

```
cisco-automation-framework/
├── ansible.cfg                      # Ansible configuration
├── inventory.ini                    # Device inventory
├── site.yml                         # Master orchestration playbook
├── requirements.txt                 # Python dependencies
│
├── group_vars/
│   ├── all.yml                      # Global variables
│   ├── ios_devices.yml              # IOS device variables
│   ├── fmc_devices.yml              # Firepower variables
│   └── all/
│       └── vault_template.yml       # Vault credentials template
│
├── host_vars/
│   ├── core-switch-01.yml           # Switch configuration
│   └── ftd-sensor-01.yml            # Firepower configuration
│
├── playbooks/
│   ├── collect_facts.yml            # Gather device facts
│   ├── drift_detection.yml          # Configuration drift detection
│   ├── restore_config.yml           # Configuration restore
│   └── [templates for reports]
│
├── roles/
│   ├── common/
│   │   ├── tasks/main.yml           # Day 0 provisioning
│   │   ├── handlers/main.yml
│   │   └── templates/
│   │
│   ├── ios_config/
│   │   ├── tasks/main.yml           # Day 1 IOS deployment
│   │   └── templates/
│   │
│   ├── fmc_security/
│   │   ├── tasks/main.yml           # Day 1 Firepower deployment
│   │   └── templates/
│   │
│   ├── validation/
│   │   ├── tasks/main.yml           # Day 2 health checks
│   │   └── templates/validation_report.j2
│   │
│   ├── backup/
│   │   ├── tasks/main.yml           # Day 2 backups
│   │   └── templates/
│   │
│   └── maintenance/
│       ├── tasks/main.yml           # OS upgrades
│       └── templates/upgrade_report.j2
│
└── backups/                         # Configuration backups directory
```

## Lifecycle Coverage

### Day 0: Provisioning
- Hostname configuration
- Domain name setup
- DNS servers
- NTP configuration
- AAA (TACACS+/RADIUS)
- SSH hardening (v2 only)
- Banner configuration
- Syslog setup
- SNMP configuration

**Run:** `ansible-playbook site.yml --tags day0`

### Day 1: Deployment
#### IOS Configuration
- Layer 2/3 interface configuration
- VLAN creation and management
- Trunk and access port setup
- Spanning Tree Protocol configuration
- OSPF/BGP routing deployment
- DHCP Snooping

#### Firepower Security
- Network/Service/Port objects
- Access Control Policies (ACP)
- NAT rules
- Security Intelligence
- IPS/IDS policies
- Policy deployment to FTD

**Run:** `ansible-playbook site.yml --tags day1`

### Day 2: Operations & Compliance
- **Validation**: OSPF neighbor status, interface health, CPU/memory
- **Backups**: Automated configuration backups with retention
- **Compliance**: SSH v2, AAA, NTP, logging verification
- **Drift Detection**: Configuration change detection
- **Git Integration**: Optional Git repository integration

**Run:** `ansible-playbook site.yml --tags day2`

### Maintenance: OS Upgrades
- Pre-upgrade validation and backup
- Image download and verification
- Controlled reload with monitoring
- Post-upgrade validation
- Comparison and reporting

**Run:** `ansible-playbook site.yml --tags maintenance --extra-vars "perform_os_upgrade=true"`

## Setup Instructions

### 1. Prerequisites
- Python 3.8+
- Ansible 2.9+
- SSH connectivity to all devices
- Sufficient privileges (enable mode for Cisco devices)

### 2. Install Collections
```bash
pip install -r requirements.txt
```

### 3. Configure Credentials (Vault)
```bash
# Create vault password file
echo "your_secure_password" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Create encrypted vault file
ansible-vault create --vault-password-file ~/.vault_pass group_vars/all/vault.yml

# Add your encrypted credentials to vault.yml
```

### 4. Update Inventory
Edit `inventory.ini` with your device information:
```ini
[ios_devices]
your-switch-01 ansible_host=192.168.1.10
your-router-01 ansible_host=192.168.1.20

[fmc_devices]
your-ftd-01 ansible_host=192.168.2.50
```

### 5. Customize Host Variables
Update `host_vars/` files with device-specific configuration:
- Interfaces
- VLAN assignments
- Routing configuration
- Security policies

## Usage Examples

### Full Lifecycle Deployment
```bash
# Run all phases (Day 0, Day 1, Day 2)
ansible-playbook site.yml --vault-password-file ~/.vault_pass

# Check mode (dry-run)
ansible-playbook site.yml --vault-password-file ~/.vault_pass --check
```

### Specific Phases
```bash
# Day 0: Provisioning only
ansible-playbook site.yml --tags day0 --vault-password-file ~/.vault_pass

# Day 1: Deployment only
ansible-playbook site.yml --tags day1 --vault-password-file ~/.vault_pass

# Day 2: Operations only
ansible-playbook site.yml --tags day2 --vault-password-file ~/.vault_pass
```

### Individual Operations
```bash
# Collect device facts
ansible-playbook playbooks/collect_facts.yml

# Backup configurations
ansible-playbook playbooks/backup.yml

# Detect configuration drift
ansible-playbook playbooks/drift_detection.yml

# Restore configuration
ansible-playbook playbooks/restore_config.yml --extra-vars "restore_backup_path=./backups/device_backup.cfg"
```

### Device-Specific Operations
```bash
# Configure single device
ansible-playbook site.yml -l core-switch-01 --tags day1

# Upgrade single device
ansible-playbook site.yml -l core-switch-01 --tags maintenance --extra-vars "perform_os_upgrade=true"
```

## Key Features

✅ **Idempotent Tasks** - Safe to run multiple times
✅ **Encrypted Credentials** - Vault integration for sensitive data
✅ **Comprehensive Logging** - Detailed audit trails
✅ **Multi-Device** - Serial execution for critical operations
✅ **Rollback Capability** - Pre/post-backup with restore playbook
✅ **Health Monitoring** - Automated validation checks
✅ **Git Integration** - Optional version control for configs
✅ **Compliance Reporting** - HTML reports and drift detection
✅ **Error Handling** - Fail-fast with detailed error messages

## Best Practices

1. **Always Use Vault** for sensitive data (passwords, keys)
2. **Test in Check Mode** before actual deployment
3. **Run Backups** before any configuration changes
4. **Use Serial Execution** for critical changes (serial: 1)
5. **Maintain Baselines** for drift detection
6. **Version Control** your playbooks and host_vars
7. **Document Changes** with meaningful commit messages
8. **Schedule Backups** as Day 2 operational task

## Troubleshooting

### SSH Connection Issues
```bash
# Test connectivity
ansible all -i inventory.ini -m ping

# Enable SSH debugging
ansible-playbook site.yml -vvv
```

### Vault Password Issues
```bash
# Test vault access
ansible-vault view --vault-password-file ~/.vault_pass group_vars/all/vault.yml
```

### Collection Issues
```bash
# Update collections
ansible-galaxy collection install --force cisco.ios cisco.fmc ansible.netcommon
```

## Security Considerations

⚠️ **Never commit the following to version control:**
- `group_vars/all/vault.yml` (encrypted vault file)
- `.vault_pass` (vault password)
- Any unencrypted credentials

✅ **Do commit:**
- `group_vars/all/vault_template.yml` (template only)
- `ansible.cfg`
- `inventory.ini` (without passwords)
- Playbooks and roles

## Support & References

- [Cisco IOS Collection](https://galaxy.ansible.com/cisco/ios)
- [Cisco FMC Collection](https://galaxy.ansible.com/cisco/fmc)
- [Ansible Network Documentation](https://docs.ansible.com/ansible/latest/network_guide/)
- [Cisco Configuration Best Practices](https://www.cisco.com/c/en/us/support/docs/)

## License

This framework is provided as-is for enterprise network automation.

---

**Last Updated:** 2024
**Framework Version:** 1.0.0