# Vault Setup Guide - Rootless Podman on IBM Power

## Overview

This guide documents the correct way to set up HashiCorp Vault on IBM Power (ppc64le) using rootless Podman. This approach is preferred over running Vault with sudo for better security and simpler management.

## Key Principles

1. **Run Vault as cecuser** (not root/sudo)
2. **Use rootless Podman** (more secure than root containers)
3. **Use Power-native container image** (icr.io/ppc64le-oss/vault-ppc64le)
4. **Set root token explicitly** (VAULT_DEV_ROOT_TOKEN_ID=myroot)

## Prerequisites

- RHEL on IBM Power system
- Podman installed (rootless mode)
- Network access to IBM Container Registry (icr.io)

## Step 1: Stop Any Existing Vault Containers

```bash
# Check for running containers
podman ps -a

# Stop and remove any existing Vault containers
sudo podman stop vault-demo 2>/dev/null || true
sudo podman rm vault-demo 2>/dev/null || true
podman stop vault 2>/dev/null || true
podman rm vault 2>/dev/null || true
```

## Step 2: Start Vault Container (Rootless)

```bash
# Start Vault in dev mode with explicit root token
# Run as cecuser (NOT sudo)
podman run -d \
  --name vault \
  -p 8200:8200 \
  --cap-add=IPC_LOCK \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  icr.io/ppc64le-oss/vault-ppc64le:v1.14.8

# Wait for Vault to start
sleep 5

# Verify container is running
podman ps
```

Expected output:
```
CONTAINER ID  IMAGE                                     COMMAND      CREATED        STATUS        PORTS                   NAMES
0d3532e9c3f4  icr.io/ppc64le-oss/vault-ppc64le:v1.14.8  server -dev  30 seconds ago Up 31 seconds 0.0.0.0:8200->8200/tcp  vault
```

## Step 3: Configure Environment Variables

```bash
# Set environment variables (as cecuser)
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="myroot"

# Add to .bashrc for persistence
echo 'export VAULT_ADDR="http://127.0.0.1:8200"' >> ~/.bashrc
echo 'export VAULT_TOKEN="myroot"' >> ~/.bashrc
```

## Step 4: Configure Vault PKI

All commands run inside the container using `podman exec`:

```bash
# Enable PKI secrets engine
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot \
  vault vault secrets enable pki

# Configure max lease TTL (1 year)
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot \
  vault vault secrets tune -max-lease-ttl=8760h pki

# Generate root CA certificate
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot \
  vault vault write -format=json pki/root/generate/internal \
    common_name="Howdens Internal Root CA" \
    issuer_name="howdens-root-ca" \
    ttl=8760h \
    organization="Howdens" \
    ou="IT Security" \
    country="GB"

# Configure CA and CRL URLs
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot \
  vault vault write pki/config/urls \
    issuing_certificates="http://${VAULT_HOST}:8200/v1/pki/ca" \
    crl_distribution_points="http://${VAULT_HOST}:8200/v1/pki/crl"

# Create PKI role for SAP/Oracle workloads
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot \
  vault vault write pki/roles/sap-oracle \
    allowed_domains="howdens.local,sap.howdens.local,oracle.howdens.local,mq.howdens.local,api.howdens.local,esb.howdens.local,b2b.howdens.local,lb.howdens.local,proxy.howdens.local" \
    allow_subdomains=true \
    allow_bare_domains=true \
    max_ttl=24h \
    ttl=24h \
    key_type=rsa \
    key_bits=2048
```

## Step 5: Test Certificate Issuance

```bash
# Test issuing a certificate
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot \
  vault vault write pki/issue/sap-oracle \
    common_name="test.howdens.local" \
    ttl=24h
```

Expected output should show:
- `certificate` field with PEM-encoded certificate
- `private_key` field with RSA private key
- `serial_number` field
- `expiration` timestamp

## Step 6: Verify Remote Access from AIX

On AIX client (p1229-pvm3):

```bash
# Set environment variables
export VAULT_ADDR="http://${VAULT_HOST}:8200"
export VAULT_TOKEN="myroot"

# Test connectivity
curl -s http://${VAULT_HOST}:8200/v1/sys/health

# Test certificate issuance via REST API
curl -s -X POST \
  -H "X-Vault-Token: myroot" \
  -H "Content-Type: application/json" \
  -d '{"common_name":"test-from-aix.howdens.local","ttl":"24h"}' \
  http://${VAULT_HOST}:8200/v1/pki/issue/sap-oracle
```

## Why Rootless Podman?

### Security Benefits
- Containers run with user privileges, not root
- Reduced attack surface
- Better isolation between containers and host
- Follows principle of least privilege

### Operational Benefits
- No sudo required for container management
- Simpler permission model
- Easier to troubleshoot
- Consistent with modern container best practices

### Demo Benefits
- Same user (cecuser) on both RHEL and AIX
- Cleaner narrative ("running as regular user")
- More production-like setup

## Troubleshooting

### Container Won't Start - Port Already in Use

```bash
# Find what's using port 8200
sudo lsof -i :8200

# If old container is running
sudo podman stop vault-demo
sudo podman rm vault-demo
```

### Vault CLI Says "no container with name vault-demo found"

This means the `vault` command is aliased or wrapped to use `podman exec`. Use the full `podman exec` syntax instead:

```bash
# Instead of: vault status
# Use:
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot \
  vault vault status
```

### Permission Denied Errors from AIX

If you see "permission denied" when issuing certificates from AIX, verify:

1. Vault is running: `podman ps`
2. Token is correct: `echo $VAULT_TOKEN` (should be "myroot")
3. Network is accessible: `curl http://${VAULT_HOST}:8200/v1/sys/health`
4. PKI is configured: Run Step 4 commands again

## Container Management

### Start Container on Boot (Optional)

```bash
# Generate systemd unit file
podman generate systemd --new --name vault > ~/.config/systemd/user/vault.service

# Enable user service
systemctl --user enable vault.service
systemctl --user start vault.service

# Enable lingering (allows user services to run without login)
loginctl enable-linger cecuser
```

### Stop Container

```bash
podman stop vault
```

### View Container Logs

```bash
podman logs vault
podman logs -f vault  # Follow logs
```

### Restart Container

```bash
podman restart vault
```

## Summary

✅ **DO:**
- Run Vault as cecuser (rootless Podman)
- Use `icr.io/ppc64le-oss/vault-ppc64le:v1.14.8`
- Set `VAULT_DEV_ROOT_TOKEN_ID=myroot`
- Use `podman exec` with `-e` flags for configuration

❌ **DON'T:**
- Run Vault with sudo
- Use root containers
- Forget to set the root token explicitly
- Use HTTPS in dev mode (use HTTP)

## Reference

- Container Image: `icr.io/ppc64le-oss/vault-ppc64le:v1.14.8`
- Vault Address: `http://$VAULT_HOST:8200` (from AIX, using pvm2 FQDN) or `http://127.0.0.1:8200` (local on pvm2)
- Root Token: `myroot`
- PKI Role: `sap-oracle`
- Certificate TTL: 24 hours

---

*Last Updated: 2026-06-09*
*Demo: PowerSC + HashiCorp Vault*
*Customer: Howdens*
