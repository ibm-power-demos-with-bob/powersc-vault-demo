# Checkpoint — PowerSC + Vault IBM Power Recipe

> Last updated: 2026-09-10 (session 2)

---

## Status

**Recipe aligned to official Bob Recipe Template. End-to-end TechZone verification passed on live reservation.**
- Podman installed and Vault container deployed on RHEL (pvm02 / ppc64le).
- Vault PKI configured with Root CA and `sap-oracle` role.
- 150 synthetic weak certificates generated on AIX (pvm03) and replaced with 24h Vault certs with full validation.
- Demo Carbon UI & Express Backend deployed and running live on RHEL (pvm02) on port 3001 (`/challenge`, `/solution`, `/results`, `/customer`).
- Script fixes applied: AIX 7.3 Python3 JSON extraction handles literal newlines without crashing.
- Environment reset to "BEFORE" state (150 weak certs on AIX) ready for live presentation scan.
- Reviewed Samvedna's Power Security Opportunity Discovery Assistant PoC and generated integration reports (`.docx` and `.md`).
- **Demo flow simplified**: `setup.sh` now does ALL environment prep (certs, PowerSC keystore, endpoint bootstrap, initial scan). The Challenge page shows BEFORE results on load — no buttons to click. The only UI actions are "Deploy Vault Certificates" and "Run AFTER Scan".
- **UI persistence fixed**: `scripts/start-ui.sh` uses `setsid nohup` for both frontend and backend, so processes survive SSH disconnects and TechZone signals. `deploy-ui.sh` calls this automatically as Step 7.
- **End-to-end demo flow verified on live reservation**: BEFORE (0% / 150 weak) → Deploy Vault Certificates → AFTER (99%+ / 0 weak). All issues resolved and committed to GitHub.
- **Recipe submitted to Florian** for CE Marketplace review.

---

## What has been done

| Session | Key output |
|---|---|
| Jun–Jul 2026 | Demo environment built. Vault deployed on ppc64le via Podman. 150 synthetic certificates on AIX. PowerSC scanning confirmed. DEMO-EXECUTION-GUIDE.md written. |
| Aug 2026 | Recipe structure started. RECIPE.md frontmatter + COLLECTION.md written. Skills and mode created. TechZone environment noted as v1 (manual reservation required). |
| Sep 2026 | Full recipe brief written: `01-PowerSC-Vault-IBM-Power.md` aligned to official template — all sections complete (exec narrative, 3-prompt chain, demo script, sample inputs, what good looks like, known issues, executive takeaway). RECIPE.md Quick Start updated to reference the brief and the 3-prompt flow. |
| 2026-09-09 | **Live Reservation End-to-End Verification**: Tested on TechZone reservation `pvm01/02/03-731cq22k` (RHEL 9.8 + AIX 7.3). Installed Podman, launched Vault container (`icr.io/ppc64le-oss/vault-ppc64le:v1.14.8`), verified PKI setup, fixed AIX JSON parsing in `replace-with-vault-certificates.sh`, verified 150 cert replacement with 24h Vault certs, reset back to BEFORE state. |
| 2026-09-09 | **Demo flow refactored**: Moved cert deploy + PowerSC keystore + endpoint bootstrap + initial scan from UI button into `setup.sh` (steps 14–16). `setup.sh` now requires `--powersc-pass`. Challenge page now shows BEFORE scan results on load (no setup button). `setup.js` route and `/api/setup` removed from Express backend. `generate-old-certificates.sh` now accepts `SCAN_FOLDER` env var. |
| 2026-09-10 | **UI persistence fix**: Added `scripts/start-ui.sh` — uses `setsid nohup` for both Express backend and Next.js frontend. Survives SSH disconnects and TechZone SIGHUP/SIGTERM signals without needing systemd. `deploy-ui.sh` updated to call this as Step 7. To restart after a drop: `bash scripts/start-ui.sh`. |
| 2026-09-10 (2) | **Full end-to-end debug and fix session**: (1) Challenge page refactor synced to remote and rebuilt. (2) PowerSC scan folder fixed — `quantumSafe.properties` written on pvm03 pointing at `~/demo-certs`; agent restarted. (3) Vault replace script was running with `sudo` which reset PATH and hid `/opt/freeware/bin/curl` — fixed with `sudo: false` in `vault.js`. (4) Missing `channel-ora.pem` in replace script (was generated but never replaced) — added, cert count updated to 151. (5) Scan time display updated to show date+time. (6) All changes committed to GitHub (`280847b`). (7) Recipe submitted to Florian for CE Marketplace review. |

---

## Key files

| File | Purpose |
|---|---|
| [`01-PowerSC-Vault-IBM-Power.md`](01-PowerSC-Vault-IBM-Power.md) | **The recipe brief** — aligned to template. This is what gets submitted. |
| [`RECIPE.md`](RECIPE.md) | Frontmatter + Quick Start entry point |
| [`COLLECTION.md`](COLLECTION.md) | Operational reference — infrastructure, architecture, step-by-step setup |
| [`RECIPE-JOURNEY.md`](RECIPE-JOURNEY.md) | Full development log — do not rewrite, only append |
| [`docs/DEMO-EXECUTION-GUIDE.md`](docs/DEMO-EXECUTION-GUIDE.md) | Detailed click-path guide (pre-dates template alignment; linked from recipe brief) |
| [`scripts/generate-old-certificates.sh`](scripts/generate-old-certificates.sh) | Deploys 150 synthetic old certificates to AIX |
| [`scripts/replace-with-vault-certificates.sh`](scripts/replace-with-vault-certificates.sh) | Replaces all 150 with Vault-issued 24h certificates |
| [`scripts/vault-pki-setup.sh`](scripts/vault-pki-setup.sh) | Configures Vault PKI via podman exec |

---

## TechZone reference

| Item | Value |
|---|---|
| Environment type | v1 — manual reservation required |
| TechZone collection | https://techzone.ibm.com/collection/powersc-hands-on/environments |
| Active reservation | `pvm01/02/03-731cq22k` (IPs: .146, .156, .151) |
| Demo Web UI (pvm02) | `http://pvm02-731cq22k.p642.pok-systems.techzone.ibm.com:3001` |
| PowerSC Server (pvm01) | `https://pvm01-731cq22k.p642.pok-systems.techzone.ibm.com` |
| Vault Host (pvm02) | `pvm02-731cq22k.p642.pok-systems.techzone.ibm.com` (129.40.125.156) |
| AIX Client (pvm03) | `pvm03-731cq22k.p642.pok-systems.techzone.ibm.com` (129.40.125.151) |
| OS User / SSH Key | `U5V9KZP` / `.ssh/id_rsa_techzone` |
| PowerSC GUI Login | `powersc` / `(8FPU5dUC4a+P1d` (or `powersc-admin`) |

---

## Next steps

1. ~~**Re-start the UI on pvm02**~~ ✅ Done
2. ~~**Full demo flow verified end-to-end**~~ ✅ Done (BEFORE 0%/150 weak → AFTER 99%+/0 weak)
3. ~~**All fixes committed to GitHub**~~ ✅ Done (commit `280847b`)
4. **Record Level 3 Stand and Deliver** — demo is live and working. Use the Carbon UI (`http://pvm02-731cq22k.p642.pok-systems.techzone.ibm.com:3001`) + PowerSC GUI. Remember to reset to BEFORE state first (`generate-old-certificates.sh`).
5. **CE Marketplace PR** — Florian has been contacted. Once approved, open PR to `ClientEngineering/bob` → `Recipes/PowerSC-Vault-IBM-Power/` with `01-PowerSC-Vault-IBM-Power.md` and `README.md`.
6. **Collaborate with Samvedna** — share `Power-Security-Discovery-Review-Report.docx` and propose linking the Discovery Assistant to this live TechZone demo.

---

## Starting a new task

Paste this into the first message:

```
We are working on the PowerSC + Vault IBM Power recipe for the CE Marketplace.
Read _checkpoint.md for full context.

Current status: demo fully working end-to-end on live TechZone reservation (pvm01/02/03-731cq22k). BEFORE→AFTER flow verified (0%→99%+ compliance). Recipe submitted to Florian for CE Marketplace review. All changes on GitHub (commit 280847b). If the UI is down, SSH to pvm02 and run: bash /home/U5V9KZP/powersc-vault-demo/scripts/_restart-backend.sh && bash /home/U5V9KZP/powersc-vault-demo/scripts/_restart-frontend.sh

[Describe what you are doing next — e.g. testing the new setup.sh steps on the live reservation, recording the Stand and Deliver, or preparing the CE Marketplace PR submission.]
```
