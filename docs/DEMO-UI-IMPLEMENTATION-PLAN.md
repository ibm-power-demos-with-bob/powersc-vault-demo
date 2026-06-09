# PowerSC + Vault Demo UI - Implementation Plan

## Overview

Executive-friendly Carbon Design System web interface for demonstrating HashiCorp Vault "taking over" certificate management from manual processes. Hides technical complexity behind polished UI suitable for Line of Business stakeholders.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Frontend (Next.js 13 + Carbon Design System)                │
│ - React components with Carbon UI                           │
│ - Runs on port 3001                                         │
│ - IBM Plex typography, Carbon spacing                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ Backend API (Node.js/Express)                               │
│ - REST endpoints for demo operations                        │
│ - WebSocket for real-time progress                          │
│ - Runs on port 3002                                         │
└─────────────────────────────────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ SSH to AIX   │  │ Vault API    │  │ PowerSC API  │
│ (p1229-pvm3) │  │ (localhost)  │  │ (p1229-pvm1) │
│              │  │              │  │              │
│ Run scripts  │  │ PKI ops      │  │ Scan trigger │
└──────────────┘  └──────────────┘  └──────────────┘
```

## Technology Stack

**Frontend:**
- Next.js 13 (App Router)
- React 18.2.0
- @carbon/react 1.33.0
- @carbon/icons-react 11.71.0
- @carbon/pictograms-react 11.71.0
- Socket.io-client (real-time updates)

**Backend:**
- Node.js 18+
- Express.js
- Socket.io (WebSocket)
- ssh2 (SSH to AIX client)
- axios (Vault API calls)

**Deployment:**
- RHEL on IBM Power (p1229-pvm2)
- Runs alongside Vault
- Port 3001 (frontend), 3002 (backend)

## Page Structure

### Page 1: The Challenge (/)

**Purpose:** Explain the problem and set up the demo environment

**Components:**
- Hero section with title: "Howdens Certificate Management Challenge"
- Infographic showing SAP/Oracle landscape (150 certificates)
- "Why These Numbers Are Realistic" section:
  - 700+ stores across UK
  - Manufacturing + distribution facilities
  - Industry benchmarks (Gartner data)
- Current state metrics (4 Carbon Tiles):
  ```
  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
  │ 📊 449      │ │ ⏰ 287+     │ │ ⚠️ 55%      │ │ 🔒 0        │
  │ Weak Certs  │ │ Days Old    │ │ Compliance  │ │ Quantum-Safe│
  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘
  ```
- Big Carbon Button: "Generate Demo Environment"
- Progress indicator (Carbon ProgressBar + InlineLoading)
- Link to PowerSC UI (Carbon Link with Launch icon)

**API Endpoints:**
- POST `/api/setup/generate-certificates`
  - Triggers SSH to AIX client
  - Runs `generate-old-certificates.sh`
  - Returns progress via WebSocket
  - Response: `{ success: true, certificatesCreated: 150 }`

**State Management:**
```javascript
const [setupStatus, setSetupStatus] = useState('idle'); // idle, running, complete, error
const [progress, setProgress] = useState(0); // 0-100
const [certificatesCreated, setCertificatesCreated] = useState(0);
```

### Page 2: The Solution (/solution)

**Purpose:** Show Vault integration and value proposition

**Components:**
- Hero section: "HashiCorp Vault Takes Over"
- Animated diagram (Carbon Pictograms):
  - Manual process (spreadsheet icon) → Vault (security icon)
  - Old certificates (warning icon) → New certificates (checkmark icon)
- Value proposition (4 Carbon Tiles):
  ```
  ┌─────────────────┐ ┌─────────────────┐
  │ ⚡ Automated    │ │ 🔐 Strong Crypto│
  │ 24-hour TTL     │ │ RSA 2048        │
  │ rotation        │ │ SHA-256         │
  └─────────────────┘ └─────────────────┘
  ┌─────────────────┐ ┌─────────────────┐
  │ 🛡️ Quantum-Safe │ │ 📉 99.2%        │
  │ Ready           │ │ Age Reduction   │
  └─────────────────┘ └─────────────────┘
  ```
- Big Carbon Button: "Deploy Vault Certificates"
- Real-time progress (Carbon ProgressIndicator with steps):
  1. Configure Vault PKI
  2. Issue Certificates (0/150)
  3. Deploy to AIX
  4. Complete
- Link to PowerSC UI

**API Endpoints:**
- POST `/api/vault/setup-pki`
  - Runs `vault-pki-setup.sh`
  - Returns: `{ success: true, rootCA: "...", role: "sap-oracle" }`
- POST `/api/vault/replace-certificates`
  - Triggers SSH to AIX client
  - Runs `replace-with-vault-certificates.sh`
  - Returns progress via WebSocket
  - Response: `{ success: true, certificatesReplaced: 150 }`

**State Management:**
```javascript
const [deploymentStatus, setDeploymentStatus] = useState('idle');
const [currentStep, setCurrentStep] = useState(0); // 0-3
const [certificatesIssued, setCertificatesIssued] = useState(0);
```

### Page 3: The Results (/results)

**Purpose:** Show before/after comparison and ROI

**Components:**
- Hero section: "The Transformation"
- Side-by-side comparison (Carbon Grid with 2 columns):
  ```
  ┌─────────────────────┬─────────────────────┐
  │ BEFORE              │ AFTER               │
  ├─────────────────────┼─────────────────────┤
  │ 449 weak certs      │ 299 weak certs      │
  │ 55% compliance      │ 75% compliance      │
  │ 0 quantum-safe      │ 150 quantum-safe    │
  │ 287 days avg age    │ 24 hours avg age    │
  └─────────────────────┴─────────────────────┘
  ```
- Animated metrics (Carbon NumberInput with animation):
  - Weak certificates: 449 → 299 (33% ↓)
  - Compliance score: 55% → 75% (20 points ↑)
  - Quantum-safe: 0 → 150 (8.7% of estate)
  - Average age: 287 days → 24 hours (99.2% ↓)
- ROI Calculator (Carbon Form with inputs):
  - Outages prevented per year
  - Manual hours saved per month
  - Security posture improvement
- Call to action (Carbon Button): "View Full PowerSC Report"

**API Endpoints:**
- GET `/api/metrics/before`
  - Returns: `{ weakCerts: 449, compliance: 55, quantumSafe: 0, avgAge: 287 }`
- GET `/api/metrics/after`
  - Returns: `{ weakCerts: 299, compliance: 75, quantumSafe: 150, avgAge: 0.04 }`
- POST `/api/metrics/calculate-roi`
  - Input: `{ outagesPerYear, hoursPerMonth }`
  - Returns: `{ costSavings, timeSavings, riskReduction }`

## File Structure

```
powersc-vault-demo-ui/
├── package.json
├── next.config.js
├── jsconfig.json
├── .gitignore
├── README.md
├── public/
│   ├── favicon.ico
│   └── images/
│       ├── howdens-logo.svg
│       ├── vault-logo.svg
│       └── powersc-logo.svg
├── src/
│   ├── app/
│   │   ├── layout.js                 # Root layout with Carbon Theme
│   │   ├── page.js                   # Page 1: The Challenge
│   │   ├── solution/
│   │   │   └── page.js               # Page 2: The Solution
│   │   ├── results/
│   │   │   └── page.js               # Page 3: The Results
│   │   ├── globals.scss              # Global Carbon styles
│   │   └── api/
│   │       ├── setup/
│   │       │   └── generate-certificates/
│   │       │       └── route.js      # API: Generate certificates
│   │       ├── vault/
│   │       │   ├── setup-pki/
│   │       │   │   └── route.js      # API: Setup Vault PKI
│   │       │   └── replace-certificates/
│   │       │       └── route.js      # API: Replace certificates
│   │       └── metrics/
│   │           ├── before/
│   │           │   └── route.js      # API: Get before metrics
│   │           ├── after/
│   │           │   └── route.js      # API: Get after metrics
│   │           └── calculate-roi/
│   │               └── route.js      # API: Calculate ROI
│   ├── components/
│   │   ├── Header/
│   │   │   ├── Header.js             # Carbon Header with navigation
│   │   │   └── Header.module.scss
│   │   ├── MetricCard/
│   │   │   ├── MetricCard.js         # Reusable metric tile
│   │   │   └── MetricCard.module.scss
│   │   ├── ProgressTracker/
│   │   │   ├── ProgressTracker.js    # Real-time progress component
│   │   │   └── ProgressTracker.module.scss
│   │   ├── ComparisonTable/
│   │   │   ├── ComparisonTable.js    # Before/After comparison
│   │   │   └── ComparisonTable.module.scss
│   │   └── ROICalculator/
│   │       ├── ROICalculator.js      # ROI calculation form
│   │       └── ROICalculator.module.scss
│   ├── lib/
│   │   ├── ssh.js                    # SSH client for AIX
│   │   ├── vault.js                  # Vault API client
│   │   └── socket.js                 # WebSocket utilities
│   └── styles/
│       └── _carbon-overrides.scss    # Carbon theme customization
└── server/
    ├── index.js                      # Express server
    ├── socket.js                     # WebSocket server
    └── routes/
        ├── setup.js                  # Setup routes
        ├── vault.js                  # Vault routes
        └── metrics.js                # Metrics routes
```

## Key Components

### 1. Header Component

```javascript
// src/components/Header/Header.js
import { Header, HeaderName, HeaderNavigation, HeaderMenuItem } from '@carbon/react';

export default function DemoHeader() {
  return (
    <Header aria-label="PowerSC + Vault Demo">
      <HeaderName href="/" prefix="IBM">
        PowerSC + Vault Demo
      </HeaderName>
      <HeaderNavigation aria-label="Demo Navigation">
        <HeaderMenuItem href="/">The Challenge</HeaderMenuItem>
        <HeaderMenuItem href="/solution">The Solution</HeaderMenuItem>
        <HeaderMenuItem href="/results">The Results</HeaderMenuItem>
      </HeaderNavigation>
    </Header>
  );
}
```

### 2. MetricCard Component

```javascript
// src/components/MetricCard/MetricCard.js
import { Tile } from '@carbon/react';
import styles from './MetricCard.module.scss';

export default function MetricCard({ icon, value, label, trend }) {
  return (
    <Tile className={styles.metricCard}>
      <div className={styles.icon}>{icon}</div>
      <div className={styles.value}>{value}</div>
      <div className={styles.label}>{label}</div>
      {trend && <div className={styles.trend}>{trend}</div>}
    </Tile>
  );
}
```

### 3. ProgressTracker Component

```javascript
// src/components/ProgressTracker/ProgressTracker.js
import { ProgressIndicator, ProgressStep, InlineLoading } from '@carbon/react';
import { useEffect, useState } from 'react';
import io from 'socket.io-client';

export default function ProgressTracker({ operation }) {
  const [currentStep, setCurrentStep] = useState(0);
  const [progress, setProgress] = useState({});

  useEffect(() => {
    const socket = io('http://localhost:3002');
    
    socket.on(`${operation}:progress`, (data) => {
      setProgress(data);
      setCurrentStep(data.step);
    });

    return () => socket.disconnect();
  }, [operation]);

  const steps = [
    { label: 'Initializing', description: 'Preparing environment' },
    { label: 'Processing', description: `${progress.current || 0}/${progress.total || 0}` },
    { label: 'Completing', description: 'Finalizing changes' },
    { label: 'Done', description: 'Operation complete' }
  ];

  return (
    <ProgressIndicator currentIndex={currentStep}>
      {steps.map((step, index) => (
        <ProgressStep
          key={index}
          label={step.label}
          description={step.description}
          complete={index < currentStep}
          current={index === currentStep}
        />
      ))}
    </ProgressIndicator>
  );
}
```

## Backend API Implementation

### SSH Client for AIX

```javascript
// src/lib/ssh.js
const { Client } = require('ssh2');

class SSHClient {
  constructor(config) {
    this.config = {
      host: config.host || '129.40.59.195',
      port: config.port || 22,
      username: config.username || 'cecuser',
      privateKey: config.privateKey // SSH key for authentication
    };
  }

  async executeScript(scriptPath, onProgress) {
    return new Promise((resolve, reject) => {
      const conn = new Client();
      
      conn.on('ready', () => {
        conn.exec(`bash ${scriptPath}`, (err, stream) => {
          if (err) return reject(err);
          
          let output = '';
          
          stream.on('data', (data) => {
            output += data.toString();
            // Parse progress from script output
            const match = output.match(/(\d+)\/(\d+)/);
            if (match && onProgress) {
              onProgress({
                current: parseInt(match[1]),
                total: parseInt(match[2])
              });
            }
          });
          
          stream.on('close', (code) => {
            conn.end();
            if (code === 0) {
              resolve({ success: true, output });
            } else {
              reject(new Error(`Script exited with code ${code}`));
            }
          });
        });
      });
      
      conn.on('error', reject);
      conn.connect(this.config);
    });
  }
}

module.exports = SSHClient;
```

### Vault API Client

```javascript
// src/lib/vault.js
const axios = require('axios');

class VaultClient {
  constructor(config) {
    this.baseURL = config.baseURL || 'http://127.0.0.1:8200';
    this.token = config.token;
    this.client = axios.create({
      baseURL: this.baseURL,
      headers: {
        'X-Vault-Token': this.token
      }
    });
  }

  async setupPKI() {
    // Enable PKI secrets engine
    await this.client.post('/v1/sys/mounts/pki', {
      type: 'pki',
      config: { max_lease_ttl: '8760h' }
    });

    // Generate root CA
    const rootCA = await this.client.post('/v1/pki/root/generate/internal', {
      common_name: 'Howdens Internal Root CA',
      ttl: '8760h'
    });

    // Create role
    await this.client.post('/v1/pki/roles/sap-oracle', {
      allowed_domains: 'howdens.local,sap.howdens.local,oracle.howdens.local',
      allow_subdomains: true,
      max_ttl: '24h',
      ttl: '24h',
      key_type: 'rsa',
      key_bits: 2048
    });

    return {
      success: true,
      rootCA: rootCA.data.data.certificate,
      role: 'sap-oracle'
    };
  }

  async issueCertificate(commonName) {
    const response = await this.client.post('/v1/pki/issue/sap-oracle', {
      common_name: commonName,
      ttl: '24h'
    });

    return {
      certificate: response.data.data.certificate,
      privateKey: response.data.data.private_key,
      serialNumber: response.data.data.serial_number
    };
  }
}

module.exports = VaultClient;
```

### WebSocket Server

```javascript
// server/socket.js
const { Server } = require('socket.io');

function setupWebSocket(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: 'http://localhost:3001',
      methods: ['GET', 'POST']
    }
  });

  io.on('connection', (socket) => {
    console.log('Client connected:', socket.id);

    socket.on('disconnect', () => {
      console.log('Client disconnected:', socket.id);
    });
  });

  return io;
}

module.exports = setupWebSocket;
```

## Deployment Instructions

### 1. Transfer Files to RHEL Client

```bash
# On your local machine
scp -r powersc-vault-demo-ui cecuser@129.40.59.194:/home/cecuser/

# SSH to RHEL client
ssh cecuser@129.40.59.194
cd /home/cecuser/powersc-vault-demo-ui
```

### 2. Install Dependencies

```bash
# Install Node.js 18+ (if not already installed)
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install project dependencies
npm install
```

### 3. Configure Environment

```bash
# Create .env.local file
cat > .env.local << EOF
# AIX Client SSH Configuration
AIX_HOST=129.40.59.195
AIX_USER=cecuser
AIX_SSH_KEY_PATH=/home/cecuser/.ssh/id_rsa

# Vault Configuration
VAULT_ADDR=http://127.0.0.1:8200
VAULT_TOKEN=your-vault-root-token

# PowerSC Configuration
POWERSC_URL=https://p1229-pvm1.p1229.cecc.ihost.com
POWERSC_USER=powersc-admin
POWERSC_PASSWORD=your-password

# Server Configuration
NEXT_PUBLIC_API_URL=http://129.40.59.194:3002
EOF
```

### 4. Build and Start

```bash
# Build the application
npm run build

# Start the application
npm start

# Or for development
npm run dev
```

### 5. Access the Demo

Open browser to: `http://129.40.59.194:3001`

## Demo Execution Flow

### For Line of Business Executive

1. **Open demo UI** → Clean, professional IBM-branded interface
2. **Page 1: The Challenge**
   - Read about Howdens' certificate problem
   - See why 150 certificates is realistic
   - Click "Generate Demo Environment"
   - Watch progress bar (30-60 seconds)
   - Click link to PowerSC → See 449 weak certificates
3. **Page 2: The Solution**
   - Read about Vault value proposition
   - Click "Deploy Vault Certificates"
   - Watch real-time progress (2-3 minutes)
   - Click link to PowerSC → See 299 weak certificates
4. **Page 3: The Results**
   - See before/after comparison
   - View animated metrics
   - Use ROI calculator
   - Understand business value

### What Executive Sees
- ✅ Professional IBM Carbon UI
- ✅ Business metrics and ROI
- ✅ Clear before/after story
- ✅ One-click demo execution
- ✅ Links to PowerSC for proof

### What Executive Doesn't See
- ❌ Bash scripts
- ❌ SSH commands
- ❌ Certificate file paths
- ❌ Technical implementation
- ❌ Command-line interfaces

## Carbon Design System Guidelines

### Typography
- Use IBM Plex Sans for all text
- Headings: `productive-heading-07` (42px)
- Body: `body-long-02` (16px)
- Labels: `label-01` (12px)

### Spacing
- Use Carbon spacing tokens: `$spacing-05` (16px), `$spacing-07` (32px)
- Grid: 16-column grid with 32px gutters
- Breakpoints: sm (320px), md (672px), lg (1056px), xlg (1312px)

### Colors
- Primary: IBM Blue (#0f62fe)
- Success: Green (#24a148)
- Warning: Yellow (#f1c21b)
- Error: Red (#da1e28)
- Background: Gray 10 (#f4f4f4)

### Components
- Use Carbon components exclusively
- No custom UI components
- Follow Carbon patterns and best practices
- Ensure accessibility (WCAG 2.1 AA)

## Testing Checklist

- [ ] Frontend builds successfully
- [ ] Backend API starts without errors
- [ ] WebSocket connection established
- [ ] SSH to AIX client works
- [ ] Vault API calls succeed
- [ ] Certificate generation completes
- [ ] Certificate replacement completes
- [ ] Progress updates in real-time
- [ ] PowerSC links work
- [ ] Metrics display correctly
- [ ] ROI calculator functions
- [ ] Responsive design works
- [ ] Accessibility standards met

## Maintenance

### Updating Scripts
If you modify the bash scripts, ensure:
1. Progress output format remains consistent
2. Exit codes are correct (0 = success)
3. Error messages are clear
4. Execution time is reasonable

### Updating Metrics
If PowerSC metrics change:
1. Update `/api/metrics/before` endpoint
2. Update `/api/metrics/after` endpoint
3. Update comparison table in results page
4. Update ROI calculator assumptions

### Troubleshooting

**Issue:** SSH connection fails
- Check SSH key permissions (chmod 600)
- Verify AIX client is accessible
- Check firewall rules

**Issue:** Vault API fails
- Verify Vault is running and unsealed
- Check VAULT_TOKEN is valid
- Ensure PKI engine is enabled

**Issue:** Progress not updating
- Check WebSocket connection
- Verify port 3002 is accessible
- Check browser console for errors

## Next Steps

1. **Create the full application** using this plan
2. **Test on RHEL/Power** to ensure compatibility
3. **Customize branding** with Howdens colors/logos
4. **Add screenshots** from PowerSC for before/after
5. **Practice demo flow** to ensure smooth execution
6. **Prepare talking points** for each page
7. **Create backup plan** if live demo fails

## Estimated Development Time

- Frontend pages: 8-12 hours
- Backend API: 6-8 hours
- WebSocket integration: 4-6 hours
- Testing and debugging: 6-8 hours
- **Total: 24-34 hours**

## Success Criteria

✅ Executive can run entire demo with 3 button clicks
✅ Demo completes in under 5 minutes
✅ UI is professional and IBM-branded
✅ Metrics show clear improvement
✅ ROI is compelling and realistic
✅ PowerSC integration works seamlessly
✅ No technical jargon visible to executive
✅ Demo is repeatable and reliable

---

**This implementation plan provides everything needed to build an executive-friendly demo UI that hides technical complexity while showcasing the business value of Vault + PowerSC integration.**