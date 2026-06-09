# Deploy Old Certificates - Step-by-Step Guide

## Overview
This guide walks through deploying the updated `generate-old-certificates.sh` script that uses real old CA certificates from the system bundle.

## Prerequisites
- RHEL system (129.40.59.194) - accessible
- AIX system (129.40.59.195) - accessible  
- Password: `8-P5VO+NT3UR5!g`
- Updated `generate-old-certificates.sh` script

## Step 1: Transfer Script Directly to AIX

From your Windows desktop:

```bash
# Open PowerShell or Command Prompt
cd C:\Users\029878866\Desktop

# Transfer directly to AIX (no need to go through RHEL)
scp generate-old-certificates.sh cecuser@129.40.59.195:/home/cecuser/

# Enter password when prompted: 8-P5VO+NT3UR5!g
```

**Note**: You can transfer directly from Windows to AIX. The RHEL system (129.40.59.194) is only needed for running Vault, not as an intermediary for file transfers.

## Step 2: Prepare AIX System

SSH to AIX:

```bash
# From RHEL (or directly from Windows)
ssh cecuser@129.40.59.195
# Password: 8-P5VO+NT3UR5!g

# Verify the CA bundle exists
ls -lh /opt/freeware/etc/ssl/certs/extracted/pem/tls-ca-bundle.pem

# Should show a file around 200-300KB with 170+ certificates
```

## Step 3: Make Script Executable

```bash
# Make the script executable
chmod +x generate-old-certificates.sh

# Verify permissions
ls -l generate-old-certificates.sh
# Should show: -rwxr-xr-x
```

## Step 4: Run the Script

```bash
# Run with sudo (needs root to create /opt directories)
# The script automatically cleans up old certificates first
sudo ./generate-old-certificates.sh

# You should see output like:
# ========================================
# PowerSC + Vault Demo Setup
# Distributing 150 Old Certificates
# ========================================
#
# Cleaning up old certificate directories...
#   Removing existing directories:
#     - /opt/sap
#     - /opt/oracle
#     - /opt/integration
#     - /opt/loadbalancer
#     - /opt/proxy
# ✓ Cleanup complete
#
# Extracting certificates from CA bundle...
# ✓ Extracted 170 certificates from bundle
#
# Deploying SAP Application Layer Certificates (60 certs)...
# ...
```

## Step 5: Verify Certificate Deployment

```bash
# Check that directories were created
ls -la /opt/

# Should see:
# drwxr-xr-x  sap
# drwxr-xr-x  oracle
# drwxr-xr-x  integration
# drwxr-xr-x  loadbalancer
# drwxr-xr-x  proxy

# Check a sample certificate
ls -la /opt/sap/app01/certs/

# View certificate details
openssl x509 -in /opt/sap/app01/certs/server.pem -noout -text | grep -A2 "Validity"

# Should show dates from 2008-2011 era
```

## Step 6: Verify Certificate Characteristics

Check a few random certificates to confirm they're old:

```bash
# Check SAP certificate
openssl x509 -in /opt/sap/app01/certs/server.pem -noout -dates -subject -issuer

# Check Oracle certificate  
openssl x509 -in /opt/oracle/prod01/certs/server.pem -noout -dates -subject -issuer

# Check Integration certificate
openssl x509 -in /opt/integration/mq/certs/qmgr01.pem -noout -dates -subject -issuer

# Look for:
# - notBefore dates from 2008-2011
# - notAfter dates from 2020-2030 (many already expired)
# - Issuer names like "AffirmTrust", "ACCVRAIZ1", "DigiCert", etc.
```

## Step 7: Count Deployed Certificates

```bash
# Count all certificate files
find /opt -name "*.pem" -type f | wc -l

# Should show 300 files (150 certs + 150 keys)

# Count just certificates (not keys)
find /opt -name "*.pem" -type f | grep -v "key" | wc -l

# Should show 150 certificates
```

## Expected Results

After successful deployment:

- **150 certificates** distributed across:
  - 60 SAP certificates (app servers, web dispatcher, gateway)
  - 50 Oracle certificates (databases, listeners)
  - 30 Integration certificates (MQ, API, ESB, B2B)
  - 10 Infrastructure certificates (load balancers, proxies)

- **Certificate characteristics**:
  - Real CA certificates from system bundle
  - Issued between 2008-2011 (15-18 years old)
  - Many already expired or expiring soon
  - Weak cryptography (RSA 1024/2048, SHA-1)
  - Randomly selected from 170+ available CAs

## Troubleshooting

### Script fails with "CA bundle not found"
```bash
# Check if the bundle exists
ls -l /opt/freeware/etc/ssl/certs/extracted/pem/tls-ca-bundle.pem

# If not found, locate it
find /opt -name "tls-ca-bundle.pem" 2>/dev/null

# Update script with correct path if needed
```

### Permission denied errors
```bash
# Make sure you're using sudo
sudo ./generate-old-certificates.sh

# Or run as root
su -
./generate-old-certificates.sh
```

### OpenSSL command not found
```bash
# Check OpenSSL installation
which openssl

# If not found, install it
# (Should already be installed on AIX)
```

## Next Steps

After successful certificate deployment:

1. **Trigger PowerSC Quantum Safety Scan**
   - Log into PowerSC console
   - Navigate to Quantum Safety
   - Run scan on AIX client (p1229-pvm3)
   - Wait for scan to complete (5-10 minutes)

2. **Capture BEFORE State**
   - Take screenshots of PowerSC findings
   - Document weak certificates detected
   - Note certificate ages and expiration dates
   - Export report if available

3. **Configure Vault PKI**
   - Run `vault-pki-setup.sh` on RHEL
   - Verify Vault is issuing 24-hour certificates
   - Test certificate generation

4. **Replace Certificates**
   - Run `replace-with-vault-certificates.sh` on AIX
   - Verify Vault certificates deployed
   - Check new certificate characteristics

5. **Rescan with PowerSC**
   - Run another Quantum Safety scan
   - Compare BEFORE vs AFTER results
   - Demonstrate improvement

## Demo Story

**BEFORE**: "Howdens has 150 certificates across their SAP and Oracle landscape. Many are 15+ years old with weak cryptography. PowerSC Quantum Safety scan reveals the risk."

**AFTER**: "Using HashiCorp Vault integrated with PowerSC, we automatically replace these certificates with modern, short-lived (24-hour) certificates. The rescan shows dramatic improvement."

## Quick Reference Commands

```bash
# Transfer script directly to AIX (from Windows)
scp generate-old-certificates.sh cecuser@129.40.59.195:/home/cecuser/

# SSH to AIX
ssh cecuser@129.40.59.195

# Run script (automatically cleans up old certs)
sudo ./generate-old-certificates.sh

# Verify deployment
find /opt -name "*.pem" -type f | grep -v "key" | wc -l

# Check sample certificate
openssl x509 -in /opt/sap/app01/certs/server.pem -noout -dates -subject
```

## System Architecture

```
Windows Desktop (Your PC)
    |
    | SCP direct transfer
    ↓
AIX Client (129.40.59.195)
    - Runs generate-old-certificates.sh
    - Hosts SAP/Oracle simulated workloads
    - Scanned by PowerSC
    
RHEL on Power (129.40.59.194)
    - Runs HashiCorp Vault
    - Issues replacement certificates
    - Not needed for initial certificate deployment
```

## Notes

- The script uses `csplit` to extract individual certificates from the CA bundle
- Certificates are randomly selected for each deployment path
- Private keys are generated as 1024-bit RSA (intentionally weak for demo)
- File permissions are set appropriately (644 for certs, 600 for keys)
- The script is idempotent - can be run multiple times safely