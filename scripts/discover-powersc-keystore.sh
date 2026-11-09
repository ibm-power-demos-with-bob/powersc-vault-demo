#!/bin/bash
# Discover PowerSC keystore / endpoint admin API paths
# Per-deployment values (hosts, password) come from ui/.env.local via lib-env.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"
BASE="$API_BASE"
AUTH="powersc:${POWERSC_PASS}"
ENDPOINT="$AIX_HOST"

echo "=== Keystore / endpoint admin paths ==="
for path in \
  "keystore" \
  "keystores" \
  "keystore/request" \
  "keystore/requests" \
  "keystoreRequest" \
  "keystoreRequests" \
  "endpointAdmin" \
  "endpoint-admin" \
  "endpointadmin" \
  "admin" \
  "admin/keystore" \
  "admin/endpoints" \
  "registration" \
  "register" \
  "onboard" \
  "onboarding" \
  "provisioning" \
  "provision" \
  "certificate" \
  "certificates" \
  "trust" \
  "truststore" \
  "pki" \
  "tls"; do
  result=$(curl -sk -u "$AUTH" -w "\nHTTP:%{http_code}" "$BASE/$path")
  code=$(echo "$result" | grep -o "HTTP:[0-9]*" | cut -d: -f2)
  body=$(echo "$result" | grep -v "HTTP:[0-9]*" | head -c 200)
  if [ "$code" != "404" ]; then
    echo "HTTP $code  $path"
    [ -n "$body" ] && echo "  $body"
  else
    echo "404  $path"
  fi
done

echo ""
echo "=== Try keystore-related command names ==="
for cmd in \
  "generateKeystore" \
  "requestKeystore" \
  "createKeystore" \
  "installKeystore" \
  "generateCertificate" \
  "trustEndpoint" \
  "addEndpoint" \
  "enrollEndpoint" \
  "connectEndpoint" \
  "pairEndpoint"; do
  result=$(curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" \
    -d "{\"orders\":[{\"commandName\":\"$cmd\",\"elementId\":\"$ENDPOINT\"}]}" \
    "$BASE/command")
  echo "$cmd => $result"
done

echo ""
echo "=== GET /systems with verbose to see all headers/links ==="
curl -sk -u "$AUTH" -D - "$BASE/systems" 2>/dev/null | head -30
