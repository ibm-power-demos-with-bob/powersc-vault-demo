#!/bin/bash
cd ~/powersc-vault-demo && git pull
pkill -f 'node server/index' 2>/dev/null || true
sleep 2
cd ~/powersc-vault-demo/ui
nohup npm run server > ~/server.log 2>&1 &
echo "Backend PID: $!"
sleep 5
echo "=== backend health ==="
curl -s http://localhost:3002/health
echo ""
echo "=== server log ==="
tail -6 ~/server.log
