---
name: ibm-power-aix-scripting
description: >
  AIX-compatible scripting rules for IBM Power demos. Covers why jq, grep -o, specialized
  CLIs (Vault, kubectl), set -e, and GNU-specific syntax all fail on AIX and what to use
  instead. Includes complete working patterns for curl REST API calls, JSON parsing with
  sed/awk, and graceful error handling.
---

# Skill: AIX-Compatible Scripting for IBM Power Demos

## When to Use This Skill

Apply this skill when writing or reviewing any shell script that will run on an AIX host
in an IBM Power TechZone environment. The rules are non-negotiable — scripts that violate
them will fail silently or with confusing errors.

## The Rules

| Forbidden | Why | Use instead |
|-----------|-----|-------------|
| `jq` | Not installed on AIX | `sed` / `awk` for JSON parsing |
| `grep -o` | AIX grep does not support `-o` (only-matching) | `sed -n 's/.../\1/p'` |
| Vault CLI (`vault write`, `vault read`) | Vault is not installed on AIX | `curl` + Vault REST API |
| `kubectl`, `helm`, etc. | Not installed on AIX | REST APIs |
| `set -e` | Causes script to exit on first failure; in a loop over 150 certificates, one failure kills all | Explicit error handling per operation |
| GNU `csplit {*}` | AIX `csplit` does not support `{*}` syntax | `awk` with state machine |
| `date -d @timestamp` | GNU date syntax; AIX date is different | `date -r timestamp` or omit |

## Pattern 1: REST API calls instead of specialized CLIs

```bash
# ✅ CORRECT — works on any system with curl
VAULT_RESPONSE=$(curl -s -X POST \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"common_name\":\"$COMMON_NAME\",\"ttl\":\"24h\"}" \
    "$VAULT_ADDR/v1/pki/issue/sap-oracle")

CURL_EXIT=$?
if [ $CURL_EXIT -ne 0 ]; then
    echo "curl failed with exit code $CURL_EXIT"
    return 1
fi
```

Always capture `$?` immediately after `curl`. Do not use `set -e` to catch failures.

## Pattern 2: JSON parsing with sed instead of jq or grep -o

```bash
# ❌ WRONG — grep -o not supported on AIX
CERT=$(echo "$JSON" | grep -o '"certificate":"[^"]*"')

# ✅ CORRECT — sed with capture group
CERT=$(echo "$JSON" | sed -n 's/.*"certificate":"\([^"]*\)".*/\1/p' | sed 's/\\n/\n/g')

# Extract private key
KEY=$(echo "$JSON" | sed -n 's/.*"private_key":"\([^"]*\)".*/\1/p' | sed 's/\\n/\n/g')

# Check for errors (grep -q is safe; grep -o is not)
if echo "$JSON" | grep -q '"errors"'; then
    ERR=$(echo "$JSON" | sed -n 's/.*"errors":\["\([^"]*\)".*/\1/p')
    echo "Vault error: $ERR"
fi
```

The `sed 's/\\n/\n/g'` step converts the JSON-encoded `\n` sequences into real newlines
in the certificate PEM output.

## Pattern 3: Split certificate bundle with awk instead of csplit

```bash
# ❌ WRONG — AIX csplit does not support {*}
csplit -f cert- ca-bundle.pem '/-----BEGIN CERTIFICATE-----/' '{*}'

# ✅ CORRECT — awk state machine (POSIX-compatible)
awk '
BEGIN { cert_num = 0; in_cert = 0 }
/-----BEGIN CERTIFICATE-----/ {
    in_cert = 1
    cert_num++
    filename = sprintf("/tmp/cert-%03d.pem", cert_num)
}
in_cert {
    print > filename
}
/-----END CERTIFICATE-----/ {
    in_cert = 0
    close(filename)
}' ca-bundle.pem
```

## Pattern 4: Graceful error handling without set -e

```bash
# ✅ CORRECT — explicit per-operation error handling
SUCCESS=0
FAILED=0

for CERT_PATH in /opt/sap/app01/certs/*.pem; do
    if process_cert "$CERT_PATH"; then
        SUCCESS=$((SUCCESS + 1))
    else
        FAILED=$((FAILED + 1))
        # Continue — do not abort the entire loop
    fi
done

echo "Results: $SUCCESS succeeded, $FAILED failed"
```

## Pattern 5: Non-critical operations with || true

```bash
mkdir -p /opt/certs 2>/dev/null || true
chmod 644 cert.pem 2>/dev/null || true
touch "$PLACEHOLDER" 2>/dev/null || true
```

## Complete Working Example: AIX Certificate Replacement Function

```bash
replace_with_vault_cert() {
    local cert_path=$1
    local key_path=$2
    local common_name=$3

    # Call Vault REST API (no Vault CLI required)
    local vault_output
    vault_output=$(curl -s -X POST \
        -H "X-Vault-Token: $VAULT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"common_name\":\"$common_name\",\"ttl\":\"24h\"}" \
        "$VAULT_ADDR/v1/pki/issue/sap-oracle" 2>/dev/null)
    local curl_exit=$?

    if [ $curl_exit -ne 0 ]; then
        echo "✗ Failed: $common_name (curl error $curl_exit)"
        touch "$cert_path" "$key_path" 2>/dev/null || true
        return 1
    fi

    # Check for Vault errors (grep -q works on AIX; grep -o does not)
    if echo "$vault_output" | grep -q '"errors"'; then
        local err
        err=$(echo "$vault_output" | sed -n 's/.*"errors":\["\([^"]*\)".*/\1/p')
        echo "✗ Vault error: $common_name — $err"
        touch "$cert_path" "$key_path" 2>/dev/null || true
        return 1
    fi

    # Extract certificate and key using sed (not jq, not grep -o)
    local cert_data
    cert_data=$(echo "$vault_output" | sed -n 's/.*"certificate":"\([^"]*\)".*/\1/p' | sed 's/\\n/\n/g')
    local key_data
    key_data=$(echo "$vault_output" | sed -n 's/.*"private_key":"\([^"]*\)".*/\1/p' | sed 's/\\n/\n/g')

    if [ -z "$cert_data" ] || [ -z "$key_data" ]; then
        echo "✗ Empty response: $common_name"
        touch "$cert_path" "$key_path" 2>/dev/null || true
        return 1
    fi

    echo "$cert_data" > "$cert_path"
    echo "$key_data"  > "$key_path"
    chmod 644 "$cert_path" 2>/dev/null || true
    chmod 600 "$key_path"  2>/dev/null || true

    echo "✓ Replaced: $common_name"
    return 0
}
```

## Diagnostic: Is a Command Available on AIX?

Before writing a script, confirm what is available on the target AIX host:

```bash
# Check for tools commonly assumed but often missing
which jq      2>/dev/null || echo "jq: NOT FOUND"
which vault   2>/dev/null || echo "vault CLI: NOT FOUND"
which kubectl 2>/dev/null || echo "kubectl: NOT FOUND"
which curl    2>/dev/null && echo "curl: available"
which openssl 2>/dev/null && echo "openssl: available"
which awk     2>/dev/null && echo "awk: available"
which sed     2>/dev/null && echo "sed: available"
```

On TechZone AIX instances: `curl`, `openssl`, `awk`, `sed` are available. `jq`, `vault`,
`kubectl` are not.

## Testing Checklist Before Running on AIX

- [ ] No `jq` dependency (use grep/sed/awk)
- [ ] No specialized CLIs (use curl + REST APIs)
- [ ] No `grep -o` (use `sed -n 's/.../\1/p'`)
- [ ] No GNU-specific syntax (use POSIX)
- [ ] No `set -e` at the top (use explicit error handling)
- [ ] `$?` captured immediately after curl calls
- [ ] Non-critical operations use `|| true`
- [ ] `stderr` suppressed for expected non-fatal errors (`2>/dev/null`)
- [ ] Script continues after individual failures (loop continues, logs failure)

## Narrative for Client Audience

Say:
- "We're using standard REST APIs for maximum portability across the estate"
- "The automation works on any Unix system without additional dependencies"

Do not say:
- "We had to work around missing tools"
- "AIX doesn't support modern tooling"
