#!/bin/bash
ENDPOINT="pvm03-731cq22k.p642.pok-systems.techzone.ibm.com"
BASE="https://pvm01-731cq22k.p642.pok-systems.techzone.ibm.com/ws/powerscui"
AUTH_ADMIN='powersc-admin:(8FPU5dUC4a+P1d'
AUTH_USER='powersc:(8FPU5dUC4a+P1d'

echo "=== Check current summary (should show scanFolders) ==="
curl -sk -u "$AUTH_USER" "$BASE/quantumsafe/summary?endpoint=$ENDPOINT"

echo ""
echo "=== Trigger scan as powersc-admin ==="
curl -sk -u "$AUTH_ADMIN" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"runQuantumSafeScan\",\"elementId\":\"$ENDPOINT\"}]}" \
  "$BASE/command"

echo ""
echo "=== Wait 60s then check summary ==="
sleep 60
curl -sk -u "$AUTH_USER" "$BASE/quantumsafe/summary?endpoint=$ENDPOINT" | python3 -m json.tool 2>/dev/null
