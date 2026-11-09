# Checkpoint — PowerSC + Vault IBM Power Recipe

> Last updated: 2026-11-09 (session 3 — full rebuild on new reservation)

---

## Status

**2026-11-09 rebuild: demo rebuilt from scratch on a NEW Demo-purpose reservation `<env-key>` (request `<demo-request-id>`, ends 2026-11-13 12:45 UTC). BEFORE state verified (150 weak certs, PowerSC scan complete). UI live on pvm02:3001. The reservation details below under "Previous status" refer to the OLD reservation `<old-env-key>`, which is no longer valid.**

### Previous status (old reservation <old-env-key>)

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
| 2026-09-09 | **Live Reservation End-to-End Verification**: Tested on TechZone reservation `pvm01/02/03-<env-key>` (RHEL 9.8 + AIX 7.3). Installed Podman, launched Vault container (`icr.io/ppc64le-oss/vault-ppc64le:v1.14.8`), verified PKI setup, fixed AIX JSON parsing in `replace-with-vault-certificates.sh`, verified 150 cert replacement with 24h Vault certs, reset back to BEFORE state. |
| 2026-09-09 | **Demo flow refactored**: Moved cert deploy + PowerSC keystore + endpoint bootstrap + initial scan from UI button into `setup.sh` (steps 14–16). `setup.sh` now requires `--powersc-pass`. Challenge page now shows BEFORE scan results on load (no setup button). `setup.js` route and `/api/setup` removed from Express backend. `generate-old-certificates.sh` now accepts `SCAN_FOLDER` env var. |
| 2026-09-10 | **UI persistence fix**: Added `scripts/start-ui.sh` — uses `setsid nohup` for both Express backend and Next.js frontend. Survives SSH disconnects and TechZone SIGHUP/SIGTERM signals without needing systemd. `deploy-ui.sh` updated to call this as Step 7. To restart after a drop: `bash scripts/start-ui.sh`. |
| 2026-09-10 (2) | **Full end-to-end debug and fix session**: (1) Challenge page refactor synced to remote and rebuilt. (2) PowerSC scan folder fixed — `quantumSafe.properties` written on pvm03 pointing at `~/demo-certs`; agent restarted. (3) Vault replace script was running with `sudo` which reset PATH and hid `/opt/freeware/bin/curl` — fixed with `sudo: false` in `vault.js`. (4) Missing `channel-ora.pem` in replace script (was generated but never replaced) — added, cert count updated to 151. (5) Scan time display updated to show date+time. (6) All changes committed to GitHub (`280847b`). (7) Recipe submitted to Florian for CE Marketplace review. |
| 2026-11-09 | **Rebuild from scratch on new reservation.** Reserved PowerSC Lab (platform `6a8f57b95f542b07f9121623`) as purpose=Demo with opportunity code (4-day window). A first MCP-created Test request (`<test-request-id>`) was made by mistake and appeared stuck/failed (user's observation; Bob did not verify its final state — confirm it is cancelled in the TechZone UI); **user's view: manual TechZone reservations are more reliable than MCP auto-reservation.** Ran `scripts/setup.sh` on pvm02 (SSH user `<os-user>`, key `.ssh/id_rsa_techzone`, gitignored): Vault + PKI, Node 20, repo clone, UI build/start, 150 weak certs to AIX, PowerSC keystore/agent bootstrap, BEFORE scan (150 weak certs confirmed via API). **setup.sh fixes made (local, NOT yet committed to GitHub):** removed hardcoded `cecuser` (now `$(whoami)`/`$HOME`); `NODE_MAJOR` detection no longer aborts under `set -e` when node is absent; Step 3 stops the vault systemd unit before re-creating the container (port 8200 clash on re-run). |

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
| Environment type | v1 — manual reservation recommended (MCP auto-reservation worked but see 2026-11-09 note) |
| TechZone collection | https://techzone.ibm.com/collection/powersc-hands-on/environments |
| Active reservation | request `<demo-request-id>`, env key `<env-key>`, Demo, expires 2026-11-13 12:45 UTC |
| Demo Web UI (pvm02) | `http://pvm02-<env-key>.<pNNN>.pok-systems.techzone.ibm.com:3001` |
| PowerSC Server (pvm01) | `https://pvm01-<env-key>.<pNNN>.pok-systems.techzone.ibm.com` (<ip>) |
| Vault Host (pvm02) | `pvm02-<env-key>.<pNNN>.pok-systems.techzone.ibm.com` (<ip>), Vault UI :8200 |
| AIX Client (pvm03) | `pvm03-<env-key>.<pNNN>.pok-systems.techzone.ibm.com` (<ip>) |
| IBM i (pvm04) | `pvm04-<env-key>.<pNNN>.pok-systems.techzone.ibm.com` (<ip>) — unused |
| OS User / SSH Key | `<os-user>` / `.ssh/id_rsa_techzone` (gitignored) |
| PowerSC GUI Login | `powersc-admin` / password on the TechZone reservation page (post-deploy notes) — not stored here |
| Old reservation (invalid) | `<old-env-key>` / `<old-env-key>` |

---

### SESSION 3 HANDOFF (2026-11-09) - READ FIRST

**State:** Demo is rebuilt and live on a Demo-purpose TechZone reservation (BEFORE state verified in UI). This folder is now a git clone of `origin/main` (`ibm-power-demos-with-bob/powersc-vault-demo`, PUBLIC repo) with the work COMMITTED and PUSHED (session 4, commit 60af3c1, fast-forward, no force). User wants this folder to become the new `main` (their code is the authority); do not force-push; commit on top of existing history; ask before pushing.

**What the staged change does:** removes every per-deployment value (OS user, hostnames, PowerSC password) from scripts/docs/skills; new `scripts/lib-env.sh` reads them from `ui/.env.local`; `setup.sh` fixed for fresh boxes (no Node installed, no hardcoded user, Vault re-run port clash); restores the 21 `.bob/` + `docs/` files that were missing locally; adds `.gitattributes` (LF for .sh); customer page is Danish NIS2 content (intentional per user).

**Pre-commit checks (all DONE, session 4):**
1. Mojibake: found in `scripts/setup.sh` and `ui/.env.local.example` only; repaired (UTF-8 -> cp1252 bytes -> UTF-8). setup.sh diff vs origin/main is now ~26 lines. Rescan of all staged files clean.
2. `generate-old-certificates.sh` / `replace-with-vault-certificates.sh`: ~300 changed lines confirmed as the `*.howdens.local` -> `*.infrastructure.local` CN rename (also removes a customer name from the public repo). Intended.
3. Secrets scan on staged content clean; `bash -n` passes on all 27 scripts (Git bash on Windows); no CRs in staged .sh files.

**Then (remaining):**
- Pushed to origin/main as 60af3c1 (session 4, user approved, fast-forward). Old commits on the public repo still contain EXPIRED TechZone passwords; history scrub is the user's call.
- Verify the published script end-to-end: on pvm02 run `bash scripts/setup.sh` pulled from GitHub (push is done, so this is unblocked). Also test AFTER flow (Deploy Vault Certificates -> Run AFTER Scan) on the live reservation.
- CE Marketplace template (https://github.ibm.com/ClientEngineering/bob/tree/main/Recipes/templates) is behind SAML SSO - Bob could not read it. Ask user to paste/export the template files, then compare with RECIPE.md / 01-PowerSC-Vault-IBM-Power.md / COLLECTION.md.

**Live environment (not stored here):** reservation ends 2026-11-13 12:45 UTC. Hosts/user/password are on the TechZone reservation page. Local `.env.local` and `.ssh/id_rsa_techzone` are gitignored. SSH to pvm02 works with the key. UI restart: `bash ~/powersc-vault-demo/scripts/start-ui.sh` on pvm02. The deployed copy on pvm02 was cloned from the OLD published repo plus a locally patched `setup.sh` - it does not have this staged work.

**User housekeeping:** cancel the stray Test request in the TechZone UI; rotate the TechZone API token that was pasted into chat.

### Starting a new task - paste this

```
Read _checkpoint.md "SESSION 3 HANDOFF" first. Repo is a git clone of origin/main with the cleaned-up work pushed (60af3c1). First: verify setup.sh from GitHub on pvm02 and test the AFTER flow.
```


## Next steps

0. ~~**Remove hardcoded OS users/hosts/passwords**~~ Done 2026-11-09: all per-deployment values (hosts, OS user, PowerSC password) now come from `ui/.env.local` via `scripts/lib-env.sh`; no credentials remain in scripts/docs/skills. Note: older commits on GitHub still contain expired TechZone passwords (public repo) - rotate/scrub history if required.
1. ~~**Re-start the UI on pvm02**~~ ✅ Done
2. ~~**Full demo flow verified end-to-end**~~ ✅ Done (BEFORE 0%/150 weak → AFTER 99%+/0 weak)
3. ~~**All fixes committed to GitHub**~~ ✅ Done (commit `280847b`)
4. **Record Level 3 Stand and Deliver** — demo is live and working. Use the Carbon UI (`http://pvm02-<env-key>.<pNNN>.pok-systems.techzone.ibm.com:3001`) + PowerSC GUI. Remember to reset to BEFORE state first (`generate-old-certificates.sh`).
5. **CE Marketplace PR** — Florian has been contacted. Once approved, open PR to `ClientEngineering/bob` → `Recipes/PowerSC-Vault-IBM-Power/` with `01-PowerSC-Vault-IBM-Power.md` and `README.md`.
6. **Collaborate with Samvedna** — share `Power-Security-Discovery-Review-Report.docx` and propose linking the Discovery Assistant to this live TechZone demo.

---

## Starting a new task

Paste this into the first message:

```
We are working on the PowerSC + Vault IBM Power recipe for the CE Marketplace.
Read _checkpoint.md for full context.

Current status: demo rebuilt from scratch on Demo reservation <env-key> (request <demo-request-id>, expires 2026-11-13 12:45 UTC). BEFORE state verified in the UI (0% / 150 weak certs). The AFTER flow (Deploy Vault Certificates -> Run AFTER Scan) has NOT yet been re-tested on this reservation. Local setup.sh fixes are uncommitted. If the UI is down, SSH to pvm02 as <os-user> and run: bash ~/powersc-vault-demo/scripts/start-ui.sh

[Describe what you are doing next — e.g. testing the new setup.sh steps on the live reservation, recording the Stand and Deliver, or preparing the CE Marketplace PR submission.]
```
