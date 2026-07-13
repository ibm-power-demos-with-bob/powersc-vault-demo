const express = require('express');
const router = express.Router();
const https = require('https');
const axios = require('axios');

// PowerSC credentials come from .env.local
const POWERSC_URL = process.env.POWERSC_URL;        // e.g. https://p1294-pvm1.p1294.cecc.ihost.com
const POWERSC_USER = process.env.POWERSC_USER || 'powersc-admin';
const POWERSC_PASS = process.env.POWERSC_PASS || '';
const AIX_HOSTNAME = process.env.AIX_HOSTNAME;      // short hostname of pvm3 as known to PowerSC

// PowerSC uses a self-signed cert — skip TLS verification for the API calls
const httpsAgent = new https.Agent({ rejectUnauthorized: false });

function powerscClient() {
  if (!POWERSC_URL) throw new Error('POWERSC_URL not set in .env.local');
  return axios.create({
    baseURL: `${POWERSC_URL}/api/v1`,
    auth: { username: POWERSC_USER, password: POWERSC_PASS },
    httpsAgent,
    timeout: 10000,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /api/powersc/scan
// Triggers a Quantum Safety scan on the AIX client via the PowerSC REST API.
//
// IMPORTANT — API status:
//   The PowerSC REST API endpoints for triggering scans have not been verified
//   against the live product in testing. This route makes a best-effort attempt.
//   If the API returns an error or is unreachable, the route returns a 'manual'
//   result instructing the presenter to trigger the scan in the PowerSC GUI.
//   This is deliberate — the GUI path is always available and always works.
// ─────────────────────────────────────────────────────────────────────────────
router.post('/scan', async (req, res) => {
  const hostname = req.body.hostname || AIX_HOSTNAME;

  if (!hostname) {
    return res.status(400).json({
      error: 'AIX_HOSTNAME not configured in .env.local and none provided in request body.',
    });
  }

  req.io.emit('powersc:status', { message: `Requesting scan of ${hostname}…` });

  // If PowerSC credentials are not configured, skip the API attempt immediately
  if (!POWERSC_URL || !POWERSC_PASS) {
    return res.json({
      success: false,
      mode: 'manual',
      message:
        'POWERSC_URL or POWERSC_PASS not configured. ' +
        'Open the PowerSC UI and trigger the Quantum Safety scan manually.',
      powerscUrl: POWERSC_URL || null,
    });
  }

  try {
    const client = powerscClient();
    const response = await client.post('/quantumsafe/scan', { hostname });

    req.io.emit('powersc:status', { message: 'Scan triggered — waiting for completion…' });

    res.json({
      success: true,
      mode: 'api',
      data: response.data,
      pollUrl: `/api/powersc/status?hostname=${encodeURIComponent(hostname)}`,
    });
  } catch (err) {
    // API unavailable or endpoint not supported — fall back to manual instruction
    const status = err.response?.status;
    const apiError = err.response?.data || err.message;

    console.warn(`[powersc] scan API call failed (${status || 'no response'}):`, apiError);
    req.io.emit('powersc:status', { message: 'API unavailable — please trigger scan manually in PowerSC UI' });

    res.json({
      success: false,
      mode: 'manual',
      message:
        'PowerSC scan API did not respond as expected. ' +
        'Trigger the Quantum Safety scan manually in the PowerSC UI, then return here.',
      powerscUrl: POWERSC_URL,
      apiError: String(apiError),
    });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// GET /api/powersc/status?hostname=<host>
// Poll for scan completion. Returns { status, progress } or falls back to manual.
// ─────────────────────────────────────────────────────────────────────────────
router.get('/status', async (req, res) => {
  const hostname = req.query.hostname || AIX_HOSTNAME;

  if (!hostname) {
    return res.status(400).json({ error: 'hostname query parameter required' });
  }

  if (!POWERSC_URL || !POWERSC_PASS) {
    return res.json({ mode: 'manual', status: 'unknown' });
  }

  try {
    const client = powerscClient();
    const response = await client.get('/quantumsafe/status', { params: { hostname } });
    res.json({ mode: 'api', ...response.data });
  } catch (err) {
    res.json({
      mode: 'manual',
      status: 'unknown',
      message: 'Status API unavailable — check PowerSC UI directly.',
    });
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// GET /api/powersc/report?hostname=<host>
// Fetch the latest scan report. Falls back gracefully.
// ─────────────────────────────────────────────────────────────────────────────
router.get('/report', async (req, res) => {
  const hostname = req.query.hostname || AIX_HOSTNAME;

  if (!hostname) {
    return res.status(400).json({ error: 'hostname query parameter required' });
  }

  if (!POWERSC_URL || !POWERSC_PASS) {
    return res.json({ mode: 'manual', report: null });
  }

  try {
    const client = powerscClient();
    const response = await client.get('/quantumsafe/report', { params: { hostname } });
    res.json({ mode: 'api', report: response.data });
  } catch (err) {
    res.json({
      mode: 'manual',
      report: null,
      message: 'Report API unavailable — view results directly in the PowerSC UI.',
      powerscUrl: POWERSC_URL,
    });
  }
});

module.exports = router;
