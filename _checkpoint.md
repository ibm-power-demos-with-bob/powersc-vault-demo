# Checkpoint — PowerSC + Vault IBM Power Recipe

> Last updated: 2026-09-09

---

## Status

**Recipe aligned to official Bob Recipe Template. End-to-end TechZone verification passed on live reservation.**
- Podman installed and Vault container deployed on RHEL (pvm02 / ppc64le).
- Vault PKI configured with Root CA and `sap-oracle` role.
- 150 synthetic weak certificates generated on AIX (pvm03) and replaced with 24h Vault certs with full validation.
- Demo Carbon UI & Express Backend deployed and running on RHEL (pvm02) on port 3001 (`/challenge`, `/solution`, `/results`, `/customer`).
- Script fixes applied: AIX 7.3 Python3 JSON extraction handles literal newlines without crashing.
- Environment reset to "BEFORE" state (150 weak certs on AIX) ready for live presentation scan.

---

## What has been done

| Session | Key output |
|---|---|
| Jun–Jul 2026 | Demo environment built. Vault deployed on ppc64le via Podman. 150 synthetic certificates on AIX. PowerSC scanning confirmed. DEMO-EXECUTION-GUIDE.md written. |
| Aug 2026 | Recipe structure started. RECIPE.md frontmatter + COLLECTION.md written. Skills and mode created. TechZone environment noted as v1 (manual reservation required). |
| Sep 2026 | Full recipe brief written: `01-PowerSC-Vault-IBM-Power.md` aligned to official template — all sections complete (exec narrative, 3-prompt chain, demo script, sample inputs, what good looks like, known issues, executive takeaway). RECIPE.md Quick Start updated to reference the brief and the 3-prompt flow. |
| 2026-09-09 | **Live Reservation End-to-End Verification**: Tested on TechZone reservation `pvm01/02/03-731cq22k` (RHEL 9.8 + AIX 7.3). Installed Podman, launched Vault container (`icr.io/ppc64le-oss/vault-ppc64le:v1.14.8`), verified PKI setup, fixed AIX JSON parsing in `replace-with-vault-certificates.sh`, verified 150 cert replacement with 24h Vault certs, reset back to BEFORE state. |

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

1. **Run PROMPT #3 end-to-end from a clean TechZone reservation** — validate the 3-prompt chain works as written; log any new failures to Known Issues in `01-PowerSC-Vault-IBM-Power.md`
2. **Record Level 3 Stand and Deliver** — use the demo script in `01-PowerSC-Vault-IBM-Power.md` § DEMO SCRIPT
3. **Open PR to CE Marketplace** — target: `ClientEngineering/bob` → `Recipes/PowerSC-Vault-IBM-Power/`
   - `01-PowerSC-Vault-IBM-Power.md`
   - `README.md` (one-paragraph blurb)

---

## Starting a new task

Paste this into the first message:

```
We are working on the PowerSC + Vault IBM Power recipe for the CE Marketplace.
Read _checkpoint.md for full context.

Current status: recipe brief (01-PowerSC-Vault-IBM-Power.md) written and aligned to the
official template. Next step is running PROMPT #3 end-to-end from a clean TechZone
reservation to validate the deploy flow and log any new Known Issues.

[Describe what you are doing next — e.g. TechZone reservation ready, or recording the Stand and Deliver, or opening the PR.]
```
