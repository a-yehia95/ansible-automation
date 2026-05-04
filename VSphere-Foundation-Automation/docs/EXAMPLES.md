# VMware vSphere Foundation - Real-World Examples

## Example 1: Complete Production Deployment

### Scenario
Deploy a production vSphere environment with 2 ESXi hosts, 3 datacenters, and 10 VMs.

### Configuration

**inventory/group_vars/vcenter_servers/main.yml**:

```yaml
# Environment
environment_name: "production"
datacenter_name: "DC-US-East"
cluster_name: "Prod-Cluster-01"

# Day 0 Configuration
day0_config:
  datacenter:
    name: "DC-US-East"
    description: "US East Production Datacenter"
    state: present

  clusters:
    - name: "Prod-Cluster-01"
      datacenter: "DC-US-East"
      ha_enabled: true
      drs_enabled: true
      drs_automation_level: "fullyAutomated"
      vsan_enabled: false

  resource_pools:
    - name: "Production"
      cpu_shares: 4000
      memory_shares: 4000
    - name: "Development"
      cpu_shares: 2000
      memory_shares: 2000
    - name: "Testing"
      cpu_shares: 1000
      memory_shares: 1000

  hosts:
    - name: "esxi01.prod.example.com"
      cluster: "Prod-Cluster-01"
      username: "root"
      ntp_servers:
        - "ntp01.example.com"
        - "ntp02.example.com"
    - name: "esxi02.prod.example.com"
      cluster: "Prod-Cluster-01"
      username: "root"
      ntp_servers:
        - "ntp01.example.com"
        - "ntp02.example.com"

  datastores:
    - name: "prod-vmfs-01"
      datastore_type: "vmfs"
      datacenter: "DC-US-East"
    - name: "prod-nfs-01"
      datastore_type: "nfs"
      nfs_server: "nfs01.example.com"
      nfs_path: "/export/vmware/prod"
      nfs_version: "nfs41"

# Day 1 Configuration
day1_config:
  vm_templates:
    - name: "Ubuntu-22.04-Template"
    - name: "CentOS-8-Template"
    - name: "Windows-2022-Template"

  virtual_machines:
    - name: "web-prod-01"
      template: "Ubuntu-22.04-Template"
      datacenter: "DC-US-East"
      resource_pool: "Production"
      cpu: 4
      memory_mb: 8192
      
    - name: "web-prod-02"
      template: "Ubuntu-22.04-Template"
      datacenter: "DC-US-East"
      resource_pool: "Production"
      cpu: 4
      memory_mb: 8192
      
    - name: "db-prod-01"
      template: "CentOS-8-Template"
      datacenter: "DC-US-East"
      resource_pool: "Production"
      cpu: 8
      memory_mb: 16384
      disks:
        - size_gb: 100

# Day 2 Configuration
day2_config:
  snapshot_policy:
    enabled: true
    retention_days: 7
    frequency: "daily"
```

### Execution

```bash
# Step 1: Deploy Foundation (Day 0)
ansible-playbook playbooks/day0/foundation.yml \
  --vault-password-file .vault_pass \
  -v

# Step 2: Provision VMs (Day 1)
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass \
  -v

# Step 3: Create initial snapshots (Day 2)
ansible-playbook playbooks/day2/admin.yml \
  --tags snapshot_create \
  --vault-password-file .vault_pass \
  -v
```

### Expected Output

```
Day 0 Foundation Operations - Complete
Infrastructure Status:
  - Datacenter: CONFIGURED
  - Cluster: CONFIGURED (HA/DRS enabled)
  - ESXi Hosts: ADDED (2 hosts)
  - Datastores: MOUNTED (1 VMFS + 1 NFS)

Day 1 Provisioning Operations - Complete
Infrastructure Status:
  - Resource Pools: CREATED (3 pools)
  - Virtual Machines: PROVISIONED (10 VMs)
  - Networks: CONFIGURED

Day 2 Administration Operations - Complete
Infrastructure Status:
  - VM Lifecycle: MANAGED
  - Snapshots: CREATED
```

---

## Example 2: Scale-Out Application Deployment

### Scenario
Add 5 new application servers to an existing cluster while maintaining resource limits.

### Configuration

```yaml
day1_config:
  virtual_machines:
    - name: "appserver-prod-01"
      template: "Ubuntu-22.04-Template"
      datacenter: "DC-US-East"
      cluster: "Prod-Cluster-01"
      resource_pool: "Production"
      cpu: 8
      memory_mb: 16384
      networks:
        - name: "Production-VLAN"
          ipv4: "192.168.10.101"

    - name: "appserver-prod-02"
      template: "Ubuntu-22.04-Template"
      datacenter: "DC-US-East"
      resource_pool: "Production"
      cpu: 8
      memory_mb: 16384
      networks:
        - name: "Production-VLAN"
          ipv4: "192.168.10.102"

    - name: "appserver-prod-03"
      template: "Ubuntu-22.04-Template"
      datacenter: "DC-US-East"
      resource_pool: "Production"
      cpu: 8
      memory_mb: 16384
      networks:
        - name: "Production-VLAN"
          ipv4: "192.168.10.103"

    - name: "appserver-prod-04"
      template: "Ubuntu-22.04-Template"
      datacenter: "DC-US-East"
      resource_pool: "Production"
      cpu: 8
      memory_mb: 16384
      networks:
        - name: "Production-VLAN"
          ipv4: "192.168.10.104"

    - name: "appserver-prod-05"
      template: "Ubuntu-22.04-Template"
      datacenter: "DC-US-East"
      resource_pool: "Production"
      cpu: 8
      memory_mb: 16384
      networks:
        - name: "Production-VLAN"
          ipv4: "192.168.10.105"
```

### Execution

```bash
# Check what will be deployed
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass \
  --check

# Deploy
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass \
  --tags vm_provisioning
```

### Verification

```bash
# Query provisioned VMs
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --tags vm_query \
  -v
```

---

## Example 3: Multi-Environment Setup

### Scenario
Manage production, staging, and development environments with different configurations.

### Directory Structure

```
inventory/group_vars/
├── production/
│   ├── main.yml
│   └── vault.yml
├── staging/
│   ├── main.yml
│   └── vault.yml
└── development/
    ├── main.yml
    └── vault.yml

inventory/hosts:
  [production]
  vcenter-prod ansible_host=vcenter-prod.example.com
  
  [staging]
  vcenter-stage ansible_host=vcenter-stage.example.com
  
  [development]
  vcenter-dev ansible_host=vcenter-dev.example.com
```

### Execution

```bash
# Deploy to production
ansible-playbook playbooks/master.yml \
  --limit production \
  --vault-password-file .vault_pass

# Deploy to staging
ansible-playbook playbooks/master.yml \
  --limit staging \
  --vault-password-file .vault_pass

# Deploy to development
ansible-playbook playbooks/master.yml \
  --limit development \
  --vault-password-file .vault_pass
```

---

## Example 4: Disaster Recovery - Snapshot and Restore

### Scenario
Create daily snapshots for backup and restore a VM from a previous snapshot.

### Daily Backup Job

**Create cron job**:

```bash
0 2 * * * cd /opt/ansible && \
  ansible-playbook playbooks/day2/admin.yml \
  --tags snapshot_create \
  --vault-password-file .vault_pass >> logs/snapshot_backup.log 2>&1
```

**Configuration**:

```yaml
day2_config:
  snapshots_to_create:
    - vm_name: "webserver-01"
      snapshot_name: "daily-backup-{{ ansible_date_time.iso8601_basic_short }}"
      include_memory: false
      quiesce: true
    
    - vm_name: "database-01"
      snapshot_name: "daily-backup-{{ ansible_date_time.iso8601_basic_short }}"
      include_memory: false
      quiesce: true
```

### Restore from Snapshot

**Configuration**:

```yaml
day2_config:
  snapshots_to_revert:
    - vm_name: "webserver-01"
      snapshot_name: "daily-backup-20260428T020000"
```

**Execution**:

```bash
ansible-playbook playbooks/day2/admin.yml \
  --tags snapshot_revert \
  --vault-password-file .vault_pass
```

---

## Example 5: Host Maintenance with vMotion

### Scenario
Put a host into maintenance mode and migrate all VMs.

### Configuration

```yaml
day2_config:
  maintenance_windows:
    - name: "esxi02 maintenance"
      host: "esxi02.example.com"
      maintenance_mode: true
      vmigration_enabled: true
      target_host: "esxi01.example.com"
```

### Execution

```bash
# Enter maintenance mode (automatically migrates VMs)
ansible-playbook playbooks/day2/admin.yml \
  --tags host_maintenance \
  --vault-password-file .vault_pass

# Perform maintenance...

# Exit maintenance mode
ansible-playbook playbooks/day2/admin.yml \
  --tags host_maintenance_exit \
  --vault-password-file .vault_pass
```

---

## Example 6: VM Cloning at Scale

### Scenario
Clone 20 test VMs for load testing from a template.

### Configuration

```yaml
day1_config:
  virtual_machines:
    {% for i in range(1, 21) %}
    - name: "loadtest-vm-{{ i }}"
      template: "Ubuntu-22.04-Template"
      datacenter: "DC-US-East"
      resource_pool: "Testing"
      cpu: 2
      memory_mb: 4096
    {% endfor %}
```

### Execution

```bash
# Clone all VMs
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass \
  --tags vm_clone

# Power on all VMs
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass \
  --tags vm_power
```

---

## Example 7: VM Retirement and Cleanup

### Scenario
Remove 5 old development VMs and their snapshots.

### Configuration

```yaml
day2_config:
  snapshots_to_delete:
    - vm_name: "dev-vm-01"
      remove_children: true
    - vm_name: "dev-vm-02"
      remove_children: true
    - vm_name: "dev-vm-03"
      remove_children: true
    - vm_name: "dev-vm-04"
      remove_children: true
    - vm_name: "dev-vm-05"
      remove_children: true

  vms_to_delete:
    - vm_name: "dev-vm-01"
    - vm_name: "dev-vm-02"
    - vm_name: "dev-vm-03"
    - vm_name: "dev-vm-04"
    - vm_name: "dev-vm-05"
```

### Execution

```bash
# Delete snapshots first
ansible-playbook playbooks/day2/admin.yml \
  --tags snapshot_delete \
  --vault-password-file .vault_pass \
  --check  # Always check first!

# Delete VMs
ansible-playbook playbooks/day2/admin.yml \
  --tags vm_delete \
  --vault-password-file .vault_pass \
  --check  # Always check first!
```

---

## Example 8: Network Configuration - vDS Setup

### Scenario
Configure a distributed virtual switch with multiple port groups for different workloads.

### Configuration

```yaml
networking:
  vds:
    - name: "vds-prod-01"
      datacenter: "DC-US-East"
      version: "7.0.0"
      mtu: 1500
      description: "Production vDistributed Switch"
      portgroups:
        - name: "Production-VLAN"
          vlan_id: 100
          num_ports: 128
          type: "earlyBinding"

        - name: "Database-VLAN"
          vlan_id: 101
          num_ports: 64
          type: "earlyBinding"

        - name: "Management-VLAN"
          vlan_id: 200
          num_ports: 32
          type: "earlyBinding"

        - name: "vMotion-VLAN"
          vlan_id: 201
          num_ports: 32
          type: "earlyBinding"

        - name: "VSAN-VLAN"
          vlan_id: 202
          num_ports: 32
          type: "earlyBinding"
```

### Execution

```bash
ansible-playbook playbooks/day1/provision.yml \
  --tags network_config \
  --vault-password-file .vault_pass
```

---

## Example 9: Tag-Based Resource Organization

### Scenario
Tag VMs for automated resource management and reporting.

### Configuration

```yaml
tags:
  - name: "Environment"
    description: "Environment category"
    cardinality: "SINGLE"
    values:
      - "production"
      - "staging"
      - "development"

  - name: "Application"
    description: "Application category"
    cardinality: "MULTIPLE"
    values:
      - "web"
      - "database"
      - "cache"
      - "monitoring"

  - name: "CostCenter"
    description: "Cost Center for billing"
    cardinality: "SINGLE"
    values:
      - "engineering"
      - "operations"
      - "marketing"
```

### Application

```yaml
day2_config:
  virtual_machines:
    - name: "web-prod-01"
      tags:
        - name: "production"
        - name: "web"
        - name: "engineering"
```

---

## Tips & Tricks

### 1. Parallel Execution

```bash
# Deploy multiple VMs faster (reduce serialization)
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file .vault_pass \
  --forks=20  # Increase parallel forks
```

### 2. Conditional Execution

```bash
# Only run for specific clusters
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  -e "target_cluster=Prod-Cluster-01"
```

### 3. Dry Run Before Production

```bash
# Always use --check mode first
ansible-playbook playbooks/master.yml \
  --vault-password-file .vault_pass \
  --check \
  --diff
```

### 4. Monitor Execution

```bash
# Watch logs in real-time
tail -f logs/ansible.log | grep -i error
```

### 5. Rollback Strategy

```bash
# Keep previous configuration as snapshot
ansible-playbook playbooks/day2/admin.yml \
  --tags snapshot_create \
  --vault-password-file .vault_pass
```

---

**Last Updated**: April 2026
**Version**: 1.0.0
