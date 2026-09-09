#!/bin/bash
# Discover what endpoints and command names PowerSC actually knows about
BASE="https://pvm01-731cq22k.p642.pok-systems.techzone.ibm.com/ws/powerscui"
AUTH="powersc:(8FPU5dUC4a+P1d"

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
