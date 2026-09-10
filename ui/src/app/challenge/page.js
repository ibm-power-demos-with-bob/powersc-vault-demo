'use client';
import { useState, useEffect } from 'react';
import {
  Grid,
  Column,
  Tile,
  Tag,
  InlineLoading,
  Link,
  InlineNotification,
  Button,
} from '@carbon/react';
import { Launch, ArrowRight, User } from '@carbon/icons-react';
import styles from './challenge-page.module.scss';
import { apiBase } from '../../lib/api';

// Static fallback values — shown before PowerSC summary loads
const METRICS_DEFAULT = [
  { key: 'certs',      value: '150',  label: 'Certificates to Manage', sub: 'Across SAP, Oracle, Integration, Infrastructure' },
  { key: 'age',        value: '15+',  label: 'Years Old (Average)',     sub: 'Issued 2008–2011, still in production' },
  { key: 'compliance', value: '~67%', label: 'Compliance Score',        sub: 'PowerSC Quantum Safety baseline' },
  { key: 'qs',         value: '0',    label: 'Quantum-Safe Ready',      sub: 'No short-lived certificates in estate' },
];

export default function ChallengePage() {
  // 'loading' | 'ready' | 'error'
  const [scanStatus, setScanStatus] = useState('loading');
  const [liveMetrics, setLiveMetrics] = useState(null);
  const [errorMsg, setErrorMsg]       = useState('');

  // Load the current BEFORE scan results on mount
  useEffect(() => {
    fetch(`${apiBase()}/api/powersc/summary`)
      .then(r => r.json())
      .then(d => {
        if (d.complianceScore !== null && d.complianceScore !== undefined) {
          setLiveMetrics(d);
        }
        setScanStatus('ready');
      })
      .catch(err => {
        setErrorMsg(err.message);
        setScanStatus('error');
      });
  }, []);

  // Build display metrics — replace compliance + qs tiles with live values when available
  const metrics = METRICS_DEFAULT.map(m => {
    if (!liveMetrics) return m;
    if (m.key === 'compliance') return { ...m, value: `${liveMetrics.complianceScore}%`, sub: 'PowerSC Quantum Safety (live)' };
    if (m.key === 'qs') return { ...m, value: String(liveMetrics.quantumSafeCertificates ?? 0) };
    return m;
  });

  const powerscUrl = process.env.NEXT_PUBLIC_POWERSC_URL || '#';

  return (
    <Grid className={styles.page} fullWidth>
      {/* Customer context hint */}
      <Column lg={16} md={8} sm={4} className={styles.contextHint}>
        <User size={16} />
        <span>
          New to this demo?{' '}
          <Link href="/customer" className={styles.contextLink}>
            Open Customer Context
          </Link>{' '}
          — the Howdens story, personas, and the JLR case study that opens the conversation.
        </span>
      </Column>

      {/* Banner */}
      <Column lg={16} md={8} sm={4} className={styles.banner}>
        <Tag type="red" className={styles.tag}>Security Risk</Tag>
        <h1 className={styles.heading}>The Certificate Management Challenge</h1>
        <p className={styles.subheading}>
          150 certificates across SAP and Oracle workloads on IBM Power — many over 15 years
          old, manually tracked, with weak cryptography. One missed renewal away from an
          outage. One exploited certificate away from a breach.
        </p>
      </Column>

      {/* Metric tiles */}
      <Column lg={16} md={8} sm={4} className={styles.metricsRow}>
        <Grid narrow>
          {metrics.map((m, i) => (
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
          IBM PowerSC&apos;s Quantum Safety scan evaluates every certificate in the estate against
          cryptographic criteria — key algorithm, key length, hash algorithm, and certificate
          age. The score is the percentage of certificates that pass all criteria. A certificate
          using SHA-1, RSA-1024, or with a multi-year lifetime fails. One issued by Vault with
          RSA-2048, SHA-256, and a 24-hour TTL passes. This is IBM&apos;s measure of how
          quantum-resilient your certificate estate is today.
        </p>
      </Column>

      {/* Context */}
      <Column lg={8} md={8} sm={4} className={styles.contextBlock}>
        <h3 className={styles.sectionHeading}>Why This Matters</h3>
        <p className={styles.body}>
          In August 2025, attackers exploited JLR&apos;s PKI infrastructure — rogue certificates
          enabled lateral movement across their network, halting production for five weeks.
          Total UK economic damage: £1.9 billion across JLR and 5,000+ supply chain businesses.
          The Cyber Monitoring Centre classified it as the costliest cyber attack in UK history.
          The attack vector was certificate-based lateral movement — exactly the risk profile
          that manual certificate management creates.
        </p>
        <p className={styles.body} style={{ marginTop: '1rem' }}>
          This demo shows how IBM PowerSC identifies the problem — and how HashiCorp Vault
          eliminates it.
        </p>
      </Column>

      {/* BEFORE scan results panel */}
      <Column lg={8} md={8} sm={4} className={styles.actionPanel}>
        <Tile className={styles.actionTile}>
          <h3 className={styles.actionHeading}>BEFORE State — PowerSC Scan Results</h3>
          <p className={styles.actionBody}>
            IBM PowerSC has already scanned the AIX estate. The results below reflect the
            current certificate posture — 150 old certificates with weak cryptography,
            distributed across SAP, Oracle, Integration, and Infrastructure paths.
          </p>

          {scanStatus === 'loading' && (
            <InlineLoading description="Loading scan results from PowerSC…" status="active" />
          )}

          {scanStatus === 'error' && (
            <InlineNotification
              kind="warning"
              title="Could not reach PowerSC —"
              subtitle="Showing estimated baseline values. Ensure POWERSC_PASS is set and the backend is running."
              hideCloseButton
            />
          )}

          {scanStatus === 'ready' && (
            <>
              {liveMetrics ? (
                <div style={{
                  background: 'var(--cds-layer-01)',
                  border: '1px solid var(--cds-border-subtle-01)',
                  borderLeft: '3px solid var(--cds-support-error)',
                  padding: '1rem 1.25rem',
                  marginTop: '1rem',
                  marginBottom: '1rem',
                }}>
                  <p style={{ fontSize: '0.75rem', color: 'var(--cds-text-secondary)', marginBottom: '0.5rem' }}>
                    PowerSC Quantum Safety scan — BEFORE state
                  </p>
                  <div style={{ display: 'flex', gap: '2rem', flexWrap: 'wrap' }}>
                    <div>
                      <p style={{ fontSize: '1.75rem', fontWeight: 600, color: liveMetrics.complianceScore < 80 ? 'var(--cds-support-error)' : 'var(--cds-support-warning)', lineHeight: 1 }}>
                        {liveMetrics.complianceScore !== null ? `${liveMetrics.complianceScore}%` : '—'}
                      </p>
                      <p style={{ fontSize: '0.75rem', color: 'var(--cds-text-secondary)' }}>Compliance Score</p>
                    </div>
                    <div>
                      <p style={{ fontSize: '1.75rem', fontWeight: 600, color: 'var(--cds-support-error)', lineHeight: 1 }}>
                        {liveMetrics.weakCertificates}
                      </p>
                      <p style={{ fontSize: '0.75rem', color: 'var(--cds-text-secondary)' }}>Weak Certificates</p>
                    </div>
                    <div>
                      <p style={{ fontSize: '1.75rem', fontWeight: 600, color: 'var(--cds-text-primary)', lineHeight: 1 }}>
                        {(liveMetrics.strongCertificates || 0) + (liveMetrics.quantumSafeCertificates || 0)}
                      </p>
                      <p style={{ fontSize: '0.75rem', color: 'var(--cds-text-secondary)' }}>Strong / Quantum-Safe</p>
                    </div>
                  </div>
                  <p style={{ fontSize: '0.6875rem', color: 'var(--cds-text-placeholder)', marginTop: '0.75rem' }}>
                    Scan time: {liveMetrics.scanTime ? new Date(liveMetrics.scanTime).toLocaleString() : '—'}
                  </p>
                </div>
              ) : (
                <InlineNotification
                  kind="info"
                  title="No scan results yet —"
                  subtitle="The initial setup scan may still be running. Refresh in a moment, or check PowerSC directly."
                  hideCloseButton
                  style={{ marginTop: '1rem', marginBottom: '1rem' }}
                />
              )}

              <div className={styles.nextActions} style={{ marginTop: '1rem', display: 'flex', flexWrap: 'wrap', gap: '0.75rem', alignItems: 'center' }}>
                {powerscUrl && powerscUrl !== '#' && (
                  <Link href={powerscUrl} target="_blank" renderIcon={Launch} style={{ fontSize: '0.875rem' }}>
                    Open PowerSC — full report
                  </Link>
                )}
                <Button
                  renderIcon={ArrowRight}
                  href="/solution"
                  kind="primary"
                  className={styles.actionButton}>
                  Continue to The Solution
                </Button>
              </div>
            </>
          )}
        </Tile>
      </Column>

    </Grid>
  );
}

// Made with Bob
