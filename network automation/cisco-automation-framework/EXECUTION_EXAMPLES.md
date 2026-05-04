# Cisco Automation Framework - Execution Workflow Examples

## Example 1: Complete Green Field Deployment

```bash
# 1. Initialize setup
./setup.sh

# 2. Create vault with credentials
ansible-vault create group_vars/all/vault.yml

# 3. Update inventory and host_vars
# (Edit inventory.ini, host_vars/*.yml)

# 4. Test connectivity
./execute.sh ping all

# 5. Execute full lifecycle
./execute.sh full

# Outputs will be in:
# - logs/ansible.log (execution details)
# - backups/*.cfg (device configurations)
# - reports/*.html (compliance and inventory reports)
```

## Example 2: Rolling Upgrade (Critical)

```bash
# 1. Backup all devices (pre-upgrade)
./execute.sh backup all

# 2. Perform upgrade with serial execution
ansible-playbook site.yml --tags maintenance \
  --extra-vars "perform_os_upgrade=true" \
  --vault-password-file ~/.vault_pass

# 3. Verify all devices are operational
./execute.sh day2

# 4. Review upgrade reports
cat logs/upgrade_report_*.txt
```

## Example 3: Configuration Restoration

```bash
# 1. List available backups
ls -lah backups/*.cfg

# 2. Restore single device
ansible-playbook playbooks/restore_config.yml \
  --extra-vars "restore_backup_path=./backups/device_backup.cfg" \
  -l target-device \
  --vault-password-file ~/.vault_pass

# 3. Verify restoration
./execute.sh day2
```

## Example 4: Drift Detection & Compliance Audit

```bash
# 1. Collect baseline (first run)
./execute.sh facts

# 2. Run drift detection regularly
./execute.sh drift

# 3. Generate compliance report
ansible-playbook playbooks/drift_detection.yml \
  --vault-password-file ~/.vault_pass \
  --tags compliance

# 4. Review compliance_report_*.html
```

## Example 5: Day 2 Operations (Scheduled)

```bash
# Run daily at 02:00 via cron:
0 2 * * * cd /opt/cisco-automation-framework && \
  ./execute.sh day2 >> logs/day2_scheduled.log 2>&1

# This will:
# - Validate all interfaces are UP
# - Check OSPF neighbor status
# - Monitor CPU/memory
# - Backup configurations
# - Detect drift
# - Generate reports
```

## Example 6: Device-Specific Configuration

```bash
# Deploy only to production switches
./execute.sh day1 ios_switches

# Deploy only to Firepower devices
./execute.sh day1 fmc_devices

# Deploy to specific device
./execute.sh day1 core-switch-01

# Dry-run check mode
./execute.sh check core-switch-01
```

## Example 7: CI/CD Integration (GitLab/GitHub)

```yaml
# .gitlab-ci.yml or .github/workflows/cisco-automation.yml
name: Cisco Network Automation

on:
  push:
    branches: [main, develop]
  schedule:
    - cron: '0 2 * * *'  # Daily at 02:00

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Lint playbooks
        run: ansible-lint
      - name: Validate inventory
        run: ansible-inventory -i inventory.ini --list
      - name: Check syntax
        run: ansible-playbook site.yml --syntax-check

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test Day 0 provisioning
        run: ansible-playbook site.yml --tags day0 --check
      - name: Test Day 1 deployment
        run: ansible-playbook site.yml --tags day1 --check

  deploy:
    needs: [validate, test]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run full lifecycle
        run: ./execute.sh full
```

## Example 8: Troubleshooting Specific Issues

```bash
# Enable verbose output
ansible-playbook site.yml -vvv --vault-password-file ~/.vault_pass

# Debug specific task
ansible-playbook site.yml --tags ios_config \
  --vault-password-file ~/.vault_pass \
  --step  # Step through each task

# Check device facts (no changes)
ansible -i inventory.ini core-switch-01 \
  -m cisco.ios.ios_facts \
  --vault-password-file ~/.vault_pass

# Get running config without changes
ansible core-switch-01 -m cisco.ios.ios_command \
  -a "commands='show running-config'" \
  --vault-password-file ~/.vault_pass
```

## Example 9: Emergency Rollback

```bash
# If something goes wrong:

# 1. Stop any running playbooks (Ctrl+C)

# 2. Immediate backup of current state
./execute.sh backup all

# 3. Restore from last known-good config
ansible-playbook playbooks/restore_config.yml \
  --extra-vars "restore_backup_path=./backups/core-switch-01_backup_TIMESTAMP.cfg" \
  -l core-switch-01 \
  --vault-password-file ~/.vault_pass

# 4. Verify restoration
./execute.sh ping all

# 5. Check device health
./execute.sh day2
```

## Example 10: Monitoring & Alerting

```bash
# Create cron job for continuous monitoring
0 * * * * cd /opt/cisco-automation-framework && \
  ansible-playbook playbooks/collect_facts.yml \
  --vault-password-file ~/.vault_pass && \
  if [ $? -ne 0 ]; then \
    echo "Device health check failed" | mail -s "Network Alert" admin@example.com; \
  fi
```