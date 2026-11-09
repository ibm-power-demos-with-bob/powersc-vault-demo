#!/bin/bash
# Per-deployment values (hosts, user, password) come from ui/.env.local via lib-env.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"
ENDPOINT="$AIX_HOST"
BASE="$API_BASE"
AUTH_ADMIN="powersc-admin:${POWERSC_PASS}"
SCAN_DIR="$SCAN_FOLDER"

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
