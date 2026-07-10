# Quick Start: Replace Certificates with Vault

## Overview
This guide walks you through replacing the 150 old certificates with fresh Vault-issued certificates on the AIX client.

## Prerequisites
✅ Old certificates deployed (150 certs from 2008-2011)
✅ PowerSC "BEFORE" scan completed and captured
✅ Vault PKI configured on RHEL (<VAULT_HOST>)
✅ Vault token available (`myroot`)
✅ `curl` installed on AIX (standard on TechZone)

## Step 1: Vault Token

The Vault root token is: **`myroot`**

**Note:** The script uses `curl` and standard shell tools (grep/sed/awk) to communicate with Vault's REST API. No special tools like Vault CLI or jq are required.

## Step 2: Transfer Updated Script to AIX

From your local machine (Desktop):

```bash
cd powersc-vault-demo/scripts
scp replace-with-vault-certificates.sh cecuser@<AIX_HOST>:/home/cecuser/
# Password: 8-P5VO+NT3UR5!g
```

## Step 3: SSH to AIX and Set Environment

```bash
ssh cecuser@<AIX_HOST>
# Password: 8-P5VO+NT3UR5!g

# Set Vault environment variables
export VAULT_ADDR="http://<VAULT_HOST>:8200"
export VAULT_TOKEN="myroot"

# Verify Vault connectivity using curl
curl -s "$VAULT_ADDR/v1/sys/health"
```

**Expected output:** JSON response showing Vault is initialized and unsealed

## Step 4: Run the Replacement Script

```bash
# Make script executable
chmod +x replace-with-vault-certificates.sh

# Run with sudo (needs root to write to /opt directories)
sudo -E ./replace-with-vault-certificates.sh
```

**Note:** The `-E` flag preserves environment variables (VAULT_ADDR, VAULT_TOKEN) when using sudo.

## Expected Output

```
========================================
PowerSC + Vault Demo
Replacing Old Certificates with Vault
========================================

Testing Vault connectivity...
✓ Vault connection successful

Replacing SAP Application Layer Certificates (60 certs)...
  SAP App Server 1...
  ✓ Replaced: sap-app01.howdens.local
  ✓ Replaced: sap-app01-client.howdens.local
  ✓ Replaced: sap-app01-icm.howdens.local
  ...

Replacing Oracle Database Layer Certificates (50 certs)...
  Oracle Production DB 1...
  ✓ Replaced: oracle-prod01.howdens.local
  ...

Replacing Integration/Middleware Certificates (30 certs)...
  IBM MQ...
  ✓ Replaced: mq-qmgr01.howdens.local
  ...

Replacing Infrastructure Certificates (10 certs)...
  Load Balancers...
  ✓ Replaced: lb01.howdens.local
  ...

========================================
Certificate Replacement Complete!
========================================

Total certificates replaced: 150

All certificates are now:
  - Issued by Vault PKI
  - 24-hour TTL (vs 287+ days)
  - Strong crypto (RSA 2048, SHA-256)
  - Quantum-safe ready
  - Automatically rotated

Next Steps:
1. Trigger PowerSC Quantum Safety scan to discover new certificates
2. Capture 'AFTER' state showing improved metrics
3. Compare before/after to demonstrate transformation

Vault has successfully taken over certificate management!
```

## Step 5: Verify Certificate Replacement

Check a few certificates to confirm they're Vault-issued:

```bash
# Check a SAP certificate
sudo openssl x509 -in /opt/sap/app01/certs/server.pem -noout -text | grep -A2 "Validity"

# Should show:
#   Not Before: Jun  9 16:00:00 2026 GMT
#   Not After : Jun 10 16:00:00 2026 GMT  (24 hours later)

# Check the issuer
sudo openssl x509 -in /opt/sap/app01/certs/server.pem -noout -issuer

# Should show:
#   issuer=CN = Howdens Demo Vault CA
```

## Step 6: Trigger PowerSC Rescan

Now trigger a new PowerSC scan to capture the "AFTER" state:

```bash
# Option 1: Use the API helper script
cd /home/cecuser
./powersc-api-helper.sh trigger-scan

# Option 2: Use curl directly
curl -k -X POST https://<POWERSC_HOST>:9443/powersc/api/v1/quantumsafe/scan \
  -H "Content-Type: application/json" \
  -u admin:admin

# Wait for scan to complete (30-60 seconds with optimized scan)
./powersc-api-helper.sh check-status

# Get the report
./powersc-api-helper.sh get-report
```

## Step 7: Compare Results

**BEFORE State:**
- 150 certificates detected
- Dates: 2008-2011 (15-18 years old)
- Crypto: SHA1withRSA (weak)
- Validity: 287+ days remaining
- Status: ⚠️ Quantum vulnerable

**AFTER State (Expected):**
- 150 certificates detected
- Dates: 2026 (current)
- Crypto: SHA256withRSA (strong)
- Validity: 24 hours (short-lived)
- Status: ✅ Quantum-safe ready

## Troubleshooting

### Issue: "Cannot connect to Vault"
```bash
# Check VAULT_ADDR is set
echo $VAULT_ADDR

# Test connectivity
curl -s http://<VAULT_HOST>:8200/v1/sys/health

# Verify token
vault token lookup
```

### Issue: "Permission denied" when writing certificates
```bash
# Make sure you're using sudo with -E flag
sudo -E ./replace-with-vault-certificates.sh

# Check if directories exist
ls -la /opt/sap/app01/certs/
```

### Issue: Some certificates fail to issue
This is expected behavior with the updated script. The script will:
- Continue processing remaining certificates
- Show clear error messages for failures
- Create placeholder files to prevent downstream errors
- Report total successful replacements at the end

### Issue: curl not found
```bash
# Check if curl is installed
which curl

# curl should be pre-installed on TechZone AIX
# If not, contact TechZone support
```

### Issue: Vault API returns errors
```bash
# Test Vault API directly
curl -s -X POST \
  -H "X-Vault-Token: myroot" \
  -H "Content-Type: application/json" \
  -d '{"common_name":"test.howdens.local","ttl":"24h"}' \
  http://<VAULT_HOST>:8200/v1/pki/issue/sap-oracle

# Should return JSON with certificate data, not errors
# Look for "certificate":"-----BEGIN CERTIFICATE-----..." in output
```

## Demo Story

This demonstrates the **"AFTER"** state of the demo:

1. **BEFORE**: 150 old certificates (2008-2011) with weak crypto detected by PowerSC
2. **VAULT TAKEOVER**: Vault replaces all certificates with fresh, short-lived, strong crypto
3. **AFTER**: PowerSC rescan shows dramatic improvement in security posture
4. **OUTCOME**: Automated certificate lifecycle management, quantum-safe ready

## Next Steps

1. ✅ Capture PowerSC "AFTER" screenshot
2. ✅ Create side-by-side comparison slide
3. ✅ Document the transformation metrics
4. ✅ Prepare demo narrative for Howdens

---

**Made with Bob - Pre-Sales Demo Builder**
