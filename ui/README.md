# PowerSC + Vault Demo UI

Carbon Design System web interface for the IBM PowerSC + HashiCorp Vault certificate
management demo. Turns three button clicks into the full before/after demonstration —
no command line visible to the audience.

## Pages

| Route | Page | What happens |
|-------|------|-------------|
| `/` | The Challenge | Shows the problem. Button deploys 150 old certificates to AIX. |
| `/solution` | The Solution | Shows Vault value. Button configures PKI and replaces all certificates. |
| `/results` | The Results | Before/after comparison table + ROI calculator. |

## Architecture

```
Browser (port 3001)
    │ Next.js (Carbon UI)
    │ API calls rewritten to port 3002
    ▼
Express + WebSocket (port 3002)
    │ SSH via ssh2 library
    ├──▶ AIX client (pvm3) — runs generate/replace scripts
    │ Axios
    └──▶ Vault REST API (localhost:8200) — PKI operations
```

## Deployment (on RHEL Vault host — pvm2)

See the `deploy-powersc-vault-power` Bob skill for full instructions.
Quick summary:

```bash
# 1. Clone the repo on pvm2
git clone https://github.com/ibm-power-demos-with-bob/powersc-vault-demo.git

# 2. Configure environment
cd powersc-vault-demo/ui
cp .env.local.example .env.local
# Edit .env.local with your reservation FQDNs and SSH key path

# 3. Install Node.js (RHEL dnf — do NOT use NodeSource on ppc64le)
sudo dnf install -y nodejs npm

# 4. Install dependencies
npm install

# 5. Build the Next.js app
npm run build

# 6. Start the Express backend (keep running in background)
nohup npm run server > ~/server.log 2>&1 &

# 7. Start the Next.js frontend (keep running in background)
nohup npm start > ~/ui.log 2>&1 &

# 8. Open in browser
# http://<pvm2-fqdn>:3001
```

## Environment Variables (.env.local)

| Variable | Description |
|----------|-------------|
| `AIX_HOST` | pvm3 FQDN (e.g. `p1234-pvm3.p1234.cecc.ihost.com`) |
| `AIX_USER` | SSH username — always `cecuser` on CE TechZone |
| `AIX_SSH_KEY_PATH` | Absolute path to downloaded TechZone SSH key |
| `VAULT_ADDR` | Vault URL on this host — `http://127.0.0.1:8200` |
| `VAULT_TOKEN` | Vault root token — `myroot` (dev mode default) |
| `VAULT_ADDR_EXTERNAL` | Vault URL as seen from AIX — `http://<pvm2-fqdn>:8200` |
| `POWERSC_URL` | pvm1 FQDN for the "Open PowerSC" links |
| `NEXT_PUBLIC_POWERSC_URL` | Same as above, prefixed for Next.js client-side access |
| `API_PORT` | Express backend port — default `3002` |

## Development (local, no IBM Power env)

The UI builds and runs fine locally. Without a real env, the API calls will fail — the
UI will show error states, which is expected behaviour.

```bash
npm install
npm run dev        # Next.js on :3001
npm run server:dev # Express on :3002 (in separate terminal)
```
