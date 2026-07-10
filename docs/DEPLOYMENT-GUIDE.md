# PowerSC + Vault Demo - Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the demo to your IBM Power systems.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Your Local Machine (Windows)                                │
│ - Demo scripts and UI code                                  │
│ - Transfer files via SCP                                    │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ SCP Transfer
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ RHEL Client (p1229-pvm2) - <VAULT_HOST>                   │
│ - Vault server (port 8200)                                  │
│ - Demo UI (port 3001)                                       │
│ - Backend API (port 3002)                                   │
│ - vault-pki-setup.sh                                        │
│ - replace-with-vault-certificates.sh                        │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ SSH to AIX
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ AIX Client (p1229-pvm3) - <AIX_HOST>                    │
│ - Target system for certificates                            │
│ - generate-old-certificates.sh                              │
│ - Certificate directories (/opt/sap, /opt/oracle, etc.)    │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

### On Your Local Machine
- [ ] SSH client installed
- [ ] SCP/SFTP client available
- [ ] Access to TechZone reservation credentials
- [ ] All demo files in current directory

### On RHEL Client (p1229-pvm2)
- [ ] Vault installed and running
- [ ] Node.js 18+ installed (we'll install if needed)
- [ ] Port 3001 and 3002 available
- [ ] SSH access to AIX client configured

### On AIX Client (p1229-pvm3)
- [ ] OpenSSL installed
- [ ] Bash shell available
- [ ] Write access to /opt directory
- [ ] PowerSC agent running

## Deployment Steps

### Step 1: Prepare Files on Local Machine

Create a deployment package with all necessary files:

```powershell
# On your Windows machine (PowerShell)
cd C:\Users\029878866\Desktop

# Create deployment directory
mkdir powersc-vault-demo-deploy
cd powersc-vault-demo-deploy

# Copy scripts
copy ..\generate-old-certificates.sh .
copy ..\vault-pki-setup.sh .
copy ..\replace-with-vault-certificates.sh .

# Copy deployment script (we'll create this next)
copy ..\deploy-demo.sh .

# Copy UI implementation plan
copy ..\DEMO-UI-IMPLEMENTATION-PLAN.md .

# Verify files
dir
```

Expected files:
```
generate-old-certificates.sh
vault-pki-setup.sh
replace-with-vault-certificates.sh
deploy-demo.sh
DEMO-UI-IMPLEMENTATION-PLAN.md
```

### Step 2: Transfer Files to RHEL Client

```powershell
# Transfer deployment package to RHEL client
scp -r powersc-vault-demo-deploy cecuser@<VAULT_HOST>:/home/cecuser/

# Verify transfer
ssh cecuser@<VAULT_HOST> "ls -la /home/cecuser/powersc-vault-demo-deploy"
```

### Step 3: Deploy on RHEL Client

```bash
# SSH to RHEL client
ssh cecuser@<VAULT_HOST>

# Navigate to deployment directory
cd /home/cecuser/powersc-vault-demo-deploy

# Make scripts executable
chmod +x *.sh

# Run deployment script
./deploy-demo.sh
```

The deployment script will:
1. Check prerequisites (Node.js, Vault, SSH keys)
2. Install missing dependencies
3. Transfer AIX scripts to p1229-pvm3
4. Configure environment variables
5. Set up systemd services (optional)
6. Provide next steps

### Step 4: Configure PowerSC Initial Setup

**IMPORTANT:** This step must be completed before running the demo scripts.

#### 4.1 Access PowerSC UI

1. Open browser and navigate to: `https://p1229-pvm1.p1229.cecc.ihost.com`
2. Login with `powersc-admin` credentials
3. Accept self-signed certificate warning

#### 4.2 Generate Keystores for AIX Client

1. Click **Endpoint Admin** in top navigation
2. Click **Keystore Requests** tab
3. Select **p1229-pvm3** (AIX client at <AIX_HOST>)
4. Click **Generate Keystore** button
5. Wait for status to change to "yes"
6. Click **Endpoints** tab
7. Wait 2-5 minutes for endpoint to appear

#### 4.3 Configure Quantum Safe Scan Paths

**This is critical - do this during initial setup!**

1. With p1229-pvm3 visible in Endpoints list, find **Actions** or **Configure** button
2. Select **"Quantum safe scan configuration"**
3. In the directory tree, **check the `/opt` checkbox**
   - This enables scanning of all `/opt` subdirectories
   - Includes current and future directories: `/opt/sap`, `/opt/oracle`, `/opt/integration`, etc.
4. Click **Save**

**Why this matters:**
- Demo certificates will be created under `/opt`
- PowerSC needs to know to scan this location
- Configuring now saves a step later
- Any future subdirectories are automatically included

#### 4.4 Run Initial Quantum Safety Scan

1. Navigate to **Security** in top navigation
2. Find p1229-pvm3 in systems list
3. Click **three-dot menu (⋮)** in Actions column
4. Select **Quantum Safety** → **Run quantum safety full scan**
5. Wait for scan completion (typically <1 minute)
6. Verify scan completed successfully

### Step 5: Verify Deployment

```bash
# Check Vault is running
vault status

# Check Node.js version
node --version  # Should be 18+

# Check SSH to AIX works
ssh cecuser@<AIX_HOST> "hostname"  # Should return p1229-pvm3

# Check AIX scripts are in place
ssh cecuser@<AIX_HOST> "ls -la /home/cecuser/demo-scripts/"
```

## File Transfer Details

### Files for RHEL Client (p1229-pvm2)

**Location:** `/home/cecuser/powersc-vault-demo/`

```
powersc-vault-demo/
├── scripts/
│   ├── vault-pki-setup.sh              # Vault PKI configuration
│   └── replace-with-vault-certificates.sh  # Certificate replacement
├── .env                                 # Environment configuration
├── deploy-demo.sh                       # Deployment automation
└── README.md                            # Quick reference
```

### Files for AIX Client (p1229-pvm3)

**Location:** `/home/cecuser/demo-scripts/`

```
demo-scripts/
├── generate-old-certificates.sh         # Generate old certificates
└── README.md                            # Usage instructions
```

## SCP Commands Reference

### Transfer Individual Files

```bash
# From Windows PowerShell to RHEL
scp generate-old-certificates.sh cecuser@<VAULT_HOST>:/home/cecuser/

# From RHEL to AIX
ssh cecuser@<VAULT_HOST>
scp generate-old-certificates.sh cecuser@<AIX_HOST>:/home/cecuser/demo-scripts/
```

### Transfer Entire Directory

```bash
# From Windows to RHEL (recursive)
scp -r powersc-vault-demo-deploy cecuser@<VAULT_HOST>:/home/cecuser/

# From RHEL to AIX (recursive)
ssh cecuser@<VAULT_HOST>
scp -r /home/cecuser/powersc-vault-demo/scripts/* cecuser@<AIX_HOST>:/home/cecuser/demo-scripts/
```

## Environment Configuration

### Create .env File on RHEL Client

```bash
# SSH to RHEL client
ssh cecuser@<VAULT_HOST>

# Create environment file
cat > /home/cecuser/powersc-vault-demo/.env << 'EOF'
# AIX Client Configuration
AIX_HOST=<AIX_HOST>
AIX_USER=cecuser
AIX_SSH_KEY_PATH=/home/cecuser/.ssh/id_rsa
AIX_SCRIPTS_PATH=/home/cecuser/demo-scripts

# Vault Configuration
VAULT_ADDR=http://127.0.0.1:8200
VAULT_TOKEN=your-vault-root-token-here

# PowerSC Configuration
POWERSC_URL=https://p1229-pvm1.p1229.cecc.ihost.com
POWERSC_USER=powersc-admin
POWERSC_PASSWORD=your-powersc-password-here

# Demo UI Configuration
DEMO_UI_PORT=3001
DEMO_API_PORT=3002
NODE_ENV=production
EOF

# Secure the file
chmod 600 /home/cecuser/powersc-vault-demo/.env
```

### Get Vault Root Token

```bash
# If you need to retrieve the Vault root token
cat /home/cecuser/vault-init.txt | grep "Initial Root Token"

# Or if Vault is already unsealed
vault token lookup
```

## Port Configuration

### Ports Used by Demo

| Port | Service | Description |
|------|---------|-------------|
| 3001 | Demo UI | Next.js frontend (Carbon UI) |
| 3002 | Demo API | Express backend + WebSocket |
| 8200 | Vault | HashiCorp Vault API |
| 8443 | PowerSC | PowerSC UI (already running) |

### Open Firewall Ports (if needed)

```bash
# On RHEL client
sudo firewall-cmd --permanent --add-port=3001/tcp
sudo firewall-cmd --permanent --add-port=3002/tcp
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-ports
```

## SSH Key Setup

### Generate SSH Key for AIX Access (if needed)

```bash
# On RHEL client
ssh-keygen -t rsa -b 4096 -f /home/cecuser/.ssh/id_rsa -N ""

# Copy public key to AIX client
ssh-copy-id cecuser@<AIX_HOST>

# Test passwordless SSH
ssh cecuser@<AIX_HOST> "hostname"
```

## Troubleshooting

### Issue: SCP Permission Denied

**Solution:**
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Verify SSH config
cat ~/.ssh/config
```

### Issue: Node.js Not Found

**Solution:**
```bash
# Install Node.js 18 on RHEL
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Verify installation
node --version
npm --version
```

### Issue: Cannot Connect to Vault

**Solution:**
```bash
# Check Vault status
vault status

# If sealed, unseal Vault
vault operator unseal

# Check Vault is listening
netstat -tlnp | grep 8200
```

### Issue: SSH to AIX Fails

**Solution:**
```bash
# Test basic connectivity
ping <AIX_HOST>

# Check SSH service on AIX
ssh cecuser@<AIX_HOST> "lssrc -s sshd"

# Verify SSH key is authorized
ssh cecuser@<AIX_HOST> "cat ~/.ssh/authorized_keys"
```

## Quick Reference Commands

### Check Deployment Status

```bash
# On RHEL client
cd /home/cecuser/powersc-vault-demo

# Check all scripts are present
ls -la scripts/

# Check environment is configured
cat .env | grep -v PASSWORD | grep -v TOKEN

# Check SSH to AIX works
ssh cecuser@<AIX_HOST> "ls -la /home/cecuser/demo-scripts/"
```

### Manual Script Execution

```bash
# On AIX client (generate old certificates)
ssh cecuser@<AIX_HOST>
cd /home/cecuser/demo-scripts
sudo ./generate-old-certificates.sh

# On RHEL client (setup Vault PKI)
cd /home/cecuser/powersc-vault-demo/scripts
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="your-token"
./vault-pki-setup.sh

# On RHEL client (replace certificates)
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="your-token"
./replace-with-vault-certificates.sh
```

## Next Steps After Deployment

1. **Verify all scripts work manually** before building UI
2. **Capture PowerSC screenshots** for before/after comparison
3. **Test Vault PKI** configuration
4. **Build the Carbon UI** using implementation plan
5. **Integrate UI with scripts** via API endpoints
6. **Test end-to-end demo flow**
7. **Practice demo execution**

## Security Considerations

### Credentials Management

```bash
# Never commit credentials to git
echo ".env" >> .gitignore
echo "*.key" >> .gitignore
echo "vault-init.txt" >> .gitignore

# Secure sensitive files
chmod 600 /home/cecuser/powersc-vault-demo/.env
chmod 600 /home/cecuser/.ssh/id_rsa
chmod 600 /home/cecuser/vault-init.txt
```

### Network Security

- Demo UI should only be accessible from trusted networks
- Consider using SSH tunneling for remote access
- Use HTTPS in production (not required for demo)

### Vault Security

- Keep root token secure
- Use Vault policies for production
- Rotate tokens regularly
- Enable audit logging

## Rollback Procedure

If deployment fails or you need to start over:

```bash
# On RHEL client
cd /home/cecuser
rm -rf powersc-vault-demo

# On AIX client
ssh cecuser@<AIX_HOST>
rm -rf /home/cecuser/demo-scripts
sudo rm -rf /opt/sap /opt/oracle /opt/integration /opt/loadbalancer /opt/proxy

# Re-deploy from scratch
# Follow Step 1-3 again
```

## Support

If you encounter issues:

1. Check this deployment guide
2. Review DEMO-UI-IMPLEMENTATION-PLAN.md
3. Check system logs: `journalctl -xe`
4. Verify network connectivity
5. Check firewall rules
6. Review Vault logs: `vault audit list`

---

**Ready to deploy? Start with Step 1 above!**
