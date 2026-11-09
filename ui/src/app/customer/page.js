'use client';
import {
  Grid,
  Column,
  Tile,
  Tag,
  Accordion,
  AccordionItem,
  StructuredListWrapper,
  StructuredListBody,
  StructuredListRow,
  StructuredListCell,
  Button,
} from '@carbon/react';
import { Warning, ArrowRight, User, Enterprise } from '@carbon/icons-react';
import styles from './customer-page.module.scss';

// ─── Section A — Industry Risk Anchor ────────────────────────────────────────
// This section is STATIC. It does not change between customers.
// The JLR case study is the industry proof-point that establishes urgency.

const JLR_STATS = [
  { value: '£1.9B', label: 'Total losses', sub: 'Classified Category 3 systemic event' },
  { value: '5 weeks', label: 'Production shutdown', sub: 'Solihull, Halewood, Wolverhampton' },
  { value: '5,000+', label: 'Businesses impacted', sub: 'Across JLR supply chain' },
  { value: '5 months', label: 'Full recovery time', sub: 'Supply chain back to normal Jan 2026' },
];

const JLR_TIMELINE = [
  { when: 'Aug 2025', what: 'Scattered Lapsus Hunters exploit JLR PKI — rogue certificates generated, lateral movement across IT and OT networks' },
  { when: 'Sep 2025', what: 'Five-week assembly shutdown begins. UK car production falls 27% — sharpest monthly decline since 1952' },
  { when: 'Oct 2025', what: 'Phased restart. 5,000+ supply chain businesses facing cash-flow freeze. SMEs pushed to brink of bankruptcy' },
  { when: 'Nov 2025', what: 'Full production capacity restored at UK plants. Financial and reputational damage ongoing' },
  { when: 'Jan 2026', what: 'Supply chain achieves full recovery — five months after initial breach' },
];

// ─── Section B — Customer Context ────────────────────────────────────────────
// This section IS CUSTOMISED per customer.
// Tailored for Danish Critical Infrastructure & Transport.
// When the seller re-bakes this demo, they replace the CUSTOMER_CONTEXT object
// and the PERSONAS array using the IBM Consulting Advantage story-builder skill.

const CUSTOMER_CONTEXT = {
  name: 'Critical Infrastructure & Enterprise Services',
  tagline: '"Operational Continuity & NIS2 Resilience"',
  industry: 'Transport, Public Sector, Utilities & Industrial Services (Denmark)',
  source: 'Danish Cyber Threat Assessment 2026 & NIS2 Resilience Framework',
  riskStatement:
    'Denmark Centre for Cyber Security assessment: Cyber Espionage (Very High), Cyber Crime (Very High), Cyber Activism (High). ' +
    'Recent waves of cyber incidents affecting ~40 Danish entities (including public transport ticketing, central government portals, courts, and industrial manufacturing) ' +
    'highlight that modern disruption directly impacts operational services citizens and businesses rely on. ' +
    'Under NIS2 and the National Cyber Strategy 2026–2029, the mandate is clear: prove resilience, eliminate unmanaged identity and cryptographic vulnerabilities, and maintain uninterrupted service delivery.',
  keyFacts: [
    'Critical Public & Commercial Services: Transport ticketing (e.g. Rejsekort), government portals, regional services, and manufacturing',
    'Infrastructure Reality: Mission-critical core workloads running on robust enterprise platforms (IBM Power, Linux, AIX)',
    'The Operational Risk: Long-lived credentials and manual certificate tracking create blind spots and risk of unplanned service disruption',
    'Regulatory Driver (NIS2): Heightened expectations for supply chain security, automated posture verification, and rapid incident recovery',
    'Resilience Goal: Transition from reactive manual renewals to automated zero-touch PKI lifecycle management and continuous compliance visibility',
  ],
  systemicRiskNote:
    'Modern enterprise environments connect hundreds of distributed operational endpoints back to core transactional systems. ' +
    'When identity, cryptographic keys, or certificates are managed manually across distributed systems, they create fertile ground for lateral movement and single points of operational failure.',
};

const PERSONAS = [
  {
    name: 'Infrastructure & Operations Leadership',
    title: 'Enterprise Architecture, Platform Engineering & IT Operations',
    focus: 'Operational continuity and eliminating unplanned service outages caused by expired credentials.',
    perspective: 'How do we automate certificate lifecycles across core platforms to ensure 100% operational uptime without manual overhead?',
    value: 'HashiCorp Vault provides zero-touch automated issuance and rotation, removing manual spreadsheets and eliminating expiry risk.',
  },
  {
    name: 'Security, Risk & Compliance Leadership',
    title: 'CISO Office, Cyber Defence & Regulatory Compliance (NIS2)',
    focus: 'Eliminating weak cryptography, preventing lateral movement, and maintaining continuous audit readiness.',
    perspective: 'How do we continuously verify our cryptographic posture and prove resilience across legacy and modern workloads to regulators?',
    value: 'IBM PowerSC provides automated posture scanning and quantum-safety scoring to verify compliance in real time.',
  },
];

export default function CustomerPage() {
  return (
    <Grid className={styles.page} fullWidth>

      {/* Page title */}
      <Column lg={16} md={8} sm={4} className={styles.pageTitle}>
        <h1 className={styles.heading}>Customer Context & Operational Resilience</h1>
        <p className={styles.subheading}>
          Aligning infrastructure security and PKI automation with Danish critical infrastructure priorities,
          NIS2 regulatory expectations, and enterprise risk management.
        </p>
      </Column>

      {/* ── SECTION 1 — Danish Landscape & Audience Alignment (Top) ──────── */}
      <Column lg={16} md={8} sm={4} className={styles.sectionDivider}>
        <div className={styles.sectionLabel}>
          <Tag type="blue">Section 1 — Critical Infrastructure Context & Stakeholders</Tag>
          <p className={styles.sectionNote}>
            Danish threat landscape, NIS2 regulatory drivers, and key operational stakeholders.
          </p>
        </div>
      </Column>

      {/* Customer overview */}
      <Column lg={8} md={8} sm={4} className={styles.customerCard}>
        <Tile className={styles.customerTile}>
          <div className={styles.customerHeader}>
            <Enterprise size={20} />
            <span className={styles.customerName}>{CUSTOMER_CONTEXT.name}</span>
            <Tag type="outline" size="sm">{CUSTOMER_CONTEXT.tagline}</Tag>
          </div>
          <p className={styles.customerIndustry}>{CUSTOMER_CONTEXT.industry}</p>
          <p className={styles.customerSource}>Source: {CUSTOMER_CONTEXT.source}</p>
          <h4 className={styles.riskHeading}>Threat Landscape & Context</h4>
          <p className={styles.riskBody}>{CUSTOMER_CONTEXT.riskStatement}</p>
          <h4 className={styles.factsHeading}>Key Industry Drivers</h4>
          <ul className={styles.factsList}>
            {CUSTOMER_CONTEXT.keyFacts.map((f, i) => (
              <li key={i}>{f}</li>
            ))}
          </ul>
        </Tile>
      </Column>

      {/* Stakeholders in the Room */}
      <Column lg={8} md={8} sm={4} className={styles.customerCard}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem', height: '100%' }}>
          {PERSONAS.map((p, i) => (
            <Tile key={i} className={styles.personaTile} style={{ height: 'auto', flex: 1 }}>
              <div className={styles.personaHeader}>
                <User size={16} />
                <strong className={styles.personaName}>{p.name}</strong>
              </div>
              <p className={styles.personaTitle}>{p.title}</p>
              <p className={styles.personaConcern}><em>Core Focus:</em> {p.focus}</p>
              <p className={styles.personaQuestion}>&ldquo;{p.perspective}&rdquo;</p>
              <p className={styles.personaHook}><strong>Solution Delivery:</strong> {p.value}</p>
            </Tile>
          ))}
        </div>
      </Column>

      {/* ── SECTION 2 — Systemic PKI Risk & Industry Case Study ─────────── */}
      <Column lg={16} md={8} sm={4} className={styles.sectionDivider} style={{ marginTop: '1.5rem' }}>
        <div className={styles.sectionLabel}>
          <Tag type="red">Section 2 — The Systemic Risk: Why Manual PKI Fails</Tag>
          <p className={styles.sectionNote}>
            How unmanaged certificates and weak cryptography create lateral movement attack paths.
          </p>
        </div>
      </Column>

      <Column lg={16} md={8} sm={4} className={styles.jlrBanner}>
        <Warning size={20} className={styles.warningIcon} />
        <div>
          <p className={styles.jlrHeadline}>
            Case Study: Jaguar Land Rover — £1.9B systemic loss from exploited PKI and lateral movement
          </p>
          <p className={styles.jlrBody}>
            In August 2025, attackers exploited JLR&apos;s internal certificate infrastructure — generating rogue
            certificates that enabled lateral movement across corporate IT and operational networks. The incident
            resulted in a five-week production shutdown across multiple facilities and severely impacted over 5,000
            supply chain businesses. Classified as a Category 3 systemic event by the Cyber Monitoring Centre.{' '}
            <strong>The root cause was manual PKI governance and unmanaged internal trust.</strong>
          </p>
        </div>
      </Column>

      {/* JLR stat tiles */}
      <Column lg={16} md={8} sm={4} className={styles.statRow}>
        <Grid narrow>
          {JLR_STATS.map((s, i) => (
            <Column key={i} lg={4} md={4} sm={4}>
              <Tile className={styles.statTile}>
                <p className={styles.statValue}>{s.value}</p>
                <p className={styles.statLabel}>{s.label}</p>
                <p className={styles.statSub}>{s.sub}</p>
              </Tile>
            </Column>
          ))}
        </Grid>
      </Column>

      {/* JLR timeline */}
      <Column lg={10} md={8} sm={4} className={styles.timelineSection}>
        <Accordion>
          <AccordionItem title="Incident Analysis: PKI exploit and lateral escalation timeline">
            <StructuredListWrapper>
              <StructuredListBody>
                {JLR_TIMELINE.map((row, i) => (
                  <StructuredListRow key={i}>
                    <StructuredListCell className={styles.timelineWhen}>{row.when}</StructuredListCell>
                    <StructuredListCell>{row.what}</StructuredListCell>
                  </StructuredListRow>
                ))}
              </StructuredListBody>
            </StructuredListWrapper>
          </AccordionItem>
        </Accordion>
      </Column>

      <Column lg={6} md={8} sm={4} className={styles.talkingPointBox}>
        <h4 className={styles.tpHeading}>Key Takeaway for Critical Operations</h4>
        <p className={styles.tpBody}>
          Unmanaged, long-lived certificates are more than an administrative nuisance — they are a high-value attack
          surface. When organisations lack automated lifecycle control, compromised or unrotated certificates can be used
          to establish persistent, undetected lateral access across core services.
        </p>
      </Column>

      {/* CTA */}
      <Column lg={16} md={8} sm={4} className={styles.ctaRow}>
        <p className={styles.ctaLabel}>Story established. Ready to show the demo.</p>
        <Button renderIcon={ArrowRight} href="/" kind="primary" className={styles.ctaButton}>
          Start the Demo — The Challenge
        </Button>
      </Column>

    </Grid>
  );
}

// Made with Bob
