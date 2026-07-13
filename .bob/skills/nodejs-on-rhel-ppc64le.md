---
name: nodejs-on-rhel-ppc64le
description: >
  Install and manage Node.js on RHEL running on IBM Power (ppc64le). Covers the
  correct version selection, dnf module stream approach (NodeSource does not support
  ppc64le), Node version compatibility with Express and Next.js, npm install flags
  required on fapolicyd-hardened hosts, and the dotenv path resolution pattern for
  Express servers started via nohup. Apply this skill whenever a demo or recipe
  requires Node.js on any IBM Power RHEL environment.
version: 1.0.0
author: EMEA AI on IBM Power Squad
---

# Skill: Node.js on RHEL (ppc64le / IBM Power)

## When to Use This Skill

Apply this skill whenever you are deploying any Node.js application — Next.js UI,
Express backend, or any npm-based tooling — onto a RHEL host running on IBM Power
(`ppc64le`). This includes TechZone PowerSC reservations, Carbon GenAI demo environments,
and any other IBM Power RHEL instance.

---

## The Core Constraint: NodeSource Does Not Support ppc64le

NodeSource (the `nodesource.com` RPM repository, commonly used to install Node 18/20/22
on x86 RHEL) **does not publish ppc64le packages**. Attempting to add the NodeSource repo
and install from it will either fail silently or install an x86 binary that will not run.

**The correct approach on ppc64le RHEL is always the RHEL AppStream dnf module stream.**

---

## Installing Node.js — The Correct Sequence

### Step 1: Enable the Node 20 module stream

```bash
sudo dnf module enable -y nodejs:20
```

This must be done **before** installing nodejs. If you install first and enable after,
the version will not change.

**Why Node 20 specifically?**

| Version | Status on ppc64le RHEL 9 |
|---------|--------------------------|
| Node 16 | Default AppStream stream — too old. Express 4.21+ fails (`es-errors`, `iconv-lite` missing). Next.js 13 runs but has rough edges. |
| Node 18 | Module stream exists but not consistently available across all RHEL 9 subscription levels. |
| Node 20 | ✅ Confirmed available. Compatible with Express 4/5, Next.js 13/14, TypeScript 5.x. **Use this.** |
| Node 22 | Available but TypeScript 5.x (pinned in demo package.json) is not yet compatible. |

### Step 2: Install nodejs

```bash
sudo dnf install -y nodejs npm
```

If Node 16 was previously installed, dnf will upgrade it in the same transaction.

### Verification

```bash
node --version   # should show v20.x.x
npm --version    # should show 10.x.x
```

### Full idempotent snippet (safe to run on any state)

```bash
NODE_MAJOR=$(node --version 2>/dev/null | sed 's/v//;s/\..*//')
if [[ "$NODE_MAJOR" -ge 20 ]] 2>/dev/null; then
  echo "Node $(node --version) — already at 20+, no action needed"
else
  sudo dnf module enable -y nodejs:20
  sudo dnf install -y nodejs npm
  echo "Node $(node --version) installed"
fi
```

---

## npm install on fapolicyd-Hardened Hosts

TechZone PowerSC reservations run `fapolicyd` — a file access policy daemon that enforces
an allow-list for executable files. This affects npm in two ways:

### Problem 1: postinstall scripts blocked

npm packages that run postinstall scripts (most commonly `@ibm/plex` telemetry) will fail
with `Operation not permitted` when fapolicyd blocks the spawned process.

**Fix:** Always use `--ignore-scripts` on these hosts:

```bash
npm install --ignore-scripts
```

This is safe for all Carbon/Next.js/Express dependencies — none of them require postinstall
scripts to function correctly.

### Problem 2: Build tools blocked in user home directory

fapolicyd's default trust rules cover system paths (RPM-installed binaries) but not
`~/node_modules/`. The `next build` process spawns worker processes from `~/node_modules/.bin/`
which fapolicyd blocks.

**Fix:** Add a home-directory allow rule before building:

```bash
# Create allow rule for user home directory
echo 'allow perm=any all : dir=/home/' | sudo tee /etc/fapolicyd/rules.d/69-home-allow.rules

# Reload
sudo fapolicyd-cli --update
sudo systemctl restart fapolicyd
```

This rule is scoped to `/home/` only — it does not weaken system-level enforcement.

---

## dotenv Path Resolution in Express Servers

When an Express server loads environment variables with `require('dotenv').config()`,
the `path` option resolves **relative to the process working directory at startup**,
not relative to the script file location.

This causes silent failures when the server is started via `nohup` or a startup
script that `cd`s before calling `npm run server` — the working directory may not
be what you expect.

**Always resolve the path relative to the script's own `__dirname`:**

```javascript
// ❌ Fragile — breaks if cwd at startup differs from expected
require('dotenv').config({ path: '../.env.local' });

// ✅ Correct — always finds .env.local relative to server/index.js
require('dotenv').config({ path: require('path').join(__dirname, '../.env.local') });
```

Verify it is loading correctly by logging the key env vars at startup:

```javascript
server.listen(PORT, () => {
  console.log(`[server] AIX_HOST: ${process.env.AIX_HOST || '(not set)'}`);
  console.log(`[server] VAULT_ADDR: ${process.env.VAULT_ADDR || 'not set'}`);
});
```

If any value shows `(not set)`, the `.env.local` file is not being found.

---

## Starting Services That Survive SSH Session Close

`nohup` alone is not sufficient on some RHEL configurations — the process may be
sent SIGHUP when the SSH session ends. Use `setsid` or `disown`:

```bash
# Option 1: nohup + disown (reliable for demo services)
nohup npm run server > ~/server.log 2>&1 &
disown $!

nohup npm start > ~/ui.log 2>&1 &
disown $!

# Option 2: setsid (fully detached)
setsid npm run server > ~/server.log 2>&1 &
```

For services that must survive **reboots** (e.g. Vault), use systemd user services:

```bash
podman generate systemd --new --name vault > ~/.config/systemd/user/vault.service
systemctl --user enable vault.service
loginctl enable-linger cecuser
```

---

## Summary: Checklist for Any New ppc64le Demo

- [ ] Enable nodejs:20 module stream before installing Node
- [ ] `npm install --ignore-scripts` on any fapolicyd host
- [ ] Add `69-home-allow.rules` before running `next build`
- [ ] Use `__dirname` in dotenv path resolution
- [ ] Use `disown` or `setsid` when backgrounding services from SSH
- [ ] Never use NodeSource on ppc64le — always use RHEL AppStream
