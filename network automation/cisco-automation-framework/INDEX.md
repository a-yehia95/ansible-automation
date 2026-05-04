# INDEX: Cisco Automation Framework - Complete Documentation

## 📚 Documentation Map

### Getting Started
1. **[README.md](README.md)** - Start here! Complete guide with features, setup, and best practices
2. **[QUICKSTART.md](QUICKSTART.md)** - 5-minute quick start for the impatient
3. **[FRAMEWORK_SUMMARY.md](FRAMEWORK_SUMMARY.md)** - High-level overview and statistics

### Architecture & Design
4. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Technical architecture, data flow, and system design
5. **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Visual directory tree with explanations

### Implementation & Deployment
6. **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Pre-deployment checklist and verification
7. **[EXECUTION_EXAMPLES.md](EXECUTION_EXAMPLES.md)** - 10 real-world execution examples
8. **[DIRECTORY_STRUCTURE.txt](DIRECTORY_STRUCTURE.txt)** - Complete file organization

### Setup & Configuration
9. **[setup.sh](setup.sh)** - Automated setup for Linux/Mac
10. **[setup.bat](setup.bat)** - Automated setup for Windows
11. **[execute.sh](execute.sh)** - Command executor for Linux/Mac
12. **[execute.bat](execute.bat)** - Command executor for Windows

---

## 🎯 Primary Files by Purpose

### Master Orchestration
- **[site.yml](site.yml)** - Main playbook (orchestrates all phases)

### Supporting Playbooks
- **[playbooks/collect_facts.yml](playbooks/collect_facts.yml)** - Device facts collection
- **[playbooks/drift_detection.yml](playbooks/drift_detection.yml)** - Drift & compliance audit
- **[playbooks/restore_config.yml](playbooks/restore_config.yml)** - Configuration restore

### Configuration Management
- **[ansible.cfg](ansible.cfg)** - Ansible settings
- **[inventory.ini](inventory.ini)** - Device inventory (EDIT THIS)
- **[requirements.txt](requirements.txt)** - Python dependencies
- **[.gitignore](.gitignore)** - Git ignore rules

### Variable Files (Templates)
- **[group_vars/all.yml](group_vars/all.yml)** - Global variables
- **[group_vars/ios_devices.yml](group_vars/ios_devices.yml)** - IOS defaults
- **[group_vars/fmc_devices.yml](group_vars/fmc_devices.yml)** - Firepower defaults
- **[group_vars/all/vault_template.yml](group_vars/all/vault_template.yml)** - Vault template
- **[host_vars/core-switch-01.yml](host_vars/core-switch-01.yml)** - Switch example
- **[host_vars/ftd-sensor-01.yml](host_vars/ftd-sensor-01.yml)** - FTD example

---

## 🛠️ Roles Reference

### Role: Common (Day 0: Provisioning)
**Location:** `roles/common/`
**Purpose:** Basic system configuration
**Key Tasks:**
- Hostname configuration
- DNS and NTP setup
- AAA/TACACS+ configuration
- SSH hardening
- Syslog and SNMP setup
- Banner and logging configuration

**Usage:**
```bash
ansible-playbook site.yml --tags day0
```

---

### Role: IOS Config (Day 1: IOS Deployment)
**Location:** `roles/ios_config/`
**Purpose:** Layer 2/3 network configuration
**Key Tasks:**
- Interface configuration (physical, SVI)
- VLAN creation and management
- Trunk and access port setup
- Spanning Tree Protocol
- OSPF routing protocol
- Static routes
- DHCP Snooping

**Usage:**
```bash
ansible-playbook site.yml --tags day1,ios
```

---

### Role: FMC Security (Day 1: Firepower Deployment)
**Location:** `roles/fmc_security/`
**Purpose:** Firepower security policy deployment
**Key Tasks:**
- Network object creation
- Service and port objects
- Access Control Policies (ACP)
- NAT rule configuration
- Security Intelligence setup
- IPS/IDS policies
- Policy deployment to FTD

**Usage:**
```bash
ansible-playbook site.yml --tags day1,firepower
```

---

### Role: Validation (Day 2: Health Checks)
**Location:** `roles/validation/`
**Purpose:** Device health and compliance validation
**Key Tasks:**
- OSPF neighbor verification
- Interface status checking
- CPU/Memory monitoring
- Spanning Tree validation
- Configuration compliance audit
- Health report generation

**Usage:**
```bash
ansible-playbook site.yml --tags day2,validation
```

**Report:** `logs/validation_report_*.txt`

---

### Role: Backup (Day 2: Configuration Backup)
**Location:** `roles/backup/`
**Purpose:** Automated configuration backup and archival
**Key Tasks:**
- Running config extraction
- Local backup storage
- Timestamped versioning
- Git repository integration
- Retention management
- Backup verification

**Usage:**
```bash
ansible-playbook site.yml --tags day2,backup
```

**Output:** `backups/*.cfg` and optional Git repository

---

### Role: Maintenance (OS Upgrades)
**Location:** `roles/maintenance/`
**Purpose:** Controlled OS image upgrades
**Key Tasks:**
- Pre-upgrade backup and validation
- Image download and verification
- Boot configuration
- Device reload with monitoring
- Post-upgrade validation
- Comprehensive reporting

**Usage:**
```bash
ansible-playbook site.yml --tags maintenance --extra-vars "perform_os_upgrade=true"
```

**Report:** `logs/upgrade_report_*.txt`

---

## 📊 Lifecycle Execution Map

```
./execute.sh day0  ──► roles/common
./execute.sh day1  ──► roles/ios_config + roles/fmc_security
./execute.sh day2  ──► roles/validation + roles/backup
./execute.sh full  ──► day0 → day1 → day2
./execute.sh maintenance ──► roles/maintenance
```

---

## 🔍 File Search Guide

### Looking for...?

**Device inventory?**
→ `inventory.ini`

**Global defaults?**
→ `group_vars/all.yml`

**Device-specific config?**
→ `host_vars/[device-name].yml`

**Encrypted credentials?**
→ `group_vars/all/vault.yml` (create this)

**Example host configuration?**
→ `host_vars/core-switch-01.yml` and `host_vars/ftd-sensor-01.yml`

**How to run playbooks?**
→ `README.md` or `QUICKSTART.md`

**Real-world examples?**
→ `EXECUTION_EXAMPLES.md`

**Pre-flight checklist?**
→ `DEPLOYMENT_CHECKLIST.md`

**System architecture?**
→ `ARCHITECTURE.md`

**File directory tree?**
→ `PROJECT_STRUCTURE.md`

**Quick reference?**
→ `FRAMEWORK_SUMMARY.md`

---

## ⚡ Quick Command Reference

### Essential Commands
```bash
# Setup
./setup.sh              # Linux/Mac setup
./setup.bat             # Windows setup

# Testing
./execute.sh ping all                    # Test connectivity
./execute.sh check core-switch-01        # Dry-run check mode

# Deployment
./execute.sh day0                        # Provisioning
./execute.sh day1                        # Deployment
./execute.sh day2                        # Operations
./execute.sh full                        # Full lifecycle

# Operations
./execute.sh backup all                  # Backup configurations
./execute.sh drift all                   # Drift detection
./execute.sh facts all                   # Collect facts

# Maintenance
ansible-playbook site.yml --tags maintenance \
  --extra-vars "perform_os_upgrade=true"

# Advanced
ansible-playbook site.yml -vvv           # Verbose output
ansible-playbook site.yml --step         # Step through tasks
```

---

## 📋 File Types & Formats

| Extension | Purpose | Count |
|-----------|---------|-------|
| `.md` | Documentation | 10 |
| `.yml` | YAML configuration & playbooks | 18 |
| `.ini` | Inventory files | 1 |
| `.txt` | Configuration files | 3 |
| `.j2` | Jinja2 templates | 5 |
| `.sh` | Bash scripts | 2 |
| `.bat` | Windows scripts | 2 |
| `.cfg` | Backups (generated) | Many |
| `.json` | Facts (generated) | Many |
| `.html` | Reports (generated) | Many |
| `.log` | Logs (generated) | Many |

---

## 🎓 Learning Resources

### For Beginners
1. Start with **QUICKSTART.md**
2. Follow **DEPLOYMENT_CHECKLIST.md**
3. Review **EXECUTION_EXAMPLES.md**
4. Try Day 0 provisioning first

### For Intermediate Users
1. Study **ARCHITECTURE.md**
2. Review all role tasks in `roles/*/tasks/main.yml`
3. Customize **host_vars** for your devices
4. Try full lifecycle deployment

### For Advanced Users
1. Review **PROJECT_STRUCTURE.md** for layout
2. Extend roles with custom tasks
3. Integrate with CI/CD pipelines
4. Add custom playbooks

---

## ✅ Implementation Checklist

### Phase 1: Setup (1-2 hours)
- [ ] Install Python 3.8+
- [ ] Install Ansible 2.9+
- [ ] Clone/download framework
- [ ] Run `./setup.sh` or `./setup.bat`
- [ ] Create vault credentials file

### Phase 2: Configuration (2-4 hours)
- [ ] Update `inventory.ini`
- [ ] Create encrypted `vault.yml`
- [ ] Customize `group_vars/` files
- [ ] Create custom `host_vars/` for each device
- [ ] Test SSH connectivity

### Phase 3: Validation (1-2 hours)
- [ ] Run `./execute.sh ping all`
- [ ] Run `./execute.sh check` (dry-run)
- [ ] Review ansible.log for errors
- [ ] Create test backups

### Phase 4: Deployment (2-6 hours)
- [ ] Run Day 0: `./execute.sh day0`
- [ ] Run Day 1: `./execute.sh day1`
- [ ] Run Day 2: `./execute.sh day2`
- [ ] Verify all devices operational
- [ ] Review generated reports

### Phase 5: Operations (Ongoing)
- [ ] Schedule daily Day 2 runs
- [ ] Schedule weekly backups
- [ ] Schedule monthly drift checks
- [ ] Review compliance reports
- [ ] Plan maintenance windows

---

## 🚀 Next Steps

1. **Read:** Start with README.md
2. **Setup:** Follow QUICKSTART.md
3. **Plan:** Use DEPLOYMENT_CHECKLIST.md
4. **Learn:** Study ARCHITECTURE.md
5. **Test:** Try EXECUTION_EXAMPLES.md
6. **Deploy:** Execute from PROJECT_STRUCTURE.md guide
7. **Monitor:** Run Day 2 operations regularly
8. **Maintain:** Schedule upgrades and backups

---

**Framework Status:** ✅ Production Ready
**Total Files:** 40+
**Total Lines:** 2,500+
**Documentation:** 1,000+
**Last Updated:** 2024