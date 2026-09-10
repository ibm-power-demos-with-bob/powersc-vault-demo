#!/bin/bash
################################################################################
# PowerSC + Vault Demo - UI Deployment Script
# 
# Purpose: Deploy Carbon Design System UI for executive demonstrations
#          Handles Node.js dependencies, Carbon packages, and UI build
#
# Prerequisites: 
#   - Node.js installed (via deploy-demo.sh)
#   - powersc-vault-demo-ui directory copied to RHEL client
#
# Usage: Run from demo home directory
#        cd /home/cecuser/powersc-vault-demo
#        ./deploy-ui.sh
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
echo -e "${GREEN}PowerSC + Vault Demo UI Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Configuration
DEMO_HOME="/home/cecuser/powersc-vault-demo"
UI_DIR="$DEMO_HOME/powersc-vault-demo-ui"
BACKEND_DIR="$UI_DIR/backend"

# Check prerequisites
echo -e "${BLUE}Step 1: Checking prerequisites...${NC}"

# Check Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}  ✗ Node.js not found${NC}"
    echo -e "${YELLOW}  Please run deploy-demo.sh first${NC}"
    exit 1
fi
NODE_VERSION=$(node --version)
echo -e "${GREEN}  ✓ Node.js installed: $NODE_VERSION${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}  ✗ npm not found${NC}"
    exit 1
fi
NPM_VERSION=$(npm --version)
echo -e "${GREEN}  ✓ npm installed: $NPM_VERSION${NC}"

# Check UI directory
if [ ! -d "$UI_DIR" ]; then
    echo -e "${RED}  ✗ UI directory not found: $UI_DIR${NC}"
    echo -e "${YELLOW}  Please copy powersc-vault-demo-ui directory to $DEMO_HOME${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ UI directory exists${NC}"

echo ""

# Step 2: Install Yarn globally
echo -e "${BLUE}Step 2: Installing Yarn package manager...${NC}"

if command -v yarn &> /dev/null; then
    YARN_VERSION=$(yarn --version)
    echo -e "${GREEN}  ✓ Yarn already installed: $YARN_VERSION${NC}"
else
    echo -e "${YELLOW}  Installing Yarn globally...${NC}"
    sudo npm install --global yarn
    
    if command -v yarn &> /dev/null; then
        YARN_VERSION=$(yarn --version)
        echo -e "${GREEN}  ✓ Yarn installed: $YARN_VERSION${NC}"
    else
        echo -e "${RED}  ✗ Yarn installation failed${NC}"
        exit 1
    fi
fi

echo ""

# Step 3: Install frontend dependencies
echo -e "${BLUE}Step 3: Installing frontend dependencies...${NC}"

cd "$UI_DIR" || exit 1
echo -e "${YELLOW}  Working directory: $(pwd)${NC}"

# Install base dependencies with yarn
echo -e "${YELLOW}  Installing base dependencies (this may take a few minutes)...${NC}"
if yarn install; then
    echo -e "${GREEN}  ✓ Base dependencies installed${NC}"
else
    echo -e "${RED}  ✗ Failed to install base dependencies${NC}"
    exit 1
fi

# Add specific Carbon packages
echo -e "${YELLOW}  Installing Carbon Design System packages...${NC}"
yarn add @carbon/react@1.33.0
yarn add @carbon/icons-react@latest
yarn add @carbon/pictograms-react@latest
yarn add sass@1.63.6
yarn add typescript

echo -e "${GREEN}  ✓ Carbon packages installed${NC}"

# Add additional frontend packages
echo -e "${YELLOW}  Installing additional frontend packages...${NC}"
yarn add socket.io-client
yarn add next@13.4.9
yarn add react@18.2.0
yarn add react-dom@18.2.0

echo -e "${GREEN}  ✓ Frontend packages installed${NC}"

echo ""

# Step 4: Install backend dependencies
echo -e "${BLUE}Step 4: Installing backend dependencies...${NC}"

if [ -d "$BACKEND_DIR" ]; then
    cd "$BACKEND_DIR" || exit 1
    echo -e "${YELLOW}  Working directory: $(pwd)${NC}"
    
    echo -e "${YELLOW}  Installing backend packages...${NC}"
    npm install express
    npm install cors
    npm install socket.io
    npm install dotenv
    npm install ssh2
    
    echo -e "${GREEN}  ✓ Backend packages installed${NC}"
else
    echo -e "${YELLOW}  Backend directory not found, skipping backend setup${NC}"
fi

echo ""

# Step 5: Build the application
echo -e "${BLUE}Step 5: Building the application...${NC}"

cd "$UI_DIR" || exit 1

echo -e "${YELLOW}  Building Next.js application (this may take several minutes)...${NC}"
if yarn build; then
    echo -e "${GREEN}  ✓ Application built successfully${NC}"
else
    echo -e "${YELLOW}  ⚠ Build failed or incomplete${NC}"
    echo -e "${YELLOW}  You can still run in development mode with: yarn dev${NC}"
fi

echo ""

# Step 6: Create startup scripts
echo -e "${BLUE}Step 6: Creating startup scripts...${NC}"

# Create frontend startup script
cat > "$UI_DIR/start-frontend.sh" << 'EOF'
#!/bin/bash
# Start Next.js frontend in production mode
cd "$(dirname "$0")"
echo "Starting PowerSC Demo UI on port 3001..."
yarn start
EOF

chmod +x "$UI_DIR/start-frontend.sh"
echo -e "${GREEN}  ✓ Created start-frontend.sh${NC}"

# Create backend startup script
if [ -d "$BACKEND_DIR" ]; then
    cat > "$BACKEND_DIR/start-backend.sh" << 'EOF'
#!/bin/bash
# Start Express backend API
cd "$(dirname "$0")"
echo "Starting PowerSC Demo API on port 3002..."
node server.js
EOF
    
    chmod +x "$BACKEND_DIR/start-backend.sh"
    echo -e "${GREEN}  ✓ Created start-backend.sh${NC}"
fi

# Create combined startup script
cat > "$DEMO_HOME/start-ui.sh" << EOF
#!/bin/bash
# Start both frontend and backend for PowerSC Demo UI

echo "Starting PowerSC + Vault Demo UI..."
echo ""

# Load environment variables
if [ -f "$DEMO_HOME/.env" ]; then
    export \$(cat $DEMO_HOME/.env | grep -v '^#' | xargs)
fi

# Start backend in background
if [ -d "$BACKEND_DIR" ]; then
    echo "Starting backend API on port 3002..."
    cd "$BACKEND_DIR"
    nohup node server.js > $DEMO_HOME/logs/backend.log 2>&1 &
    BACKEND_PID=\$!
    echo "Backend PID: \$BACKEND_PID"
    echo ""
fi

# Start frontend
echo "Starting frontend UI on port 3001..."
cd "$UI_DIR"
yarn start

# Cleanup on exit
trap "kill \$BACKEND_PID 2>/dev/null" EXIT
EOF

chmod +x "$DEMO_HOME/start-ui.sh"
echo -e "${GREEN}  ✓ Created start-ui.sh${NC}"

echo ""

# Step 7: Start UI persistently (setsid + nohup — survives SSH disconnect)
echo -e "${BLUE}Step 7: Starting UI (persistent, survives SSH disconnect)...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/start-ui.sh" ]; then
    bash "$SCRIPT_DIR/start-ui.sh"
else
    echo -e "${YELLOW}  ⚠ start-ui.sh not found — falling back to inline start${NC}"
    mkdir -p "$DEMO_HOME/logs"
    cd "$UI_DIR/server"
    setsid nohup node index.js > "$DEMO_HOME/logs/backend.log" 2>&1 &
    echo "  Backend PID: $!"
    cd "$UI_DIR"
    setsid nohup yarn start > "$DEMO_HOME/logs/frontend.log" 2>&1 &
    echo "  Frontend PID: $!"
fi

# Made with Bob