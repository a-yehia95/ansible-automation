---
# ==============================================================================
# DEPLOYMENT GUIDE - RHEL 9 CIS Hardening Best Practices
# ==============================================================================

# Production Deployment Guide

## Pre-Deployment Planning

### 1. Assessment Phase

Before deploying hardening, perform thorough assessment:

```bash
# Inventory current systems
ansible-playbook -i inventory/hosts playbooks/validate.yml --check

# Document current state
ansible all -i inventory/hosts -m setup > system_facts.json

# Record current service status
systemctl status --all > service_status_baseline.txt
```

### 2. Risk Analysis

Identify potential impact:

```yaml
# Document critical applications
- Application: Database
  Ports: 3306
  Service: mysql
  Risk: Connection drops if restart needed
  
- Application: Web Server
  Ports: 80, 443
  Service: httpd
  Risk: Firewall rules may block traffic
  
- Application: Message Queue
  Ports: 5672
  Service: rabbitmq
  Risk: Network parameter changes may affect performance
```

### 3. Change Management

```
1. Create change ticket
2. Notify stakeholders
3. Schedule maintenance window
4. Prepare rollback procedure
5. Test in development/staging
6. Get approval for production
7. Perform deployment
8. Validate and monitor
```

## Staging Environment Setup

### Phase 1: Lab Testing (Non-Production)

```bash
# Create test VMs matching production specs
# RHEL 9.0 or later
# 4GB RAM minimum
# 50GB storage

# Configure test inventory
mkdir -p inventory/staging
cat > inventory/staging/hosts << EOF
[rhel9_test]
test-server-01 ansible_host=192.168.100.10
test-server-02 ansible_host=192.168.100.11

[rhel9_test:vars]
ansible_user=root
ansible_become=yes
EOF

# Run hardening on test servers
ansible-playbook -i inventory/staging/hosts playbooks/master.yml --check
ansible-playbook -i inventory/staging/hosts playbooks/master.yml -vv

# Validate functionality
# Test critical applications
# Review logs for errors
# Run compliance checks
ansible-playbook -i inventory/staging/hosts playbooks/validate.yml
```

### Phase 2: Staging Environment (Pre-Production)

```bash
# Deploy to staging environment matching production
# Same network, same services, same load patterns

ansible-playbook -i inventory/hosts playbooks/master.yml \
  -l staging \
  -e "enable_account_policies=true" \
  -e "enable_firewall_network=true" \
  --check

# Extensive testing:
# 1. Application functionality tests
# 2. Performance baseline tests
# 3. Network connectivity tests
# 4. Log forwarding tests
# 5. Backup/restore tests
# 6. User access tests

# Generate compliance report
ansible-playbook -i inventory/hosts playbooks/compliance_report.yml
```

## Production Deployment

### Deployment Strategy: Blue-Green

```bash
# 1. Keep blue environment (current production) running
# 2. Deploy to green environment (identical copy)
# 3. Run validation tests
# 4. Switch load balancer/DNS to green
# 5. Monitor for issues
# 6. Rollback if needed (switch back to blue)

# Configure blue-green inventories
inventory/
├── hosts-blue         # Current production
├── hosts-green        # New environment
```

### Deployment Strategy: Rolling

```bash
# Deploy to production in waves:
# 1. Deploy to 10% of servers
# 2. Monitor for 30 minutes
# 3. If successful, deploy to 25%
# 4. Monitor for 30 minutes
# 5. Deploy to remaining 65%

ansible-playbook -i inventory/hosts playbooks/master.yml \
  -l prod_wave1 \
  -e "deployment_mode=rolling" \
  -vv
```

### Deployment Strategy: Canary

```bash
# Deploy to 1-2% of traffic first
# Monitor closely
# Gradually increase traffic percentage

# Single canary server
ansible-playbook -i inventory/hosts playbooks/master.yml \
  -l prod_canary \
  --check
```

## Critical Backup Procedure

### Pre-Deployment Backups

```bash
# 1. System state backup
tar czf /backup/rhel-pre-hardening-$(date +%Y%m%d).tar.gz \
  /etc/sudoers \
  /etc/ssh/sshd_config \
  /etc/security/limits.conf \
  /etc/login.defs \
  /etc/pam.d/ \
  /etc/audit/audit.rules

# 2. Database backup (if applicable)
mysqldump -u root -p --all-databases > /backup/db-pre-hardening.sql

# 3. VM snapshot
virsh snapshot-create-as rhel9-prod-01 pre-hardening

# 4. Configuration backup
ansible-playbook playbooks/backup.yml
```

### Backup Verification

```bash
# Test restore procedure
# 1. Verify backup integrity
tar tzf /backup/rhel-pre-hardening-*.tar.gz

# 2. Test extraction to separate location
mkdir /tmp/test-restore
tar xzf /backup/rhel-pre-hardening-*.tar.gz -C /tmp/test-restore

# 3. Document restore steps
cat > RESTORE_PROCEDURE.md << EOF
# Emergency Restore Procedure

1. Boot from RHEL 9 installation media
2. Mount root filesystem
3. Restore backed-up files
4. Reboot system
EOF
```

## Performance Monitoring

### Pre-Deployment Baseline

```bash
# Capture baseline metrics
ansible all -i inventory/hosts -m debug -a "msg='{{ ansible_memfree_mb }}'" 

# Monitor during deployment
# CPU usage, memory usage, I/O, network latency

# Post-deployment comparison
# Note any performance degradation
```

### Security Monitoring Setup

```yaml
# Configure security monitoring
- name: Enable audit logging
  command: auditctl -l

- name: Check firewall status
  command: firewall-cmd --list-all

- name: Monitor SSH access
  tail: /var/log/secure

- name: Watch audit logs
  tail: /var/log/audit/audit.log
```

## Rollback Procedure

### Quick Rollback

```bash
# If immediate rollback needed:
# 1. Stop deployment
ansible -i inventory/hosts -m systemd -a "name=sshd state=stopped" prod_servers

# 2. Restore from backup
tar xzf /backup/rhel-pre-hardening-*.tar.gz -C /

# 3. Restart services
systemctl restart sshd auditd rsyslog

# 4. Verify system
ansible-playbook -i inventory/hosts playbooks/validate.yml
```

### Gradual Rollback

```bash
# For systems requiring gradual rollback:
# 1. Use git to revert configuration changes
git revert HARDENING_COMMIT_HASH

# 2. Re-apply previous configuration
ansible-playbook -i inventory/hosts playbooks/baseline.yml

# 3. Validate system state
ansible-playbook -i inventory/hosts playbooks/validate.yml
```

## SSH Access Planning

### Critical: SSH After Hardening

```bash
# SSH is likely restricted after hardening
# Plan ahead to maintain access

# Option 1: Key-based authentication setup BEFORE hardening
# 1. Generate SSH keys on management server
ssh-keygen -t rsa -b 4096

# 2. Distribute public keys to servers BEFORE hardening
ansible-playbook -i inventory/hosts playbooks/setup_ssh_keys.yml

# Option 2: Configure firewall rules before hardening
# 1. Document required ports
# 2. Add firewall rule for SSH
# 3. Verify access before completing deployment

# Option 3: Out-of-band access
# 1. Console access via IPMI/iLO
# 2. Serial console backup access
# 3. Local access from management console
```

## Testing Checklist

### Pre-Deployment
- [ ] Lab environment testing completed
- [ ] Staging deployment successful
- [ ] Compliance validation passed
- [ ] Backup procedures tested
- [ ] Rollback procedure documented
- [ ] Change ticket approved
- [ ] Stakeholder notification sent

### During Deployment
- [ ] Monitor CPU/Memory/Disk
- [ ] Monitor network connectivity
- [ ] Monitor service status
- [ ] Check SSH access
- [ ] Review audit logs
- [ ] Review system logs

### Post-Deployment
- [ ] All systems online and responding
- [ ] SSH access verified
- [ ] Critical services running
- [ ] Firewall rules verified
- [ ] Logs being collected
- [ ] Compliance checks passing
- [ ] Performance acceptable
- [ ] Backups completed

## Troubleshooting Common Issues

### SSH Connection Lost

```bash
# On system console:
systemctl restart sshd
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Or restore from backup:
tar xzf /backup/sshd_config.tar.gz -C /etc/ssh/
systemctl restart sshd
```

### Firewall Blocking Traffic

```bash
# Add application-specific rules:
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --permanent --add-service=mysql
firewall-cmd --reload
```

### High CPU Usage

```bash
# Check auditd impact:
ps aux | grep auditd

# Reduce audit rules if needed:
auditctl -l  # List current rules
# Comment out less critical rules and reload
```

### Log Disk Space Issues

```bash
# Configure log rotation:
logrotate -f /etc/logrotate.d/audit

# Clean old logs:
find /var/log/audit -name "*.log" -mtime +30 -delete
```

## Compliance Maintenance

### Monthly Checks

```bash
# Run compliance validation
ansible-playbook -i inventory/hosts playbooks/validate.yml

# Generate compliance report
ansible-playbook -i inventory/hosts playbooks/compliance_report.yml

# Review audit logs
tail -100 /var/log/audit/audit.log
```

### Quarterly Reviews

```bash
# Full CIS compliance assessment
ansible-playbook -i inventory/hosts playbooks/master.yml --check

# Update documentation
# Review and update security policies
# Assess new security requirements
```

### Annual Security Assessment

```bash
# Comprehensive security audit
# Penetration testing
# Compliance certification
# Security training
```

## Support & Documentation

- Maintain deployment logs
- Document any customizations
- Create troubleshooting runbooks
- Provide team training
- Set up security monitoring dashboards

---

**Key Takeaways**:
1. Test thoroughly before production
2. Plan SSH access carefully
3. Have rollback procedures ready
4. Monitor closely during and after deployment
5. Maintain detailed documentation
6. Conduct ongoing compliance reviews
