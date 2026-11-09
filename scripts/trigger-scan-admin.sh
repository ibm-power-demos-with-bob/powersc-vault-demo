#!/bin/bash
# Per-deployment values (hosts, password) come from ui/.env.local via lib-env.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"
ENDPOINT="$AIX_HOST"
BASE="$API_BASE"
# TechZone sets the same password on both PowerSC accounts
AUTH_ADMIN="powersc-admin:${POWERSC_PASS}"
AUTH_USER="powersc:${POWERSC_PASS}"

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
