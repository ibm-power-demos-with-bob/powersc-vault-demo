require('dotenv').config({ path: require('path').join(__dirname, '../../.env.local') });
const express = require('express');
const router = express.Router();
const https = require('https');
const axios = require('axios');

const POWERSC_URL  = process.env.POWERSC_URL;
const POWERSC_USER = process.env.POWERSC_USER || 'powersc-admin';
const POWERSC_PASS = process.env.POWERSC_PASS || '';
const AIX_ENDPOINT = process.env.AIX_HOST; // FQDN — PowerSC uses this as the endpoint id

// PowerSC uses a self-signed cert
const httpsAgent = new https.Agent({ rejectUnauthorized: false });

function client() {
  if (!POWERSC_URL) throw new Error('POWERSC_URL not set in .env.local');
  if (!POWERSC_PASS) throw new Error('POWERSC_PASS not set in .env.local');
  return axios.create({
    baseURL: `${POWERSC_URL}/ws/powerscui`,
    auth: { username: POWERSC_USER, password: POWERSC_PASS },
    httpsAgent,
    timeout: 15000,
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────────

// Parse the flat summary array [ { weakCertificates: N }, ... ] into a plain object
function parseSummary(summaryArray) {
  const out = {};
  for (const item of summaryArray) {
    Object.assign(out, item);
  }
  return out;
}

// Calculate compliance score: (strong + quantumSafe) / total certificates * 100
function calcScore(s) {
  const weak   = s.weakCertificates        || 0;
  const strong = s.strongCertificates      || 0;
  const qs     = s.quantumSafeCertificates || 0;
  const uncl   = s.unclassifiedCertificates|| 0;
  const total  = weak + strong + qs + uncl;
  if (total === 0) return null;
  return Math.round(((strong + qs) / total) * 100);
}

async function fetchSummary(endpoint) {
  const c = client();
  const res = await c.get('/quantumsafe/summary', { params: { endpoint } });
  const s = parseSummary(res.data.summary || []);
  return {
    scanTime:              res.data.scanTime,
    weakCertificates:      s.weakCertificates        || 0,
    strongCertificates:    s.strongCertificates      || 0,
    quantumSafeCertificates: s.quantumSafeCertificates || 0,
    weakKeys:              s.weakKeys                || 0,
    complianceScore:       calcScore(s),
  };
}

// ── Routes ────────────────────────────────────────────────────────────────────

// GET /api/powersc/summary
// Returns the most recent scan results + calculated compliance score.
// Does NOT trigger a new scan — use /scan for that.
router.get('/summary', async (req, res) => {
  const endpoint = req.query.endpoint || AIX_ENDPOINT;
  if (!endpoint) return res.status(400).json({ error: 'endpoint query param required' });

  if (!POWERSC_URL || !POWERSC_PASS) {
    return res.json({ mode: 'unconfigured', complianceScore: null });
  }

  try {
    const summary = await fetchSummary(endpoint);
    res.json({ mode: 'api', ...summary });
  } catch (err) {
    console.warn('[powersc] summary fetch failed:', err.message);
    res.json({ mode: 'error', error: err.message, complianceScore: null });
  }
});

// POST /api/powersc/scan
// 1. Notes current scanTime
// 2. Triggers runQuantumSafeScan via POST /command
// 3. Polls GET /quantumsafe/summary every 5s until scanTime advances
// 4. Returns calculated score from fresh results
//
// Falls back gracefully to manual instructions if PowerSC is not configured
// or the API fails — the GUI path always works.
router.post('/scan', async (req, res) => {
  const endpoint = req.body.endpoint || AIX_ENDPOINT;

  if (!endpoint) {
    return res.status(400).json({ error: 'AIX_HOST not configured and no endpoint in request body.' });
  }

  if (!POWERSC_URL || !POWERSC_PASS) {
    return res.json({
      success: false,
      mode: 'manual',
      message: 'POWERSC_PASS not configured. Trigger the Quantum Safety scan manually in the PowerSC UI.',
      powerscUrl: POWERSC_URL || null,
    });
  }

  req.io.emit('powersc:status', { message: 'Connecting to PowerSC…' });

  try {
    const c = client();

    // Step 1 — note current scanTime before we trigger
    let preScanTime = 0;
    try {
      const pre = await fetchSummary(endpoint);
      preScanTime = pre.scanTime || 0;
      req.io.emit('powersc:status', { message: 'Baseline captured — triggering scan…' });
    } catch (_) {
      // If summary fetch fails before scan, proceed anyway — preScanTime stays 0
    }

    // Step 2 — trigger the scan
    await c.post('/command', {
      orders: [{ commandName: 'runQuantumSafeScan', elementId: endpoint }],
    });
    req.io.emit('powersc:status', { message: 'Scan running — waiting for results…' });

    // Step 3 — poll until scanTime advances (max 3 minutes, every 5s)
    const POLL_INTERVAL_MS = 5000;
    const TIMEOUT_MS = 180000;
    const deadline = Date.now() + TIMEOUT_MS;
    let summary = null;

    while (Date.now() < deadline) {
      await new Promise(r => setTimeout(r, POLL_INTERVAL_MS));
      try {
        const s = await fetchSummary(endpoint);
        req.io.emit('powersc:status', { message: 'Scan in progress…' });
        if (s.scanTime && s.scanTime > preScanTime) {
          summary = s;
          break;
        }
      } catch (_) {
        // transient error — keep polling
      }
    }

    if (!summary) {
      // Timed out — return whatever summary we can get
      try { summary = await fetchSummary(endpoint); } catch (_) {}
      return res.json({
        success: false,
        mode: 'timeout',
        message: 'Scan did not complete within 3 minutes. Results shown are from the previous scan.',
        ...(summary || {}),
      });
    }

    req.io.emit('powersc:status', { message: 'Scan complete' });
    res.json({ success: true, mode: 'api', ...summary });

  } catch (err) {
    console.warn('[powersc] scan error:', err.message);
    req.io.emit('powersc:status', { message: 'PowerSC API error — use manual scan in PowerSC UI' });
    res.json({
      success: false,
      mode: 'manual',
      message: 'PowerSC API error: ' + err.message + '. Trigger the scan manually in the PowerSC UI.',
      powerscUrl: POWERSC_URL,
    });
  }
});

module.exports = router;
