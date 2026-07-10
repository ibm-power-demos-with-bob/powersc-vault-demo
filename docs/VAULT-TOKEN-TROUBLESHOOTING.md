# Vault Token Troubleshooting

## Issue: "permission denied" When Issuing Certificates

### Symptoms
```
✗ Vault error for sap-app01.howdens.local: permission denied
```

### Root Cause
The Vault token being used doesn't have permission to issue certificates from the PKI engine.

### Solution Steps

#### 1. Verify Vault Token on RHEL

SSH to the RHEL Vault server:
```bash
ssh cecuser@<VAULT_HOST>
# Password: 8-P5VO+NT3UR5!g
```

Check if Vault is initialized and unsealed:
```bash
export VAULT_ADDR="http://127.0.0.1:8200"
export VAULT_TOKEN="myroot"
vault status
```

#### 2. Check PKI Engine Status

Verify the PKI engine is enabled:
```bash
vault secrets list
```

Should show:
```
Path          Type         Description
----          ----         -----------
pki/          pki          n/a
```

#### 3. Check PKI Role Configuration

Verify the "sap-oracle" role exists:
```bash
vault read pki/roles/sap-oracle
```

Should show role configuration with:
- `allowed_domains: ["howdens.local"]`
- `allow_subdomains: true`
- `max_ttl: 24h`

#### 4. Re-run PKI Setup if Needed

If the PKI engine or role is missing, re-run the setup:
```bash
cd /home/cecuser
./vault-pki-setup.sh
```

This will:
- Enable PKI engine at `pki/`
- Generate root CA
- Create "sap-oracle" role
- Configure 24-hour TTL

#### 5. Get a Valid Token

If "myroot" doesn't work, create a new token with PKI permissions:

```bash
# Login with root token
vault login
# Enter root token when prompted

# Create a policy for PKI
cat > pki-policy.hcl <<EOF
path "pki/issue/sap-oracle" {
  capabilities = ["create", "update"]
}
EOF

vault policy write pki-issuer pki-policy.hcl

# Create a token with this policy
vault token create -policy=pki-issuer -ttl=24h
```

Use the generated token in place of "myroot".

#### 6. Test Certificate Issuance

Test issuing a certificate directly:
```bash
curl -s -X POST \
  -H "X-Vault-Token: myroot" \
  -H "Content-Type: application/json" \
  -d '{"common_name":"test.howdens.local","ttl":"24h"}' \
  http://<VAULT_HOST>:8200/v1/pki/issue/sap-oracle
```

Should return JSON with certificate data, not errors.

#### 7. Update AIX Script

If you created a new token, update the environment variable on AIX:
```bash
ssh cecuser@<AIX_HOST>
export VAULT_ADDR="http://<VAULT_HOST>:8200"
export VAULT_TOKEN="your-new-token-here"
sudo -E ./replace-with-vault-certificates.sh
```

## Quick Diagnostic Commands

### On RHEL Vault Server:
```bash
# Check Vault status
vault status

# List secrets engines
vault secrets list

# Check PKI role
vault read pki/roles/sap-oracle

# Test certificate issuance
vault write pki/issue/sap-oracle common_name="test.howdens.local" ttl=24h
```

### From AIX Client:
```bash
# Test Vault connectivity
curl -s http://<VAULT_HOST>:8200/v1/sys/health

# Test certificate issuance via API
curl -s -X POST \
  -H "X-Vault-Token: $VAULT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"common_name":"test.howdens.local","ttl":"24h"}' \
  http://<VAULT_HOST>:8200/v1/pki/issue/sap-oracle
```

## Common Issues

### Issue: "Vault is sealed"
**Solution:** Unseal Vault on RHEL:
```bash
vault operator unseal
# Enter unseal key when prompted
```

### Issue: "PKI engine not found"
**Solution:** Re-run `vault-pki-setup.sh` on RHEL

### Issue: "Role not found"
**Solution:** Re-create the role:
```bash
vault write pki/roles/sap-oracle \
    allowed_domains=howdens.local \
    allow_subdomains=true \
    max_ttl=24h \
    ttl=24h
```

### Issue: "Invalid token"
**Solution:** Get a new root token or create a token with PKI permissions (see step 5 above)

## Expected Successful Output

When everything is working, the script should show:
```
Testing Vault connectivity...
✓ Vault connection successful

Replacing SAP Application Layer Certificates (60 certs)...
  SAP App Server 1...
  ✓ Replaced: sap-app01.howdens.local
  ✓ Replaced: sap-app01-client.howdens.local
  ✓ Replaced: sap-app01-icm.howdens.local
  ...
```

---

**Made with Bob - Pre-Sales Demo Builder**
