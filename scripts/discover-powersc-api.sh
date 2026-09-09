#!/bin/bash
BASE="https://pvm01-731cq22k.p642.pok-systems.techzone.ibm.com/ws/powerscui"
AUTH="powersc:(8FPU5dUC4a+P1d"
ENDPOINT="pvm03-731cq22k.p642.pok-systems.techzone.ibm.com"

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
  body="{\"orders\":[{\"commandName\":\"$cmd\",\"elementId\":\"$ENDPOINT\",\"scanFolders\":\"/home/U5V9KZP/demo-certs\"}]}"
  result=$(curl -sk -u "$AUTH" -X POST -H "Content-Type: application/json" -d "$body" -w "\nHTTP:%{http_code}" "$BASE/command")
  echo "$cmd => $result"
done
