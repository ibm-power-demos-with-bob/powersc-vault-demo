#!/bin/bash
# Upgrade Node.js from 16 to 20 via RHEL dnf module stream
# (NodeSource does not support ppc64le — module stream is the correct path)
echo "=== current node version ==="
node --version

echo "=== enabling nodejs:20 module stream ==="
sudo dnf module enable -y nodejs:20 2>&1

echo "=== installing nodejs 20 ==="
sudo dnf install -y nodejs 2>&1

echo "=== new node version ==="
node --version
npm --version
