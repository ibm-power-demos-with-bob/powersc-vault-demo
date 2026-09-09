# Review & Collaboration Report: Power Security Opportunity Discovery Assistant & Live Demo Integration

**To:** Peter & Samvedna (IBM Power Security & Technical Sales)  
**From:** Power Technical Sales / Presales Demo Team  
**Subject:** Technical Review of the Discovery Assistant PoC & Integration with Live PowerSC + Vault Demo  
**Date:** March 2026  

---

## 1. Executive Summary & Tool Assessment

We reviewed the **Power Security Opportunity Discovery Assistant** PoC repository and presentation deck. It is a well-engineered React 18 / TypeScript application with an embedded IBM Bob skill (`power-security-discovery`) and 6 modular detection engines (covering PowerSC Hardening, Compliance, Privileged Access, Database Security, Threat Detection, and Lifecycle Risk).

### Key Architectural Findings:
* **Offline / Metadata-Driven:** The tool is **not** an agent installed on customer systems. It runs locally on a seller/technical specialist's workstation or within IBM Bob.
* **Strict Privacy Model:** It operates solely on high-level infrastructure metadata (Power generation, OS/VIOS levels, database types, compliance mandates, and known control flags). It does **not** collect or display hostnames, IP addresses, user credentials, database contents, or PII.

---

## 2. The End-to-End Presales Funnel

The Discovery Assistant fills a critical middle step between initial account research and our live technical demonstrations:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. DISCOVER — IBM Consulting Advantage (Public / Account Research)          │
│    Extracts board priorities, cyber risk appetite, compliance obligations,  │
│    and business context (e.g., Annual Reports, JLR supply chain parallels). │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Business context
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 2. QUANTIFY — Power Security Opportunity Discovery Assistant                │
│    (Samvedna's Tool / Bob Skill)                                            │
│    Maps infrastructure metadata into 6 detection modules.                   │
│    Calculates security pipeline value & recommends target IBM products.     │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Scoped account profile
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ 3. PROVE — Live PowerSC + Vault Demo (TechZone / Platform Reality)          │
│    Executes a live before/after scan on real AIX + Vault PKI infrastructure.│
│    Demonstrates the live transformation (287-day certs ➔ 24h automated certs│
│    and a 67% ➔ 98% compliance jump on real hardware).                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Alignment with Early Account Data (e.g. Howdens Worked Example)

Even high-level information gathered early from public records or initial discovery calls maps directly into Samvedna’s metadata schema:

| Discovery Assistant Attribute | Sample Early / Public Data | Resulting Opportunity & Demo Asset |
| :--- | :--- | :--- |
| **`generation` & `osVersion`** | Power9 / Power10, AIX 7.2 / 7.3 | Scopes the target environment for PowerSC endpoint agent |
| **`databases`** | SAP HANA, Oracle, Db2 | Targets synthetic workload paths (`/opt/sap`, `/opt/oracle`) |
| **`hasManualComplianceReporting`** | `true` (Spreadsheets for PCI/ISO) | Triggers **PowerSC Compliance Automation** ($100k+) |
| **`powerSCDeployed`** | `false` (Baseline estate) | Triggers **PowerSC Hardening** ($150k+) & live before/after scan |
| **`sharedRoot` / `weakAuditing`** | `true` (Pre-hardening baseline) | Triggers **IBM Verify Privilege / MFA Attach** ($115k+) |

---

## 4. Proposed Collaboration Opportunities

1. **Direct Handoff to Live TechZone Demo:**
   Add a *"Launch Live Proof of Value"* action in the Discovery Assistant's Opportunity Report view. When a PowerSC or Compliance gap is detected, it can hand the account profile straight to the live demo builder to generate a tailored 5-act demo script.

2. **Add a Certificate & Quantum Posture Module:**
   Introduce a 7th detection engine for *Certificate Lifecycle & Quantum-Safe Readiness* (detecting manual PKI tracking, long-lived certificates, and post-quantum crypto gaps), which directly attaches **PowerSC + HashiCorp Vault**.

3. **Combined IBM Bob Skillset:**
   Merge the `power-security-discovery` skill with our `powersc-vault-story-builder` skill so sellers can discover gaps, generate executive talking points, and launch the live TechZone demo within a single workflow.
