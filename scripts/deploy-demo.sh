#!/bin/bash
################################################################################
# PowerSC + Vault Demo - Automated Deployment Script
# 
# Purpose: Automate deployment of demo scripts and environment setup
#          on RHEL client (p1229-pvm2) and AIX client (p1229-pvm3)
#
# Usage: Run on RHEL client after transferring files
#        ./deploy-demo.sh
#
# Author: Pre-Sales Demo Builder
# Date: 2026-06-08
################################################################################

set -e  # Exit on error

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PowerSC + Vault Demo Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Configuration
DEMO_HOME="/home/cecuser/powersc-vault-demo"
AIX_HOST="${AIX_HOST:-<AIX_HOST>}"  # Set AIX_HOST env var to your pvm3 FQDN before running
AIX_USER="cecuser"
AIX_SCRIPTS_PATH="/home/cecuser/demo-scripts"

# Step 1: Check prerequisites
echo -e "${BLUE}Step 1: Checking prerequisites...${NC}"

# Check if running on RHEL client
HOSTNAME=$(hostname)
if [[ ! "$HOSTNAME" =~ "pvm2" ]]; then
    echo -e "${YELLOW}  Warning: Not running on expected RHEL client (p1229-pvm2)${NC}"
    echo -e "${YELLOW}  Current hostname: $HOSTNAME${NC}"
    read -p "  Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}  ✓ Node.js installed: $NODE_VERSION${NC}"
    
    # Check if version is 18+
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -lt 18 ]; then
        echo -e "${YELLOW}  Warning: Node.js version should be 18+${NC}"
        echo -e "${YELLOW}  Attempting to upgrade Node.js via dnf...${NC}"
        sudo dnf install -y nodejs npm
    fi
else
    echo -e "${YELLOW}  Node.js not found. Installing via dnf (ppc64le compatible)...${NC}"
    # Use system package manager instead of NodeSource for ppc64le support
    sudo dnf install -y nodejs npm
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        echo -e "${GREEN}  ✓ Node.js installed: $NODE_VERSION${NC}"
    else
        echo -e "${RED}  ✗ Node.js installation failed${NC}"
        echo -e "${YELLOW}  Note: For UI deployment, Node.js is required${NC}"
        echo -e "${YELLOW}  However, demo scripts can still run without it${NC}"
    fi
fi

# Check Vault
if command -v vault &> /dev/null; then
    echo -e "${GREEN}  ✓ Vault CLI installed${NC}"
    
    # Check if Vault is running
    if vault status &> /dev/null; then
        echo -e "${GREEN}  ✓ Vault is running${NC}"
    else
        echo -e "${RED}  ✗ Vault is not running or sealed${NC}"
        echo -e "${YELLOW}  Please start and unseal Vault before continuing${NC}"
        exit 1
    fi
else
    echo -e "${RED}  ✗ Vault CLI not found${NC}"
    echo -e "${YELLOW}  Please install Vault before continuing${NC}"
    exit 1
fi

# Check SSH key
if [ -f "$HOME/.ssh/id_rsa" ]; then
    echo -e "${GREEN}  ✓ SSH key exists${NC}"
else
    echo -e "${YELLOW}  SSH key not found. Generating...${NC}"
    ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N ""
    echo -e "${GREEN}  ✓ SSH key generated${NC}"
    echo -e "${YELLOW}  Please copy the key to AIX client:${NC}"
    echo -e "${YELLOW}  ssh-copy-id $AIX_USER@$AIX_HOST${NC}"
    read -p "  Press Enter after copying the key..."
fi

# Test SSH to AIX
echo -e "${BLUE}  Testing SSH connection to AIX client...${NC}"
if ssh -o BatchMode=yes -o ConnectTimeout=5 $AIX_USER@$AIX_HOST "hostname" &> /dev/null; then
    echo -e "${GREEN}  ✓ SSH to AIX client works${NC}"
else
    echo -e "${RED}  ✗ Cannot SSH to AIX client${NC}"
    echo -e "${YELLOW}  Please ensure:${NC}"
    echo -e "${YELLOW}  1. SSH key is copied: ssh-copy-id $AIX_USER@$AIX_HOST${NC}"
    echo -e "${YELLOW}  2. AIX client is accessible: ping $AIX_HOST${NC}"
    exit 1
fi

echo ""

# Step 2: Create directory structure
echo -e "${BLUE}Step 2: Creating directory structure...${NC}"

# Create demo home directory
mkdir -p "$DEMO_HOME/scripts"
mkdir -p "$DEMO_HOME/logs"
echo -e "${GREEN}  ✓ Created $DEMO_HOME${NC}"

# Create scripts directory on AIX
ssh $AIX_USER@$AIX_HOST "mkdir -p $AIX_SCRIPTS_PATH"
echo -e "${GREEN}  ✓ Created $AIX_SCRIPTS_PATH on AIX client${NC}"

echo ""

# Step 3: Copy scripts to appropriate locations
echo -e "${BLUE}Step 3: Deploying scripts...${NC}"

# Copy Vault scripts to RHEL
if [ -f "vault-pki-setup.sh" ]; then
    cp vault-pki-setup.sh "$DEMO_HOME/scripts/"
    chmod +x "$DEMO_HOME/scripts/vault-pki-setup.sh"
    echo -e "${GREEN}  ✓ Deployed vault-pki-setup.sh to RHEL${NC}"
else
    echo -e "${RED}  ✗ vault-pki-setup.sh not found${NC}"
fi

if [ -f "replace-with-vault-certificates.sh" ]; then
    cp replace-with-vault-certificates.sh "$DEMO_HOME/scripts/"
    chmod +x "$DEMO_HOME/scripts/replace-with-vault-certificates.sh"
    echo -e "${GREEN}  ✓ Deployed replace-with-vault-certificates.sh to RHEL${NC}"
else
    echo -e "${RED}  ✗ replace-with-vault-certificates.sh not found${NC}"
fi

# Copy certificate generation script to AIX
if [ -f "generate-old-certificates.sh" ]; then
    scp generate-old-certificates.sh $AIX_USER@$AIX_HOST:$AIX_SCRIPTS_PATH/
    ssh $AIX_USER@$AIX_HOST "chmod +x $AIX_SCRIPTS_PATH/generate-old-certificates.sh"
    echo -e "${GREEN}  ✓ Deployed generate-old-certificates.sh to AIX${NC}"
else
    echo -e "${RED}  ✗ generate-old-certificates.sh not found${NC}"
fi

echo ""

# Step 4: Create environment configuration
echo -e "${BLUE}Step 4: Creating environment configuration...${NC}"

# Check if .env already exists
if [ -f "$DEMO_HOME/.env" ]; then
    echo -e "${YELLOW}  .env file already exists${NC}"
    read -p "  Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}  Skipping .env creation${NC}"
    else
        CREATE_ENV=true
    fi
else
    CREATE_ENV=true
fi

if [ "$CREATE_ENV" = true ]; then
    # Get Vault token
    echo -e "${YELLOW}  Enter Vault root token (or press Enter to skip):${NC}"
    read -s VAULT_TOKEN
    echo
    
    # Get PowerSC password
    echo -e "${YELLOW}  Enter PowerSC admin password (or press Enter to skip):${NC}"
    read -s POWERSC_PASSWORD
    echo
    
    # Create .env file
    cat > "$DEMO_HOME/.env" << EOF
# AIX Client Configuration
AIX_HOST=$AIX_HOST
AIX_USER=$AIX_USER
AIX_SSH_KEY_PATH=$HOME/.ssh/id_rsa
AIX_SCRIPTS_PATH=$AIX_SCRIPTS_PATH

# Vault Configuration
VAULT_ADDR=http://127.0.0.1:8200
VAULT_TOKEN=$VAULT_TOKEN

# PowerSC Configuration
POWERSC_URL=https://p1229-pvm1.p1229.cecc.ihost.com
POWERSC_USER=powersc-admin
POWERSC_PASSWORD=$POWERSC_PASSWORD

# Demo UI Configuration
DEMO_UI_PORT=3001
DEMO_API_PORT=3002
NODE_ENV=production

# Logging
LOG_LEVEL=info
LOG_FILE=$DEMO_HOME/logs/demo.log
EOF
    
    chmod 600 "$DEMO_HOME/.env"
    echo -e "${GREEN}  ✓ Created .env configuration${NC}"
fi

echo ""

# Step 5: Create README files
echo -e "${BLUE}Step 5: Creating documentation...${NC}"

# Create README for RHEL
cat > "$DEMO_HOME/README.md" << 'EOF'
# PowerSC + Vault Demo

## Quick Start

### 1. Setup Vault PKI
```bash
cd /home/cecuser/powersc-vault-demo/scripts
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="your-vault-token"
./vault-pki-setup.sh
```

### 2. Generate Old Certificates on AIX
```bash
ssh cecuser@$AIX_HOST
cd /home/cecuser/demo-scripts
sudo ./generate-old-certificates.sh
```

### 3. Trigger PowerSC Scan
- Open PowerSC UI: https://p1229-pvm1.p1229.cecc.ihost.com
- Navigate to Security → p1229-pvm3 → Actions → Run quantum safety full scan
- Capture "BEFORE" state

### 4. Replace with Vault Certificates
```bash
cd /home/cecuser/powersc-vault-demo/scripts
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="your-vault-token"
./replace-with-vault-certificates.sh
```

### 5. Trigger PowerSC Rescan
- Return to PowerSC UI
- Run quantum safety full scan again
- Capture "AFTER" state

## Files

- `scripts/vault-pki-setup.sh` - Configure Vault PKI
- `scripts/replace-with-vault-certificates.sh` - Replace certificates
- `.env` - Environment configuration
- `logs/` - Demo execution logs

## Troubleshooting

See DEPLOYMENT-GUIDE.md for detailed troubleshooting steps.
EOF

echo -e "${GREEN}  ✓ Created README.md${NC}"

# Create README for AIX
ssh $AIX_USER@$AIX_HOST "cat > $AIX_SCRIPTS_PATH/README.md" << 'EOF'
# Demo Scripts for AIX Client

## Generate Old Certificates

This script creates 150 realistic "old" certificates simulating an enterprise SAP/Oracle landscape.

### Usage

```bash
sudo ./generate-old-certificates.sh
```

### What it creates

- 60 SAP certificates (app servers, dev, QA, web dispatcher, gateway)
- 50 Oracle certificates (production DBs, dev, QA, listeners)
- 30 Integration certificates (MQ, API Gateway, ESB, B2B)
- 10 Infrastructure certificates (load balancers, proxies)

### Certificate characteristics

- Weak crypto (RSA 1024, SHA-1)
- Backdated to appear 287-315 days old
- Distributed across realistic paths

### After running

1. Trigger PowerSC quantum safety scan
2. View results in PowerSC UI
3. Capture "BEFORE" state for demo

## Troubleshooting

If script fails:
- Check you have sudo access
- Verify OpenSSL is installed
- Ensure /opt directory is writable
EOF

echo -e "${GREEN}  ✓ Created README.md on AIX${NC}"

echo ""

# Step 6: Test script execution
echo -e "${BLUE}Step 6: Testing script accessibility...${NC}"

# Test RHEL scripts
if [ -x "$DEMO_HOME/scripts/vault-pki-setup.sh" ]; then
    echo -e "${GREEN}  ✓ vault-pki-setup.sh is executable${NC}"
else
    echo -e "${RED}  ✗ vault-pki-setup.sh is not executable${NC}"
fi

if [ -x "$DEMO_HOME/scripts/replace-with-vault-certificates.sh" ]; then
    echo -e "${GREEN}  ✓ replace-with-vault-certificates.sh is executable${NC}"
else
    echo -e "${RED}  ✗ replace-with-vault-certificates.sh is not executable${NC}"
fi

# Test AIX script
if ssh $AIX_USER@$AIX_HOST "[ -x $AIX_SCRIPTS_PATH/generate-old-certificates.sh ]"; then
    echo -e "${GREEN}  ✓ generate-old-certificates.sh is executable on AIX${NC}"
else
    echo -e "${RED}  ✗ generate-old-certificates.sh is not executable on AIX${NC}"
fi

echo ""

# Step 7: Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Deployment Summary:${NC}"
echo ""
echo -e "${BLUE}RHEL Client (p1229-pvm2):${NC}"
echo "  Demo home: $DEMO_HOME"
echo "  Scripts: $DEMO_HOME/scripts/"
echo "  Config: $DEMO_HOME/.env"
echo "  Logs: $DEMO_HOME/logs/"
echo ""
echo -e "${BLUE}AIX Client (p1229-pvm3):${NC}"
echo "  Scripts: $AIX_SCRIPTS_PATH"
echo "  Accessible via: ssh $AIX_USER@$AIX_HOST"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Review configuration:"
echo "   cat $DEMO_HOME/.env"
echo ""
echo "2. Test Vault PKI setup:"
echo "   cd $DEMO_HOME/scripts"
echo "   export VAULT_ADDR=\"http://127.0.0.1:8200\""
echo "   export VAULT_TOKEN=\"your-token\""
echo "   ./vault-pki-setup.sh"
echo ""
echo "3. Generate old certificates on AIX:"
echo "   ssh $AIX_USER@$AIX_HOST"
echo "   cd $AIX_SCRIPTS_PATH"
echo "   sudo ./generate-old-certificates.sh"
echo ""
echo "4. Trigger PowerSC scan and capture BEFORE state"
echo ""
echo "5. Replace certificates with Vault:"
echo "   cd $DEMO_HOME/scripts"
echo "   ./replace-with-vault-certificates.sh"
echo ""
echo "6. Trigger PowerSC rescan and capture AFTER state"
echo ""
echo -e "${GREEN}For detailed instructions, see:${NC}"
echo "  - $DEMO_HOME/README.md"
echo "  - DEPLOYMENT-GUIDE.md"
echo "  - DEMO-UI-IMPLEMENTATION-PLAN.md"
echo ""
echo -e "${BLUE}Optional: Deploy Carbon UI${NC}"
echo ""
echo "To deploy the Carbon UI for executive demos:"
echo "1. Copy powersc-vault-demo-ui directory to RHEL client"
echo "2. Run: cd $DEMO_HOME && ./deploy-ui.sh"
echo ""

# Made with Bob
