#!/bin/bash
################################################################################
# PowerSC Quantum Safety Scan Configuration
# 
# Purpose: Configure PowerSC uiAgent to scan only our demo certificate paths
#          This dramatically reduces scan time from minutes to seconds
#
# Usage: Run on AIX client (p1229-pvm3) as root
#        ./configure-powersc-scan.sh
#
# Author: Pre-Sales Demo Builder
# Date: 2026-06-09
################################################################################

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PowerSC Quantum Safety Configuration${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root or with sudo${NC}"
    exit 1
fi

# PowerSC uiAgent configuration directory
CONFIG_DIR="/etc/security/powersc/uiAgent"
CONFIG_FILE="$CONFIG_DIR/quantumsafe.properties"

echo -e "${YELLOW}Configuring PowerSC uiAgent scan paths...${NC}"

# Create directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    echo "  Creating configuration directory: $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
fi

# Backup existing config if it exists
if [ -f "$CONFIG_FILE" ]; then
    echo "  Backing up existing configuration"
    cp "$CONFIG_FILE" "$CONFIG_FILE.backup.$(date +%Y%m%d-%H%M%S)"
fi

# Create optimized configuration
# Only scan our demo certificate directories for faster results
cat > "$CONFIG_FILE" << 'EOF'
# PowerSC Quantum Safety Scan Configuration
# Optimized for Howdens Demo - Only scan certificate directories
# This reduces scan time from minutes to seconds

# Scan only our demo certificate paths
scanFolders=/opt/sap,/opt/oracle,/opt/integration,/opt/loadbalancer,/opt/proxy

# Optional: Additional settings
# scanDepth=10
# excludePatterns=*.log,*.tmp
EOF

echo -e "${GREEN}✓ Configuration file created: $CONFIG_FILE${NC}"
echo ""

echo -e "${YELLOW}Configuration details:${NC}"
cat "$CONFIG_FILE"
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Configuration Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${YELLOW}Scan paths configured:${NC}"
echo "  - /opt/sap (60 certificates)"
echo "  - /opt/oracle (50 certificates)"
echo "  - /opt/integration (30 certificates)"
echo "  - /opt/loadbalancer (5 certificates)"
echo "  - /opt/proxy (5 certificates)"
echo ""

echo -e "${YELLOW}Benefits:${NC}"
echo "  - Scan time reduced from ~5-10 minutes to ~30-60 seconds"
echo "  - Focused on demo-relevant certificates only"
echo "  - Faster demo execution"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Restart PowerSC uiAgent (if running):"
echo "   systemctl restart powersc-uiagent"
echo ""
echo "2. Trigger scan via REST API or PowerSC console"
echo ""
echo "3. Or use the demo UI to trigger and view scans"
echo ""

# Made with Bob