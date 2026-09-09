#!/bin/bash
ENDPOINT="pvm03-731cq22k.p642.pok-systems.techzone.ibm.com"
BASE="https://pvm01-731cq22k.p642.pok-systems.techzone.ibm.com/ws/powerscui"
AUTH='powersc:(8FPU5dUC4a+P1d'

echo "=== Setting scan folder ==="
curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"setQuantumSafeScanFolders\",\"elementId\":\"$ENDPOINT\",\"scanFolders\":\"/home/U5V9KZP/demo-certs\"}]}" \
  "$BASE/command"

echo ""
echo "=== Triggering scan ==="
curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"runQuantumSafeScan\",\"elementId\":\"$ENDPOINT\"}]}" \
  "$BASE/command"

echo ""
echo "=== Waiting 30s then checking summary ==="
sleep 30
curl -sk -u "$AUTH" "$BASE/quantumsafe/summary?endpoint=$ENDPOINT" | python3 -m json.tool 2>/dev/null
