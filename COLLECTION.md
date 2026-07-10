# PowerSC + HashiCorp Vault on IBM Power — Demo Collection

> **One-sentence pitch:** Show your customer how IBM PowerSC + HashiCorp Vault transforms
> manual, multi-year-old certificate management into automated, 24-hour certificate
> lifecycle — with a live before/after on actual IBM Power infrastructure.

---

## What This Is

A pre-sales demo that proves IBM PowerSC's ability to continuously monitor certificate
health on IBM Power, combined with HashiCorp Vault's automated certificate issuance —
turning a significant security risk into a measurable, visible improvement.

The demo runs on a **real TechZone environment** using **actual IBM PowerSC** and **actual
Vault**. There is no mock UI. The credibility comes from showing real platforms, real
certificate issuance, and real monitoring.

**Audience:** CISOs, security architects, IT Directors, compliance and audit teams at
organisations running critical workloads on IBM Power.

**Best fit:** Organisations with SAP, Oracle, or similar enterprise workloads on IBM Power
(AIX or RHEL), where certificate management is manual or partially manual.

---

## The Demo Story

**The Problem:** Your customer has hundreds of certificates spread across SAP and Oracle
systems on IBM Power. Many are years old, issued with weak cryptography. Manual tracking
via spreadsheets leads to outages and compliance failures.

**The Risk:** Certificate-based attacks are real and costly. In August 2025, JLR suffered
£1.9B in losses when attackers exploited their PKI infrastructure, triggering a five-week
shutdown affecting 5,000 businesses in their supply chain.

**The Solution:** HashiCorp Vault issues short-lived (24-hour) certificates. IBM PowerSC
monitors the certificate estate continuously. Together, they eliminate the attack surface
and provide governance-ready compliance reporting.

**The Wow Moment:** Side-by-side PowerSC scans showing certificates go from 15 years old
(weak, manual, ~67% compliant) to 24 hours old (automated, quantum-safe, ~98% compliant).

---

## What Is Included

| Asset | Purpose |
|-------|---------|
| `deploy-powersc-vault-power` skill | Tells Bob how to deploy Vault via SSH and configure PKI |
| `powersc-vault-story-builder` skill | Tells Bob how to help you customise the story for your customer |
| `ibm-power-vault-podman` skill | Vault on ppc64le via rootless Podman + fapolicyd remediation |
| `ibm-power-aix-scripting` skill | AIX-compatible scripting rules (curl, sed, no jq) |
| IBM Power Security Demo mode | Seller persona — knows the story, drives deployment |
| `scripts/generate-old-certificates.sh` | Deploys 150 synthetic old certificates to AIX |
| `scripts/replace-with-vault-certificates.sh` | Replaces all 150 with Vault-issued 24h certificates |
| `scripts/vault-pki-setup.sh` | Configures Vault PKI via podman exec |
| `RECIPE-JOURNEY.md` | Full living log of decisions, bugs found, and deployment history |
| `docs/DEMO-EXECUTION-GUIDE.md` | Step-by-step demo script and talking points |

---

## Before You Start — The Story Phase

**Do this before you touch any infrastructure.**

This demo was built for Howdens Joinery using IBM Consulting Advantage research on their
2025 Annual Report. Every talking point was extracted from Howdens' own words.

For your customer, ask Bob (in IBM Power Security Demo mode) to:
1. Help you research your customer using IBM Consulting Advantage
2. Replace Howdens-specific language with your customer's industry, personas, and risk language
3. Find the right risk case study for their industry (the JLR case study works for UK
   manufacturing / distribution; other industries need their own equivalent)

The story phase takes 15–30 minutes. It is the single biggest factor in whether the demo
lands or falls flat.

---

## Infrastructure Requirements

One TechZone reservation provides everything needed:

| Node | Role | What runs there |
|------|------|----------------|
| pvm1 | PowerSC server | PowerSC UI — scan engine, compliance reports |
| pvm2 | RHEL on Power | HashiCorp Vault (rootless Podman) |
| pvm3 | AIX client | 150 synthetic certificates |
| pvm4 | IBM i | Unused |

**TechZone collection:** Search for "PowerSC" on TechZone. Look for a collection that
includes PowerSC server + RHEL + AIX + IBM i clients.

This is a **v1 TechZone environment** — Bob cannot make the reservation on your behalf.
The reservation takes ~5 minutes to fill out and ~15–30 minutes to provision.

**Important:** Download your private SSH key from the TechZone reservation details page.
Bob uses the SSH key (not the password) for all automated steps.

---

## How to Run This Recipe

### Step 1: Story Phase (15–30 minutes, no infrastructure needed)

```
Tell Bob:
  "I want to use the PowerSC + Vault recipe. My customer is [name/industry/audience]."

Bob will:
  - Activate the IBM Power Security Demo mode
  - Guide you through IBM Consulting Advantage research
  - Produce tailored talking points for your customer
```

### Step 2: Reserve TechZone Environment (5 minutes + 15–30 minute wait)

Reserve the PowerSC TechZone collection (v1 — manual reservation required).
When the environment is Ready, note:
- FQDNs for pvm1 (PowerSC), pvm2 (RHEL/Vault), pvm3 (AIX)
- Private SSH key (download from reservation details)
- PowerSC admin credentials (from reservation details)

### Step 3: Deploy Vault (Bob-driven, ~10 minutes)

```
Tell Bob:
  "My pvm2 FQDN is <fqdn>. My SSH key is at <path>. Deploy Vault."

Bob will:
  - Apply fapolicyd trust remediation on pvm2
  - Start the Vault container (Power-native image)
  - Configure Vault PKI via podman exec
  - Test certificate issuance
```

### Step 4: PowerSC UI Setup (manual, ~10 minutes)

In your browser:
- Generate keystores for the AIX client
- Configure `/opt` as the quantum safe scan path
- Run initial scan

(Bob will guide you through exactly which buttons to click.)

### Step 5: Deploy Old Certificates (Bob-driven, ~3 minutes)

```
Tell Bob: "Deploy the old certificates to AIX."

Bob will:
  - Transfer and run generate-old-certificates.sh on pvm3
  - Confirm 150 certificates are in place
```

### Step 6: Demo Ready

- Trigger PowerSC scan → capture BEFORE state
- Run replace-with-vault-certificates.sh → Vault replaces all 150 certificates
- Trigger PowerSC rescan → capture AFTER state
- Demo your story

**Total elapsed time:** ~60 minutes (mostly waiting for TechZone provisioning).
**Total human effort:** ~30 minutes.

---

## Resetting for Another Run

To repeat the before/after cycle:

```
Tell Bob: "Reset the demo for another run."

Bob will run generate-old-certificates.sh again on pvm3.
Then trigger a PowerSC scan from the UI to confirm BEFORE state.
```

---

## The Howdens Worked Example

The initial demo was built for Howdens Joinery (UK kitchen and joinery supplier):

- **IBM Consulting Advantage input:** Howdens 2025 Annual Report
- **Key extractions:** "low appetite for cyber security risk", six IBM Power E980 servers
  running SAP, 100+ key suppliers, Audit Committee cyber governance oversight
- **Risk case study:** JLR August 2025 PKI exploitation — £1.9B losses, five-week shutdown,
  5,000 suppliers affected — parallels Howdens' distributed depot network and SAP dependency
- **Demo personas:** Richard Sutcliffe (IT Director), Jackie Callaway (CFO + Audit Committee)

This worked example is preserved in [`docs/hashicorp-vault-powersc-demo-plan.md`](docs/hashicorp-vault-powersc-demo-plan.md)
as a reference for how to apply IBM Consulting Advantage research to this demo.

---

## Known Issues and Constraints

| Issue | Mitigation |
|-------|-----------|
| TechZone v1 — Bob cannot auto-reserve | Manual reservation (~5 minutes effort) |
| No native ppc64le Vault binary | Power-native container `icr.io/ppc64le-oss/vault-ppc64le:v1.14.8` |
| Podman not pre-installed on fresh RHEL 9.6 | `sudo dnf install -y podman` — first line of Step 2 in deployment skill |
| fapolicyd may block Podman on RHEL host | Trust remediation in deployment skill (Step 2) — idempotent, safe to run always |
| Vault container exits when SSH session closes | Use systemd user service (`systemctl --user enable vault`) + `loginctl enable-linger` |
| AIX scripting — no jq, no grep -o | curl + sed patterns in all scripts; PATH fix for `/opt/freeware/bin` |
| Vault dev mode loses config on restart | Re-run PKI setup if container restarts |
| git clone hooks error on hardened RHEL | `git clone --template="" <url>` |
| npm install blocked by fapolicyd | `npm install --ignore-scripts` |
| CA bundle path varies on AIX | Check `openssl version -d`; update `CA_BUNDLE` in generate script if needed |
| Quantum safe scan — do not select all of `/opt` | Check only `sap`, `oracle`, `integration`, `loadbalancer`, `proxy` — not `/opt/freeware` |

---

## Related Demos

| Demo | Story | When to use |
|------|-------|------------|
| **Carbon GenAI on IBM Power** | On-prem AI / data sovereignty | AI capability, data residency, regulated industries |
| **PowerSC + Vault (this demo)** | Automated certificate security | Security posture, compliance, certificate risk |

Both run on TechZone IBM Power environments and can be installed together as a complementary
IBM Power pre-sales toolkit.

---

*Maintained by the EMEA AI on IBM Power Squad.*
*Built with Bob (AI Assistant).*
