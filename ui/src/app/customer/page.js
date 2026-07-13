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
// The Howdens Joinery worked example is pre-loaded here.
// When the seller re-bakes this demo, they replace the CUSTOMER_CONTEXT object
// and the PERSONAS array using the IBM Consulting Advantage story-builder skill.

const CUSTOMER_CONTEXT = {
  name: 'Howdens Joinery',
  tagline: '"Built for the Trade"',
  industry: 'Trade Distribution — UK kitchen and joinery supplier',
  source: 'IBM Consulting Advantage analysis of Howdens 2025 Annual Report',
  riskStatement:
    'Explicit board-level mandate: "low appetite for cyber security risk." ' +
    'Hundreds of depot locations depend on continuous SAP availability to serve ' +
    'trade customers. A certificate-related outage preventing depot access to SAP ' +
    'is directly equivalent to closing depots.',
  keyFacts: [
    'UK's leading trade-only kitchen supplier — 900+ depots',
    'Six IBM Power E980 servers running SAP in production landscape',
    '100+ key suppliers exchanging verified data through certificate-protected channels',
    'Distributed depot network — each depot depends on certificate-based SAP connectivity',
    'Audit Committee oversees cyber security governance at board level',
    'Brand promise: trade customers depend on Howdens systems 24/7',
  ],
  parallelToJLR:
    'Distributed operational network connected to central SAP systems — ' +
    'the same IT/OT convergence pattern that made JLR vulnerable. ' +
    'A certificate-based lateral movement attack could sever depot access to SAP, ' +
    'preventing trade orders and triggering supply chain disruption across 100+ suppliers.',
};

const PERSONAS = [
  {
    name: 'Richard Sutcliffe',
    title: 'Supply Chain & IT Director (Executive Committee)',
    concern: 'Business continuity for the depot network. Any outage that prevents trade customers from placing orders is unacceptable.',
    question: '"Can you guarantee our depot network stays operational if a certificate issue occurs?"',
    hook: 'Show the AFTER state — zero manual steps, continuous monitoring, automated rotation. Depots never miss a certificate renewal.',
  },
  {
    name: 'Jackie Callaway',
    title: 'CFO + Audit Committee',
    concern: 'Governance, measurable risk reduction, and board-level reporting. Needs numbers she can put in front of the Audit Committee.',
    question: '"How do we demonstrate to the Audit Committee that our certificate risk is under control?"',
    hook: 'The PowerSC compliance report is the Audit Committee artefact. ~67% → ~98% compliance, with a continuous monitoring trail.',
  },
];

export default function CustomerPage() {
  return (
    <Grid className={styles.page} fullWidth>

      {/* Page title */}
      <Column lg={16} md={8} sm={4} className={styles.pageTitle}>
        <h1 className={styles.heading}>Before You Demo</h1>
        <p className={styles.subheading}>
          Two things that make every demo land: the industry proof-point that creates urgency,
          and the customer context that makes it personal. Keep both in front of you
          while you present.
        </p>
      </Column>

      {/* ── SECTION A — Industry Risk (static) ──────────────────────────── */}
      <Column lg={16} md={8} sm={4} className={styles.sectionDivider}>
        <div className={styles.sectionLabel}>
          <Tag type="red">Section A — Industry Risk</Tag>
          <p className={styles.sectionNote}>
            Static across all customers. Use this to open every conversation.
          </p>
        </div>
      </Column>

      <Column lg={16} md={8} sm={4} className={styles.jlrBanner}>
        <Warning size={20} className={styles.warningIcon} />
        <div>
          <p className={styles.jlrHeadline}>
            August 2025 — Jaguar Land Rover: £1.9 billion lost to a certificate attack
          </p>
          <p className={styles.jlrBody}>
            The Scattered Lapsus Hunters exploited JLR&apos;s PKI infrastructure — generating rogue
            internal certificates that allowed lateral movement from corporate IT into operational
            technology systems. The result: a five-week production shutdown across flagship UK plants,
            affecting 5,000+ businesses in the supply chain.{' '}
            <strong>The attack vector was certificate-based. The root cause was manual PKI management.</strong>
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
          <AccordionItem title="How the JLR attack unfolded — timeline">
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
        <h4 className={styles.tpHeading}>Opening talking point</h4>
        <p className={styles.tpBody}>
          &ldquo;In August 2025, Jaguar Land Rover lost £1.9 billion when attackers used rogue
          certificates to move laterally across their infrastructure and shut down production for
          five weeks. 5,000 businesses in their supply chain were affected. The attack vector
          was PKI — specifically, old, manually-managed certificate infrastructure.
          That risk profile is not unique to automotive.&rdquo;
        </p>
        <p className={styles.tpTransition}>
          → <em>Then pivot to your customer&apos;s specific parallel (Section B below).</em>
        </p>
      </Column>

      {/* ── SECTION B — Customer Context (customisable) ──────────────────── */}
      <Column lg={16} md={8} sm={4} className={styles.sectionDivider}>
        <div className={styles.sectionLabel}>
          <Tag type="blue">Section B — Your Customer</Tag>
          <p className={styles.sectionNote}>
            Customise this section per engagement using the IBM Consulting Advantage
            story-builder. The Howdens worked example is pre-loaded below.
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
          <h4 className={styles.riskHeading}>Risk statement</h4>
          <p className={styles.riskBody}>{CUSTOMER_CONTEXT.riskStatement}</p>
          <h4 className={styles.factsHeading}>Key facts from IBM Consulting Advantage research</h4>
          <ul className={styles.factsList}>
            {CUSTOMER_CONTEXT.keyFacts.map((f, i) => (
              <li key={i}>{f}</li>
            ))}
          </ul>
        </Tile>
      </Column>

      {/* JLR parallel */}
      <Column lg={8} md={8} sm={4} className={styles.parallelCard}>
        <Tile className={styles.parallelTile}>
          <h4 className={styles.parallelHeading}>The JLR parallel for this customer</h4>
          <p className={styles.parallelBody}>{CUSTOMER_CONTEXT.parallelToJLR}</p>
          <h4 className={styles.parallelHeading} style={{ marginTop: '1.5rem' }}>
            Pivot line
          </h4>
          <p className={styles.tpBody}>
            &ldquo;Howdens has a similar profile — distributed depot network, SAP at the centre,
            100+ suppliers. The difference is, today we can show you what the proactive
            version of this story looks like.&rdquo;
          </p>
        </Tile>
      </Column>

      {/* Personas */}
      <Column lg={16} md={8} sm={4} className={styles.personasSection}>
        <h3 className={styles.personasHeading}>Who is in the room</h3>
        <Grid narrow>
          {PERSONAS.map((p, i) => (
            <Column key={i} lg={8} md={8} sm={4}>
              <Tile className={styles.personaTile}>
                <div className={styles.personaHeader}>
                  <User size={16} />
                  <strong className={styles.personaName}>{p.name}</strong>
                </div>
                <p className={styles.personaTitle}>{p.title}</p>
                <p className={styles.personaConcern}><em>Their concern:</em> {p.concern}</p>
                <p className={styles.personaQuestion}>{p.question}</p>
                <p className={styles.personaHook}><strong>Your hook:</strong> {p.hook}</p>
              </Tile>
            </Column>
          ))}
        </Grid>
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
