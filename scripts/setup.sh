#!/bin/bash
################################################################################
# PowerSC + HashiCorp Vault Demo — One-Command Setup
#
# Run this script on pvm2 (RHEL on Power) to go from a fresh TechZone
# PowerSC reservation to a running demo in one command.
#
# Usage (from pvm2, after cloning the repo):
#
#   bash scripts/setup.sh \
#     --vault-host  <pvm2-fqdn>     \
#     --aix-host    <pvm3-fqdn>     \
#     --powersc-url https://<pvm1-fqdn> \
#     --ssh-key     /home/cecuser/.ssh/techzone-key.pem
#
# Or set environment variables and run without flags:
#
#   export VAULT_HOST=p1294-pvm2.p1294.cecc.ihost.com
#   export AIX_HOST=p1294-pvm3.p1294.cecc.ihost.com
#   export POWERSC_URL=https://p1294-pvm1.p1294.cecc.ihost.com
#   export SSH_KEY=/home/cecuser/.ssh/techzone-key.pem
#   bash scripts/setup.sh
#
# What this script does (infrastructure only):
#   1. Install Podman
#   2. Apply fapolicyd trust remediation for OCI runtimes
#   3. Pull and start Vault container (Power-native image)
#   4. Set up Vault systemd user service (survives reboot)
#   5. Configure Vault PKI (root CA + sap-oracle role)
#   6. Open firewall ports (8200, 3001, 3002)
#   7. Install Node.js via dnf
#   8. Clone/update this repo
#   9. npm install --ignore-scripts
#  10. npm run build (Next.js)
#  11. Write ui/.env.local from the provided flags/env vars
#  12. Start Express backend (port 3002) and Next.js frontend (port 3001)
#
# What this script does NOT do:
#   - Generate demo certificates on AIX (use the UI: "Generate Demo Environment")
#   - Trigger PowerSC scans (use the UI scan buttons, or PowerSC UI directly)
#   - Replace certificates with Vault (use the UI: "Deploy Vault Certificates")
#   - Set up PowerSC keystore / endpoints (manual UI step, see COLLECTION.md Step 4)
#
# After this script completes:
#   Open http://<pvm2-fqdn>:3001 in your browser.
#
# Author: EMEA AI on IBM Power Squad
################################################################################

set -euo pipefail

# ── Colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "${GREEN}  ✓ $*${NC}"; }
info() { echo -e "${BLUE}  → $*${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $*${NC}"; }
fail() { echo -e "${RED}  ✗ $*${NC}"; exit 1; }
step() { echo -e "\n${BOLD}${BLUE}── $* ──${NC}"; }

# ── Argument parsing ──────────────────────────────────────────────────────────
# Accept --flag value or fall back to environment variables
while [[ $# -gt 0 ]]; do
  case $1 in
    --vault-host)  VAULT_HOST="$2";   shift 2 ;;
    --aix-host)    AIX_HOST="$2";     shift 2 ;;
    --powersc-url) POWERSC_URL="$2";  shift 2 ;;
    --ssh-key)     SSH_KEY="$2";      shift 2 ;;
    --repo-url)    REPO_URL="$2";     shift 2 ;;
    *) warn "Unknown flag: $1 (ignored)"; shift ;;
  esac
done

VAULT_HOST="${VAULT_HOST:-}"
AIX_HOST="${AIX_HOST:-}"
POWERSC_URL="${POWERSC_URL:-}"
SSH_KEY="${SSH_KEY:-/home/cecuser/.ssh/techzone-key.pem}"
REPO_URL="${REPO_URL:-https://github.com/ibm-power-demos-with-bob/powersc-vault-demo.git}"
DEMO_DIR="${DEMO_DIR:-/home/cecuser/powersc-vault-demo}"

# ── Preflight checks ──────────────────────────────────────────────────────────
echo -e "\n${BOLD}PowerSC + Vault Demo — Setup${NC}"
echo "────────────────────────────────────────────────────────────"

[[ -z "$VAULT_HOST" ]]   && fail "VAULT_HOST is required. Pass --vault-host <fqdn> or set the env var."
[[ -z "$AIX_HOST" ]]     && fail "AIX_HOST is required. Pass --aix-host <fqdn> or set the env var."
[[ -z "$POWERSC_URL" ]]  && warn "POWERSC_URL not set — PowerSC link in UI will be disabled."
[[ ! -f "$SSH_KEY" ]]    && fail "SSH key not found at $SSH_KEY. Pass --ssh-key <path>."

# Derive AIX short hostname (first component of FQDN) for PowerSC endpoint reference
AIX_HOSTNAME="${AIX_HOST%%.*}"

info "Vault host (pvm2):  $VAULT_HOST"
info "AIX host (pvm3):    $AIX_HOST"
info "AIX hostname:       $AIX_HOSTNAME"
info "PowerSC URL (pvm1): ${POWERSC_URL:-not set}"
info "SSH key:            $SSH_KEY"
info "Repo:               $REPO_URL"
info "Demo directory:     $DEMO_DIR"

# ── Step 1: Install Podman ────────────────────────────────────────────────────
step "Step 1: Install Podman"

if command -v podman &>/dev/null; then
  ok "Podman already installed: $(podman --version)"
else
  info "Installing Podman via dnf…"
  sudo dnf install -y podman
  ok "Podman installed: $(podman --version)"
fi

# ── Step 2: fapolicyd trust remediation ──────────────────────────────────────
step "Step 2: fapolicyd trust remediation"

# This is idempotent — running it on an environment where fapolicyd is not
# blocking anything does no harm. It is always safe to run.
if sudo systemctl is-active fapolicyd &>/dev/null; then
  info "fapolicyd is active — adding OCI runtime trust entries…"

  for bin in /usr/bin/runc /usr/bin/crun /bin/conmon; do
    if [[ -f "$bin" ]] && ! sudo grep -qF "$bin" /etc/fapolicyd/fapolicyd.trust 2>/dev/null; then
      echo "$bin" | sudo tee -a /etc/fapolicyd/fapolicyd.trust >/dev/null
      info "Added $bin to fapolicyd trust"
    fi
  done

  for lib in /lib64/libresolv.so.2 /lib64/libsystemd.so.0; do
    if [[ -f "$lib" ]] && ! sudo grep -qF "$lib" /etc/fapolicyd/fapolicyd.trust 2>/dev/null; then
      echo "$lib" | sudo tee -a /etc/fapolicyd/fapolicyd.trust >/dev/null
    fi
  done

  # Add a permissive home-directory rule so Node.js can build in ~/
  RULES_DIR="/etc/fapolicyd/rules.d"
  HOME_RULE="$RULES_DIR/69-home-allow.rules"
  if [[ ! -f "$HOME_RULE" ]]; then
    info "Adding home-directory allow rule for Node.js build…"
    echo 'allow perm=any all : dir=/home/' | sudo tee "$HOME_RULE" >/dev/null
  fi

  sudo fapolicyd-cli --update >/dev/null 2>&1 || true
  sudo systemctl restart fapolicyd
  ok "fapolicyd trust updated and restarted"
else
  ok "fapolicyd is not active — no trust remediation needed"
fi

# Smoke-test Podman
info "Verifying Podman can run a container…"
if podman run --rm registry.access.redhat.com/ubi9/ubi-minimal echo "podman-ok" 2>&1 | grep -q "podman-ok"; then
  ok "Podman container test passed"
else
  warn "Podman container test did not return expected output — check fapolicyd logs if containers fail later"
fi

# ── Step 3: Start Vault container ────────────────────────────────────────────
step "Step 3: Start Vault container"

VAULT_IMAGE="icr.io/ppc64le-oss/vault-ppc64le:v1.14.8"

# Stop and remove any existing Vault container (safe on re-run)
podman stop vault 2>/dev/null && info "Stopped existing vault container" || true
podman rm   vault 2>/dev/null && info "Removed existing vault container" || true

info "Starting Vault (Power-native container, rootless Podman)…"
podman run -d \
  --name vault \
  -p 8200:8200 \
  --cap-add=IPC_LOCK \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  "$VAULT_IMAGE"

sleep 5

# Health check
if curl -sf http://127.0.0.1:8200/v1/sys/health | grep -q '"initialized":true'; then
  ok "Vault is running and healthy"
else
  fail "Vault health check failed. Check: podman logs vault"
fi

# ── Step 4: Vault systemd user service (persist across SSH sessions/reboots) ──
step "Step 4: Vault systemd user service"

mkdir -p ~/.config/systemd/user

podman generate systemd --new --name vault > ~/.config/systemd/user/vault.service
systemctl --user daemon-reload
systemctl --user enable vault.service
loginctl enable-linger cecuser 2>/dev/null || true

ok "Vault systemd user service enabled — will survive reboot"

# ── Step 5: Configure Vault PKI ───────────────────────────────────────────────
step "Step 5: Configure Vault PKI"

V="podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot vault vault"

info "Enabling PKI secrets engine…"
$V secrets list | grep -q "^pki/" \
  || $V secrets enable pki

$V secrets tune -max-lease-ttl=8760h pki

info "Generating root CA…"
$V read pki/cert/ca >/dev/null 2>&1 \
  || $V write pki/root/generate/internal \
       common_name="Demo Internal Root CA" \
       issuer_name="demo-root-ca" \
       ttl=8760h \
       organization="Demo Organisation" \
       ou="IT Security" \
       country="GB"

info "Configuring CA/CRL URLs…"
$V write pki/config/urls \
  issuing_certificates="http://${VAULT_HOST}:8200/v1/pki/ca" \
  crl_distribution_points="http://${VAULT_HOST}:8200/v1/pki/crl"

info "Creating sap-oracle PKI role (24h TTL)…"
$V write pki/roles/sap-oracle \
  allowed_domains="howdens.local,sap.howdens.local,oracle.howdens.local,mq.howdens.local,api.howdens.local,esb.howdens.local,b2b.howdens.local,lb.howdens.local,proxy.howdens.local" \
  allow_subdomains=true \
  allow_bare_domains=true \
  allow_localhost=false \
  allow_ip_sans=false \
  max_ttl=24h \
  ttl=24h \
  key_type=rsa \
  key_bits=2048

info "Issuing test certificate…"
if $V write pki/issue/sap-oracle common_name="test.howdens.local" ttl=24h \
    | grep -q "serial_number"; then
  ok "PKI configured — test certificate issued successfully"
else
  fail "PKI test certificate issue failed. Check Vault logs: podman logs vault"
fi

# ── Step 6: Open firewall ports ───────────────────────────────────────────────
step "Step 6: Open firewall ports"

for port in 8200 3001 3002; do
  if sudo firewall-cmd --query-port="${port}/tcp" --permanent &>/dev/null; then
    info "Port $port already open"
  else
    sudo firewall-cmd --permanent --add-port="${port}/tcp"
    info "Opened port $port"
  fi
done
sudo firewall-cmd --reload
ok "Firewall ports open: 8200 (Vault), 3001 (UI), 3002 (API)"

# ── Step 7: Install Node.js ───────────────────────────────────────────────────
step "Step 7: Install Node.js"

# Use dnf — NOT NodeSource, which does not support ppc64le
if command -v node &>/dev/null; then
  ok "Node.js already installed: $(node --version)"
else
  info "Installing nodejs via dnf (RHEL AppStream — ppc64le compatible)…"
  sudo dnf install -y nodejs npm
  ok "Node.js installed: $(node --version)"
fi

# ── Step 8: Clone or update the demo repo ────────────────────────────────────
step "Step 8: Clone / update demo repo"

if [[ -d "$DEMO_DIR/.git" ]]; then
  info "Repo already cloned — pulling latest…"
  cd "$DEMO_DIR"
  git pull
  ok "Repo up to date"
else
  info "Cloning repo… (--template=\"\" bypasses hooks permission error on hardened RHEL)"
  sudo dnf install -y git 2>/dev/null || true
  git clone --template="" "$REPO_URL" "$DEMO_DIR"
  ok "Repo cloned to $DEMO_DIR"
fi

cd "$DEMO_DIR/ui"

# ── Step 9: npm install ───────────────────────────────────────────────────────
step "Step 9: npm install"

info "Installing npm dependencies… (--ignore-scripts: fapolicyd blocks IBM Plex telemetry postinstall)"
npm install --ignore-scripts
ok "npm install complete"

# ── Step 10: Next.js build ────────────────────────────────────────────────────
step "Step 10: Next.js build"

info "Building Next.js app…"
npm run build
ok "Next.js build complete"

# ── Step 11: Write .env.local ─────────────────────────────────────────────────
step "Step 11: Write ui/.env.local"

ENV_FILE="$DEMO_DIR/ui/.env.local"

# Only write if not already present (idempotent re-runs preserve manual edits)
if [[ -f "$ENV_FILE" ]]; then
  warn ".env.local already exists — not overwriting. Delete it and re-run to regenerate."
else
  cat > "$ENV_FILE" << EOF
# Generated by setup.sh — edit as needed.
# See ui/.env.local.example for all available options.

AIX_HOST=${AIX_HOST}
AIX_USER=cecuser
AIX_SSH_KEY_PATH=${SSH_KEY}

VAULT_ADDR=http://127.0.0.1:8200
VAULT_ADDR_EXTERNAL=http://${VAULT_HOST}:8200
VAULT_TOKEN=myroot

POWERSC_URL=${POWERSC_URL}
NEXT_PUBLIC_POWERSC_URL=${POWERSC_URL}
POWERSC_USER=powersc-admin
POWERSC_PASS=
AIX_HOSTNAME=${AIX_HOSTNAME}

API_PORT=3002
EOF
  ok ".env.local written"
  warn "POWERSC_PASS is blank — fill it in from TechZone reservation details to enable API scan buttons."
  warn "Edit: $ENV_FILE"
fi

# ── Step 12: Copy SSH key to expected path ────────────────────────────────────
step "Step 12: Ensure SSH key is in place"

EXPECTED_KEY="/home/cecuser/.ssh/techzone-key.pem"
if [[ "$SSH_KEY" != "$EXPECTED_KEY" && ! -f "$EXPECTED_KEY" ]]; then
  cp "$SSH_KEY" "$EXPECTED_KEY"
  chmod 600 "$EXPECTED_KEY"
  ok "Copied SSH key to $EXPECTED_KEY"
else
  ok "SSH key already at $EXPECTED_KEY"
fi

# ── Step 13: Start services ───────────────────────────────────────────────────
step "Step 13: Start demo services"

cd "$DEMO_DIR/ui"

# Kill any existing instances
pkill -f 'node server/index' 2>/dev/null && info "Stopped existing backend" || true
pkill -f 'next start'        2>/dev/null && info "Stopped existing frontend" || true
sleep 2

info "Starting Express backend (port 3002)…"
nohup npm run server > ~/server.log 2>&1 &
BACKEND_PID=$!

sleep 2

info "Starting Next.js frontend (port 3001)…"
nohup npm start > ~/ui.log 2>&1 &
FRONTEND_PID=$!

sleep 4

# Verify both are responding
if curl -sf http://localhost:3002/health | grep -q '"status":"ok"'; then
  ok "Backend healthy (port 3002) — PID $BACKEND_PID"
else
  warn "Backend health check failed — check ~/server.log"
fi

if curl -sf http://localhost:3001 | head -c 50 | grep -q '.'; then
  ok "Frontend responding (port 3001) — PID $FRONTEND_PID"
else
  warn "Frontend not yet responding — it may still be starting. Check ~/ui.log in 10 seconds."
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}────────────────────────────────────────────────────────────${NC}"
echo -e "${BOLD}${GREEN}  Setup complete${NC}"
echo -e "${BOLD}${GREEN}────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "  ${BOLD}Demo UI:${NC}       http://${VAULT_HOST}:3001"
echo -e "  ${BOLD}Backend API:${NC}   http://${VAULT_HOST}:3002/health"
echo -e "  ${BOLD}Vault UI:${NC}      http://${VAULT_HOST}:8200"
echo -e "  ${BOLD}PowerSC UI:${NC}    ${POWERSC_URL:-not configured}"
echo ""
echo -e "  ${BOLD}Next steps:${NC}"
echo "  1. Open the demo UI in your browser (link above)"
echo "  2. Complete PowerSC UI setup if not already done:"
echo "     — Generate keystore for AIX client (pvm3)"
echo "     — Configure quantum safe scan paths: sap, oracle, integration, loadbalancer, proxy"
echo "     (See COLLECTION.md Step 4 for the exact clicks)"
echo "  3. Fill in POWERSC_PASS in ui/.env.local then restart the backend"
echo "     to enable API-driven scan buttons (optional — manual scan always works)"
echo "  4. In the demo UI: click 'Generate Demo Environment' to deploy old certificates"
echo ""
echo -e "  ${YELLOW}Logs:${NC} ~/server.log  ~/ui.log"
echo ""

# Made with Bob
