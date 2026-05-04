# Pre-Deployment Checklist

## Prerequisites

### Environment
- [ ] Python 3.8+ installed
- [ ] Ansible 2.9+ installed
- [ ] SSH access to all network devices
- [ ] Network connectivity to management interfaces
- [ ] Git installed (optional, for version control)

### Device Access
- [ ] Device hostnames and IP addresses documented
- [ ] Admin credentials available
- [ ] Enable/privilege mode password available
- [ ] SSH enabled on all devices
- [ ] Devices running supported OS versions:
  - [ ] Cisco IOS 15.x+
  - [ ] Cisco IOS-XE 16.x+
  - [ ] Cisco Firepower 6.4+

### Ansible Setup
- [ ] Required collections installed:
  - [ ] `ansible-galaxy collection install cisco.ios`
  - [ ] `ansible-galaxy collection install cisco.fmc`
  - [ ] `ansible-galaxy collection install ansible.netcommon`
- [ ] SSH key-based authentication configured (recommended)
- [ ] SSH known_hosts updated for all devices

## Framework Configuration

### Step 1: Inventory Setup
- [ ] Copy `inventory.ini.example` to `inventory.ini`
- [ ] Add all network devices to inventory
- [ ] Verify device groups:
  - [ ] `[ios_devices]` - Switches and routers
  - [ ] `[fmc_devices]` - Firepower managed devices
  - [ ] `[ios_switches]` - Switch devices only
  - [ ] `[ios_routers]` - Router devices only
  - [ ] `[fmc_management]` - FMC servers

### Step 2: Variable Setup
- [ ] Review `group_vars/all.yml`
- [ ] Update global variables:
  - [ ] `domain_name`
  - [ ] `ntp_servers`
  - [ ] `dns_servers`
  - [ ] `syslog_servers`
  - [ ] `tacacs_servers` (if using TACACS+)
- [ ] Review `group_vars/ios_devices.yml`
- [ ] Review `group_vars/fmc_devices.yml`

### Step 3: Credentials & Vault
- [ ] Create `.vault_pass` file:
  ```bash
  echo "your_secure_password" > ~/.vault_pass
  chmod 600 ~/.vault_pass
  ```
- [ ] Create encrypted vault file:
  ```bash
  ansible-vault create --vault-password-file ~/.vault_pass group_vars/all/vault.yml
  ```
- [ ] Add encrypted credentials:
  - [ ] `ios_user` / `ios_password`
  - [ ] `ios_enable_password`
  - [ ] `tacacs_shared_key` (if applicable)
  - [ ] `snmp_ro_community` / `snmp_rw_community` (if applicable)
  - [ ] `fmc_admin_user` / `fmc_admin_password`
  - [ ] `ftd_user` / `ftd_password`

### Step 4: Device-Specific Configuration
- [ ] Create/update host variables for each device:
  - [ ] `host_vars/core-switch-01.yml`
  - [ ] `host_vars/distribution-router-01.yml`
  - [ ] `host_vars/ftd-sensor-01.yml`
  - [ ] Configure interface details
  - [ ] Configure VLAN assignments
  - [ ] Configure routing protocols
  - [ ] Configure security policies

### Step 5: Pre-Deployment Validation
- [ ] Test inventory parsing:
  ```bash
  ansible-inventory -i inventory.ini --list
  ```
- [ ] Test device connectivity:
  ```bash
  ./execute.sh ping all
  ```
- [ ] Verify Ansible facts collection:
  ```bash
  ./execute.sh facts
  ```
- [ ] Run syntax check:
  ```bash
  ansible-playbook site.yml --syntax-check
  ```
- [ ] Run lint check:
  ```bash
  ansible-lint
  ```

## Day-to-Day Operations

### Pre-Deployment
- [ ] Create pre-deployment backup:
  ```bash
  ./execute.sh backup all
  ```
- [ ] Review change plan
- [ ] Notify stakeholders
- [ ] Schedule maintenance window

### Deployment
- [ ] Day 0 Provisioning:
  - [ ] `./execute.sh day0 all` (or specific device)
  - [ ] Verify configuration applied
  - [ ] Check logs for errors
  
- [ ] Day 1 Deployment:
  - [ ] `./execute.sh day1 all` (or specific device)
  - [ ] Verify interfaces are UP
  - [ ] Verify OSPF neighbors
  - [ ] Review configuration
  
- [ ] Day 2 Operations:
  - [ ] `./execute.sh day2 all`
  - [ ] Validate health checks
  - [ ] Review compliance reports

### Post-Deployment
- [ ] Verify all devices responding
- [ ] Check backup creation
- [ ] Review generated reports
- [ ] Document any issues
- [ ] Commit changes to Git (if applicable)

## Operational Tasks

### Regular Backups
- [ ] Schedule automated backups:
  ```bash
  0 2 * * * cd /path/to/framework && ./execute.sh backup all
  ```
- [ ] Verify backup files exist
- [ ] Test backup restore procedure

### Configuration Compliance
- [ ] Run drift detection weekly:
  ```bash
  ./execute.sh drift all
  ```
- [ ] Review compliance reports
- [ ] Address any drift findings
- [ ] Update baselines

### Device Health Monitoring
- [ ] Run health checks daily:
  ```bash
  0 * * * * cd /path/to/framework && ./execute.sh day2 all
  ```
- [ ] Monitor CPU/memory utilization
- [ ] Check interface status
- [ ] Verify OSPF neighbors

### OS Upgrades
- [ ] Plan upgrade window
- [ ] Prepare upgrade image
- [ ] Create pre-upgrade backup
- [ ] Execute upgrade:
  ```bash
  ./execute.sh full --extra-vars "perform_os_upgrade=true"
  ```
- [ ] Verify post-upgrade functionality
- [ ] Review upgrade reports

## Security & Compliance

### Credentials Management
- [ ] Never commit `.vault_pass` to Git
- [ ] Never commit unencrypted credentials
- [ ] Rotate credentials regularly
- [ ] Use strong vault passwords
- [ ] Restrict file permissions (chmod 600)

### Change Management
- [ ] Document all changes
- [ ] Maintain change log
- [ ] Version control playbooks
- [ ] Use Git branches for development
- [ ] Require code reviews before merging

### Audit & Compliance
- [ ] Enable device syslog collection
- [ ] Archive configuration backups
- [ ] Maintain compliance reports
- [ ] Review audit logs regularly
- [ ] Document compliance findings

## Troubleshooting Guide

If deployment fails:

1. **Check connectivity:**
   ```bash
   ansible all -m ping --vault-password-file ~/.vault_pass
   ```

2. **Review logs:**
   ```bash
   tail -f logs/ansible.log
   ```

3. **Run in verbose mode:**
   ```bash
   ansible-playbook site.yml -vvv --vault-password-file ~/.vault_pass
   ```

4. **Check specific task:**
   ```bash
   ansible-playbook site.yml --tags day0 --step \
     --vault-password-file ~/.vault_pass
   ```

5. **Verify credentials:**
   ```bash
   ansible-vault view --vault-password-file ~/.vault_pass \
     group_vars/all/vault.yml
   ```

6. **Check device connectivity manually:**
   ```bash
   ssh -l admin 192.168.1.10
   ```

## Support Contacts

- **Network Team:** network-team@example.com
- **Automation Team:** automation@example.com
- **Emergency:** on-call@example.com

## Documentation Links

- README.md - Complete framework documentation
- QUICKSTART.md - 5-minute setup guide
- EXECUTION_EXAMPLES.md - Usage examples
- PROJECT_STRUCTURE.md - Detailed structure overview
- ansible.cfg - Ansible configuration options