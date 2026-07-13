'use client';
import { useState } from 'react';
import { Button, InlineLoading, InlineNotification, Link } from '@carbon/react';
import { Scan, Launch } from '@carbon/icons-react';

/**
 * ScanPanel — triggers a PowerSC Quantum Safety scan via the backend API.
 *
 * The backend route makes a best-effort attempt to call the PowerSC REST API.
 * If the API is unreachable or credentials are not set, it returns mode:'manual'
 * and this component shows a direct link to the PowerSC UI instead.
 *
 * Props:
 *   label      — button label (e.g. "Run BEFORE Scan")
 *   description — short explanation shown under the button
 *   powerscUrl  — direct link to PowerSC UI (NEXT_PUBLIC_POWERSC_URL)
 *   onComplete  — called when scan is confirmed complete (or presenter confirms manual)
 */
export default function ScanPanel({ label, description, powerscUrl, onComplete }) {
  const [status, setStatus] = useState('idle'); // idle | requesting | polling | manual | complete | error
  const [message, setMessage] = useState('');
  const [pollUrl, setPollUrl] = useState(null);

  async function handleScan() {
    setStatus('requesting');
    setMessage('Requesting scan…');

    try {
      const res = await fetch('/api/powersc/scan', {
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

      // API scan triggered — poll for completion
      setPollUrl(data.pollUrl);
      setStatus('polling');
      setMessage('Scan running…');
      pollForCompletion(data.pollUrl);
    } catch (err) {
      setStatus('error');
      setMessage(err.message);
    }
  }

  async function pollForCompletion(url) {
    const maxAttempts = 24; // 2-minute timeout at 5s intervals
    let attempts = 0;

    const tick = async () => {
      attempts++;
      try {
        const res = await fetch(url);
        const data = await res.json();

        if (data.mode === 'manual' || data.status === 'unknown') {
          setStatus('manual');
          setMessage('Unable to poll scan status — check PowerSC UI for results.');
          return;
        }

        if (data.status === 'completed') {
          setStatus('complete');
          setMessage('');
          onComplete?.();
          return;
        }

        if (attempts >= maxAttempts) {
          setStatus('manual');
          setMessage('Scan is taking longer than expected. Check PowerSC UI for status.');
          return;
        }

        setTimeout(tick, 5000);
      } catch {
        setStatus('manual');
        setMessage('Lost contact with backend. Check PowerSC UI directly.');
      }
    };

    setTimeout(tick, 5000);
  }

  return (
    <div style={{ marginTop: '1rem' }}>
      {status === 'idle' && (
        <>
          <p style={{ fontSize: '0.875rem', color: 'var(--cds-text-secondary)', marginBottom: '0.75rem', lineHeight: 1.5 }}>
            {description}
          </p>
          <Button renderIcon={Scan} onClick={handleScan} kind="secondary">
            {label}
          </Button>
        </>
      )}

      {(status === 'requesting' || status === 'polling') && (
        <InlineLoading
          description={message}
          status="active"
        />
      )}

      {status === 'manual' && (
        <>
          <InlineNotification
            kind="info"
            title="Trigger scan manually —"
            subtitle={message || 'Open PowerSC UI and run a Quantum Safety full scan on the AIX client.'}
            hideCloseButton
          />
          {powerscUrl && powerscUrl !== '#' && (
            <Link
              href={powerscUrl}
              target="_blank"
              renderIcon={Launch}
              style={{ marginTop: '0.75rem', display: 'inline-flex', fontSize: '0.875rem' }}>
              Open PowerSC UI
            </Link>
          )}
          <div style={{ marginTop: '0.75rem' }}>
            <Button kind="ghost" size="sm" onClick={() => { setStatus('complete'); onComplete?.(); }}>
              ✓ I&apos;ve triggered the scan — continue
            </Button>
          </div>
        </>
      )}

      {status === 'complete' && (
        <InlineNotification
          kind="success"
          title="Scan complete —"
          subtitle="PowerSC has finished the Quantum Safety scan. View results in the PowerSC UI."
          hideCloseButton
        />
      )}

      {status === 'error' && (
        <>
          <InlineNotification
            kind="error"
            title="Scan request failed —"
            subtitle={message}
            hideCloseButton
          />
          <Button kind="ghost" size="sm" onClick={() => setStatus('idle')} style={{ marginTop: '0.5rem' }}>
            Try again
          </Button>
        </>
      )}
    </div>
  );
}
