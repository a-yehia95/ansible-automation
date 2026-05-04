# VMware Ansible - Example Configurations

This document provides configuration examples for different scenarios and environments.

## Scenario 1: Multi-Datacenter Production Setup

**Use Case**: Large enterprise with multiple datacenters requiring HA and DRS

Edit `group_vars/vmware_infrastructure.yml`:

```yaml
datacenters:
  - name: "Primary-DC"
    description: "Primary Production Datacenter - US East"
  - name: "Secondary-DC"
    description: "Secondary/DR Datacenter - US West"

clusters:
  - name: "Prod-Cluster-East-1"
    datacenter: "Primary-DC"
    enable_drs: true
    drs_automation_level: "fullyAutomated"
    enable_ha: true
    ha_failure_level: 2
    ha_isolation_response: "powerOff"
    
  - name: "Prod-Cluster-East-2"
    datacenter: "Primary-DC"
    enable_drs: true
    drs_automation_level: "fullyAutomated"
    enable_ha: true
    ha_failure_level: 2
    
  - name: "Prod-Cluster-West-1"
    datacenter: "Secondary-DC"
    enable_drs: true
    drs_automation_level: "partiallyAutomated"
    enable_ha: true
    ha_failure_level: 1

dvs_switches:
  - name: "DVS-Primary-East"
    datacenter: "Primary-DC"
    description: "Primary DVS for East datacenter"
    mtu: 1500
    num_uplinks: 4
  - name: "DVS-Secondary-West"
    datacenter: "Secondary-DC"
    description: "Secondary DVS for West datacenter"
    mtu: 1500
    num_uplinks: 2

vm_folders:
  - name: "Production"
    parent: "/"
    datacenter: "Primary-DC"
    children:
      - "Web-Tier"
      - "App-Tier"
      - "Database-Tier"
  - name: "Staging"
    parent: "/"
    datacenter: "Primary-DC"
    children:
      - "Web-Staging"
      - "App-Staging"
```

## Scenario 2: Development/Test Environment

**Use Case**: Smaller dev environment with minimal HA requirements

Edit `group_vars/vmware_infrastructure.yml`:

```yaml
datacenters:
  - name: "Dev-DC"
    description: "Development and Testing Datacenter"

clusters:
  - name: "Dev-Cluster"
    datacenter: "Dev-DC"
    enable_drs: true
    drs_automation_level: "manual"  # Manual DRS for dev
    enable_ha: false  # HA not needed for dev

dvs_switches:
  - name: "DVS-Dev"
    datacenter: "Dev-DC"
    description: "Development DVS"
    mtu: 1500
    num_uplinks: 2

# Smaller defaults for dev
vm_provisioning_defaults:
  cpu_count: 2
  memory_gb: 4
  disk_size_gb: 30
```

Run Day 0 setup:
```bash
ansible-playbook playbooks/day0/foundation.yml --vault-password-file=.vault_pass
```

## Scenario 3: Provision Web Server Tier

**Use Case**: Scale out a 3-tier web application

```bash
# Provision web tier (3 servers)
for i in {1..3}; do
  ansible-playbook playbooks/day1/provision.yml \
    --vault-password-file=.vault_pass \
    --extra-vars="{
      'vm_name': 'web-server-0$i',
      'vm_template': 'centos-9-base',
      'datacenter_name': 'Primary-DC',
      'cluster_name': 'Prod-Cluster-East-1',
      'vm_folder': 'Production/Web-Tier',
      'vm_hostname': 'web-server-0$i',
      'vm_domain': 'example.com',
      'vm_cpu_count': 4,
      'vm_memory_gb': 8,
      'vm_ip_address': '192.168.1.10$i',
      'vm_netmask': '255.255.255.0',
      'vm_gateway': '192.168.1.1'
    }"
done

# Create snapshots before deployment
for i in {1..3}; do
  ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
    --vault-password-file=.vault_pass \
    --extra-vars="{
      'vm_name': 'web-server-0$i',
      'datacenter_name': 'Primary-DC',
      'snapshot_state': 'present',
      'snapshot_name': 'post-deployment'
    }"
done
```

## Scenario 4: Windows Server Provisioning

**Use Case**: Deploy Windows Server applications

```bash
# Provision Windows server
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file=.vault_pass \
  --extra-vars='{
    "vm_name": "windows-app-01",
    "vm_template": "windows-2022-base",
    "datacenter_name": "Primary-DC",
    "cluster_name": "Prod-Cluster-East-1",
    "vm_hostname": "WINAPP01",
    "vm_domain": "example.com",
    "vm_os_type": "windows",
    "vm_cpu_count": 8,
    "vm_memory_gb": 16,
    "vm_disk_size_gb": 100,
    "windows_autologon": true,
    "windows_autologon_count": 1
  }'
```

## Scenario 5: Database Server with Additional Disks

**Use Case**: Deploy database server with separate data/log volumes

```bash
# Provision database server with multiple disks
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file=.vault_pass \
  --extra-vars='{
    "vm_name": "db-server-01",
    "vm_template": "centos-9-base",
    "datacenter_name": "Primary-DC",
    "cluster_name": "Prod-Cluster-East-1",
    "vm_folder": "Production/Database-Tier",
    "vm_hostname": "db-server-01",
    "vm_cpu_count": 16,
    "vm_memory_gb": 32,
    "vm_disk_size_gb": 100,
    "vm_additional_disks": [
      {
        "size_gb": 500,
        "type": "thick",
        "datastore": "SSD-Datastore-1"
      },
      {
        "size_gb": 300,
        "type": "thick",
        "datastore": "SSD-Datastore-1"
      }
    ]
  }'
```

## Scenario 6: Batch VM Deprovisioning

**Use Case**: Power off and snapshot multiple VMs for migration

```bash
# Create snapshots for all servers
SERVERS=("web-server-01" "web-server-02" "app-server-01" "db-server-01")

for server in "${SERVERS[@]}"; do
  ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
    --vault-password-file=.vault_pass \
    --extra-vars="{
      'vm_name': '$server',
      'datacenter_name': 'Primary-DC',
      'snapshot_state': 'present',
      'snapshot_name': 'pre-migration-$(date +%Y%m%d)'
    }"
done

# Power off all servers
ansible-playbook playbooks/day2/admin.yml --tags=power \
  --vault-password-file=.vault_pass \
  --extra-vars='{
    "vm_names": ["web-server-01", "web-server-02", "app-server-01", "db-server-01"],
    "datacenter_name": "Primary-DC",
    "power_state": "powered_off",
    "force_shutdown": false
  }'
```

## Scenario 7: Host Maintenance with vMotion

**Use Case**: Update ESXi hosts without downtime

```bash
# Verify current state
ansible-playbook playbooks/day2/admin.yml --tags=reporting \
  --vault-password-file=.vault_pass

# Put host in maintenance mode (VMs migrate via vMotion)
ansible-playbook playbooks/day2/admin.yml --tags=maintenance \
  --vault-password-file=.vault_pass \
  --extra-vars='{
    "cluster_name": "Prod-Cluster-East-1",
    "esxi_hosts": ["esxi1.example.com"],
    "maintenance_mode": "enter",
    "timeout_seconds": 1800
  }'

# [Perform maintenance on ESXi host...]
# SSH into esxi1 and perform updates, patches, etc.

# Exit maintenance mode (VMs return)
ansible-playbook playbooks/day2/admin.yml --tags=maintenance \
  --vault-password-file=.vault_pass \
  --extra-vars='{
    "cluster_name": "Prod-Cluster-East-1",
    "esxi_hosts": ["esxi1.example.com"],
    "maintenance_mode": "exit"
  }'

# Verify all VMs are back online
ansible-playbook playbooks/day2/admin.yml --tags=reporting \
  --vault-password-file=.vault_pass
```

## Scenario 8: Disaster Recovery Test

**Use Case**: Test DR capabilities by reverting to known-good snapshots

```bash
# Create pre-test snapshots
SERVERS=("web-server-01" "app-server-01" "db-server-01")

for server in "${SERVERS[@]}"; do
  ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
    --vault-password-file=.vault_pass \
    --extra-vars="{
      'vm_name': '$server',
      'datacenter_name': 'Primary-DC',
      'snapshot_state': 'present',
      'snapshot_name': 'dr-test-baseline'
    }"
done

# Run chaos/failover tests...

# Revert to known good state
for server in "${SERVERS[@]}"; do
  ansible-playbook playbooks/day2/admin.yml --tags=snapshots \
    --vault-password-file=.vault_pass \
    --extra-vars="{
      'vm_name': '$server',
      'datacenter_name': 'Primary-DC',
      'snapshot_state': 'revert',
      'snapshot_name': 'dr-test-baseline'
    }"
done
```

## Scenario 9: Automated Reporting

**Use Case**: Generate infrastructure reports on schedule (cron)

Create shell script `/opt/scripts/vmware_reporting.sh`:

```bash
#!/bin/bash

REPORT_DATE=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="/reports/vmware"

cd /path/to/VMware-Ansible

# Generate comprehensive report
ansible-playbook playbooks/day2/admin.yml --tags=reporting \
  --vault-password-file=.vault_pass

# Archive reports
tar -czf "${REPORT_DIR}/vmware_reports_${REPORT_DATE}.tar.gz" /tmp/vmware_reports/

# Email report (optional)
# mail -s "VMware Infrastructure Report - $REPORT_DATE" admin@example.com < /tmp/vmware_reports/SUMMARY_*.txt
```

Add to crontab for daily reports at 2 AM:
```cron
0 2 * * * /opt/scripts/vmware_reporting.sh
```

## Scenario 10: High-Performance VM Deployment

**Use Case**: Deploy low-latency, high-throughput VMs

```bash
ansible-playbook playbooks/day1/provision.yml \
  --vault-password-file=.vault_pass \
  --extra-vars='{
    "vm_name": "hpc-compute-01",
    "vm_template": "centos-9-base",
    "datacenter_name": "Primary-DC",
    "cluster_name": "Prod-Cluster-East-1",
    "vm_hostname": "hpc-compute-01",
    "vm_cpu_count": 32,
    "vm_memory_gb": 128,
    "vm_cpu_cores_per_socket": 16,
    "vm_disk_size_gb": 500,
    "vm_additional_disks": [
      {"size_gb": 1000, "type": "thick"}
    ],
    "allow_hotplug_cpu": true,
    "allow_hotplug_memory": true
  }'
```

---

For more information, see [README.md](README.md) and role-specific documentation.
