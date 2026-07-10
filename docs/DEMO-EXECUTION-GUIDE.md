# PowerSC + Vault Demo Execution Guide
## Howdens Certificate Takeover Demonstration

---

## 🎯 Demo Objective

**Show how HashiCorp Vault "takes over" certificate management for Howdens' SAP/Oracle workloads on AIX, transforming long-lived manually-managed certificates into short-lived automated certificates with improved quantum-safe posture.**

---

## 📊 Key Metrics to Demonstrate

| Metric | BEFORE (Manual) | AFTER (Vault) | Improvement |
|--------|----------------|---------------|-------------|
| Average Cert Age | 287+ days | 24 hours | 99% reduction |
| Compliance Score | ~67% | ~98% | +31% |
| Quantum-Safe Ready | Partial | Yes | Full compliance |
| Management Method | Manual spreadsheets | Automated | Zero touch |
| Annual Outages | 3 per year | 0 | 100% reduction |

---

## 🏗️ Environment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ PowerSC Server (p1229-pvm1) - <POWERSC_HOST>               │
│ - PowerSC UI (port 8443)                                   │
│ - Quantum Inventory Report                                 │
│ - Monitors all agents                                      │
└─────────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
│ RHEL Client  │  │ AIX Client  │  │ IBM i       │
│ p1229-pvm2   │  │ p1229-pvm3  │  │ p1229-pvm4  │
│ .194         │  │ .195        │  │ .196        │
│              │  │             │  │             │
│ ✅ Vault     │  │ 🎯 TARGET   │  │ (unused)    │
│   :8200      │  │ SAP/Oracle  │  │             │
└──────────────┘  └─────────────┘  └─────────────┘
```

---

## 📋 Demo Flow (Step-by-Step)

### PHASE 0: Initial Setup (REQUIRED - 10 minutes)

#### 0.1 Access PowerSC UI

**Steps:**
1. Open browser (Chrome/Firefox recommended)
2. Navigate to: `https://p1229-pvm1.p1229.cecc.ihost.com` (no port needed)
   - Alternative: `https://<POWERSC_HOST>` (if hostname doesn't resolve)
3. Login with admin credentials:
   - **Username:** `powersc-admin`
   - **Password:** (from TechZone reservation)
4. Accept self-signed certificate warning
   - Note: `/webclient/#/` path is added automatically

#### 0.2 Generate Keystores (CRITICAL STEP)

**Why This Matters:**
- AIX client will NOT be visible until keystores are generated
- This step registers the AIX client with PowerSC
- Enables certificate discovery and scanning

**Updated UI Navigation:**
1. Click **Endpoint Admin** in the top navigation bar
2. You'll see the Endpoint Admin page showing:
   - **Endpoints** tab (initially shows "No systems have been added")
   - **Keystore Requests** tab
3. Click the **Keystore Requests** tab
4. Select **p1229-pvm3** (AIX client at <AIX_HOST>)
5. Click **Generate Keystore** button
6. Wait for keystore generation to complete (status changes to "yes")
7. Return to the **Endpoints** tab
8. Wait 2-5 minutes for endpoint registration
9. Verify AIX client (p1229-pvm3) now appears in the table with:
   - System Name
   - IP Address (<AIX_HOST>)
   - User Group
   - Verified Timestamp
   - Connectivity Diagnosis
   - Key Expiration Timestamp
   - OS (AIX)
10. Confirm client status shows as "Active" or "Connected"

#### 0.3 Configure Quantum Safe Scan Paths (CRITICAL - Do This Now!)

**Why This Matters:**
- Demo certificates will be created under `/opt` directory
- PowerSC needs to know to scan this location
- Configuring now means one less step later
- Any future subdirectories under `/opt` will be scanned automatically

**Steps:**
1. With p1229-pvm3 selected in the Endpoints list, find the **Actions** menu or **Configure** button
2. Select **"Quantum safe scan configuration"**
3. In the scan configuration dialog, locate the directory tree
4. **Check the `/opt` checkbox**
   - This enables scanning of all current and future `/opt` subdirectories
   - Includes: `/opt/sap`, `/opt/oracle`, `/opt/integration`, `/opt/loadbalancer`, `/opt/proxy`
5. Click **Save** to apply the configuration

**Talking Points (if presenting):**
- "First, we need to register our AIX system with PowerSC"
- "This enables PowerSC to discover and monitor certificates"
- "We're also configuring PowerSC to scan the `/opt` directory where our SAP and Oracle certificates live"
- "In production, this would be part of your initial setup"

**Wait for:** AIX client to appear and scan paths configured before proceeding to Phase 1

---

### PHASE 1: Show the Problem (5 minutes)

#### 1.1 Navigate to Quantum Inventory Report
**Look for navigation paths:**
- Reports → Quantum Inventory
- Compliance → Quantum Safe → Certificate Report
- Security → Quantum Readiness → Inventory

#### 1.3 Show "BEFORE" State
**Point out on screen:**
- ❌ Certificates with 287+ day age
- ❌ Compliance score ~67%
- ❌ Quantum-safe status: Not Ready
- ❌ Manual management indicators

**Talking Points:**
- "Howdens runs critical SAP and Oracle on this AIX system"
- "These certificates are 287+ days old - nearly a year!"
- "Manual tracking via spreadsheets leads to 3 outages per year"
- "Not quantum-safe ready - vulnerable to future threats"
- "Remember JLR: £1.9B losses from certificate issues"

**Screenshots to Capture:**
- [ ] Full Quantum Inventory Report
- [ ] Certificate age distribution
- [ ] Individual old certificate details
- [ ] Compliance score dashboard

---

### PHASE 2: Introduce the Solution (3 minutes)

#### 2.1 Switch to Vault UI
- URL: `http://<VAULT_HOST>:8200`
- Show Vault dashboard

**Talking Points:**
- "HashiCorp Vault will take over certificate management"
- "Vault becomes the certificate authority"
- "Automated issuance and rotation"
- "Short-lived certificates (24 hours vs 287+ days)"

#### 2.2 Show Vault PKI Configuration
```bash
# SSH to RHEL client
ssh cecuser@<VAULT_HOST>

# Show PKI configuration
vault read pki/roles/sap-oracle

# Expected output shows:
# - max_ttl: 24h
# - allowed_domains: howdens.local, sap.howdens.local
# - key_type: rsa
# - key_bits: 2048
```

**Talking Points:**
- "Vault is configured to issue 24-hour certificates"
- "Automatic rotation eliminates manual tracking"
- "Modern crypto standards: RSA 2048, SHA-256"

---

### PHASE 3: Execute the Takeover (5 minutes)

#### 3.1 Issue Certificate from Vault
```bash
# Issue new certificate for SAP workload
vault write pki/issue/sap-oracle \
    common_name="sap.howdens.local" \
    ttl=24h \
    format=pem

# Save output to files
# - certificate: vault-cert.pem
# - private_key: vault-key.pem
# - ca_chain: vault-ca.pem
```

**Talking Points:**
- "Vault issues certificate in seconds"
- "24-hour lifespan - dramatically reduced attack window"
- "Fully automated - no spreadsheets needed"

#### 3.2 Deploy to AIX Client
```bash
# SSH to AIX client
ssh cecuser@<AIX_HOST>

# Deploy certificates (simulate SAP/Oracle paths)
sudo cp vault-cert.pem /etc/security/certs/sap-app.pem
sudo cp vault-key.pem /etc/security/certs/sap-app-key.pem
sudo cp vault-ca.pem /etc/security/certs/sap-ca.pem

# Set proper permissions
sudo chmod 644 /etc/security/certs/sap-app.pem
sudo chmod 600 /etc/security/certs/sap-app-key.pem
```

**Talking Points:**
- "Deploying Vault-issued certificates to AIX"
- "These replace the old 287+ day certificates"
- "In production, this would be fully automated"

#### 3.3 Trigger PowerSC Rescan
**Option A - Via UI:**
- Navigate to AIX client details
- Click "Scan Now" or "Refresh Inventory"
- Wait 5-10 minutes

**Option B - Via CLI:**
```bash
ssh cecuser@<POWERSC_HOST>
powersc scan --target p1229-pvm3 --type certificates
```

**Talking Points:**
- "PowerSC will now discover the new certificates"
- "This scan happens automatically on schedule"
- "Let's see the transformation..."

---

### PHASE 4: Show the Transformation (5 minutes)

#### 4.1 Return to PowerSC Quantum Inventory Report
- Refresh the report
- Show updated metrics

#### 4.2 Highlight "AFTER" State
**Point out on screen:**
- ✅ New certificates with 24-hour age
- ✅ Compliance score ~98%
- ✅ Quantum-safe status: Ready
- ✅ Automated management

**Talking Points:**
- "Certificate age dropped from 287+ days to 24 hours"
- "Compliance improved from 67% to 98%"
- "Now quantum-safe ready with modern algorithms"
- "Zero manual intervention required"

**Screenshots to Capture:**
- [ ] Updated Quantum Inventory Report
- [ ] Improved certificate age distribution
- [ ] New Vault-issued certificate details
- [ ] Improved compliance score
- [ ] Side-by-side before/after comparison

---

## 💡 Key Messages

### The Problem
- **Long-lived certificates** (287+ days) = larger attack window
- **Manual management** = human error = outages
- **Aging crypto** = not quantum-safe ready
- **Real cost:** 3 outages/year, potential £1.9B losses (JLR example)

### The Solution
- **PowerSC provides visibility:** Continuous certificate inventory and compliance monitoring
- **Vault provides automation:** Automated certificate lifecycle management
- **Together they deliver:** Security + Compliance + Reliability

### The Value
- ✅ Eliminate certificate-related outages
- ✅ Reduce attack surface with short-lived certificates
- ✅ Achieve quantum-safe readiness
- ✅ Meet compliance requirements automatically
- ✅ Free up IT staff from manual certificate tracking

---

## 🎬 Demo Script (Condensed)

**Opening (30 seconds):**
"Today I'll show you how Howdens transformed their certificate management for SAP and Oracle workloads running on AIX - from manual spreadsheet tracking to fully automated, quantum-safe certificate lifecycle management."

**Act 1 - The Problem (2 minutes):**
"Here's what Howdens faced: [Show PowerSC Report] Certificates averaging 287+ days old, 67% compliance score, manual tracking leading to 3 outages per year. Remember JLR's £1.9B ransomware losses? Certificate issues played a role."

**Act 2 - The Solution (2 minutes):**
"HashiCorp Vault takes over as the certificate authority. [Show Vault] Configured to issue 24-hour certificates with automatic rotation. No more spreadsheets, no more manual tracking."

**Act 3 - The Takeover (3 minutes):**
"Watch as Vault issues a new certificate in seconds. [Execute commands] We deploy it to AIX, and PowerSC discovers it automatically."

**Act 4 - The Transformation (2 minutes):**
"[Show updated PowerSC Report] Certificate age: 24 hours. Compliance: 98%. Quantum-safe: Ready. Outages: Zero. This is the power of PowerSC visibility combined with Vault automation."

**Closing (30 seconds):**
"PowerSC gives you the visibility. Vault gives you the automation. Together, they eliminate certificate-related outages, improve security posture, and prepare you for the quantum computing era."

---

## 📸 Screenshot Checklist

### BEFORE State
- [ ] PowerSC Quantum Inventory Report (full view)
- [ ] Certificate age distribution showing 287+ days
- [ ] Individual certificate details (old cert)
- [ ] Compliance score ~67%
- [ ] Quantum-safe status indicators

### DURING Process
- [ ] Vault UI dashboard
- [ ] Vault PKI configuration
- [ ] Certificate issuance command and output
- [ ] Certificate deployment to AIX

### AFTER State
- [ ] Updated PowerSC Quantum Inventory Report
- [ ] Improved certificate age distribution (24 hours)
- [ ] New Vault-issued certificate details
- [ ] Improved compliance score ~98%
- [ ] Side-by-side before/after comparison

---

## 🔧 Troubleshooting

### PowerSC UI Won't Load
```bash
ssh cecuser@<POWERSC_HOST>
sudo systemctl status powersc
# or for AIX-based PowerSC:
sudo lssrc -g powersc
```

### AIX Agent Not Showing
```bash
ssh cecuser@<AIX_HOST>
lssrc -s powersc_agent
cat /var/log/powersc/agent.log
```

### Vault Not Accessible
```bash
ssh cecuser@<VAULT_HOST>
vault status
systemctl status vault
```

### PowerSC Not Detecting New Certificates
- Wait 10-15 minutes for automatic scan
- Trigger manual scan from UI
- Check certificate file permissions on AIX
- Verify certificate paths are in PowerSC scan configuration

---

## 📚 Reference Information

### URLs
- PowerSC UI: `https://<POWERSC_HOST>:8443`
- Vault UI: `http://<VAULT_HOST>:8200`

### Credentials
- PowerSC: `powersc` / (TechZone password)
- SSH: `cecuser` / (TechZone password)

### Key Paths
- AIX Certificates: `/etc/security/certs/`
- PowerSC Logs: `/var/log/powersc/`
- Vault Config: `/etc/vault.d/`

### Industry Context
- **Howdens:** UK kitchen and joinery supplier
- **Workloads:** SAP (ERP), Oracle (Database)
- **Challenge:** Manual certificate management, aging crypto
- **Risk Reference:** JLR ransomware (£1.9B losses, certificate issues)

---

## ✅ Success Criteria

Demo is successful when you can show:
1. ✅ Clear "before" state with old certificates (287+ days)
2. ✅ Vault issuing new 24-hour certificates
3. ✅ PowerSC detecting the new certificates
4. ✅ Clear "after" state with improved metrics
5. ✅ Compelling narrative about transformation

---

**Good luck with your demo! 🚀**
