'use client';
import { useState, useEffect } from 'react';
import {
  Grid,
  Column,
  Button,
  Tile,
  Tag,
  InlineLoading,
  ProgressBar,
  Link,
  InlineNotification,
} from '@carbon/react';
import { Launch, Certificate, Warning, ArrowRight, User } from '@carbon/icons-react';
import ScanPanel from '../../components/ScanPanel/ScanPanel';
import styles from './challenge-page.module.scss';

// Static fallback values — shown before PowerSC summary loads
const METRICS_DEFAULT = [
  { key: 'certs',      value: '150',  label: 'Certificates to Manage', sub: 'Across SAP, Oracle, Integration, Infrastructure' },
  { key: 'age',        value: '15+',  label: 'Years Old (Average)',     sub: 'Issued 2008–2011, still in production' },
  { key: 'compliance', value: '~67%', label: 'Compliance Score',        sub: 'PowerSC Quantum Safety baseline' },
  { key: 'qs',         value: '0',    label: 'Quantum-Safe Ready',      sub: 'No short-lived certificates in estate' },
];

export default function ChallengePage() {
  const [status, setStatus] = useState('idle'); // idle | running | complete | error
  const [progress, setProgress] = useState(0);
  const [message, setMessage] = useState('');
  const [certsDeployed, setCertsDeployed] = useState(0);
  const [beforeScanDone, setBeforeScanDone] = useState(false);
  // Live metrics from PowerSC — null until loaded
  const [liveMetrics, setLiveMetrics] = useState(null);

  // Fetch the current summary on mount so tiles show live data immediately
  useEffect(() => {
    fetch('/api/powersc/summary')
      .then(r => r.json())
      .then(d => { if (d.complianceScore !== null && d.complianceScore !== undefined) setLiveMetrics(d); })
      .catch(() => {}); // silently ignore — static fallback stays
  }, []);

  // Called by ScanPanel when a scan completes — update live metrics
  function handleScanComplete(data) {
    if (data && data.complianceScore !== undefined) setLiveMetrics(data);
    setBeforeScanDone(true);
  }

  // Build display metrics — replace compliance + qs tiles with live values when available
  const metrics = METRICS_DEFAULT.map(m => {
    if (!liveMetrics) return m;
    if (m.key === 'compliance') return { ...m, value: `${liveMetrics.complianceScore}%`, sub: 'PowerSC Quantum Safety (live)' };
    if (m.key === 'qs') return { ...m, value: String(liveMetrics.quantumSafeCertificates ?? 0) };
    return m;
  });

  async function handleGenerateCerts() {
    setStatus('running');
    setProgress(10);
    setMessage('Connecting to AIX client…');
    setCertsDeployed(0);

    try {
      const res = await fetch('/api/setup/generate-certificates', { method: 'POST' });
      const data = await res.json();

      if (!res.ok) throw new Error(data.error || 'Failed to generate certificates');

      setProgress(100);
      setCertsDeployed(data.certificatesCreated || 150);
      setStatus('complete');
      setMessage('');
    } catch (err) {
      setStatus('error');
      setMessage(err.message);
      setProgress(0);
    }
  }

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

      {/* Action panel */}
      <Column lg={8} md={8} sm={4} className={styles.actionPanel}>
        <Tile className={styles.actionTile}>
          <h3 className={styles.actionHeading}>Step 1: Set Up the Demo Environment</h3>
          <p className={styles.actionBody}>
            Deploy 150 synthetic old certificates to the AIX client. These represent the
            current state — real CA certificates from 2008–2011 with weak cryptography,
            distributed across SAP, Oracle, Integration, and Infrastructure paths.
          </p>

          {status === 'idle' && (
            <Button
              renderIcon={Certificate}
              onClick={handleGenerateCerts}
              className={styles.actionButton}>
              Generate Demo Environment
            </Button>
          )}

          {status === 'running' && (
            <div className={styles.progressBlock}>
              <InlineLoading description={message} status="active" />
              <ProgressBar label="Deploying certificates…" value={progress} />
            </div>
          )}

          {status === 'complete' && (
            <>
              <InlineNotification
                kind="success"
                title="Environment ready —"
                subtitle={`${certsDeployed} old certificates deployed to AIX client.`}
                hideCloseButton
              />
              <ScanPanel
                label="Run BEFORE Scan"
                description="Trigger a PowerSC Quantum Safety scan now to capture the BEFORE state — 150 old certificates, weak crypto, low compliance. The scan takes 30–90 seconds."
                powerscUrl={powerscUrl}
                onComplete={handleScanComplete}
              />
              {beforeScanDone && (
                <div className={styles.nextActions}>
                  <Link href={powerscUrl} target="_blank" renderIcon={Launch} className={styles.powerscLink}>
                    Open PowerSC — view BEFORE state
                  </Link>
                  <Button
                    renderIcon={ArrowRight}
                    href="/solution"
                    kind="primary"
                    className={styles.actionButton}>
                    Continue to The Solution
                  </Button>
                </div>
              )}
            </>
          )}

          {status === 'error' && (
            <>
              <InlineNotification
                kind="error"
                title="Error —"
                subtitle={message}
                hideCloseButton
              />
              <Button kind="ghost" onClick={() => setStatus('idle')}>
                Try again
              </Button>
            </>
          )}
        </Tile>
      </Column>

      {/* Footer hint */}
      <Column lg={16} md={8} sm={4} className={styles.footerHint}>
        <Warning size={16} />
        <span> After clicking "Generate Demo Environment", open PowerSC to see the BEFORE
          state — 150 old certificates, weak crypto, low compliance score. Then proceed to
          The Solution.</span>
      </Column>
    </Grid>
  );
}

// Made with Bob
