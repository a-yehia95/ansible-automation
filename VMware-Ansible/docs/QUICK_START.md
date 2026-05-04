# Quick Start Guide - VMware Ansible Automation

Get up and running with VMware Ansible automation in 5 minutes!

## 1. Initial Setup (One-time)

```bash
# Navigate to project directory
cd VMware-Ansible

# Install dependencies
ansible-galaxy install -r requirements.yml

# Create vault password file
echo "MySecureVaultPassword123!" > .vault_pass
chmod 600 .vault_pass
```

## 2. Configure vCenter Credentials

```bash
# Create encrypted vault file with credentials
ansible-vault create group_vars/vmware_infrastructure/vault.yml --vault-password-file=.vault_pass

# Add this content (replace with your values):
---
vault_vcenter_hostname: "vcenter.example.com"
vault_vcenter_username: "administrator@vsphere.local"
vault_vcenter_password: "YourPassword123"
```

## 3. Update Inventory

Edit `inventory/hosts`:

```ini
[vmware_infrastructure]
vcenter01 ansible_host=vcenter.example.com
```

## 4. Update Configuration

Edit `group_vars/vmware_infrastructure.yml`:

```yaml
# Update these values
datacenters:
  - name: "My-Datacenter"
    description: "Production Datacenter"

clusters:
  - name: "My-Cluster"
    datacenter: "My-Datacenter"
    enable_drs: true
    enable_ha: true
```

## 5. Run Day 0 Foundation Setup

```bash
# Setup infrastructure foundation
ansible-playbook playbooks/day0/foundation.yml --vault-password-file=.vault_pass

# Verify success - check output for "changed=X" (X > 0 for first run)
```

## 6. Provision a VM (Day 1)

```bash
# Clone a VM from template
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file=.vault_pass \
  --extra-vars='vm_name=test-server vm_template=centos-9-base datacenter_name=My-Datacenter'
```

## 7. Manage VM (Day 2)

```bash
# Create snapshot
ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
  --vault-password-file=.vault_pass \
  --extra-vars='vm_name=test-server datacenter_name=My-Datacenter snapshot_state=present'

# Power off VM
ansible-playbook playbooks/day2/admin.yml --tags=power \
  --vault-password-file=.vault_pass \
  --extra-vars='vm_names=[test-server] datacenter_name=My-Datacenter power_state=powered_off'

# Generate reports
ansible-playbook playbooks/day2/admin.yml --tags=reporting \
  --vault-password-file=.vault_pass
```

## Common Tasks Quick Reference

### List all VMs
```bash
ansible-playbook playbooks/day2/admin.yml --tags=reporting
# Check reports in /tmp/vmware_reports/
```

### Provision multiple VMs
```bash
for i in {1..3}; do
  ansible-playbook playbooks/day1/provision.yml \
    --vault-password-file=.vault_pass \
    --extra-vars="vm_name=web-server-$i vm_template=ubuntu-22.04-base datacenter_name=My-Datacenter"
done
```

### Batch power management
```bash
# Power on multiple VMs
ansible-playbook playbooks/day2/admin.yml --tags=power \
  --vault-password-file=.vault_pass \
  --extra-vars='vm_names=[web-server-1,web-server-2,web-server-3] datacenter_name=My-Datacenter power_state=powered_on'
```

## Troubleshooting

### SSH connection issues
```bash
# Verify vCenter is reachable
ping vcenter.example.com

# Check vault password is correct
ansible-vault view group_vars/vmware_infrastructure/vault.yml
```

### SSL certificate errors
In `group_vars/vmware_infrastructure.yml`:
```yaml
vcenter_validate_certs: no  # For self-signed certificates
```

### Invalid template name
```bash
# Generate inventory report to see available templates
ansible-playbook playbooks/day2/admin.yml --tags=reporting
```

## Next Steps

- Review [README.md](README.md) for comprehensive documentation
- Explore role-specific variables in `roles/*/vars/main.yml`
- Customize configuration for your environment
- Add custom Jinja2 filters in `filter_plugins/`

## Support

- Enable verbose output: `-v` or `-vv`
- Check logs in `logs/ansible.log`
- Review role tasks in `roles/*/tasks/main.yml`

---

**Now you're ready!** Start with Day 0 foundation setup, then move to Day 1 provisioning and Day 2 administration as needed.
