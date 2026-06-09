# PowerSC Quantum Inventory Demo - Vault Certificate Takeover

## Demo Strategy

**Goal:** Show how HashiCorp Vault "takes over" certificate management for Howdens' SAP/Oracle workloads running on AIX, transforming long-lived, manually-managed certificates into short-lived, automated certificates with improved quantum-safe posture.

**Key Report:** PowerSC Quantum Inventory Report (shows certificates with ages + quantum-safe encryption details)

## Current Environment Status

✅ **Vault installed:** p1229-pvm2 (RHEL client) at 129.40.59.194
✅ **fapolicy disabled** on RHEL client to allow Vault to run
🔄 **Next step:** Access PowerSC UI and locate Quantum Inventory Report

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ PowerSC Server (p1229-pvm1)                                 │
│ 129.40.59.193                                               │
│ - PowerSC UI (port 8443)                                    │
│ - Monitoring all agents                                     │
└─────────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
┌───────▼──────┐  ┌──────▼──────┐  ┌──────▼──────┐
│ RHEL Client  │  │ AIX Client  │  │ IBM i       │
│ p1229-pvm2   │  │ p1229-pvm3  │  │ p1229-pvm4  │
│ .194         │  │ .195        │  │ .196        │
│              │  │             │  │             │
│ + Vault      │  │ TARGET      │  │ (unused)    │
│   :8200      │  │ SYSTEM      │  │             │
└──────────────┘  └─────────────┘  └─────────────┘
```

## Step 1: Access PowerSC UI and Locate Quantum Inventory Report

### Access Steps

1. **Open Browser**
   - Use Chrome or Firefox for best compatibility
   
2. **Navigate to PowerSC Server**
   - **Primary URL:** `https://p1229-pvm1.p1229.cecc.ihost.com` (no port needed)
   - **Alternative URL:** `https://129.40.59.193` (if hostname doesn't resolve)
   - **Note:** The `/webclient/#/` path is added automatically

3. **Login with Admin Credentials**
   - **Username:** `powersc-admin`
   - **Password:** (from TechZone reservation)

4. **Accept Security Warnings**
   - Accept self-signed certificate warning when prompted
   - This is expected for demo environments

### Initial Setup: Generate Keystores (Required First!)

**IMPORTANT:** Before the AIX client will be visible, you must generate keystores. This step:
- Registers the AIX client with PowerSC
- Enables certificate discovery and scanning
- Makes the client visible in the PowerSC UI

**Exact Steps to Generate Keystore for AIX Client:**

1. Click **Endpoint Admin** in the top navigation bar

2. Click the **Keystore Requests** tab

3. You'll see a table with 4 systems:
   - p1229-pvm1 (129.40.59.193) - PowerSC Server
   - p1229-pvm2 (129.40.59.194) - RHEL Client (Vault)
   - **p1229-pvm3 (129.40.59.195) - AIX Client** ← This is your target!
   - p1229-pvm4 (129.40.59.196) - IBM i

4. **Select p1229-pvm3** (the AIX client) by clicking its checkbox
   - The row will highlight in blue
   - "1 selected" will appear in the top right

5. Click the **Generate Keystore** button in the blue action bar

6. Wait for keystore generation to complete
   - The "Keystore Generated" column will change from "no" to "yes"
   - This may take a few minutes

7. Once complete, click the **Endpoints** tab

8. **Wait for endpoint registration** (typically 2-5 minutes)
   - Initially, the Endpoints tab may still show "No systems have been added"
   - This is normal - the system needs time to register
   - You can click the **Refresh Table** button to check for updates
   - Or wait and the page will auto-refresh

9. Verify p1229-pvm3 appears in the Endpoints list with:
   - System Name: p1229-pvm3
   - IP: 129.40.59.195
   - OS: AIX
   - Status: Active/Connected
   - Verified Timestamp: Recent date/time

10. **Configure Quantum Safe Scan Paths** (IMPORTANT - Do this now!)
    - With p1229-pvm3 selected in the Endpoints list, look for the **Actions** menu or **Configure** button
    - Select **"Quantum safe scan configuration"** or similar option
    - In the scan configuration dialog, you'll see a directory tree
    - **Check the `/opt` checkbox** to enable scanning of all `/opt` subdirectories
      - This will automatically scan `/opt/sap`, `/opt/oracle`, `/opt/integration`, etc.
      - Any future subdirectories under `/opt` will also be scanned automatically
    - Click **Save** to apply the configuration
    - **Why this matters:** The demo certificates will be created under `/opt`, so PowerSC needs to know to scan there

**What You'll See:**
- **Keystore Requests tab:** "Keystore Generated" changes from "no" to "yes"
- **Endpoints tab (initially):** "No systems have been added" (wait 2-5 minutes)
- **Endpoints tab (after registration):** p1229-pvm3 appears in the table
- **Scan configuration:** `/opt` checkbox checked, ready to discover certificates

**Troubleshooting:**
- If endpoint doesn't appear after 10 minutes, check Keystore Requests tab to confirm "yes" status
- Try clicking "Refresh Table" button
- Check PowerSC agent status on AIX client: `lssrc -s powersc_agent`
- If you forget to configure scan paths now, you can do it later, but it's more efficient to do it during initial setup

**Once keystores are generated and the AIX client is visible, proceed to locate the Quantum Inventory Report.**

---

### Navigate to Quantum Safe Analysis Report

**Updated Navigation Path:**

1. Click **Reports** in the top navigation bar

2. **Expand the left sidebar** (if collapsed)
   - Click the hamburger menu icon if needed

3. **Expand the "Security" section** in the left sidebar
   - Click the dropdown arrow next to "Security"

4. Click **"Quantum Safe Analysis"**
   - You'll see "No Endpoint Selected" initially

5. **Select the AIX endpoint:**
   - Click the blue button **"Select group or endpoint here"**
   - Choose **p1229-pvm3** (AIX client at 129.40.59.195)
   - Or select "All Systems" to see all endpoints

**What the Report Shows:**
- Certificate inventory with ages
- Quantum-safe encryption status
- Compliance scoring
- Certificate details (issuer, validity, algorithm)
- Certificate age distribution
- Algorithm strength indicators

## Step 2: Run Quantum Safety Scan (REQUIRED!)

**Why This is Needed:**
The Quantum Safe Analysis report will show all zeros until you run a scan. The endpoint is registered, but PowerSC hasn't scanned for certificates yet.

**Steps to Run the Scan:**

1. Click **Security** in the top navigation bar

2. Find the AIX client (p1229-pvm3) in the systems list

3. In the **Actions** column for the AIX VM, click the **three-dot menu (⋮)**

4. Select **Quantum Safety** → **Run quantum safety full scan**

5. **Wait for scan completion** (typically less than 1 minute)
   - Events will appear in the PowerSC Security page
   - You'll see "Quantum safety scan has started"
   - Then "Quantum safety scan has completed"

6. **Return to Reports** → **Security** → **Quantum Safe Analysis**

7. Select p1229-pvm3 again

8. The report will now display actual data:
   - Certificate counts (Weak, Strong, Quantum Safe)
   - Cipher information
   - Key details
   - Certificate inventory

**What You'll See:**
- **Before scan:** All metrics show "0"
- **After scan:** Real certificate data appears with counts and details

---

## Step 3: Verify AIX Client in System Inventory

### Navigate to Agent/Systems View

Look for these details:

**AIX Client Information:**
- **Hostname:** `p1229-pvm3.p1229.cecc.ihost.com`
- **IP Address:** `129.40.59.195`
- **OS:** AIX
- **Status:** Should show "Active" or "Connected"
- **Last Contact:** Recent timestamp
- **Agent Version:** Should be displayed

### What to Verify:
- [ ] AIX agent (p1229-pvm3) appears in the systems list
- [ ] Status is "Active" or "Online"
- [ ] Last scan/contact time is recent
- [ ] No error messages or warnings
- [ ] System is being monitored for certificates

## Step 3: Capture "BEFORE" State - Baseline Metrics

### Navigate to Certificate Management

Typical navigation paths:
- **Compliance** → **Certificates**
- **Reports** → **Certificate Inventory**
- **Security** → **Certificate Management**
- **Dashboard** → **Certificate Compliance**

### For AIX Client (p1229-pvm3), Look For:

**Certificate Inventory:**
- Total number of certificates discovered
- Certificate locations (paths on AIX system)
- Certificate types (SSL/TLS, application certs, etc.)

**Certificate Age Distribution:**
- Certificates 0-90 days old
- Certificates 91-180 days old
- Certificates 181-365 days old
- **Certificates 365+ days old** ← This is what we want to see!

**Expected "Before" State:**
- Several certificates with age **287+ days** (as shown in presentation)
- Long validity periods (365 days or more)
- Manual management indicators

## Step 4: Configure Vault for Certificate Takeover

### On RHEL Client (p1229-pvm2) - Vault Server

**Goal:** Configure Vault PKI engine to issue short-lived certificates (24 hours) that will replace the old AIX certificates.

**Key Configuration:**
```bash
# Enable PKI secrets engine
vault secrets enable pki

# Configure PKI with short TTL
vault secrets tune -max-lease-ttl=8760h pki

# Generate root CA
vault write pki/root/generate/internal \
    common_name="Howdens Internal CA" \
    ttl=8760h

# Configure PKI role for short-lived certs
vault write pki/roles/sap-oracle \
    allowed_domains="howdens.local,sap.howdens.local,oracle.howdens.local" \
    allow_subdomains=true \
    max_ttl=24h \
    ttl=24h \
    key_type=rsa \
    key_bits=2048
```

**What This Demonstrates:**
- Vault becomes the certificate authority
- Certificates have 24-hour lifespan (vs 287+ days)
- Automated rotation eliminates manual management
- Modern crypto standards (RSA 2048, SHA-256)

## Step 5: Capture Screenshots

### Screenshots to Take:

1. **Dashboard/Overview**
   - Shows all monitored systems including AIX
   - Overall compliance score

2. **AIX Agent Status**
   - Agent details page
   - Connection status
   - Last scan time

3. **Certificate Inventory for AIX**
   - Total certificates
   - Age distribution chart/table
   - List of certificates

4. **Certificate Age Report**
   - Highlighting old certificates (287+ days)
   - Showing compliance gaps

5. **Individual Certificate Details**
   - Pick one old certificate
   - Show full details (issuer, validity, algorithm)
   - Demonstrate the "before" state

## Expected Findings (Before Vault Integration)

### Compliance Score
- **Current:** ~67% (as per presentation)
- **Issues:** Long-lived certificates, manual management

### Certificate Profile
- **Average Age:** 287+ days
- **Longest Certificate:** 365+ days
- **Management:** Manual, spreadsheet-based
- **Rotation:** Infrequent, error-prone

### Risk Indicators
- Aging certificates increase attack surface
- Manual tracking leads to missed renewals
- Certificate-related outages: 3 per year (Howdens context)

## Step 6: Document Current State

### Create a "Before" Baseline

Note down:
- Total certificates on AIX client: _______
- Certificates > 365 days old: _______
- Certificates > 180 days old: _______
- Current compliance score: _______
- Oldest certificate age: _______
- Certificate locations: _______

This baseline will be compared against the "After Vault" state.

## Troubleshooting

### If PowerSC UI Won't Load
```bash
ssh cecuser@129.40.59.193
sudo systemctl status powersc
# or for AIX-based PowerSC:
sudo lssrc -g powersc
```

### If AIX Agent Not Showing
```bash
ssh cecuser@129.40.59.195
lssrc -s powersc_agent
# Check agent logs
cat /var/log/powersc/agent.log
```

### If Certificate Scan Incomplete
- Trigger manual scan from PowerSC UI
- Wait 5-10 minutes for scan to complete
- Check scan logs for errors

### If No Certificates Showing
- Verify certificate scan paths are configured
- Check AIX certificate locations:
  - `/etc/security/certs/`
  - `/var/ssl/`
  - Application-specific paths
- Trigger rescan

## Step 5: Deploy Vault Certificates to AIX Client

### On AIX Client (p1229-pvm3) - Simulating SAP/Oracle

**Goal:** Replace old certificates with Vault-issued short-lived certificates.

**Approach:**
```bash
# Issue certificate from Vault
vault write pki/issue/sap-oracle \
    common_name="sap.howdens.local" \
    ttl=24h

# Deploy to AIX certificate locations
# (Simulate SAP/Oracle certificate paths)
cp vault-cert.pem /etc/security/certs/sap-app.pem
cp vault-key.pem /etc/security/certs/sap-app-key.pem
```

**What This Demonstrates:**
- Vault "takes over" certificate management
- Old 287+ day certificates replaced with 24-hour certificates
- Automated process vs manual spreadsheet tracking

## Step 6: Trigger PowerSC Rescan

### Force PowerSC to Discover New Certificates

**In PowerSC UI:**
- Navigate to AIX client (p1229-pvm3) details
- Click "Scan Now" or "Refresh Inventory"
- Wait 5-10 minutes for scan to complete

**Or via CLI on PowerSC Server:**
```bash
ssh cecuser@129.40.59.193
# Trigger certificate scan for AIX client
powersc scan --target p1229-pvm3 --type certificates
```

## Step 7: Capture "AFTER" State - Improved Metrics

### Return to Quantum Inventory Report

**Document Improvements:**
- [ ] New certificate count with 24-hour TTL: _______
- [ ] Certificates 0-90 days old: _______ (should increase)
- [ ] Certificates 365+ days old: _______ (should decrease)
- [ ] Average certificate age: _______ days (should drop dramatically)
- [ ] Quantum-safe compliant certificates: _______ (should increase)
- [ ] Overall compliance score: _______% (expect ~98%)

**Screenshot Checklist:**
- [ ] Updated Quantum Inventory Report
- [ ] Certificate age distribution showing improvement
- [ ] New Vault-issued certificate details (24-hour TTL)
- [ ] Improved compliance score
- [ ] Side-by-side before/after comparison

## Step 8: Build Demo Narrative

## Step 8: Build Demo Narrative - The Transformation Story

### Act 1: "The Problem Howdens Faces Today" (BEFORE)
**Show PowerSC Quantum Inventory Report - Initial State**
- "Howdens runs critical SAP and Oracle workloads on AIX"
- "PowerSC discovers certificates with average age of 287+ days"
- "Compliance score: 67% - not quantum-safe ready"
- "Manual certificate management via spreadsheets"
- "Result: 3 certificate-related outages per year"
- **Reference:** JLR ransomware attack (£1.9B losses from certificate issues)

### Act 2: "The Certificate Lifecycle Gap"
**Explain the Risk**
- Long-lived certificates = larger attack window
- Manual tracking = missed renewals = outages
- Aging crypto algorithms not quantum-safe
- No automation = human error

### Act 3: "Vault Takes Over Certificate Management"
**Switch to Vault UI (p1229-pvm2)**
- "HashiCorp Vault becomes the certificate authority"
- Issue 24-hour certificate for SAP/Oracle workload
- Show automated rotation configuration
- Demonstrate API-driven certificate issuance
- "Vault replaces spreadsheets with automation"

### Act 4: "The Transformation" (AFTER)
**Return to PowerSC Quantum Inventory Report**
- "PowerSC now shows Vault-managed certificates"
- "Average certificate age: 24 hours (vs 287+ days)"
- "Compliance score: 98% (vs 67%)"
- "Quantum-safe ready with modern algorithms"
- "Zero manual intervention required"

### The Value Proposition
**PowerSC + Vault Integration:**
- **Visibility:** PowerSC provides continuous certificate inventory and compliance monitoring
- **Automation:** Vault provides automated certificate lifecycle management
- **Security:** Short-lived certificates reduce attack surface
- **Compliance:** Quantum-safe ready for future threats
- **Reliability:** Eliminate certificate-related outages

**ROI for Howdens:**
- Reduce certificate-related outages from 3/year to 0
- Eliminate manual certificate tracking overhead
- Improve security posture and quantum-safe readiness
- Meet compliance requirements automatically