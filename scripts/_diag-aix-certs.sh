#!/bin/bash
# Check the actual PowerSC scan folder config on pvm03
AIX_HOST="$(grep AIX_HOST ~/powersc-vault-demo/ui/.env.local | cut -d= -f2 | tr -d ' \r')"
ssh -o StrictHostKeyChecking=no "U5V9KZP@${AIX_HOST}" '
echo "=== quantumSafe.properties ==="
cat /etc/security/powersc/uiAgent/quantumSafe.properties 2>/dev/null || echo "file not found"

echo ""
echo "=== cert count in scanFolders path ==="
FOLDER=$(grep scanFolders /etc/security/powersc/uiAgent/quantumSafe.properties 2>/dev/null | cut -d= -f2 | tr -d " \r")
echo "scanFolders=$FOLDER"
find "$FOLDER" -name "*.pem" 2>/dev/null | wc -l

echo ""
echo "=== sample cert from that folder ==="
find "$FOLDER" -name "server.pem" 2>/dev/null | head -1 | xargs -I{} openssl x509 -in {} -noout -issuer -enddate 2>/dev/null
'
