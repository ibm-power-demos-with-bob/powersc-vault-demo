---
name: deploy-powersc-vault-power
description: >
  Deploy and operate the PowerSC + HashiCorp Vault certificate management demo on IBM Power.
  Covers TechZone environment topology, Vault deployment via rootless Podman (Power-native
  container), fapolicyd trust remediation, Vault PKI configuration, AIX certificate
  deployment scripts, PowerSC UI manual steps, demo execution, and demo reset procedure.
---

# Skill: Deploy PowerSC + HashiCorp Vault on IBM Power

## When to Use This Skill

Activate this skill when the seller has:
1. Completed the story phase (their customer context is defined)
2. A TechZone PowerSC reservation in **Ready** status
3. The FQDNs for the reservation VMs
4. The private SSH key downloaded from the TechZone reservation page

## TechZone Environment Topology

One PowerSC reservation provides all required nodes. FQDNs follow the pattern
`p<NNNN>-pvm<N>.p<NNNN>.cecc.ihost.com`. Ask the seller for each FQDN and set
variables at the start:

```bash
# Set these from the seller's reservation details
POWERSC_HOST="p<NNNN>-pvm1.p<NNNN>.cecc.ihost.com"   # PowerSC server
VAULT_HOST="p<NNNN>-pvm2.p<NNNN>.cecc.ihost.com"      # RHEL — Vault host
AIX_HOST="p<NNNN>-pvm3.p<NNNN>.cecc.ihost.com"        # AIX — certificate target
SSH_KEY="<path to downloaded .pem file>"
SSH_USER="cecuser"
```

Node roles:
- **pvm1** — PowerSC server. UI accessible at `https://<POWERSC_HOST>`. Do not modify.
- **pvm2** — RHEL on IBM Power. This is where Vault is deployed. Bob drives this via SSH.
- **pvm3** — AIX client. This is where the 150 synthetic certificates live. Bob drives via SSH from pvm2 or directly.
- **pvm4** — IBM i. Unused in this demo.

## Step 1: Confirm SSH Connectivity

```bash
# Confirm RHEL host
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" "uname -m"
# Expected: ppc64le

# Confirm AIX host
ssh -i "$SSH_KEY" "$SSH_USER@$AIX_HOST" "uname"
# Expected: AIX
```

If SSH complains about a known-hosts conflict (host key mismatch), the FQDN may have
been reused from a previous reservation. Clear the stale entry:
```bash
ssh-keygen -R "$VAULT_HOST"
ssh-keygen -R "$AIX_HOST"
```

## Step 2: fapolicyd Trust Remediation on RHEL Host

The RHEL host in the PowerSC reservation is pre-hardened with `fapolicyd` active.
This enforces an allow-list for executables and shared libraries. OCI container runtimes
(`crun`, `runc`, `conmon`) are NOT in the default trust list and will fail with
`Operation not permitted` or silent `runc create failed` errors.

**This step must be completed before any Podman container can run.**

```bash
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" << 'ENDSSH'
# Check fapolicyd status
sudo systemctl status fapolicyd --no-pager

# Add OCI runtime binaries and required shared libraries to trust
echo '/usr/bin/runc'           | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/usr/bin/crun'           | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/bin/conmon'             | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/lib64/libresolv.so.2'   | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/lib64/libsystemd.so.0'  | sudo tee -a /etc/fapolicyd/fapolicyd.trust

# Reload fapolicyd trust database
sudo fapolicyd-cli --update
sudo systemctl restart fapolicyd

# Verify Podman can now run a minimal container
podman run --rm registry.access.redhat.com/ubi9/ubi-minimal echo "fapolicyd test passed"
ENDSSH
```

Expected final output: `fapolicyd test passed`

If additional libraries are blocked, the error will mention specific `.so` paths. Add
each one to `/etc/fapolicyd/fapolicyd.trust`, run `sudo fapolicyd-cli --update` and
`sudo systemctl restart fapolicyd`, then retry.

## Step 3: Start Vault Container

Vault runs as a **Power-native container** using rootless Podman as `cecuser`. The image
`icr.io/ppc64le-oss/vault-ppc64le:v1.14.8` is maintained by IBM for ppc64le.

There is no current native ppc64le Vault binary on HashiCorp's release pages. The
container is the correct deployment path for this demo.

```bash
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" << 'ENDSSH'
# Stop and remove any existing Vault containers (safe on re-run)
podman stop vault 2>/dev/null || true
podman rm   vault 2>/dev/null || true

# Start Vault in dev mode with explicit root token
# Run as cecuser (NOT sudo) — rootless Podman
podman run -d \
  --name vault \
  -p 8200:8200 \
  --cap-add=IPC_LOCK \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  icr.io/ppc64le-oss/vault-ppc64le:v1.14.8

sleep 5

# Verify container is running
podman ps | grep vault

# Health check
curl -s http://127.0.0.1:8200/v1/sys/health | grep '"initialized":true'
ENDSSH
```

Expected: container listed in `podman ps`, health response contains `"initialized":true`.

### Narrative for client audience
Say: "Vault is running on IBM Power in a Power-native container deployment model."
Do not say: "We had to use a container because the binary was missing."

## Step 4: Configure Vault PKI via podman exec

All Vault CLI commands run inside the container using `podman exec`. The token is `myroot`
(set when the container started). These commands run on pvm2 (RHEL host).

```bash
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" << ENDSSH
V="podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot vault vault"

# Enable PKI secrets engine (idempotent)
\$V secrets list | grep -q "^pki/" || \$V secrets enable pki

# Configure max lease TTL (1 year)
\$V secrets tune -max-lease-ttl=8760h pki

# Generate root CA (idempotent — only generates if not already present)
\$V read pki/cert/ca >/dev/null 2>&1 || \$V write pki/root/generate/internal \
  common_name="Demo Internal Root CA" \
  issuer_name="demo-root-ca" \
  ttl=8760h \
  organization="Demo Organisation" \
  ou="IT Security" \
  country="GB"

# Configure CA and CRL URLs using the Vault host FQDN
\$V write pki/config/urls \
  issuing_certificates="http://${VAULT_HOST}:8200/v1/pki/ca" \
  crl_distribution_points="http://${VAULT_HOST}:8200/v1/pki/crl"

# Create PKI role for SAP/Oracle workloads
\$V write pki/roles/sap-oracle \
  allowed_domains="howdens.local,sap.howdens.local,oracle.howdens.local,mq.howdens.local,api.howdens.local,esb.howdens.local,b2b.howdens.local,lb.howdens.local,proxy.howdens.local" \
  allow_subdomains=true \
  allow_bare_domains=true \
  allow_localhost=false \
  allow_ip_sans=false \
  max_ttl=24h \
  ttl=24h \
  key_type=rsa \
  key_bits=2048

# Test certificate issuance
\$V write pki/issue/sap-oracle \
  common_name="test.howdens.local" \
  ttl=24h | grep serial_number
ENDSSH
```

Expected: `serial_number` line printed — confirming PKI is configured and issuing certificates.

> **Note on customer story:** The PKI role uses `howdens.local` domains. These domain names
> appear in the certificates but are internal — they do not affect the demo story for other
> customers. They can be changed if the seller wants to use their customer's domain names,
> but it is not required for the demo to work.

## Step 5: PowerSC UI Manual Steps (human gate)

These steps **must be completed by the seller in the PowerSC browser UI**. They cannot be
automated via SSH. Estimated time: 10 minutes.

### 5.1 Access PowerSC UI
1. Open browser, navigate to `https://<POWERSC_HOST>`
2. Accept the self-signed certificate warning
3. Login with `powersc-admin` credentials (from the TechZone reservation details page)
   - The path `/webclient/#/` is added automatically

### 5.2 Generate Keystores for AIX Client (CRITICAL)
The AIX client will NOT appear in the Endpoints list until keystores are generated.

1. Click **Endpoint Admin** in the top navigation bar
2. Click the **Keystore Requests** tab
3. Select the AIX client (pvm3 hostname, ending in `.195` or similar — check your reservation)
4. Click **Generate Keystore**
5. Wait for status to change to **"yes"** (takes 1–2 minutes)
6. Click the **Endpoints** tab
7. Wait 2–5 minutes for the AIX client to appear in the table
8. Confirm it shows as Active/Connected with OS = AIX

### 5.3 Configure Quantum Safe Scan Paths (CRITICAL)
1. In the Endpoints list, click the AIX client row or find its **Actions** menu
2. Select **"Quantum safe scan configuration"**
3. In the directory tree, **check the `/opt` checkbox**
   - This enables scanning of all current and future `/opt` subdirectories
   - Includes: `/opt/sap`, `/opt/oracle`, `/opt/integration`, `/opt/loadbalancer`, `/opt/proxy`
4. Click **Save**

### 5.4 Run Initial Scan
1. Navigate to **Security** in the top navigation
2. Find pvm3 in the systems list
3. Click the **three-dot menu (⋮)** in the Actions column
4. Select **Quantum Safety → Run quantum safety full scan**
5. Wait for scan completion (~1–2 minutes)

## Step 6: Deploy Old Certificates to AIX

Transfer and run the `generate-old-certificates.sh` script on the AIX host. This script:
- Removes any existing `/opt/sap`, `/opt/oracle`, `/opt/integration`, `/opt/loadbalancer`, `/opt/proxy` directories (clean reset)
- Extracts real CA bundle certificates from the AIX system bundle (2008–2011 vintage)
- Distributes 150 certificates across all paths

```bash
# Transfer script from local machine to AIX via RHEL relay (or direct if accessible)
scp -i "$SSH_KEY" scripts/generate-old-certificates.sh "$SSH_USER@$AIX_HOST:/home/$SSH_USER/"

# Run script on AIX as root
ssh -i "$SSH_KEY" "$SSH_USER@$AIX_HOST" "sudo /home/$SSH_USER/generate-old-certificates.sh"
```

### CA bundle path on AIX
The script looks for the CA bundle at:
```
/opt/freeware/etc/ssl/certs/extracted/pem/tls-ca-bundle.pem
```
This is the IBM AIX Toolbox OpenSSL CA bundle location. If not present, check:
- `/etc/security/cacerts/`
- `openssl version -d` to find the OpenSSL directory

If the CA bundle is not available, the script will exit with an error. On a fresh TechZone AIX instance,
the IBM AIX Toolbox may need to be installed, or the path may differ slightly. Check and adjust the
`CA_BUNDLE` variable in `generate-old-certificates.sh` if needed.

Expected output:
```
✓ Extracted N certificates from bundle
Total certificates deployed: 150
```

## Step 7: Trigger PowerSC BEFORE Scan

1. In the PowerSC UI, trigger another Quantum Safety scan on the AIX client (pvm3)
2. Wait for completion (~1–2 minutes)
3. Navigate to **Quantum Inventory Report** (Reports → Quantum Inventory, or similar)
4. Capture the BEFORE state:
   - Certificate ages: 15+ years old (2008–2011)
   - Compliance score: ~67% (weak/old crypto)
   - Quantum-safe status: Not Ready

**This is the "before" screenshot moment. Capture it before proceeding.**

## Step 8: Replace Certificates with Vault-Issued Ones

The replacement script runs on the AIX host and calls Vault's REST API over the network
from AIX to the RHEL host. It uses `curl` + `sed` (AIX-compatible, no jq, no Vault CLI).

```bash
# Transfer script to AIX
scp -i "$SSH_KEY" scripts/replace-with-vault-certificates.sh "$SSH_USER@$AIX_HOST:/home/$SSH_USER/"

# Run script on AIX — Vault address is the RHEL host's FQDN (port 8200)
ssh -i "$SSH_KEY" "$SSH_USER@$AIX_HOST" \
  "export VAULT_ADDR=\"http://$VAULT_HOST:8200\" && \
   export VAULT_TOKEN=\"myroot\" && \
   sudo -E /home/$SSH_USER/replace-with-vault-certificates.sh"
```

Expected output: 150 `✓ Replaced:` lines, then summary showing 150 total.

If some certificates fail with `"errors": ["permission denied"]`:
1. Verify Vault is still running: `podman ps` on pvm2
2. Verify token: `curl -s http://$VAULT_HOST:8200/v1/sys/health` from AIX
3. Re-run `vault-pki-setup.sh` equivalent on pvm2 (see Step 4)

## Step 9: Trigger PowerSC AFTER Scan

1. Trigger another Quantum Safety scan on the AIX client in PowerSC UI
2. Wait for completion
3. Refresh the Quantum Inventory Report
4. Confirm AFTER state:
   - Certificate ages: <24 hours (just issued)
   - Compliance score: ~98%
   - Quantum-safe status: Ready

**This is the "after" screenshot moment and the climax of the demo.**

## Demo Reset Procedure

The before/after cycle is the entire demo. To reset and run it again (or to prepare for
a fresh demo presentation):

```bash
# Step 1: Re-generate old certificates on AIX (the script cleans up first)
ssh -i "$SSH_KEY" "$SSH_USER@$AIX_HOST" "sudo /home/$SSH_USER/generate-old-certificates.sh"

# Step 2: Trigger PowerSC scan to confirm BEFORE state is restored
# (via PowerSC UI — Quantum Safety scan on pvm3)

# Step 3: Demo is ready to run again
```

Vault does not need to be restarted — it retains its PKI configuration across resets.

## Vault Container Management

```bash
# Check Vault is running
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" "podman ps | grep vault"

# View Vault logs
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" "podman logs vault"

# Restart Vault (token resets to myroot after restart)
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" "podman restart vault && sleep 5 && curl -s http://127.0.0.1:8200/v1/sys/health"

# If Vault container is gone (e.g. after RHEL reboot), re-run Step 3 and Step 4
```

**Important:** Vault runs in dev mode. A container restart resets all PKI configuration.
If the container restarts, re-run Step 4 (PKI configuration) before attempting certificate issuance.

For persistent Vault across reboots, use:
```bash
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" << 'ENDSSH'
podman generate systemd --new --name vault > ~/.config/systemd/user/vault.service
systemctl --user enable vault.service
systemctl --user start vault.service
loginctl enable-linger cecuser
ENDSSH
```

## Key Messages During Demo

| Moment | What to say |
|--------|-------------|
| BEFORE state revealed | "These certificates are 15 years old. Manual tracking via spreadsheets. The same infrastructure profile that exposed JLR to a £1.9 billion loss." |
| Vault PKI shown | "Vault becomes the certificate authority. Short-lived certificates — 24 hours. Automatically rotated. Zero spreadsheets." |
| Replacement running | "Watch Vault issue 150 certificates in seconds. Each one valid for 24 hours. In production, this rotation would be continuous." |
| AFTER state revealed | "Certificate age: 24 hours. Compliance: 98%. Quantum-safe ready. Zero manual intervention. This is the power of PowerSC visibility combined with Vault automation." |

## Common Failure Modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Operation not permitted` on `podman run` | fapolicyd blocking OCI runtime | Re-run Step 2 fapolicyd remediation |
| `Error: no image with name vault found` | Image pull failed (network) | `podman pull icr.io/ppc64le-oss/vault-ppc64le:v1.14.8` manually |
| `"errors": ["permission denied"]` from Vault | PKI role not configured | Re-run Step 4 PKI setup |
| `ERROR: Cannot connect to Vault` on AIX | Firewall blocking port 8200 | `sudo firewall-cmd --permanent --add-port=8200/tcp && sudo firewall-cmd --reload` on pvm2 |
| AIX client not appearing in PowerSC | Keystore not generated | Repeat Step 5.2 |
| PowerSC scan shows 0 certificates | Scan path not configured | Repeat Step 5.3 and re-scan |
| `CA bundle not found` in generate script | Different AIX Toolbox path | Check `openssl version -d` on AIX; update `CA_BUNDLE` in script |
| Vault container disappeared | RHEL rebooted or OOM | Re-run Steps 3 and 4 |

## Step 10: Deploy the Carbon UI (optional — for LOB-friendly demos)

The `ui/` directory contains a Carbon Design System web app that wraps all demo operations
in a three-page click-through interface. No command line is visible to the audience.

The UI runs on the RHEL Vault host (pvm2) on port 3001. The Express backend runs on port 3002.
Both must be started after Vault is running.

### Deploy the UI on pvm2

```bash
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" << ENDSSH
# Clone the repo (or git pull if already cloned)
if [ ! -d ~/powersc-vault-demo ]; then
  sudo dnf install -y git
  git clone https://github.com/ibm-power-demos-with-bob/powersc-vault-demo.git ~/powersc-vault-demo
else
  cd ~/powersc-vault-demo && git pull
fi

cd ~/powersc-vault-demo/ui

# Install Node.js via dnf (NOT NodeSource — ppc64le not supported there)
command -v node || sudo dnf install -y nodejs npm

# Install dependencies
npm install

# Build Next.js app
npm run build
ENDSSH
```

### Configure .env.local

```bash
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" "cat > ~/powersc-vault-demo/ui/.env.local << EOF
AIX_HOST=${AIX_HOST}
AIX_USER=cecuser
AIX_SSH_KEY_PATH=/home/cecuser/.ssh/techzone-key.pem
VAULT_ADDR=http://127.0.0.1:8200
VAULT_TOKEN=myroot
VAULT_ADDR_EXTERNAL=http://${VAULT_HOST}:8200
POWERSC_URL=https://${POWERSC_HOST}
NEXT_PUBLIC_POWERSC_URL=https://${POWERSC_HOST}
API_PORT=3002
EOF"
```

Also copy the TechZone SSH key to the expected path on pvm2:
```bash
scp -i "$SSH_KEY" "$SSH_KEY" "$SSH_USER@$VAULT_HOST:/home/cecuser/.ssh/techzone-key.pem"
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" "chmod 600 /home/cecuser/.ssh/techzone-key.pem"
```

### Open firewall ports and start services

```bash
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" << 'ENDSSH'
# Open UI ports
sudo firewall-cmd --permanent --add-port=3001/tcp
sudo firewall-cmd --permanent --add-port=3002/tcp
sudo firewall-cmd --reload

cd ~/powersc-vault-demo/ui

# Start Express backend
nohup npm run server > ~/server.log 2>&1 &
echo "Backend PID: $!"

# Start Next.js frontend
nohup npm start > ~/ui.log 2>&1 &
echo "Frontend PID: $!"

sleep 3
echo "Checking services..."
curl -s http://localhost:3002/health && echo " — backend OK"
curl -s http://localhost:3001 | head -c 100 && echo " — frontend OK"
ENDSSH
```

### Access the UI

Open in browser: `http://<VAULT_HOST>:3001`

The three pages:
- **The Challenge** (`/`) — click "Generate Demo Environment" → deploys 150 old certificates to AIX
- **The Solution** (`/solution`) — click "Deploy Vault Certificates" → Vault replaces all 150 certs
- **The Results** (`/results`) — before/after table + ROI calculator

### Stopping / restarting the UI

```bash
ssh -i "$SSH_KEY" "$SSH_USER@$VAULT_HOST" "pkill -f 'node server/index' ; pkill -f 'next start'"
# Then re-run the start commands above
```

