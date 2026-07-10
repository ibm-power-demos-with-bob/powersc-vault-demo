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

const COMPARISON = [
  { metric: 'Average Certificate Age', before: '15+ years', after: '24 hours', delta: '99% ↓' },
  { metric: 'Compliance Score', before: '~67%', after: '~98%', delta: '+31 pts' },
  { metric: 'Quantum-Safe Certificates', before: '0', after: '150', delta: '100% ↑' },
  { metric: 'Certificate Authority', before: 'Manual / legacy CA', after: 'HashiCorp Vault PKI', delta: 'Automated' },
  { metric: 'Rotation Method', before: 'Spreadsheet, ad-hoc', after: 'API-driven, on demand', delta: 'Zero-touch' },
  { metric: 'Weakest Crypto', before: 'SHA-1, RSA 1024', after: 'SHA-256, RSA 2048', delta: 'Eliminated' },
];

const AFTER_METRICS = [
  { value: '24h', label: 'Max Certificate Age', sub: 'Down from 15+ years' },
  { value: '~98%', label: 'Compliance Score', sub: 'Up from ~67%' },
  { value: '150', label: 'Vault-Issued Certs', sub: 'All with 24-hour TTL' },
  { value: '0', label: 'Manual Steps Required', sub: 'Fully automated rotation' },
];

export default function ResultsPage() {
  const [outagesPerYear, setOutagesPerYear] = useState(3);
  const [hoursPerMonth, setHoursPerMonth] = useState(8);
  const [roi, setRoi] = useState(null);

  useEffect(() => {
    // Simple client-side ROI calculation — no API call needed
    const outageHours = outagesPerYear * 4; // avg 4h per outage
    const avoidedDowntimeCost = outageHours * 25000; // £25k/hr downtime estimate
    const manualHoursSaved = hoursPerMonth * 12 * 150; // £150/hr staff cost
    setRoi({
      avoidedDowntime: avoidedDowntimeCost,
      staffTimeSaved: manualHoursSaved,
      total: avoidedDowntimeCost + manualHoursSaved,
    });
  }, [outagesPerYear, hoursPerMonth]);

  const powerscUrl = process.env.NEXT_PUBLIC_POWERSC_URL || '#';

  return (
    <Grid className={styles.page} fullWidth>
      {/* Banner */}
      <Column lg={16} md={8} sm={4} className={styles.banner}>
        <Tag type="green" className={styles.tag}>The Transformation</Tag>
        <h1 className={styles.heading}>The Results</h1>
        <p className={styles.subheading}>
          PowerSC now shows 150 certificates with a 24-hour age, modern cryptography, and full
          quantum-safety compliance. The attack surface that enabled the JLR-style breach no
          longer exists.
        </p>
      </Column>

      {/* After metrics */}
      <Column lg={16} md={8} sm={4} className={styles.metricsRow}>
        <Grid narrow>
          {AFTER_METRICS.map((m, i) => (
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
              onChange={(e, { value }) => setOutagesPerYear(value)}
            />
            <NumberInput
              id="hours"
              label="Hours/month spent on manual cert management"
              value={hoursPerMonth}
              min={0}
              max={200}
              onChange={(e, { value }) => setHoursPerMonth(value)}
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
