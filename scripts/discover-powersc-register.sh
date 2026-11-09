#!/bin/bash
# Try to register pvm03 as a managed system in PowerSC
# Per-deployment values (hosts, password) come from ui/.env.local via lib-env.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"
BASE="$API_BASE"
AUTH="powersc:${POWERSC_PASS}"
ENDPOINT="$AIX_HOST"
ENDPOINT_IP="${AIX_IP:-$(getent hosts "$AIX_HOST" | awk '{print $1}')}"

echo "=== Try POST to /systems ==="
curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
  -d "{\"hostname\":\"$ENDPOINT\",\"ipAddress\":\"$ENDPOINT_IP\"}" \
  -w "\nHTTP:%{http_code}" "$BASE/systems"

echo ""
echo "=== Try POST /command addSystem ==="
curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"addSystem\",\"elementId\":\"$ENDPOINT\"}]}" \
  -w "\nHTTP:%{http_code}" "$BASE/command"

echo ""
echo "=== Try POST /command registerSystem ==="
curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"registerSystem\",\"elementId\":\"$ENDPOINT\"}]}" \
  -w "\nHTTP:%{http_code}" "$BASE/command"

echo ""
echo "=== Try POST /command discoverSystem ==="
curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"discoverSystem\",\"elementId\":\"$ENDPOINT\"}]}" \
  -w "\nHTTP:%{http_code}" "$BASE/command"

echo ""
echo "=== Try GET /systems with full response ==="
curl -sk -u "$AUTH" "$BASE/systems" | python3 -m json.tool 2>/dev/null

echo ""
echo "=== Check if there is a separate registration API base path ==="
for path in "v1/systems" "api/systems" "powerscui/v1" "powerscui/v2" "rest/systems" "rest/v1/systems"; do
  code=$(curl -sk -u "$AUTH" -o /dev/null -w "%{http_code}" "${POWERSC_URL}/ws/$path")
  echo "$code  /ws/$path"
done
