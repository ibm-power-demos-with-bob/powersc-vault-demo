#!/bin/bash
# Restart the Next.js frontend on pvm02
# Uses npm run start (avoids yarn PATH issues in non-interactive SSH)

DEMO_HOME="$HOME/powersc-vault-demo"
UI_DIR="$DEMO_HOME/ui"
LOG_DIR="$DEMO_HOME/logs"

mkdir -p "$LOG_DIR"

# Find node and npm
NODE=$(command -v node || find /usr/bin /usr/local/bin -name node 2>/dev/null | head -1)
NPM=$(command -v npm || find /usr/bin /usr/local/bin -name npm 2>/dev/null | head -1)

echo "Node: $NODE"
echo "npm:  $NPM"

if [ -z "$NODE" ] || [ -z "$NPM" ]; then
    echo "ERROR: node or npm not found"
    exit 1
fi

# Kill stale processes
echo "Killing stale next/jest-worker processes..."
pkill -f "jest-worker" 2>/dev/null || true
pkill -f "next-server" 2>/dev/null || true
pkill -f "next start"  2>/dev/null || true
sleep 2

# Check port 3001
if ss -tlnp | grep -q ':3001'; then
    echo "WARNING: port 3001 still in use, attempting to free..."
    fuser -k 3001/tcp 2>/dev/null || true
    sleep 2
fi

# Start frontend via npm run start
echo "Starting frontend (npm run start) on port 3001..."
cd "$UI_DIR"
setsid nohup "$NPM" run start > "$LOG_DIR/frontend.log" 2>&1 &
FPID=$!
echo "Launched PID $FPID"

sleep 8

echo "--- Port check ---"
ss -tlnp | grep 3001 || echo "Port 3001 not yet listening (may still be starting)"

echo "--- Last 15 lines of frontend.log ---"
tail -15 "$LOG_DIR/frontend.log"
