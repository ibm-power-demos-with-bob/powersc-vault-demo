const express = require('express');
const router = express.Router();

// GET /api/metrics/before
router.get('/before', (_req, res) => {
  res.json({
    weakCerts: 150,
    avgAgeDays: 5475, // ~15 years
    complianceScore: 67,
    quantumSafe: 0,
    certAuthority: 'Legacy CA bundle (2008–2011)',
    managementMethod: 'Manual',
  });
});

// GET /api/metrics/after
router.get('/after', (_req, res) => {
  res.json({
    weakCerts: 0,
    avgAgeHours: 24,
    complianceScore: 98,
    quantumSafe: 150,
    certAuthority: 'HashiCorp Vault PKI (sap-oracle role)',
    managementMethod: 'Automated',
  });
});

// POST /api/metrics/calculate-roi
router.post('/calculate-roi', (req, res) => {
  const { outagesPerYear = 3, hoursPerMonth = 8 } = req.body;
  const outageHours = outagesPerYear * 4;
  const avoidedDowntimeCost = outageHours * 25000;
  const staffTimeSaved = hoursPerMonth * 12 * 150;
  res.json({
    avoidedDowntimeCost,
    staffTimeSaved,
    total: avoidedDowntimeCost + staffTimeSaved,
    assumptions: {
      downtimeCostPerHour: 25000,
      avgOutageDurationHours: 4,
      staffCostPerHour: 150,
    },
  });
});

module.exports = router;
