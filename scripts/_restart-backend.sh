#!/bin/bash
# Restart just the Express backend
DEMO_HOME="$HOME/powersc-vault-demo"
UI_DIR="$DEMO_HOME/ui"
LOG_DIR="$DEMO_HOME/logs"
NPM=$(command -v npm || find /usr/bin /usr/local/bin -name npm 2>/dev/null | head -1)

mkdir -p "$LOG_DIR"

echo "Stopping old backend..."
pkill -f "node.*server/index" 2>/dev/null && echo "  stopped" || echo "  (not running)"
sleep 1

echo "Starting backend..."
cd "$UI_DIR"
setsid nohup node server/index.js > "$LOG_DIR/backend.log" 2>&1 &
echo "PID $!"

sleep 3
echo "--- backend.log ---"
tail -8 "$LOG_DIR/backend.log"
