# PowerSC + HashiCorp Vault Demo

## Overview

This demo showcases the integration of IBM PowerSC Quantum Safety scanning with HashiCorp Vault PKI for automated certificate lifecycle management. Built for Howdens, this demonstration illustrates how to identify weak/old certificates and replace them with modern, short-lived certificates from Vault.

## Demo Story

**Problem**: Howdens has 150 certificates across their SAP and Oracle landscape. Many are 15+ years old with weak cryptography (SHA-1, RSA 1024/2048). PowerSC Quantum Safety scan reveals significant security risks.

**Solution**: Using HashiCorp Vault integrated with PowerSC, we automatically replace these certificates with modern, short-lived (24-hour) certificates. The rescan shows dramatic improvement in security posture.

## Architecture

```
Windows Desktop (Demo Control)
    |
    ├─> RHEL on IBM Power (129.40.59.194)
    |   └─> HashiCorp Vault
    |       └─> PKI Engine (24-hour certificates)
    |
    └─> AIX Client (129.40.59.195)
        ├─> SAP Applications (60 certificates)
        ├─> Oracle Databases (50 certificates)
        ├─> Integration/Middleware (30 certificates)
        └─> Infrastructure (10 certificates)
        
PowerSC Server
    └─> Quantum Safety Scanner
        └─> Scans AIX client for certificate vulnerabilities
```

## Repository Structure

```
powersc-vault-demo/
├── README.md                          # This file
├── docs/                              # Documentation
│   ├── DEPLOYMENT-GUIDE.md           # Complete deployment instructions
│   ├── DEMO-EXECUTION-GUIDE.md       # Step-by-step demo walkthrough
│   ├── DEPLOY-CERTIFICATES-GUIDE.md  # Certificate deployment details
│   ├── POWERSC-API-INTEGRATION.md    # PowerSC REST API integration
│   ├── AIX-TERMINAL-TIPS.md          # AIX terminal troubleshooting
│   ├── DEMO-UI-IMPLEMENTATION-PLAN.md # UI development plan
│   ├── powersc-ui-checklist.md       # UI feature checklist
│   ├── pre-sales-demo-skills.md      # Pre-sales demo best practices
│   └── hashicorp-vault-powersc-demo-plan.md # Original demo plan
├── scripts/                           # Automation scripts
│   ├── generate-old-certificates.sh  # Deploy 150 old certificates
│   ├── vault-pki-setup.sh            # Configure Vault PKI
│   ├── replace-with-vault-certificates.sh # Replace with Vault certs
│   ├── configure-powersc-scan.sh     # Optimize PowerSC scanning
│   ├── powersc-api-helper.sh         # PowerSC REST API tool
│   ├── deploy-demo.sh                # Full demo deployment
│   └── deploy-ui.sh                  # Deploy demo UI
└── ui/                                # Demo UI (future)
    └── package.json                   # UI dependencies
```

## Quick Start

### Prerequisites

- Access to TechZone environment with:
  - RHEL on IBM Power (Vault server)
  - AIX client (certificate host)
  - PowerSC server (scanning)
- SSH access with password: `8-P5VO+NT3UR5!g`
- Windows desktop with SCP/SSH client

### 1. Deploy Old Certificates (BEFORE State)

```bash
# Transfer script to AIX
scp scripts/generate-old-certificates.sh cecuser@129.40.59.195:/home/cecuser/

# SSH to AIX and run
ssh cecuser@129.40.59.195
sudo ./generate-old-certificates.sh
```

**Result**: 150 certificates deployed (2008-2011 vintage, weak crypto)

### 2. Run PowerSC Scan (BEFORE)

- Log into PowerSC console
- Navigate to Quantum Safety
- Run scan on AIX client (p1229-pvm3)
- Capture screenshots showing weak/old certificates

### 3. Configure Vault PKI

```bash
# Transfer script to RHEL
scp scripts/vault-pki-setup.sh cecuser@129.40.59.194:/home/cecuser/

# SSH to RHEL and run
ssh cecuser@129.40.59.194
./vault-pki-setup.sh
```

**Result**: Vault configured to issue 24-hour certificates

### 4. Replace Certificates

```bash
# On AIX
./replace-with-vault-certificates.sh
```

**Result**: All 150 certificates replaced with Vault-issued ones

### 5. Run PowerSC Scan (AFTER)

- Trigger another Quantum Safety scan
- Compare BEFORE vs AFTER results
- Show improvement in security posture

## Key Features

✅ **Realistic Scenario** - 150 certificates across SAP/Oracle/Integration paths
✅ **Authentic Old Certificates** - Real CA certificates from 2008-2011
✅ **Weak Crypto Detection** - SHA-1, RSA 1024/2048 flagged by PowerSC
✅ **Automated Replacement** - Vault PKI integration
✅ **Short-lived Certificates** - 24-hour TTL from Vault
✅ **Fast Scanning** - Optimized PowerSC configuration (30-60 seconds)
✅ **API Integration** - REST API for automation
✅ **Repeatable** - Easy to reset and re-run

## Demo Timing

- **Setup** (one-time): 10-15 minutes
- **Certificate Deployment**: 1-2 minutes
- **PowerSC Scan**: 30-60 seconds (optimized) or 5-10 minutes (full)
- **Vault Configuration**: 2-3 minutes
- **Certificate Replacement**: 2-3 minutes
- **Total Demo Time**: 15-20 minutes

## Environment Details

### RHEL on IBM Power (Vault Server)
- **IP**: 129.40.59.194
- **Hostname**: p1229-pvm2
- **User**: cecuser
- **Role**: HashiCorp Vault PKI

### AIX Client (Certificate Host)
- **IP**: 129.40.59.195
- **Hostname**: p1229-pvm3
- **User**: cecuser
- **Role**: SAP/Oracle workload simulation

### PowerSC Server
- **Role**: Quantum Safety scanning
- **API**: REST API for automation

## Documentation

- **[DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md)** - Complete setup instructions
- **[DEMO-EXECUTION-GUIDE.md](docs/DEMO-EXECUTION-GUIDE.md)** - Step-by-step demo flow
- **[POWERSC-API-INTEGRATION.md](docs/POWERSC-API-INTEGRATION.md)** - API automation guide
- **[AIX-TERMINAL-TIPS.md](docs/AIX-TERMINAL-TIPS.md)** - Troubleshooting tips

## Troubleshooting

### Certificates not showing as old
- Verify you're using `generate-old-certificates.sh` (not generating new ones)
- Check certificate dates: `openssl x509 -in /opt/sap/app01/certs/server.pem -noout -dates`

### PowerSC scan takes too long
- Run `configure-powersc-scan.sh` to optimize scan paths
- Restart PowerSC uiAgent: `sudo systemctl restart powersc-uiagent`

### Vault connection fails
- Verify Vault is running: `vault status`
- Check network connectivity between RHEL and AIX
- Verify Vault token is valid

## Future Enhancements

- [ ] Complete demo UI with React/Carbon
- [ ] PowerSC REST API integration
- [ ] Automated before/after comparison
- [ ] Certificate lifecycle visualization
- [ ] Multi-environment support

## Credits

Built with Bob - Pre-Sales Demo Builder
For Howdens demonstration
IBM PowerSC + HashiCorp Vault Integration

## License

Internal IBM demonstration use only.