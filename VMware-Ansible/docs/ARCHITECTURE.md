# VMware Ansible - Architecture & Best Practices

## 📐 Project Architecture

### Three-Phase Deployment Model

```
┌─────────────────────────────────────────────────────────────────┐
│                    VMware Ansible Automation                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Day 0: Foundation              Day 1: Provisioning              │
│  ─────────────────              ──────────────────               │
│  • Datacenters                  • VM Cloning                     │
│  • Clusters                     • Customization                  │
│  • Folder Hierarchy             • Hardware Adjust                │
│  • DVS/Port Groups                                               │
│                                  Day 2: Administration            │
│                                  ──────────────────              │
│                                  • Snapshots                      │
│                                  • Power Management               │
│                                  • Host Maintenance               │
│                                  • Reporting                      │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Component Relationships

```
Inventory (hosts)
    ↓
Group Variables (vmware_infrastructure.yml)
    ↓
Vault Encryption (vault.yml)
    ↓
Playbooks (day0/day1/day2)
    ↓
Roles (foundation, provisioning, administration)
    ↓
Tasks + Templates + Handlers
    ↓
VMware vSphere Infrastructure
```

## 🎯 Role Structure & Purpose

### Foundation Roles (Day 0)

```
foundation/
├── datacenter/          # Creates vSphere datacenters
│   ├── tasks/main.yml   # Create/manage datacenters
│   └── vars/main.yml    # State configuration
│
├── cluster/             # Configures clusters with DRS/HA
│   ├── tasks/main.yml   # Cluster setup with policies
│   ├── vars/main.yml    # DRS/HA settings
│   └── handlers/        # Cluster events
│
├── folders/             # Organizes VM hierarchies
│   ├── tasks/main.yml   # Create folder trees
│   ├── vars/main.yml    # Folder structure
│   └── handlers/        # Folder events
│
└── dvs/                 # Distributed Virtual Switches
    ├── tasks/main.yml   # DVS + port group creation
    ├── vars/main.yml    # Network settings
    ├── templates/       # DVS configurations
    └── handlers/        # Network events
```

**Usage Flow:**
```
datacenter created → cluster added to DC → folders organized → DVS deployed
```

### Provisioning Roles (Day 1)

```
provisioning/
├── vm_clone/            # Clone VMs from templates
│   ├── tasks/main.yml   # Clone logic with placement
│   ├── vars/main.yml    # Clone defaults
│   └── handlers/        # Post-clone events
│
├── customization/       # Configure OS-level settings
│   ├── tasks/main.yml   # Hostname, IP, DNS setup
│   ├── vars/main.yml    # Default values
│   └── handlers/        # Customization events
│
└── hardware/            # Adjust CPU, RAM, Disk
    ├── tasks/main.yml   # Hardware modifications
    ├── vars/main.yml    # Hardware defaults
    └── handlers/        # Capacity recalculation
```

**Usage Flow:**
```
clone VM → customize guest OS → adjust hardware → VM ready
```

### Administration Roles (Day 2)

```
administration/
├── snapshots/           # Snapshot lifecycle
│   ├── tasks/main.yml   # Create/remove/revert
│   ├── vars/main.yml    # Retention policies
│   └── handlers/        # Storage updates
│
├── power_management/    # VM power control
│   ├── tasks/main.yml   # On/off/restart logic
│   ├── vars/main.yml    # Power settings
│   └── handlers/        # State tracking
│
├── host_maintenance/    # Host maintenance + vMotion
│   ├── tasks/main.yml   # Maint mode/evacuation
│   ├── vars/main.yml    # Timeout settings
│   └── handlers/        # vMotion tracking
│
└── reporting/           # Infrastructure inventory
    ├── tasks/main.yml   # Report generation
    ├── vars/main.yml    # Report format
    └── handlers/        # Report archival
```

**Usage Flow:**
```
VM operations → snapshots/backups → maintenance → reporting
```

## 🔒 Security Design

### Credential Management

```yaml
# NEVER commit credentials to version control
# Use Ansible Vault for sensitive data

group_vars/
├── vmware_infrastructure.yml    # Public configuration
└── vmware_infrastructure/
    └── vault.yml                # Encrypted with ansible-vault
       (contains: vcenter_hostname, username, password)
```

**Vault Usage:**
```bash
# Create encrypted file
ansible-vault create group_vars/vmware_infrastructure/vault.yml

# Reference in playbooks (automatic decryption)
- name: Connect to vCenter
  vmware_guest:
    hostname: "{{ vault_vcenter_hostname }}"
    username: "{{ vault_vcenter_username }}"
    password: "{{ vault_vcenter_password }}"
```

### Access Control Pattern

```yaml
# All VMware operations use delegate_to: localhost
# This runs VMware module on Ansible controller, not vCenter

- name: Create VM
  vmware_guest:
    ...
  delegate_to: localhost    # Runs locally, not on SSH target
  # No SSH needed to vCenter - credentials handled locally
```

## 🏗️ Idempotency Design

All roles follow idempotent principles:

```
First Run:  Provision → Create resources → CHANGED=True
Second Run: Provision → Resources exist → CHANGED=False
Third Run:  Provision → Resources exist → CHANGED=False
```

### Example: VM Cloning

```yaml
- name: Clone VM from template
  vmware_guest:
    name: "{{ vm_name }}"
    template: "{{ vm_template }}"
    state: present        # Idempotent key
  # If VM exists: skips cloning (changed=false)
  # If VM missing: creates VM (changed=true)
  # Result is always: VM exists
```

## 📊 Tag Strategy

Use tags for selective execution:

```bash
# Execute specific operation
ansible-playbook playbooks/day0/foundation.yml --tags=datacenter

# Multiple tags (OR logic)
ansible-playbook playbooks/day2/admin.yml --tags=snapshots,power

# Exclude tags (skip operations)
ansible-playbook playbooks/day1/provision.yml --skip-tags=hardware
```

### Tag Hierarchy

```
day0          ← All Day 0 operations
├─ foundation ← All foundation roles
│  ├─ datacenter
│  ├─ cluster
│  ├─ folders
│  └─ dvs
│
day1          ← All Day 1 operations
├─ provisioning ← All provisioning roles
│  ├─ clone
│  ├─ customization
│  └─ hardware
│
day2          ← All Day 2 operations
├─ administration ← All admin roles
│  ├─ snapshots
│  ├─ power
│  ├─ maintenance
│  └─ reporting
```

## 🔄 Error Handling

### Assertion Validation

```yaml
- name: Validate required variables
  assert:
    that:
      - vm_name is defined
      - vm_template is defined
    fail_msg: "Missing required: vm_name, vm_template"
    success_msg: "All variables present"
```

### Conditional Execution

```yaml
- name: Clone VM
  vmware_guest:
    ...
  when:
    - clone_state == "present"
    - vm_name is defined
    - vm_template is defined
```

### Retry Logic

```yaml
- name: Wait for VM IP
  vmware_guest_info:
    ...
  register: vm_info
  until: vm_info.instance.ipv4 is defined
  retries: 120
  delay: 5
```

## 📈 Scalability Considerations

### Batch Operations

```bash
# Provision 10 VMs in parallel
for i in {1..10}; do
  ansible-playbook playbooks/day1/provision.yml \
    --extra-vars="vm_name=web-$i" &
done
wait
```

### Multi-Datacenter

```yaml
# group_vars supports multiple environments
group_vars/
├── vmware_infrastructure.yml     # Global config
├── vmware_infrastructure/vault.yml
├── vmware_prod.yml              # Production overrides
├── vmware_dev.yml               # Development overrides
└── vmware_dr.yml                # DR site overrides
```

## 🧪 Testing & Validation

### Pre-flight Checks

```yaml
pre_tasks:
  - name: Verify vCenter connectivity
    vmware_about_info:
      hostname: "{{ vcenter_hostname }}"
      ...
    register: vcenter_info

  - name: Validate configuration
    assert:
      that:
        - vcenter_info.about is defined
        - datacenter_name in vcenter_facts
```

### Post-deployment Verification

```yaml
post_tasks:
  - name: Verify VM is running
    vmware_guest_info:
      ...
    register: vm_final_state
    
  - name: Assert VM operational
    assert:
      that:
        - vm_final_state.instance.powerstate == "poweredOn"
        - vm_final_state.instance.ipv4 is defined
```

## 📋 Playbook Organization

### Single Purpose

Each playbook has one primary function:

```yaml
# playbooks/day0/foundation.yml → Set up infrastructure
# playbooks/day1/provision.yml  → Deploy VMs
# playbooks/day2/admin.yml      → Manage operations
```

### Reusability

Roles are independent and reusable:

```bash
# Use in multiple playbooks
playbooks/day0/foundation.yml (uses foundation/cluster)
playbooks/day1/scale_out.yml   (uses foundation/folders)
playbooks/day2/audit.yml       (uses administration/reporting)
```

## 🔧 Customization Points

### Override Variables

```yaml
# Priority order (highest to lowest):
1. Extra vars (--extra-vars)
2. Host variables
3. Group variables (group_vars/vmware_infrastructure.yml)
4. Role variables (roles/*/vars/main.yml)
5. Role defaults (roles/*/defaults/main.yml)
```

### Extend with Custom Filters

Create `filter_plugins/custom_vmware.py`:

```python
def vcenter_fqdn(hostname):
    """Convert short hostname to FQDN"""
    if '.' not in hostname:
        return f"{hostname}.example.com"
    return hostname

class FilterModule(object):
    def filters(self):
        return {
            'vcenter_fqdn': vcenter_fqdn,
        }
```

Usage in playbooks:

```yaml
- debug:
    msg: "{{ vcenter_hostname | vcenter_fqdn }}"
```

## 📚 Documentation Best Practices

### Inline Comments

```yaml
- name: Clone VM from template
  vmware_guest:
    name: "{{ vm_name }}"           # New VM name
    template: "{{ vm_template }}"   # Source template
    datacenter: "{{ datacenter_name }}"  # Target DC
```

### README in Roles

```
roles/provisioning/vm_clone/
├── README.md              # Role documentation
├── tasks/main.yml
└── vars/main.yml
```

### Playbook Documentation

```yaml
---
# ==============================================================================
# Provision VMs from Templates
# ==============================================================================
# Prerequisites: Day 0 foundation must be complete
# Variables required: vm_name, vm_template, datacenter_name
# Tags: day1, provisioning, clone
```

## 🎓 Learning Resources

1. **Official Collections**: https://github.com/ansible-collections/community.vmware
2. **VMware API**: https://docs.vmware.com/en/VMware-vSphere
3. **Ansible Best Practices**: https://docs.ansible.com/ansible/latest/tips_tricks/
4. **Example Playbooks**: Review `/playbooks` directory

## ✅ Implementation Checklist

- [ ] Install dependencies: `pip install -r requirements.txt`
- [ ] Install collections: `ansible-galaxy install -r requirements.yml`
- [ ] Create vault file with credentials
- [ ] Update inventory with vCenter details
- [ ] Customize group_vars for your environment
- [ ] Test Day 0 foundation setup
- [ ] Test Day 1 VM provisioning
- [ ] Test Day 2 administration tasks
- [ ] Document custom extensions
- [ ] Implement backup strategy for configurations
- [ ] Set up monitoring/logging for playbooks

---

**Ready to automate VMware!** Start with [QUICK_START.md](QUICK_START.md) and refer to [EXAMPLES.md](EXAMPLES.md) for common scenarios.
