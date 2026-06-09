# Pre-Sales Demo Skills Log

## Skill: Pivot to Power-Native Containers When Native Power Binaries Are Unavailable

### Context
Use this skill during IBM Power demo builds when a required product does not provide a current native `ppc64le` binary or package, but the demo still needs to run credibly on IBM Power infrastructure.

### Trigger Pattern
Apply this skill when all of the following are true:

1. The demo is a **Platform Reality** demo
2. The target environment is IBM Power / `ppc64le`
3. Native install path fails or is unavailable
4. A Power-native container image exists from a credible source
5. The audience cares more about the operational outcome than the packaging format

### Why This Matters
In pre-sales, credibility matters more than purity of installation method.

If the customer needs to see:
- the workload running on IBM Power
- the IBM platform observing or integrating with it
- the business/security outcome

then a Power-native container is often the fastest believable route.

### Decision Rule
Prefer a Power-native container image when:

- native `ppc64le` binaries are missing from the vendor release site
- the container image is available from a trusted registry
- the runtime can be supported in the reserved environment
- using the container does not weaken the story being told

### Example: HashiCorp Vault on IBM Power
Observed pattern:
- Current HashiCorp release pages exposed Linux builds for `386`, `amd64`, `arm`, and `arm64`
- No current native `ppc64le` Vault binary was available from the tested release pages
- A Power-native image was visible from IBM container registry patterns such as:
  - `icr.io/ppc64le-oss/vault-ppc64le:v1.14.8`

### Recommended Narrative
Say:
- "Vault is running on IBM Power in a Power-native container deployment model"
- "PowerSC is monitoring the managed endpoint and the resulting certificate posture"
- "We chose the fastest credible deployment path for this environment while preserving the architecture story"

Do not say:
- "We had to fake it because the binary was missing"

### Architectural Guidance
For demos like Vault + PowerSC:

- Keep the **management plane** separate from the **workload plane**
- Avoid installing experimental components on the PowerSC server if an agent/workload VM is available
- Prefer:
  - PowerSC server/UI on one host
  - Vault or supporting service on a separate RHEL Power host
  - monitored certificate targets on the same or adjacent managed hosts

### Demo Credibility Test
This skill is valid if the customer would still say:
- "That looked like us"
- "That could fit our environment"
- "Can we try this in our estate?"

If yes, the packaging choice is acceptable.

### Reusable Procedure
1. Validate architecture and audience
2. Attempt native install path
3. Confirm native Power artifact gap
4. Search for trusted Power-native container image
5. Verify runtime availability (`podman` preferred, `docker` acceptable)
6. Deploy container with minimal production-like configuration
7. Integrate with the IBM platform story
8. Capture the rationale in the demo notes

### Preferred Runtime Order
1. `podman`
2. `docker`
3. install runtime only if needed and low-risk

### Risks
- Container runtime may not be installed
- Registry access may be blocked
- Security teams may ask whether containerization is production intent

### Mitigations
- Verify runtime before committing
- Pre-pull image during prep if possible
- Position containerization as the demo deployment method, not the only production option

### How to Reuse This Skill Later
When a future IBM Power demo hits a packaging dead-end, recall:

**"Pivot to Power-native containers when native Power binaries are unavailable, as long as the platform story and customer credibility remain intact."**

### Current Example Reference
- Customer: Howdens
- Demo: HashiCorp Vault + IBM PowerSC
- Environment: TechZone PowerSC reservation with RHEL Power agent
- Decision: Prefer Vault on RHEL Power agent via Power-native container if no native binary is available

## Skill: Diagnose and Remediate `fapolicyd` Blocking Podman on PowerSC RHEL Hosts

### Context
Use this skill when Podman containers fail to start on a PowerSC-prepared RHEL host even though:
- Podman is installed
- images can be pulled
- file permissions look normal
- SELinux is permissive or not obviously blocking execution

This is especially relevant on PowerSC environments where file trust / allow-listing controls may already be active on the image.

### Trigger Pattern
Apply this skill when you see symptoms like:
- `Operation not permitted`
- `runc create failed`
- `crun` or `runc` failing while loading shared libraries
- Podman can pull images but cannot start even a minimal container
- stopping `fapolicyd` temporarily makes the same container run successfully

### Why This Matters
This failure can look like:
- a Podman problem
- a Vault image problem
- an IBM Power compatibility problem
- a generic OCI runtime issue

But on hardened PowerSC RHEL hosts, the real issue may be `fapolicyd` trust enforcement.

Recognizing this quickly can save hours of unproductive runtime debugging.

### Diagnostic Pattern
Typical evidence includes:
- `fapolicyd` service is active
- rules such as:
  - `allow perm=open all : ftype=application/x-sharedlib trust=1`
  - `deny_audit perm=open all : ftype=application/x-sharedlib`
  - `allow perm=execute all : trust=1`
  - `deny_audit perm=execute all : all`
- runtime errors mentioning shared libraries such as:
  - `/lib64/libresolv.so.2`
  - `/lib64/libsystemd.so.0`
- a controlled test where:
  - `sudo systemctl stop fapolicyd`
  - Podman container runs successfully
  - `sudo systemctl start fapolicyd`

### Recommended Diagnostic Flow
1. Confirm Podman image pull works
2. Confirm minimal container run fails
3. Check `fapolicyd` status
4. Inspect active rules and trust behavior
5. Perform a controlled stop/start test for `fapolicyd`
6. If confirmed, add required runtime binaries and libraries to trust
7. Reload `fapolicyd`
8. Retest minimal container
9. Only then retry the target workload container

### Minimal Trust Remediation Example
For OCI runtime execution on affected PowerSC RHEL hosts, explicitly trust:

- `/usr/bin/runc`
- `/usr/bin/crun`
- `/bin/conmon`
- `/lib64/libresolv.so.2`
- `/lib64/libsystemd.so.0`

Example commands:

```bash
echo '/usr/bin/runc' | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/usr/bin/crun' | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/bin/conmon' | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/lib64/libresolv.so.2' | sudo tee -a /etc/fapolicyd/fapolicyd.trust
echo '/lib64/libsystemd.so.0' | sudo tee -a /etc/fapolicyd/fapolicyd.trust

sudo fapolicyd-cli --update
sudo systemctl restart fapolicyd
sudo podman run --rm registry.access.redhat.com/ubi9/ubi-minimal echo hello
```

### Demo Guidance
If this issue appears during prep:
- do not immediately abandon the same-reservation architecture
- first test whether `fapolicyd` trust remediation restores container execution
- if it does, keep the cleaner same-reservation story

### Risks
- modifying trust policy on a prepared environment may need care
- additional binaries or libraries may also need trust entries
- some environments may have broader hardening beyond `fapolicyd`

### Mitigations
- use a minimal container test first
- make only targeted trust additions
- document exactly what was added and why
- keep a fallback healthy IBM Power host available during prep

### Current Example Reference
- Customer: Howdens
- Demo: HashiCorp Vault + IBM PowerSC
- Host: `p1229-pvm2`
- Root cause: `fapolicyd` blocked OCI runtime binaries/libraries
- Fix: add runtime binaries and required shared libraries to `/etc/fapolicyd/fapolicyd.trust`, update policy, restart daemon

## Skill: Use System Package Manager for Node.js on ppc64le Architecture

### Context
Use this skill when building Carbon Design System demos or any Node.js-based applications on IBM Power (`ppc64le`) architecture, particularly on RHEL systems in TechZone environments.

### Trigger Pattern
Apply this skill when all of the following are true:

1. The demo requires Node.js (e.g., Carbon UI, Next.js, React applications)
2. The target environment is IBM Power / `ppc64le` architecture
3. You're writing deployment scripts or installation procedures
4. Standard Node.js installation methods (NodeSource, nvm) are being considered

### Why This Matters
Third-party Node.js repositories like NodeSource **do not support ppc64le architecture**. Attempting to use them will result in:
- "Unsupported architecture: ppc64le" errors
- Failed deployments
- Wasted time debugging what appears to be a Node.js problem

However, RHEL's system package manager (`dnf`/`yum`) **does provide Node.js packages for ppc64le**.

### The Problem Pattern
Common mistake in deployment scripts:

```bash
# ❌ DOES NOT WORK on ppc64le
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs
```

Error message:
```
Error: Unsupported architecture: ppc64le. 
Only aarch64 and x86_64 are supported.
```

### The Solution Pattern
Use the system package manager directly:

```bash
# ✅ WORKS on ppc64le
sudo dnf install -y nodejs npm
```

Or for yum-based systems:
```bash
sudo yum install -y nodejs npm
```

### Verification Pattern
After installation, verify Node.js is working:

```bash
node --version
npm --version
```

### Real-World Example
**Working deployment script** (from Carbon GenAI demo):
```bash
# Phase 2: Install System Dependencies
install_dependencies() {
    print_step "📦 Installing system dependencies..."
    
    local packages="python3.12 python3.12-pip python3.12-devel git gcc gcc-c++ nodejs make cmake automake llvm-toolset ninja-build gfortran curl-devel wget"
    
    if run_command "sudo dnf install -y $packages" "System dependencies installed"; then
        # Verify installations
        for cmd in python3.12 git gcc g++ node npm make cmake wget; do
            if command_exists "$cmd"; then
                local version=$($cmd --version 2>&1 | head -n1)
                print_info "$cmd: $version"
            fi
        done
        return 0
    fi
}
```

### Key Insight
The system package manager approach works because:
- RHEL maintains Node.js packages for all supported architectures
- IBM Power is a first-class RHEL architecture
- System packages are tested and validated for the platform
- No need for third-party repositories

### Deployment Script Pattern
When writing deployment scripts for ppc64le:

```bash
# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✓ Node.js installed: $NODE_VERSION"
else
    echo "Installing Node.js via dnf (ppc64le compatible)..."
    sudo dnf install -y nodejs npm
    
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        echo "✓ Node.js installed: $NODE_VERSION"
    else
        echo "✗ Node.js installation failed"
        echo "Note: For UI deployment, Node.js is required"
    fi
fi
```

### Carbon Design System Deployment Pattern
When deploying Carbon UI demos on ppc64le, follow this complete workflow:

**Phase 1: Install Node.js (System Package Manager)**
```bash
sudo dnf install -y nodejs npm
```

**Phase 2: Install Yarn Globally**
```bash
sudo npm install --global yarn
```

**Phase 3: Install Carbon Dependencies**
```bash
cd your-carbon-app
yarn install                              # Base dependencies from package.json
yarn add @carbon/react@1.33.0            # Carbon Design System
yarn add @carbon/icons-react@latest      # Carbon Icons
yarn add @carbon/pictograms-react@latest # Carbon Pictograms
yarn add sass@1.63.6                     # Sass compiler (required for Carbon)
yarn add typescript                       # TypeScript support
```

**Phase 4: Install Additional Packages**
```bash
# Frontend packages
yarn add socket.io-client                # Real-time updates
yarn add next@13.4.9                     # Next.js framework
yarn add react@18.2.0                    # React
yarn add react-dom@18.2.0                # React DOM

# Backend packages (if needed)
npm install express cors socket.io dotenv
```

**Phase 5: Build Application**
```bash
yarn build  # Production build
```

### IBM Wheels Repository for Python Packages
When Python packages are needed on ppc64le (e.g., for AI/ML features), use IBM's wheels repository:

```bash
# Upgrade pip first
pip install --upgrade pip

# Install packages with IBM wheels repository
pip install --prefer-binary torch openblas \
  --extra-index-url=https://wheels.developerfirst.ibm.com/ppc64le/linux
```

**Why this matters:**
- Many Python packages don't provide pre-built wheels for ppc64le
- IBM maintains a wheels repository specifically for Power architecture
- Using `--prefer-binary` avoids lengthy compilation from source
- Critical for packages like PyTorch, NumPy, SciPy on Power systems
- Dramatically reduces installation time (minutes vs hours)

**Common packages available from IBM wheels:**
- `torch` - PyTorch deep learning framework
- `openblas` - Optimized BLAS library
- `numpy` - Numerical computing
- `scipy` - Scientific computing
- `pandas` - Data analysis

### Version Considerations
- System package manager may provide older Node.js versions
- For Carbon Design System demos, Node.js 16+ is typically sufficient
- Carbon React 1.33.0 is tested and stable on ppc64le
- Sass 1.63.6 is the recommended version for Carbon compatibility
- If newer versions are required, consider:
  - Building from source (time-consuming)
  - Using IBM's Node.js builds if available
  - Accepting the system version for demo purposes

### Demo Credibility Test
This approach is valid if:
- Node.js runs successfully on ppc64le
- Carbon components render correctly
- The demo UI functions as expected
- The customer sees a working demonstration

The Node.js version number is rarely a customer concern in pre-sales demos.

### Recommended Narrative
Say:
- "We're using the RHEL-provided Node.js package for IBM Power compatibility"
- "This ensures the demo runs natively on the Power architecture"
- "The Carbon UI is fully functional on this platform"

Do not say:
- "We had to use an old version of Node.js"
- "NodeSource doesn't support Power"

### Related Skills
This skill complements:
- **Pivot to Power-Native Containers** - When native binaries aren't available
- **Diagnose fapolicyd Blocking** - When runtime execution is blocked

### Risks
- System package version may be older than latest Node.js LTS
- Some npm packages may have native dependencies requiring compilation
- Build times may be longer on Power systems

### Mitigations
- Test the demo early to identify any version-specific issues
- Use `--prefer-binary` flag with pip/npm when available
- Consider pre-building dependencies if build times are excessive
- Document any version-specific workarounds

### How to Reuse This Skill Later
When building any Node.js-based demo on IBM Power, recall:

**"Use system package manager (dnf/yum) for Node.js on ppc64le - NodeSource and similar third-party repos don't support this architecture."**

### Current Example Reference
- Customer: Howdens
- Demo: PowerSC + HashiCorp Vault with Carbon UI
- Environment: TechZone PowerSC reservation (p1229-pvm2, RHEL on Power)
- Issue: NodeSource installation failed with "Unsupported architecture: ppc64le"
- Solution: Changed from NodeSource to `sudo dnf install -y nodejs npm`
- Result: Node.js installed successfully, Carbon UI deployment proceeded

### Additional Resources
- Working example: `C:\Users\029878866\EMEA-AI-SQUAD\Carbon-GenAI-Demos\deployment\deploy-carbon-genai.sh`
- Fixed script: `deploy-demo.sh` (PowerSC Vault demo)