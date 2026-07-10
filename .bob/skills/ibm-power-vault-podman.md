---
name: ibm-power-vault-podman
description: >
  Deploy HashiCorp Vault on IBM Power (ppc64le) using a Power-native container image
  via rootless Podman. Covers the fapolicyd trust remediation that is required on
  hardened RHEL hosts (including PowerSC TechZone reservations), the correct container
  image and startup flags, and how to drive Vault via podman exec when the Vault CLI
  is not directly available on the host.
---

# Skill: Vault on IBM Power via Rootless Podman

## When to Use This Skill

Apply this skill when:
1. The demo requires HashiCorp Vault on an IBM Power (`ppc64le`) RHEL host
2. No native ppc64le Vault binary is available from HashiCorp's release pages
3. The RHEL host is a TechZone PowerSC reservation (pre-hardened with fapolicyd)
4. You need to run Vault CLI commands remotely

## Why a Container Instead of a Native Binary

HashiCorp's release pages provide Linux builds for `386`, `amd64`, `arm`, and `arm64`.
There is currently no current native `ppc64le` Vault binary distributed there.

IBM maintains a Power-native Vault image:
```
icr.io/ppc64le-oss/vault-ppc64le:v1.14.8
```

This image runs natively on ppc64le and is the correct deployment path for IBM Power demos.

**Narrative:** Say "Vault is running on IBM Power in a Power-native container deployment model."
Do not say "We had to use a container because the binary was missing."

## The fapolicyd Problem

PowerSC TechZone RHEL hosts come with `fapolicyd` (file access policy daemon) active.
`fapolicyd` enforces an allow-list for all executables and shared libraries. The OCI
container runtimes that Podman uses (`crun`, `runc`) and their shared libraries
(`/lib64/libresolv.so.2`, `/lib64/libsystemd.so.0`) are NOT in the default trust list.

### Symptoms of fapolicyd blocking Podman

- `podman run` fails with `Operation not permitted`
- `runc create failed` or `crun` errors
- `error loading shared library /lib64/libresolv.so.2`
- Podman can pull images successfully but cannot start any container
- Stopping `fapolicyd` temporarily makes containers run

### Diagnosis

```bash
# Check if fapolicyd is active
sudo systemctl status fapolicyd

# View active rules
sudo fapolicyd-cli --list | head -20

# Controlled test: stop fapolicyd, try container, restart fapolicyd
sudo systemctl stop fapolicyd
podman run --rm registry.access.redhat.com/ubi9/ubi-minimal echo "test"
sudo systemctl start fapolicyd
```

If the container runs only when fapolicyd is stopped, fapolicyd is the cause.

### Remediation

Add the required binaries and libraries to the trust database:

```bash
echo '/usr/bin/runc'           | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/usr/bin/crun'           | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/bin/conmon'             | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/lib64/libresolv.so.2'   | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/lib64/libsystemd.so.0'  | sudo tee -a /etc/fapolicyd/fapolicyd.trust

sudo fapolicyd-cli --update
sudo systemctl restart fapolicyd

# Verify fix
podman run --rm registry.access.redhat.com/ubi9/ubi-minimal echo "fapolicyd test passed"
```

If additional libraries are blocked, the error message will name the specific `.so` file.
Add it to the trust file and re-run `fapolicyd-cli --update` + `systemctl restart fapolicyd`.

**Do not disable fapolicyd entirely.** The targeted trust additions are the correct approach
and maintain the host's security posture for the PowerSC demo.

## Starting Vault

Run as `cecuser` (rootless Podman — not sudo):

```bash
# Clean up any previous container
podman stop vault 2>/dev/null || true
podman rm   vault 2>/dev/null || true

# Start Vault in dev mode
# VAULT_DEV_ROOT_TOKEN_ID sets the root token to a known value
# VAULT_DEV_LISTEN_ADDRESS must be 0.0.0.0 so AIX can reach it
podman run -d \
  --name vault \
  -p 8200:8200 \
  --cap-add=IPC_LOCK \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=myroot' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  icr.io/ppc64le-oss/vault-ppc64le:v1.14.8

sleep 5

# Verify
podman ps | grep vault
curl -s http://127.0.0.1:8200/v1/sys/health
```

## Running Vault CLI Commands via podman exec

The Vault CLI is inside the container. Use `podman exec` to run it:

```bash
# Pattern for all Vault CLI commands
podman exec \
  -e VAULT_ADDR=http://127.0.0.1:8200 \
  -e VAULT_TOKEN=myroot \
  vault \
  vault <command> [args]

# Examples:
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot vault vault status
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot vault vault secrets list
podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot vault vault secrets enable pki

# Convenience alias for interactive sessions:
alias V="podman exec -e VAULT_ADDR=http://127.0.0.1:8200 -e VAULT_TOKEN=myroot vault vault"
V status
V secrets list
```

## Persistent Vault (Optional — for longer-lived environments)

Vault in dev mode loses all configuration on container restart. For demos that span multiple
days, enable auto-restart via systemd user service:

```bash
podman generate systemd --new --name vault > ~/.config/systemd/user/vault.service
mkdir -p ~/.config/systemd/user
systemctl --user daemon-reload
systemctl --user enable vault.service
systemctl --user start vault.service
loginctl enable-linger cecuser
```

**Note:** Even with auto-restart, dev mode Vault resets PKI configuration on restart. For
a persistent demo environment, consider Vault server mode with a storage backend (outside
the scope of the demo recipe).

## Architecture Decision: Separate VM for Vault

Keep Vault on the RHEL LPAR (pvm2), not on the PowerSC server (pvm1). Reasons:
- PowerSC server is the "observer" — its job is monitoring, not hosting workloads
- Running experimental containers on the PowerSC server risks destabilising the UI
- The architecture story is cleaner: PowerSC server monitors, RHEL+Vault manages

## Troubleshooting Reference

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Operation not permitted` on `podman run` | fapolicyd blocking OCI runtime | Apply fapolicyd trust remediation above |
| `no image with name vault` | Pull failed or never attempted | `podman pull icr.io/ppc64le-oss/vault-ppc64le:v1.14.8` |
| Container starts but `curl :8200` fails | VAULT_DEV_LISTEN_ADDRESS not set to 0.0.0.0 | Re-start container with the correct env flag |
| `vault: command not found` | Trying to run vault directly on the host | Use `podman exec` pattern above |
| `permission denied` issuing certificate | PKI not configured | Re-run PKI setup commands |
| Port 8200 unreachable from AIX | RHEL firewall blocking | `sudo firewall-cmd --permanent --add-port=8200/tcp && sudo firewall-cmd --reload` |
