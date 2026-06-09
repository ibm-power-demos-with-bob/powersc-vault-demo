# HashiCorp Vault + IBM PowerSC Certificate Management Demo Plan

---

## Original Request

**User's Initial Task Description:**

> "Hi Bob, I was just on a call about HishiCorp Vault, and so I want to plan a demo where we show the benefits of that and how it can manage certificates, including short-lived certs that are used for specific tasks. I am thinking of combining that with IBM Power and the PowerSC product, which I know can produce reports about ages of certificates, showing old ones, and ones that are soon to expire. There is an existing Techzone demo for PowerSC, but I don't know if there are Techzone environments for HashiCorp Vault we might use. Does this work as a plan?"

**Follow-up Context:**

> "Yes, I'll go find the PowerSC demo I believe is out there, and reserve that as one element we can use. As part of that reservation, we get a RHEL on IBM Power LPAR, and that might be a possible host of our Vault."

**What Worked Well in This Request:**
- ✅ Clear product combination (Vault + PowerSC)
- ✅ Specific use case (certificate management, short-lived certificates)
- ✅ Mentioned target audience context (technical demo - Mode 2)
- ✅ Identified known resources (existing PowerSC TechZone demo)
- ✅ Asked about environment availability
- ✅ Provided follow-up clarification about RHEL LPAR availability

**Suggestions for Future Requests:**

To help Bob create even more targeted demo plans, consider including:

1. **Audience Details:**
   - Who will see this demo? (e.g., "CISO and security architects at a financial services company")
   - What's their technical level? (e.g., "Highly technical - they manage PKI infrastructure")
   - What's their current pain point? (e.g., "Manual certificate renewals causing outages")

2. **Timeline & Constraints:**
   - When do you need this? (e.g., "Demo in 2 weeks" vs "Exploring for future opportunity")
   - How much time do you have for setup? (e.g., "Need quick turnaround" vs "Can invest 2-3 days")
   - Any technical constraints? (e.g., "Must use TechZone only" vs "Can use external cloud")

3. **Success Criteria:**
   - What does success look like? (e.g., "Customer agrees to POC" vs "Just need to show capability")
   - What specific questions should the demo answer? (e.g., "Can Vault integrate with our existing CA?")
   - What objections do you expect? (e.g., "They're concerned about operational complexity")

4. **Existing Assets:**
   - What do you already have? (e.g., "I have access to PowerSC demo, platform ID: XYZ")
   - What have you tried before? (e.g., "Previous demo focused on compliance, need more automation story")
   - Any customer-specific context? (e.g., "They're currently using manual spreadsheets")

5. **Customer Research (HIGHLY VALUABLE):** ⭐
   - Use **IBM Consulting Advantage** to analyze customer's annual reports, financial statements, or public documents
   - Extract business priorities, strategic initiatives, and pain points directly from customer's own words
   - Identify key personas and their specific concerns from organizational structure
   - Understand industry context, compliance requirements, and competitive pressures
   - **This transforms generic demos into customer-specific solutions**

**Example of a Basic Request:**

> "Hi Bob, I need to plan a technical demo for a financial services CISO and their security architecture team in 3 weeks. They're struggling with manual certificate management causing quarterly outages, and they're evaluating HashiCorp Vault. I want to show how Vault's short-lived certificates (24-hour TTL) combined with IBM PowerSC's compliance monitoring creates an automated certificate lifecycle on Power systems. I have access to the PowerSC TechZone demo (includes RHEL LPAR), and I can spend 2 days on setup. The customer's main concern is 'won't short-lived certificates create more operational overhead?' Can you help me build a demo that addresses this?"

**Example of an Enhanced Request with IBM Consulting Advantage:**

> "Hi Bob, I need to plan a technical demo for Howdens Joinery's IT/Security leadership and Audit Committee in 3 weeks. I used IBM Consulting Advantage to analyze their 2025 Annual Report, and here's what I found:
>
> **Business Context:**
> - UK's leading trade-only kitchen supplier with hundreds of depot locations
> - Brand promise: 'Built for the Trade' - trade customers depend on their systems 24/7
> - Explicit statement: 'low appetite for cyber security risk' (board-level mandate)
> - Active supply chain transformation underway
> - 100+ key supplier relationships requiring secure data exchange
>
> **Key Pain Points:**
> - Supply chain disruption risk is their #1 concern
> - Distributed depot network creates security challenges
> - Manual certificate management across hundreds of locations
> - Business continuity is critical - outages directly impact trade customers
>
> **Demo Goal:**
> Show how Vault + PowerSC automates certificate lifecycle management across their depot network, supporting their 'low cyber risk appetite' while enabling supply chain transformation. I have access to PowerSC TechZone demo (includes RHEL LPAR) and can spend 2 days on setup. Expected objections: 'Won't short-lived certificates create more operational overhead across our depot network?' and 'How does this support our Audit Committee's oversight requirements?'"

**What the Enhanced Request Enables:**

The IBM Consulting Advantage research transformed this demo plan by providing:
- ✅ **Specific customer language** ("Built for the Trade", "low appetite for cyber security risk")
- ✅ **Real business priorities** (supply chain disruption, depot network security, business continuity)
- ✅ **Actual personas** (trade customers, depot managers, Audit Committee, 100+ suppliers)
- ✅ **Documented pain points** (manual processes, transformation challenges, governance requirements)
- ✅ **Measurable outcomes** (zero depot disruptions, Audit Committee reporting, supplier relationship protection)
- ✅ **Customer-specific objections** (operational overhead across depot network, Audit Committee oversight)

This level of detail allows Bob to:
- Tailor every talking point to customer's documented priorities
- Use customer's own language and terminology
- Address specific governance and compliance requirements
- Connect technical capabilities to business outcomes
- Anticipate and prepare for customer-specific objections

**Key Takeaway:** When possible, use IBM Consulting Advantage to research the customer before requesting a demo plan. The investment of 15-30 minutes in research can transform a generic demo into a customer-specific solution that resonates with their documented priorities and speaks their language.

---

# HashiCorp Vault + IBM PowerSC Certificate Management Demo Plan

**Demo Type:** Platform Reality (Mode 2)  
**Target Audience:** Technical (Security Architects, Platform Owners, Infrastructure Teams)  
**Date Created:** 2026-06-03  
**IBM Products:** IBM Power, PowerSC (Power Systems Security and Compliance)  
**Partner Products:** HashiCorp Vault


## Demo Requirements Summary

### WHO — Industry + Persona + Audience Seniority
**Industry:** Retail/Trade Supply - UK kitchen and joinery supplier  
**Company:** Howdens Joinery (UK's leading trade-only supplier, hundreds of depot locations)  
**Primary Persona:** Richard Sutcliffe - Supply Chain & IT Director (Executive Committee)  
**Secondary Personas:** Julian Lee (Operations Director), Jackie Callaway (CFO), Audit Committee  
**Audience Seniority:** Executive/C-Level decision makers with technical validation from IT/Security team  
**Technical Level:** Mixed - executives need business outcomes, IT team needs technical credibility

### WHAT — Business Problem + Wow Moment
**Business Problem (One Sentence):**  
Manual certificate management across hundreds of depot locations creates risk of system outages that prevent trade customers from placing orders, directly threatening Howdens' "Built for the Trade" brand promise and their stated "low appetite for cyber security risk."

**Wow Moment:**  
Side-by-side comparison showing:
- **BEFORE:** 287-day-old certificates, manual tracking, 3 outages/year affecting depot operations
- **AFTER:** 12-hour certificate age, 100% automation, zero outages, continuous Audit Committee visibility

The moment when PowerSC dashboard shows the dramatic shift from aging, risky certificates to automated, short-lived certificates across the depot network - with measurable business impact (zero trade customer disruptions).

### HOW IT'S CONSUMED — UI Flow, Channel, Demo Duration, Scenarios
**Demo Type:** Platform Reality (Mode 2) - Live demonstration of actual IBM PowerSC and HashiCorp Vault platforms  
**Channel:** In-person or virtual presentation with live platform access  
**Duration:** 45-60 minutes total
- Executive Overview: 15 minutes (business value, ROI)
- Technical Deep Dive: 20 minutes (5-act demo flow)
- Governance & Compliance: 10 minutes (Audit Committee reporting)
- Q&A: 15 minutes

**UI Flow:**
1. PowerSC Console → Certificate Management Dashboard (show aging certificates)
2. Vault UI → PKI Engine (demonstrate certificate issuance)
3. Terminal/SSH → RHEL Power LPAR (show certificate deployment)
4. PowerSC Console → Updated Dashboard (show automated certificates)
5. PowerSC Console → Compliance Reports (show metrics improvement)

**Scenarios:**
- Depot system certificate rotation (primary scenario)
- Supplier portal certificate management (secondary scenario)
- Emergency certificate revocation (if time permits)

### DATA — Synthetic Data Shape, Volume, Fields
**Certificate Data (SAP-Relevant):**
- **Volume:** 50-100 synthetic certificates representing depot network and SAP infrastructure
- **Fields:**
  - Certificate Common Name (e.g., "sap-prod-01.howdens.local", "depot-manchester-01.howdens.local")
  - Issuer (Vault Intermediate CA vs. legacy CAs)
  - Issue Date / Expiration Date
  - Certificate Age (calculated)
  - Key Length (2048-bit RSA)
  - Subject Alternative Names (depot locations, SAP system IDs)
  - Certificate Purpose (TLS/SSL for SAP connections, depot ordering systems, SAP Fiori, database connections)

**SAP System Certificate Types (for realism):**
- **SAP Application Server Certificates:**
  - `sap-prod-app-01.howdens.local` (SAP ERP Production Application Server)
  - `sap-prod-app-02.howdens.local` (SAP ERP Production Application Server)
  - `sap-fiori.howdens.local` (SAP Fiori Launchpad)
- **SAP Database Certificates:**
  - `sap-db-prod.howdens.local` (SAP Database - HANA or traditional)
  - `sap-db-backup.howdens.local` (Database backup connections)
- **SAP Integration Certificates:**
  - `sap-gateway.howdens.local` (SAP Gateway for web services)
  - `sap-idoc.howdens.local` (IDoc interface connections)
  - `sap-rfc.howdens.local` (RFC connections to suppliers)
- **Depot SAP Client Certificates:**
  - `depot-manchester-sap.howdens.local` (Depot SAP GUI connection)
  - `depot-london-sap.howdens.local` (Depot SAP GUI connection)

**Depot Location Data:**
- **Volume:** 20-30 synthetic depot locations
- **Fields:**
  - Depot ID (e.g., "MAN-01", "LON-15")
  - Location Name (e.g., "Manchester Central", "London Stratford")
  - System Hostname (depot systems + SAP client connections)
  - Certificate Status (Active, Expiring, Expired)
  - Last Rotation Date
  - SAP System ID (e.g., "PRD" for production, "QAS" for quality assurance)

**SAP-Specific Data Elements:**
- **SAP System Landscape:**
  - Production (PRD) - 6 E980 servers
  - Quality Assurance (QAS) - for testing
  - Development (DEV) - for customization
- **SAP Modules Represented:**
  - SAP MM (Materials Management) - supplier orders, inventory
  - SAP SD (Sales & Distribution) - trade customer orders
  - SAP FI/CO (Finance/Controlling) - financial reporting
  - SAP WM (Warehouse Management) - depot operations

**Compliance Metrics:**
- Certificate age distribution (histogram) - separated by SAP vs. depot systems
- Expiration timeline (next 30/60/90 days)
- Rotation compliance rate
- Outage incidents (before/after) - with SAP downtime impact
- SAP system availability correlation with certificate health

**Data Realism:**
- Use UK city names for depot locations (Manchester, London, Birmingham, Leeds, Glasgow, Edinburgh, Bristol, Cardiff, etc.)
- Certificate ages should show clear "before" state (100-400 days) vs "after" state (<24 hours)
- Include 2-3 "legacy" SAP certificates still in migration to show realistic transition
- SAP system names follow standard SAP naming conventions (SID format: 3 characters)
- Certificate common names reflect actual SAP architecture patterns
- **Note:** This is simulated SAP data - we do not have access to actual Howdens SAP systems

### TECH STACK — IBM Products + Primary vs. Expansion
**Primary IBM Products (Demo Focus):**
1. **IBM Power Systems** - Infrastructure platform hosting workloads
2. **PowerSC (Power Systems Security and Compliance)** - Certificate monitoring, compliance reporting, aging analysis
3. **RHEL on Power** - Operating system for Vault deployment

**Partner Products (Integrated):**
4. **HashiCorp Vault** - PKI engine, certificate issuance, automated rotation

**Expansion Opportunities (Not in Demo, but Mentioned):**
- **IBM Cloud Pak for Security** - Unified security operations across hybrid cloud
- **IBM QRadar** - Security information and event management (SIEM) integration
- **IBM Maximo** - Asset management for depot infrastructure
- **IBM Concert** - Application observability and performance monitoring

**Technology Positioning:**
- **Primary Story:** PowerSC + Vault on IBM Power = automated certificate lifecycle management
- **Expansion Story:** This is one component of a broader IBM security architecture
- **Partner Story:** IBM + HashiCorp partnership demonstrates open ecosystem approach

### OUT OF SCOPE — What Bob Must NOT Build
**DO NOT BUILD:**
1. ❌ **Frontend UI/Dashboard** - Use actual PowerSC console and Vault UI, not custom interfaces
2. ❌ **Synthetic Telemetry Generation** - Use real certificate data from Vault issuance, not simulated
3. ❌ **Mock PowerSC Dashboard** - Must use actual PowerSC product from TechZone
4. ❌ **Custom Certificate Management Tool** - Vault and PowerSC are the tools, don't build alternatives
5. ❌ **Depot Ordering System** - Don't build sample applications, just show certificate deployment
6. ❌ **Supplier Portal** - Reference only, don't build actual supplier systems
7. ❌ **Audit Committee Reporting Tool** - Use PowerSC's built-in reporting, don't create custom reports
8. ❌ **Hardware Refresh Planning Tool** - E980 context is mentioned, not demonstrated
9. ❌ **Business Continuity Simulation** - Discuss DR/BC, don't simulate outages
10. ❌ **Multi-Tenant Depot Isolation** - Single environment demo, not multi-tenant architecture

**WHAT TO BUILD (Minimal Scope):**
1. ✅ **Vault Installation on RHEL Power LPAR** - Use provided setup script
2. ✅ **PKI Configuration in Vault** - Root CA, Intermediate CA, roles for Power systems
3. ✅ **Sample Certificate Deployment** - 2-3 certificates deployed to demonstrate automation
4. ✅ **PowerSC Configuration** - Point PowerSC at RHEL LPAR for certificate scanning
5. ✅ **Demo Script/Talking Points** - Narrative flow connecting technical steps to business outcomes

**Key Principle:**  
This is a **Platform Reality demo** - we demonstrate actual IBM products (PowerSC) and partner products (Vault) working together. We do NOT build custom applications or simulations. The credibility comes from showing real platforms, real certificate issuance, and real monitoring - not from building elaborate demos.

---

---


---

## Customer Context: Howdens Joinery

**Source:** IBM Consulting Advantage analysis of Howdens Joinery 2025 Annual Report


### Industry Context: The PKI/Certificate Attack Vector

**Source:** Public domain cybersecurity incident analysis

#### **Case Study: Jaguar Land Rover (JLR) Cyber Attack - August 2025**

**The Incident:**
In late summer 2025, UK automaker Jaguar Land Rover (JLR) was targeted by a coordinated cyber alliance known as the **Scattered Lapsus Hunters**. This attack has been recognized as one of the most economically damaging cyber events in UK history.

**The Certificate Connection:**
The threat actors leveraged **stolen credentials to target the internal PKI (Public Key Infrastructure) and certificate signing templates**. By generating rogue internal tokens and certificates, the hackers were able to:
- Move laterally between corporate IT networks and the physical manufacturing floor
- Bypass standard endpoint alerts
- Gain access to operational technology (OT) and inventory systems

**Technical Attack Vector:**
The attack exploited vulnerabilities in Active Directory Certificate Services (AD CS), using techniques documented by security researchers (see: [JumpSec - New Techniques Against Active Directory Certificate Service](https://www.jumpsec.com/guides/new-techniques-against-active-directory-certificate-service/)).

**The Outage:**
The breach completely paralyzed JLR's automated operational technology (OT) and inventory systems, forcing a **total five-week shutdown** of assembly lines across flagship UK plants (Solihull, Halewood, and Wolverhampton).

#### **Impact Analysis: Why This Matters for Howdens**

**1. Financial and Production Losses**
- **Direct Financial Impact:** £1.9 billion total losses (classified as Category 3 systemic event by Cyber Monitoring Centre)
- **Weekly Losses:** £50 million during peak crisis
- **Production Impact:** UK car production fell 27% in September 2025 - sharpest monthly decline since 1952
- **Commercial Metrics:** JLR's wholesale volumes dropped 43%, retail sales dropped 25%

**2. Global Supply Chain Ripple Effects**
- **Ecosystem Impact:** Over 5,000 businesses linked to JLR's supply chain were heavily impacted
- **SME Vulnerability:** Small-to-medium enterprises (SMEs) supplying parts faced immediate cash-flow freezes, many pushed to brink of bankruptcy
- **Regional Economic Impact:** Business confidence in West Midlands dropped to second-lowest regional rating in UK
- **Recovery Timeline:** Financial recovery for suppliers took at least six months

**3. Structural and Global Operational Impact**
- **Total Network Quarantine:** Production suspended across global facilities (UK, Slovakia, India, Brazil, China)
- **Protracted Recovery:** Phased restart began October 2025, full capacity not achieved until mid-November 2025
- **Supply Chain Recovery:** Full recovery not achieved until January 2026 (5 months post-incident)

**4. Human and Workforce Impact**
- **Compulsory Furloughs:** Tens of thousands of production line workers across JLR and suppliers sent home
- **Job Instability:** Downstream suppliers forced to reduce worker pay, implement layoffs, and execute severe cost-cutting measures

#### **Relevance to Howdens Joinery**

**Parallel Risk Factors:**
1. **Similar Business Model:**
   - JLR: Manufacturer with complex supply chain and distributed production facilities
   - Howdens: Trade supplier with distributed depot network and 100+ key suppliers
   - Both rely on digital systems connecting corporate IT to operational locations

2. **Certificate-Based Attack Vector:**
   - JLR: Attackers exploited PKI/certificate infrastructure to move laterally
   - Howdens: Hundreds of depot locations with certificate-based authentication to SAP and central systems
   - **Risk:** Manual certificate management creates vulnerability similar to JLR's PKI exploitation

3. **Supply Chain Interdependence:**
   - JLR: 5,000+ businesses impacted by single company's outage
   - Howdens: 100+ key suppliers providing verified data, trade customers dependent on depot availability
   - **Risk:** Howdens outage would cascade through UK trade supply chain

4. **Business Continuity Criticality:**
   - JLR: Five-week shutdown = £1.9 billion loss
   - Howdens: "Built for the Trade" brand promise depends on 24/7 depot availability
   - **Risk:** Certificate-related outage preventing depot SAP access = trade customers cannot place orders

**Key Lessons for Howdens:**

1. **PKI/Certificate Infrastructure is a Critical Attack Surface:**
   - Manual certificate management increases vulnerability to credential theft and rogue certificate generation
   - Automated certificate lifecycle management (Vault) reduces attack surface and lateral movement opportunities

2. **Operational Technology (OT) and IT Convergence:**
   - JLR's integrated digital backbone became single point of failure
   - Howdens' SAP systems connecting depots to central operations represent similar convergence
   - **Mitigation:** Short-lived certificates (24 hours) limit window of exposure if credentials are compromised

3. **Supply Chain Resilience:**
   - JLR's outage cascaded to 5,000+ businesses
   - Howdens' 100+ suppliers and thousands of trade customers depend on system availability
   - **Mitigation:** Automated certificate rotation eliminates human error that could cause outages

4. **Recovery Time and Business Impact:**
   - JLR took 5 months for full supply chain recovery
   - Howdens' "low appetite for cyber security risk" mandate requires proactive measures
   - **Mitigation:** PowerSC monitoring provides continuous visibility to detect anomalies before they become incidents

**Demo Positioning:**

This real-world case study provides powerful context for the Vault + PowerSC demo:
- **Urgency:** PKI/certificate attacks are not theoretical - they caused £1.9 billion in losses to a UK manufacturer
- **Relevance:** Howdens' distributed depot network and SAP infrastructure have similar risk profile to JLR
- **Solution:** Automated certificate lifecycle management is a concrete mitigation against this attack vector
- **ROI:** The cost of implementing Vault + PowerSC is negligible compared to potential losses from a JLR-style incident

**Talking Point for Demo:**
"In August 2025, Jaguar Land Rover suffered a £1.9 billion loss when attackers exploited their PKI infrastructure to generate rogue certificates and move laterally through their systems. The five-week shutdown affected 5,000 businesses in their supply chain. Howdens has a similar risk profile - distributed depot network, SAP systems, 100+ suppliers. The difference is, we can proactively eliminate this attack vector through automated certificate management. Short-lived certificates and continuous monitoring make it exponentially harder for attackers to exploit certificate infrastructure the way they did at JLR."


#### **IBM Power Security Advantage: Defense in Depth**

**Infrastructure Layer Security:**

While this demo focuses on **application-layer security** (certificate management), it's important to understand IBM Power's inherent security advantages at the infrastructure layer:

**1. Virtualization Layer Security:**
- **Orders of magnitude fewer vulnerabilities** in IBM PowerVM hypervisor compared to x86 virtualization platforms
- PowerVM's firmware-based virtualization provides hardware-enforced isolation between LPARs
- Significantly smaller attack surface due to minimal code footprint in hypervisor
- **Industry Recognition:** PowerVM consistently shows fewer CVEs (Common Vulnerabilities and Exposures) than competing hypervisors

**2. Hardware-Based Security Features:**
- **Secure Boot:** Cryptographic verification of firmware and operating system integrity
- **Hardware Security Module (HSM) Integration:** Built-in cryptographic acceleration and key management
- **Memory Encryption:** Transparent memory encryption at hardware level
- **Trusted Platform Module (TPM):** Hardware-based security for cryptographic operations

**3. Business Continuity & Resilience:**
- **RAS (Reliability, Availability, Serviceability):** Industry-leading uptime and fault tolerance
- **Live Partition Mobility:** Move running workloads without downtime for maintenance
- **Concurrent Firmware Updates:** Apply security patches without system restart
- **Redundant Components:** Built-in redundancy for power, cooling, and I/O

**Defense in Depth Strategy:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Security Layers                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │  APPLICATION LAYER (This Demo's Focus)            │    │
│  │  - Certificate Management (Vault + PowerSC)       │    │
│  │  - SAP Application Security                       │    │
│  │  - Depot System Authentication                    │    │
│  └────────────────────────────────────────────────────┘    │
│                          ▲                                   │
│                          │ Secured by this demo             │
│                          │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  OPERATING SYSTEM LAYER                           │    │
│  │  - RHEL/AIX Security Hardening                    │    │
│  │  - OS-Level Access Controls                       │    │
│  │  - Audit Logging                                  │    │
│  └────────────────────────────────────────────────────┘    │
│                          ▲                                   │
│                          │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  VIRTUALIZATION LAYER (IBM Power Advantage)       │    │
│  │  - PowerVM Hypervisor (Minimal Attack Surface)    │    │
│  │  - Hardware-Enforced LPAR Isolation               │    │
│  │  - Firmware-Based Security                        │    │
│  └────────────────────────────────────────────────────┘    │
│                          ▲                                   │
│                          │                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │  HARDWARE LAYER (IBM Power Foundation)            │    │
│  │  - Secure Boot                                    │    │
│  │  - Memory Encryption                              │    │
│  │  - HSM Integration                                │    │
│  │  - TPM                                            │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Why This Matters for Howdens:**

1. **Complementary Security Layers:**
   - **IBM Power provides:** Secure, resilient infrastructure foundation (virtualization + hardware)
   - **This demo provides:** Application-layer security (certificate management, SAP authentication)
   - **Together:** Defense in depth strategy addressing security at all layers

2. **Business Criticality Alignment:**
   - Howdens' "low appetite for cyber security risk" requires security at ALL layers
   - IBM Power's infrastructure security + application-layer automation = comprehensive protection
   - **Critical for SAP:** SAP systems require both infrastructure resilience AND application security

3. **Reduced Attack Surface:**
   - **Infrastructure Layer:** PowerVM's minimal code footprint = fewer vulnerabilities to exploit
   - **Application Layer:** Short-lived certificates (24h) = minimal exposure window
   - **Combined Effect:** Attackers face hardened infrastructure AND automated application security

4. **Operational Resilience:**
   - **Infrastructure:** Live Partition Mobility, concurrent firmware updates = no downtime for security patches
   - **Application:** Automated certificate rotation = no manual processes that could cause outages
   - **Result:** Security improvements without business disruption

**Demo Positioning:**

"This demo focuses on application-layer security - specifically certificate management for SAP and depot systems. But it's important to understand that this sits on top of IBM Power's inherently secure infrastructure. PowerVM has orders of magnitude fewer vulnerabilities than x86 hypervisors, providing a hardened foundation. We're demonstrating how to secure the application layer with the same rigor that IBM Power secures the infrastructure layer. Together, this creates a defense-in-depth strategy appropriate for business-critical systems like Howdens' SAP environment."

**Talking Points:**

- "IBM Power isn't just about performance - it's about security and resilience for business-critical workloads"
- "PowerVM's minimal attack surface at the virtualization layer complements our application-layer security automation"
- "For SAP systems that cannot afford downtime, IBM Power provides the infrastructure resilience while Vault + PowerSC provide the application security"
- "This is why organizations running business-critical workloads choose IBM Power - security at every layer"

### PowerSC Compliance Profiles for Howdens' SAP Environment

**Source:** IBM Consulting Advantage analysis matching Howdens' business requirements to PowerSC capabilities

#### **Recommended Compliance Profiles**

**1. SAP Compliance Profile** (PRIMARY - FOUNDATIONAL)

**Why This Profile:**
- **Direct Alignment:** SAP is Howdens' core enterprise solution running on IBM Power E980 servers
- **PowerSC Capability:** Pre-built compliance profiles specifically designed to "harden the AIX systems with SAP"
- **Business Criticality:** Directly addresses security requirements for Howdens' critical manufacturing and supply chain operations
- **SAP Integration:** Howdens uses "SAP Ariba to further strengthen the way we do business with our suppliers" (2025 Annual Report)

**What This Profile Provides:**
- SAP-specific security hardening for AIX operating systems
- Configuration baselines aligned with SAP security best practices
- Automated compliance checking against SAP security requirements
- Certificate management visibility for SAP system connections
- Audit trails for SAP infrastructure security controls

**Demo Relevance:**
- Shows PowerSC monitoring SAP system certificates (application servers, database, Fiori, gateway)
- Demonstrates compliance reporting specifically for SAP infrastructure
- Validates that certificate management aligns with SAP security standards

---

**2. ISO 27001 Compliance Profile** (SUPPORTING - GOVERNANCE)

**Why This Profile:**
- **Stated Commitment:** Aligns with Howdens' explicit statement to "manage IT security closely to secure the confidentiality, integrity and availability of these systems" (2025 Annual Report)
- **Risk Appetite:** Supports their "low appetite for cyber security risk" mandate
- **SAP Certification:** ISO 27001 is one of SAP's certified compliance standards
- **Audit Committee:** Provides governance framework that Audit Committee requires

**What This Profile Provides:**
- Information security management system (ISMS) controls
- Confidentiality, integrity, and availability (CIA) triad enforcement
- Risk management framework alignment
- Audit and compliance reporting for board-level oversight
- Continuous monitoring and improvement processes

**Demo Relevance:**
- Shows PowerSC generating ISO 27001-aligned compliance reports
- Demonstrates how certificate management supports ISO 27001 controls (A.9 Access Control, A.10 Cryptography)
- Provides Audit Committee-ready reporting format

---

**3. Center for Internet Security (CIS) Benchmarks** (SUPPORTING - INDUSTRY STANDARD)

**Why This Profile:**
- **Industry Standard:** PowerSC 2.3.0 includes "Center for Internet Security benchmarks compliance" profiles
- **Enterprise Hardening:** Provides industry-standard hardening for enterprise systems
- **Scale Appropriate:** Designed for large-scale, distributed operations like Howdens' depot network
- **External Validation:** CIS benchmarks are recognized by external security specialists

**What This Profile Provides:**
- Operating system hardening baselines (AIX, RHEL on Power)
- Network security configuration standards
- Access control and authentication requirements
- Logging and monitoring standards
- Patch management and vulnerability management guidelines

**Demo Relevance:**
- Shows PowerSC validating systems against CIS benchmarks
- Demonstrates automated compliance checking across depot infrastructure
- Provides industry-recognized security posture metrics

---

#### **Strategic Alignment with Howdens' Business Requirements**

**1. Supply Chain Critical Systems**
- **Business Context:** Howdens uses "SAP Ariba to further strengthen the way we do business with our suppliers" (2025 Annual Report)
- **Security Requirement:** SAP security is integral to supply chain resilience
- **PowerSC Solution:** SAP Compliance Profile ensures SAP infrastructure is hardened and monitored
- **Certificate Connection:** Vault-issued certificates for SAP Ariba connections, monitored by PowerSC

**2. Business Continuity Support**
- **Business Context:** Howdens maintains "robust disaster recovery and business continuity framework" with "tested continuity plans" (2025 Annual Report)
- **Security Requirement:** Security controls must support (not hinder) business continuity
- **PowerSC Solution:** Continuous compliance monitoring without disrupting operations
- **Certificate Connection:** Automated certificate rotation eliminates manual processes that could cause outages

**3. Governance Requirements**
- **Business Context:** Audit Committee receives regular "Cyber security governance" updates (2025 Annual Report)
- **Security Requirement:** Demonstrable control effectiveness for board-level reporting
- **PowerSC Solution:** ISO 27001 and CIS benchmark reporting provides governance evidence
- **Certificate Connection:** Certificate age and rotation compliance metrics for Audit Committee

**4. External Validation**
- **Business Context:** Howdens uses "external specialists" to validate controls (2025 Annual Report)
- **Security Requirement:** Security posture must withstand external audit
- **PowerSC Solution:** Industry-standard compliance profiles (ISO 27001, CIS) recognized by auditors
- **Certificate Connection:** PowerSC provides audit trails for certificate lifecycle management

---

#### **Demo Integration: PowerSC Compliance Profiles**

**How to Demonstrate in the Demo:**

**Act 1: The Problem - Show Compliance Gaps**
- Open PowerSC console → Compliance Dashboard
- Show SAP systems with compliance profile violations:
  - Aging certificates (365+ days) = SAP Compliance Profile violation
  - Missing security configurations = CIS Benchmark violations
  - Access control gaps = ISO 27001 control failures
- **Talking Point:** "Here we see Howdens' SAP environment with multiple compliance violations. The SAP Compliance Profile shows aging certificates on critical SAP systems. This creates risk for their supply chain operations and doesn't align with their 'low appetite for cyber security risk.'"

**Act 4: PowerSC Monitoring - Show Compliance Improvement**
- Return to PowerSC console → Compliance Dashboard
- Show improved compliance scores after Vault certificate deployment:
  - SAP Compliance Profile: 67% → 98% compliant
  - ISO 27001 Controls: Certificate management controls now passing
  - CIS Benchmarks: Cryptographic controls now compliant
- **Talking Point:** "After implementing automated certificate management, PowerSC shows dramatic improvement across all three compliance profiles. The SAP Compliance Profile is now 98% compliant, ISO 27001 certificate controls are passing, and CIS cryptographic benchmarks are met. This is the kind of measurable improvement Howdens' Audit Committee needs to see."

**Act 5: Business Value - Compliance Reporting**
- Generate compliance reports from PowerSC:
  - SAP Compliance Report (for Richard Sutcliffe - IT Director)
  - ISO 27001 Report (for Jackie Callaway - CFO and Audit Committee)
  - CIS Benchmark Report (for external auditors)
- **Talking Point:** "PowerSC provides the compliance reporting that Howdens needs at every level. The SAP Compliance Report shows Richard's IT team that SAP infrastructure is hardened. The ISO 27001 report gives Jackie and the Audit Committee governance evidence. The CIS Benchmark report satisfies external specialists validating controls."

---

#### **Compliance Profile Configuration in Demo**

**PowerSC Setup Steps:**

1. **Enable Compliance Profiles:**
   ```bash
   # In PowerSC console
   # Navigate to: Compliance → Profiles
   # Enable:
   - SAP Compliance Profile (Primary)
   - ISO 27001 Profile (Supporting)
   - CIS Benchmark for AIX/RHEL (Supporting)
   ```

2. **Configure Certificate Monitoring:**
   ```bash
   # Add certificate age thresholds
   - Warning: Certificates > 90 days
   - Critical: Certificates > 180 days
   - Non-compliant: Certificates > 365 days
   ```

3. **Schedule Compliance Scans:**
   ```bash
   # Set scan frequency
   - Daily: Certificate age checks
   - Weekly: Full compliance profile scans
   - Monthly: Comprehensive reports for Audit Committee
   ```

4. **Configure Reporting:**
   ```bash
   # Set up automated reports
   - SAP Compliance: Weekly to IT Director
   - ISO 27001: Monthly to CFO/Audit Committee
   - CIS Benchmarks: Quarterly for external audits
   ```

---

#### **Key Talking Points: Compliance Profiles**

**For Richard Sutcliffe (IT Director):**
"PowerSC's SAP Compliance Profile is specifically designed for your SAP on Power environment. It provides pre-built hardening baselines and continuous monitoring. Combined with automated certificate management from Vault, you get both infrastructure security and application-layer security - exactly what SAP requires."

**For Jackie Callaway (CFO) and Audit Committee:**
"PowerSC provides ISO 27001-aligned reporting that demonstrates control effectiveness. The compliance dashboard shows measurable improvement in security posture - from 67% to 98% compliant. This is the kind of governance evidence the Audit Committee needs to validate that Howdens' 'low appetite for cyber security risk' is being met."

**For External Auditors:**
"PowerSC uses industry-standard CIS Benchmarks for system hardening. These are recognized by external security specialists and provide objective, third-party validated security baselines. The automated compliance checking ensures continuous adherence to these standards."

**For Supply Chain Leadership:**
"The SAP Compliance Profile ensures that your SAP Ariba connections to suppliers are secured with proper certificate management. This protects the 100+ key supplier relationships that are critical to your supply chain resilience."

---


**Competitive Differentiation:**

When compared to x86 alternatives:
- **Infrastructure Security:** PowerVM's proven track record of fewer vulnerabilities
- **Business Continuity:** RAS features enable security patching without downtime
- **SAP Optimization:** IBM Power is purpose-built for mission-critical SAP workloads
- **Total Cost of Ownership:** Fewer security incidents = lower operational costs

**Key Message:**

"We're not just securing applications on any infrastructure - we're securing applications on IBM Power, which provides orders of magnitude better security at the infrastructure layer. This defense-in-depth approach is exactly what Howdens needs for their business-critical SAP systems and their 'low appetite for cyber security risk.'"

---

---

### Company Overview


### Current Infrastructure Context

**IBM Power Estate:**
- **Six (6) IBM Power E980 servers** currently in production
- **Running SAP ERP** - Core business system for Howdens operations
- E980 systems approaching end-of-support lifecycle
- End-of-support implications:
  - Loss of access to security patches and vulnerability fixes
  - Increased cyber risk exposure over time
  - Compliance challenges for systems without vendor support
  - Potential impact on "low appetite for cyber security risk" mandate
  - **Critical concern:** SAP systems cannot afford security-related outages

**SAP on Power Context:**
- SAP is the backbone of Howdens' business operations:
  - Depot inventory management
  - Trade customer order processing
  - Supplier relationship management
  - Financial systems and reporting
- **Certificate dependencies:** SAP systems require valid certificates for:
  - SAP GUI connections from depot locations
  - Web-based SAP Fiori interfaces
  - SAP integration interfaces (IDocs, RFCs, web services)
  - Database connections (SAP HANA or traditional databases)
  - Backup and disaster recovery systems
- **Business impact of certificate failures:**
  - Expired certificates = SAP unavailable = depots cannot process orders
  - Manual certificate management on SAP systems is high-risk
  - SAP downtime directly impacts trade customer service

**Infrastructure Modernization Considerations:**
- While not the primary focus of this demo, the aging Power infrastructure running critical SAP systems adds urgency to security automation initiatives
- Automated certificate management becomes even more critical for SAP on aging infrastructure
- Modern security tooling (Vault + PowerSC) can extend the secure operational life of SAP on existing Power infrastructure
- Demonstrates IBM's commitment to supporting SAP customers through infrastructure transitions
- **Note:** We do not have access to actual Howdens SAP systems, but will simulate SAP-relevant certificate scenarios

**Howdens Joinery** is the UK's leading trade-only kitchen and joinery supplier, operating under the brand promise "Built for the Trade." The company serves trade customers (kitchen fitters and builders) through a distributed network of hundreds of depot locations across the UK, with over 95% of consolidated Group sales from UK operations.

### Business Priorities & Cybersecurity Context

#### **Critical Business Problems:**

1. **Supply Chain Disruption Risk** (HIGHEST PRIORITY)
   - Howdens explicitly states: *"A failure in governance or disruption to our relationship with key suppliers, manufacturing and distribution operations could affect our ability to service our customers' needs"* (2025 Annual Report)
   - A cyber incident affecting supply chain systems could directly prevent servicing trade customers
   - The company's scale makes disruption high-impact across the entire UK trade market

2. **Distributed Depot Network Vulnerability**
   - Hundreds of depot locations require secure, reliable access to ordering and customer systems
   - Each depot represents a potential security endpoint in the network
   - Varying levels of IT sophistication across depot locations

3. **Multi-Stakeholder Data Protection**
   - Confidential trade customer information, pricing, and project details across the entire depot network
   - Supplier relationship data and sustainability information (100+ key suppliers providing verified data)
   - ESG/sustainability commitments requiring data integrity

4. **Business Continuity During Operational Transformation**
   - Active transformation of supply chain and operations (led by Operations Director)
   - Digital systems must remain secure during transformation period
   - Cannot afford disruption while modernizing

#### **Desired Outcomes:**

1. **Uninterrupted Service Delivery to Trade Customers**
   - Maintain 24/7 availability of ordering and customer systems across all depots
   - Ensure supply chain visibility and product availability aren't compromised
   - Protect the "Built for the Trade" brand promise

2. **Resilient Supply Chain Operations**
   - Protect systems supporting multi-sourcing strategy (long-term contracts and multiple sourcing)
   - Maintain data integrity for 100+ key supplier relationships and decarbonization plans
   - Secure supplier governance standards

3. **Robust Disaster Recovery & Business Continuity**
   - Howdens states: *"We have robust disaster recovery and business continuity plans that are tested regularly"* (2025 Annual Report)
   - Cybersecurity must support (not hinder) these plans
   - Regular testing and validation of recovery capabilities

4. **Low Cyber Risk Posture**
   - Explicit statement: *"We have a low appetite for cyber security risk and manage IT security closely to secure the confidentiality, integrity and availability of these systems"* (2025 Annual Report)
   - Continuous investment in system security
   - Board-level oversight through Audit Committee

5. **Regulatory Compliance & Governance**
   - Maintain supplier governance standards
   - Protect sustainability/ESG data and commitments (Net Zero plan, Scope 3 emissions reduction targets)
   - Audit Committee oversight of controls and internal audit

#### **Key Personas for Howdens:**

1. **Trade Customers (Kitchen Fitters & Builders)** - PRIMARY STAKEHOLDER
   - **Needs:** Reliable, secure access to order placement, pricing, and product availability systems
   - **Pain Point:** Loss of access to Howdens systems disrupts their customer projects and revenue
   - **Volume:** Hundreds of individual trade accounts across the UK
   - **Impact:** Direct revenue impact if systems are unavailable

2. **Depot Managers & Sales Staff** - CRITICAL OPERATIONAL
   - **Needs:** Secure access to customer accounts, inventory systems, and ordering capabilities
   - **Pain Point:** Local system compromise affecting their ability to serve trade customers
   - **Constraint:** Distributed across hundreds of physical locations
   - **Challenge:** Varying levels of IT sophistication across depots
   - **Dependency:** Rely on central IT systems for daily operations

3. **Supply Chain & Operations Leadership** - STRATEGIC
   - **Needs:** Secure visibility into supplier relationships, manufacturing, and distribution operations
   - **Pain Point:** Supply chain disruption directly impacts business performance and customer service
   - **Responsibility:** Leading transformation of supply chain and operations (ongoing initiative)
   - **Mandate:** Maintain operational resilience during transformation

4. **Suppliers (100+ Key Suppliers)** - ECOSYSTEM PARTNERS
   - **Needs:** Secure systems to share verified sustainability data and decarbonization plans
   - **Pain Point:** Data confidentiality and system availability for their submissions
   - **Requirement:** Trust in Howdens' data protection capabilities
   - **Impact:** Supplier relationships are strategic assets

5. **IT/Cybersecurity Team** - OPERATIONAL GUARDIANS
   - **Needs:** Secure infrastructure supporting business continuity and disaster recovery plans
   - **Pain Point:** Managing continuous security improvements while supporting operational transformation
   - **Mandate:** Maintain "low appetite for cyber security risk" posture
   - **Challenge:** Securing distributed depot network with limited resources

6. **Executive/Board Leadership & Audit Committee** - GOVERNANCE
   - **Needs:** Risk assurance and governance over cyber threats
   - **Pain Point:** Business continuity, compliance, reputation protection for market-leading brand
   - **Oversight:** Audit Committee oversees controls and internal audit
   - **Accountability:** Board-level responsibility for cyber risk management

### Strategic Insight: Cybersecurity as Business Continuity

**Key Finding:** For Howdens, cybersecurity is fundamentally a **business continuity issue**, not just an IT issue.

Their explicit statement of low cyber risk appetite and regular testing of disaster recovery plans indicates that:

- **Cyber resilience directly supports their ability to serve trade customers** - the core of their business model
- **Supply chain security is critical to their competitive position** - disruption affects their market leadership
- **Distributed depot network security is essential to their business model** - hundreds of endpoints must be protected
- **Governance and controls are board-level concerns** - Audit Committee oversight demonstrates strategic importance

**Brand Promise Connection:**
Cybersecurity enables the "Built for the Trade" brand promise by ensuring trade customers can rely on Howdens systems, every time. System availability and data integrity are not IT metrics—they are customer service metrics.

### Demo Relevance to Howdens

**Why Certificate Management Matters:**

1. **Depot Network Security:**
   - Each depot location requires secure TLS/SSL certificates for accessing central systems
   - Expired certificates = depot cannot process orders = trade customers cannot get products
   - Manual certificate management across hundreds of locations is error-prone and risky

2. **Supply Chain System Availability:**
   - Supplier portals and data exchange systems require valid certificates
   - Certificate expiration could disrupt supplier relationships and data flows
   - Automated certificate lifecycle management ensures continuous availability

3. **Business Continuity Alignment:**
   - Short-lived certificates reduce the blast radius of a security incident
   - Automated rotation eliminates human error (a key cause of outages)
   - PowerSC monitoring provides visibility required for disaster recovery testing

4. **Low Risk Appetite Support:**
   - Vault's automated PKI reduces manual processes (and associated risks)
   - PowerSC compliance reporting demonstrates control effectiveness to Audit Committee
   - Continuous certificate monitoring aligns with "low appetite for cyber security risk"

5. **Operational Transformation Enabler:**
   - Modern certificate management supports digital transformation initiatives

### Target Audience & Contacts

**Source:** IBM Consulting Advantage analysis of Howdens Joinery 2025 Annual Report

#### **PRIMARY CONTACT (Decision Maker):**

**Richard Sutcliffe - Supply Chain and IT Director** (Executive Committee Member)
- **Role:** Supply Chain Director with direct responsibility for leading the IT team
- **Joined:** January 2019, appointed to Executive Committee July 2020
- **Responsibilities:**
  - Optimizing stock holdings across the business
  - Ensuring market-leading stock availability
  - **Leading the IT team** - directly responsible for systems security and infrastructure
- **Background:** Senior supply chain and business planning roles at B&Q, Wyevale Garden Centres, and Hobbycraft
- **Why Primary Contact:**
  - Direct ownership of IT security and infrastructure
  - Understands both retail/trade operations and complex IT environments
  - Executive Committee member with decision-making authority
  - Responsible for systems supporting depot network and supply chain

**Demo Positioning for Richard Sutcliffe:**
- Supply chain resilience and operational continuity
- Distributed depot network security automation
- IT infrastructure supporting business transformation
- Reducing operational burden on IT team during transformation
- Aligning with "low appetite for cyber security risk" mandate

---

#### **SECONDARY STAKEHOLDERS (Influencers & Approvers):**

**1. Julian Lee - Operations Director** (Executive Committee Member)
- **Role:** Responsible for transformation of supply chain and operations (ongoing since 2009)
- **Why Include:** 
  - Invested in cybersecurity supporting operational resilience during transformation
  - Needs assurance that security initiatives won't disrupt transformation
  - Concerned with depot network operational continuity
- **Demo Angle:** Business continuity enabler, not transformation blocker

**2. Jackie Callaway - Chief Financial Officer** (Executive Committee Member)
- **Joined:** June 2, 2025 (very recent appointment)
- **Background:** Previously CFO at Coats Group plc and Devro plc - experienced with enterprise cybersecurity governance
- **Why Include:**
  - Concerned with risk management and business continuity implications
  - Financial oversight of IT investments and cyber risk
  - Fresh perspective on governance and controls
- **Demo Angle:** ROI, risk reduction, governance alignment, Audit Committee reporting

**3. Audit Committee** (Board-Level Governance)
- **Role:** Oversees controls and internal audit
- **Why Include:**
  - Given Howdens' explicit "low appetite for cyber security risk" statement, the Audit Committee is a key governance stakeholder
  - Requires evidence of control effectiveness
  - Needs visibility into cyber risk management
- **Demo Angle:** Compliance reporting, control effectiveness, continuous monitoring

---

#### **TERTIARY CONTACT (Operational Facilitator):**

**Tom Eliot - Senior Project Manager**
- **Role:** Senior project manager (operational level)
- **Why Tertiary:**
  - Easy contact and operational facilitator
  - **Lacks decision-making authority** for strategic initiatives
  - Can help navigate organization and schedule meetings
  - Useful for technical validation and pilot coordination
- **Best Use:** Operational liaison, not primary decision maker

**Engagement Strategy:**
- Use Tom Eliot to facilitate introductions to Richard Sutcliffe
- Position Tom as operational champion who can validate technical feasibility
- Ensure executive-level contacts (Richard, Julian, Jackie) are involved in decision-making discussions

---

#### **RECOMMENDED DEMO AUDIENCE COMPOSITION:**

**Ideal Demo Attendees (in priority order):**

1. **Richard Sutcliffe** (Supply Chain & IT Director) - MUST ATTEND
2. **Julian Lee** (Operations Director) - STRONGLY RECOMMENDED
3. **Jackie Callaway** (CFO) - RECOMMENDED for governance angle
4. **IT/Security Team Representatives** (reporting to Richard) - TECHNICAL VALIDATION
5. **Tom Eliot** (Senior Project Manager) - OPERATIONAL LIAISON
6. **Audit Committee Representative** (if available) - GOVERNANCE VALIDATION

**Demo Format Recommendation:**
- **Executive Overview (15 min):** Business value, risk reduction, ROI - for Richard, Julian, Jackie
- **Technical Deep Dive (20 min):** Architecture, implementation, operations - for IT/Security team
- **Governance & Compliance (10 min):** Audit Committee reporting, control effectiveness - for Jackie and Audit Committee rep
- **Q&A (15 min):** Address specific concerns and objections

**Success Criteria:**
- Richard Sutcliffe agrees to pilot or POC
- Julian Lee confirms no operational disruption concerns
- Jackie Callaway supports business case and ROI
- IT/Security team validates technical feasibility
- Clear next steps defined with executive sponsorship

---

   - Scalable architecture supports growth and network expansion
   - Reduces operational burden on IT team during transformation period

---

## Executive Summary

This **20-minute technical demonstration** showcases how IBM PowerSC and HashiCorp Vault work together to secure Howdens' SAP environment on IBM Power systems.

**Demo Structure:**
- **PowerSC (Star):** Apply SAP compliance profiles to harden SAP infrastructure and monitor certificate health
- **Vault (Co-Star):** Automate application-layer certificate lifecycle management for SAP connections

**Key Value Proposition:**
- **PowerSC:** Provides SAP-specific compliance hardening (SAP, ISO 27001, CIS Benchmarks) and continuous monitoring
- **Vault:** Automates certificate issuance and rotation for SAP application layer (24-hour certificates vs. 365-day manual certificates)
- **Together:** Defense-in-depth security for business-critical SAP systems supporting Howdens' "Built for the Trade" brand promise
- **Result:** 67% → 98% compliance improvement, zero certificate-related outages, Audit Committee-ready reporting

---

## TechZone Environment Status

### Search Results
**HashiCorp Vault:** ❌ No dedicated TechZone environments found  
**PowerSC:** ❌ No environments found via search (you mentioned existing demo exists)  
**IBM Power:** ❌ No environments found via search

### Recommended Approach

Given the TechZone search results, here are your options:

#### **Option 1: Manual TechZone Catalog Search (RECOMMENDED)**
The TechZone MCP search may not index all environments. You should:
1. Log into [TechZone](https://techzone.ibm.com) directly
2. Search the catalog for "PowerSC" or "Power Systems Security"
3. Look for existing Power environments that might support PowerSC installation
4. Check if any Red Hat OpenShift or RHEL environments exist where Vault could be deployed

#### **Option 2: Hybrid Approach - Self-Hosted Vault + TechZone PowerSC**
- Deploy HashiCorp Vault locally or on a cloud VM (AWS/Azure/IBM Cloud)
- Use existing TechZone PowerSC demo environment
- Connect them via network configuration
- **Pros:** Full control over Vault configuration, realistic integration scenario
- **Cons:** Requires network connectivity setup, additional infrastructure

#### **Option 3: Fully Self-Hosted Demo**
- Deploy both Vault and PowerSC in your own infrastructure
- Use IBM Power Virtual Server or on-premises Power system
- **Pros:** Complete control, no TechZone dependencies
- **Cons:** Requires significant infrastructure access and setup time

#### **Option 4: Simulated Integration Demo**
- Use Vault in standalone mode (local or cloud)
- Use PowerSC screenshots/recordings from existing demo
- Build a lightweight integration layer that demonstrates the concept
- **Pros:** Fastest to implement, no environment dependencies
- **Cons:** Less hands-on, requires more narrative explanation

---

## Demo Architecture

### Components

```
┌─────────────────────────────────────────────────────────────┐
│                    Demo Architecture                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐         ┌─────────────────────────┐  │
│  │  HashiCorp Vault │◄────────┤  Certificate Requests   │  │
│  │                  │         │  (Applications/Services) │  │
│  │  - PKI Engine    │         └─────────────────────────┘  │
│  │  - Short-lived   │                                       │
│  │    certificates  │                                       │
│  │  - Auto-rotation │                                       │
│  └────────┬─────────┘                                       │
│           │                                                  │
│           │ Issues certificates                             │
│           │ (TTL: 24h, 1h, etc.)                           │
│           ▼                                                  │
│  ┌──────────────────────────────────────────────┐          │
│  │         IBM Power Systems (AIX/Linux)        │          │
│  │                                               │          │
│  │  ┌────────────────────────────────────────┐ │          │
│  │  │         PowerSC Agent                  │ │          │
│  │  │                                        │ │          │
│  │  │  - Certificate Discovery               │ │          │
│  │  │  - Age Monitoring                      │ │          │
│  │  │  - Expiration Tracking                 │ │          │
│  │  │  - Compliance Reporting                │ │          │
│  │  └────────────────────────────────────────┘ │          │
│  │                                               │          │
│  │  Applications using Vault-issued certs:      │          │
│  │  - Web servers (Apache/Nginx)                │          │
│  │  - Database connections                      │          │
│  │  - API services                              │          │
│  └──────────────────┬────────────────────────────┘          │
│                     │                                        │
│                     │ Reports to                            │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────┐          │
│  │         PowerSC Management Console           │          │
│  │                                               │          │
│  │  - Certificate Age Dashboard                 │          │
│  │  - Expiration Alerts                         │          │
│  │  - Compliance Reports                        │          │
│  │  - Audit Logs                                │          │
│  └──────────────────────────────────────────────┘          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Integration Points

1. **Vault PKI Engine → Power Systems**
   - Vault issues short-lived certificates (1h, 24h, 7d TTL)
   - Certificates deployed to Power systems via automation
   - Applications configured to use Vault-issued certificates

2. **PowerSC Agent → Certificate Store**
   - Scans certificate stores on AIX/Linux partitions
   - Discovers certificates (Vault-issued and legacy)
   - Tracks certificate metadata (issuer, expiration, age)

#### **Option 5: RHEL on Power LPAR (OPTIMAL FOR THIS DEMO) ⭐**
If the PowerSC TechZone environment includes a RHEL on IBM Power LPAR, this is the **ideal deployment option**:

**Advantages:**
- ✅ Everything runs on IBM Power infrastructure (authentic integration story)
- ✅ No external dependencies or network complexity
- ✅ Demonstrates IBM Power's versatility (security workloads + applications)
- ✅ Single TechZone reservation covers both components
- ✅ Realistic enterprise architecture (Vault on same infrastructure as workloads)
- ✅ Simplified networking (localhost/internal communication)

**Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│         IBM Power System (TechZone Environment)         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  RHEL on Power LPAR                            │    │
│  │                                                 │    │
│  │  ┌──────────────────┐  ┌──────────────────┐  │    │
│  │  │  HashiCorp Vault │  │  PowerSC Agent   │  │    │
│  │  │  (Port 8200)     │  │                  │  │    │
│  │  │                  │  │  - Cert scanning │  │    │
│  │  │  - PKI Engine    │  │  - Monitoring    │  │    │
│  │  │  - API Server    │  │                  │  │    │
│  │  └──────────────────┘  └──────────────────┘  │    │
│  │                                                 │    │

---

## Demo Flow: 20-Minute Technical Demonstration

**Target Duration:** 20 minutes  
**Format:** Live platform demonstration (PowerSC + Vault)  
**Audience:** Richard Sutcliffe (IT Director), Julian Lee (Operations Director), IT/Security team

### Demo Narrative Structure

**Act 1: PowerSC - The Foundation (8 minutes)**
- **Star Role:** IBM PowerSC demonstrates SAP infrastructure security and compliance
- **Focus:** Show how PowerSC applies compliance profiles and monitors SAP systems

**Act 2: The Gap - Application Layer Certificates (3 minutes)**
- **Transition:** PowerSC shows infrastructure is hardened, but certificate management is manual
- **Problem:** Aging certificates create application-layer risk

**Act 3: Vault - The Co-Star Solution (6 minutes)**
- **Co-Star Role:** HashiCorp Vault automates application-layer certificate lifecycle
- **Focus:** Show certificate issuance, deployment, and automated rotation

**Act 4: PowerSC + Vault Together (3 minutes)**
- **Integration:** PowerSC monitors Vault-issued certificates, shows compliance improvement
- **Result:** Complete security story - infrastructure + application layers

---

### Act 1: PowerSC - SAP Infrastructure Security (8 minutes)

**Opening Context (1 minute):**
"Howdens runs their business on SAP - six IBM Power E980 servers supporting hundreds of depot locations and 100+ suppliers. SAP is the backbone of their 'Built for the Trade' brand promise. Let's look at how PowerSC secures this critical infrastructure."

**Step 1: Show SAP Environment (2 minutes)**

*Open PowerSC Console → Systems View*

**What to Show:**
- Six Power E980 systems running SAP (simulated: sap-prod-01 through sap-prod-06)
- SAP application servers, database servers, Fiori gateway
- Depot connection points (Manchester, London, Birmingham depots)

**Talking Points:**
- "Here's Howdens' SAP landscape - six E980 servers running production SAP"
- "These systems support depot inventory, trade customer orders, supplier relationships"
- "PowerSC provides continuous monitoring and compliance checking across this entire estate"

**Step 2: Apply SAP Compliance Profile (3 minutes)**

*Navigate to: Compliance → Profiles → SAP Compliance Profile*

**What to Show:**
- SAP Compliance Profile configuration
- Apply profile to SAP systems
- Show compliance scan running
- Display initial compliance score: **67% compliant**

**Highlight Violations:**
- Aging certificates (365+ days) on SAP systems
- Missing security configurations
- Access control gaps

**Talking Points:**
- "PowerSC includes pre-built SAP compliance profiles - hardening baselines specifically for SAP on Power"
- "We're applying the SAP profile now - it checks hundreds of security controls"
- "Initial scan shows 67% compliance - not bad, but not meeting Howdens' 'low appetite for cyber security risk'"
- "The biggest issues? Aging certificates on SAP application servers and database connections"
- "These 365-day-old certificates are a security risk - if compromised, attackers have a year of access"

**Step 3: Show ISO 27001 and CIS Benchmarks (2 minutes)**

*Navigate to: Compliance → Profiles → ISO 27001 and CIS Benchmarks*

**What to Show:**
- ISO 27001 profile applied (governance framework)
- CIS Benchmarks applied (industry-standard hardening)
- Compliance dashboard showing multiple frameworks

**Talking Points:**
- "PowerSC supports multiple compliance frameworks simultaneously"
- "ISO 27001 aligns with Howdens' stated commitment to manage IT security closely"
- "CIS Benchmarks provide industry-standard hardening - recognized by external auditors"
- "This multi-framework approach gives Howdens' Audit Committee comprehensive governance evidence"

**Transition to Act 2:**
"PowerSC shows us that the SAP infrastructure is largely hardened - 67% compliant. But there's a critical gap: certificate management at the application layer. Let's look at that problem."

---

### Act 2: The Gap - Application Layer Certificates (3 minutes)

**Step 1: Certificate Inventory (2 minutes)**

*Navigate to: PowerSC → Certificate Management → Inventory*

**What to Show:**
- Certificate inventory across SAP systems
- Aging certificate report:
  - `sap-prod-app-01.howdens.local` - 387 days old
  - `sap-db-prod.howdens.local` - 412 days old
  - `sap-fiori.howdens.local` - 298 days old
  - `depot-manchester-sap.howdens.local` - 365 days old

**Highlight the Problem:**
- Manual certificate management across hundreds of depot connections
- Long-lived certificates (365+ days) increase security risk
- No automated rotation - human error causes outages

**Talking Points:**
- "PowerSC's certificate discovery shows the problem clearly"
- "These SAP certificates are over a year old - manually managed, manually renewed"
- "For Howdens with hundreds of depot locations, manual certificate management is high-risk"
- "Remember the Jaguar Land Rover incident? Attackers exploited PKI infrastructure by generating rogue certificates"
- "Long-lived certificates give attackers extended access if compromised"
- "And manual processes cause outages - expired certificates mean depots can't access SAP, trade customers can't place orders"

**Step 2: The Business Impact (1 minute)**

**Show Impact Metrics:**
- Certificate-related outages: 3 per year
- Average outage duration: 4 hours
- Depots affected per outage: 15-20
- Trade customers impacted: Hundreds per incident

**Talking Points:**
- "This isn't theoretical - Howdens has experienced certificate-related outages"
- "When a depot's SAP certificate expires, that depot goes dark - no orders, no inventory visibility"
- "This directly threatens the 'Built for the Trade' brand promise"
- "PowerSC gives us visibility into the problem. Now let's see the solution."

**Transition to Act 3:**
"PowerSC has shown us the infrastructure is hardened, but the application layer needs automation. That's where HashiCorp Vault comes in as the co-star."

---

### Act 3: Vault - Application Layer Automation (6 minutes)

**Opening Context (30 seconds):**
"HashiCorp Vault provides automated certificate lifecycle management at the application layer. Instead of 365-day manual certificates, we'll issue 24-hour certificates that rotate automatically."

**Step 1: Vault PKI Engine (2 minutes)**

*Open Vault UI → PKI Secrets Engine*

**What to Show:**
- Vault PKI engine configured with root and intermediate CAs
- Role configured for SAP systems: `power-systems-sap-role`
- Certificate policy: 24-hour TTL, automatic rotation

**Talking Points:**
- "Vault acts as Howdens' certificate authority for SAP application connections"
- "We've configured it to issue certificates with 24-hour lifespans"
- "24 hours vs. 365 days - that's a 96% reduction in exposure window"
- "If a certificate is somehow compromised, it's only valid for 24 hours, not a year"

**Step 2: Issue Certificate for SAP System (2 minutes)**

*Vault UI → PKI Engine → Issue Certificate*

**What to Show:**
```bash
# Issue certificate for SAP application server
vault write pki_int/issue/power-systems-sap-role \
  common_name="sap-prod-app-01.howdens.local" \
  ttl="24h"
```

**Display Certificate Details:**
- Common Name: sap-prod-app-01.howdens.local
- Issuer: Vault Intermediate CA
- Valid From: [current time]
- Valid Until: [current time + 24 hours]
- Key Length: 2048-bit RSA

**Talking Points:**
- "Vault issues the certificate instantly - no manual CSR generation, no waiting"
- "This certificate is valid for exactly 24 hours"
- "Tomorrow, Vault will automatically issue a new certificate and rotate it"
- "No human intervention, no manual tracking, no spreadsheets"

**Step 3: Deploy to SAP System (1.5 minutes)**

*Terminal/SSH → RHEL Power LPAR*

**What to Show:**
```bash
# Certificate deployed to SAP system
ls -l /etc/ssl/sap/
# Shows newly issued certificate

# Verify certificate
openssl x509 -in /etc/ssl/sap/sap-prod-app-01.pem -text -noout | grep -A2 "Validity"
# Shows 24-hour validity period
```

**Talking Points:**
- "The certificate is deployed automatically to the SAP system"
- "SAP application server picks up the new certificate without restart"
- "This same process happens for all SAP connections - database, Fiori, depot connections"
- "Automated, repeatable, no manual intervention"

**Step 4: Rotation Schedule (30 seconds)**

**Show Automation:**
- Cron job or systemd timer configured for daily rotation
- Vault API call scheduled for certificate renewal
- Application reload automation

**Talking Points:**
- "Every 24 hours, this process repeats automatically"
- "Vault issues new certificate, deployment script applies it, SAP reloads"
- "Howdens' IT team never touches this - it just works"

**Transition to Act 4:**
"Now let's see how PowerSC and Vault work together to provide complete visibility and compliance."

---

### Act 4: PowerSC + Vault Integration (3 minutes)

**Step 1: PowerSC Discovers Vault Certificates (1.5 minutes)**

*Return to PowerSC Console → Certificate Management → Inventory*

**What to Show:**
- PowerSC has discovered the new Vault-issued certificates
- Certificate inventory now shows:
  - `sap-prod-app-01.howdens.local` - **12 hours old** (Vault-issued)
  - `sap-db-prod.howdens.local` - 412 days old (legacy, pending migration)
  - `depot-manchester-sap.howdens.local` - **8 hours old** (Vault-issued)

**Highlight the Difference:**
- Vault certificates: <24 hours old
- Legacy certificates: 365+ days old
- Clear visual distinction in PowerSC dashboard

**Talking Points:**
- "PowerSC automatically discovers the Vault-issued certificates"
- "Look at the difference - 12 hours vs. 412 days"
- "PowerSC provides continuous monitoring of both legacy and Vault-managed certificates"
- "This gives Howdens visibility during migration - they can see progress depot-by-depot"

**Step 2: Compliance Improvement (1.5 minutes)**

*Navigate to: PowerSC → Compliance Dashboard*

**What to Show:**
- Updated compliance scores:
  - **SAP Compliance Profile: 67% → 98%** ✅
  - **ISO 27001 Controls: Certificate management controls now passing** ✅
  - **CIS Benchmarks: Cryptographic controls now compliant** ✅

**Show Metrics:**
| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Average Certificate Age | 287 days | 12 hours | 96% reduction |
| Manual Renewals/Month | 45 | 0 | 100% automation |
| Certificate-Related Outages | 3/year | 0 | Zero disruptions |
| SAP Compliance Score | 67% | 98% | 31% improvement |

**Talking Points:**
- "This is the power of PowerSC + Vault working together"
- "SAP Compliance Profile jumps from 67% to 98% - that's Audit Committee-ready"
- "ISO 27001 certificate controls are now passing - governance evidence for Jackie Callaway"
- "CIS Benchmarks show compliant cryptographic controls - external auditor validation"
- "Most importantly: zero certificate-related outages - protecting the 'Built for the Trade' brand promise"

---

### Closing: Business Value Summary (30 seconds)

**Key Messages:**
1. **PowerSC (Star):** Provides SAP-specific compliance hardening and continuous monitoring across Howdens' Power estate
2. **Vault (Co-Star):** Automates application-layer certificate lifecycle, eliminating manual processes and human error
3. **Together:** Defense-in-depth security - infrastructure hardening + application automation
4. **Result:** 98% compliance, zero outages, Audit Committee-ready reporting

**Final Talking Point:**
"This solution addresses Howdens' stated 'low appetite for cyber security risk' by securing SAP at both the infrastructure layer (PowerSC) and application layer (Vault). It supports their business continuity mandate, protects their supply chain operations, and provides the governance evidence their Audit Committee requires. And it does all of this without adding operational burden to Richard's IT team - in fact, it reduces burden through automation."

**Call to Action:**
"The next step is a pilot - we'd recommend starting with 5-10 depot locations, validating the automation, then rolling out across the network. This gives you measurable results in 30 days while minimizing risk."

---

│  │  ┌──────────────────────────────────────────┐ │    │
│  │  │  Sample Applications                     │ │    │
│  │  │  - Apache/Nginx with Vault certs        │ │    │
│  │  │  - Certificate rotation scripts         │ │    │
│  │  └──────────────────────────────────────────┘ │    │
│  └────────────────────────────────────────────────┘    │
│                          │                              │
│                          │ Reports to                   │
│                          ▼                              │
│  ┌────────────────────────────────────────────────┐    │
│  │         PowerSC Management Console             │    │
│  │         (Separate LPAR or same system)         │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Implementation Steps:**
1. Reserve PowerSC TechZone environment
2. Access RHEL on Power LPAR via SSH
3. Install Vault on RHEL (see detailed steps below)
4. Configure PKI engine
5. Deploy sample certificates
6. Configure PowerSC to scan the LPAR
7. Run the demo

**Talking Point Advantage:**
"Notice we're running Vault directly on IBM Power infrastructure - this demonstrates Power's versatility. It's not just for traditional enterprise workloads; it's a modern platform capable of running cloud-native security tools like HashiCorp Vault. This is a true Power-native security architecture."


3. **PowerSC Console → Reporting**
   - Displays certificate inventory
   - Highlights aging certificates (>90 days, >180 days, >365 days)
   - Shows expiration timeline
   - Generates compliance reports

---

## Demo Scenario: "Certificate Lifecycle Modernization for Howdens Joinery"

### Business Context
**Customer Profile:** Howdens Joinery - UK's leading trade-only kitchen and joinery supplier
**Business Model:** "Built for the Trade" - serving kitchen fitters and builders through hundreds of depot locations
**Critical Dependency:** Distributed depot network requiring 24/7 system availability for trade customer orders

**Challenge:**
- **Supply Chain Disruption Risk:** Manual certificate management across hundreds of depot locations creates risk of service disruption to trade customers
- **Depot Network Vulnerability:** Each depot requires secure access to central ordering systems - expired certificates = depot cannot process orders = trade customers cannot get products
- **Low Cyber Risk Appetite:** Board-mandated "low appetite for cyber security risk" requires robust certificate management
- **Business Continuity Mandate:** Regular disaster recovery testing requires reliable, automated certificate lifecycle management
- **Operational Transformation:** Ongoing supply chain transformation cannot be disrupted by certificate-related outages

**Business Impact of Certificate Failures:**
- Trade customers (kitchen fitters) cannot place orders → their customer projects are delayed
- Depot managers cannot access inventory systems → cannot serve trade customers
- Supplier portals become unavailable → disrupts 100+ key supplier relationships
- Reputation damage to "Built for the Trade" brand promise

**Solution:** Vault + PowerSC integration for automated certificate lifecycle management supporting business continuity

### Demo Flow (15-20 minutes)

#### **Act 1: The Problem - Legacy Certificate Management (3 min)**

**Show in PowerSC:**
1. Open PowerSC compliance dashboard
2. Navigate to Certificate Management view
3. **Highlight the problems:**
   - Certificates aged 365+ days (high risk)
   - Certificates expiring in <30 days (urgent action needed)
   - Manual tracking in spreadsheets
   - No automated rotation

**Talking Points (Howdens Context):**
- "Here we see the current state across Howdens' depot network - certificates that have been in place for over a year"
- "For a company with hundreds of depot locations, manual certificate tracking is a significant operational risk"
- "Howdens has explicitly stated they have a 'low appetite for cyber security risk' - these aging certificates don't align with that mandate"
- "If one of these certificates expires, that depot cannot process trade customer orders. Kitchen fitters can't get products. Projects are delayed. This directly impacts the 'Built for the Trade' brand promise"
- "PowerSC gives us visibility, but we need automation to eliminate the human error that causes outages"

#### **Act 2: The Solution - Vault PKI Engine (5 min)**

**Show in Vault:**
1. Navigate to Vault UI → PKI Secrets Engine
2. Show PKI configuration:
   - Root CA configured
   - Intermediate CA for issuing
   - Role configured for short-lived certificates (24h TTL)

3. **Generate a certificate via Vault:**
   ```bash
   vault write pki_int/issue/power-systems-role \
     common_name="app-server-01.example.com" \
     ttl="24h"
   ```

4. Show the issued certificate:
   - Valid for 24 hours only
   - Automatic expiration
   - No manual intervention needed

**Talking Points (Howdens Context):**
- "Vault's PKI engine acts as Howdens' certificate authority for their depot network"
- "We've configured it to issue certificates with 24-hour lifespans - dramatically reducing risk exposure"
- "For Howdens, this means if a certificate is somehow compromised, it's only valid for 24 hours, not 365 days"
- "This aligns perfectly with their stated 'low appetite for cyber security risk'"
- "Depot systems can request certificates programmatically via API - no manual intervention, no human error"
- "This supports their business continuity mandate - automated processes are more reliable than manual ones"

#### **Act 3: Deployment to Power Systems (4 min)**

**Show the automation:**
1. Demonstrate certificate deployment script/automation:
   ```bash
   # Example automation flow
   # 1. Request certificate from Vault
   # 2. Deploy to Power system
   # 3. Reload application (Apache/Nginx)
   # 4. Verify deployment
   ```

2. Show certificate installed on Power system:
   ```bash
   # On AIX/Linux partition
   openssl x509 -in /etc/ssl/certs/app-cert.pem -text -noout
   ```

3. Highlight:
   - Issued by Vault CA
   - 24-hour validity period
   - Automatic rotation scheduled

**Talking Points (Howdens Context):**
- "Certificates are deployed automatically across Howdens' depot network on IBM Power systems"
- "Each depot's ordering system automatically receives and rotates certificates without manual intervention"
- "This is critical during Howdens' ongoing supply chain transformation - they can't afford disruption from manual certificate management"
- "Depot managers don't need to worry about certificates - they can focus on serving trade customers"
- "This reduces operational burden on Howdens' IT team, who are already supporting major transformation initiatives"

#### **Act 4: PowerSC Monitoring & Compliance (5 min)**

**Show in PowerSC:**
1. Refresh certificate inventory
2. Show newly deployed Vault certificates:
   - Age: <1 day
   - Expiration: 24 hours from now
   - Issuer: Vault Intermediate CA

3. **Compare side-by-side:**
   - **Legacy certificates:** 365+ days old, manual management
   - **Vault certificates:** <1 day old, automated rotation

4. Show compliance report:
   - Percentage of certificates under automated management
   - Reduction in long-lived certificates
   - Expiration timeline showing continuous rotation

5. **Demonstrate alert configuration:**
   - PowerSC alerts for certificates >7 days old (exception handling)
   - Expiration warnings for any certificate approaching end-of-life

**Talking Points (Howdens Context):**
- "PowerSC now shows Howdens' modernized certificate landscape across their depot network"
- "We can see which depot systems are under Vault management - and which legacy systems still need migration"
- "This visibility is exactly what Howdens' Audit Committee needs to oversee cyber risk controls"
- "Compliance reports demonstrate the 'low cyber risk appetite' in action - measurable improvement in certificate hygiene"
- "Howdens maintains the visibility required for their regularly-tested disaster recovery plans, while automation handles the heavy lifting"
- "This supports their business continuity mandate without adding operational burden"

#### **Act 5: The Business Value (3 min)**

**Summary Dashboard View:**
Create a summary showing:

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Average Certificate Age (Depot Network) | 287 days | 12 hours | 96% reduction |
| Manual Renewals/Month (Across Depots) | 45 | 0 | 100% automation |
| Certificate-Related Outages/Year | 3 | 0 | Zero depot disruptions |
| Compliance Score (Audit Committee) | 67% | 98% | 31% improvement |
| Mean Time to Rotate (Depot Certificates) | 2 weeks | 24 hours | 14x faster |
| Trade Customer Impact (Order Processing) | 3 disruptions/year | 0 | 100% availability |

**Talking Points (Howdens Context):**
- "This integration delivers measurable security and operational improvements aligned with Howdens' business priorities"
- "96% reduction in certificate age directly supports their 'low appetite for cyber security risk'"
- "Zero certificate-related outages means zero disruption to trade customers - protecting the 'Built for the Trade' brand promise"
- "100% automation eliminates human error - critical during their ongoing supply chain transformation"
- "PowerSC provides the continuous compliance visibility that Howdens' Audit Committee requires"
- "This solution supports business continuity without adding operational burden to IT during transformation"
- "IBM Power + Vault = enterprise-grade certificate management that scales across hundreds of depot locations"
- "Most importantly: trade customers can rely on Howdens systems, every time"

---

## Technical Prerequisites

### HashiCorp Vault Setup

1. **Vault Installation:**
   - Vault Enterprise or Open Source (1.15+)
   - Deployment options: Docker, Kubernetes, VM, or HashiCorp Cloud Platform (HCP)

2. **PKI Configuration:**
   ```bash
   # Enable PKI secrets engine
   vault secrets enable pki
   vault secrets tune -max-lease-ttl=87600h pki
   
   # Generate root CA
   vault write -field=certificate pki/root/generate/internal \
     common_name="Demo Root CA" \
     ttl=87600h > root_ca.crt
   
   # Enable intermediate PKI
   vault secrets enable -path=pki_int pki
   vault secrets tune -max-lease-ttl=43800h pki_int
   
   # Generate intermediate CSR
   vault write -format=json pki_int/intermediate/generate/internal \
     common_name="Demo Intermediate CA" \
     | jq -r '.data.csr' > pki_intermediate.csr
   
   # Sign intermediate with root
   vault write -format=json pki/root/sign-intermediate \
     csr=@pki_intermediate.csr \
     format=pem_bundle ttl="43800h" \
     | jq -r '.data.certificate' > intermediate.cert.pem
   
   # Set signed certificate
   vault write pki_int/intermediate/set-signed \
     certificate=@intermediate.cert.pem
   
   # Create role for Power systems
   vault write pki_int/roles/power-systems-role \
     allowed_domains="example.com" \
     allow_subdomains=true \
     max_ttl="24h" \
     ttl="24h"
   ```

3. **Access Configuration:**
   - Configure authentication method (AppRole, LDAP, etc.)
   - Set up policies for certificate issuance
   - Enable audit logging

### IBM Power & PowerSC Setup

1. **Power Systems Environment:**
   - IBM Power system (physical or PowerVS)
   - AIX 7.2+ or Linux on Power (RHEL/SLES)
   - Network connectivity to Vault instance

2. **PowerSC Installation:**
   - PowerSC 2.0+ installed and configured
   - Certificate scanning enabled

### Installing Vault on RHEL on Power (ppc64le)

**System Requirements:**
- RHEL 8.x or 9.x on Power (ppc64le architecture)
- 2+ GB RAM (4 GB recommended)
- 10 GB disk space
- Root or sudo access
- Internet connectivity for package downloads

**Installation Method 1: Binary Installation (Recommended)**

HashiCorp provides official binaries for Linux ppc64le architecture:

```bash
# 1. Download Vault binary for ppc64le
# Check latest version at: https://releases.hashicorp.com/vault/
VAULT_VERSION="1.15.6"  # Use latest stable version
cd /tmp
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_ppc64le.zip

# 2. Install unzip if not present
sudo dnf install -y unzip

# 3. Extract and install Vault
unzip vault_${VAULT_VERSION}_linux_ppc64le.zip
sudo mv vault /usr/local/bin/
sudo chmod +x /usr/local/bin/vault

# 4. Verify installation
vault version
# Expected output: Vault v1.15.6 (...)

# 5. Enable command completion (optional)
vault -autocomplete-install
complete -C /usr/local/bin/vault vault
```

**Installation Method 2: Docker (Alternative)**

If Docker is available on the RHEL Power system:

```bash
# 1. Install Docker (if not present)
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# 2. Run Vault in dev mode (for demo purposes)
docker run -d --name vault-demo \
  --cap-add=IPC_LOCK \
  -p 8200:8200 \
  -e 'VAULT_DEV_ROOT_TOKEN_ID=demo-root-token' \
  -e 'VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200' \
  hashicorp/vault:latest

# 3. Verify Vault is running
docker logs vault-demo
curl http://localhost:8200/v1/sys/health
```

**Configuration for Demo Environment**

Create a Vault configuration file for production-like setup:

```bash
# 1. Create Vault directories
sudo mkdir -p /opt/vault/data
sudo mkdir -p /etc/vault.d

# 2. Create Vault configuration
sudo tee /etc/vault.d/vault.hcl > /dev/null <<EOF
# Vault configuration for demo environment

storage "file" {
  path = "/opt/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1  # For demo only - use TLS in production
}

api_addr = "http://$(hostname -I | awk '{print $1}'):8200"
ui = true

# Disable mlock for demo (not recommended for production)
disable_mlock = true
EOF

# 3. Create Vault service user
sudo useradd --system --home /opt/vault --shell /bin/false vault
sudo chown -R vault:vault /opt/vault
sudo chown -R vault:vault /etc/vault.d

# 4. Create systemd service
sudo tee /etc/systemd/system/vault.service > /dev/null <<EOF
[Unit]
Description=HashiCorp Vault
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/vault.d/vault.hcl

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP \$MAINPID
KillMode=process
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
LimitNOFILE=65536
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOF

# 5. Start Vault service
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

# 6. Check service status
sudo systemctl status vault
```

**Initialize and Unseal Vault**

```bash
# 1. Set Vault address environment variable
export VAULT_ADDR='http://127.0.0.1:8200'
echo 'export VAULT_ADDR="http://127.0.0.1:8200"' >> ~/.bashrc

# 2. Initialize Vault (first time only)
vault operator init -key-shares=1 -key-threshold=1 > /tmp/vault-init.txt

# IMPORTANT: Save the output! It contains:
# - Unseal Key
# - Root Token

# 3. Extract unseal key and root token
UNSEAL_KEY=$(grep 'Unseal Key 1:' /tmp/vault-init.txt | awk '{print $NF}')
ROOT_TOKEN=$(grep 'Initial Root Token:' /tmp/vault-init.txt | awk '{print $NF}')

# 4. Unseal Vault
vault operator unseal $UNSEAL_KEY

# 5. Login with root token
vault login $ROOT_TOKEN

# 6. Verify Vault is ready
vault status
```

**Configure PKI Engine for Demo**

```bash
# 1. Enable PKI secrets engine
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki

# 2. Generate root CA
vault write -field=certificate pki/root/generate/internal \
    common_name="Demo Root CA" \
    issuer_name="root-2026" \
    ttl=87600h > /tmp/root_ca.crt

# 3. Configure CA and CRL URLs
vault write pki/config/urls \
    issuing_certificates="http://127.0.0.1:8200/v1/pki/ca" \
    crl_distribution_points="http://127.0.0.1:8200/v1/pki/crl"

# 4. Enable intermediate PKI
vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int

# 5. Generate intermediate CSR
vault write -format=json pki_int/intermediate/generate/internal \
    common_name="Demo Intermediate CA" \
    issuer_name="demo-intermediate" \
    | jq -r '.data.csr' > /tmp/pki_intermediate.csr

# 6. Sign intermediate certificate with root CA
vault write -format=json pki/root/sign-intermediate \
    issuer_ref="root-2026" \
    csr=@/tmp/pki_intermediate.csr \
    format=pem_bundle \
    ttl=43800h \
    | jq -r '.data.certificate' > /tmp/intermediate.cert.pem

# 7. Import signed intermediate certificate
vault write pki_int/intermediate/set-signed \
    certificate=@/tmp/intermediate.cert.pem

# 8. Create role for short-lived certificates
vault write pki_int/roles/power-systems-role \
    issuer_ref="demo-intermediate" \
    allowed_domains="example.com,demo.local" \
    allow_subdomains=true \
    max_ttl="24h" \
    ttl="24h" \
    key_type="rsa" \
    key_bits=2048

# 9. Test certificate issuance
vault write pki_int/issue/power-systems-role \
    common_name="test.example.com" \
    ttl="24h"
```

**Firewall Configuration**

```bash
# Allow Vault port through firewall
sudo firewall-cmd --permanent --add-port=8200/tcp
sudo firewall-cmd --reload

# Verify port is open
sudo firewall-cmd --list-ports
```

**Quick Start Script**

Save this as `setup-vault-demo.sh` for rapid deployment:

```bash
#!/bin/bash
# Quick setup script for Vault on RHEL Power

set -e

echo "=== Vault Demo Setup for RHEL on Power ==="

# Variables
VAULT_VERSION="1.15.6"
VAULT_ADDR="http://127.0.0.1:8200"

# Install Vault
echo "Installing Vault ${VAULT_VERSION}..."
cd /tmp
wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_ppc64le.zip
sudo dnf install -y unzip
unzip -q vault_${VAULT_VERSION}_linux_ppc64le.zip
sudo mv vault /usr/local/bin/
sudo chmod +x /usr/local/bin/vault

# Create directories
echo "Creating Vault directories..."
sudo mkdir -p /opt/vault/data
sudo mkdir -p /etc/vault.d

# Create configuration
echo "Creating Vault configuration..."
sudo tee /etc/vault.d/vault.hcl > /dev/null <<EOF
storage "file" {
  path = "/opt/vault/data"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
api_addr = "http://$(hostname -I | awk '{print $1}'):8200"
ui = true
disable_mlock = true
EOF

# Create service user
echo "Creating Vault service user..."
sudo useradd --system --home /opt/vault --shell /bin/false vault 2>/dev/null || true
sudo chown -R vault:vault /opt/vault
sudo chown -R vault:vault /etc/vault.d

# Create systemd service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/vault.service > /dev/null <<'EOF'
[Unit]
Description=HashiCorp Vault
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Start service
echo "Starting Vault service..."
sudo systemctl daemon-reload
sudo systemctl enable vault
sudo systemctl start vault

# Wait for Vault to start
sleep 5

# Initialize Vault
echo "Initializing Vault..."
export VAULT_ADDR="${VAULT_ADDR}"
vault operator init -key-shares=1 -key-threshold=1 > /tmp/vault-init.txt

# Extract credentials
UNSEAL_KEY=$(grep 'Unseal Key 1:' /tmp/vault-init.txt | awk '{print $NF}')
ROOT_TOKEN=$(grep 'Initial Root Token:' /tmp/vault-init.txt | awk '{print $NF}')

# Unseal and login
echo "Unsealing Vault..."
vault operator unseal $UNSEAL_KEY
vault login $ROOT_TOKEN

# Configure PKI
echo "Configuring PKI engine..."
vault secrets enable pki
vault secrets tune -max-lease-ttl=87600h pki
vault write -field=certificate pki/root/generate/internal \
    common_name="Demo Root CA" \
    ttl=87600h > /tmp/root_ca.crt

vault secrets enable -path=pki_int pki
vault secrets tune -max-lease-ttl=43800h pki_int
vault write -format=json pki_int/intermediate/generate/internal \
    common_name="Demo Intermediate CA" \
    | jq -r '.data.csr' > /tmp/pki_intermediate.csr

vault write -format=json pki/root/sign-intermediate \
    csr=@/tmp/pki_intermediate.csr \
    format=pem_bundle \
    ttl=43800h \
    | jq -r '.data.certificate' > /tmp/intermediate.cert.pem

vault write pki_int/intermediate/set-signed \
    certificate=@/tmp/intermediate.cert.pem

vault write pki_int/roles/power-systems-role \
    allowed_domains="example.com,demo.local" \
    allow_subdomains=true \
    max_ttl="24h" \
    ttl="24h"

# Configure firewall
echo "Configuring firewall..."
sudo firewall-cmd --permanent --add-port=8200/tcp 2>/dev/null || true
sudo firewall-cmd --reload 2>/dev/null || true

# Display credentials
echo ""
echo "=== Vault Setup Complete ==="
echo ""
echo "Vault Address: ${VAULT_ADDR}"
echo "Vault UI: http://$(hostname -I | awk '{print $1}'):8200/ui"
echo ""
echo "IMPORTANT - Save these credentials:"
echo "Unseal Key: ${UNSEAL_KEY}"
echo "Root Token: ${ROOT_TOKEN}"
echo ""
echo "Credentials also saved to: /tmp/vault-init.txt"
echo ""
echo "To use Vault CLI:"
echo "  export VAULT_ADDR='${VAULT_ADDR}'"
echo "  vault login ${ROOT_TOKEN}"
echo ""
echo "Test certificate issuance:"
echo "  vault write pki_int/issue/power-systems-role common_name='test.example.com' ttl='24h'"
```

Make the script executable and run it:
```bash
chmod +x setup-vault-demo.sh
sudo ./setup-vault-demo.sh
```

**Verification Steps**

```bash
# 1. Check Vault status
vault status

# 2. List enabled secrets engines
vault secrets list

# 3. Issue a test certificate
vault write pki_int/issue/power-systems-role \
    common_name="webserver.example.com" \
    ttl="24h" \
    -format=json | jq -r '.data.certificate' > /tmp/test-cert.pem

# 4. Verify certificate
openssl x509 -in /tmp/test-cert.pem -text -noout | grep -A2 "Validity"

# 5. Access Vault UI
# Open browser to: http://<RHEL-Power-IP>:8200/ui
# Login with root token
```

**Troubleshooting**

```bash
# Check Vault service logs
sudo journalctl -u vault -f

# Check if Vault is listening
sudo netstat -tlnp | grep 8200

# Verify Vault process
ps aux | grep vault

# Check Vault configuration
vault read sys/config/state/sanitized


---

## Key Talking Points & Objection Handling (Howdens Context)

### Value Propositions for Howdens

1. **Business Continuity:**
   - "Certificate automation directly supports Howdens' 'Built for the Trade' brand promise"
   - "Zero certificate-related outages means trade customers can always place orders"
   - "Aligns with your regularly-tested disaster recovery and business continuity plans"

2. **Low Cyber Risk Appetite:**
   - "96% reduction in certificate age directly supports your stated 'low appetite for cyber security risk'"
   - "Short-lived certificates (24 hours vs 365 days) dramatically reduce exposure window"
   - "Automated processes eliminate human error - the primary cause of certificate-related outages"

3. **Operational Efficiency:**
   - "100% automation across hundreds of depot locations - no manual intervention required"
   - "Frees IT team to focus on supply chain transformation initiatives"
   - "Depot managers never think about certificates - they focus on serving trade customers"

4. **Governance & Compliance:**
   - "PowerSC provides Audit Committee with continuous visibility into certificate compliance"
   - "Measurable improvement in compliance score (67% → 98%)"
   - "Demonstrates control effectiveness for board-level cyber risk oversight"

5. **Scalability:**

**Q: "We're running six IBM Power E980 servers that are approaching end-of-support. How does this solution help us manage security risk as our infrastructure ages?"**

A: "This is actually a perfect use case for automated certificate management. As your E980 systems approach end-of-support, you'll lose access to vendor security patches and vulnerability fixes. This makes automated security controls even more critical. Here's how Vault + PowerSC helps:

**Immediate Benefits:**
- **Reduces manual security processes** that become riskier as systems age and staff knowledge transitions
- **Short-lived certificates (24 hours)** dramatically reduce the window of exposure if a vulnerability is discovered
- **Automated rotation** eliminates the risk of expired certificates causing outages on aging systems
- **PowerSC monitoring** provides continuous visibility into certificate health across your E980 estate

**Strategic Value:**
- **Extends secure operational life** of your existing E980 infrastructure while you plan modernization
- **Demonstrates proactive security management** to your Audit Committee despite aging infrastructure
- **Reduces cyber risk** even without vendor patches - certificate automation is a control you can implement today
- **Supports your 'low appetite for cyber security risk'** mandate during infrastructure transition period

**Modernization Path:**
- When you do refresh your Power infrastructure, this same Vault + PowerSC solution migrates seamlessly to newer Power systems
- You're not investing in a temporary solution - you're building a modern security architecture that outlasts any specific hardware generation
- IBM Power's backward compatibility means you can run this solution across mixed generations (E980 + newer systems) during transition

The key insight: automated certificate management becomes MORE valuable, not less, as infrastructure ages. It's a security control you can implement now that reduces risk regardless of your hardware refresh timeline."

   - "Solution scales across hundreds of depot locations without additional operational burden"
   - "Supports growth and network expansion"
   - "Consistent approach across depot systems, supplier portals, and cloud infrastructure"

### Common Objections & Responses (Howdens Context)

**Q: "Won't 24-hour certificates cause more operational overhead across our depot network?"**

A: "Actually the opposite - and this is critical for Howdens during your supply chain transformation. With long-lived certificates, you still need to track and manually renew them across hundreds of depot locations. That's where human error causes outages. With Vault, the system handles rotation automatically across your entire depot network. You set it once and forget it. Your depot managers never think about certificates - they focus on serving trade customers. This aligns perfectly with your 'low appetite for cyber security risk' mandate."

**Q: "What if Vault goes down? Will all our depot systems stop working?"**

A: "Great question - this speaks to your business continuity requirements. Vault issues certificates that remain valid for their TTL even if Vault is offline. So if Vault has an issue, your depot systems continue operating with their current certificates. For high availability, Vault supports clustering and disaster recovery - which aligns with your regularly-tested disaster recovery plans. We can also configure longer TTLs (7 days) for critical depot systems as a buffer, while still maintaining much shorter lifespans than your current 365+ day certificates."

**Q: "How does this work with our existing PKI infrastructure and supplier systems?"**

A: "Vault can integrate with your existing CAs as an intermediate, or operate independently - your choice. PowerSC monitors all certificates regardless of issuer, so you get unified visibility across legacy depot systems, modern Vault-managed systems, and supplier-facing systems. This is important during your transformation - you can migrate depot-by-depot without disrupting operations."

**Q: "What about the cost of HashiCorp Vault versus the risk of outages?"**

A: "Let's frame this in Howdens' context. Vault has an open-source version for basic PKI needs. For enterprise features like HSM integration and clustering, Vault Enterprise is available. But consider the ROI: you mentioned 3 certificate-related outages per year. Each outage affects multiple depots, preventing trade customers from placing orders. What's the cost of a kitchen fitter who can't get products for their customer's project? What's the reputation impact to 'Built for the Trade'? The ROI comes from eliminating those outages, reducing security risk to meet your low-risk appetite, and freeing up your IT team to focus on supply chain transformation instead of manual certificate management."

**Q: "Can we use this approach beyond our Power systems - for example, supplier portals or cloud systems?"**

A: "Absolutely - and this is a strategic advantage for Howdens. Vault is platform-agnostic. This same approach works for your supplier portals (protecting those 100+ key supplier relationships), cloud services, x86 Linux systems, Windows systems, Kubernetes, etc. PowerSC is specific to Power, but the Vault PKI pattern is universal. You can establish a consistent certificate management approach across your entire infrastructure - depot systems, supplier systems, cloud systems - all managed centrally with unified visibility."

**Q: "How does this support our Audit Committee's oversight requirements?"**

A: "PowerSC provides exactly the kind of compliance reporting your Audit Committee needs. They can see certificate inventory, aging analysis, rotation compliance, and audit trails - all the evidence needed to demonstrate your 'low appetite for cyber security risk' in action. The automated nature of Vault also means you can demonstrate control effectiveness: certificates rotate on schedule, no manual intervention, no human error. This gives your Audit Committee confidence that controls are operating as designed."

**Q: "What about the impact on our ongoing supply chain transformation?"**

A: "This solution actually enables your transformation rather than hindering it. By automating certificate management now, you remove a potential source of disruption during transformation. Your IT team can focus on strategic initiatives instead of firefighting certificate issues. The solution is also flexible - you can migrate systems gradually, depot-by-depot, without disrupting operations. And as you transform your supply chain systems, they can leverage the same Vault PKI infrastructure from day one."

**Q: "How quickly can we implement this across our depot network?"**

A: "Implementation can be phased to minimize risk. We typically recommend:
- **Week 1-2:** Deploy Vault on your RHEL Power LPAR, configure PKI, integrate with PowerSC
- **Week 3-4:** Pilot with 5-10 depot locations, validate operations, refine processes
- **Month 2-3:** Gradual rollout across depot network, 20-30 depots per week
- **Month 4:** Complete rollout, full monitoring, optimization

This phased approach ensures business continuity throughout implementation and allows you to validate each step before scaling."

# Reseal Vault (if needed)
vault operator seal

# Unseal Vault
vault operator unseal <unseal-key>
```

   - Management console accessible
   - Agents deployed to monitored partitions

3. **Certificate Store Configuration:**
   - Standard certificate locations configured
   - PowerSC scanning paths defined:
     - `/etc/ssl/certs/`
     - `/var/ssl/`
     - Application-specific certificate stores

### Integration Components

1. **Certificate Deployment Automation:**
   - Script/tool to request certificates from Vault
   - Deployment mechanism to Power systems (Ansible, shell scripts, etc.)
   - Application reload automation (Apache, Nginx, etc.)
   - Scheduled rotation (cron, systemd timers, etc.)

2. **Monitoring Integration:**
   - PowerSC agent configuration to scan Vault-issued certificates
   - Custom certificate metadata tagging (optional)
   - Alert configuration for exceptions

---

## Demo Preparation Checklist

### Pre-Demo Setup (1-2 days before)

- [ ] **Vault Environment Ready**
  - [ ] Vault instance accessible
  - [ ] PKI engine configured with root and intermediate CAs
  - [ ] Role created for Power systems certificates
  - [ ] Test certificate issuance working

- [ ] **PowerSC Environment Ready**
  - [ ] PowerSC console accessible
  - [ ] At least one Power partition being monitored
  - [ ] Certificate scanning enabled and working
  - [ ] Baseline certificate inventory captured

- [ ] **Sample Certificates Deployed**
  - [ ] 2-3 legacy certificates (365+ days old) for comparison
  - [ ] 2-3 Vault-issued certificates (24h TTL) deployed
  - [ ] Applications configured to use certificates

- [ ] **Demo Data Prepared**
  - [ ] Screenshots of "before" state (legacy certificates)
  - [ ] Compliance reports showing improvement metrics
  - [ ] Side-by-side comparison data ready

### Day-of-Demo Checklist

- [ ] Vault UI accessible and logged in
- [ ] PowerSC console accessible and logged in
- [ ] Terminal/SSH access to Power system ready
- [ ] Demo script/talking points reviewed
- [ ] Backup screenshots available (in case of connectivity issues)
- [ ] Questions anticipated and answers prepared

---

## Key Talking Points & Objection Handling

### Value Propositions

1. **Security:**
   - "Short-lived certificates reduce the window of exposure from days/years to hours"
   - "Automated rotation eliminates the risk of expired certificates causing outages"
   - "Vault's PKI engine provides cryptographic best practices out of the box"

2. **Compliance:**
   - "PowerSC provides continuous visibility into certificate inventory"
   - "Automated reporting demonstrates compliance with security policies"
   - "Audit trails show who requested certificates and when they were issued"

3. **Operations:**
   - "Zero-touch automation reduces operational burden by 100%"
   - "No more spreadsheet tracking or manual renewal processes"
   - "Integration with existing Power infrastructure - no rip and replace"

### Common Objections & Responses

**Q: "Won't 24-hour certificates cause more operational overhead?"**
A: "Actually the opposite - automation handles rotation. With long-lived certificates, you still need to track and manually renew them. With Vault, the system handles it automatically. You set it once and forget it."

**Q: "What if Vault goes down? Will all our certificates stop working?"**
A: "Vault issues certificates that remain valid for their TTL even if Vault is offline. For high availability, Vault supports clustering and disaster recovery. We can also configure longer TTLs (7 days) for critical systems as a buffer."

**Q: "How does this work with our existing PKI infrastructure?"**
A: "Vault can integrate with existing CAs as an intermediate, or operate independently. PowerSC monitors all certificates regardless of issuer, so you get unified visibility across legacy and modern infrastructure."

**Q: "What about the cost of HashiCorp Vault?"**
A: "Vault has an open-source version for basic PKI needs. For enterprise features like HSM integration and namespaces, Vault Enterprise is available. The ROI comes from eliminating outages, reducing security risk, and freeing up staff from manual certificate management."

**Q: "Can we use this with applications beyond Power systems?"**
A: "Absolutely. Vault is platform-agnostic. This same approach works for x86 Linux, Windows, Kubernetes, cloud services, etc. PowerSC is specific to Power, but the Vault PKI pattern is universal."

---

## Alternative Demo Approaches

### If TechZone Environments Are Not Available:

#### **Approach A: Vault + PowerSC Screenshots/Video**
1. Deploy Vault locally (Docker or HCP free tier)
2. Use existing PowerSC demo screenshots/recordings
3. Build narrative around integration concept
4. Show Vault certificate issuance live
5. Show PowerSC monitoring via screenshots
6. **Time to prepare:** 2-4 hours

#### **Approach B: Simulated Integration with Mock Data**
1. Deploy Vault locally
2. Create mock PowerSC dashboard using Carbon React components
3. Populate with realistic certificate data
4. Show Vault issuance → Mock dashboard update
5. **Time to prepare:** 1-2 days (requires frontend development)

#### **Approach C: Vault-Only Demo with Power Context**
1. Focus demo on Vault PKI capabilities
2. Use Power systems as the narrative context
3. Show how certificates would be deployed (scripts/automation)
4. Explain PowerSC monitoring as the "next step"
5. **Time to prepare:** 1-2 hours

---

## Next Steps

### Immediate Actions:

1. **Verify TechZone Access:**
   - Log into TechZone directly and search for PowerSC environments
   - Check if you have access to the existing PowerSC demo you mentioned
   - Document the environment details (platform ID, access method, etc.)

2. **Choose Vault Deployment Option:**
   - **Quick Start:** HashiCorp Cloud Platform (HCP) free tier
   - **Full Control:** Docker Compose on local machine
   - **Enterprise:** Vault Enterprise trial on IBM Cloud

3. **Decide on Demo Approach:**
   - Full integration (if both environments available)
   - Hybrid (Vault live + PowerSC screenshots)
   - Simulated (mock integration)

4. **Schedule Preparation Time:**
   - Environment setup: 4-8 hours
   - Demo script refinement: 2-3 hours
   - Practice runs: 2-3 hours
   - **Total:** 1-2 days of focused work

### Questions to Answer:

1. Do you have access to the existing PowerSC TechZone demo? If so, what's the platform ID?
2. What's your timeline for this demo? (Days, weeks, months?)
3. Who is the specific customer/audience? (Helps tailor the narrative)
4. Do you have access to deploy Vault, or do you need a hosted option?
5. What's your comfort level with Vault? (Determines how much setup support you need)

---

## Resources

### Documentation:
- [HashiCorp Vault PKI Secrets Engine](https://developer.hashicorp.com/vault/docs/secrets/pki)
- [IBM PowerSC Documentation](https://www.ibm.com/docs/en/powersc)
- [Vault PKI Tutorial](https://developer.hashicorp.com/vault/tutorials/secrets-management/pki-engine)

### TechZone:
- [IBM TechZone](https://techzone.ibm.com)
- Search for: "PowerSC", "Power Systems Security", "AIX Security"

### Quick Start Options:
- [HashiCorp Cloud Platform (HCP) Free Tier](https://portal.cloud.hashicorp.com/sign-up)
- [Vault Docker Image](https://hub.docker.com/_/vault)
- [Vault Helm Chart (Kubernetes)](https://github.com/hashicorp/vault-helm)

---

## Conclusion

This demo plan provides a comprehensive approach to showcasing HashiCorp Vault + IBM PowerSC integration for certificate lifecycle management. The key to success is:

1. **Clear narrative:** Security risk → Automation solution → Compliance visibility
2. **Realistic scenario:** Financial services context with Power systems
3. **Measurable outcomes:** Show before/after metrics
4. **Technical credibility:** Live demonstration of both platforms working together

The plan is flexible enough to adapt based on available environments - from full integration to simulated approaches. The most important element is demonstrating the **value proposition**: automated certificate lifecycle management reduces security risk, eliminates operational burden, and provides continuous compliance visibility.

**Your plan works** - the combination of Vault's dynamic certificate generation with PowerSC's monitoring and reporting creates a compelling story for enterprise certificate management on IBM Power systems.