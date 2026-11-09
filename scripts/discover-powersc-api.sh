#!/bin/bash
# Per-deployment values (hosts, user, password) come from ui/.env.local via lib-env.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"
BASE="$API_BASE"
AUTH="powersc:${POWERSC_PASS}"
ENDPOINT="$AIX_HOST"

echo "=== GET paths ==="
for path in \
  "quantumsafe/summary" \
  "quantumsafe/config" \
  "quantumsafe/settings" \
  "quantumsafe/folders" \
  "quantumsafe/scanfolders" \
  "quantumsafe/policy" \
  "quantumsafe/inventory" \
  "config" \
  "settings" \
  "nodes" \
  "assets" \
  "commands" \
  "inventory" \
  "inventory/certificates"; do
  code=$(curl -sk -u "$AUTH" -o /tmp/psc_resp.txt -w "%{http_code}" "$BASE/$path?endpoint=$ENDPOINT")
  body=$(cat /tmp/psc_resp.txt | head -c 200)
  echo "$code  $path  =>  $body"
done

echo ""
echo "=== Known command names via POST /command ==="
for cmd in \
  "runQuantumSafeScan" \
  "setQuantumSafeScanFolders" \
  "setScanFolders" \
  "updateScanFolders" \
  "configureQuantumSafe" \
  "setEndpointConfig" \
  "getCommands"; do
  body="{\"orders\":[{\"commandName\":\"$cmd\",\"elementId\":\"$ENDPOINT\",\"scanFolders\":\"$SCAN_FOLDER\"}]}"
  result=$(curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" -d "$body" -w "\nHTTP:%{http_code}" "$BASE/command")
  echo "$cmd => $result"
done
