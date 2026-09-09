# Use Case 1 — IBM Power / Security / "150 Certificates. 24 Hours. No Spreadsheet."
## Bob MODE: pre-sales-demo (Pre-Sales Demo Builder mode)
## SKILL: powersc-vault-story-builder

**Build Path:** Platform Reality Demo — IBM PowerSC infrastructure + live Vault certificate issuance + Carbon Web Application

Why this is a strong platform reality demo: IBM PowerSC monitors the full certificate estate on IBM Power AIX hosts continuously, and HashiCorp Vault replaces multi-year-old manually-tracked certificates with 24-hour automatically-rotated ones — live, in front of the customer, on real infrastructure. The "aha" moment is the side-by-side transformation: 287+ days → 24 hours, 67% compliance → 98%, in a single scan. The audience can see the numbers change both in the PowerSC GUI and in the dedicated Carbon Design System demo web application.

Cluster: Security & Compliance · Industry: Customisable per engagement (default: enterprise Oracle/SAP on AIX; worked example: UK manufacturing/distribution) · Output shape: Next.js + Carbon Design System web app (port 3001) + Live PowerSC before/after scan + Vault PKI issuing 24-hour certificates + 150 synthetic certificates replaced on AIX target

> **Build path guardrail.** The deliverable is real IBM PowerSC showing real certificate data on a real AIX host. If PowerSC is not running or the AIX client is not registered, the demo has no before/after. A screenshot of PowerSC with hardcoded numbers is not this demo. The value is the live scan transformation — that requires the TechZone environment.

---

### EXECUTIVE NARRATIVE

Imagine you are a CISO at a manufacturing company. It is Monday morning. Your team runs SAP and Oracle on IBM Power AIX — critical, revenue-generating workloads.

Your certificate estate is managed in a spreadsheet. Hundreds of certificates. Most of them years old. Nobody is quite sure when the next one expires. Last year, one did — and a production system went down for four hours.

You have read about the JLR incident — £1.9 billion in losses, a five-week shutdown, 5,000 supply chain businesses affected. The initial exploit vector was PKI infrastructure. Certificates.

Your Legal team keeps asking whether you are quantum-safe ready. You do not have an answer.

This demo compresses that conversation into 20 minutes on real hardware.

The goal is not to sell a security product.

The goal is to show that IBM PowerSC — running on the infrastructure you already own — can give you continuous visibility of your certificate estate, and that HashiCorp Vault can automate the entire lifecycle so the spreadsheet becomes irrelevant.

---

### USE CASE DESCRIPTION

The pitch in one line:

> "IBM PowerSC monitors your certificate estate continuously; HashiCorp Vault replaces your oldest, weakest certificates with 24-hour automated ones — and you can see the compliance score improve live."

This is a before/after platform reality demo. The PowerSC Quantum Inventory Report shows the estate at two moments: before (150 certificates averaging 287+ days old, ~67% compliance) and after (150 Vault-issued certificates, 24 hours old, ~98% compliance, quantum-safe ready). The transformation is triggered by a single script run. The PowerSC rescan is what the audience watches.

The architecture is deliberately minimal — three nodes, no orchestration layer — because the story is about continuous monitoring meeting automated issuance on infrastructure the client already runs.

- **Carbon Design System Web App & Express Backend on RHEL/Power (pvm2)** — the customer-facing interface running on port 3001 (Next.js frontend) and port 3002 (Express API + WebSocket). Provides interactive narrative views: `/customer` (JLR case study and personas), `/challenge` (baseline risk & weak cert trigger), `/solution` (automated Vault PKI deployment step), and `/results` (before/after comparison table & ROI/avoided downtime calculator).
- **IBM PowerSC (pvm1)** — the monitoring and compliance layer. Quantum Inventory Report scans the AIX endpoint for certificate age, cryptographic strength, and quantum-safe readiness. This is the evidence layer.
- **HashiCorp Vault on RHEL/Power (pvm2)** — PKI engine running in rootless Podman, Power-native container image. Issues 24-hour certificates via a configured role. No native ppc64le binary exists — the container is the correct deployment path.
- **AIX client (pvm3)** — the workload simulation. 150 synthetic certificates representing SAP and Oracle paths under `/opt`. These are the certificates PowerSC scans and Vault replaces.

The land-and-expand line: this three-node architecture is the pattern for a production certificate lifecycle management layer on any IBM Power estate running enterprise workloads.

---

### PRE-LOADED PRESET SCENARIOS

**The generic baseline (use this for any customer):**

The 150 synthetic certificates represent a plausible enterprise estate:
- `/opt/sap/` — SAP application layer certificates
- `/opt/oracle/` — Oracle database and listener certificates
- `/opt/integration/` — middleware and integration endpoint certificates
- `/opt/loadbalancer/` — load balancer and proxy certificates
- `/opt/proxy/` — outbound proxy certificates

All certificates are synthetic (generated by `scripts/generate-old-certificates.sh`). No real customer data, no real PKI, no real hostnames. Certificate validity dates are backdated to create the "before" state — 287+ day average age with weak cryptographic parameters.

**Worked example — UK manufacturing/distribution (internal reference only):**

The recipe was developed using a UK manufacturing/distribution company as the internal worked example. This company runs IBM Power E980 servers with SAP and Oracle. The IBM Consulting Advantage analysis identified: low cyber risk appetite stated in annual report, six Power servers in scope, Audit Committee cyber governance, distributed depot network paralleling a JLR-style supply chain risk. The personas used were IT Director and CFO/Audit Committee chair.

> **Important:** This worked example is a private internal reference showing how to apply IBM Consulting Advantage research to this demo. It must not appear in customer-facing content unless you have explicit permission. Use it as the substitution map template, then replace every detail with the target customer's context.

---

### PREPARATION

**Required:**
- IBM Bob with the `pre-sales-demo` mode and the `powersc-vault-story-builder` skill
- IBM VPN active throughout — the TechZone `cecc.ihost.com` / `pok-systems.techzone.ibm.com` domain is IBM-intranet only
- A PowerSC TechZone reservation (v1 — manual reservation required; Bob cannot automate this)
  - Search TechZone for "PowerSC" → look for the collection that provides PowerSC + RHEL + AIX + IBM i
  - One reservation gives you four nodes: pvm1 (PowerSC), pvm2 (RHEL/Vault + Carbon Web UI), pvm3 (AIX), pvm4 (IBM i, unused)
- Private SSH key downloaded from the TechZone reservation details page
- SSH client (OpenSSH — not PuTTY, which has key-format issues)

**Key Endpoints Once Deployed:**
- **Demo Carbon Web App:** `http://<pvm2>:3001` (Customer story, interactive triggers, & results dashboard)
- **PowerSC Server UI:** `https://<pvm1>` (Live compliance & Quantum Inventory Report)
- **HashiCorp Vault UI:** `http://<pvm2>:8200` (PKI engine & certificates)

**Optional:**
- IBM Consulting Advantage access — for the story tailoring phase (PROMPT #1). Without it, you can still tailor the story manually using the substitution map.

**Environment variables** (kept in a gitignored `.env`):

```bash
POWERSC_HOST=p<NNNN>-pvm1.p<NNNN>.cecc.ihost.com
VAULT_HOST=p<NNNN>-pvm2.p<NNNN>.cecc.ihost.com
AIX_HOST=p<NNNN>-pvm3.p<NNNN>.cecc.ihost.com
SSH_KEY_PATH=<path-to-downloaded-key-file>
DEMO_MODE=mock
```

> Set `DEMO_MODE=live` once your TechZone environment is Ready and SSH connectivity is confirmed.

---

### PROMPT #1 — Tailor the story for your customer (no infrastructure needed)

> **This is the step that separates a generic demo from a conversation.** Do this before touching any infrastructure. The story phase uses IBM Consulting Advantage to research the target customer and produce a substitution map — replacing all internal worked-example content with the customer's industry, personas, workload mix, and risk language. The JLR case study is a reusable public anchor; keep it unless a better-fit public example exists for the customer's sector.
>
> **Honest adaptation note:** PROMPT #1 produces no running software. For this recipe, "mock mode" means producing tailored talking points, a substitution map, and a demo script — all of which can be reviewed and rehearsed without a TechZone environment. The demo itself requires live infrastructure; that is not a gap, it is the point. A mock UI with fake certificate numbers does not prove PowerSC monitors real estates.

Use the **Pre-Sales Demo Builder** mode and the **powersc-vault-story-builder** skill.

```text
Use the Pre-Sales Demo Builder mode and the powersc-vault-story-builder skill.

I am preparing the PowerSC + Vault certificate security demo for a client engagement.

Client context:
- Company: [client name]
- Industry: [industry]
- Audience in the room: [e.g. CISO, IT Director, CFO, Audit Committee]
- Key themes for this client: [e.g. regulatory compliance, quantum readiness, supply chain risk]
- IBM products they already use: [e.g. IBM Power, AIX, specific software]
- Known workloads on IBM Power: [e.g. SAP, Oracle, CICS, other]

Using IBM Consulting Advantage, research this client and produce:

1. A substitution map — for each piece of internal worked-example content in the demo,
   give me the client-specific replacement:
   - Company name and industry framing
   - Personas (titles and relevant risk concerns)
   - Workload framing (which of SAP / Oracle / integration / loadbalancer / proxy paths
     are most credible for this client)
   - A public risk case study that fits their sector better than JLR if one exists,
     or confirm JLR is the right anchor

2. Tailored talking points for each demo phase (BEFORE / Vault introduction /
   AFTER) using the client's language and risk context

3. A DEMO_SCRIPT.md tailored to this client with:
   - Speaker lines for each phase referencing their specific context
   - Suggested order and emphasis based on the audience
   - Lines for handling likely objections from each persona
   - A suggested "what next" close

4. Confirm that no internal worked-example content remains in any customer-facing material

DEMO_MODE=mock
```

**Stop point:** You should now have a `DEMO_SCRIPT.md` and a substitution map. Read through it — every line should be plausible for the target client. If any generic or internal placeholder language survives, ask Bob to replace it. Once this is clean, proceed to PROMPT #2 to reserve the TechZone environment.

---

### PROMPT #1A — Understand the architecture before your environment is ready (optional)

> This prompt is for presenters who want to understand the demo deeply before their TechZone environment is provisioned, or for rehearsing the talking points without live infrastructure.

Use the **Pre-Sales Demo Builder** mode and the **powersc-vault-story-builder** skill.

```text
Use the Pre-Sales Demo Builder mode and the powersc-vault-story-builder skill.

I need to understand the PowerSC + Vault demo before I present it. My TechZone
environment is not ready yet.

1. Walk me through the three-node architecture — pvm1 (PowerSC), pvm2 (Vault on RHEL),
   pvm3 (AIX with certificates) — and explain what breaks if any one is missing.

2. Explain what the PowerSC Quantum Inventory Report actually shows:
   - What is "quantum-safe readiness" and why does it matter?
   - What makes a certificate score badly vs well in PowerSC?
   - What is the compliance score calculation — what moves it from 67% to 98%?

3. For each demo phase (Setup / BEFORE / Vault intro / Takeover / AFTER), give me:
   - The exact UI path I follow
   - The exact talking point I say out loud
   - The one thing the audience should be looking at

Format as a DEMO_PREP.md I can open on a second monitor during the demo.
```

**Stop point:** You should now have `DEMO_PREP.md` on disk with per-phase guidance. Read it. If any step description surprises you or you cannot picture the UI path, ask Bob to clarify before you are in front of a client.

---

### PROMPT #2 — Reserve the TechZone environment and preflight

> **This is a v1 TechZone environment — Bob cannot make the reservation automatically.** The reservation takes ~5 minutes to complete and ~15–30 minutes to provision.

Reserve manually:
1. Go to TechZone and search for "PowerSC"
2. Find the collection that provides: PowerSC server + RHEL client + AIX client + IBM i client
3. Reserve it. Once Ready, note the FQDNs for pvm1, pvm2, and pvm3, and download the private SSH key.

Then run the preflight:

```text
Use the Pre-Sales Demo Builder mode and the deploy-powersc-vault-power skill.

My TechZone PowerSC environment is Ready. Run a preflight check before I deploy.

Environment:
- PowerSC host (pvm1): p<NNNN>-pvm1.p<NNNN>.cecc.ihost.com
- Vault host (pvm2):   p<NNNN>-pvm2.p<NNNN>.cecc.ihost.com
- AIX host (pvm3):     p<NNNN>-pvm3.p<NNNN>.cecc.ihost.com
- SSH key path:        <path-to-downloaded-key-file>

For each host, check:
1. SSH connectivity — confirm I can reach it and report the OS/architecture
2. pvm1 — confirm PowerSC service is running and the UI is reachable on port 8443
3. pvm2 — confirm architecture is ppc64le, check available disk (need 5 GB+) and RAM
4. pvm3 — confirm it is AIX and that /opt exists

Give me a green/red report per host. If anything is red, tell me exactly what to do
before I proceed to PROMPT #3.

DEMO_MODE=live
```

**Stop point:** You need a clean green report on all three hosts before deploying. The most common red result is SSH connectivity — see Known Issues for the host key conflict workaround. Do not proceed to PROMPT #3 until all checks are green.

---

### PROMPT #3 — Deploy Vault, set up PowerSC, and verify the demo

```text
Use the Pre-Sales Demo Builder mode and the deploy-powersc-vault-power skill.

All preflight checks are green. Deploy the full demo stack.

Environment:
- PowerSC host (pvm1): p<NNNN>-pvm1.p<NNNN>.cecc.ihost.com
- Vault host (pvm2):   p<NNNN>-pvm2.p<NNNN>.cecc.ihost.com
- AIX host (pvm3):     p<NNNN>-pvm3.p<NNNN>.cecc.ihost.com
- SSH key path:        <path-to-downloaded-key-file>
- SSH username:        cecuser

Run the full deployment in this order:

1. RHEL/Vault & Demo UI (pvm2):
   - Apply fapolicyd trust remediation
   - Install and start Vault container (Power-native image: icr.io/ppc64le-oss/vault-ppc64le:v1.14.8)
   - Configure Vault PKI — enable secrets engine, create root CA, create sap-oracle role (max_ttl 24h)
   - Set up systemd user service and loginctl linger so Vault survives SSH session close
   - Install Node.js & build/start the Carbon Design System Web App (`ui` directory) on port 3001 & backend on port 3002
   - Test certificate issuance: vault write pki/issue/sap-oracle common_name="test.local" ttl=24h
   - Report: Demo Web UI reachable at http://<pvm2>:3001 ✅ / ❌
   - Report: Vault UI reachable at http://<pvm2>:8200 ✅ / ❌

2. AIX (pvm3):
   - Transfer and run scripts/generate-old-certificates.sh
   - Confirm 150 synthetic certificates are in place under /opt
   - Report: certificate count per path (sap / oracle / integration / loadbalancer / proxy)

3. PowerSC UI (pvm1) — guide me through these manual steps:
   a. Log in to https://<pvm1> — accept self-signed cert
   b. Endpoint Admin → Keystore Requests → select pvm3 → Generate Keystore → wait for status "yes"
   c. Endpoint Admin → Endpoints tab → wait for pvm3 to appear as Active/Connected
   d. Select pvm3 → Quantum safe scan configuration → check only:
      sap, oracle, integration, loadbalancer, proxy (NOT /opt/freeware)
   e. Trigger initial scan

4. Capture the BEFORE state:
   - Reports → Quantum Inventory Report (or equivalent path)
   - Confirm certificates show ~287+ day average age
   - Confirm compliance score ~67%
   - Report the exact numbers you see

5. Run the replacement:
   - Transfer and run scripts/replace-with-vault-certificates.sh on pvm3
   - Confirm all 150 certificates are replaced

6. Trigger PowerSC rescan and capture AFTER state:
   - Confirm certificates show ~24 hour age
   - Confirm compliance score ~98%
   - Report the exact numbers you see

Tell me when the before/after transformation is confirmed and I can start presenting.

DEMO_MODE=live
```

**Stop point:** You should see: Vault issuing certificates ✅, 150 old certificates on AIX ✅, PowerSC BEFORE scan showing ~67% compliance ✅, replacement run ✅, PowerSC AFTER scan showing ~98% compliance ✅. Total elapsed from starting this prompt: ~30–45 minutes. If any step fails, paste the error to Bob — the deploy skill has documented workarounds for all known failure modes.

---

### EXPECTED OUTPUT

**pvm2 — Vault & Demo Web UI running on RHEL/Power:**
- Demo Web App accessible at `http://<pvm2>:3001` (Next.js Carbon UI) and API at `http://<pvm2>:3002`
- Vault container running via Podman (`podman ps` shows vault container)
- Vault UI accessible at `http://<pvm2>:8200`
- PKI secrets engine enabled at `pki/`
- Role `sap-oracle` configured with `max_ttl=24h`
- systemd user service enabled (`systemctl --user status vault` shows active)

**pvm3 — AIX with certificates:**
- 150 synthetic certificates under `/opt/sap/`, `/opt/oracle/`, `/opt/integration/`, `/opt/loadbalancer/`, `/opt/proxy/`
- Before state: average age 287+ days, RSA 1024 or weak SHA parameters
- After state: 150 Vault-issued certificates, 24h TTL, RSA 2048, SHA-256

**pvm1 — PowerSC scans:**
- AIX client (pvm3) registered and Active in Endpoint Admin
- Quantum safe scan paths configured (sap, oracle, integration, loadbalancer, proxy)
- BEFORE Quantum Inventory Report: ~67% compliance, certificates ~287+ days
- AFTER Quantum Inventory Report: ~98% compliance, certificates ~24 hours

**Documentation generated:**
- `DEMO_SCRIPT.md` — tailored to your customer (from PROMPT #1)
- `DEMO_PREP.md` — per-phase architecture briefing card (from PROMPT #1A, optional)

---

### DEMO SCRIPT

**Pre-demo setup (10 minutes before):**
- IBM VPN must be active
- Browser tab 1: Demo Web UI at `http://<pvm2>:3001` — confirm it loads (`/customer`, `/challenge`, `/solution`, `/results`)
- Browser tab 2: PowerSC UI at `https://<pvm1>` — confirm it loads and pvm3 shows Active
- Browser tab 3: Vault UI at `http://<pvm2>:8200` — confirm it loads
- Have `DEMO_SCRIPT.md` open on a second monitor or printed
- Brief the audience: *"Everything you're about to see is running on IBM Power. This is the actual PowerSC monitoring platform, actual HashiCorp Vault, and an interactive Carbon demonstration interface. We're going to replace 150 certificates live."*

**Step 1 — Open PowerSC and show the BEFORE state (3 min)**

Navigate to the Quantum Inventory Report. Point out: certificate ages averaging 287+ days, compliance score ~67%, quantum-safe status not ready. Let the numbers land. Say: *"This is what your estate looks like today. Every one of these is a potential attack window. JLR's PKI estate looked like this before the incident."*

**Step 2 — Show Vault (2 min)**

Switch to the Vault UI. Show the PKI secrets engine and the `sap-oracle` role. Say: *"Vault is configured to issue 24-hour certificates. It is the certificate authority. When we flip to Vault, the spreadsheet becomes irrelevant — there is nothing to track manually because nothing lives long enough to go stale."*

**Step 3 — Run the replacement (3 min)**

In the Demo Web UI (`/solution`), click the automated **Deploy / Replace Certificates** button (or run `scripts/replace-with-vault-certificates.sh` via SSH). Show the progress and live output as certificates are replaced — 150 of them, one Vault API call per cert. Say: *"In production, this runs on a schedule. No human intervention. Every certificate rotates automatically."*

**Step 4 — Trigger PowerSC rescan and show the AFTER state (3 min)**

Trigger a scan from the Demo Web UI (or from the PowerSC UI on the AIX endpoint). Wait. Refresh the Quantum Inventory Report or Results page (`/results`). Show the transformation: 24 hours, ~98% compliance, quantum-safe ready. Say: *"Same platform. Same IBM Power infrastructure you already own. The only thing that changed is automation."*

**Step 5 — Client questions and close (5 min)**

Hand the conversation to the customer. Let them ask about their specific workloads. Say: *"PowerSC gives you the visibility. Vault gives you the automation. Together, they eliminate the category of risk that took JLR five weeks and £1.9 billion to recover from. And this architecture slots directly into the Power estate you are already running."*

---

### SAMPLE PROMPTS / INPUTS

**1. Vault certificate issuance (live terminal, shown to audience)**
```bash
vault write pki/issue/sap-oracle \
    common_name="sap.customer.local" \
    ttl=24h \
    format=pem
```
*Expected: Certificate issued in <1 second. Output shows `expiration` timestamp 24 hours from now. Copy the `certificate` and `private_key` fields.*

**2. Verify BEFORE state on AIX**
```bash
find /opt/sap /opt/oracle /opt/integration /opt/loadbalancer /opt/proxy \
    -name "*.pem" -o -name "*.crt" | wc -l
```
*Expected: 150. If different, re-run `generate-old-certificates.sh`.*

**3. Verify AFTER state on AIX**
```bash
openssl x509 -in /opt/sap/sap-app-001.pem -noout -dates
```
*Expected: `notAfter` is ~24 hours from when `replace-with-vault-certificates.sh` was run.*

---

### WHAT GOOD LOOKS LIKE

A strong run should feel like watching a compliance officer's workload disappear in real time.

It should:
- Show a genuine compliance score change in the PowerSC UI — not a hardcoded number, an actual scan result reflecting the actual certificates on the AIX host
- Issue Vault certificates that are visibly 24-hour TTL (`openssl x509 -noout -dates` confirms it)
- Complete the full replacement of 150 certificates without manual intervention on AIX
- Show the PowerSC rescan discovering all new Vault certificates — demonstrating that PowerSC's continuous monitoring picks up the change automatically
- Correctly decline to scan `/opt/freeware` — that path contains OS binaries, not workload certificates, and scanning it produces noise not signal

The output should not just be "security looks better."

It should answer:

> "Can IBM PowerSC, running on the infrastructure I already own, give me continuous visibility of my certificate estate — and can HashiCorp Vault automate the lifecycle so that a JLR-style PKI incident cannot happen to me?"

---

### KNOWN ISSUES & WORKAROUNDS

**Issue: SSH host key conflict — connection fails with "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED"**
- **Cause:** TechZone reuses FQDNs across reservations. Your SSH `known_hosts` file holds the old host key.
- **Workaround:** `ssh-keygen -R <fqdn>` on your laptop before the first SSH attempt to a new reservation.
- **Impact:** None once cleared. Affects the first SSH attempt to a recycled FQDN only.

---

**Issue: No native ppc64le HashiCorp Vault binary**
- **Cause:** HashiCorp does not publish a ppc64le binary for Vault. The official distribution is x86-only.
- **Workaround:** Use the Power-native container image: `icr.io/ppc64le-oss/vault-ppc64le:v1.14.8` via rootless Podman. This is the correct and supported deployment path for IBM Power.
- **Impact:** Vault runs inside a container rather than as a native binary. No functional difference for demo purposes.

---

**Issue: Podman not pre-installed on fresh RHEL TechZone image**
- **Cause:** The base RHEL TechZone image does not include Podman.
- **Workaround:** `sudo dnf install -y podman` — this is step 1 of the deploy skill and runs in <2 minutes.
- **Impact:** None if running via the deploy skill, which handles this automatically.

---

**Issue: fapolicyd blocks Podman or npm on RHEL host**
- **Cause:** fapolicyd (file access policy daemon) may be enabled on hardened RHEL images and blocks unrecognised binaries including Podman and Node.js.
- **Workaround:** The deploy skill runs fapolicyd trust remediation as an idempotent first step. If blocked manually: `sudo fapolicyd-cli --file add /usr/bin/podman && sudo systemctl restart fapolicyd`.
- **Impact:** None if running via the deploy skill.

---

**Issue: Vault container exits when the SSH session closes**
- **Cause:** Rootless Podman containers do not persist after logout unless configured to do so.
- **Workaround:** Enable the systemd user service (`systemctl --user enable vault`) and set `loginctl enable-linger cecuser`. The deploy skill does both automatically.
- **Impact:** If not set, Vault will be down after the next SSH disconnect. Always verify `vault status` before starting the demo.

---

**Issue: Vault dev mode loses PKI configuration on container restart**
- **Cause:** Vault dev mode uses in-memory storage. A restart wipes all configuration.
- **Workaround:** Re-run `scripts/vault-pki-setup.sh` after any restart. This is idempotent.
- **Impact:** PKI must be reconfigured. Takes ~2 minutes via the deploy skill.

---

**Issue: AIX client (pvm3) not appearing in PowerSC Endpoint Admin after keystore generation**
- **Cause:** There is a ~2–5 minute propagation delay after keystore generation before the endpoint registers.
- **Workaround:** Wait 5 minutes and refresh. If still not appearing, check PowerSC agent status on pvm3: `ssh cecuser@<pvm3> "lssrc -s powersc_agent"`.
- **Impact:** Demo cannot proceed to scan phase until pvm3 shows Active. Allow 10 minutes for setup before starting the live demo clock.

---

**Issue: PowerSC quantum safe scan path — `/opt/freeware` produces noise**
- **Cause:** `/opt/freeware` contains IBM AIX Toolbox binaries (curl, sed, bash etc.) which have their own certificates unrelated to workload PKI.
- **Workaround:** In the quantum safe scan configuration, check only the specific subdirectories: `sap`, `oracle`, `integration`, `loadbalancer`, `proxy`. Do not check the `/opt` parent or `/opt/freeware`.
- **Impact:** If `/opt/freeware` is included, the scan results include OS tooling certificates which inflate the count and distort the before/after comparison.

---

**Issue: TechZone environment provisioning fails on RHEL load (known intermittent)**
- **Cause:** The PowerSC TechZone collection has experienced intermittent failures during RHEL node provisioning (2 confirmed failures noted in RECIPE-JOURNEY.md). Root cause not confirmed.
- **Workaround:** If pvm2 does not provision correctly, raise a new reservation. Keep the old FQDN noted so you can clear it from `known_hosts` if it is reused.
- **Impact:** Adds 15–30 minutes. Reserve the environment the day before a client demo where possible.

---

### EXECUTIVE TAKEAWAY

At the end of this demo, the takeaway should be simple:

> "Your IBM Power infrastructure already has everything you need to eliminate certificate-related outages and achieve quantum-safe readiness — PowerSC gives you the visibility, Vault gives you the automation, and together they make the spreadsheet irrelevant."

This is not a proof of concept. The three-node architecture shown in this demo — PowerSC monitoring, Vault PKI, AIX workload target — is the production pattern for certificate lifecycle management on any IBM Power estate running enterprise workloads. The demo runs on actual IBM PowerSC and actual Vault. What you saw is what a production deployment looks like.

---

### ADDITIONAL MATERIAL

- Demo execution guide (detailed click-path): [`docs/DEMO-EXECUTION-GUIDE.md`](docs/DEMO-EXECUTION-GUIDE.md)
- Full deployment guide: [`docs/DEPLOYMENT-GUIDE.md`](docs/DEPLOYMENT-GUIDE.md)
- Vault setup reference: [`docs/VAULT-SETUP-GUIDE.md`](docs/VAULT-SETUP-GUIDE.md)
- AIX scripting reference: [`docs/AIX-SCRIPTING-BEST-PRACTICES.md`](docs/AIX-SCRIPTING-BEST-PRACTICES.md)
- Development log: [`RECIPE-JOURNEY.md`](RECIPE-JOURNEY.md)
- Collection README: [`COLLECTION.md`](COLLECTION.md)
- TechZone collection: Search TechZone for "PowerSC" → select the collection with PowerSC + RHEL + AIX + IBM i
- Deployment scripts: [`scripts/generate-old-certificates.sh`](scripts/generate-old-certificates.sh), [`scripts/replace-with-vault-certificates.sh`](scripts/replace-with-vault-certificates.sh), [`scripts/vault-pki-setup.sh`](scripts/vault-pki-setup.sh)
- Related recipe: [`../Carbon-GenAI-IBM-Power/01-Carbon-GenAI-IBM-Power.md`](../Carbon-GenAI-IBM-Power/01-Carbon-GenAI-IBM-Power.md)
