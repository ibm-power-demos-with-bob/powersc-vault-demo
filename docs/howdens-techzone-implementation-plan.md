# Howdens TechZone Demo Implementation Plan

## Reservation Context

**Reservation ID:** `6a218765d20dcc88bf917b61`  
**Environment Type:** PowerSC environment with multiple VMs  
**Primary OS Account:** `cecuser` (sudo-capable)  
**PowerSC UI Account:** `powersc`

### Reserved Systems

| Role | Hostname | IP |
|---|---|---|
| PowerSC Server RHEL VM | `p1229-pvm1.p1229.cecc.ihost.com` | `129.40.59.193` |
| PowerSC Agent RHEL VM | `p1229-pvm2.p1229.cecc.ihost.com` | `129.40.59.194` |
| PowerSC Agent AIX VM | `p1229-pvm3.p1229.cecc.ihost.com` | `129.40.59.195` |
| PowerSC Agent IBM i VM | `p1229-pvm4.p1229.cecc.ihost.com` | `129.40.59.196` |

## Recommended Implementation Path

Use the **optimal live demo path** from the original plan:

- Install **HashiCorp Vault on the PowerSC Server RHEL VM** (`p1229-pvm1`)
- Keep **PowerSC Server** as the monitoring/compliance console
- Use the **RHEL agent VM** (`p1229-pvm2`) as the primary certificate target
- Optionally reference the **AIX VM** as an expansion point during the narrative
- Do not depend on external hosted Vault unless the TechZone environment blocks installation

This gives a credible live story:
- PowerSC provides infrastructure and certificate visibility
- Vault provides short-lived certificate issuance and rotation
- The RHEL agent demonstrates deployment and discovery
- The AIX host can be positioned as the next rollout target

## Target Demo Architecture

```text
TechZone Reservation
├── p1229-pvm1 (129.40.59.193)
│   ├── PowerSC Server / UI
│   └── Vault server (port 8200)
├── p1229-pvm2 (129.40.59.194)
│   └── RHEL agent target for certificate deployment
├── p1229-pvm3 (129.40.59.195)
│   └── AIX agent target (optional narrative / later extension)
└── p1229-pvm4 (129.40.59.196)
    └── IBM i agent target (out of scope for first implementation)
```

## Demo Objective

Demonstrate that:

1. PowerSC identifies certificate hygiene/compliance issues
2. Vault issues short-lived certificates on demand
3. Certificates can be deployed to a monitored PowerSC target
4. PowerSC then shows improved certificate posture / fresher inventory
5. The combined story supports Howdens’ SAP, depot, and compliance narrative

## Implementation Sequence

## Phase 1 — Validate the Reserved Environment

### 1. Confirm access
From your workstation:

```bash
ssh cecuser@129.40.59.193
ssh cecuser@129.40.59.194
```

### 2. Confirm sudo and OS details
On each RHEL VM:

```bash
whoami
hostname -f
sudo -l
cat /etc/os-release
uname -a
arch
ip addr
```

Expected:
- `cecuser` can sudo
- RHEL 8 or 9
- `ppc64le` on at least the Power-hosted Linux VM(s)

### 3. Confirm PowerSC services on server VM
On `p1229-pvm1`:

```bash
sudo systemctl list-units --type=service | grep -i powersc
sudo ss -tulpn
```

### 4. Confirm PowerSC UI access
From browser:
- Open the PowerSC UI URL exposed by the reservation
- Log in with `powersc`
- Verify certificate/compliance views are accessible

## Phase 2 — Install Vault on the PowerSC Server VM

Install Vault on `p1229-pvm1` so the demo remains self-contained.

### 1. Install prerequisites

```bash
sudo dnf install -y unzip jq wget openssl
```

### 2. Download Vault binary for Power

```bash
VAULT_VERSION="1.15.6"
cd /tmp
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_ppc64le.zip
unzip vault_${VAULT_VERSION}_linux_ppc64le.zip
sudo mv vault /usr/local/bin/
sudo chmod +x /usr/local/bin/vault
vault version
```

### 3. Create Vault directories and config

```bash
sudo mkdir -p /opt/vault/data /etc/vault.d
sudo useradd --system --home /opt/vault --shell /bin/false vault 2>/dev/null || true
sudo chown -R vault:vault /opt/vault /etc/vault.d
```

Create `/etc/vault.d/vault.hcl`:

```hcl
storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}

api_addr = "http://129.40.59.193:8200"
ui = true
disable_mlock = true
```

### 4. Create systemd service

```bash
sudo tee /etc/systemd/system/vault.service > /dev/null <<'EOF'
[Unit]
Description=HashiCorp Vault
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

### 5. Start Vault

```bash
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault
sudo systemctl status vault
```

### 6. Open firewall if required

```bash
sudo firewall-cmd --permanent --add-port=8200/tcp
sudo firewall-cmd --reload
```

## Phase 3 — Initialize and Configure Vault PKI

### 1. Initialize Vault

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
vault operator init -key-shares=1 -key-threshold=1 > /tmp/vault-init.txt
```

Extract credentials:

```bash
UNSEAL_KEY=$(grep 'Unseal Key 1:' /tmp/vault-init.txt | awk '{print $NF}')
ROOT_TOKEN=$(grep 'Initial Root Token:' /tmp/vault-init.txt | awk '{print $NF}')
vault operator unseal $UNSEAL_KEY
vault login $ROOT_TOKEN
vault status
```

### 2. Enable PKI engines

```bash
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki

vault write -field=certificate pki/root/generate/internal \
  common_name="Howdens Demo Root CA" \
  issuer_name="howdens-root-2026" \
  ttl=87600h > /tmp/root_ca.crt

vault write pki/config/urls \
  issuing_certificates="http://129.40.59.193:8200/v1/pki/ca" \
  crl_distribution_points="http://129.40.59.193:8200/v1/pki/crl"

vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int
```

### 3. Create intermediate CA

```bash
vault write -format=json pki_int/intermediate/generate/internal \
  common_name="Howdens Demo Intermediate CA" \
  issuer_name="howdens-demo-int" \
  | jq -r '.data.csr' > /tmp/pki_intermediate.csr

vault write -format=json pki/root/sign-intermediate \
  issuer_ref="howdens-root-2026" \
  csr=@/tmp/pki_intermediate.csr \
  format=pem_bundle \
  ttl=43800h \
  | jq -r '.data.certificate' > /tmp/intermediate.cert.pem

vault write pki_int/intermediate/set-signed \
  certificate=@/tmp/intermediate.cert.pem
```

### 4. Create demo role

```bash
vault write pki_int/roles/power-systems-sap-role \
  issuer_ref="howdens-demo-int" \
  allowed_domains="howdens.local,demo.local" \
  allow_subdomains=true \
  max_ttl="24h" \
  ttl="24h" \
  key_type="rsa" \
  key_bits=2048
```

### 5. Test issuance

```bash
vault write -format=json pki_int/issue/power-systems-sap-role \
  common_name="sap-prod-app-01.howdens.local" \
  ttl="24h"
```

## Phase 4 — Prepare Certificate Deployment Target

Use `p1229-pvm2` as the monitored target.

### 1. Create demo certificate directories

On `129.40.59.194`:

```bash
ssh cecuser@129.40.59.194
sudo mkdir -p /etc/ssl/sap /etc/ssl/legacy
sudo chown -R cecuser:cecuser /etc/ssl/sap /etc/ssl/legacy
```

### 2. Create legacy comparison certificates

Generate one or two self-signed legacy certificates with long validity:

```bash
openssl req -x509 -newkey rsa:2048 -sha256 -days 365 \
  -nodes \
  -keyout /etc/ssl/legacy/sap-db-prod.key \
  -out /etc/ssl/legacy/sap-db-prod.pem \
  -subj "/CN=sap-db-prod.howdens.local"
```

Repeat for:
- `sap-fiori.howdens.local`
- `depot-manchester-sap.howdens.local`

These provide the “before” state for PowerSC inventory.

### 3. Issue and deploy Vault-managed certificates

From `p1229-pvm1`:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
vault login $ROOT_TOKEN

vault write -format=json pki_int/issue/power-systems-sap-role \
  common_name="sap-prod-app-01.howdens.local" \
  ttl="24h" > /tmp/sap-prod-app-01.json
```

Extract artifacts:

```bash
jq -r '.data.certificate' /tmp/sap-prod-app-01.json > /tmp/sap-prod-app-01.pem
jq -r '.data.private_key' /tmp/sap-prod-app-01.json > /tmp/sap-prod-app-01.key
jq -r '.data.ca_chain[]' /tmp/sap-prod-app-01.json > /tmp/sap-prod-app-01-ca-chain.pem
```

Copy to target:

```bash
scp /tmp/sap-prod-app-01.pem cecuser@129.40.59.194:/tmp/
scp /tmp/sap-prod-app-01.key cecuser@129.40.59.194:/tmp/
```

On `129.40.59.194`:

```bash
sudo mv /tmp/sap-prod-app-01.pem /etc/ssl/sap/
sudo mv /tmp/sap-prod-app-01.key /etc/ssl/sap/
openssl x509 -in /etc/ssl/sap/sap-prod-app-01.pem -text -noout | grep -A2 "Validity"
```

Repeat for one or two additional hostnames if needed.

## Phase 5 — Align PowerSC Discovery

### 1. Confirm certificate scan paths
In PowerSC, verify that certificate discovery includes:
- `/etc/ssl/sap/`
- `/etc/ssl/legacy/`
- standard certificate paths already monitored

### 2. Trigger or wait for scan
Use the PowerSC UI to:
- refresh certificate inventory
- rescan the RHEL agent
- capture screenshots before and after

### 3. Build the visible contrast
Target inventory should show:
- legacy certificates with long validity
- Vault-issued certificates with 24-hour TTL
- clear age/issuer differences

## Phase 6 — Optional Rotation Automation

If time permits, add a simple renewal script on `p1229-pvm1`.

### Example rotation script concept

```bash
#!/bin/bash
set -e

export VAULT_ADDR='http://127.0.0.1:8200'
CERT_NAME="sap-prod-app-01.howdens.local"
OUT_JSON="/tmp/${CERT_NAME}.json"

vault write -format=json pki_int/issue/power-systems-sap-role \
  common_name="${CERT_NAME}" \
  ttl="24h" > "${OUT_JSON}"

jq -r '.data.certificate' "${OUT_JSON}" > /tmp/${CERT_NAME}.pem
jq -r '.data.private_key' "${OUT_JSON}" > /tmp/${CERT_NAME}.key

scp /tmp/${CERT_NAME}.pem cecuser@129.40.59.194:/tmp/
scp /tmp/${CERT_NAME}.key cecuser@129.40.59.194:/tmp/

ssh cecuser@129.40.59.194 "sudo mv /tmp/${CERT_NAME}.pem /etc/ssl/sap/ && sudo mv /tmp/${CERT_NAME}.key /etc/ssl/sap/"
```

A cron or systemd timer can be mentioned in the demo even if not fully automated live.

## Demo Runbook

## Act 1 — PowerSC Foundation
Show:
- monitored systems
- certificate inventory
- legacy certificates
- compliance/certificate posture

## Act 2 — The Gap
Explain:
- manual certificate handling
- long-lived cert risk
- outage/compliance exposure

## Act 3 — Vault Live
Show:
- Vault UI or CLI
- PKI engine
- role `power-systems-sap-role`
- issue a 24-hour certificate live

## Act 4 — Combined Story
Show:
- deployed certificate on `p1229-pvm2`
- PowerSC discovery / refreshed inventory
- improved posture narrative

## Minimum Viable Demo

If time is constrained, implement only:

1. Vault installed on `p1229-pvm1`
2. PKI configured
3. One legacy cert on `p1229-pvm2`
4. One Vault-issued cert on `p1229-pvm2`
5. PowerSC inventory screenshot or live refresh

That is enough for a credible live demo.

## Risks and Mitigations

### Risk: Vault binary download blocked
Mitigation:
- download externally and copy in
- use Docker only if available and simpler

### Risk: PowerSC certificate scan paths not obvious
Mitigation:
- use standard `/etc/ssl` paths
- rely on screenshots if live refresh is slow

### Risk: Firewall blocks port 8200
Mitigation:
- use localhost for CLI demo
- only expose UI if browser access is needed

### Risk: No immediate PowerSC inventory refresh
Mitigation:
- capture “before” and “after” screenshots during prep
- keep live Vault issuance as the centerpiece

### Risk: AIX/IBM i integration takes too long
Mitigation:
- keep first implementation focused on RHEL agent only

## Immediate Next Commands

Start with these on the server VM:

```bash
ssh cecuser@129.40.59.193
sudo -i
dnf install -y unzip jq wget openssl
cat /etc/os-release
uname -a
arch
```

Then proceed with Vault installation.

## Recommended Presentation Updates

The existing presentation is close, but should be updated to reflect that:
- the TechZone environment is now reserved
- the actual hostnames/IPs are known
- the next step is implementation, not reservation
- the demo target is the RHEL agent VM first, with AIX as optional extension

## Deliverables to Prepare

1. Live Vault instance on `p1229-pvm1`
2. Demo certificate set on `p1229-pvm2`
3. PowerSC screenshots:
   - before inventory
   - after inventory
   - compliance/certificate view
4. Updated presentation slide deck
5. One-page operator runbook for demo day

## Decision

Proceed with:
- **Vault on `p1229-pvm1`**
- **certificate deployment to `p1229-pvm2`**
- **PowerSC discovery as the integration proof point**

This is the fastest credible path to a live Howdens demo using the reserved TechZone environment.