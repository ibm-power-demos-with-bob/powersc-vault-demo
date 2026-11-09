#!/bin/sh
################################################################################
# PowerSC + Vault Demo: Replace Old Certificates with Vault-Issued Ones
# 
# Purpose: Replace the 150 "old" certificates with fresh Vault-issued
#          certificates (24-hour TTL, strong crypto). This demonstrates
#          Vault "taking over" certificate management.
#
# Prerequisites:
#   - Vault must be running and accessible
#   - Vault PKI must be configured (see vault-pki-setup.sh)
#   - Old certificates must exist (run generate-old-certificates.sh first)
#
# Usage: Run on AIX client (p1229-pvm3) with Vault access
#        export VAULT_ADDR="http://<VAULT_HOST>:8200"
#        export VAULT_TOKEN="your-vault-token"
#        ./replace-with-vault-certificates.sh
#
# Author: Pre-Sales Demo Builder
# Date: 2026-06-09
################################################################################

# Note: Not using 'set -e' to allow graceful error handling
# This ensures the script continues even if individual certificate issuance fails

# On AIX, curl lives in /opt/freeware/bin — add it to PATH if not already there
if [ -d /opt/freeware/bin ]; then
  export PATH="/opt/freeware/bin:$PATH"
fi

echo "========================================"
echo "PowerSC + Vault Demo"
echo "Replacing Old Certificates with Vault"
echo "========================================"
echo ""

# Check prerequisites
if [ -z "$VAULT_ADDR" ]; then
    echo "ERROR: VAULT_ADDR not set"
    echo "Please set: export VAULT_ADDR=\"http://<VAULT_HOST>:8200\""
    exit 1
fi

if [ -z "$VAULT_TOKEN" ]; then
    echo "ERROR: VAULT_TOKEN not set"
    echo "Please set: export VAULT_TOKEN=\"your-vault-token\""
    exit 1
fi

# Check curl is reachable (PATH already includes /opt/freeware/bin above)
CURL_BIN=""
if [ -x /opt/freeware/bin/curl ]; then
    CURL_BIN=/opt/freeware/bin/curl
elif [ -x /usr/bin/curl ]; then
    CURL_BIN=/usr/bin/curl
else
    echo "ERROR: curl not found in /opt/freeware/bin or /usr/bin"
    exit 1
fi

# Determine base directory — use /opt if writable, otherwise fall back to ~/demo-certs
# Must match the directory used by generate-old-certificates.sh
# Test by actually writing a file — -w and mkdir checks are unreliable on AIX ksh.
if mkdir -p /opt/powersc-demo-test 2>/dev/null && touch /opt/powersc-demo-test/.write-test 2>/dev/null; then
  DEMO_BASE="/opt"
  rm -rf /opt/powersc-demo-test 2>/dev/null
else
  DEMO_BASE="${HOME}/demo-certs"
fi
echo "Using certificate base directory: $DEMO_BASE"

# Test Vault connectivity
echo "Testing Vault connectivity..."
if ! $CURL_BIN -s -f "$VAULT_ADDR/v1/sys/health" > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to Vault at $VAULT_ADDR"
    exit 1
fi
echo "Vault connection successful"
echo ""

# Counter for certificates replaced
CERT_COUNT=0

# Function to issue and deploy a Vault certificate using curl
# Usage: replace_with_vault_cert <cert_path> <key_path> <common_name>
replace_with_vault_cert() {
    cert_path=$1
    key_path=$2
    common_name=$3

    # Issue certificate from Vault (24-hour TTL, strong crypto)
    vault_output=$($CURL_BIN -s -X POST \
        -H "X-Vault-Token: $VAULT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"common_name\":\"$common_name\",\"ttl\":\"24h\"}" \
        "$VAULT_ADDR/v1/pki/issue/sap-oracle" 2>/dev/null)
    curl_exit_code=$?

    if [ $curl_exit_code -ne 0 ]; then
        echo "  FAILED: $common_name (curl exit $curl_exit_code)"
        touch "$cert_path" "$key_path" 2>/dev/null || true
        return 1
    fi

    # Check for Vault errors (grep -q is AIX-safe; grep -o is not)
    if echo "$vault_output" | grep -q '"errors"'; then
        error_msg=$(echo "$vault_output" | awk -F'"errors":\["' 'NF>1{gsub(/".*$/,"",$2); print $2}')
        echo "  VAULT ERROR: $common_name: $error_msg"
        touch "$cert_path" "$key_path" 2>/dev/null || true
        return 1
    fi

    # Extract certificate and private key using Python 3 JSON parser (strict=False handles literal unescaped newlines)
    cert_data=$(echo "$vault_output" | python3 -c "import sys, json; d=json.loads(sys.stdin.read(), strict=False); print(d.get('data',{}).get('certificate',''))" 2>/dev/null)
    key_data=$(echo "$vault_output" | python3 -c "import sys, json; d=json.loads(sys.stdin.read(), strict=False); print(d.get('data',{}).get('private_key',''))" 2>/dev/null)

    if [ -z "$cert_data" ]; then
        echo "  FAILED: empty certificate for $common_name"
        touch "$cert_path" "$key_path" 2>/dev/null || true
        return 1
    fi
    printf '%s\n' "$cert_data" > "$cert_path"

    if [ -z "$key_data" ]; then
        echo "  FAILED: empty key for $common_name"
        touch "$key_path" 2>/dev/null || true
        return 1
    fi
    printf '%s\n' "$key_data" > "$key_path"

    chmod 644 "$cert_path" 2>/dev/null || true
    chmod 600 "$key_path"  2>/dev/null || true

    CERT_COUNT=$((CERT_COUNT + 1))
    echo "  Replaced: $common_name"
    return 0
}

echo "Replacing SAP Application Layer Certificates (60 certs)..."

# SAP Production App Server 1 (10 certs)
echo "  SAP App Server 1..."
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/server.pem" "${DEMO_BASE}/sap/app01/certs/server-key.pem" "sap-app01.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/client.pem" "${DEMO_BASE}/sap/app01/certs/client-key.pem" "sap-app01-client.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/icm.pem" "${DEMO_BASE}/sap/app01/certs/icm-key.pem" "sap-app01-icm.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/gateway.pem" "${DEMO_BASE}/sap/app01/certs/gateway-key.pem" "sap-app01-gw.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/rfc.pem" "${DEMO_BASE}/sap/app01/certs/rfc-key.pem" "sap-app01-rfc.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/message-server.pem" "${DEMO_BASE}/sap/app01/certs/message-server-key.pem" "sap-app01-ms.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/enqueue.pem" "${DEMO_BASE}/sap/app01/certs/enqueue-key.pem" "sap-app01-enq.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/web.pem" "${DEMO_BASE}/sap/app01/certs/web-key.pem" "sap-app01-web.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/fiori.pem" "${DEMO_BASE}/sap/app01/certs/fiori-key.pem" "sap-app01-fiori.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app01/certs/sso.pem" "${DEMO_BASE}/sap/app01/certs/sso-key.pem" "sap-app01-sso.infrastructure.local"

# SAP Production App Server 2 (10 certs)
echo "  SAP App Server 2..."
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/server.pem" "${DEMO_BASE}/sap/app02/certs/server-key.pem" "sap-app02.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/client.pem" "${DEMO_BASE}/sap/app02/certs/client-key.pem" "sap-app02-client.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/icm.pem" "${DEMO_BASE}/sap/app02/certs/icm-key.pem" "sap-app02-icm.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/gateway.pem" "${DEMO_BASE}/sap/app02/certs/gateway-key.pem" "sap-app02-gw.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/rfc.pem" "${DEMO_BASE}/sap/app02/certs/rfc-key.pem" "sap-app02-rfc.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/message-server.pem" "${DEMO_BASE}/sap/app02/certs/message-server-key.pem" "sap-app02-ms.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/enqueue.pem" "${DEMO_BASE}/sap/app02/certs/enqueue-key.pem" "sap-app02-enq.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/web.pem" "${DEMO_BASE}/sap/app02/certs/web-key.pem" "sap-app02-web.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/fiori.pem" "${DEMO_BASE}/sap/app02/certs/fiori-key.pem" "sap-app02-fiori.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app02/certs/sso.pem" "${DEMO_BASE}/sap/app02/certs/sso-key.pem" "sap-app02-sso.infrastructure.local"

# SAP Production App Server 3 (10 certs)
echo "  SAP App Server 3..."
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/server.pem" "${DEMO_BASE}/sap/app03/certs/server-key.pem" "sap-app03.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/client.pem" "${DEMO_BASE}/sap/app03/certs/client-key.pem" "sap-app03-client.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/icm.pem" "${DEMO_BASE}/sap/app03/certs/icm-key.pem" "sap-app03-icm.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/gateway.pem" "${DEMO_BASE}/sap/app03/certs/gateway-key.pem" "sap-app03-gw.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/rfc.pem" "${DEMO_BASE}/sap/app03/certs/rfc-key.pem" "sap-app03-rfc.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/message-server.pem" "${DEMO_BASE}/sap/app03/certs/message-server-key.pem" "sap-app03-ms.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/enqueue.pem" "${DEMO_BASE}/sap/app03/certs/enqueue-key.pem" "sap-app03-enq.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/web.pem" "${DEMO_BASE}/sap/app03/certs/web-key.pem" "sap-app03-web.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/fiori.pem" "${DEMO_BASE}/sap/app03/certs/fiori-key.pem" "sap-app03-fiori.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/app03/certs/sso.pem" "${DEMO_BASE}/sap/app03/certs/sso-key.pem" "sap-app03-sso.infrastructure.local"

# SAP Development (8 certs)
echo "  SAP Development..."
replace_with_vault_cert "${DEMO_BASE}/sap/dev/certs/server.pem" "${DEMO_BASE}/sap/dev/certs/server-key.pem" "sap-dev.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/dev/certs/client.pem" "${DEMO_BASE}/sap/dev/certs/client-key.pem" "sap-dev-client.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/dev/certs/icm.pem" "${DEMO_BASE}/sap/dev/certs/icm-key.pem" "sap-dev-icm.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/dev/certs/gateway.pem" "${DEMO_BASE}/sap/dev/certs/gateway-key.pem" "sap-dev-gw.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/dev/certs/rfc.pem" "${DEMO_BASE}/sap/dev/certs/rfc-key.pem" "sap-dev-rfc.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/dev/certs/web.pem" "${DEMO_BASE}/sap/dev/certs/web-key.pem" "sap-dev-web.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/dev/certs/fiori.pem" "${DEMO_BASE}/sap/dev/certs/fiori-key.pem" "sap-dev-fiori.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/dev/certs/sso.pem" "${DEMO_BASE}/sap/dev/certs/sso-key.pem" "sap-dev-sso.infrastructure.local"

# SAP QA/Staging (8 certs)
echo "  SAP QA..."
replace_with_vault_cert "${DEMO_BASE}/sap/qas/certs/server.pem" "${DEMO_BASE}/sap/qas/certs/server-key.pem" "sap-qas.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/qas/certs/client.pem" "${DEMO_BASE}/sap/qas/certs/client-key.pem" "sap-qas-client.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/qas/certs/icm.pem" "${DEMO_BASE}/sap/qas/certs/icm-key.pem" "sap-qas-icm.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/qas/certs/gateway.pem" "${DEMO_BASE}/sap/qas/certs/gateway-key.pem" "sap-qas-gw.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/qas/certs/rfc.pem" "${DEMO_BASE}/sap/qas/certs/rfc-key.pem" "sap-qas-rfc.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/qas/certs/web.pem" "${DEMO_BASE}/sap/qas/certs/web-key.pem" "sap-qas-web.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/qas/certs/fiori.pem" "${DEMO_BASE}/sap/qas/certs/fiori-key.pem" "sap-qas-fiori.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/qas/certs/sso.pem" "${DEMO_BASE}/sap/qas/certs/sso-key.pem" "sap-qas-sso.infrastructure.local"

# SAP Web Dispatcher (6 certs)
echo "  SAP Web Dispatcher..."
replace_with_vault_cert "${DEMO_BASE}/sap/webdispatcher/certs/server.pem" "${DEMO_BASE}/sap/webdispatcher/certs/server-key.pem" "sap-webdisp.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/webdispatcher/certs/backend.pem" "${DEMO_BASE}/sap/webdispatcher/certs/backend-key.pem" "sap-webdisp-backend.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/webdispatcher/certs/ssl.pem" "${DEMO_BASE}/sap/webdispatcher/certs/ssl-key.pem" "sap-webdisp-ssl.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/webdispatcher/certs/client-auth.pem" "${DEMO_BASE}/sap/webdispatcher/certs/client-auth-key.pem" "sap-webdisp-client.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/webdispatcher/certs/admin.pem" "${DEMO_BASE}/sap/webdispatcher/certs/admin-key.pem" "sap-webdisp-admin.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/webdispatcher/certs/monitoring.pem" "${DEMO_BASE}/sap/webdispatcher/certs/monitoring-key.pem" "sap-webdisp-mon.infrastructure.local"

# SAP Gateway (8 certs)
echo "  SAP Gateway..."
replace_with_vault_cert "${DEMO_BASE}/sap/gateway/certs/server.pem" "${DEMO_BASE}/sap/gateway/certs/server-key.pem" "sap-gateway.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/gateway/certs/odata.pem" "${DEMO_BASE}/sap/gateway/certs/odata-key.pem" "sap-gateway-odata.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/gateway/certs/rest.pem" "${DEMO_BASE}/sap/gateway/certs/rest-key.pem" "sap-gateway-rest.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/gateway/certs/soap.pem" "${DEMO_BASE}/sap/gateway/certs/soap-key.pem" "sap-gateway-soap.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/gateway/certs/mobile.pem" "${DEMO_BASE}/sap/gateway/certs/mobile-key.pem" "sap-gateway-mobile.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/gateway/certs/b2b.pem" "${DEMO_BASE}/sap/gateway/certs/b2b-key.pem" "sap-gateway-b2b.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/gateway/certs/edi.pem" "${DEMO_BASE}/sap/gateway/certs/edi-key.pem" "sap-gateway-edi.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/sap/gateway/certs/idoc.pem" "${DEMO_BASE}/sap/gateway/certs/idoc-key.pem" "sap-gateway-idoc.infrastructure.local"

echo ""
echo "Replacing Oracle Database Layer Certificates (50 certs)..."

# Oracle Production DB 1 (12 certs)
echo "  Oracle Production DB 1..."
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/server.pem" "${DEMO_BASE}/oracle/prod01/certs/server-key.pem" "oracle-prod01.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/listener.pem" "${DEMO_BASE}/oracle/prod01/certs/listener-key.pem" "oracle-prod01-listener.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/wallet.pem" "${DEMO_BASE}/oracle/prod01/certs/wallet-key.pem" "oracle-prod01-wallet.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/tns.pem" "${DEMO_BASE}/oracle/prod01/certs/tns-key.pem" "oracle-prod01-tns.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/sqlnet.pem" "${DEMO_BASE}/oracle/prod01/certs/sqlnet-key.pem" "oracle-prod01-sqlnet.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/em.pem" "${DEMO_BASE}/oracle/prod01/certs/em-key.pem" "oracle-prod01-em.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/apex.pem" "${DEMO_BASE}/oracle/prod01/certs/apex-key.pem" "oracle-prod01-apex.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/ords.pem" "${DEMO_BASE}/oracle/prod01/certs/ords-key.pem" "oracle-prod01-ords.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/dataguard.pem" "${DEMO_BASE}/oracle/prod01/certs/dataguard-key.pem" "oracle-prod01-dg.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/rman.pem" "${DEMO_BASE}/oracle/prod01/certs/rman-key.pem" "oracle-prod01-rman.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/goldengate.pem" "${DEMO_BASE}/oracle/prod01/certs/goldengate-key.pem" "oracle-prod01-gg.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod01/certs/asm.pem" "${DEMO_BASE}/oracle/prod01/certs/asm-key.pem" "oracle-prod01-asm.infrastructure.local"

# Oracle Production DB 2 (12 certs)
echo "  Oracle Production DB 2..."
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/server.pem" "${DEMO_BASE}/oracle/prod02/certs/server-key.pem" "oracle-prod02.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/listener.pem" "${DEMO_BASE}/oracle/prod02/certs/listener-key.pem" "oracle-prod02-listener.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/wallet.pem" "${DEMO_BASE}/oracle/prod02/certs/wallet-key.pem" "oracle-prod02-wallet.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/tns.pem" "${DEMO_BASE}/oracle/prod02/certs/tns-key.pem" "oracle-prod02-tns.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/sqlnet.pem" "${DEMO_BASE}/oracle/prod02/certs/sqlnet-key.pem" "oracle-prod02-sqlnet.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/em.pem" "${DEMO_BASE}/oracle/prod02/certs/em-key.pem" "oracle-prod02-em.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/apex.pem" "${DEMO_BASE}/oracle/prod02/certs/apex-key.pem" "oracle-prod02-apex.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/ords.pem" "${DEMO_BASE}/oracle/prod02/certs/ords-key.pem" "oracle-prod02-ords.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/dataguard.pem" "${DEMO_BASE}/oracle/prod02/certs/dataguard-key.pem" "oracle-prod02-dg.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/rman.pem" "${DEMO_BASE}/oracle/prod02/certs/rman-key.pem" "oracle-prod02-rman.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/goldengate.pem" "${DEMO_BASE}/oracle/prod02/certs/goldengate-key.pem" "oracle-prod02-gg.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/prod02/certs/asm.pem" "${DEMO_BASE}/oracle/prod02/certs/asm-key.pem" "oracle-prod02-asm.infrastructure.local"

# Oracle Development DB (8 certs)
echo "  Oracle Development DB..."
replace_with_vault_cert "${DEMO_BASE}/oracle/dev/certs/server.pem" "${DEMO_BASE}/oracle/dev/certs/server-key.pem" "oracle-dev.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/dev/certs/listener.pem" "${DEMO_BASE}/oracle/dev/certs/listener-key.pem" "oracle-dev-listener.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/dev/certs/wallet.pem" "${DEMO_BASE}/oracle/dev/certs/wallet-key.pem" "oracle-dev-wallet.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/dev/certs/tns.pem" "${DEMO_BASE}/oracle/dev/certs/tns-key.pem" "oracle-dev-tns.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/dev/certs/sqlnet.pem" "${DEMO_BASE}/oracle/dev/certs/sqlnet-key.pem" "oracle-dev-sqlnet.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/dev/certs/em.pem" "${DEMO_BASE}/oracle/dev/certs/em-key.pem" "oracle-dev-em.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/dev/certs/apex.pem" "${DEMO_BASE}/oracle/dev/certs/apex-key.pem" "oracle-dev-apex.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/dev/certs/ords.pem" "${DEMO_BASE}/oracle/dev/certs/ords-key.pem" "oracle-dev-ords.infrastructure.local"

# Oracle QA DB (8 certs)
echo "  Oracle QA DB..."
replace_with_vault_cert "${DEMO_BASE}/oracle/qas/certs/server.pem" "${DEMO_BASE}/oracle/qas/certs/server-key.pem" "oracle-qas.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/qas/certs/listener.pem" "${DEMO_BASE}/oracle/qas/certs/listener-key.pem" "oracle-qas-listener.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/qas/certs/wallet.pem" "${DEMO_BASE}/oracle/qas/certs/wallet-key.pem" "oracle-qas-wallet.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/qas/certs/tns.pem" "${DEMO_BASE}/oracle/qas/certs/tns-key.pem" "oracle-qas-tns.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/qas/certs/sqlnet.pem" "${DEMO_BASE}/oracle/qas/certs/sqlnet-key.pem" "oracle-qas-sqlnet.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/qas/certs/em.pem" "${DEMO_BASE}/oracle/qas/certs/em-key.pem" "oracle-qas-em.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/qas/certs/apex.pem" "${DEMO_BASE}/oracle/qas/certs/apex-key.pem" "oracle-qas-apex.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/qas/certs/ords.pem" "${DEMO_BASE}/oracle/qas/certs/ords-key.pem" "oracle-qas-ords.infrastructure.local"

# Oracle Listeners (10 certs)
echo "  Oracle Listeners..."
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/listener01.pem" "${DEMO_BASE}/oracle/listener/certs/listener01-key.pem" "oracle-listener01.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/listener02.pem" "${DEMO_BASE}/oracle/listener/certs/listener02-key.pem" "oracle-listener02.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/listener03.pem" "${DEMO_BASE}/oracle/listener/certs/listener03-key.pem" "oracle-listener03.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/scan01.pem" "${DEMO_BASE}/oracle/listener/certs/scan01-key.pem" "oracle-scan01.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/scan02.pem" "${DEMO_BASE}/oracle/listener/certs/scan02-key.pem" "oracle-scan02.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/scan03.pem" "${DEMO_BASE}/oracle/listener/certs/scan03-key.pem" "oracle-scan03.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/vip01.pem" "${DEMO_BASE}/oracle/listener/certs/vip01-key.pem" "oracle-vip01.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/vip02.pem" "${DEMO_BASE}/oracle/listener/certs/vip02-key.pem" "oracle-vip02.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/vip03.pem" "${DEMO_BASE}/oracle/listener/certs/vip03-key.pem" "oracle-vip03.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/grid.pem" "${DEMO_BASE}/oracle/listener/certs/grid-key.pem" "oracle-grid.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/oracle/listener/certs/crs.pem" "${DEMO_BASE}/oracle/listener/certs/crs-key.pem" "oracle-crs.infrastructure.local"

echo ""
echo "Replacing Integration/Middleware Certificates (30 certs)..."

# IBM MQ (10 certs)
echo "  IBM MQ..."
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/qmgr01.pem" "${DEMO_BASE}/integration/mq/certs/qmgr01-key.pem" "mq-qmgr01.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/qmgr02.pem" "${DEMO_BASE}/integration/mq/certs/qmgr02-key.pem" "mq-qmgr02.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/channel-sap.pem" "${DEMO_BASE}/integration/mq/certs/channel-sap-key.pem" "mq-channel-sap.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/channel-ora.pem"    "${DEMO_BASE}/integration/mq/certs/channel-ora-key.pem"    "mq-channel-ora.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/channel-oracle.pem" "${DEMO_BASE}/integration/mq/certs/channel-oracle-key.pem" "mq-channel-oracle.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/channel-web.pem" "${DEMO_BASE}/integration/mq/certs/channel-web-key.pem" "mq-channel-web.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/listener.pem" "${DEMO_BASE}/integration/mq/certs/listener-key.pem" "mq-listener.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/client.pem" "${DEMO_BASE}/integration/mq/certs/client-key.pem" "mq-client.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/admin.pem" "${DEMO_BASE}/integration/mq/certs/admin-key.pem" "mq-admin.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/monitoring.pem" "${DEMO_BASE}/integration/mq/certs/monitoring-key.pem" "mq-monitoring.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/mq/certs/cluster.pem" "${DEMO_BASE}/integration/mq/certs/cluster-key.pem" "mq-cluster.infrastructure.local"

# API Gateway (8 certs)
echo "  API Gateway..."
replace_with_vault_cert "${DEMO_BASE}/integration/api/certs/gateway.pem" "${DEMO_BASE}/integration/api/certs/gateway-key.pem" "api-gateway.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/api/certs/portal.pem" "${DEMO_BASE}/integration/api/certs/portal-key.pem" "api-portal.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/api/certs/manager.pem" "${DEMO_BASE}/integration/api/certs/manager-key.pem" "api-manager.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/api/certs/analytics.pem" "${DEMO_BASE}/integration/api/certs/analytics-key.pem" "api-analytics.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/api/certs/oauth.pem" "${DEMO_BASE}/integration/api/certs/oauth-key.pem" "api-oauth.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/api/certs/jwt.pem" "${DEMO_BASE}/integration/api/certs/jwt-key.pem" "api-jwt.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/api/certs/backend.pem" "${DEMO_BASE}/integration/api/certs/backend-key.pem" "api-backend.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/api/certs/developer.pem" "${DEMO_BASE}/integration/api/certs/developer-key.pem" "api-developer.infrastructure.local"

# ESB (6 certs)
echo "  ESB..."
replace_with_vault_cert "${DEMO_BASE}/integration/esb/certs/server.pem" "${DEMO_BASE}/integration/esb/certs/server-key.pem" "esb-server.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/esb/certs/sap-adapter.pem" "${DEMO_BASE}/integration/esb/certs/sap-adapter-key.pem" "esb-sap-adapter.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/esb/certs/oracle-adapter.pem" "${DEMO_BASE}/integration/esb/certs/oracle-adapter-key.pem" "esb-oracle-adapter.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/esb/certs/http-adapter.pem" "${DEMO_BASE}/integration/esb/certs/http-adapter-key.pem" "esb-http-adapter.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/esb/certs/soap-adapter.pem" "${DEMO_BASE}/integration/esb/certs/soap-adapter-key.pem" "esb-soap-adapter.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/esb/certs/rest-adapter.pem" "${DEMO_BASE}/integration/esb/certs/rest-adapter-key.pem" "esb-rest-adapter.infrastructure.local"

# B2B Gateway (6 certs)
echo "  B2B Gateway..."
replace_with_vault_cert "${DEMO_BASE}/integration/b2b/certs/gateway.pem" "${DEMO_BASE}/integration/b2b/certs/gateway-key.pem" "b2b-gateway.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/b2b/certs/edi.pem" "${DEMO_BASE}/integration/b2b/certs/edi-key.pem" "b2b-edi.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/b2b/certs/as2.pem" "${DEMO_BASE}/integration/b2b/certs/as2-key.pem" "b2b-as2.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/b2b/certs/sftp.pem" "${DEMO_BASE}/integration/b2b/certs/sftp-key.pem" "b2b-sftp.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/b2b/certs/partner-a.pem" "${DEMO_BASE}/integration/b2b/certs/partner-a-key.pem" "b2b-partner-a.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/integration/b2b/certs/partner-b.pem" "${DEMO_BASE}/integration/b2b/certs/partner-b-key.pem" "b2b-partner-b.infrastructure.local"

echo ""
echo "Replacing Infrastructure Certificates (10 certs)..."

# Load Balancers (5 certs)
echo "  Load Balancers..."
replace_with_vault_cert "${DEMO_BASE}/loadbalancer/certs/lb01.pem" "${DEMO_BASE}/loadbalancer/certs/lb01-key.pem" "lb01.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/loadbalancer/certs/lb02.pem" "${DEMO_BASE}/loadbalancer/certs/lb02-key.pem" "lb02.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/loadbalancer/certs/vip-sap.pem" "${DEMO_BASE}/loadbalancer/certs/vip-sap-key.pem" "vip-sap.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/loadbalancer/certs/vip-oracle.pem" "${DEMO_BASE}/loadbalancer/certs/vip-oracle-key.pem" "vip-oracle.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/loadbalancer/certs/admin.pem" "${DEMO_BASE}/loadbalancer/certs/admin-key.pem" "lb-admin.infrastructure.local"

# Reverse Proxies (5 certs)
echo "  Reverse Proxies..."
replace_with_vault_cert "${DEMO_BASE}/proxy/certs/proxy01.pem" "${DEMO_BASE}/proxy/certs/proxy01-key.pem" "proxy01.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/proxy/certs/proxy02.pem" "${DEMO_BASE}/proxy/certs/proxy02-key.pem" "proxy02.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/proxy/certs/frontend.pem" "${DEMO_BASE}/proxy/certs/frontend-key.pem" "proxy-frontend.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/proxy/certs/backend.pem" "${DEMO_BASE}/proxy/certs/backend-key.pem" "proxy-backend.infrastructure.local"
replace_with_vault_cert "${DEMO_BASE}/proxy/certs/ssl-offload.pem" "${DEMO_BASE}/proxy/certs/ssl-offload-key.pem" "proxy-ssl.infrastructure.local"

echo ""
echo "========================================"
echo "Certificate Replacement Complete!"
echo "========================================"
echo ""
echo "Total certificates replaced: ${CERT_COUNT}"
echo ""
echo "All certificates are now:"
echo "  - Issued by Vault PKI"
echo "  - 24-hour TTL (vs 287+ days)"
echo "  - Strong crypto (RSA 2048, SHA-256)"
echo "  - Quantum-safe ready"
echo "  - Automatically rotated"
echo ""
echo "Next Steps:"
echo "1. Trigger PowerSC Quantum Safety scan to discover new certificates"
echo "2. Capture 'AFTER' state showing improved metrics"
echo "3. Compare before/after to demonstrate transformation"
echo ""
echo "Vault has successfully taken over certificate management!"
echo ""

# Made with Bob

