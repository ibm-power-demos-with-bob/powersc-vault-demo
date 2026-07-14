'use client';
import { useState, useEffect } from 'react';
import {
  Grid,
  Column,
  Button,
  Tile,
  Tag,
  Link,
  StructuredListWrapper,
  StructuredListHead,
  StructuredListRow,
  StructuredListCell,
  StructuredListBody,
  NumberInput,
} from '@carbon/react';
import { Launch, Renew, ArrowLeft } from '@carbon/icons-react';
import styles from './results-page.module.scss';
import { apiBase } from '../../lib/api';

const COMPARISON = [
  { metric: 'Average Certificate Age', before: '15+ years', after: '24 hours', delta: '99% ↓' },
  { metric: 'Compliance Score', before: '~67%', after: '~98%', delta: '+31 pts' },
  { metric: 'Quantum-Safe Certificates', before: '0', after: '150', delta: '100% ↑' },
  { metric: 'Certificate Authority', before: 'Manual / legacy CA', after: 'HashiCorp Vault PKI', delta: 'Automated' },
  { metric: 'Rotation Method', before: 'Spreadsheet, ad-hoc', after: 'API-driven, on demand', delta: 'Zero-touch' },
  { metric: 'Weakest Crypto', before: 'SHA-1, RSA 1024', after: 'SHA-256, RSA 2048', delta: 'Eliminated' },
];

// Static fallback values — shown before PowerSC summary loads
const AFTER_METRICS_DEFAULT = [
  { key: 'age',        value: '24h',   label: 'Max Certificate Age', sub: 'Down from 15+ years' },
  { key: 'compliance', value: '~98%',  label: 'Compliance Score',    sub: 'Up from ~67%' },
  { key: 'vaultcerts', value: '150',   label: 'Vault-Issued Certs',  sub: 'All with 24-hour TTL' },
  { key: 'manual',     value: '0',     label: 'Manual Steps Required', sub: 'Fully automated rotation' },
];

export default function ResultsPage() {
  const [outagesPerYear, setOutagesPerYear] = useState(3);
  const [hoursPerMonth, setHoursPerMonth] = useState(8);
  const [roi, setRoi] = useState(null);
  // Live metrics from PowerSC
  const [liveMetrics, setLiveMetrics] = useState(null);

  // Fetch current summary on mount
  useEffect(() => {
    fetch(`${apiBase()}/api/powersc/summary`)
      .then(r => r.json())
      .then(d => { if (d.complianceScore !== null && d.complianceScore !== undefined) setLiveMetrics(d); })
      .catch(() => {});
  }, []);

  // ROI calculation
  useEffect(() => {
    const outageHours = outagesPerYear * 4;
    const avoidedDowntimeCost = outageHours * 25000;
    const manualHoursSaved = hoursPerMonth * 12 * 150;
    setRoi({
      avoidedDowntime: avoidedDowntimeCost,
      staffTimeSaved: manualHoursSaved,
      total: avoidedDowntimeCost + manualHoursSaved,
    });
  }, [outagesPerYear, hoursPerMonth]);

  // Build display metrics — replace compliance tile with live value when available
  const afterMetrics = AFTER_METRICS_DEFAULT.map(m => {
    if (!liveMetrics) return m;
    if (m.key === 'compliance') return {
      ...m,
      value: `${liveMetrics.complianceScore}%`,
      sub: 'PowerSC Quantum Safety (live)',
    };
    return m;
  });

  const powerscUrl = process.env.NEXT_PUBLIC_POWERSC_URL || '#';

  return (
    <Grid className={styles.page} fullWidth>
      {/* Banner */}
      <Column lg={16} md={8} sm={4} className={styles.banner}>
        <Tag type="green" className={styles.tag}>The Transformation</Tag>
        <h1 className={styles.heading}>The Results</h1>
        <p className={styles.subheading}>
          PowerSC now shows 150 certificates with a 24-hour age, modern cryptography, and full
          quantum-safety compliance. The attack surface that enabled the JLR-style breach —
          old, manually-managed certificates — no longer exists.
        </p>
      </Column>

      {/* After metrics */}
      <Column lg={16} md={8} sm={4} className={styles.metricsRow}>
        <Grid narrow>
          {afterMetrics.map((m, i) => (
            <Column key={i} lg={4} md={4} sm={4}>
              <Tile className={styles.metricTile}>
                <p className={styles.metricValue}>{m.value}</p>
                <p className={styles.metricLabel}>{m.label}</p>
                <p className={styles.metricSub}>{m.sub}</p>
              </Tile>
            </Column>
          ))}
        </Grid>
      </Column>

      {/* Compliance score explainer */}
      <Column lg={16} md={8} sm={4} className={styles.scoreNote}>
        <p>
          <strong>What is the Compliance Score?</strong>{' '}
          IBM PowerSC&apos;s Quantum Safety scan grades every certificate against cryptographic
          criteria — key algorithm, key length, hash algorithm, and certificate age. The score
          is the percentage that pass. In the BEFORE state, ~67% passed: most old certificates
          used weak SHA-1 or RSA-1024. After Vault replacement, ~98% pass: all 150 Vault-issued
          certificates use RSA-2048 + SHA-256 with a 24-hour TTL. The residual ~2% are system
          certificates outside the demo scope.
        </p>
      </Column>

      {/* Before/After comparison table */}
      <Column lg={10} md={8} sm={4} className={styles.tableSection}>
        <h3 className={styles.sectionHeading}>Before vs. After</h3>
        <StructuredListWrapper>
          <StructuredListHead>
            <StructuredListRow head>
              <StructuredListCell head>Metric</StructuredListCell>
              <StructuredListCell head>Before (Manual)</StructuredListCell>
              <StructuredListCell head>After (Vault)</StructuredListCell>
              <StructuredListCell head>Change</StructuredListCell>
            </StructuredListRow>
          </StructuredListHead>
          <StructuredListBody>
            {COMPARISON.map((row, i) => (
              <StructuredListRow key={i}>
                <StructuredListCell>{row.metric}</StructuredListCell>
                <StructuredListCell className={styles.beforeCell}>{row.before}</StructuredListCell>
                <StructuredListCell className={styles.afterCell}>{row.after}</StructuredListCell>
                <StructuredListCell className={styles.deltaCell}>{row.delta}</StructuredListCell>
              </StructuredListRow>
            ))}
          </StructuredListBody>
        </StructuredListWrapper>
      </Column>

      {/* ROI Calculator */}
      <Column lg={6} md={8} sm={4} className={styles.roiSection}>
        <h3 className={styles.sectionHeading}>Business Value Calculator</h3>
        <Tile className={styles.roiTile}>
          <p className={styles.roiIntro}>
            Adjust these figures to match your customer's environment.
          </p>
          <div className={styles.roiInputs}>
            <NumberInput
              id="outages"
              label="Certificate-related outages per year"
              value={outagesPerYear}
              min={0}
              max={20}
              onChange={(e, { value } = {}) => {
                // Carbon v11: stepper fires (evt, { value }); direct typing fires (evt)
                const n = value !== undefined ? Number(value) : Number(e?.target?.value);
                if (!isNaN(n)) setOutagesPerYear(n);
              }}
            />
            <NumberInput
              id="hours"
              label="Hours/month spent on manual cert management"
              value={hoursPerMonth}
              min={0}
              max={200}
              onChange={(e, { value } = {}) => {
                const n = value !== undefined ? Number(value) : Number(e?.target?.value);
                if (!isNaN(n)) setHoursPerMonth(n);
              }}
            />
          </div>
          {roi && (
            <div className={styles.roiResults}>
              <div className={styles.roiRow}>
                <span>Avoided downtime cost</span>
                <strong>£{roi.avoidedDowntime.toLocaleString()}</strong>
              </div>
              <div className={styles.roiRow}>
                <span>Staff time saved (annual)</span>
                <strong>£{roi.staffTimeSaved.toLocaleString()}</strong>
              </div>
              <div className={`${styles.roiRow} ${styles.roiTotal}`}>
                <span>Estimated annual value</span>
                <strong>£{roi.total.toLocaleString()}</strong>
              </div>
              <p className={styles.roiDisclaimer}>
                Illustrative estimate. Assumptions: £25k/hr downtime cost, 4h avg outage, £150/hr staff.
              </p>
            </div>
          )}
        </Tile>
      </Column>

      {/* Actions */}
      <Column lg={16} md={8} sm={4} className={styles.actionsRow}>
        <Link href={powerscUrl} target="_blank" renderIcon={Launch} className={styles.powerscLink}>
          Open PowerSC — view final compliance report
        </Link>
        <Button renderIcon={ArrowLeft} href="/" kind="secondary" className={styles.actionButton}>
          Back to The Challenge
        </Button>
        <Button renderIcon={Renew} href="/solution" kind="ghost" className={styles.actionButton}>
          Run Demo Again
        </Button>
      </Column>
    </Grid>
  );
}

// Made with Bob
