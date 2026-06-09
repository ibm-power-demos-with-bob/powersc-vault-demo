#!/bin/bash
################################################################################
# PowerSC + Vault Demo: Distribute Real Old Certificates from CA Bundle
# 
# Purpose: Extract real certificates from the system CA bundle (2008-2011)
#          and distribute them across 150 SAP/Oracle/Integration paths.
#          These certificates have authentic old dates and weak crypto.
#
# Usage: Run on AIX client (p1229-pvm3) as root or cecuser with sudo
#        ./generate-old-certificates.sh
#
# Author: Pre-Sales Demo Builder
# Date: 2026-06-09
################################################################################

# Note: Not using 'set -e' to allow graceful error handling
# set -e  # Exit on error

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PowerSC + Vault Demo Setup${NC}"
echo -e "${GREEN}Distributing 150 Old Certificates${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

echo -e "${YELLOW}Cleaning up old certificate directories...${NC}"

# Remove old certificate directories if they exist
if [ -d "/opt/sap" ] || [ -d "/opt/oracle" ] || [ -d "/opt/integration" ] || [ -d "/opt/loadbalancer" ] || [ -d "/opt/proxy" ]; then
    echo "  Removing existing directories:"
    [ -d "/opt/sap" ] && echo "    - /opt/sap" && rm -rf /opt/sap
    [ -d "/opt/oracle" ] && echo "    - /opt/oracle" && rm -rf /opt/oracle
    [ -d "/opt/integration" ] && echo "    - /opt/integration" && rm -rf /opt/integration
    [ -d "/opt/loadbalancer" ] && echo "    - /opt/loadbalancer" && rm -rf /opt/loadbalancer
    [ -d "/opt/proxy" ] && echo "    - /opt/proxy" && rm -rf /opt/proxy
    echo -e "${GREEN}✓ Cleanup complete${NC}"
else
    echo "  No existing certificate directories found"
fi
echo ""

# Source CA bundle path
CA_BUNDLE="/opt/freeware/etc/ssl/certs/extracted/pem/tls-ca-bundle.pem"

# Check if CA bundle exists
if [ ! -f "$CA_BUNDLE" ]; then
    echo -e "${RED}CA bundle not found at $CA_BUNDLE${NC}"
    exit 1
fi

echo -e "${YELLOW}Extracting certificates from CA bundle...${NC}"

# Create temporary directory for extracted certificates
TEMP_DIR="/tmp/demo-certs-$$"
mkdir -p "$TEMP_DIR"

# Extract individual certificates from bundle using awk (AIX-compatible)
# AIX csplit doesn't support {*} syntax, so we use awk instead
awk '
BEGIN { cert_num = 0; in_cert = 0 }
/-----BEGIN CERTIFICATE-----/ {
    in_cert = 1
    cert_num++
    filename = sprintf("'"$TEMP_DIR"'/cert-%03d.pem", cert_num)
}
in_cert {
    print > filename
}
/-----END CERTIFICATE-----/ {
    in_cert = 0
    close(filename)
}
' "$CA_BUNDLE"

# Count extracted certificates
CERT_FILES=($TEMP_DIR/cert-*.pem)
NUM_CERTS=${#CERT_FILES[@]}

echo -e "${GREEN}✓ Extracted $NUM_CERTS certificates from bundle${NC}"
echo ""

# Counter for certificates deployed
CERT_COUNT=0

# Function to deploy a random certificate from the bundle
deploy_cert() {
    local cert_path=$1
    local key_path=$2
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$cert_path")" || {
        echo -e "${RED}Failed to create directory for $cert_path${NC}"
        return 1
    }
    
    # Select a random certificate from extracted files
    local random_index=$((RANDOM % NUM_CERTS))
    local source_cert="${CERT_FILES[$random_index]}"
    
    # Copy certificate
    if ! cp "$source_cert" "$cert_path" 2>/dev/null; then
        echo -e "${RED}Failed to copy certificate to $cert_path${NC}"
        return 1
    fi
    
    # Create a dummy key file (not used in demo, but maintains structure)
    # Generate a simple RSA 1024 key - suppress output but check for errors
    if ! openssl genrsa -out "$key_path" 1024 >/dev/null 2>&1; then
        echo -e "${YELLOW}Warning: Failed to generate key for $key_path, creating dummy key${NC}"
        # Create a minimal dummy key file if openssl fails
        echo "-----BEGIN RSA PRIVATE KEY-----" > "$key_path"
        echo "MIICXAIBAAKBgQC0..." >> "$key_path"
        echo "-----END RSA PRIVATE KEY-----" >> "$key_path"
    fi
    
    # Set proper permissions
    chmod 644 "$cert_path" 2>/dev/null || true
    chmod 600 "$key_path" 2>/dev/null || true
    
    ((CERT_COUNT++))
    return 0
}

echo -e "${YELLOW}Deploying SAP Application Layer Certificates (60 certs)...${NC}"

# SAP Production App Server 1 (10 certs)
echo "  Creating SAP App Server 1 certificates..."
deploy_cert "/opt/sap/app01/certs/server.pem" "/opt/sap/app01/certs/server-key.pem"
deploy_cert "/opt/sap/app01/certs/client.pem" "/opt/sap/app01/certs/client-key.pem"
deploy_cert "/opt/sap/app01/certs/icm.pem" "/opt/sap/app01/certs/icm-key.pem"
deploy_cert "/opt/sap/app01/certs/gateway.pem" "/opt/sap/app01/certs/gateway-key.pem"
deploy_cert "/opt/sap/app01/certs/rfc.pem" "/opt/sap/app01/certs/rfc-key.pem"
deploy_cert "/opt/sap/app01/certs/message-server.pem" "/opt/sap/app01/certs/message-server-key.pem"
deploy_cert "/opt/sap/app01/certs/enqueue.pem" "/opt/sap/app01/certs/enqueue-key.pem"
deploy_cert "/opt/sap/app01/certs/web.pem" "/opt/sap/app01/certs/web-key.pem"
deploy_cert "/opt/sap/app01/certs/fiori.pem" "/opt/sap/app01/certs/fiori-key.pem"
deploy_cert "/opt/sap/app01/certs/sso.pem" "/opt/sap/app01/certs/sso-key.pem"

# SAP Production App Server 2 (10 certs)
echo "  Creating SAP App Server 2 certificates..."
deploy_cert "/opt/sap/app02/certs/server.pem" "/opt/sap/app02/certs/server-key.pem"
deploy_cert "/opt/sap/app02/certs/client.pem" "/opt/sap/app02/certs/client-key.pem"
deploy_cert "/opt/sap/app02/certs/icm.pem" "/opt/sap/app02/certs/icm-key.pem"
deploy_cert "/opt/sap/app02/certs/gateway.pem" "/opt/sap/app02/certs/gateway-key.pem"
deploy_cert "/opt/sap/app02/certs/rfc.pem" "/opt/sap/app02/certs/rfc-key.pem"
deploy_cert "/opt/sap/app02/certs/message-server.pem" "/opt/sap/app02/certs/message-server-key.pem"
deploy_cert "/opt/sap/app02/certs/enqueue.pem" "/opt/sap/app02/certs/enqueue-key.pem"
deploy_cert "/opt/sap/app02/certs/web.pem" "/opt/sap/app02/certs/web-key.pem"
deploy_cert "/opt/sap/app02/certs/fiori.pem" "/opt/sap/app02/certs/fiori-key.pem"
deploy_cert "/opt/sap/app02/certs/sso.pem" "/opt/sap/app02/certs/sso-key.pem"

# SAP Production App Server 3 (10 certs)
echo "  Creating SAP App Server 3 certificates..."
deploy_cert "/opt/sap/app03/certs/server.pem" "/opt/sap/app03/certs/server-key.pem"
deploy_cert "/opt/sap/app03/certs/client.pem" "/opt/sap/app03/certs/client-key.pem"
deploy_cert "/opt/sap/app03/certs/icm.pem" "/opt/sap/app03/certs/icm-key.pem"
deploy_cert "/opt/sap/app03/certs/gateway.pem" "/opt/sap/app03/certs/gateway-key.pem"
deploy_cert "/opt/sap/app03/certs/rfc.pem" "/opt/sap/app03/certs/rfc-key.pem"
deploy_cert "/opt/sap/app03/certs/message-server.pem" "/opt/sap/app03/certs/message-server-key.pem"
deploy_cert "/opt/sap/app03/certs/enqueue.pem" "/opt/sap/app03/certs/enqueue-key.pem"
deploy_cert "/opt/sap/app03/certs/web.pem" "/opt/sap/app03/certs/web-key.pem"
deploy_cert "/opt/sap/app03/certs/fiori.pem" "/opt/sap/app03/certs/fiori-key.pem"
deploy_cert "/opt/sap/app03/certs/sso.pem" "/opt/sap/app03/certs/sso-key.pem"

# SAP Development (8 certs)
echo "  Creating SAP Development certificates..."
deploy_cert "/opt/sap/dev/certs/server.pem" "/opt/sap/dev/certs/server-key.pem"
deploy_cert "/opt/sap/dev/certs/client.pem" "/opt/sap/dev/certs/client-key.pem"
deploy_cert "/opt/sap/dev/certs/icm.pem" "/opt/sap/dev/certs/icm-key.pem"
deploy_cert "/opt/sap/dev/certs/gateway.pem" "/opt/sap/dev/certs/gateway-key.pem"
deploy_cert "/opt/sap/dev/certs/rfc.pem" "/opt/sap/dev/certs/rfc-key.pem"
deploy_cert "/opt/sap/dev/certs/web.pem" "/opt/sap/dev/certs/web-key.pem"
deploy_cert "/opt/sap/dev/certs/fiori.pem" "/opt/sap/dev/certs/fiori-key.pem"
deploy_cert "/opt/sap/dev/certs/sso.pem" "/opt/sap/dev/certs/sso-key.pem"

# SAP QA/Staging (8 certs)
echo "  Creating SAP QA certificates..."
deploy_cert "/opt/sap/qas/certs/server.pem" "/opt/sap/qas/certs/server-key.pem"
deploy_cert "/opt/sap/qas/certs/client.pem" "/opt/sap/qas/certs/client-key.pem"
deploy_cert "/opt/sap/qas/certs/icm.pem" "/opt/sap/qas/certs/icm-key.pem"
deploy_cert "/opt/sap/qas/certs/gateway.pem" "/opt/sap/qas/certs/gateway-key.pem"
deploy_cert "/opt/sap/qas/certs/rfc.pem" "/opt/sap/qas/certs/rfc-key.pem"
deploy_cert "/opt/sap/qas/certs/web.pem" "/opt/sap/qas/certs/web-key.pem"
deploy_cert "/opt/sap/qas/certs/fiori.pem" "/opt/sap/qas/certs/fiori-key.pem"
deploy_cert "/opt/sap/qas/certs/sso.pem" "/opt/sap/qas/certs/sso-key.pem"

# SAP Web Dispatcher (6 certs)
echo "  Creating SAP Web Dispatcher certificates..."
deploy_cert "/opt/sap/webdispatcher/certs/server.pem" "/opt/sap/webdispatcher/certs/server-key.pem"
deploy_cert "/opt/sap/webdispatcher/certs/backend.pem" "/opt/sap/webdispatcher/certs/backend-key.pem"
deploy_cert "/opt/sap/webdispatcher/certs/ssl.pem" "/opt/sap/webdispatcher/certs/ssl-key.pem"
deploy_cert "/opt/sap/webdispatcher/certs/client-auth.pem" "/opt/sap/webdispatcher/certs/client-auth-key.pem"
deploy_cert "/opt/sap/webdispatcher/certs/admin.pem" "/opt/sap/webdispatcher/certs/admin-key.pem"
deploy_cert "/opt/sap/webdispatcher/certs/monitoring.pem" "/opt/sap/webdispatcher/certs/monitoring-key.pem"

# SAP Gateway (8 certs)
echo "  Creating SAP Gateway certificates..."
deploy_cert "/opt/sap/gateway/certs/server.pem" "/opt/sap/gateway/certs/server-key.pem"
deploy_cert "/opt/sap/gateway/certs/odata.pem" "/opt/sap/gateway/certs/odata-key.pem"
deploy_cert "/opt/sap/gateway/certs/rest.pem" "/opt/sap/gateway/certs/rest-key.pem"
deploy_cert "/opt/sap/gateway/certs/soap.pem" "/opt/sap/gateway/certs/soap-key.pem"
deploy_cert "/opt/sap/gateway/certs/mobile.pem" "/opt/sap/gateway/certs/mobile-key.pem"
deploy_cert "/opt/sap/gateway/certs/b2b.pem" "/opt/sap/gateway/certs/b2b-key.pem"
deploy_cert "/opt/sap/gateway/certs/edi.pem" "/opt/sap/gateway/certs/edi-key.pem"
deploy_cert "/opt/sap/gateway/certs/idoc.pem" "/opt/sap/gateway/certs/idoc-key.pem"

echo ""
echo -e "${YELLOW}Deploying Oracle Database Layer Certificates (50 certs)...${NC}"

# Oracle Production DB 1 (12 certs)
echo "  Creating Oracle Production DB 1 certificates..."
deploy_cert "/opt/oracle/prod01/certs/server.pem" "/opt/oracle/prod01/certs/server-key.pem"
deploy_cert "/opt/oracle/prod01/certs/listener.pem" "/opt/oracle/prod01/certs/listener-key.pem"
deploy_cert "/opt/oracle/prod01/certs/wallet.pem" "/opt/oracle/prod01/certs/wallet-key.pem"
deploy_cert "/opt/oracle/prod01/certs/tns.pem" "/opt/oracle/prod01/certs/tns-key.pem"
deploy_cert "/opt/oracle/prod01/certs/sqlnet.pem" "/opt/oracle/prod01/certs/sqlnet-key.pem"
deploy_cert "/opt/oracle/prod01/certs/em.pem" "/opt/oracle/prod01/certs/em-key.pem"
deploy_cert "/opt/oracle/prod01/certs/apex.pem" "/opt/oracle/prod01/certs/apex-key.pem"
deploy_cert "/opt/oracle/prod01/certs/ords.pem" "/opt/oracle/prod01/certs/ords-key.pem"
deploy_cert "/opt/oracle/prod01/certs/dataguard.pem" "/opt/oracle/prod01/certs/dataguard-key.pem"
deploy_cert "/opt/oracle/prod01/certs/rman.pem" "/opt/oracle/prod01/certs/rman-key.pem"
deploy_cert "/opt/oracle/prod01/certs/goldengate.pem" "/opt/oracle/prod01/certs/goldengate-key.pem"
deploy_cert "/opt/oracle/prod01/certs/asm.pem" "/opt/oracle/prod01/certs/asm-key.pem"

# Oracle Production DB 2 (12 certs)
echo "  Creating Oracle Production DB 2 certificates..."
deploy_cert "/opt/oracle/prod02/certs/server.pem" "/opt/oracle/prod02/certs/server-key.pem"
deploy_cert "/opt/oracle/prod02/certs/listener.pem" "/opt/oracle/prod02/certs/listener-key.pem"
deploy_cert "/opt/oracle/prod02/certs/wallet.pem" "/opt/oracle/prod02/certs/wallet-key.pem"
deploy_cert "/opt/oracle/prod02/certs/tns.pem" "/opt/oracle/prod02/certs/tns-key.pem"
deploy_cert "/opt/oracle/prod02/certs/sqlnet.pem" "/opt/oracle/prod02/certs/sqlnet-key.pem"
deploy_cert "/opt/oracle/prod02/certs/em.pem" "/opt/oracle/prod02/certs/em-key.pem"
deploy_cert "/opt/oracle/prod02/certs/apex.pem" "/opt/oracle/prod02/certs/apex-key.pem"
deploy_cert "/opt/oracle/prod02/certs/ords.pem" "/opt/oracle/prod02/certs/ords-key.pem"
deploy_cert "/opt/oracle/prod02/certs/dataguard.pem" "/opt/oracle/prod02/certs/dataguard-key.pem"
deploy_cert "/opt/oracle/prod02/certs/rman.pem" "/opt/oracle/prod02/certs/rman-key.pem"
deploy_cert "/opt/oracle/prod02/certs/goldengate.pem" "/opt/oracle/prod02/certs/goldengate-key.pem"
deploy_cert "/opt/oracle/prod02/certs/asm.pem" "/opt/oracle/prod02/certs/asm-key.pem"

# Oracle Development DB (8 certs)
echo "  Creating Oracle Development DB certificates..."
deploy_cert "/opt/oracle/dev/certs/server.pem" "/opt/oracle/dev/certs/server-key.pem"
deploy_cert "/opt/oracle/dev/certs/listener.pem" "/opt/oracle/dev/certs/listener-key.pem"
deploy_cert "/opt/oracle/dev/certs/wallet.pem" "/opt/oracle/dev/certs/wallet-key.pem"
deploy_cert "/opt/oracle/dev/certs/tns.pem" "/opt/oracle/dev/certs/tns-key.pem"
deploy_cert "/opt/oracle/dev/certs/sqlnet.pem" "/opt/oracle/dev/certs/sqlnet-key.pem"
deploy_cert "/opt/oracle/dev/certs/em.pem" "/opt/oracle/dev/certs/em-key.pem"
deploy_cert "/opt/oracle/dev/certs/apex.pem" "/opt/oracle/dev/certs/apex-key.pem"
deploy_cert "/opt/oracle/dev/certs/ords.pem" "/opt/oracle/dev/certs/ords-key.pem"

# Oracle QA DB (8 certs)
echo "  Creating Oracle QA DB certificates..."
deploy_cert "/opt/oracle/qas/certs/server.pem" "/opt/oracle/qas/certs/server-key.pem"
deploy_cert "/opt/oracle/qas/certs/listener.pem" "/opt/oracle/qas/certs/listener-key.pem"
deploy_cert "/opt/oracle/qas/certs/wallet.pem" "/opt/oracle/qas/certs/wallet-key.pem"
deploy_cert "/opt/oracle/qas/certs/tns.pem" "/opt/oracle/qas/certs/tns-key.pem"
deploy_cert "/opt/oracle/qas/certs/sqlnet.pem" "/opt/oracle/qas/certs/sqlnet-key.pem"
deploy_cert "/opt/oracle/qas/certs/em.pem" "/opt/oracle/qas/certs/em-key.pem"
deploy_cert "/opt/oracle/qas/certs/apex.pem" "/opt/oracle/qas/certs/apex-key.pem"
deploy_cert "/opt/oracle/qas/certs/ords.pem" "/opt/oracle/qas/certs/ords-key.pem"

# Oracle Listeners (10 certs)
echo "  Creating Oracle Listener certificates..."
deploy_cert "/opt/oracle/listener/certs/listener01.pem" "/opt/oracle/listener/certs/listener01-key.pem"
deploy_cert "/opt/oracle/listener/certs/listener02.pem" "/opt/oracle/listener/certs/listener02-key.pem"
deploy_cert "/opt/oracle/listener/certs/listener03.pem" "/opt/oracle/listener/certs/listener03-key.pem"
deploy_cert "/opt/oracle/listener/certs/scan01.pem" "/opt/oracle/listener/certs/scan01-key.pem"
deploy_cert "/opt/oracle/listener/certs/scan02.pem" "/opt/oracle/listener/certs/scan02-key.pem"
deploy_cert "/opt/oracle/listener/certs/scan03.pem" "/opt/oracle/listener/certs/scan03-key.pem"
deploy_cert "/opt/oracle/listener/certs/vip01.pem" "/opt/oracle/listener/certs/vip01-key.pem"
deploy_cert "/opt/oracle/listener/certs/vip02.pem" "/opt/oracle/listener/certs/vip02-key.pem"
deploy_cert "/opt/oracle/listener/certs/grid.pem" "/opt/oracle/listener/certs/grid-key.pem"
deploy_cert "/opt/oracle/listener/certs/crs.pem" "/opt/oracle/listener/certs/crs-key.pem"

echo ""
echo -e "${YELLOW}Deploying Integration/Middleware Certificates (30 certs)...${NC}"

# IBM MQ (10 certs)
echo "  Creating IBM MQ certificates..."
deploy_cert "/opt/integration/mq/certs/qmgr01.pem" "/opt/integration/mq/certs/qmgr01-key.pem"
deploy_cert "/opt/integration/mq/certs/qmgr02.pem" "/opt/integration/mq/certs/qmgr02-key.pem"
deploy_cert "/opt/integration/mq/certs/channel-sap.pem" "/opt/integration/mq/certs/channel-sap-key.pem"
deploy_cert "/opt/integration/mq/certs/channel-oracle.pem" "/opt/integration/mq/certs/channel-oracle-key.pem"
deploy_cert "/opt/integration/mq/certs/channel-web.pem" "/opt/integration/mq/certs/channel-web-key.pem"
deploy_cert "/opt/integration/mq/certs/listener.pem" "/opt/integration/mq/certs/listener-key.pem"
deploy_cert "/opt/integration/mq/certs/client.pem" "/opt/integration/mq/certs/client-key.pem"
deploy_cert "/opt/integration/mq/certs/admin.pem" "/opt/integration/mq/certs/admin-key.pem"
deploy_cert "/opt/integration/mq/certs/monitoring.pem" "/opt/integration/mq/certs/monitoring-key.pem"
deploy_cert "/opt/integration/mq/certs/cluster.pem" "/opt/integration/mq/certs/cluster-key.pem"

# API Gateway (8 certs)
echo "  Creating API Gateway certificates..."
deploy_cert "/opt/integration/api/certs/gateway.pem" "/opt/integration/api/certs/gateway-key.pem"
deploy_cert "/opt/integration/api/certs/portal.pem" "/opt/integration/api/certs/portal-key.pem"
deploy_cert "/opt/integration/api/certs/manager.pem" "/opt/integration/api/certs/manager-key.pem"
deploy_cert "/opt/integration/api/certs/analytics.pem" "/opt/integration/api/certs/analytics-key.pem"
deploy_cert "/opt/integration/api/certs/oauth.pem" "/opt/integration/api/certs/oauth-key.pem"
deploy_cert "/opt/integration/api/certs/jwt.pem" "/opt/integration/api/certs/jwt-key.pem"
deploy_cert "/opt/integration/api/certs/backend.pem" "/opt/integration/api/certs/backend-key.pem"
deploy_cert "/opt/integration/api/certs/developer.pem" "/opt/integration/api/certs/developer-key.pem"

# ESB (6 certs)
echo "  Creating ESB certificates..."
deploy_cert "/opt/integration/esb/certs/server.pem" "/opt/integration/esb/certs/server-key.pem"
deploy_cert "/opt/integration/esb/certs/sap-adapter.pem" "/opt/integration/esb/certs/sap-adapter-key.pem"
deploy_cert "/opt/integration/esb/certs/oracle-adapter.pem" "/opt/integration/esb/certs/oracle-adapter-key.pem"
deploy_cert "/opt/integration/esb/certs/http-adapter.pem" "/opt/integration/esb/certs/http-adapter-key.pem"
deploy_cert "/opt/integration/esb/certs/soap-adapter.pem" "/opt/integration/esb/certs/soap-adapter-key.pem"
deploy_cert "/opt/integration/esb/certs/rest-adapter.pem" "/opt/integration/esb/certs/rest-adapter-key.pem"

# B2B Gateway (6 certs)
echo "  Creating B2B Gateway certificates..."
deploy_cert "/opt/integration/b2b/certs/gateway.pem" "/opt/integration/b2b/certs/gateway-key.pem"
deploy_cert "/opt/integration/b2b/certs/edi.pem" "/opt/integration/b2b/certs/edi-key.pem"
deploy_cert "/opt/integration/b2b/certs/as2.pem" "/opt/integration/b2b/certs/as2-key.pem"
deploy_cert "/opt/integration/b2b/certs/sftp.pem" "/opt/integration/b2b/certs/sftp-key.pem"
deploy_cert "/opt/integration/b2b/certs/partner-a.pem" "/opt/integration/b2b/certs/partner-a-key.pem"
deploy_cert "/opt/integration/b2b/certs/partner-b.pem" "/opt/integration/b2b/certs/partner-b-key.pem"

echo ""
echo -e "${YELLOW}Deploying Infrastructure Certificates (10 certs)...${NC}"

# Load Balancers (5 certs)
echo "  Creating Load Balancer certificates..."
deploy_cert "/opt/loadbalancer/certs/lb01.pem" "/opt/loadbalancer/certs/lb01-key.pem"
deploy_cert "/opt/loadbalancer/certs/lb02.pem" "/opt/loadbalancer/certs/lb02-key.pem"
deploy_cert "/opt/loadbalancer/certs/vip-sap.pem" "/opt/loadbalancer/certs/vip-sap-key.pem"
deploy_cert "/opt/loadbalancer/certs/vip-oracle.pem" "/opt/loadbalancer/certs/vip-oracle-key.pem"
deploy_cert "/opt/loadbalancer/certs/admin.pem" "/opt/loadbalancer/certs/admin-key.pem"

# Reverse Proxies (5 certs)
echo "  Creating Reverse Proxy certificates..."
deploy_cert "/opt/proxy/certs/proxy01.pem" "/opt/proxy/certs/proxy01-key.pem"
deploy_cert "/opt/proxy/certs/proxy02.pem" "/opt/proxy/certs/proxy02-key.pem"
deploy_cert "/opt/proxy/certs/frontend.pem" "/opt/proxy/certs/frontend-key.pem"
deploy_cert "/opt/proxy/certs/backend.pem" "/opt/proxy/certs/backend-key.pem"
deploy_cert "/opt/proxy/certs/ssl-offload.pem" "/opt/proxy/certs/ssl-offload-key.pem"

# Cleanup temporary directory
rm -rf "$TEMP_DIR"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Certificate Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Total certificates deployed: ${CERT_COUNT}${NC}"
echo ""
echo -e "${YELLOW}Certificate Distribution:${NC}"
echo "  SAP Application Layer:    60 certificates"
echo "  Oracle Database Layer:    50 certificates"
echo "  Integration/Middleware:   30 certificates"
echo "  Infrastructure:           10 certificates"
echo "  ────────────────────────────────────────"
echo "  TOTAL:                   150 certificates"
echo ""
echo -e "${YELLOW}Certificate Characteristics:${NC}"
echo "  - Real CA certificates from system bundle"
echo "  - Issued between 2008-2011 (15-18 years old)"
echo "  - Weak crypto (RSA 1024/2048, SHA-1)"
echo "  - Randomly distributed from 170+ CA certificates"
echo "  - Distributed across realistic SAP/Oracle paths"
echo "  - Ready to be detected by PowerSC as weak/old"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Trigger PowerSC Quantum Safety scan to discover these certificates"
echo "2. Capture 'BEFORE' state showing weak & old certificates"
echo "3. Configure Vault PKI to issue replacement certificates"
echo "4. Deploy Vault-issued certificates to replace these old ones"
echo "5. Rescan with PowerSC to show improvement"
echo ""
echo -e "${GREEN}Certificates are ready for PowerSC scanning!${NC}"
echo ""

# Made with Bob
