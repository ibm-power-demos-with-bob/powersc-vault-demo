# PowerSC REST API Integration Guide

## Overview

This guide explains how to integrate PowerSC Quantum Safety scanning into the Howdens demo using REST APIs for faster, automated scanning.

## Problem Statement

**Current Issue**: Full PowerSC scans take 5-10 minutes because they scan entire filesystems (`/etc`, `/opt`, `/usr`, etc.)

**Solution**: 
1. Configure PowerSC to scan only our demo certificate directories
2. Use REST API to trigger scans programmatically
3. Integrate into demo UI for seamless execution

## Components

### 1. PowerSC uiAgent Configuration

**File**: [`configure-powersc-scan.sh`](configure-powersc-scan.sh:1)

**Purpose**: Configure PowerSC uiAgent to scan only demo certificate paths

**Usage**:
```bash
# On AIX client (p1229-pvm3)
scp configure-powersc-scan.sh cecuser@<AIX_HOST>:/home/cecuser/
ssh cecuser@<AIX_HOST>
sudo ./configure-powersc-scan.sh
```

**What it does**:
- Creates `/etc/security/powersc/uiAgent/quantumsafe.properties`
- Sets `scanFolders=/opt/sap,/opt/oracle,/opt/integration,/opt/loadbalancer,/opt/proxy`
- Reduces scan time from 5-10 minutes to 30-60 seconds

### 2. PowerSC REST API Helper

**File**: [`powersc-api-helper.sh`](powersc-api-helper.sh:1)

**Purpose**: Command-line tool to interact with PowerSC REST API

**Commands**:
```bash
# Trigger a scan
./powersc-api-helper.sh trigger-scan p1229-pvm3

# Get scan report
./powersc-api-helper.sh get-report p1229-pvm3

# Check scan status
./powersc-api-helper.sh check-status p1229-pvm3

# Configure auto-scan schedule
./powersc-api-helper.sh configure-schedule p1229-pvm3 daily
```

**Configuration**:
Set environment variables or edit the script:
```bash
export POWERSC_SERVER="your-powersc-server.com"
export POWERSC_PORT="8443"
export POWERSC_USER="admin"
export POWERSC_PASS="your-password"
```

## PowerSC REST API Endpoints

### Base URL
```
https://<powersc-server>:8443/api/v1
```

### Key Endpoints

#### 1. Trigger Quantum Safety Scan
```http
POST /quantumsafe/scan
Content-Type: application/json

{
  "hostname": "p1229-pvm3"
}
```

#### 2. Get Scan Report
```http
GET /quantumsafe/report?hostname=p1229-pvm3
```

**Response Example**:
```json
{
  "hostname": "p1229-pvm3",
  "scanDate": "2026-06-09T15:00:00Z",
  "totalCertificates": 150,
  "weakCertificates": 150,
  "expiredCertificates": 45,
  "findings": [
    {
      "path": "/opt/sap/app01/certs/server.pem",
      "issuer": "AffirmTrust Commercial",
      "notBefore": "2010-01-29T14:06:06Z",
      "notAfter": "2030-12-31T14:06:06Z",
      "algorithm": "sha1WithRSAEncryption",
      "keySize": 2048,
      "status": "weak",
      "issues": ["SHA-1 signature", "Old certificate (16 years)"]
    }
  ]
}
```

#### 3. Check Scan Status
```http
GET /quantumsafe/status?hostname=p1229-pvm3
```

**Response Example**:
```json
{
  "hostname": "p1229-pvm3",
  "status": "completed",
  "progress": 100,
  "startTime": "2026-06-09T15:00:00Z",
  "endTime": "2026-06-09T15:00:45Z",
  "duration": 45
}
```

#### 4. Configure Auto-Scan Schedule
```http
PUT /quantumsafeScheduleConfig
Content-Type: application/json

{
  "hostname": "p1229-pvm3",
  "schedule": "daily",
  "time": "02:00"
}
```

## Demo UI Integration

### Backend API Routes

Add these routes to your demo UI backend:

```javascript
// Trigger PowerSC scan
app.post('/api/powersc/scan', async (req, res) => {
  const { hostname } = req.body;
  
  try {
    const response = await axios.post(
      `${POWERSC_BASE_URL}/quantumsafe/scan`,
      { hostname },
      {
        auth: {
          username: POWERSC_USER,
          password: POWERSC_PASS
        },
        httpsAgent: new https.Agent({ rejectUnauthorized: false })
      }
    );
    
    res.json({ success: true, data: response.data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get scan report
app.get('/api/powersc/report/:hostname', async (req, res) => {
  const { hostname } = req.params;
  
  try {
    const response = await axios.get(
      `${POWERSC_BASE_URL}/quantumsafe/report?hostname=${hostname}`,
      {
        auth: {
          username: POWERSC_USER,
          password: POWERSC_PASS
        },
        httpsAgent: new https.Agent({ rejectUnauthorized: false })
      }
    );
    
    res.json({ success: true, data: response.data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Check scan status
app.get('/api/powersc/status/:hostname', async (req, res) => {
  const { hostname } = req.params;
  
  try {
    const response = await axios.get(
      `${POWERSC_BASE_URL}/quantumsafe/status?hostname=${hostname}`,
      {
        auth: {
          username: POWERSC_USER,
          password: POWERSC_PASS
        },
        httpsAgent: new https.Agent({ rejectUnauthorized: false })
      }
    );
    
    res.json({ success: true, data: response.data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});
```

### Frontend Components

```typescript
// PowerSC Scan Component
const PowerSCScan = () => {
  const [scanning, setScanning] = useState(false);
  const [report, setReport] = useState(null);
  
  const triggerScan = async () => {
    setScanning(true);
    
    try {
      // Trigger scan
      await fetch('/api/powersc/scan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ hostname: 'p1229-pvm3' })
      });
      
      // Poll for completion
      const pollInterval = setInterval(async () => {
        const statusRes = await fetch('/api/powersc/status/p1229-pvm3');
        const status = await statusRes.json();
        
        if (status.data.status === 'completed') {
          clearInterval(pollInterval);
          
          // Get report
          const reportRes = await fetch('/api/powersc/report/p1229-pvm3');
          const reportData = await reportRes.json();
          
          setReport(reportData.data);
          setScanning(false);
        }
      }, 5000); // Poll every 5 seconds
      
    } catch (error) {
      console.error('Scan failed:', error);
      setScanning(false);
    }
  };
  
  return (
    <div>
      <Button onClick={triggerScan} disabled={scanning}>
        {scanning ? 'Scanning...' : 'Run Quantum Safety Scan'}
      </Button>
      
      {report && (
        <div>
          <h3>Scan Results</h3>
          <p>Total Certificates: {report.totalCertificates}</p>
          <p>Weak Certificates: {report.weakCertificates}</p>
          <p>Expired: {report.expiredCertificates}</p>
          {/* Display findings table */}
        </div>
      )}
    </div>
  );
};
```

## Demo Workflow

### 1. Setup Phase (One-time)

```bash
# On AIX client
sudo ./configure-powersc-scan.sh

# Restart PowerSC uiAgent
sudo systemctl restart powersc-uiagent
```

### 2. Demo Execution

**BEFORE State**:
1. Click "Run Quantum Safety Scan" in demo UI
2. Wait 30-60 seconds (vs 5-10 minutes previously)
3. Display results showing 150 weak/old certificates
4. Capture screenshots/metrics

**Vault Integration**:
1. Click "Configure Vault PKI" in demo UI
2. Click "Replace Certificates with Vault"
3. Wait for replacement to complete

**AFTER State**:
1. Click "Run Quantum Safety Scan" again
2. Wait 30-60 seconds
3. Display results showing 0 weak certificates, all modern Vault-issued
4. Show before/after comparison

## Benefits

✅ **Faster Demos**: 30-60 seconds vs 5-10 minutes per scan
✅ **Automated**: No manual PowerSC console interaction
✅ **Professional**: Seamless UI-driven experience
✅ **Repeatable**: Easy to reset and re-run
✅ **Focused**: Only scans relevant certificate paths

## Troubleshooting

### Scan Configuration Not Applied

```bash
# Check if config file exists
cat /etc/security/powersc/uiAgent/quantumsafe.properties

# Restart uiAgent
sudo systemctl restart powersc-uiagent

# Check uiAgent logs
tail -f /var/log/powersc/uiagent.log
```

### API Authentication Fails

```bash
# Test API connectivity
curl -k -u admin:password \
  https://powersc-server:8443/api/v1/quantumsafe/status?hostname=p1229-pvm3

# Check credentials
echo $POWERSC_USER
echo $POWERSC_PASS
```

### Scan Takes Too Long

```bash
# Verify scan paths are limited
grep scanFolders /etc/security/powersc/uiAgent/quantumsafe.properties

# Should show only:
# scanFolders=/opt/sap,/opt/oracle,/opt/integration,/opt/loadbalancer,/opt/proxy
```

## Next Steps

1. **Configure PowerSC** - Run `configure-powersc-scan.sh` on AIX
2. **Test API** - Use `powersc-api-helper.sh` to verify connectivity
3. **Integrate UI** - Add PowerSC API routes to demo UI backend
4. **Build Frontend** - Create scan trigger and results display components
5. **Test End-to-End** - Run complete demo workflow

## Security Notes

- Store PowerSC credentials securely (environment variables, secrets manager)
- Use HTTPS for all API calls
- Consider certificate validation in production
- Implement proper error handling and logging
- Add authentication/authorization to demo UI endpoints

---

**Made with Bob - Pre-Sales Demo Builder**
