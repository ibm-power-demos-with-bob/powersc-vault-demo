#!/bin/bash
# Find the one remaining weak cert in ~/demo-certs
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"   # AIX_HOST / AIX_USER for this deployment

ssh -o StrictHostKeyChecking=no "${AIX_USER}@${AIX_HOST}" '
echo "=== Total pem files in ~/demo-certs ==="
find ~/demo-certs -name "*.pem" | wc -l

echo ""
echo "=== Certs NOT issued by Vault (weak/old) ==="
find ~/demo-certs -name "*.pem" | while read f; do
  issuer=$(openssl x509 -in "$f" -noout -issuer 2>/dev/null)
  if echo "$issuer" | grep -qv "Demo Internal Root CA"; then
    echo "$f  |  $issuer"
  fi
done
'
