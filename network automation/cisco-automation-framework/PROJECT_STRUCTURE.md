## PROJECT DIRECTORY TREE

```
cisco-automation-framework/
│
├─ 📄 Documentation
│  ├─ README.md                        [Complete guide & best practices]
│  ├─ QUICKSTART.md                    [5-minute setup guide]
│  ├─ DIRECTORY_STRUCTURE.txt          [This tree with explanations]
│  └─ CONTRIBUTING.md                  [Guidelines for contributions]
│
├─ 🎯 Master Playbook & Configuration
│  ├─ site.yml                         [MAIN: Orchestrates all lifecycle stages]
│  ├─ ansible.cfg                      [Ansible configuration settings]
│  ├─ inventory.ini                    [Device inventory - CUSTOMIZE THIS]
│  └─ requirements.txt                 [Python package dependencies]
│
├─ 📚 Additional Playbooks
│  └─ playbooks/
│     ├─ collect_facts.yml             [Gather device facts and inventory]
│     ├─ drift_detection.yml           [Configuration compliance & drift]
│     ├─ restore_config.yml            [Configuration restore from backup]
│     ├─ execution_summary.j2          [HTML execution report template]
│     ├─ inventory_report.j2           [HTML inventory report template]
│     └─ compliance_report.j2          [HTML compliance report template]
│
├─ 🔐 Variables & Credentials (Security)
│  ├─ group_vars/                      [Group-level variables]
│  │  ├─ all.yml                       [Global settings - CUSTOMIZE]
│  │  ├─ ios_devices.yml               [IOS device defaults - CUSTOMIZE]
│  │  ├─ fmc_devices.yml               [Firepower defaults - CUSTOMIZE]
│  │  └─ all/
│  │     └─ vault_template.yml         [Vault template for credentials]
│  │
│  └─ host_vars/                       [Host-specific variables]
│     ├─ core-switch-01.yml            [Switch config - CUSTOMIZE THIS]
│     ├─ core-switch-02.yml
│     ├─ distribution-router-01.yml
│     ├─ ftd-sensor-01.yml             [FTD config - CUSTOMIZE THIS]
│     └─ ftd-sensor-02.yml
│
├─ 🛠️  Roles (Lifecycle Management)
│  │
│  ├─ roles/common/                    ╔════════════════════════════════╗
│  │  ├─ tasks/main.yml                ║ DAY 0: PROVISIONING             ║
│  │  ├─ handlers/main.yml             ║ Basic system configuration      ║
│  │  ├─ templates/                    ╚════════════════════════════════╝
│  │  └─ vars/
│  │  └─ README.md
│  │     Contents: Hostname, DNS, NTP, AAA/TACACS+, SSH, Banner,
│  │               Syslog, SNMP, Console logging, Clock
│  │
│  ├─ roles/ios_config/                ╔════════════════════════════════╗
│  │  ├─ tasks/main.yml                ║ DAY 1: IOS DEPLOYMENT           ║
│  │  ├─ templates/                    ║ Layer 2/3 Configuration         ║
│  │  ├─ vars/                         ╚════════════════════════════════╝
│  │  └─ README.md
│  │     Contents: Interfaces, VLANs, Trunks, Access ports, SVI,
│  │               OSPF/BGP routing, Spanning Tree, DHCP Snooping
│  │
│  ├─ roles/fmc_security/              ╔════════════════════════════════╗
│  │  ├─ tasks/main.yml                ║ DAY 1: FIREPOWER DEPLOYMENT     ║
│  │  ├─ templates/                    ║ Security Policy Configuration   ║
│  │  ├─ vars/                         ╚════════════════════════════════╝
│  │  └─ README.md
│  │     Contents: Network objects, Service objects, Access Control
│  │               Policies, NAT rules, Security Intelligence,
│  │               IPS/IDS, Threat Defense, Policy deployment
│  │
│  ├─ roles/validation/                ╔════════════════════════════════╗
│  │  ├─ tasks/main.yml                ║ DAY 2: VALIDATION & MONITORING  ║
│  │  ├─ templates/                    ║ Health Checks & Compliance      ║
│  │  │  └─ validation_report.j2       ║ (Idempotent, Read-only)         ║
│  │  ├─ vars/                         ╚════════════════════════════════╝
│  │  └─ README.md
│  │     Contents: OSPF neighbors, Interface status, CPU/Memory,
│  │               Spanning Tree, Temperature, Compliance checks,
│  │               Health reports
│  │
│  ├─ roles/backup/                    ╔════════════════════════════════╗
│  │  ├─ tasks/main.yml                ║ DAY 2: BACKUP & GIT             ║
│  │  ├─ templates/                    ║ Configuration Backups           ║
│  │  ├─ vars/                         ╚════════════════════════════════╝
│  │  └─ README.md
│  │     Contents: Running config backup, Timestamped files,
│  │               Retention management, Git integration, Verification
│  │
│  └─ roles/maintenance/               ╔════════════════════════════════╗
│     ├─ tasks/main.yml                ║ MAINTENANCE: OS UPGRADE         ║
│     ├─ templates/                    ║ Controlled Image Upgrades       ║
│     │  └─ upgrade_report.j2          ║ (Serial 1 device at a time)     ║
│     ├─ vars/                         ╚════════════════════════════════╝
│     └─ README.md
│        Contents: Pre-upgrade validation, Image download, Verification,
│                  Boot configuration, Reload management, Post-upgrade
│                  validation, Comprehensive reporting
│
├─ 📊 Output & Reports
│  ├─ logs/
│  │  ├─ ansible.log                   [Playbook execution log]
│  │  ├─ audit.log                     [Configuration audit trail]
│  │  ├─ validation_report_*.txt       [Day 2 validation reports]
│  │  ├─ compliance_report_*.html      [Compliance audit reports]
│  │  └─ upgrade_report_*.txt          [OS upgrade reports]
│  │
│  ├─ backups/
│  │  ├─ *.cfg                         [Configuration files]
│  │  ├─ *_backup_*.cfg                [Timestamped backups]
│  │  ├─ PRE_UPGRADE_*.cfg             [Pre-upgrade backups]
│  │  ├─ PRE_RESTORE_*.cfg             [Pre-restore backups]
│  │  ├─ *_baseline.cfg                [Baseline for drift detection]
│  │  ├─ drift_report_*.txt            [Drift detection reports]
│  │  └─ .git/                         [Optional Git repository]
│  │
│  ├─ facts/
│  │  └─ *_facts.json                  [Device facts in JSON format]
│  │
│  └─ reports/
│     ├─ inventory_*.html              [Device inventory reports]
│     ├─ execution_summary_*.html      [Execution summary reports]
│     └─ compliance_*.html             [Compliance reports]
│
├─ 🚀 Execution Scripts
│  ├─ execute.sh                       [Linux/Mac executor script]
│  ├─ execute.bat                      [Windows executor script]
│  ├─ setup.sh                         [Linux/Mac setup script]
│  ├─ setup.bat                        [Windows setup script]
│  └─ Makefile                         [Optional: Make automation]
│
└─ 📋 Project Files
   ├─ .gitignore                       [Git ignore rules]
   ├─ .ansible-lint                    [Ansible linting rules]
   ├─ galaxy.yml                       [Ansible Galaxy metadata]
   └─ LICENSE                          [Project license]
```

## 📊 Workflow Summary

```
                    ┌─────────────────────────────────┐
                    │   ANSIBLE CISCO FRAMEWORK       │
                    │  Complete Lifecycle Management   │
                    └──────────────┬──────────────────┘
                                   │
                ┌──────────────────┼──────────────────┐
                │                  │                  │
        ┌───────▼────────┐ ┌──────▼────────┐ ┌──────▼──────┐
        │    DAY 0       │ │    DAY 1      │ │   DAY 2     │
        │  PROVISIONING  │ │  DEPLOYMENT   │ │ OPERATIONS  │
        └───────┬────────┘ └──────┬────────┘ └──────┬──────┘
                │                 │                 │
        ┌───────▼────────┐        │        ┌────────▼────────┐
        │  common role   │        │        │  validation     │
        │  - Hostname    │        │        │  - Health check │
        │  - DNS/NTP     │        │        │  - Compliance   │
        │  - AAA/SSH     │        │        │  - Drift detect │
        │  - Logging     │        │        └────────┬────────┘
        └────────────────┘        │                 │
                                  │        ┌────────▼────────┐
                    ┌─────────────┼────────┤   backup role   │
                    │             │        │  - Git backup   │
            ┌───────▼────────┐    │        │  - Retention    │
            │  ios_config    │    │        └─────────────────┘
            │  - Interfaces  │    │
            │  - VLANs       │    │
            │  - OSPF/BGP    │    │        ┌──────────────────┐
            └────────────────┘    │        │  maintenance     │
                                  │        │  - OS upgrade    │
            ┌───────▼────────┐    │        │  - Pre/post chks │
            │ fmc_security   │    │        └──────────────────┘
            │ - Objects      │    │
            │ - Policies     │    │
            │ - IPS/IDS      │    │
            └────────────────┘    │
                                  │
                    ┌─────────────┴────────┐
                    │                      │
            ┌───────▼──────┐      ┌──────▼────────┐
            │  REPORTS &   │      │  BACKUPS &    │
            │  LOGGING     │      │  GIT REPO     │
            │  - Audit     │      │  - Config mgmt│
            │  - Compliance│      │  - Version Ctr│
            └──────────────┘      └───────────────┘
```

## 🎯 Key Implementation Points

### Idempotency
✓ All tasks are idempotent - safe to run multiple times
✓ Uses match/line logic for configuration management
✓ Proper state declarations (merged, replaced, deleted)

### Agnosticism
✓ Uses ansible.netcommon for network-agnostic modules
✓ Supports Cisco IOS, IOS-XE, and NX-OS with minimal changes
✓ FMC integration via REST APIs

### Serial Execution
- Maintenance role: `serial: 1` (one device at a time)
- Prevents cascading failures during upgrades
- Safe for critical network changes

### Security
✓ Vault integration for all credentials
✓ No hardcoded passwords
✓ Enable/privilege mode separation
✓ SSH key-based authentication recommended

### Reporting
✓ Automatic HTML report generation
✓ Audit trail logging
✓ Compliance documentation
✓ Pre/post change comparison