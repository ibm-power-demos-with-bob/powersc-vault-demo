#!/bin/bash
cd ~/powersc-vault-demo/ui
echo "=== wiping node_modules ==="
rm -rf node_modules package-lock.json
echo "=== fresh npm install ==="
npm install --ignore-scripts 2>&1
echo "=== exit code: $? ==="
echo "=== restarting backend ==="
pkill -f 'node server/index' 2>/dev/null || true
sleep 2
nohup npm run server > ~/server.log 2>&1 &
echo "Backend PID: $!"
sleep 6
echo "=== backend health ==="
curl -s http://localhost:3002/health
echo ""
echo "=== server log tail ==="
tail -5 ~/server.log
