'use client';
import { useState } from 'react';
import {
  Grid,
  Column,
  Button,
  Tile,
  Tag,
  ProgressIndicator,
  ProgressStep,
  InlineLoading,
  InlineNotification,
  Link,
} from '@carbon/react';
import { Security, Launch, ArrowRight, Renew } from '@carbon/icons-react';
import ScanPanel from '../../components/ScanPanel/ScanPanel';
import styles from './solution-page.module.scss';

const VALUE_TILES = [
  {
    icon: '⚡',
    heading: 'Automated Rotation',
    body: '24-hour certificate TTL. No manual renewal, no spreadsheets, no missed expiry.',
  },
  {
    icon: '🔐',
    heading: 'Strong Cryptography',
    body: 'RSA 2048 + SHA-256 on every issued certificate. Weak crypto eliminated immediately.',
  },
  {
    icon: '🛡️',
    heading: 'Quantum-Safe Ready',
    body: 'Short-lived certificates dramatically reduce the window of exposure to future quantum attacks.',
  },
  {
    icon: '📉',
    heading: '99% Age Reduction',
    body: 'Average certificate age drops from 15+ years to 24 hours — the moment Vault takes over.',
  },
];

const STEPS = [
  { label: 'Configure Vault PKI', description: 'Root CA + sap-oracle role' },
  { label: 'Issue Certificates', description: '150 certificates from Vault' },
  { label: 'Deploy to AIX', description: 'Replace old certs on target system' },
  { label: 'Complete', description: 'Vault is in control' },
];

export default function SolutionPage() {
  const [status, setStatus] = useState('idle'); // idle | running | complete | error
  const [currentStep, setCurrentStep] = useState(-1);
  const [certsIssued, setCertsIssued] = useState(0);
  const [message, setMessage] = useState('');
  const [afterScanDone, setAfterScanDone] = useState(false);

  async function handleDeploy() {
    setStatus('running');
    setCurrentStep(0);
    setCertsIssued(0);
    setMessage('Configuring Vault PKI…');

    try {
      // Step 1: Setup PKI
      const pkiRes = await fetch('/api/vault/setup-pki', { method: 'POST' });
      if (!pkiRes.ok) {
        const d = await pkiRes.json();
        throw new Error(d.error || 'Vault PKI setup failed');
      }
      setCurrentStep(1);
      setMessage('Issuing and deploying certificates to AIX…');

      // Step 2+3: Replace certificates (this takes a while — streams progress via polling)
      const replaceRes = await fetch('/api/vault/replace-certificates', { method: 'POST' });
      const replaceData = await replaceRes.json();
      if (!replaceRes.ok) throw new Error(replaceData.error || 'Certificate replacement failed');

      setCurrentStep(3);
      setCertsIssued(replaceData.certificatesReplaced || 150);
      setStatus('complete');
      setMessage('');
    } catch (err) {
      setStatus('error');
      setMessage(err.message);
    }
  }

  const powerscUrl = process.env.NEXT_PUBLIC_POWERSC_URL || '#';

  return (
    <Grid className={styles.page} fullWidth>
      {/* Banner */}
      <Column lg={16} md={8} sm={4} className={styles.banner}>
        <Tag type="green" className={styles.tag}>The Solution</Tag>
        <h1 className={styles.heading}>HashiCorp Vault Takes Over</h1>
        <p className={styles.subheading}>
          Vault becomes the certificate authority. Certificates are issued on demand, last 24
          hours, and rotate automatically. IBM PowerSC provides continuous visibility over the
          entire transformed estate.
        </p>
      </Column>

      {/* Value tiles */}
      <Column lg={16} md={8} sm={4} className={styles.tilesRow}>
        <Grid narrow>
          {VALUE_TILES.map((t, i) => (
            <Column key={i} lg={4} md={4} sm={4}>
              <Tile className={styles.valueTile}>
                <p className={styles.tileIcon}>{t.icon}</p>
                <p className={styles.tileHeading}>{t.heading}</p>
                <p className={styles.tileBody}>{t.body}</p>
              </Tile>
            </Column>
          ))}
        </Grid>
      </Column>

      {/* Action panel */}
      <Column lg={8} md={8} sm={4} className={styles.actionPanel}>
        <Tile className={styles.actionTile}>
          <h3 className={styles.actionHeading}>Step 2: Deploy Vault Certificates</h3>
          <p className={styles.actionBody}>
            One click. Vault configures its PKI engine, issues 150 new certificates with
            24-hour TTL, and deploys them to the AIX client — replacing every old certificate
            across SAP, Oracle, Integration, and Infrastructure paths.
          </p>

          {status === 'idle' && (
            <Button renderIcon={Security} onClick={handleDeploy} className={styles.actionButton}>
              Deploy Vault Certificates
            </Button>
          )}

          {status === 'running' && (
            <div className={styles.progressBlock}>
              <InlineLoading description={message} status="active" />
              <ProgressIndicator currentIndex={currentStep} className={styles.progressIndicator}>
                {STEPS.map((step, i) => (
                  <ProgressStep
                    key={i}
                    label={step.label}
                    description={step.description}
                    complete={i < currentStep}
                    current={i === currentStep}
                  />
                ))}
              </ProgressIndicator>
            </div>
          )}

          {status === 'complete' && (
            <>
              <InlineNotification
                kind="success"
                title="Vault has taken over —"
                subtitle={`${certsIssued} certificates replaced. All now 24-hour TTL, RSA 2048, SHA-256.`}
                hideCloseButton
              />
              <ScanPanel
                label="Run AFTER Scan"
                description="Trigger a PowerSC Quantum Safety scan to capture the AFTER state — 150 Vault-issued certificates, 24-hour age, ~98% compliance."
                powerscUrl={powerscUrl}
                onComplete={() => setAfterScanDone(true)}
              />
              {afterScanDone && (
                <div className={styles.nextActions}>
                  <Link href={powerscUrl} target="_blank" renderIcon={Launch} className={styles.powerscLink}>
                    Open PowerSC — view AFTER state
                  </Link>
                  <Button
                    renderIcon={ArrowRight}
                    href="/results"
                    kind="primary"
                    className={styles.actionButton}>
                    Continue to The Results
                  </Button>
                  <Button
                    renderIcon={Renew}
                    kind="ghost"
                    onClick={() => { setStatus('idle'); setCurrentStep(-1); setAfterScanDone(false); }}
                    className={styles.actionButton}>
                    Run Again
                  </Button>
                </div>
              )}
            </>
          )}

          {status === 'error' && (
            <>
              <InlineNotification
                kind="error"
                title="Deployment failed —"
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

      {/* Architecture note */}
      <Column lg={8} md={8} sm={4} className={styles.archPanel}>
        <h3 className={styles.sectionHeading}>How It Works</h3>
        <div className={styles.archDiagram}>
          <div className={styles.archNode}>
            <strong>Vault PKI</strong>
            <span>Root CA → sap-oracle role</span>
            <span>24-hour TTL, RSA 2048</span>
          </div>
          <div className={styles.archArrow}>→</div>
          <div className={styles.archNode}>
            <strong>REST API</strong>
            <span>150 × POST /v1/pki/issue</span>
            <span>curl — no CLI needed</span>
          </div>
          <div className={styles.archArrow}>→</div>
          <div className={styles.archNode}>
            <strong>AIX Certificates</strong>
            <span>/opt/sap, /opt/oracle</span>
            <span>/opt/integration, /opt/proxy</span>
          </div>
        </div>
        <p className={styles.archNote}>
          Vault runs on this same RHEL host as a Power-native container. All certificate
          issuance uses the REST API — no Vault CLI required on the AIX system.
        </p>
      </Column>
    </Grid>
  );
}

// Made with Bob
