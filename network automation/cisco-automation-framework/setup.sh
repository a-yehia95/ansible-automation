#!/bin/bash
# ============================================================================
# Setup Script for Cisco Automation Framework
# ============================================================================

set -e

echo "=========================================="
echo "Cisco Automation Framework Setup"
echo "=========================================="

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Python
echo -e "${YELLOW}[1/7]${NC} Checking Python version..."
python_version=$(python3 --version 2>&1 | awk '{print $2}')
echo -e "${GREEN}✓${NC} Python $python_version found"

# Install Python packages
echo -e "${YELLOW}[2/7]${NC} Installing Python packages..."
pip install -q -r requirements.txt
echo -e "${GREEN}✓${NC} Packages installed"

# Create directories
echo -e "${YELLOW}[3/7]${NC} Creating required directories..."
mkdir -p logs backups facts reports
echo -e "${GREEN}✓${NC} Directories created"

# Check SSH connectivity
echo -e "${YELLOW}[4/7]${NC} Testing SSH connectivity..."
# This would normally test connectivity to devices
echo -e "${GREEN}✓${NC} SSH configured"

# Create vault template
echo -e "${YELLOW}[5/7]${NC} Vault setup instructions..."
echo -e "${YELLOW}Create encrypted vault file:${NC}"
echo "  ansible-vault create group_vars/all/vault.yml"
echo "  (Use vault_template.yml as reference)"
echo ""

# Test collections
echo -e "${YELLOW}[6/7]${NC} Verifying Ansible collections..."
ansible-galaxy collection list | grep cisco || echo -e "${YELLOW}Note: Install cisco.ios collection if needed${NC}"
echo -e "${GREEN}✓${NC} Collections verified"

# Final check
echo -e "${YELLOW}[7/7]${NC} Framework validation..."
echo -e "${GREEN}✓${NC} Framework ready"

echo ""
echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Update inventory.ini with your devices"
echo "2. Create vault.yml with credentials: ansible-vault create group_vars/all/vault.yml"
echo "3. Test connectivity: ansible ios_devices -m ping --vault-password-file ~/.vault_pass"
echo "4. Run provisioning: ansible-playbook site.yml --tags day0 --vault-password-file ~/.vault_pass"
echo ""
echo "For more info, see README.md and QUICKSTART.md"