#!/bin/bash
# Fix quantumSafe.properties on pvm03 and trigger a fresh scan
# Runs on pvm02 — SSHes to pvm03 with sudo (U5V9KZP has NOPASSWD:ALL)

source <(grep -E '^(POWERSC_URL|POWERSC_USER|POWERSC_PASS|AIX_HOST)' \
  ~/powersc-vault-demo/ui/.env.local | tr -d '\r')

SCAN_FOLDER="/home/U5V9KZP/demo-certs"
API_BASE="${POWERSC_URL}/ws/powerscui"
PROPS="/etc/security/powersc/uiAgent/quantumSafe.properties"

echo "=== Step 1: Write quantumSafe.properties on pvm03 ==="
ssh -o StrictHostKeyChecking=no "U5V9KZP@${AIX_HOST}" \
  "sudo mkdir -p /etc/security/powersc/uiAgent && \
   printf 'scanType=all\nscanFolders=${SCAN_FOLDER}\nportScan=false\nfileExtensions=.key,.pem,.pkcs8,.p8,.pk8,.pvk,.pub,.keystore,.jks,.p12,.pfx,.crt,.cer,.der,.p7b,.p7c,.spc,.crl,.cert,.arm,.ca-bundle,.kdb\n' \
   | sudo tee ${PROPS} && \
   echo 'Written:' && sudo cat ${PROPS}"

echo ""
echo "=== Step 2: Restart pscuiagent on pvm03 ==="
ssh -o StrictHostKeyChecking=no "U5V9KZP@${AIX_HOST}" \
  "sudo stopsrc -s pscuiagent 2>/dev/null || true; sleep 3; sudo startsrc -s pscuiagent && echo agent-restarted"

echo ""
echo "=== Step 3: Wait 15s for agent to register ==="
sleep 15

echo ""
echo "=== Step 4: Trigger fresh PowerSC scan ==="
curl -sk -u "${POWERSC_USER}:${POWERSC_PASS}" \
  -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"runQuantumSafeScan\",\"elementId\":\"${AIX_HOST}\"}]}" \
  "${API_BASE}/command"
echo ""

echo ""
echo "=== Step 5: Poll for results (up to 90s) ==="
DEADLINE=$(( $(date +%s) + 90 ))
while [ $(date +%s) -lt $DEADLINE ]; do
  sleep 5
  SUMMARY=$(curl -sk -u "${POWERSC_USER}:${POWERSC_PASS}" \
    "${API_BASE}/quantumsafe/summary?endpoint=${AIX_HOST}")
  SCANTIME=$(echo "$SUMMARY" | grep -o '"scanTime":[0-9]*' | grep -o '[0-9]*')
  WEAK=$(echo "$SUMMARY" | grep -o '"weakCertificates":[0-9]*' | grep -o '[0-9]*')
  printf "  scanTime=%-14s  weakCertificates=%s\n" "$SCANTIME" "$WEAK"
  if [ -n "$SCANTIME" ] && [ "$SCANTIME" -gt 0 ]; then
    echo ""
    echo "Scan complete. Summary:"
    echo "$SUMMARY"
    break
  fi
done
