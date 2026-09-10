#!/bin/bash
# Diagnose why the Vault replace isn't working
source <(grep -E '^(AIX_HOST|AIX_USER|AIX_SSH_KEY_PATH|VAULT_ADDR|VAULT_TOKEN|VAULT_ADDR_EXTERNAL)' \
  ~/powersc-vault-demo/ui/.env.local | tr -d '\r')

echo "=== SSH key check ==="
ls -la "$AIX_SSH_KEY_PATH" 2>/dev/null || echo "KEY NOT FOUND at $AIX_SSH_KEY_PATH"

echo ""
echo "=== SSH connectivity to AIX ==="
ssh -i "$AIX_SSH_KEY_PATH" -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
  "${AIX_USER}@${AIX_HOST}" 'echo SSH-OK && whoami' 2>&1

echo ""
echo "=== Vault reachable from AIX (using VAULT_ADDR_EXTERNAL) ==="
ssh -i "$AIX_SSH_KEY_PATH" -o StrictHostKeyChecking=no \
  "${AIX_USER}@${AIX_HOST}" \
  "curl -sf '${VAULT_ADDR_EXTERNAL}/v1/sys/health' | head -c 100 && echo ''" 2>&1

echo ""
echo "=== Test Vault certificate issue from AIX ==="
ssh -i "$AIX_SSH_KEY_PATH" -o StrictHostKeyChecking=no \
  "${AIX_USER}@${AIX_HOST}" \
  "export PATH=/opt/freeware/bin:\$PATH; curl -sf -X POST \
   -H 'X-Vault-Token: ${VAULT_TOKEN}' \
   -H 'Content-Type: application/json' \
   -d '{\"common_name\":\"test.howdens.local\",\"ttl\":\"24h\"}' \
   '${VAULT_ADDR_EXTERNAL}/v1/pki/issue/sap-oracle' 2>&1 | head -c 300"

echo ""
echo "=== Current cert in ~/demo-certs/sap/app01/certs/server.pem ==="
ssh -i "$AIX_SSH_KEY_PATH" -o StrictHostKeyChecking=no \
  "${AIX_USER}@${AIX_HOST}" \
  'openssl x509 -in ~/demo-certs/sap/app01/certs/server.pem -noout -issuer -dates 2>/dev/null'
