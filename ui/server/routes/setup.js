const express = require('express');
const router = express.Router();
const { runScriptOnAIX } = require('../lib/ssh');
const path = require('path');

// POST /api/setup/generate-certificates
// SSH to the AIX client and run generate-old-certificates.sh
router.post('/generate-certificates', async (req, res) => {
  const aixHost = process.env.AIX_HOST;
  const aixUser = process.env.AIX_USER || 'cecuser';
  const sshKeyPath = process.env.AIX_SSH_KEY_PATH;

  if (!aixHost) {
    return res.status(500).json({ error: 'AIX_HOST not configured. Check .env.local on the server.' });
  }
  if (!sshKeyPath) {
    return res.status(500).json({ error: 'AIX_SSH_KEY_PATH not configured. Check .env.local on the server.' });
  }

  try {
    req.io.emit('setup:status', { step: 'Connecting to AIX client…', progress: 10 });

    // Transfer the script and run it — script path relative to where it lives in the repo
    const scriptSrc = path.resolve(__dirname, '../../scripts/generate-old-certificates.sh');
    const remotePath = `/home/${aixUser}/generate-old-certificates.sh`;

    await runScriptOnAIX({
      host: aixHost,
      username: aixUser,
      privateKeyPath: sshKeyPath,
      localScript: scriptSrc,
      remoteScript: remotePath,
      sudo: true,
      onOutput: (line) => {
        req.io.emit('setup:status', { step: line, progress: 50 });
      },
    });

    req.io.emit('setup:status', { step: 'Complete', progress: 100 });
    res.json({ success: true, certificatesCreated: 150 });
  } catch (err) {
    console.error('[setup] generate-certificates error:', err.message);
    req.io.emit('setup:error', { message: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
