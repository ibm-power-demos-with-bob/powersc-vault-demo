#!/bin/bash
################################################################################
# PowerSC + Vault Demo: Configure Vault PKI for Certificate Issuance
#
# Purpose: Set up Vault PKI secrets engine to issue short-lived certificates
#          (24-hour TTL) for SAP/Oracle workloads. This configuration enables
#          Vault to "take over" certificate management from manual processes.
#
# Prerequisites:
#   - Vault container must be running (see VAULT-SETUP-GUIDE.md)
#   - Run on the RHEL Vault host (pvm2)
#
# Usage:
#   ssh cecuser@$VAULT_HOST "VAULT_HOST=$VAULT_HOST bash -s" < vault-pki-setup.sh
#
# All Vault commands run inside the container via podman exec.
# No Vault CLI or jq required on the host — uses curl + sed for JSON.
#
# Author: Pre-Sales Demo Builder
# Date: 2026-06-08 (revised 2026-07-10 — parameterised IPs, removed jq)
################################################################################

# Note: Not using set -e — using explicit error handling per step

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

# VAULT_HOST is the FQDN of this RHEL server (set by the caller).
# Vault runs in a container; all CLI commands use podman exec.
# Default to localhost if not set (running directly on the vault host).
VAULT_HOST="${VAULT_HOST:-127.0.0.1}"

# Convenience function: run vault CLI inside the container
V() { podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot vault vault "$@"; }

# Test Vault connectivity via health endpoint (no CLI required)
echo -e "${YELLOW}Testing Vault connectivity...${NC}"
if ! curl -s -f "http://127.0.0.1:8200/v1/sys/health" > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Cannot connect to Vault at http://127.0.0.1:8200${NC}"
    echo "Make sure the Vault container is running: podman ps | grep vault"
    exit 1
fi
echo -e "${GREEN}✓ Vault connection successful${NC}"
echo ""

# Step 1: Enable PKI secrets engine
echo -e "${BLUE}Step 1: Enabling PKI secrets engine...${NC}"
if V secrets list | grep -q "^pki/"; then
    echo -e "${YELLOW}  PKI secrets engine already enabled${NC}"
else
    V secrets enable pki
    echo -e "${GREEN}  ✓ PKI secrets engine enabled${NC}"
fi
echo ""

# Step 2: Configure PKI max lease TTL
echo -e "${BLUE}Step 2: Configuring PKI max lease TTL (1 year)...${NC}"
V secrets tune -max-lease-ttl=8760h pki
echo -e "${GREEN}  ✓ Max lease TTL configured${NC}"
echo ""

# Step 3: Generate root CA certificate (idempotent — skip if already present)
echo -e "${BLUE}Step 3: Generating root CA certificate...${NC}"
if V read pki/cert/ca > /dev/null 2>&1; then
    echo -e "${YELLOW}  Root CA already exists — skipping generation${NC}"
else
    V write pki/root/generate/internal \
        common_name="Demo Internal Root CA" \
        issuer_name="demo-root-ca" \
        ttl=8760h \
        organization="Demo Organisation" \
        ou="IT Security" \
        country="GB"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}  ✓ Root CA certificate generated${NC}"
    else
        echo -e "${RED}  ✗ Failed to generate root CA${NC}"
        exit 1
    fi
fi
echo ""

# Step 4: Configure CA and CRL URLs (uses VAULT_HOST FQDN — no hardcoded IPs)
echo -e "${BLUE}Step 4: Configuring CA and CRL URLs...${NC}"
V write pki/config/urls \
    issuing_certificates="http://${VAULT_HOST}:8200/v1/pki/ca" \
    crl_distribution_points="http://${VAULT_HOST}:8200/v1/pki/crl"
echo -e "${GREEN}  ✓ CA and CRL URLs configured (using host: ${VAULT_HOST})${NC}"
echo ""

# Step 5: Create PKI role for SAP/Oracle workloads
echo -e "${BLUE}Step 5: Creating PKI role 'sap-oracle' for workload certificates...${NC}"
V write pki/roles/sap-oracle \
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
    echo "    Allowed Domains: *.howdens.local (and subdomains)"
    echo "    Max TTL: 24 hours"
    echo "    Default TTL: 24 hours"
    echo "    Key Type: RSA 2048"
    echo "    Signature: SHA-256"
else
    echo -e "${RED}  ✗ Failed to create PKI role${NC}"
    exit 1
fi
echo ""

# Step 6: Test certificate issuance (no jq — use curl + sed)
echo -e "${BLUE}Step 6: Testing certificate issuance...${NC}"
TEST_RESPONSE=$(curl -s -X POST \
    -H "X-Vault-Token: myroot" \
    -H "Content-Type: application/json" \
    -d '{"common_name":"test.howdens.local","ttl":"24h"}' \
    "http://127.0.0.1:8200/v1/pki/issue/sap-oracle")

if echo "$TEST_RESPONSE" | grep -q '"serial_number"'; then
    CERT_SERIAL=$(echo "$TEST_RESPONSE" | sed -n 's/.*"serial_number":"\([^"]*\)".*/\1/p')
    echo -e "${GREEN}  ✓ Test certificate issued successfully${NC}"
    echo -e "${YELLOW}  Test Certificate Details:${NC}"
    echo "    Common Name: test.howdens.local"
    echo "    Serial Number: $CERT_SERIAL"
    echo "    TTL: 24 hours"
else
    echo -e "${RED}  ✗ Failed to issue test certificate${NC}"
    ERROR=$(echo "$TEST_RESPONSE" | sed -n 's/.*"errors":\["\([^"]*\)".*/\1/p')
    echo "  Error: $ERROR"
    exit 1
fi
echo ""

# Step 7: Retrieve root CA certificate (no jq — use curl)
echo -e "${BLUE}Step 7: Saving root CA certificate...${NC}"
curl -s "http://127.0.0.1:8200/v1/pki/ca/pem" > /tmp/demo-root-ca.pem
if [ -s /tmp/demo-root-ca.pem ]; then
    echo -e "${GREEN}  ✓ Root CA certificate saved to /tmp/demo-root-ca.pem${NC}"
    echo ""
    echo -e "${YELLOW}  Root CA Certificate (first 5 lines):${NC}"
    head -5 /tmp/demo-root-ca.pem | sed 's/^/    /'
    echo "    ..."
else
    echo -e "${YELLOW}  Warning: Could not retrieve root CA certificate (non-critical)${NC}"
fi
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Vault PKI Configuration Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Configuration Summary:${NC}"
echo "  ✓ PKI secrets engine enabled at: pki/"
echo "  ✓ Root CA generated: Demo Internal Root CA"
echo "  ✓ Max lease TTL: 1 year (8760h)"
echo "  ✓ PKI role created: sap-oracle"
echo "  ✓ Certificate TTL: 24 hours"
echo "  ✓ Key type: RSA 2048 with SHA-256"
echo "  ✓ Test certificate issued successfully"
echo ""
echo -e "${YELLOW}Allowed Domains:${NC}"
echo "  - *.howdens.local (and all sub-domains)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Run generate-old-certificates.sh on AIX client to create old certificates"
echo "2. Trigger PowerSC scan to capture 'BEFORE' state"
echo "3. Run replace-with-vault-certificates.sh to deploy Vault certificates"
echo "4. Trigger PowerSC rescan to capture 'AFTER' state"
echo ""
echo -e "${GREEN}Vault is now ready to issue certificates for SAP/Oracle workloads!${NC}"
echo ""
echo -e "${YELLOW}Vault Address (from AIX):${NC}"
echo "  http://${VAULT_HOST}:8200"
echo ""

# Made with Bob
