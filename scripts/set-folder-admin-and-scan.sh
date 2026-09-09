#!/bin/bash
ENDPOINT="pvm03-731cq22k.p642.pok-systems.techzone.ibm.com"
BASE="https://pvm01-731cq22k.p642.pok-systems.techzone.ibm.com/ws/powerscui"
AUTH_ADMIN='powersc-admin:(8FPU5dUC4a+P1d'
SCAN_DIR="/home/U5V9KZP/demo-certs"

echo "=== Set scan folder as powersc-admin ==="
curl -sk -u "$AUTH_ADMIN" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"setQuantumSafeScanFolders\",\"elementId\":\"$ENDPOINT\",\"scanFolders\":\"$SCAN_DIR\"}]}" \
  "$BASE/command"

echo ""
echo "=== Trigger scan ==="
curl -sk -u "$AUTH_ADMIN" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"runQuantumSafeScan\",\"elementId\":\"$ENDPOINT\"}]}" \
  "$BASE/command"

echo ""
echo "=== Wait 60s then check summary ==="
sleep 60
curl -sk -u "$AUTH_ADMIN" "$BASE/quantumsafe/summary?endpoint=$ENDPOINT" | python3 -m json.tool 2>/dev/null
