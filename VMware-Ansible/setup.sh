#!/bin/bash
# ==============================================================================
# VMware Ansible Project Setup Script
# ==============================================================================
# Automated setup for VMware Ansible automation project
# 
# Usage: bash setup.sh
# Or: bash setup.sh --vault-password "your_password"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
VAULT_PASSWORD=${1:-""}
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}VMware Ansible Project Setup${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check Python
echo -e "${YELLOW}[1/6]${NC} Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 is not installed!${NC}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo -e "${GREEN}✓ Python ${PYTHON_VERSION}${NC}\n"

# Check Ansible
echo -e "${YELLOW}[2/6]${NC} Checking Ansible installation..."
if ! command -v ansible &> /dev/null; then
    echo -e "${RED}Ansible is not installed!${NC}"
    echo "Install with: pip install ansible"
    exit 1
fi
ANSIBLE_VERSION=$(ansible --version 2>&1 | head -n1)
echo -e "${GREEN}✓ ${ANSIBLE_VERSION}${NC}\n"

# Install Python dependencies
echo -e "${YELLOW}[3/6]${NC} Installing Python dependencies..."
pip install -r requirements.txt > /dev/null 2>&1
echo -e "${GREEN}✓ Dependencies installed${NC}\n"

# Install Ansible collections
echo -e "${YELLOW}[4/6]${NC} Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml > /dev/null 2>&1
echo -e "${GREEN}✓ Collections installed${NC}\n"

# Create directories
echo -e "${YELLOW}[5/6]${NC} Creating required directories..."
mkdir -p logs facts
chmod 755 logs facts
echo -e "${GREEN}✓ Directories created${NC}\n"

# Setup vault password
echo -e "${YELLOW}[6/6]${NC} Setting up Vault password..."

if [ -z "$VAULT_PASSWORD" ]; then
    # Interactive mode
    read -sp "Enter Vault password (will not be echoed): " VAULT_PASSWORD
    echo ""
    read -sp "Confirm Vault password: " VAULT_PASSWORD_CONFIRM
    echo ""
    
    if [ "$VAULT_PASSWORD" != "$VAULT_PASSWORD_CONFIRM" ]; then
        echo -e "${RED}Passwords do not match!${NC}"
        exit 1
    fi
fi

# Write vault password file
echo "$VAULT_PASSWORD" > .vault_pass
chmod 600 .vault_pass

echo -e "${GREEN}✓ Vault password configured${NC}\n"

# Create encrypted vault file if it doesn't exist
if [ ! -f "group_vars/vmware_infrastructure/vault.yml" ]; then
    echo -e "${YELLOW}Creating encrypted vault file...${NC}"
    cat > /tmp/vault_template.yml << 'EOF'
---
# vCenter Credentials
vault_vcenter_hostname: "vcenter.example.com"
vault_vcenter_username: "administrator@vsphere.local"
vault_vcenter_password: "VerySecurePassword123!"

# Network Configuration
vault_ntp_server: "ntp.example.com"
vault_dns_servers:
  - 8.8.8.8
  - 8.8.4.4

# Additional credentials (add as needed)
# vault_backup_username: "backup_user"
# vault_backup_password: "backup_password"
EOF

    # Encrypt and move to final location
    ansible-vault encrypt /tmp/vault_template.yml --vault-password-file=.vault_pass
    mv /tmp/vault_template.yml group_vars/vmware_infrastructure/vault.yml
    echo -e "${GREEN}✓ Vault file created at group_vars/vmware_infrastructure/vault.yml${NC}"
    echo -e "${YELLOW}IMPORTANT: Edit this file with your actual vCenter credentials:${NC}"
    echo "ansible-vault edit group_vars/vmware_infrastructure/vault.yml --vault-password-file=.vault_pass"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Edit configuration:"
echo "   vim inventory/hosts"
echo "   vim group_vars/vmware_infrastructure.yml"
echo ""
echo "2. Add vCenter credentials:"
echo "   ansible-vault edit group_vars/vmware_infrastructure/vault.yml --vault-password-file=.vault_pass"
echo ""
echo "3. Run Day 0 foundation setup:"
echo "   ansible-playbook playbooks/day0/foundation.yml --vault-password-file=.vault_pass"
echo ""
echo "4. Check documentation:"
echo "   cat docs/QUICK_START.md"
echo ""
echo -e "${GREEN}For detailed information, see README.md${NC}\n"
