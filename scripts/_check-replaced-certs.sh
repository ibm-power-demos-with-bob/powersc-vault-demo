#!/bin/bash
# Check what certs are actually in ~/demo-certs after the Vault replace run
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"   # AIX_HOST / AIX_USER for this deployment

ssh -o StrictHostKeyChecking=no "${AIX_USER}@${AIX_HOST}" '
echo "--- sap/app01/certs/server.pem (should be Vault-issued) ---"
openssl x509 -in ~/demo-certs/sap/app01/certs/server.pem -noout -issuer -dates 2>/dev/null

echo ""
echo "--- oracle/prod01/certs/server.pem ---"
openssl x509 -in ~/demo-certs/oracle/prod01/certs/server.pem -noout -issuer -dates 2>/dev/null

echo ""
echo "--- key size check (should be 2048 if Vault-issued) ---"
openssl x509 -in ~/demo-certs/sap/app01/certs/server.pem -noout -text 2>/dev/null | grep "Public-Key"

echo ""
echo "--- signature algorithm (should be sha256 if Vault-issued) ---"
openssl x509 -in ~/demo-certs/sap/app01/certs/server.pem -noout -text 2>/dev/null | grep "Signature Algorithm" | head -1
'
