#!/bin/bash
# Discover what endpoints and command names PowerSC actually knows about
# Per-deployment values (hosts, password) come from ui/.env.local via lib-env.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"
BASE="$API_BASE"
AUTH="powersc:${POWERSC_PASS}"

echo "=== All systems known to PowerSC ==="
for path in \
  "systems" \
  "system" \
  "managedSystems" \
  "managedsystems" \
  "managed-systems" \
  "assets" \
  "asset" \
  "clients" \
  "client" \
  "endpoints" \
  "endpoint" \
  "nodes" \
  "node" \
  "host" \
  "hosts" \
  "agents" \
  "agent"; do
  result=$(curl -sk -u "$AUTH" -w "HTTP:%{http_code}" "$BASE/$path")
  code=$(echo "$result" | grep -o "HTTP:[0-9]*" | cut -d: -f2)
  body=$(echo "$result" | sed 's/HTTP:[0-9]*//' | head -c 300)
  if [ "$code" = "200" ] && [ -n "$body" ]; then
    echo "FOUND: $path (HTTP $code)"
    echo "$body"
    echo "---"
  else
    echo "404  $path"
  fi
done

echo ""
echo "=== Summary without endpoint param (list all?) ==="
curl -sk -u "$AUTH" "$BASE/quantumsafe/summary" | python3 -m json.tool 2>/dev/null

echo ""
echo "=== Try runQuantumSafeScan with no elementId ==="
curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
  -d '{"orders":[{"commandName":"runQuantumSafeScan"}]}' \
  "$BASE/command" | python3 -m json.tool 2>/dev/null
