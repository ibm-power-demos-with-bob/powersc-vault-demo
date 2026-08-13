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
  collection_url: https://techzone.ibm.com/collection/power-systems-security-powersc
  infrastructure: systems-onprem
  note: >
    v1 TechZone environment — manual reservation required.
    One reservation provides all four nodes: pvm1 (PowerSC), pvm2 (RHEL/Vault),
    pvm3 (AIX/certificates), pvm4 (IBM i, unused in this demo).
---

# PowerSC + HashiCorp Vault on IBM Power — Certificate Security Demo

For full setup instructions, see [`COLLECTION.md`](COLLECTION.md).

For the development journey, decisions, and deployment log, see [`RECIPE-JOURNEY.md`](RECIPE-JOURNEY.md).

## Quick Start

1. **Story phase** — Tell Bob: *"I want to use the PowerSC + Vault recipe. My customer is [name/industry/audience]."*
2. **Reserve** the PowerSC TechZone collection (manual, ~5 min effort + ~20 min wait)
3. **Deploy** — Tell Bob your pvm2 FQDN and SSH key path. Bob deploys Vault.
4. **Setup** — Complete the PowerSC UI steps (Bob guides you through each one).
5. **Demo** — Before/after PowerSC scan showing 150 certificates transformed.

**Total human effort:** ~30 minutes. **Total elapsed:** ~60 minutes.
