# Cisco Automation Framework - Architecture Overview

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     ANSIBLE CONTROL NODE                         │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ Cisco Automation Framework (IaC Repository)               │  │
│  │                                                            │  │
│  │  site.yml (Master Orchestration)                         │  │
│  │    ├─ Day 0: Provisioning (common role)                  │  │
│  │    ├─ Day 1: Deployment (ios_config, fmc_security)       │  │
│  │    ├─ Day 2: Operations (validation, backup)             │  │
│  │    └─ Maintenance (OS upgrades)                          │  │
│  │                                                            │  │
│  │  Supporting Playbooks:                                    │  │
│  │    ├─ collect_facts.yml                                  │  │
│  │    ├─ drift_detection.yml                                │  │
│  │    └─ restore_config.yml                                 │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
└────────────────┬──────────────────────────────────────────────────┘
                 │
                 │ SSH / Network CLI
                 │
    ┌────────────┴──────────────────────┐
    │                                   │
    ▼                                   ▼
┌─────────────────────┐      ┌──────────────────────┐
│   IOS DEVICES       │      │  FIREPOWER DEVICES   │
│   (network_cli)     │      │  (httpapi / SSH)     │
│                     │      │                      │
│ ├─ Switches         │      │ ├─ FTD Sensors       │
│ │  ├─ GE1/0/1       │      │ │  ├─ Inside Int     │
│ │  ├─ GE1/0/2       │      │ │  ├─ Outside Int    │
│ │  └─ Trunk links   │      │ │  └─ Mgmt Int       │
│ │                   │      │ │                    │
│ ├─ Routers          │      │ └─ FMC Management    │
│ │  ├─ OSPF neighbors│      │    └─ Central control│
│ │  ├─ BGP peers     │      │                      │
│ │  └─ WAN links     │      │                      │
│ │                   │      │                      │
│ └─ Config backup ◄──┼──────┼──► Backup storage    │
│                     │      │                      │
└─────────────────────┘      └──────────────────────┘
```

## Data Flow

```
┌─────────────────────────────────────────────────┐
│  1. GATHER FACTS                                 │
│     ansible_net_hostname, version, interfaces    │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│  2. APPLY CONFIGURATION (Idempotent)             │
│     - Interfaces, VLANs, Routing                 │
│     - ACLs, Policies, NAT                        │
│     - Security Intelligence                      │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│  3. VALIDATE CHANGES                             │
│     - Check device operational status            │
│     - Verify neighbor relationships              │
│     - Confirm configuration applied              │
└────────────────────┬────────────────────────────┘
                     ▼
┌─────────────────────────────────────────────────┐
│  4. BACKUP & ARCHIVE                             │
│     - Save running-config to Git/SFTP            │
│     - Maintain version history                   │
│     - Enable configuration restore               │
└─────────────────────────────────────────────────┘
```

## Lifecycle Stages (Device Timeline)

```
                    DEVICE LIFECYCLE
────────────────────────────────────────────────────────────────

DAY 0: PROVISIONING
├─ Device Bootstrapping
│  ├─ Hostname configuration
│  ├─ Domain name setup
│  ├─ DNS servers
│  └─ NTP synchronization
│
├─ Security Hardening
│  ├─ SSH version 2 only
│  ├─ SSH key generation
│  ├─ Login banner
│  └─ Session timeout
│
├─ Authentication & Authorization
│  ├─ AAA configuration
│  ├─ TACACS+ servers
│  ├─ RADIUS fallback
│  └─ Privilege levels
│
└─ Operational Infrastructure
   ├─ Syslog configuration
   ├─ SNMP setup
   ├─ NTP stratum
   └─ Logging levels

DAY 1: DEPLOYMENT
├─ Layer 2 Configuration
│  ├─ VLAN creation
│  ├─ Trunk configuration
│  ├─ Access ports
│  └─ Port security
│
├─ Layer 3 Configuration
│  ├─ Interface IP addressing
│  ├─ SVI configuration
│  ├─ Loopback interfaces
│  └─ Routing metrics
│
├─ Routing Protocols
│  ├─ OSPF areas and networks
│  ├─ BGP AS and peers
│  ├─ Route filtering
│  └─ Neighbor relationships
│
└─ Firepower Security
   ├─ Network object definitions
   ├─ Access control policies
   ├─ NAT translation rules
   ├─ Security Intelligence
   └─ Threat Defense policies

DAY 2: OPERATIONS
├─ Health Monitoring
│  ├─ Interface status checks
│  ├─ OSPF neighbor verification
│  ├─ CPU/Memory monitoring
│  ├─ Temperature monitoring
│  └─ Spanning Tree validation
│
├─ Compliance Verification
│  ├─ Configuration audit
│  ├─ Security policy check
│  ├─ Compliance reporting
│  └─ Exception documentation
│
├─ Automated Backups
│  ├─ Daily configuration backup
│  ├─ Backup retention (30 days)
│  ├─ Git repository synchronization
│  └─ Backup integrity verification
│
└─ Drift Detection
   ├─ Configuration baseline
   ├─ Change detection
   ├─ Drift reporting
   └─ Remediation triggers

MAINTENANCE: CONTROLLED UPGRADES
├─ Pre-Upgrade Phase
│  ├─ Full configuration backup
│  ├─ Device health baseline
│  ├─ Device capacity check
│  └─ Compatibility verification
│
├─ Upgrade Phase
│  ├─ Image download
│  ├─ Checksum verification
│  ├─ Boot configuration
│  ├─ Device reload
│  └─ Connectivity wait
│
└─ Post-Upgrade Phase
   ├─ Device connectivity verification
   ├─ Configuration integrity check
   ├─ Neighbor relationship validation
   ├─ Performance baseline comparison
   └─ Upgrade report generation
```

## Role Dependencies & Execution Order

```
                    ┌──────────────────┐
                    │   site.yml       │
                    │  (Master Playbook)
                    └────────┬─────────┘
                             │
                    ┌────────┴─────────┐
                    │                  │
            ┌───────▼──────────┐  ┌───▼──────────────┐
            │  IOS Device Play  │  │ FMC Device Play  │
            └───────┬──────────┘  └────┬─────────────┘
                    │                  │
        ┌───────────┼──────────────┬───┴────────────┐
        │           │              │                │
    ┌───▼──┐   ┌───▼──────┐  ┌───▼──────┐  ┌──────▼─┐
    │Day 0 │   │Day 1     │  │Day 1     │  │Day 2   │
    │Role: │   │Role:     │  │Role:     │  │Roles:  │
    │      │   │          │  │          │  │        │
    │common│   │ios_config│  │fmc_      │  │validat-│
    │      │   │          │  │security  │  │ion     │
    └──┬───┘   └──┬───────┘  └──┬───────┘  │backup  │
       │          │             │          │        │
       ├─ Hostname├─ Interfaces  ├─ Objects└────────┘
       ├─ DNS     ├─ VLANs       ├─ Policies
       ├─ NTP     ├─ Trunks      ├─ NAT
       ├─ AAA     ├─ OSPF/BGP    ├─ ACPs
       ├─ SSH     ├─ DHCP Snoop  ├─ IPS/IDS
       ├─ Logging └─ Spanning Tree└─ Deploy
       └─ SNMP
```

## Collections & Modules Used

### Cisco IOS Collection (cisco.ios)
- `cisco.ios.ios_facts` - Gather device facts
- `cisco.ios.ios_command` - Execute commands
- `cisco.ios.ios_config` - Configure devices
- `cisco.ios.ios_interfaces` - Interface management
- `cisco.ios.ios_l2_interfaces` - Layer 2 config
- `cisco.ios.ios_l3_interfaces` - Layer 3 config
- `cisco.ios.ios_vlans` - VLAN management
- `cisco.ios.ios_static_routes` - Routing config

### Cisco FMC Collection (cisco.fmc)
- `cisco.fmc.fmc_access_policies` - ACP management
- `cisco.fmc.fmc_network_objects` - Network objects
- `cisco.fmc.fmc_deployments` - Policy deployment

### Ansible Network Common (ansible.netcommon)
- `ansible.netcommon.restconf_get` - REST API calls
- `ansible.netcommon.restconf_post` - REST API calls
- `ansible.netcommon.restconf_patch` - REST API updates

## Template Variables Hierarchy

```
Lower Priority ◄────────────────────────────► Higher Priority
                          │
        group_vars/        │        host_vars/
        (defaults)         │        (overrides)
             │             │             │
        ┌────▼────┐    ┌───┼────┐  ┌────▼─────┐
        │  all.yml │    │ Facts  │  │ device.yml
        │          │    │ from   │  │          │
        │ Global   ◄────┤ device ├─►│ Device- │
        │ defaults │    │        │  │ specific│
        └────┬─────┘    └────────┘  └────┬────┘
             │                            │
             ├────────────┬───────────────┤
                          │
             Final Configuration Applied to Device
```

## Idempotency Strategy

```
Each Task Follows This Pattern:
┌─────────────────────────────────────────┐
│  1. Check Current State (gather facts)   │
└────────────────┬────────────────────────┘
                 │
                 ▼
    ┌──────────────────────────┐
    │ Compare with Desired     │
    │ State (from variables)   │
    └──────────┬───────────────┘
               │
        ┌──────┴──────┐
        │             │
        YES           NO
        │             │
        │             ▼
        │      ┌─────────────────────┐
        │      │ Apply Configuration │
        │      │ (merged/replaced)   │
        │      └────────┬────────────┘
        │               │
        ▼               ▼
    ┌──────────────────────────────┐
    │ No Change Needed             │
    │ OR                           │
    │ Configuration Applied        │
    └──────────────────────────────┘

Result: Task is ALWAYS SAFE to run multiple times
```