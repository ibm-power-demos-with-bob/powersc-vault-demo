'use client';
import { useState } from 'react';
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

const METRICS_BEFORE = [
  { value: '150', label: 'Certificates to Manage', sub: 'Across SAP, Oracle, Integration, Infrastructure' },
  { value: '15+', label: 'Years Old (Average)', sub: 'Issued 2008–2011, still in production' },
  { value: '~67%', label: 'Compliance Score', sub: 'PowerSC Quantum Safety baseline' },
  { value: '0', label: 'Quantum-Safe Ready', sub: 'No short-lived certificates in estate' },
];

export default function ChallengePage() {
  const [status, setStatus] = useState('idle'); // idle | running | complete | error
  const [progress, setProgress] = useState(0);
  const [message, setMessage] = useState('');
  const [certsDeployed, setCertsDeployed] = useState(0);
  const [beforeScanDone, setBeforeScanDone] = useState(false);

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
          {METRICS_BEFORE.map((m, i) => (
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

      {/* Context */}
      <Column lg={8} md={8} sm={4} className={styles.contextBlock}>
        <h3 className={styles.sectionHeading}>Why This Matters</h3>
        <p className={styles.body}>
          In August 2025, attackers exploited a PKI/certificate infrastructure at a major UK
          manufacturer. The result: a five-week production shutdown, £1.9 billion in losses,
          and over 5,000 supplier businesses affected. The attack vector was certificate-based
          lateral movement — exactly the risk profile that manual certificate management creates.
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
                onComplete={() => setBeforeScanDone(true)}
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
