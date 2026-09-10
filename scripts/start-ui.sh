#!/bin/bash
# Note: no set -e — pkill returning non-zero (nothing to kill) must not abort
################################################################################
# PowerSC + Vault Demo - Start UI (persistent)
#
# Uses setsid + nohup so both processes survive SSH disconnects and
# TechZone signals that kill the controlling terminal session.
#
# Usage:
#   bash scripts/start-ui.sh
#
# To check if running:
#   pgrep -a -f "node.*server/index.js"
#   pgrep -a -f "next start"
#
# To stop:
#   pkill -f "node.*server/index.js"
#   pkill -f "next start"
#
# Logs:
#   tail -f ~/powersc-vault-demo/logs/backend.log
#   tail -f ~/powersc-vault-demo/logs/frontend.log
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DEMO_HOME="$HOME/powersc-vault-demo"
UI_DIR="$DEMO_HOME/ui"
LOG_DIR="$DEMO_HOME/logs"

# Find npm (yarn may not be on PATH in non-interactive SSH sessions)
NPM=$(command -v npm || find /usr/bin /usr/local/bin -name npm 2>/dev/null | head -1)
if [ -z "$NPM" ]; then
    echo -e "${RED}✗ npm not found${NC}"; exit 1
fi

mkdir -p "$LOG_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}PowerSC Demo — Starting UI${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Kill any existing instances cleanly
echo -e "${BLUE}Stopping any existing processes...${NC}"
pkill -f "jest-worker"          2>/dev/null && echo "  stopped stale jest-worker" || true
pkill -f "node.*server/index.js" 2>/dev/null && echo "  stopped old backend"      || true
pkill -f "next start"            2>/dev/null && echo "  stopped old frontend"     || true
sleep 2

# Free port 3001 if still bound
if ss -tlnp | grep -q ':3001'; then
    echo -e "${YELLOW}  Port 3001 still bound — freeing...${NC}"
    fuser -k 3001/tcp 2>/dev/null || true
    sleep 1
fi

# Start backend (Express API, port 3002)
echo -e "${BLUE}Starting backend (port 3002)...${NC}"
cd "$UI_DIR/server"
setsid nohup node index.js > "$LOG_DIR/backend.log" 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}  ✓ Backend PID: $BACKEND_PID${NC}"

sleep 2

# Start frontend (Next.js, port 3001) — use npm run start, not yarn
echo -e "${BLUE}Starting frontend (port 3001)...${NC}"
cd "$UI_DIR"
setsid nohup "$NPM" run start > "$LOG_DIR/frontend.log" 2>&1 &
FRONTEND_PID=$!
echo -e "${GREEN}  ✓ Frontend PID: $FRONTEND_PID${NC}"

sleep 8

# Quick health check
echo ""
echo -e "${BLUE}Checking processes are alive...${NC}"
if pgrep -f "node.*index.js" > /dev/null; then
    echo -e "${GREEN}  ✓ Backend running${NC}"
else
    echo -e "${RED}  ✗ Backend may have failed — check: tail -f $LOG_DIR/backend.log${NC}"
fi

if ss -tlnp | grep -q ':3001'; then
    echo -e "${GREEN}  ✓ Frontend listening on :3001${NC}"
else
    echo -e "${RED}  ✗ Frontend not yet on :3001 — check: tail -f $LOG_DIR/frontend.log${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}Demo URL:${NC} http://$(hostname -I | awk '{print $1}'):3001"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Logs:${NC}"
echo "  tail -f $LOG_DIR/backend.log"
echo "  tail -f $LOG_DIR/frontend.log"
echo ""
