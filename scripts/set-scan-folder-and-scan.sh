#!/bin/bash
# Per-deployment values (hosts, user, password) come from ui/.env.local via lib-env.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"
ENDPOINT="$AIX_HOST"
BASE="$API_BASE"
AUTH="powersc:${POWERSC_PASS}"

echo "=== Setting scan folder ==="
curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"setQuantumSafeScanFolders\",\"elementId\":\"$ENDPOINT\",\"scanFolders\":\"$SCAN_FOLDER\"}]}" \
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
