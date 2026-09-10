#!/bin/bash
# Rebuild Next.js and restart the frontend
DEMO_HOME="$HOME/powersc-vault-demo"
UI_DIR="$DEMO_HOME/ui"
LOG_DIR="$DEMO_HOME/logs"
NPM=$(command -v npm || find /usr/bin /usr/local/bin -name npm 2>/dev/null | head -1)

mkdir -p "$LOG_DIR"

echo "Stopping frontend..."
pkill -f "jest-worker" 2>/dev/null || true
pkill -f "next-server" 2>/dev/null || true
pkill -f "next start"  2>/dev/null || true
sleep 2

echo "Building..."
cd "$UI_DIR"
"$NPM" run build 2>&1 | tail -20

echo "Starting frontend..."
fuser -k 3001/tcp 2>/dev/null || true
sleep 1
setsid nohup "$NPM" run start > "$LOG_DIR/frontend.log" 2>&1 &
echo "PID $!"
sleep 8

echo "--- Port check ---"
ss -tlnp | grep 3001 || echo "Not yet on :3001"
echo "--- Log tail ---"
tail -10 "$LOG_DIR/frontend.log"
