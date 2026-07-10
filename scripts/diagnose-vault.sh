#!/bin/bash
################################################################################
# Vault PKI Diagnostic Script
# 
# Purpose: Quickly diagnose Vault PKI configuration issues
#
# Usage: Run on RHEL Vault server
#        export VAULT_ADDR="http://127.0.0.1:8200"
#        export VAULT_TOKEN="myroot"
#        ./diagnose-vault.sh
################################################################################

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Vault PKI Diagnostic"
echo "========================================="
echo ""

# Check environment variables
echo "1. Environment Variables:"
if [ -z "$VAULT_ADDR" ]; then
    echo -e "  ${RED}✗ VAULT_ADDR not set${NC}"
else
    echo -e "  ${GREEN}✓ VAULT_ADDR: $VAULT_ADDR${NC}"
fi

if [ -z "$VAULT_TOKEN" ]; then
    echo -e "  ${RED}✗ VAULT_TOKEN not set${NC}"
else
    echo -e "  ${GREEN}✓ VAULT_TOKEN: ${VAULT_TOKEN:0:10}...${NC}"
fi
echo ""

# Check Vault status
echo "2. Vault Status:"
if vault status &> /dev/null; then
    echo -e "  ${GREEN}✓ Vault is accessible${NC}"
    vault status | grep -E "Sealed|Initialized" | sed 's/^/  /'
else
    echo -e "  ${RED}✗ Cannot connect to Vault${NC}"
    exit 1
fi
echo ""

# Check PKI engine
echo "3. PKI Secrets Engine:"
if vault secrets list | grep -q "^pki/"; then
    echo -e "  ${GREEN}✓ PKI engine is enabled${NC}"
else
    echo -e "  ${RED}✗ PKI engine is NOT enabled${NC}"
    echo "  Run: vault secrets enable pki"
fi
echo ""

# Check PKI role
echo "4. PKI Role 'sap-oracle':"
if vault read pki/roles/sap-oracle &> /dev/null; then
    echo -e "  ${GREEN}✓ Role 'sap-oracle' exists${NC}"
    vault read pki/roles/sap-oracle | grep -E "allowed_domains|max_ttl|ttl" | sed 's/^/  /'
else
    echo -e "  ${RED}✗ Role 'sap-oracle' does NOT exist${NC}"
    echo "  Run: ./vault-pki-setup.sh"
fi
echo ""

# Test certificate issuance
echo "5. Test Certificate Issuance:"
TEST_OUTPUT=$(vault write pki/issue/sap-oracle common_name="diagnostic-test.howdens.local" ttl=1h 2>&1)
if echo "$TEST_OUTPUT" | grep -q "serial_number"; then
    echo -e "  ${GREEN}✓ Successfully issued test certificate${NC}"
    echo "$TEST_OUTPUT" | grep "serial_number" | sed 's/^/  /'
else
    echo -e "  ${RED}✗ Failed to issue certificate${NC}"
    echo "$TEST_OUTPUT" | head -3 | sed 's/^/  /'
fi
echo ""

# Summary
echo "========================================="
echo "Diagnostic Summary"
echo "========================================="
echo ""

if vault secrets list | grep -q "^pki/" && vault read pki/roles/sap-oracle &> /dev/null; then
    echo -e "${GREEN}✓ Vault PKI is properly configured${NC}"
    echo ""
    echo "If certificate issuance still fails, check:"
    echo "  1. Token permissions (try root token)"
    echo "  2. Network connectivity from AIX to RHEL"
    echo "  3. Vault address is correct - check VAULT_ADDR is set to http://<VAULT_HOST>:8200"
else
    echo -e "${RED}✗ Vault PKI needs configuration${NC}"
    echo ""
    echo "To fix, run on RHEL:"
    echo "  cd /home/cecuser"
    echo "  ./vault-pki-setup.sh"
fi
echo ""

# Made with Bob
