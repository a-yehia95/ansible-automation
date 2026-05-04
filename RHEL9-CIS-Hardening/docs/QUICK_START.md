---
# ==============================================================================
# QUICK START - RHEL 9 CIS Hardening
# ==============================================================================

# 5-Minute Quick Start Guide

## Prerequisites

```bash
# Ensure Ansible is installed
ansible --version  # Should be 2.9+

# SSH access to RHEL 9 servers as root/sudo
ssh root@rhel9-server
```

## Step 1: Configure Target Servers

Edit `inventory/hosts`:

```yaml
[rhel9_servers]
rhel9-prod-01 ansible_host=192.168.1.100
rhel9-prod-02 ansible_host=192.168.1.101
```

## Step 2: Test Connection

```bash
ansible all -i inventory/hosts -m ping
# Should return: "pong"
```

## Step 3: Dry-Run (No Changes)

```bash
ansible-playbook -i inventory/hosts playbooks/master.yml --check
# Review output for potential changes
```

## Step 4: Apply Hardening

```bash
# Full hardening
ansible-playbook -i inventory/hosts playbooks/master.yml

# Or with specific tags
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_5,cis_6
```

## Step 5: Validate

```bash
# Check compliance
ansible-playbook -i inventory/hosts playbooks/validate.yml

# Generate report
ansible-playbook -i inventory/hosts playbooks/compliance_report.yml
```

## Common Commands

```bash
# Check syntax
ansible-playbook --syntax-check playbooks/master.yml

# Run verbose
ansible-playbook -i inventory/hosts playbooks/master.yml -vv

# Run specific role
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_account_policies

# Limit to specific host
ansible-playbook -i inventory/hosts playbooks/master.yml -l rhel9-prod-01

# Dry run with verbose output
ansible-playbook -i inventory/hosts playbooks/master.yml --check -vv
```

## Troubleshooting

**SSH Connection Refused**
```bash
# Verify SSH is accessible
ssh -v root@rhel9-server
# Check inventory host is correct
grep "ansible_host" inventory/hosts
```

**Insufficient Privileges**
```bash
# Ensure running with sudo/root
ansible-playbook -i inventory/hosts playbooks/master.yml -K
# -K prompts for become password
```

**Firewall Blocks SSH**
```bash
# After hardening, firewall might block access
# On system console:
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload
```

## Post-Hardening Checklist

- [ ] SSH access working
- [ ] Firewall rules verified
- [ ] Critical services running
- [ ] Log files accessible
- [ ] Backups validated
- [ ] Compliance report reviewed

## Quick Configuration

To customize hardening level, edit `inventory/group_vars/rhel9_servers.yml`:

```yaml
# Enable/disable areas
enable_account_policies: true
enable_firewall_network: true
enable_logging_auditing: true

# Password policy
cis_account_policies:
  password_max_days: 90
  password_min_length: 14

# SSH configuration
cis_authentication:
  ssh_config:
    permit_root_login: "without-password"
    password_authentication: "no"
```

## Getting Help

- Review full documentation: `docs/README.md`
- Check CIS Benchmark: `docs/CIS_REFERENCE.md`
- Review role details: `roles/*/README.md` (if available)
- Check Ansible logs: `logs/ansible.log`

---

**Need more details?** See the full README.md for comprehensive documentation.
