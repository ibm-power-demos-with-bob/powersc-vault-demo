# From Demo to Recipe — PowerSC + HashiCorp Vault on IBM Power

> This document captures the journey of turning the PowerSC + HashiCorp Vault certificate
> management demo into a Client Engineering Bob Marketplace recipe. It is a living record —
> written as decisions are made, constraints discovered, and steps completed — so the
> rationale is preserved for anyone who picks this up later.
>
> The Howdens engagement is the origin story and the worked example. The recipe is designed
> so any seller can re-run the story phase for their own customer before touching infrastructure.

---

## What We Are Building

A **Bob Marketplace recipe** that lets a seller or CE:

1. **Tailor the customer story** — guided by Bob using IBM Consulting Advantage research on
   the customer's annual report or public documents, replacing Howdens-specific language with
   their customer's industry, personas, and risk language.
2. **Deploy the demo environment** — Bob drives Vault deployment via SSH onto the RHEL host
   in a fresh TechZone reservation. The seller completes the required PowerSC UI steps
   (documented in the skill).
3. **Run the demo** — before/after PowerSC scan showing aged weak certificates replaced by
   24-hour Vault-issued certificates.

The end state is:
- A seller opens Bob, activates the recipe collection, describes their client context
- Bob guides them through the IBM Consulting Advantage story step (~15–30 minutes)
- Seller makes one manual TechZone reservation (~5–10 minutes, ~30 minute wait)
- Bob deploys Vault via SSH onto the RHEL host (~5 minutes)
- Seller completes the PowerSC UI steps (~10 minutes)
- Demo is ready to run — before/after transformation in ~15 minutes of live demo

---

## Why This Demo, Why IBM Power

This demo shows **IBM PowerSC + HashiCorp Vault automating certificate lifecycle management
on IBM Power** — transforming manually-tracked, multi-year-old certificates into short-lived
(24-hour) automatically-rotated certificates, with continuous compliance monitoring.

The story is deliberately built around:
- **Real business risk** — certificate-based attack vectors (JLR £1.9B case study)
- **IBM Power's security posture** — PowerSC, PowerVM minimal hypervisor attack surface,
  hardware-based security (Secure Boot, HSM, TPM)
- **A partner integration story** — IBM + HashiCorp showing open ecosystem approach
- **A before/after transformation** — credible, measurable, audience-visible

This is a **Platform Reality demo** — it runs on actual IBM PowerSC and actual Vault. No
mock UIs, no simulated data except the certificate files on the AIX target.

The Howdens worked example was built using IBM Consulting Advantage analysis of the Howdens
2025 Annual Report. The recipe codifies this as the first step for any new customer.

---

## Key Constraints and Decisions

### 1. TechZone v1 — automated reservation is not possible today

The PowerSC TechZone collection is a **v1 TechZone environment**. The Bob TechZone MCP
only supports v2 API collections. This means Bob cannot make the reservation on the
seller's behalf.

**Decision:** The manual reservation step is explicitly documented and kept short. The
recipe instructions make this the one human gate, with Bob driving everything else.

One reservation provides all required nodes:
- **PowerSC server** (pvm1) — PowerSC UI and scan engine
- **RHEL on Power** (pvm2) — HashiCorp Vault host
- **AIX client** (pvm3) — certificate target (SAP/Oracle simulation)
- **IBM i** (pvm4) — unused in this demo

### 2. Vault runs as a Power-native container, not a native binary

HashiCorp does not provide a current native `ppc64le` Vault binary on their release pages.
A Power-native container image is available at `icr.io/ppc64le-oss/vault-ppc64le:v1.14.8`.

**Decision:** Vault runs via rootless Podman as `cecuser` on the RHEL host. This is
documented in the skill with the correct framing ("Power-native container deployment model").

### 3. fapolicyd on the RHEL host may block Podman

The RHEL host in the PowerSC TechZone reservation comes pre-hardened with `fapolicyd`
(file access policy daemon) active. This enforces an allow-list for executable files and
shared libraries. OCI container runtimes (`crun`, `runc`, `conmon`) are not in the default
trust list and will fail silently.

**Decision:** The deployment skill includes a fapolicyd trust remediation step that must
be run before attempting to start any container. This is a known-good sequence documented
from the Howdens engagement.

### 4. Hardcoded IPs replaced with variables

The original scripts and docs referenced specific IPs (`129.40.59.194`, `129.40.59.195`,
`129.40.59.193`) tied to the expired Howdens reservation. These have been replaced with
environment variable references (`$VAULT_HOST`, `$AIX_HOST`, `$POWERSC_HOST`), set from
the FQDNs provided by the new TechZone reservation.

### 5. vault-pki-setup.sh uses jq — fixed for recipe

The original `vault-pki-setup.sh` used `jq` for JSON parsing and the Vault CLI directly.
For the recipe, this script runs on the RHEL host (which has the Vault CLI available inside
the container), so Vault CLI via `podman exec` is the correct pattern. The `jq` dependency
has been removed.

### 6. AIX scripting: no jq, no grep -o, curl + sed only

All scripts that run on AIX (`generate-old-certificates.sh`, `replace-with-vault-certificates.sh`)
use only POSIX-compatible tooling. See the AIX scripting skill for full rules.

### 7. The story phase is the first step, not the last

Unlike a generic demo toolkit where the seller customises after deployment, this recipe
makes the **customer story re-baking the first step**. The seller should not touch
infrastructure until they know what industry, personas, and risk language they will use.
This is because the demo's entire credibility depends on the narrative — the certificates
and the compliance numbers are secondary to the story.

---

## Environment Architecture

```
TechZone PowerSC Reservation (all nodes in one reservation)
│
├── pvm1 — PowerSC Server
│   └── PowerSC UI (HTTPS) — scan engine, compliance reports
│
├── pvm2 — RHEL on Power (Vault Host)
│   └── Vault (rootless Podman, port 8200)
│       └── PKI engine — issues 24-hour certificates
│
├── pvm3 — AIX Client (Certificate Target)
│   └── /opt/sap, /opt/oracle, /opt/integration, /opt/loadbalancer, /opt/proxy
│       └── 150 synthetic old certificates (CA bundle extracts, 2008–2011)
│
└── pvm4 — IBM i (unused in this demo)
```

```
Demo Flow:
  PowerSC scans pvm3 → shows 150 old certificates (BEFORE)
  Vault on pvm2 issues 150 new 24h certificates
  replace-with-vault-certificates.sh deploys them to pvm3
  PowerSC rescans pvm3 → shows 150 fresh certificates (AFTER)
```

---

## Bob Recipe Assets

### 1. Deployment Skill (`deploy-powersc-vault-power`)
Everything Bob needs to deploy and operate this demo:
- TechZone environment topology
- SSH key authentication pattern
- Vault deployment via rootless Podman (Power-native container)
- fapolicyd trust remediation sequence
- Vault PKI configuration via `podman exec`
- AIX certificate deployment scripts
- PowerSC UI manual steps (documented as human gates)
- Demo reset procedure (re-generate old certs → re-run before/after cycle)
- Common failure modes and recovery

### 2. Story-Phase Skill (`powersc-vault-story-builder`)
Instructs Bob how to guide a seller through customer story customisation:
- IBM Consulting Advantage workflow
- What to extract from annual reports / public documents
- How to replace Howdens-specific language
- The JLR case study as a reusable template
- Adapting the five demo acts per persona

### 3. Seller Mode (IBM Power Security Demo)
Pre-Sales Demo Builder persona extended for this demo:
- Knows the PowerSC + Vault story
- Can narrate the before/after transformation for an audience
- Knows how to guide deployment from scratch
- Understands when this demo is the right fit vs. other IBM security stories

### 4. Collection (`powersc-vault-ibm-power`)
Bundles the skills + mode. Collection README is the one page a seller reads to
understand what they are deploying and why, and how the Howdens worked example
can be adapted for their customer.

---

## Deployment Log

| Date | Event |
|------|-------|
| 2026-06-03 | Original demo plan created using Pre-Sales Demo Builder mode with IBM Consulting Advantage research on Howdens 2025 Annual Report |
| 2026-06-08 | `vault-pki-setup.sh` written — initial version using Vault CLI directly |
| 2026-06-09 | `generate-old-certificates.sh` and `replace-with-vault-certificates.sh` written using AIX-compatible curl + sed pattern |
| 2026-06-09 | `fapolicyd` blocking Podman discovered on PowerSC RHEL host — trust remediation procedure documented in `ibm-power-pre-sales-demo-skills.md` |
| 2026-06-09 | Vault confirmed running via rootless Podman using `icr.io/ppc64le-oss/vault-ppc64le:v1.14.8` |
| 2026-06-09 | Vault PKI configured; certificate issuance confirmed from AIX via curl REST API |
| 2026-06-09 | `VAULT-SETUP-GUIDE.md` written documenting the Podman-based deployment path |
| 2026-07-10 | Recipe journey started — hardcoded IPs parameterised, Bob skills authored, COLLECTION.md written |

---

## Open Items

- [x] Document origin engagement (Howdens, IBM Consulting Advantage, demo plan)
- [x] Document Vault deployment path (rootless Podman, Power-native container)
- [x] Document fapolicyd remediation pattern
- [x] Document AIX scripting constraints
- [x] Parameterise hardcoded IPs → environment variables
- [x] Write `RECIPE-JOURNEY.md`
- [x] Convert existing skills to `.bob/skills/` format
- [x] Write `deploy-powersc-vault-power` skill
- [x] Write `powersc-vault-story-builder` skill
- [x] Write `COLLECTION.md`
- [x] Write IBM Power Security Demo mode
- [ ] **Handoff test** — tester reserves fresh TechZone PowerSC environment and runs recipe end-to-end
- [ ] Validate fapolicyd remediation sequence on fresh reservation (may differ from Howdens env)
- [ ] Confirm `icr.io/ppc64le-oss/vault-ppc64le:v1.14.8` image still available and pulls cleanly
- [ ] Test `generate-old-certificates.sh` on fresh AIX instance (CA bundle path may vary)
- [ ] Validate full before/after cycle: generate → scan → replace → rescan
- [ ] Determine correct marketplace repo target (EMEA or default CE marketplace) and submit

---

## Handoff Test Checklist

Work through this in order on a completely fresh TechZone reservation. Note any failures
in the Deployment Log above and open a GitHub issue.

### Phase 1 — Story (do this before any infrastructure work)

- [ ] Open Bob and activate the `powersc-vault-ibm-power` collection
- [ ] Bob is in IBM Power Security Demo mode
- [ ] Describe your customer to Bob — industry, any known pain points, role of the audience
- [ ] Bob guides you through IBM Consulting Advantage research (optional but recommended)
- [ ] Bob produces a tailored talking point set replacing Howdens-specific language
- [ ] You are satisfied the story matches your customer before proceeding

### Phase 2 — Environment

> **Note on FQDNs:** Every TechZone reservation gets unique FQDNs. The ones used during
> initial development (`p1229-pvm1/2/3`) are tied to an expired reservation. You need
> your own reservation. FQDNs follow the pattern `p<NNNN>-pvm<N>.p<NNNN>.cecc.ihost.com`.
>
> If SSH complains about a host key conflict, clear the stale entry:
> ```bash
> ssh-keygen -R <old-fqdn>
> ```

- [ ] New TechZone PowerSC reservation created (search TechZone for "PowerSC")
- [ ] Environment status is **Ready** (provisioning takes ~15–30 minutes)
- [ ] FQDNs noted for all four VMs (pvm1 = PowerSC, pvm2 = RHEL, pvm3 = AIX, pvm4 = IBM i)
- [ ] Private SSH key downloaded from reservation details page
- [ ] SSH connectivity confirmed to pvm2 (RHEL): `ssh -i <keyfile> cecuser@<pvm2-fqdn> "uname -m"` → `ppc64le`
- [ ] SSH connectivity confirmed to pvm3 (AIX): `ssh -i <keyfile> cecuser@<pvm3-fqdn> "uname"` → `AIX`

### Phase 3 — Vault Deployment (Bob-driven via SSH)

Tell Bob:
- Your pvm2 FQDN
- Your downloaded SSH key path

Bob should execute the deployment skill steps:

- [ ] fapolicyd trust remediation applied on pvm2
- [ ] Podman confirmed working: `podman run --rm registry.access.redhat.com/ubi9/ubi-minimal echo hello`
- [ ] Vault container started: `podman run -d --name vault -p 8200:8200 ...`
- [ ] Vault health check passes: `curl -s http://localhost:8200/v1/sys/health`
- [ ] Vault PKI configured via `podman exec` (root CA generated, sap-oracle role created)
- [ ] Test certificate issued successfully from pvm2

### Phase 4 — PowerSC UI Steps (manual)

- [ ] PowerSC UI accessible at `https://<pvm1-fqdn>`
- [ ] Login with `powersc-admin` credentials (from TechZone reservation)
- [ ] Keystore generated for pvm3 (AIX client) — Endpoint Admin → Keystore Requests
- [ ] AIX client appears in Endpoints tab (wait 2–5 minutes)
- [ ] Quantum safe scan path configured: `/opt` checkbox enabled for pvm3
- [ ] Initial quantum safety scan triggered and completed

### Phase 5 — Demo Setup (Bob-driven via SSH to AIX)

Tell Bob your pvm3 FQDN and SSH key. Bob should:

- [ ] Transfer `generate-old-certificates.sh` to pvm3
- [ ] Run script with sudo on pvm3
- [ ] Confirm 150 certificates deployed: `ls -la /opt/sap/app01/certs/`
- [ ] Trigger PowerSC rescan from UI
- [ ] Confirm BEFORE state visible: old certificates (2008–2011), weak crypto

### Phase 6 — Demo Run (Before/After Cycle)

- [ ] BEFORE state captured: certificates 15+ years old, compliance ~67%
- [ ] Transfer `replace-with-vault-certificates.sh` to pvm3 (Bob via SSH from pvm2)
- [ ] Set `VAULT_ADDR` to `http://<pvm2-fqdn>:8200` and `VAULT_TOKEN=myroot` on pvm3
- [ ] Run replacement script on pvm3 — confirm 150 certificates replaced
- [ ] Trigger PowerSC rescan
- [ ] AFTER state confirmed: 24-hour certificates, compliance ~98%
- [ ] Before/after delta clearly visible in PowerSC UI

### Phase 7 — Recipe Assets

- [ ] [`RECIPE-JOURNEY.md`](RECIPE-JOURNEY.md) — readable and accurate
- [ ] [`.bob/skills/deploy-powersc-vault-power.md`](.bob/skills/deploy-powersc-vault-power.md) — skill loads correctly
- [ ] [`.bob/skills/powersc-vault-story-builder.md`](.bob/skills/powersc-vault-story-builder.md) — skill loads correctly
- [ ] Deployment skill instructions match actual experience — note any gaps

### Phase 8 — Sign-off

- [ ] Full before/after cycle completed successfully
- [ ] No unrecoverable failures
- [ ] Any new failure modes documented in the Deployment Log
- [ ] Ready for marketplace submission

---

*This document is maintained by the EMEA AI on IBM Power Squad.*
*Built with Bob (AI Assistant).*
