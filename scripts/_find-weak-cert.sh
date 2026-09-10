#!/bin/bash
# Find the one remaining weak cert in ~/demo-certs
AIX_HOST="$(grep AIX_HOST ~/powersc-vault-demo/ui/.env.local | cut -d= -f2 | tr -d ' \r')"

ssh -o StrictHostKeyChecking=no "U5V9KZP@${AIX_HOST}" '
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
