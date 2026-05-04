---
# ==============================================================================
# README - RHEL 9 CIS Benchmark Hardening Playbooks
# ==============================================================================

# RHEL 9 CIS Benchmark Automated Hardening

A comprehensive Ansible-based solution for automated hardening of RHEL 9 Linux servers based on the Center for Internet Security (CIS) Benchmark.

## Overview

This project provides production-ready Ansible playbooks and roles to automate the hardening of RHEL 9 systems according to CIS Benchmark standards. It covers all major security areas including user account policies, file permissions, logging, firewall configuration, and system hardening.

### Key Features

- **Modular Architecture**: 8 specialized roles for different security domains
- **CIS Compliance**: Implements CIS Benchmark controls across all areas
- **Flexible Levels**: Supports Level 1 (essential) and Level 2 (defense-in-depth) configurations
- **Audit Logging**: Comprehensive auditd and rsyslog configuration
- **Validation Playbooks**: Built-in compliance checking and reporting
- **Production-Ready**: Error handling, idempotent operations, pre-checks
- **Well-Documented**: Extensive comments and CIS section references

## Supported Systems

- RHEL 9.0 - 9.9
- Rocky Linux 9.x
- AlmaLinux 9.x

### Requirements

- Ansible 2.9 or higher
- Python 3.8+
- SSH access to target systems
- Root or sudo privileges

## Quick Start

### 1. Installation

```bash
# Clone or download the project
cd RHEL9-CIS-Hardening

# Install Ansible (if not already installed)
pip install ansible

# Install Python requirements
pip install -r requirements.txt
```

### 2. Configure Inventory

Edit `inventory/hosts` to add your RHEL 9 servers:

```yaml
[rhel9_servers]
server1.example.com ansible_user=root
server2.example.com ansible_user=root
```

### 3. Run Hardening Playbook

```bash
# Apply all hardening measures
ansible-playbook -i inventory/hosts playbooks/master.yml

# Apply specific security area (example: account policies only)
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_5

# Run in check mode (dry-run)
ansible-playbook -i inventory/hosts playbooks/master.yml --check

# Enable verbose output
ansible-playbook -i inventory/hosts playbooks/master.yml -vv
```

### 4. Validate Compliance

```bash
# Validate hardening was applied correctly
ansible-playbook -i inventory/hosts playbooks/validate.yml

# Generate compliance report
ansible-playbook -i inventory/hosts playbooks/compliance_report.yml
```

## Project Structure

```
RHEL9-CIS-Hardening/
├── playbooks/
│   ├── master.yml              # Main orchestrator playbook
│   ├── validate.yml            # Compliance validation playbook
│   └── compliance_report.yml   # Report generation
├── roles/
│   ├── cis_account_policies/   # CIS 5.x - Account & Access Control
│   ├── cis_file_permissions/   # CIS 6.x - File permissions
│   ├── cis_logging_auditing/   # CIS 4.x - Logging & Auditing
│   ├── cis_firewall_network/   # CIS 3.x - Firewall & Network
│   ├── cis_package_management/ # CIS 1.x - Package management
│   ├── cis_system_settings/    # CIS 2.x - System settings
│   ├── cis_authentication/     # CIS 5.2 - SSH & PAM
│   └── cis_services/           # CIS 7.x - Services
├── inventory/
│   ├── hosts                   # Inventory file
│   └── group_vars/
│       └── rhel9_servers.yml   # Configuration variables
├── templates/                  # Jinja2 templates
├── docs/                       # Documentation
└── tests/                      # Validation tests
```

## Roles Description

### 1. **cis_account_policies** (CIS 5.x)
- Password policy configuration
- Account lockout policies
- Sudo access hardening
- Session timeout configuration
- User account management

**Key Controls**: PASS_MAX_DAYS, faillock, sudo logging, umask

### 2. **cis_file_permissions** (CIS 6.x)
- System file permissions enforcement
- User home directory security
- World-writable file detection
- SUID/SGID file auditing
- Unowned/ungrouped file remediation

**Key Controls**: /etc/passwd, /etc/shadow, /etc/ssh/sshd_config permissions

### 3. **cis_logging_auditing** (CIS 4.x)
- Auditd configuration and rule deployment
- Rsyslog centralized logging setup
- Log file permissions and retention
- Audit trail for critical operations
- System administration tracking

**Key Controls**: auditd, rsyslog, audit rules, log rotation

### 4. **cis_firewall_network** (CIS 3.x)
- Firewalld configuration
- IPv4/IPv6 parameter hardening
- Packet redirect disabling
- TCP SYN Cookies enabling
- Network protocol security

**Key Controls**: firewalld, sysctl parameters, IP forwarding, ICMP

### 5. **cis_package_management** (CIS 1.x)
- Repository configuration
- Package manager updates
- Unnecessary package removal
- Security package installation
- AIDE file integrity checking

**Key Controls**: dnf-automatic, security packages, AIDE

### 6. **cis_system_settings** (CIS 2.x)
- Kernel parameter hardening
- ASLR enablement
- Core dump restriction
- SELinux configuration
- Uncommon protocol disabling

**Key Controls**: kernel.randomize_va_space, SELinux, core dumps

### 7. **cis_authentication** (CIS 5.2, 5.3)
- SSH hardened configuration
- PAM password quality requirements
- SSH key management
- Root login restriction
- SSH banner configuration

**Key Controls**: sshd_config, PAM pwquality, SSH keys

### 8. **cis_services** (CIS 7.x)
- Unnecessary service disabling
- Essential service enablement
- Service-specific hardening
- Network listener audit
- Service masking

**Key Controls**: Service states, cron hardening, listener audit

## Configuration Variables

Main variables in `inventory/group_vars/rhel9_servers.yml`:

```yaml
# CIS Profile Selection
cis_profile: "level1"           # level1 or level2

# Password Policy
cis_account_policies:
  password_max_days: 90
  password_min_length: 14
  account_lock_threshold: 5
  account_lock_duration: 900

# Firewall Configuration
cis_firewall_network:
  firewall_enabled: true
  default_zone: public
  ssh_port: 22

# Logging
cis_logging_auditing:
  auditd_enabled: true
  log_retention_days: 30

# SSH Configuration
cis_authentication:
  ssh_config:
    permit_root_login: "without-password"
    password_authentication: "no"
    pubkey_authentication: "yes"
```

## Advanced Usage

### Selective Hardening

Apply hardening only to specific areas:

```bash
# Only account policies
ansible-playbook -i inventory/hosts playbooks/master.yml \
  --tags cis_5_1,cis_5_2

# Everything except firewall
ansible-playbook -i inventory/hosts playbooks/master.yml \
  --skip-tags firewall_network

# Only check mode (no changes)
ansible-playbook -i inventory/hosts playbooks/master.yml --check
```

### Environment-Specific Configuration

Create environment-specific inventory:

```bash
inventory/
├── hosts                       # Base inventory
├── group_vars/
│   └── rhel9_servers.yml      # Default variables
├── host_vars/
│   ├── webserver.yml          # Web server specifics
│   └── dbserver.yml           # Database server specifics
```

### Post-Hardening Tasks

```bash
# Backup configuration before changes
ansible-playbook -i inventory/hosts playbooks/master.yml -e backup_dir=/backups

# Generate detailed audit report
ansible-playbook -i inventory/hosts playbooks/compliance_report.yml

# Run compliance check
ansible-playbook -i inventory/hosts playbooks/validate.yml -vv
```

## CIS Benchmark Coverage

| Section | Area | Status |
|---------|------|--------|
| 1.x | Filesystem & Package Management | ✓ Implemented |
| 2.x | System Settings & Kernel Hardening | ✓ Implemented |
| 3.x | Network Configuration & Firewall | ✓ Implemented |
| 4.x | Logging & Auditing | ✓ Implemented |
| 5.x | Access Control & Authentication | ✓ Implemented |
| 6.x | File Permissions & Ownership | ✓ Implemented |
| 7.x | System Maintenance & Services | ✓ Implemented |

## Security Best Practices

### Pre-Hardening

1. **Backup System**: Take snapshots/backups before hardening
2. **Test in Lab**: Validate in non-production first
3. **Review Configuration**: Customize variables for your environment
4. **Disable Services**: Ensure unnecessary services are removed
5. **Plan Downtime**: Account for SSH and network configuration changes

### Post-Hardening

1. **Test Connectivity**: Verify SSH and network access
2. **Validate Services**: Ensure critical applications still function
3. **Review Logs**: Check for unexpected errors
4. **Document Changes**: Record any customizations made
5. **Monitor Systems**: Track performance and security metrics

### Ongoing Maintenance

1. **Regular Updates**: Keep RHEL 9 packages updated
2. **Log Review**: Monitor audit and system logs
3. **Compliance Checks**: Periodically re-run validate.yml
4. **Incident Response**: Review audit logs for suspicious activity
5. **Security Updates**: Apply CIS recommended patches promptly

## Troubleshooting

### SSH Access Issues

```bash
# If SSH becomes unresponsive after hardening:
# 1. Check firewall configuration
firewall-cmd --list-all

# 2. Verify SSH service status
systemctl status sshd

# 3. Check SSH configuration syntax
sshd -t

# 4. Review SSH logs
tail -f /var/log/secure
```

### Performance Issues

```bash
# Check auditd impact
auditctl -l | wc -l

# Monitor disk usage for logs
du -sh /var/log/audit/

# Check SELinux impact
getenforce
```

### Compliance Failures

```bash
# Run validation with verbose output
ansible-playbook -i inventory/hosts playbooks/validate.yml -vv

# Check specific CIS section
grep -r "cis_5_1" /var/log/
```

## Reference Documentation

### CIS Benchmark
- [CIS RHEL 9 Benchmark](https://www.cisecurity.org/benchmark/red-hat-enterprise-linux-9)

### RHEL 9 Security
- [Red Hat Security Guide](https://access.redhat.com/articles/11258)
- [SELinux Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/using_selinux/index)

### Ansible Documentation
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

## Limitations & Notes

1. **Grub Password**: Not automated (set manually if needed)
2. **Custom Services**: May require additional firewall rules
3. **Application Dependencies**: Some hardening may affect specific applications
4. **Logging Storage**: Ensure sufficient disk space for audit logs
5. **Network Changes**: Changes to network settings may interrupt connectivity

## Support & Contribution

For issues, questions, or contributions:

1. Review CIS Benchmark documentation
2. Check Ansible logs for errors
3. Validate syntax: `ansible-playbook --syntax-check`
4. Test in non-production environment first

## License

These playbooks are provided as-is for CIS Benchmark hardening of RHEL 9 systems.

## Disclaimer

This project provides automated security hardening based on CIS Benchmark standards. While comprehensive, security is multi-faceted and requires:

- Regular updates and patching
- Continuous monitoring and logging review
- Incident response procedures
- Regular security assessments
- User security awareness training

Always test in a non-production environment first and customize for your specific security requirements.

---

**Last Updated**: 2024
**Supported Versions**: RHEL 9.0 - 9.9
**Ansible Version**: 2.9+
