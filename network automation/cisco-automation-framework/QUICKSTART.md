# QUICK START GUIDE

## 5-Minute Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Create Vault File
```bash
echo "your_password" > ~/.vault_pass
chmod 600 ~/.vault_pass
```

### 3. Update Inventory
Edit `inventory.ini` - add your devices:
```ini
[ios_devices]
my-switch ansible_host=192.168.1.10
my-router ansible_host=192.168.1.20
```

### 4. Edit Credentials
```bash
ansible-vault create group_vars/all/vault.yml
# Add these lines and save:
ios_user: admin
ios_password: yourpassword
ios_enable_password: enablepassword
```

### 5. Test Connection
```bash
ansible ios_devices -m ping --vault-password-file ~/.vault_pass
```

### 6. Run Provisioning (Day 0)
```bash
ansible-playbook site.yml --tags day0 --vault-password-file ~/.vault_pass
```

## Quick Commands

```bash
# Backup all configs
ansible-playbook playbooks/backup.yml -vault-password-file ~/.vault_pass

# Check device health
ansible-playbook playbooks/collect_facts.yml --vault-password-file ~/.vault_pass

# Detect drift
ansible-playbook playbooks/drift_detection.yml --vault-password-file ~/.vault_pass

# Dry-run (check mode)
ansible-playbook site.yml --check --vault-password-file ~/.vault_pass

# Verbose output
ansible-playbook site.yml -vvv --vault-password-file ~/.vault_pass
```

## File Customization Checklist

- [ ] Update `inventory.ini` with your devices
- [ ] Create encrypted `group_vars/all/vault.yml`
- [ ] Customize `host_vars/core-switch-01.yml` for your switch
- [ ] Customize `host_vars/ftd-sensor-01.yml` for your FTD
- [ ] Update `group_vars/ios_devices.yml` with your VLAN/interface standards
- [ ] Configure `group_vars/fmc_devices.yml` with your FMC details
- [ ] Review `ansible.cfg` for your environment
- [ ] Test SSH connectivity before running playbooks

## Support

For issues or questions, check:
1. ansible.cfg settings
2. Vault password file permissions
3. SSH key setup (if using key-based auth)
4. Device credentials (enable mode access required)
5. Network connectivity to management interfaces