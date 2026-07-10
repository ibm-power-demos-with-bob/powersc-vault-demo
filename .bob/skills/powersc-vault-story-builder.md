---
name: powersc-vault-story-builder
description: >
  Guide a seller through the customer story customisation phase of the PowerSC + Vault
  IBM Power demo. Covers IBM Consulting Advantage research workflow, extracting business
  context from customer documents, replacing Howdens-specific language, adapting the
  JLR case study for other industries, and tailoring the five demo acts per audience persona.
---

# Skill: PowerSC + Vault Customer Story Builder

## When to Use This Skill

Activate this skill at the **start of a new customer engagement** — before the seller
touches any infrastructure. The story phase should be complete before the TechZone
reservation is even made.

The seller has a customer in mind. They may have a meeting coming up, or they may be
exploring whether this demo is the right fit. This skill helps them answer that question
and, if yes, tailor the demo so it speaks the customer's language.

## The Core Story Structure

The demo has five acts that must be adapted per customer:

| Act | What happens | Customer-specific element |
|-----|-------------|--------------------------|
| **1. The Problem** | PowerSC shows old, weak certificates across a complex estate | Use customer's actual system names, workload types, or infrastructure language |
| **2. The Risk** | A real-world certificate-based attack is referenced | Find an industry-relevant incident; JLR works for UK manufacturing/distribution |
| **3. The Solution** | Vault PKI is introduced as the certificate authority | Position against customer's current manual process |
| **4. The Takeover** | Vault issues new certificates; they are deployed to AIX | Frame as "automated lifecycle" matching customer's operational priorities |
| **5. The Transformation** | PowerSC AFTER scan shows dramatic improvement | Connect the metrics (98% compliance, 24h cert age) to customer's stated priorities |

## Step 1: Ask the Seller Three Questions

Before any research, ask:

1. **Who is the audience?** (e.g., CISO and security architects, IT director, Audit Committee, mixed executive + technical)
2. **What industry?** (This determines which risk case study is most relevant)
3. **What do you already know about their pain?** (Any recent incidents, audit findings, manual processes, compliance pressure)

If the seller has already done IBM Consulting Advantage research, ask them to share the
key findings. If not, recommend it as the next step.

## Step 2: IBM Consulting Advantage Research (Optional but Highly Recommended)

IBM Consulting Advantage can read and extract insights from customer documents — annual
reports, financial statements, press releases, investor presentations.

Guide the seller to:

1. Open IBM Consulting Advantage
2. Upload or link the customer's most recent annual report (publicly available for listed companies)
3. Ask Consulting Advantage to identify:
   - **Business priorities and strategic initiatives** (what the board is focused on)
   - **Cybersecurity language** (how they describe their risk appetite, existing controls)
   - **Operational criticality** (what systems/processes cannot afford downtime)
   - **Key personas** from the organisational structure (named roles, board committees)
   - **Compliance and governance frameworks** mentioned (ISO 27001, NIST, industry-specific)
   - **Supplier and partner relationships** (supply chain dependencies)

The Howdens worked example extracted:
- "low appetite for cyber security risk" — board-level mandate
- Six IBM Power E980 servers running SAP ERP
- 100+ key suppliers requiring secure data exchange
- Audit Committee oversight of cyber governance
- "Built for the Trade" — brand promise tied to 24/7 depot availability
- Active supply chain transformation (adding urgency to security automation)

## Step 3: Build the Tailored Talking Points

With research findings in hand, build a tailored version of each demo act.

### Finding the Right Risk Case Study (Act 2)

The JLR case study (August 2025, £1.9B loss, PKI exploitation, five-week shutdown) is
compelling for UK manufacturing, automotive, trade supply, and any company with a complex
supply chain. Use it when the customer has:
- Distributed operations or depot/factory networks
- SAP or Oracle on IBM Power
- Supply chain dependencies (they are a hub in a wider ecosystem)
- A "business continuity is critical" mandate

For other industries, find an equivalent:
- **Financial services:** Certificate mismanagement leading to trading outage or regulatory breach
- **Healthcare:** Certificate expiry causing clinical system downtime
- **Telecoms:** PKI exploitation in network infrastructure
- **Public sector/utilities:** Critical infrastructure certificate-based attack

The structure of the case study is always:
> "In [month/year], [organisation] suffered [business impact] when [attackers / failure mode]
> exploited their PKI/certificate infrastructure. [Number] of [downstream entities] were affected.
> Recovery took [duration]. Your organisation has a similar risk profile because [parallel factor].
> The difference is, we can proactively eliminate this attack vector."

### Replacing Howdens-Specific Language

The demo scripts and documentation use Howdens-specific names:
- `howdens.local` — internal domain names in certificates (invisible to audience, can remain)
- "Howdens' SAP and Oracle landscape" — replace with customer's actual workloads
- "depot network" → replace with customer's operational footprint (branches, factories, sites)
- "trade customers" → replace with customer's end customers or users
- "Built for the Trade" → replace with customer's own brand promise or SLA
- Jackie Callaway (CFO), Richard Sutcliffe (IT Director) → replace with real or representative personas
- "Audit Committee" → replace with appropriate governance body

Create a simple substitution map before the demo:

| Howdens term | This customer term |
|-------------|-------------------|
| depot network | [their operational footprint] |
| SAP on E980 | [their workloads on Power] |
| supply chain | [their equivalent] |
| "low appetite for cyber security risk" | [their own stated risk posture] |
| Audit Committee | [their governance body] |

### Tailoring by Audience Persona

**For a CISO / Head of Security:**
Lead with the technical attack vector and the PowerSC monitoring capability. Show them
the Vault PKI configuration. Use the compliance score numbers. Mention quantum safety
readiness.

**For a CIO / IT Director:**
Lead with the operational story — certificate-related outages, manual spreadsheet tracking,
the automation narrative. Show the before/after transformation. Connect to their IT roadmap.

**For a CFO / Audit Committee:**
Lead with the business risk case study (£1.9B equivalent for their industry). Show the
compliance reporting output from PowerSC. Frame as risk reduction and governance evidence.

**For a mixed executive + technical audience:**
Open with the business risk case study (executives engage immediately). Drop into the
technical live demo. Close with the compliance dashboard (executives re-engage).

## Step 4: Produce the Tailored Talking Point Set

Output a structured document for the seller containing:

1. **Opening statement** (30 seconds) — customer-specific, using their language
2. **Risk case study** (2 minutes) — industry-relevant incident
3. **BEFORE talking points** — what to say while showing PowerSC before state
4. **Solution narrative** — what to say while introducing Vault
5. **AFTER talking points** — what to say while showing PowerSC after state
6. **Closing** (30 seconds) — connects back to their stated priority

This document is what the seller rehearses, not the generic demo script.

## The Howdens Worked Example (Reference)

The Howdens engagement demonstrates the full process:

**Research source:** IBM Consulting Advantage analysis of Howdens 2025 Annual Report

**Key extractions:**
- "low appetite for cyber security risk" (board-level mandate, their exact words)
- Six IBM Power E980 servers running SAP — critical to depot ordering
- 100+ key supplier relationships — supply chain risk is board concern
- Audit Committee receives regular cyber governance updates
- "Built for the Trade" brand promise = 24/7 depot availability is non-negotiable

**Risk case study selected:** JLR August 2025 — £1.9B losses, PKI exploitation, five-week shutdown, 5,000+ suppliers affected. Relevant because: UK manufacturer, complex supply chain, distributed operations, PKI exploitation is the attack vector.

**Substitution map applied:**
- depot network = hundreds of UK depot locations
- SAP on E980 = actual Howdens SAP workload (confirmed from annual report)
- "low appetite for cyber security risk" = kept verbatim (their own words)

**Result:** A demo narrative where every talking point connects to something Howdens
documented in their own annual report. The audience recognises their own language.

## When This Demo is NOT the Right Fit

This demo works best when:
- The customer runs critical workloads on IBM Power (AIX, RHEL, or IBM i)
- They have SAP, Oracle, or similar enterprise workloads with certificate dependencies
- Certificate management is manual or partially manual
- Business continuity is a board-level concern
- They have compliance or governance reporting requirements

Consider a different demo when:
- The customer has no IBM Power infrastructure
- Their certificate management is already fully automated (Vault or similar)
- The audience is primarily cloud-focused (this is an on-prem / IBM Power story)
- The primary conversation is about AI or application modernisation (use Carbon GenAI demo instead)
