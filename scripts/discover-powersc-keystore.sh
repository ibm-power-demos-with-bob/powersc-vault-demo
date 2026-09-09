#!/bin/bash
# Discover PowerSC keystore / endpoint admin API paths
BASE="https://pvm01-731cq22k.p642.pok-systems.techzone.ibm.com/ws/powerscui"
AUTH="powersc:(8FPU5dUC4a+P1d"
ENDPOINT="pvm03-731cq22k.p642.pok-systems.techzone.ibm.com"

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
