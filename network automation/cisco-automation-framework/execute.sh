#!/bin/bash
# ============================================================================
# Execute Cisco Automation Framework
# ============================================================================

VAULT_FILE="$HOME/.vault_pass"
FRAMEWORK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check vault password file
if [ ! -f "$VAULT_FILE" ]; then
    echo -e "${RED}Error: Vault password file not found at $VAULT_FILE${NC}"
    echo "Please create: echo 'your_password' > ~/.vault_pass"
    exit 1
fi

# Parse arguments
COMMAND=${1:-help}
DEVICE=${2:-all}

case "$COMMAND" in
    day0)
        echo -e "${BLUE}Executing Day 0: Provisioning${NC}"
        ansible-playbook "$FRAMEWORK_DIR/site.yml" \
            --tags day0 \
            --vault-password-file "$VAULT_FILE" \
            -l "$DEVICE"
        ;;
    day1)
        echo -e "${BLUE}Executing Day 1: Deployment${NC}"
        ansible-playbook "$FRAMEWORK_DIR/site.yml" \
            --tags day1 \
            --vault-password-file "$VAULT_FILE" \
            -l "$DEVICE"
        ;;
    day2)
        echo -e "${BLUE}Executing Day 2: Operations${NC}"
        ansible-playbook "$FRAMEWORK_DIR/site.yml" \
            --tags day2 \
            --vault-password-file "$VAULT_FILE" \
            -l "$DEVICE"
        ;;
    backup)
        echo -e "${BLUE}Executing: Backup Configurations${NC}"
        ansible-playbook "$FRAMEWORK_DIR/playbooks/backup.yml" \
            --vault-password-file "$VAULT_FILE" \
            -l "$DEVICE"
        ;;
    drift)
        echo -e "${BLUE}Executing: Drift Detection${NC}"
        ansible-playbook "$FRAMEWORK_DIR/playbooks/drift_detection.yml" \
            --vault-password-file "$VAULT_FILE" \
            -l "$DEVICE"
        ;;
    facts)
        echo -e "${BLUE}Executing: Collect Facts${NC}"
        ansible-playbook "$FRAMEWORK_DIR/playbooks/collect_facts.yml" \
            --vault-password-file "$VAULT_FILE" \
            -l "$DEVICE"
        ;;
    ping)
        echo -e "${BLUE}Testing connectivity to $DEVICE${NC}"
        ansible "$DEVICE" -i "$FRAMEWORK_DIR/inventory.ini" \
            -m ping \
            --vault-password-file "$VAULT_FILE"
        ;;
    full)
        echo -e "${BLUE}Executing Full Lifecycle (Day 0 -> Day 1 -> Day 2)${NC}"
        ansible-playbook "$FRAMEWORK_DIR/site.yml" \
            --vault-password-file "$VAULT_FILE" \
            -l "$DEVICE"
        ;;
    check)
        echo -e "${BLUE}Executing Check Mode (Dry-run)${NC}"
        ansible-playbook "$FRAMEWORK_DIR/site.yml" \
            --vault-password-file "$VAULT_FILE" \
            --check \
            -l "$DEVICE"
        ;;
    *)
        cat << EOF
${BLUE}Cisco Automation Framework Executor${NC}

Usage: $(basename "$0") <command> [device]

Commands:
    ${GREEN}day0${NC}       - Provisioning (system configuration)
    ${GREEN}day1${NC}       - Deployment (IOS & Firepower configuration)
    ${GREEN}day2${NC}       - Operations (validation, backup, monitoring)
    ${GREEN}full${NC}       - Full lifecycle (Day 0 → Day 1 → Day 2)
    ${GREEN}backup${NC}     - Backup configurations
    ${GREEN}drift${NC}      - Detect configuration drift
    ${GREEN}facts${NC}      - Collect device facts
    ${GREEN}ping${NC}       - Test device connectivity
    ${GREEN}check${NC}      - Dry-run (check mode)
    ${GREEN}help${NC}       - Show this help message

Examples:
    # Full provisioning on all devices
    $(basename "$0") full

    # Day 1 deployment on specific device
    $(basename "$0") day1 core-switch-01

    # Check mode for device group
    $(basename "$0") check ios_devices

    # Backup single device
    $(basename "$0") backup core-switch-01

    # Test connectivity
    $(basename "$0") ping all

${YELLOW}Note:${NC} Vault password file must exist at ~/.vault_pass
EOF
        ;;
esac