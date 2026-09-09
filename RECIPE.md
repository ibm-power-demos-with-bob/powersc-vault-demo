---
name: powersc-vault-ibm-power
title: "PowerSC + HashiCorp Vault on IBM Power — Certificate Security Demo"
description: >
  Deploy a before/after certificate security demo on IBM Power. IBM PowerSC
  monitors certificate health continuously; HashiCorp Vault automates 24-hour
  certificate issuance. Live before/after scan shows 150 aged, weak certificates
  replaced by short-lived Vault-issued certificates — with a real compliance score
  improvement visible in the PowerSC UI. Runs on actual TechZone PowerSC infrastructure.
  No mock UIs, no simulated data.
author: EMEA AI on IBM Power Squad
version: 1.0.0
repository: https://github.com/ibm-power-demos-with-bob/powersc-vault-demo
tags:
  - ibm-power
  - powersc
  - hashicorp-vault
  - certificate-management
  - security
  - compliance
  - quantum-safe
  - aix
  - rhel
  - pre-sales
  - platform-reality-demo
skills:
  - deploy-powersc-vault-power
  - powersc-vault-story-builder
  - ibm-power-vault-podman
  - ibm-power-aix-scripting
  - nodejs-on-rhel-ppc64le
modes:
  - ibm-power-security-demo
techzone:
  collection_url: https://techzone.ibm.com/collection/powersc-hands-on/environments
  infrastructure: systems-onprem
  note: >
    v1 TechZone environment — manual reservation required.
    One reservation provides all four nodes: pvm1 (PowerSC), pvm2 (RHEL/Vault),
    pvm3 (AIX/certificates), pvm4 (IBM i, unused in this demo).
---

# PowerSC + HashiCorp Vault on IBM Power — Certificate Security Demo

For the full recipe brief (prompts, demo script, sample inputs, known issues), see [`01-PowerSC-Vault-IBM-Power.md`](01-PowerSC-Vault-IBM-Power.md).

For full operational setup instructions, see [`COLLECTION.md`](COLLECTION.md).

For the development journey, decisions, and deployment log, see [`RECIPE-JOURNEY.md`](RECIPE-JOURNEY.md).

## Quick Start

1. **Story** — Tell Bob: *"I want to use the PowerSC + Vault recipe. My customer is [name/industry/audience]."* (PROMPT #1 — no infrastructure needed)
2. **Preflight** — Once your TechZone environment is Ready, give Bob the three FQDNs and SSH key path. Bob runs a green/red connectivity report. (PROMPT #2)
3. **Deploy** — Bob deploys Vault on pvm2, loads 150 certificates on pvm3, and guides you through the PowerSC UI setup steps. (PROMPT #3)
4. **Demo** — Before/after PowerSC Quantum Inventory scan: 150 certificates, 287+ days → 24 hours, ~67% → ~98% compliance.

**Total human effort:** ~30 minutes. **Total elapsed:** ~60 minutes (mostly TechZone provisioning).
