---
# ==============================================================================
# START HERE - RHEL 9 CIS Hardening Ansible Framework
# ==============================================================================

# 🚀 Welcome to RHEL 9 CIS Hardening Automation

This is a production-ready Ansible framework for automating the hardening of RHEL 9 Linux servers according to the **Center for Internet Security (CIS) Benchmark** standards.

## 📋 What You Have

A complete automation solution with:

- **8 Specialized Roles**: Account policies, file permissions, logging, firewall, packages, system settings, authentication, and services
- **3 Playbooks**: Master (hardening), validation (compliance), and reporting
- **4+ Documentation Files**: Setup guide, deployment guide, CIS reference, and quick start
- **Configuration Management**: Full variable-based configuration system
- **Testing & Validation**: Built-in compliance checking playbooks
- **Production-Ready**: Error handling, idempotent operations, and pre-checks

### Project Contents

```
RHEL9-CIS-Hardening/
├── 📁 playbooks/          → Main automation playbooks
│   ├── master.yml         → Run this to apply hardening
│   ├── validate.yml       → Run this to check compliance
│   └── compliance_report.yml → Generate compliance report
├── 📁 roles/              → Security hardening roles (8 total)
├── 📁 inventory/          → Target servers configuration
├── 📁 templates/          → Configuration templates
├── 📁 docs/               → Documentation
├── ansible.cfg            → Ansible configuration
└── requirements.txt       → Python dependencies
```

## ⚡ Quick Start (5 Minutes)

### 1. Prepare Your Environment

```bash
# Install Ansible (if not already installed)
pip install ansible

# Navigate to project directory
cd RHEL9-CIS-Hardening

# Install Python dependencies
pip install -r requirements.txt
```

### 2. Configure Your Servers

Edit `inventory/hosts`:

```yaml
[rhel9_servers]
rhel9-prod-01 ansible_host=192.168.1.100
rhel9-prod-02 ansible_host=192.168.1.101
```

### 3. Test Connection

```bash
ansible all -i inventory/hosts -m ping
# Should show: "pong"
```

### 4. Run Hardening (Choose one)

**Dry Run (Preview Changes):**
```bash
ansible-playbook -i inventory/hosts playbooks/master.yml --check
```

**Apply Hardening:**
```bash
ansible-playbook -i inventory/hosts playbooks/master.yml
```

**Specific Area Only:**
```bash
# Example: Only account policies hardening
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_5
```

### 5. Validate

```bash
ansible-playbook -i inventory/hosts playbooks/validate.yml
```

## 📚 Documentation Guide

| Document | Purpose | Time |
|----------|---------|------|
| **This File** | Project overview | 5 min |
| [QUICK_START.md](QUICK_START.md) | Fast reference | 5 min |
| [README.md](README.md) | Complete guide | 20 min |
| [CIS_REFERENCE.md](CIS_REFERENCE.md) | CIS mapping | 15 min |
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | Production deployment | 30 min |

## 🔒 Security Areas Covered

### 1. **Account Policies** (CIS 5.x)
- Password aging and complexity
- Account lockout policies  
- Sudo access hardening
- Session timeout configuration

### 2. **File Permissions** (CIS 6.x)
- System file permission enforcement
- Home directory security
- Special file auditing (SUID/SGID)

### 3. **Logging & Auditing** (CIS 4.x)
- Auditd configuration with critical rules
- Rsyslog centralized logging
- Log file protection and retention

### 4. **Firewall & Network** (CIS 3.x)
- Firewalld configuration
- Network parameter hardening
- IP forwarding and redirect disabling

### 5. **Package Management** (CIS 1.x)
- Automatic security updates
- Unnecessary package removal
- Security tool installation (AIDE, auditd)

### 6. **System Settings** (CIS 2.x)
- Kernel hardening (ASLR, core dumps)
- SELinux enforcement
- Network protocol disabling

### 7. **SSH & Authentication** (CIS 5.2, 5.3)
- SSH hardening (ciphers, algorithms)
- PAM password quality requirements
- SSH key management

### 8. **System Services** (CIS 7.x)
- Unnecessary service disabling
- Essential service management
- Service listener auditing

## ✅ What Gets Hardened

**Automatically Applied:**
- ✅ Password policies
- ✅ SSH configuration
- ✅ Firewall rules
- ✅ Audit/Logging setup
- ✅ File permissions
- ✅ Kernel parameters
- ✅ Service states
- ✅ Network security

**Audited (Report Generated):**
- 📋 World-writable files
- 📋 SUID/SGID permissions
- 📋 Unowned files
- 📋 Network listeners
- 📋 Unnecessary packages

**Manual/Review Only:**
- ⚠️ Grub bootloader password
- ⚠️ Filesystem partitioning
- ⚠️ Custom application rules

## 🎯 Use Cases

### Production Deployment
```bash
ansible-playbook -i inventory/hosts playbooks/master.yml
ansible-playbook -i inventory/hosts playbooks/validate.yml
```

### Compliance Check
```bash
ansible-playbook -i inventory/hosts playbooks/validate.yml -vv
```

### Generate Report
```bash
ansible-playbook -i inventory/hosts playbooks/compliance_report.yml
```

### Specific Hardening Area
```bash
# Only firewall configuration
ansible-playbook -i inventory/hosts playbooks/master.yml --tags firewall_network
```

### Multiple Environments
```bash
# Production
ansible-playbook -i inventory/prod/hosts playbooks/master.yml

# Staging
ansible-playbook -i inventory/staging/hosts playbooks/master.yml

# Development
ansible-playbook -i inventory/dev/hosts playbooks/master.yml
```

## 🚨 Important: Pre-Hardening

**Before running hardening, ensure:**

1. ✅ **SSH Access**: Verify SSH is accessible
2. ✅ **Backup**: Create system backups/snapshots
3. ✅ **Documentation**: Review and customize variables
4. ✅ **Testing**: Test in staging/lab environment first
5. ✅ **Notifications**: Alert users of maintenance window
6. ✅ **Rollback Plan**: Have a restore procedure ready

## ⚠️ Critical Post-Hardening

**After hardening, ensure:**

1. ✅ SSH access is still working
2. ✅ Firewall rules allow your applications
3. ✅ Critical services are running
4. ✅ Log files are being created
5. ✅ System performance is acceptable
6. ✅ Compliance validation passes

## 🔧 Configuration

### Customize Hardening

Edit `inventory/group_vars/rhel9_servers.yml`:

```yaml
# Example: Adjust password policy
cis_account_policies:
  password_max_days: 60      # Change from 90 to 60
  password_min_length: 16    # Change from 14 to 16

# Example: Disable specific hardening area
enable_firewall_network: false  # Skip firewall

# Example: Configure SSH
cis_authentication:
  ssh_config:
    permit_root_login: "no"   # Disable root entirely
```

### Select Hardening Profile

```yaml
# Level 1 (Essential) - Default, suitable for most systems
cis_profile: "level1"

# Level 2 (Defense-in-Depth) - Stricter controls
cis_profile: "level2"
```

## 📖 Common Commands

```bash
# Check Ansible syntax
ansible-playbook --syntax-check playbooks/master.yml

# Dry run with verbose output
ansible-playbook -i inventory/hosts playbooks/master.yml --check -vv

# Run with specific tag
ansible-playbook -i inventory/hosts playbooks/master.yml --tags cis_5_1

# Skip specific tag
ansible-playbook -i inventory/hosts playbooks/master.yml --skip-tags firewall

# Run on one server only
ansible-playbook -i inventory/hosts playbooks/master.yml -l rhel9-prod-01

# Enable verbose output (debug info)
ansible-playbook -i inventory/hosts playbooks/master.yml -vv

# See what will change (check mode)
ansible-playbook -i inventory/hosts playbooks/master.yml --check

# Validate compliance
ansible-playbook -i inventory/hosts playbooks/validate.yml
```

## 🆘 Troubleshooting

### SSH After Hardening?
SSH may be blocked by firewall or configuration changes. Solutions:
1. Access via system console/IPMI
2. Have management server with SSH keys pre-distributed
3. Configure firewall rules before completing hardening

### Performance Issues?
1. Check auditd: `auditctl -l | wc -l`
2. Review SELinux: `getenforce`
3. Monitor logs: `tail -f /var/log/messages`

### Compliance Failing?
```bash
# Run validation with details
ansible-playbook -i inventory/hosts playbooks/validate.yml -vv

# Review specific section
grep -r "cis_section_number" /var/log/
```

## 📊 CIS Benchmark Coverage

| Section | Status | Controls |
|---------|--------|----------|
| 1.x - Filesystem & Package Mgmt | ✅ Automated | 6 |
| 2.x - System Settings | ✅ Automated | 7 |
| 3.x - Network & Firewall | ✅ Automated | 10 |
| 4.x - Logging & Auditing | ✅ Automated | 10 |
| 5.x - Access Control & Auth | ✅ Automated | 15 |
| 6.x - File Permissions | ✅ Automated | 12 |
| 7.x - Services | ✅ Automated | 8 |
| **Total Coverage** | **✅ 68 Controls** |

## 🎓 Learning Resources

- **Ansible**: https://docs.ansible.com/
- **CIS Benchmark**: https://www.cisecurity.org/
- **RHEL 9 Security**: https://access.redhat.com/articles/11258
- **Project Documentation**: See `docs/` folder

## 📞 Next Steps

1. **Read Full Documentation**: `docs/README.md`
2. **Test in Lab**: Deploy to test environment first
3. **Customize**: Adjust variables for your environment
4. **Deploy to Staging**: Validate in pre-production
5. **Deploy to Production**: Apply hardening
6. **Monitor**: Run validation and compliance checks regularly

## ⚡ Pro Tips

✨ **Tip 1**: Test in lab/staging before production
✨ **Tip 2**: Use `--check` flag to preview changes
✨ **Tip 3**: Tag-based execution for selective hardening
✨ **Tip 4**: Run validation after hardening
✨ **Tip 5**: Keep documentation of customizations
✨ **Tip 6**: Monitor compliance monthly
✨ **Tip 7**: Subscribe to security updates
✨ **Tip 8**: Have rollback procedure ready

## 📝 Project Statistics

- **Lines of Code**: 3,000+
- **Configuration Lines**: 2,000+
- **Documentation**: 100+ pages
- **CIS Controls Covered**: 68
- **Ansible Roles**: 8
- **Playbooks**: 3
- **Documentation Files**: 5+
- **Templates**: 7+

## 🎉 You're Ready!

Everything is set up and ready to harden your RHEL 9 systems according to CIS Benchmark standards.

**Choose your next action:**

| Action | Command | Time |
|--------|---------|------|
| Quick reference | Read QUICK_START.md | 5 min |
| Full details | Read README.md | 20 min |
| Test drive | `ansible-playbook playbooks/master.yml --check` | 5 min |
| Deploy | `ansible-playbook playbooks/master.yml` | 10-30 min |
| Validate | `ansible-playbook playbooks/validate.yml` | 5 min |

---

## 📄 License & Support

This framework is provided for CIS Benchmark hardening of RHEL 9 systems.

**Questions?** Review the comprehensive documentation in the `docs/` folder.

**Ready to start?** Run your first hardening playbook:

```bash
ansible-playbook -i inventory/hosts playbooks/master.yml --check
```

---

**Last Updated**: 2024
**RHEL Versions**: 9.0 - 9.9  
**Ansible**: 2.9+
**Status**: ✅ Production Ready
