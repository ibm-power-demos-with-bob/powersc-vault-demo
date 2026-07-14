'use client';
import { useState } from 'react';
import {
  Button,
  InlineLoading,
  InlineNotification,
  Link,
} from '@carbon/react';
import { Launch, Scan } from '@carbon/icons-react';
import { apiBase } from '../../lib/api';

// ScanPanel — triggers a PowerSC Quantum Safety scan and displays the live result.
//
// Props:
//   label        — button label (e.g. "Run BEFORE Scan")
//   description  — explanatory text shown above the button
//   powerscUrl   — direct link to the PowerSC UI
//   onComplete   — callback({ complianceScore, weakCertificates, scanTime }) when scan finishes

export default function ScanPanel({ label, description, powerscUrl, onComplete }) {
  const [status, setStatus] = useState('idle'); // idle | scanning | complete | manual | error
  const [message, setMessage] = useState('');
  const [result, setResult] = useState(null);

  async function handleScan() {
    setStatus('scanning');
    setMessage('Connecting to PowerSC…');
    setResult(null);

    try {
      // Call the Express backend directly — long-running scan polling
      // cannot go through the Next.js rewrite proxy (ECONNRESET).
      const res = await fetch(`${apiBase()}/api/powersc/scan`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({}),
      });
      const data = await res.json();

      if (data.mode === 'manual') {
        setStatus('manual');
        setMessage(data.message);
        return;
      }

      if (data.mode === 'timeout') {
        setResult(data);
        setStatus('complete');
        setMessage('Scan timed out — showing last available results.');
        if (onComplete) onComplete(data);
        return;
      }

      if (!res.ok || !data.success) {
        throw new Error(data.message || data.error || 'Scan failed');
      }

      setResult(data);
      setStatus('complete');
      setMessage('');
      if (onComplete) onComplete(data);

    } catch (err) {
      setStatus('error');
      setMessage(err.message);
    }
  }

  return (
    <div style={{ marginTop: '1.25rem' }}>
      {description && (
        <p style={{ fontSize: '0.875rem', color: 'var(--cds-text-secondary)', marginBottom: '0.75rem', lineHeight: 1.5 }}>
          {description}
        </p>
      )}

      {status === 'idle' && (
        <Button renderIcon={Scan} onClick={handleScan} kind="secondary" size="md">
          {label}
        </Button>
      )}

      {status === 'scanning' && (
        <div style={{ display: 'flex', alignItems: 'center', gap: '0.75rem' }}>
          <InlineLoading description={message} status="active" />
        </div>
      )}

      {status === 'complete' && result && (
        <div>
          {message && (
            <InlineNotification
              kind="warning"
              title="Note —"
              subtitle={message}
              hideCloseButton
              style={{ marginBottom: '0.75rem' }}
            />
          )}
          <div style={{
            background: 'var(--cds-layer-01)',
            border: '1px solid var(--cds-border-subtle-01)',
            borderLeft: '3px solid var(--cds-support-success)',
            padding: '1rem 1.25rem',
            marginBottom: '0.75rem',
          }}>
            <p style={{ fontSize: '0.75rem', color: 'var(--cds-text-secondary)', marginBottom: '0.5rem' }}>
              PowerSC Quantum Safety scan complete
            </p>
            <div style={{ display: 'flex', gap: '2rem', flexWrap: 'wrap' }}>
              <div>
                <p style={{ fontSize: '1.75rem', fontWeight: 600, color: 'var(--cds-support-success)', lineHeight: 1 }}>
                  {result.complianceScore !== null ? `${result.complianceScore}%` : '—'}
                </p>
                <p style={{ fontSize: '0.75rem', color: 'var(--cds-text-secondary)' }}>Compliance Score</p>
              </div>
              <div>
                <p style={{ fontSize: '1.75rem', fontWeight: 600, color: result.weakCertificates > 0 ? 'var(--cds-support-error)' : 'var(--cds-support-success)', lineHeight: 1 }}>
                  {result.weakCertificates}
                </p>
                <p style={{ fontSize: '0.75rem', color: 'var(--cds-text-secondary)' }}>Weak Certificates</p>
              </div>
              <div>
                <p style={{ fontSize: '1.75rem', fontWeight: 600, color: 'var(--cds-text-primary)', lineHeight: 1 }}>
                  {(result.strongCertificates || 0) + (result.quantumSafeCertificates || 0)}
                </p>
                <p style={{ fontSize: '0.75rem', color: 'var(--cds-text-secondary)' }}>Strong / Quantum-Safe</p>
              </div>
            </div>
            <p style={{ fontSize: '0.6875rem', color: 'var(--cds-text-placeholder)', marginTop: '0.75rem' }}>
              Scan time: {result.scanTime ? new Date(result.scanTime).toLocaleTimeString() : '—'}
            </p>
          </div>
          {powerscUrl && powerscUrl !== '#' && (
            <Link href={powerscUrl} target="_blank" renderIcon={Launch} style={{ fontSize: '0.875rem' }}>
              Open PowerSC — view full report
            </Link>
          )}
        </div>
      )}

      {status === 'manual' && (
        <div>
          <InlineNotification
            kind="info"
            title="Manual scan required —"
            subtitle={message}
            hideCloseButton
            style={{ marginBottom: '0.75rem' }}
          />
          {powerscUrl && powerscUrl !== '#' && (
            <Link href={powerscUrl} target="_blank" renderIcon={Launch} style={{ fontSize: '0.875rem' }}>
              Open PowerSC UI to trigger scan
            </Link>
          )}
          <div style={{ marginTop: '0.75rem' }}>
            <Button kind="ghost" size="sm" onClick={() => { setStatus('idle'); setMessage(''); }}>
              Try API again
            </Button>
            {onComplete && (
              <Button kind="ghost" size="sm" onClick={() => onComplete({ manual: true })}
                style={{ marginLeft: '0.5rem' }}>
                Mark as done (manual)
              </Button>
            )}
          </div>
        </div>
      )}

      {status === 'error' && (
        <div>
          <InlineNotification
            kind="error"
            title="Scan error —"
            subtitle={message}
            hideCloseButton
            style={{ marginBottom: '0.75rem' }}
          />
          <Button kind="ghost" size="sm" onClick={() => { setStatus('idle'); setMessage(''); }}>
            Try again
          </Button>
        </div>
      )}
    </div>
  );
}
