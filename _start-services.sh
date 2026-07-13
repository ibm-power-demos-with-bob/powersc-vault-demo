#!/bin/bash
pkill -f 'node server/index' 2>/dev/null || true
pkill -f 'next start' 2>/dev/null || true
sleep 2

cd ~/powersc-vault-demo/ui

nohup npm run server > ~/server.log 2>&1 &
echo "Backend PID: $!"
sleep 4

nohup npm start > ~/ui.log 2>&1 &
echo "Frontend PID: $!"
sleep 6

echo "=== backend health ==="
curl -s http://localhost:3002/health

echo ""
echo "=== frontend responding ==="
curl -sf http://localhost:3001 | head -c 80 && echo " OK" || echo "not yet ready"
