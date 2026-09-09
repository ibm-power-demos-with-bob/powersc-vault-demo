#!/bin/bash
################################################################################
# PowerSC Endpoint Bootstrap Script
#
# Purpose: Registers an AIX endpoint with the PowerSC server by:
#   1. Generating an endpoint keystore on the PowerSC server (pvm01)
#   2. Copying the keystore to the endpoint (pvm03)
#   3. Restarting the uiAgent on the endpoint to trigger registration
#   4. Setting the quantum safe scan folder on the endpoint
#   5. Verifying registration via the PowerSC API
#
# Usage: Run on pvm02 (the RHEL/demo host) with:
#   SSH_KEY=~/.ssh/id_rsa_techzone bash bootstrap-powersc-endpoint.sh
#
# Environment variables (all required):
#   POWERSC_SERVER  - PowerSC server hostname (pvm01)
#   AIX_ENDPOINT    - AIX endpoint hostname (pvm03)
#   POWERSC_URL     - PowerSC HTTPS base URL
#   POWERSC_USER    - PowerSC API user
#   POWERSC_PASS    - PowerSC API password
#   SSH_KEY         - Path to SSH private key
#   SCAN_FOLDER     - Certificate folder to scan on the endpoint
################################################################################

set -e

POWERSC_SERVER="${POWERSC_SERVER:-pvm01-731cq22k.p642.pok-systems.techzone.ibm.com}"
AIX_ENDPOINT="${AIX_ENDPOINT:-pvm03-731cq22k.p642.pok-systems.techzone.ibm.com}"
POWERSC_URL="${POWERSC_URL:-https://pvm01-731cq22k.p642.pok-systems.techzone.ibm.com}"
POWERSC_USER="${POWERSC_USER:-powersc}"
POWERSC_PASS="${POWERSC_PASS:-}"  # supply via env var — never hardcode
SSH_KEY="${SSH_KEY:-/home/U5V9KZP/.ssh/id_rsa_techzone}"
SCAN_FOLDER="${SCAN_FOLDER:-/home/U5V9KZP/demo-certs}"
SSH_USER="${SSH_USER:-U5V9KZP}"

SSH_OPTS="-i $SSH_KEY -o StrictHostKeyChecking=no -o ConnectTimeout=15"
SSH_PVM01="ssh $SSH_OPTS $SSH_USER@$POWERSC_SERVER"
SSH_PVM03="ssh $SSH_OPTS -t $SSH_USER@$AIX_ENDPOINT"

KEYSTORE_PATH="/etc/security/powersc/uiServer/${AIX_ENDPOINT}/endpointKeystore.p12"
AGENT_KEYSTORE="/etc/security/powersc/uiAgent/endpointKeystore.p12"
GENERATE_SCRIPT="/opt/powersc/uiServer/bin/generate_endpoint_keystore_uiServer.sh"
API_BASE="$POWERSC_URL/ws/powerscui"

echo "========================================"
echo "PowerSC Endpoint Bootstrap"
echo "  Server:   $POWERSC_SERVER"
echo "  Endpoint: $AIX_ENDPOINT"
echo "  Scan dir: $SCAN_FOLDER"
echo "========================================"
echo ""

# ── Step 1: Generate endpoint keystore on pvm01 ──────────────────────────────
echo "Step 1: Generating endpoint keystore on $POWERSC_SERVER..."
$SSH_PVM01 "sudo -n $GENERATE_SCRIPT $AIX_ENDPOINT"
echo "  ✓ Keystore generated at $KEYSTORE_PATH on $POWERSC_SERVER"
echo ""

# ── Step 2: Copy keystore from pvm01 to pvm03 ────────────────────────────────
echo "Step 2: Copying keystore from $POWERSC_SERVER to $AIX_ENDPOINT..."

# Pull the keystore to a temp location on this host (pvm02)
TMP_KEYSTORE="/tmp/endpointKeystore-$(date +%s).p12"
scp $SSH_OPTS "$SSH_USER@$POWERSC_SERVER:$KEYSTORE_PATH" "$TMP_KEYSTORE"

# Push it to pvm03
TMP_REMOTE="/tmp/endpointKeystore.p12"
scp $SSH_OPTS "$TMP_KEYSTORE" "$SSH_USER@$AIX_ENDPOINT:$TMP_REMOTE"
rm -f "$TMP_KEYSTORE"

# Move into place as root on pvm03
$SSH_PVM03 "sudo -n mkdir -p /etc/security/powersc/uiAgent && sudo -n cp $TMP_REMOTE $AGENT_KEYSTORE && sudo -n chmod 600 $AGENT_KEYSTORE && sudo -n chown root:security $AGENT_KEYSTORE && rm -f $TMP_REMOTE"
echo "  ✓ Keystore installed at $AGENT_KEYSTORE on $AIX_ENDPOINT"
echo ""

# ── Step 3: Restart uiAgent on pvm03 to trigger registration ─────────────────
echo "Step 3: Restarting PowerSC uiAgent on $AIX_ENDPOINT..."
$SSH_PVM03 "sudo -n /opt/powersc/uiAgent/bin/pscuiagentctl stop 2>/dev/null || true; sleep 2; sudo -n /opt/powersc/uiAgent/bin/pscuiagentctl start"
echo "  ✓ uiAgent restarted — waiting 15s for registration..."
sleep 15
echo ""

# ── Step 4: Verify registration ──────────────────────────────────────────────
echo "Step 4: Verifying registration with PowerSC API..."
SYSTEMS=$(curl -sk -u "$POWERSC_USER:$POWERSC_PASS" "$API_BASE/systems")
echo "  Registered systems: $SYSTEMS"

if echo "$SYSTEMS" | grep -q "$AIX_ENDPOINT"; then
  echo "  ✓ $AIX_ENDPOINT is registered"
else
  echo "  ✗ $AIX_ENDPOINT not yet visible — may need more time, check agent logs"
  echo "    Agent log on pvm03: sudo -n cat /var/log/powersc/uiAgent.log"
fi
echo ""

# ── Step 5: Set scan folder via API ──────────────────────────────────────────
echo "Step 5: Setting scan folder to $SCAN_FOLDER via PowerSC API..."
SCAN_RESULT=$(curl -sk -u "$POWERSC_USER:$POWERSC_PASS" \
  -X POST -H "Content-Type: application/json" \
  -d "{\"orders\":[{\"commandName\":\"setQuantumSafeScanFolders\",\"elementId\":\"$AIX_ENDPOINT\",\"scanFolders\":\"$SCAN_FOLDER\"}]}" \
  "$API_BASE/command")
echo "  API response: $SCAN_RESULT"

if echo "$SCAN_RESULT" | grep -q "SUCCESS\|success\|OK"; then
  echo "  ✓ Scan folder set"
else
  echo "  Note: Check API response above — may need to verify command name"
fi
echo ""

echo "========================================"
echo "Bootstrap complete."
echo "  Next: trigger a scan from the UI or via:"
echo "  curl -sk -u '$POWERSC_USER:$POWERSC_PASS' -X POST \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"orders\":[{\"commandName\":\"runQuantumSafeScan\",\"elementId\":\"$AIX_ENDPOINT\"}]}' \\"
echo "    '$API_BASE/command'"
echo "========================================"
