#!/bin/bash
echo "=== backend ==="
curl -s http://localhost:3002/health
echo ""
echo "=== frontend / ==="
curl -sf http://localhost:3001 | head -c 100
echo ""
echo "=== frontend /customer ==="
curl -sf http://localhost:3001/customer | head -c 100
echo ""
echo "=== server log tail ==="
tail -5 ~/server.log
