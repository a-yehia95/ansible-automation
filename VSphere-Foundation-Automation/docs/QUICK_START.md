# Quick Start Guide - VMware vSphere Foundation Automation

## 5-Minute Setup

### 1. Install Collections

```bash
ansible-galaxy collection install -r requirements.yml
```

### 2. Setup Vault Password

```bash
cp .vault_pass.example .vault_pass
echo "your-secure-password" > .vault_pass
chmod 600 .vault_pass
```

### 3. Configure vCenter Connection

Edit `inventory/group_vars/vcenter_servers/main.yml`:

```yaml
vcenter_hostname: "your-vcenter.example.com"
vcenter_username: "administrator@vsphere.local"
environment_name: "production"
datacenter_name: "Datacenter1"
```

### 4. Encrypt Credentials

```bash
ansible-vault encrypt inventory/group_vars/vcenter_servers/vault.yml
```

Edit vault file and add:

```yaml
vault_vcenter_password: "your-vcenter-password"
vault_esxi_password: "your-esxi-password"
```

### 5. Run Foundation Setup (Day 0)

```bash
ansible-playbook playbooks/day0/foundation.yml \
  --vault-password-file .vault_pass
```

---

## Common Operations

### Check vCenter Connectivity

```bash
ansible-playbook playbooks/master.yml \
  --tags vcenter_init \
  --vault-password-file .vault_pass
```

### Deploy Complete Infrastructure

```bash
# Preview changes
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --check

# Apply changes
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass
```

### Provision VMs

```bash
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass \
  --tags vm_provisioning
```

### Create VM Snapshots

```bash
ansible-playbook playbooks/day2/admin.yml \
  --vault-password-file .vault_pass \
  --tags snapshot_create
```

### Query Infrastructure Status

```bash
# List all VMs
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --tags vm_query

# List all datastores
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --tags datastore_query
```

---

## Configuration Examples

### Add New ESXi Host

In `inventory/group_vars/vcenter_servers/main.yml`:

```yaml
day0_config:
  hosts:
    - name: "esxi03.example.com"
      cluster: "Cluster1"
      username: "root"
      ntp_servers:
        - "ntp.example.com"
```

Then run:

```bash
ansible-playbook playbooks/day0/foundation.yml \
  --tags host_add \
  --vault-password-file .vault_pass
```

### Provision New VM

In `inventory/group_vars/vcenter_servers/main.yml`:

```yaml
day1_config:
  virtual_machines:
    - name: "appserver-01"
      template: "Ubuntu-22.04-Template"
      datacenter: "Datacenter1"
      cluster: "Cluster1"
      cpu: 8
      memory_mb: 16384
```

Then run:

```bash
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass
```

### Create Snapshot

In `inventory/group_vars/vcenter_servers/main.yml`:

```yaml
day2_config:
  snapshots_to_create:
    - vm_name: "webserver-01"
      snapshot_name: "pre-patch-snapshot"
```

Then run:

```bash
ansible-playbook playbooks/day2/admin.yml \
  --tags snapshot_create \
  --vault-password-file .vault_pass
```

---

## Troubleshooting

### Issue: "vault password file not found"

```bash
# Create and secure vault password file
cp .vault_pass.example .vault_pass
chmod 600 .vault_pass
```

### Issue: "Collection vmware.rest not found"

```bash
# Install collections
ansible-galaxy collection install -r requirements.yml

# Verify
ansible-galaxy collection list | grep vmware
```

### Issue: "Failed to connect to vCenter"

- Check hostname: `ping vcenter.example.com`
- Test connectivity: `curl -k https://vcenter.example.com/api/vcenter`
- Verify credentials in vault.yml
- Run with debug: `ansible-playbook playbooks/master.yml -vvv`

---

## Next Steps

1. Read full [README.md](README.md) for comprehensive guide
2. Review [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for file layout
3. Check example use cases in documentation
4. Customize for your environment
5. Test in staging before production

---

## Support

See troubleshooting sections in main README.md or review logs:

```bash
tail -f logs/ansible.log
```
