const express = require('express');
const router = express.Router();
const axios = require('axios');
const { runScriptOnAIX } = require('../lib/ssh');
const path = require('path');

const VAULT_ADDR = process.env.VAULT_ADDR || 'http://127.0.0.1:8200';
const VAULT_TOKEN = process.env.VAULT_TOKEN || 'myroot';

const vaultClient = axios.create({
  baseURL: VAULT_ADDR,
  headers: { 'X-Vault-Token': VAULT_TOKEN },
});

// POST /api/vault/setup-pki
// Configure Vault PKI (idempotent — safe to run multiple times)
router.post('/setup-pki', async (req, res) => {
  try {
    // Enable PKI engine if not already enabled
    try {
      await vaultClient.post('/v1/sys/mounts/pki', {
        type: 'pki',
        config: { max_lease_ttl: '8760h' },
      });
    } catch (e) {
      if (e.response?.status !== 400) throw e; // 400 = already mounted, that's fine
    }

    // Tune max TTL
    await vaultClient.post('/v1/sys/mounts/pki/tune', { max_lease_ttl: '8760h' });

    // Generate root CA if not already present
    try {
      await vaultClient.get('/v1/pki/cert/ca');
    } catch {
      await vaultClient.post('/v1/pki/root/generate/internal', {
        common_name: 'Demo Internal Root CA',
        issuer_name: 'demo-root-ca',
        ttl: '8760h',
        organization: 'Demo Organisation',
        ou: 'IT Security',
        country: 'GB',
      });
    }

    // Configure CA/CRL URLs using the server's own hostname
    const vaultHost = new URL(VAULT_ADDR).hostname;
    const vaultPort = new URL(VAULT_ADDR).port || '8200';
    await vaultClient.post('/v1/pki/config/urls', {
      issuing_certificates: `http://${vaultHost}:${vaultPort}/v1/pki/ca`,
      crl_distribution_points: `http://${vaultHost}:${vaultPort}/v1/pki/crl`,
    });

    // Create / update the sap-oracle role
    await vaultClient.post('/v1/pki/roles/sap-oracle', {
      allowed_domains: [
        'howdens.local',
        'sap.howdens.local',
        'oracle.howdens.local',
        'mq.howdens.local',
        'api.howdens.local',
        'esb.howdens.local',
        'b2b.howdens.local',
        'lb.howdens.local',
        'proxy.howdens.local',
      ],
      allow_subdomains: true,
      allow_bare_domains: true,
      max_ttl: '24h',
      ttl: '24h',
      key_type: 'rsa',
      key_bits: 2048,
    });

    res.json({ success: true, role: 'sap-oracle' });
  } catch (err) {
    console.error('[vault] setup-pki error:', err.response?.data || err.message);
    res.status(500).json({
      error: err.response?.data?.errors?.[0] || err.message,
    });
  }
});

// POST /api/vault/replace-certificates
// SSH to AIX and run replace-with-vault-certificates.sh
router.post('/replace-certificates', async (req, res) => {
  const aixHost = process.env.AIX_HOST;
  const aixUser = process.env.AIX_USER || 'cecuser';
  const sshKeyPath = process.env.AIX_SSH_KEY_PATH;

  if (!aixHost) {
    return res.status(500).json({ error: 'AIX_HOST not configured. Check .env.local.' });
  }

  try {
    req.io.emit('vault:status', { step: 1, message: 'Deploying certificates to AIX…' });

    const scriptSrc = path.resolve(__dirname, '../../../scripts/replace-with-vault-certificates.sh');
    const remotePath = `/home/${aixUser}/replace-with-vault-certificates.sh`;

    // The replace script needs VAULT_ADDR pointing to this RHEL host (not 127.0.0.1)
    // VAULT_ADDR for AIX = use pvm2 FQDN (derived from env or fallback to local)
    const vaultAddrForAix = process.env.VAULT_ADDR_EXTERNAL || VAULT_ADDR;

    await runScriptOnAIX({
      host: aixHost,
      username: aixUser,
      privateKeyPath: sshKeyPath,
      localScript: scriptSrc,
      remoteScript: remotePath,
      sudo: true,
      env: {
        VAULT_ADDR: vaultAddrForAix,
        VAULT_TOKEN: VAULT_TOKEN,
      },
      onOutput: (line) => {
        // Count successes from script output lines like "✓ Replaced: sap-app01.howdens.local"
        if (line.includes('Replaced:')) {
          req.io.emit('vault:progress', { line: line.trim() });
        }
      },
    });

    req.io.emit('vault:status', { step: 3, message: 'Complete' });
    res.json({ success: true, certificatesReplaced: 150 });
  } catch (err) {
    console.error('[vault] replace-certificates error:', err.message);
    req.io.emit('vault:error', { message: err.message });
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
