---
# ==============================================================================
# CIS BENCHMARK REFERENCE - RHEL 9 Controls Mapping
# ==============================================================================

# CIS Benchmark Control Mapping for RHEL 9

This document maps the automated hardening to specific CIS Benchmark controls.

## CIS Benchmark Sections Covered

### 1. Filesystem & Package Management (CIS 1.x)

| Control | Title | Role | Implementation |
|---------|-------|------|-----------------|
| 1.1.1 | Configure /tmp | N/A | Informational |
| 1.2.1 | Ensure GPG keys configured | cis_package_management | Checked |
| 1.2.3 | Ensure DNF automatic updates enabled | cis_package_management | Configured |
| 1.3.1 | Remove unnecessary packages | cis_package_management | Automated |
| 1.4.1 | Install security packages | cis_package_management | Automated |
| 1.5.1 | Configure AIDE | cis_package_management | Configured |

### 2. System Settings & Kernel (CIS 2.x)

| Control | Title | Role | Implementation |
|---------|-------|------|-----------------|
| 2.1.1 | Enable ASLR | cis_system_settings | Configured |
| 2.1.2 | Enable ptrace scope | cis_system_settings | Configured |
| 2.1.3 | Restrict kernel pointers | cis_system_settings | Configured |
| 2.1.4 | Disable unprivileged BPF | cis_system_settings | Configured |
| 2.2.1 | Disable core dumps | cis_system_settings | Configured |
| 2.3.1 | Configure SELinux | cis_system_settings | Configured |
| 2.4.1 | Disable uncommon protocols | cis_system_settings | Configured |

### 3. Network Configuration & Firewall (CIS 3.x)

| Control | Title | Role | Implementation |
|---------|-------|------|-----------------|
| 3.1.1 | IPv6 disabled (if not needed) | cis_firewall_network | Configured |
| 3.2.1 | Disable IPv4 send redirects | cis_firewall_network | Configured |
| 3.2.2 | Disable IPv4 accept redirects | cis_firewall_network | Configured |
| 3.3.1 | Enable TCP SYN Cookies | cis_firewall_network | Configured |
| 3.4.1 | Disable IP forwarding | cis_firewall_network | Configured |
| 3.5.1 | Install firewalld | cis_firewall_network | Automated |
| 3.5.2 | Enable firewalld | cis_firewall_network | Automated |
| 3.5.3 | Configure default zone | cis_firewall_network | Configured |
| 3.6.1 | Configure network parameters | cis_firewall_network | Configured |

### 4. Logging & Auditing (CIS 4.x)

| Control | Title | Role | Implementation |
|---------|-------|------|-----------------|
| 4.1.1 | Install auditd | cis_logging_auditing | Automated |
| 4.1.2 | Enable auditd | cis_logging_auditing | Automated |
| 4.2.1 | Audit time changes | cis_logging_auditing | Configured |
| 4.2.2 | Audit identity changes | cis_logging_auditing | Configured |
| 4.2.3 | Audit mount operations | cis_logging_auditing | Configured |
| 4.2.4 | Audit file deletion | cis_logging_auditing | Configured |
| 4.3.1 | Install rsyslog | cis_logging_auditing | Automated |
| 4.3.2 | Enable rsyslog | cis_logging_auditing | Automated |
| 4.3.3 | Configure rsyslog | cis_logging_auditing | Configured |
| 4.4.1 | Configure log file permissions | cis_logging_auditing | Configured |

### 5. Access Control & Authentication (CIS 5.x)

| Control | Title | Role | Implementation |
|---------|-------|------|-----------------|
| 5.1.1 | PASS_MAX_DAYS | cis_account_policies | Configured (90 days) |
| 5.1.2 | PASS_MIN_DAYS | cis_account_policies | Configured (1 day) |
| 5.1.3 | PASS_MIN_LEN | cis_account_policies | Configured (14 chars) |
| 5.1.4 | PASS_WARN_AGE | cis_account_policies | Configured (14 days) |
| 5.2.1 | Configure SSH server | cis_authentication | Automated |
| 5.2.2 | Enable SSH | cis_authentication | Automated |
| 5.2.3 | Harden SSH configuration | cis_authentication | Configured |
| 5.2.16 | Configure SSH banner | cis_authentication | Configured |
| 5.3.1 | PAM password quality | cis_authentication | Configured |
| 5.3.3 | Password history | cis_authentication | Configured (5 passwords) |
| 5.5.1 | Restrict root SSH login | cis_authentication | Configured |
| 5.5.2 | Disable empty password login | cis_authentication | Configured |

### 6. File Permissions & Ownership (CIS 6.x)

| Control | Title | Role | Implementation |
|---------|-------|------|-----------------|
| 6.1.2 | /etc/passwd permissions | cis_file_permissions | Verified (0644) |
| 6.1.3 | /etc/shadow permissions | cis_file_permissions | Verified (0600) |
| 6.1.4 | /etc/group permissions | cis_file_permissions | Verified (0644) |
| 6.1.5 | /etc/gshadow permissions | cis_file_permissions | Verified (0600) |
| 6.1.10 | SSH config permissions | cis_file_permissions | Verified (0600) |
| 6.2.12 | User home directory ownership | cis_file_permissions | Verified |
| 6.2.13 | User home directory permissions | cis_file_permissions | Verified (750) |
| 6.3.1 | Find world-writable files | cis_file_permissions | Audited |
| 6.3.2 | Find SUID files | cis_file_permissions | Audited |
| 6.3.3 | Find SGID files | cis_file_permissions | Audited |
| 6.4.1 | Find unowned files | cis_file_permissions | Audited |
| 6.4.2 | Find ungrouped files | cis_file_permissions | Audited |

### 7. System Maintenance & Services (CIS 7.x)

| Control | Title | Role | Implementation |
|---------|-------|------|-----------------|
| 7.1.1 | Disable unnecessary services | cis_services | Automated |
| 7.2.1 | Enable essential services | cis_services | Automated |
| 7.3.1 | Harden cron service | cis_services | Configured |
| 7.3.3 | Ensure SSH enabled | cis_services | Configured |
| 7.4.1 | Audit network listeners | cis_services | Audited |
| 7.4.2 | Audit network protocols | cis_services | Audited |

## Implementation Status

### Fully Automated
- Password policy configuration
- SSH hardening
- Firewall configuration
- Auditd and rsyslog setup
- File permissions
- Service management
- Kernel parameter hardening
- SELinux configuration

### Manual/Informational
- Filesystem partitioning (CIS 1.1)
- Bootloader password (CIS 2.1)
- Custom firewall rules for applications
- Special file permissions review (SUID/SGID)

### Auditing Only (Report Generated)
- Unowned/ungrouped files
- World-writable files
- Special permission files (SUID/SGID)
- Network listeners

## Compliance Levels

### Level 1 (Essential) - Default
Covers basic security controls needed for all systems:
- Password policies
- SSH hardening
- Firewall basics
- Logging setup
- Basic file permissions
- Service hardening

### Level 2 (Defense-in-Depth) - Enhanced
Adds stricter controls for higher security:
- Complex password requirements
- Restricted network access
- Additional audit rules
- Extended service masking
- Stricter file permission enforcement

## Customization by CIS Section

To apply hardening only to specific CIS sections:

```bash
# CIS 1.x - Package Management
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_1

# CIS 2.x - System Settings
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_2

# CIS 3.x - Network
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_3

# CIS 4.x - Logging
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_4

# CIS 5.x - Access Control
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_5

# CIS 6.x - File Permissions
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_6

# CIS 7.x - Services
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_7
```

## Limitations & Notes

### Not Covered (Manual Implementation)
1. **CIS 1.1** - Filesystem partitioning
   - Requires system redesign, not automatable post-installation

2. **CIS 2.1** - Bootloader password
   - Requires interactive grub configuration

3. **CIS 5.4** - SSH key generation
   - Use your own key management system

4. **Custom Application Rules**
   - Firewall rules for specific applications
   - Service-specific configuration

### Environment-Specific Configuration
Some controls may need customization:

- **Firewall rules**: Add application-specific rules after hardening
- **SSH keys**: Generate and distribute securely
- **Log server**: Configure remote logging if needed
- **Network parameters**: Adjust for specific network requirements

## References

- [CIS RHEL 9 Benchmark v1.0.0](https://www.cisecurity.org/)
- [Red Hat Security Guide](https://access.redhat.com/articles/11258)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework/)

---

**Last Updated**: 2024
**CIS Version**: Benchmark v1.0.0
**RHEL Version**: 9.0 - 9.9
