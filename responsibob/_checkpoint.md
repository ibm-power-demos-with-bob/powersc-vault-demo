# Responsibob Checkpoint — powersc-vault-demo

## Latest certificate

| Field | Value |
|---|---|
| File | `responsibob/powersc-vault-demo-epc.html` |
| Assessed | July 2026 |
| Combined rating | **C** (current) → **B** (potential) |
| Language axis | **E** (TypeScript 21.5× structural) |
| Algorithm axis | **C** |

## Top 3 improvements

1. **Replace 150 sequential curl calls with server-side Vault issuance** — move the cert replacement loop into the Express backend's `vaultClient` Axios pool. Removes 150 TCP/TLS handshakes, cuts demo wall-clock time from ~7.5 s to <1 s. Changes algo axis from C → B. (`replace-with-vault-certificates.sh:81`)
2. **Skip Next.js rebuild on re-run if source unchanged** — `setup.sh:326` runs `npm run build` unconditionally. Guard with `.next/BUILD_ID` existence check to skip on idempotent re-runs.
3. **Share a single openssl config across all 150 cert generations** — `generate-old-certificates.sh:83-95` writes + deletes a `.cnf` file per cert. Use `-subj` inline to eliminate 150 file writes.

## Good patterns noted
- Pre-built ICR Power-native Vault image (no compile-from-source cost)
- Idempotent guards throughout `setup.sh`
- Streaming SSH output in `ssh.js` (no full-output memory accumulation)
- Axios singleton `vaultClient` with connection pooling
- PassportEye principle correctly applied — Vault PKI, not an LLM
