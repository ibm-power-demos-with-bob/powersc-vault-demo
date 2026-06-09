#!/bin/bash
################################################################################
# PowerSC + Vault Demo: Configure Vault PKI for Certificate Issuance
# 
# Purpose: Set up Vault PKI secrets engine to issue short-lived certificates
#          (24-hour TTL) for SAP/Oracle workloads. This configuration enables
#          Vault to "take over" certificate management from manual processes.
#
# Prerequisites:
#   - Vault must be running and unsealed
#   - You must have root token or appropriate permissions
#
# Usage: Run on RHEL client (p1229-pvm2) where Vault is installed
#        export VAULT_ADDR="http://127.0.0.1:8200"
#        export VAULT_TOKEN="your-root-token"
#        ./vault-pki-setup.sh
#
# Author: Pre-Sales Demo Builder
# Date: 2026-06-08
################################################################################

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PowerSC + Vault Demo${NC}"
echo -e "${GREEN}Configuring Vault PKI${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check prerequisites
if [ -z "$VAULT_ADDR" ]; then
    echo -e "${RED}ERROR: VAULT_ADDR not set${NC}"
    echo "Please set: export VAULT_ADDR=\"http://127.0.0.1:8200\""
    exit 1
fi

if [ -z "$VAULT_TOKEN" ]; then
    echo -e "${RED}ERROR: VAULT_TOKEN not set${NC}"
    echo "Please set: export VAULT_TOKEN=\"your-root-token\""
    exit 1
fi

# Check if vault CLI is available
if ! command -v vault &> /dev/null; then
    echo -e "${RED}ERROR: Vault CLI not found${NC}"
    echo "Please install Vault CLI first"
    exit 1
fi

# Test Vault connectivity
echo -e "${YELLOW}Testing Vault connectivity...${NC}"
if ! vault status &> /dev/null; then
    echo -e "${RED}ERROR: Cannot connect to Vault at $VAULT_ADDR${NC}"
    echo "Make sure Vault is running and unsealed"
    exit 1
fi
echo -e "${GREEN}✓ Vault connection successful${NC}"
echo ""

# Step 1: Enable PKI secrets engine
echo -e "${BLUE}Step 1: Enabling PKI secrets engine...${NC}"
if vault secrets list | grep -q "^pki/"; then
    echo -e "${YELLOW}  PKI secrets engine already enabled${NC}"
else
    vault secrets enable pki
    echo -e "${GREEN}  ✓ PKI secrets engine enabled${NC}"
fi
echo ""

# Step 2: Configure PKI max lease TTL
echo -e "${BLUE}Step 2: Configuring PKI max lease TTL (1 year)...${NC}"
vault secrets tune -max-lease-ttl=8760h pki
echo -e "${GREEN}  ✓ Max lease TTL configured${NC}"
echo ""

# Step 3: Generate root CA certificate
echo -e "${BLUE}Step 3: Generating root CA certificate...${NC}"
vault write -format=json pki/root/generate/internal \
    common_name="Howdens Internal Root CA" \
    issuer_name="howdens-root-ca" \
    ttl=8760h \
    organization="Howdens" \
    ou="IT Security" \
    country="GB" \
    locality="London" \
    province="England" > /tmp/vault-root-ca.json

if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Root CA certificate generated${NC}"
    echo -e "${YELLOW}  Root CA Details:${NC}"
    echo "    Common Name: Howdens Internal Root CA"
    echo "    Organization: Howdens"
    echo "    Country: GB"
    echo "    TTL: 1 year (8760h)"
else
    echo -e "${RED}  ✗ Failed to generate root CA${NC}"
    exit 1
fi
echo ""

# Step 4: Configure CA and CRL URLs
echo -e "${BLUE}Step 4: Configuring CA and CRL URLs...${NC}"
vault write pki/config/urls \
    issuing_certificates="http://vault.howdens.local:8200/v1/pki/ca" \
    crl_distribution_points="http://vault.howdens.local:8200/v1/pki/crl"
echo -e "${GREEN}  ✓ CA and CRL URLs configured${NC}"
echo ""

# Step 5: Create PKI role for SAP/Oracle workloads
echo -e "${BLUE}Step 5: Creating PKI role 'sap-oracle' for workload certificates...${NC}"
vault write pki/roles/sap-oracle \
    allowed_domains="howdens.local,sap.howdens.local,oracle.howdens.local,mq.howdens.local,api.howdens.local,esb.howdens.local,b2b.howdens.local,lb.howdens.local,proxy.howdens.local" \
    allow_subdomains=true \
    allow_bare_domains=true \
    allow_localhost=false \
    allow_ip_sans=false \
    max_ttl=24h \
    ttl=24h \
    key_type=rsa \
    key_bits=2048 \
    signature_bits=256 \
    use_csr_common_name=false \
    use_csr_sans=false \
    require_cn=true \
    organization="Howdens" \
    ou="SAP/Oracle Workloads" \
    country="GB"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ PKI role 'sap-oracle' created${NC}"
    echo -e "${YELLOW}  Role Configuration:${NC}"
    echo "    Allowed Domains: *.howdens.local, *.sap.howdens.local, *.oracle.howdens.local"
    echo "    Max TTL: 24 hours"
    echo "    Default TTL: 24 hours"
    echo "    Key Type: RSA 2048"
    echo "    Signature: SHA-256"
    echo "    Organization: Howdens"
else
    echo -e "${RED}  ✗ Failed to create PKI role${NC}"
    exit 1
fi
echo ""

# Step 6: Test certificate issuance
echo -e "${BLUE}Step 6: Testing certificate issuance...${NC}"
vault write -format=json pki/issue/sap-oracle \
    common_name="test.howdens.local" \
    ttl=24h > /tmp/vault-test-cert.json

if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Test certificate issued successfully${NC}"
    
    # Extract and display certificate details
    CERT_SERIAL=$(cat /tmp/vault-test-cert.json | jq -r .data.serial_number)
    CERT_EXPIRY=$(cat /tmp/vault-test-cert.json | jq -r .data.expiration)
    
    echo -e "${YELLOW}  Test Certificate Details:${NC}"
    echo "    Common Name: test.howdens.local"
    echo "    Serial Number: $CERT_SERIAL"
    echo "    Expires: $(date -d @$CERT_EXPIRY 2>/dev/null || date -r $CERT_EXPIRY 2>/dev/null || echo $CERT_EXPIRY)"
    echo "    TTL: 24 hours"
    
    # Clean up test certificate
    rm -f /tmp/vault-test-cert.json
else
    echo -e "${RED}  ✗ Failed to issue test certificate${NC}"
    exit 1
fi
echo ""

# Step 7: Display root CA certificate
echo -e "${BLUE}Step 7: Saving root CA certificate...${NC}"
vault read -field=certificate pki/cert/ca > /tmp/howdens-root-ca.pem
if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Root CA certificate saved to /tmp/howdens-root-ca.pem${NC}"
    echo ""
    echo -e "${YELLOW}  Root CA Certificate (first 10 lines):${NC}"
    head -10 /tmp/howdens-root-ca.pem | sed 's/^/    /'
    echo "    ..."
else
    echo -e "${RED}  ✗ Failed to retrieve root CA certificate${NC}"
fi
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Vault PKI Configuration Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Configuration Summary:${NC}"
echo "  ✓ PKI secrets engine enabled at: pki/"
echo "  ✓ Root CA generated: Howdens Internal Root CA"
echo "  ✓ Max lease TTL: 1 year (8760h)"
echo "  ✓ PKI role created: sap-oracle"
echo "  ✓ Certificate TTL: 24 hours"
echo "  ✓ Key type: RSA 2048 with SHA-256"
echo "  ✓ Test certificate issued successfully"
echo ""
echo -e "${YELLOW}Allowed Domains:${NC}"
echo "  - *.howdens.local"
echo "  - *.sap.howdens.local"
echo "  - *.oracle.howdens.local"
echo "  - *.mq.howdens.local"
echo "  - *.api.howdens.local"
echo "  - *.esb.howdens.local"
echo "  - *.b2b.howdens.local"
echo "  - *.lb.howdens.local"
echo "  - *.proxy.howdens.local"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Run generate-old-certificates.sh on AIX client to create old certificates"
echo "2. Trigger PowerSC scan to capture 'BEFORE' state"
echo "3. Run replace-with-vault-certificates.sh to deploy Vault certificates"
echo "4. Trigger PowerSC rescan to capture 'AFTER' state"
echo ""
echo -e "${GREEN}Vault is now ready to issue certificates for SAP/Oracle workloads!${NC}"
echo ""

# Export environment variables for convenience
echo -e "${YELLOW}Environment Variables (for reference):${NC}"
echo "  export VAULT_ADDR=\"$VAULT_ADDR\""
echo "  export VAULT_TOKEN=\"$VAULT_TOKEN\""
echo ""

# Made with Bob
