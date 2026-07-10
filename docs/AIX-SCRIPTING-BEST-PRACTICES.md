# AIX Scripting Best Practices for Pre-Sales Demos

## Overview
This document captures lessons learned from building the PowerSC + Vault demo on AIX, providing best practices for creating portable, reliable scripts for IBM Power demonstrations.

## Core Principles

### 1. Avoid Specialized CLIs - Use REST APIs with curl

**Problem:** Specialized CLIs (like Vault CLI, kubectl, etc.) may not be installed on demo environments, especially AIX systems.

**Solution:** Use `curl` to call REST APIs directly instead of relying on specialized command-line tools.

**Example - Vault Certificate Issuance:**

❌ **Don't do this (requires Vault CLI):**
```bash
vault write -format=json pki/issue/sap-oracle \
    common_name="server.example.com" \
    ttl=24h
```

✅ **Do this (uses curl + REST API):**
```bash
curl -s -X POST \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"common_name":"server.example.com","ttl":"24h"}' \
    "$VAULT_ADDR/v1/pki/issue/sap-oracle"
```

**Benefits:**
- Works on any system with curl (universally available)
- No installation or setup required
- Easier to debug (can test API calls directly)
- More portable across different environments
- Better for automation and CI/CD

### 2. Avoid jq - Use Standard Shell Tools for JSON Parsing

**Problem:** `jq` is not always available on AIX systems, and installing it requires package management (yum/dnf) which may not be configured.

**Solution:** Use standard shell tools (grep, sed, awk) for JSON parsing.

**Example - Extracting Certificate from JSON:**

❌ **Don't do this (requires jq):**
```bash
echo "$json_output" | jq -r .data.certificate > cert.pem
echo "$json_output" | jq -r .data.private_key > key.pem
```

✅ **Do this (uses grep/sed):**
```bash
# Extract certificate
cert_data=$(echo "$json_output" | grep -o '"certificate":"[^"]*"' | \
    sed 's/"certificate":"//' | sed 's/"$//' | sed 's/\\n/\n/g')
echo "$cert_data" > cert.pem

# Extract private key
key_data=$(echo "$json_output" | grep -o '"private_key":"[^"]*"' | \
    sed 's/"private_key":"//' | sed 's/"$//' | sed 's/\\n/\n/g')
echo "$key_data" > key.pem
```

**Benefits:**
- Works on any Unix/Linux system
- No additional packages required
- Faster execution (no external process)
- More predictable behavior

### 3. Avoid GNU-Specific Commands - Use POSIX-Compatible Alternatives

**Problem:** AIX uses different implementations of common commands that may not support GNU extensions.

**Example - File Splitting:**

❌ **Don't do this (GNU csplit syntax):**
```bash
csplit -f cert- ca-bundle.pem '/-----BEGIN CERTIFICATE-----/' '{*}'
```

✅ **Do this (POSIX awk):**
```bash
awk '
BEGIN { cert_num = 0; in_cert = 0 }
/-----BEGIN CERTIFICATE-----/ {
    in_cert = 1
    cert_num++
    filename = sprintf("cert-%03d.pem", cert_num)
}
in_cert {
    print > filename
}
/-----END CERTIFICATE-----/ {
    in_cert = 0
}' ca-bundle.pem
```

### 4. Graceful Error Handling - Don't Use `set -e`

**Problem:** `set -e` causes scripts to exit on the first error, which is problematic for batch operations where you want to continue processing even if individual items fail.

**Solution:** Use explicit error checking with informative messages and graceful degradation.

❌ **Don't do this:**
```bash
#!/bin/bash
set -e  # Exit on any error

for cert in *.pem; do
    process_cert "$cert"  # Script exits if this fails
done
```

✅ **Do this:**
```bash
#!/bin/bash
# Note: Not using 'set -e' to allow graceful error handling

success_count=0
failure_count=0

for cert in *.pem; do
    if process_cert "$cert"; then
        echo "✓ Processed: $cert"
        ((success_count++))
    else
        echo "✗ Failed: $cert"
        ((failure_count++))
        # Continue processing remaining certificates
    fi
done

echo "Results: $success_count succeeded, $failure_count failed"
```

**Benefits:**
- Script continues even if individual operations fail
- Clear reporting of successes and failures
- Better for batch operations
- Easier to debug

### 5. Use `|| true` for Non-Critical Operations

**Problem:** Even without `set -e`, some operations might cause script failures if they're part of a pipeline or conditional.

**Solution:** Append `|| true` to non-critical operations to ensure they never cause script failure.

**Example:**
```bash
# Create directory (don't fail if it already exists)
mkdir -p /opt/certs 2>/dev/null || true

# Set permissions (don't fail if file doesn't exist)
chmod 644 cert.pem 2>/dev/null || true

# Remove file (don't fail if it doesn't exist)
rm -f old-cert.pem 2>/dev/null || true

# Touch placeholder (don't fail if directory doesn't exist)
touch "$cert_path" 2>/dev/null || true
```

### 6. Capture Exit Codes Before Using Them

**Problem:** The special variable `$?` only contains the exit code of the most recent command, so it can be overwritten before you check it.

**Solution:** Capture exit codes in variables immediately after the command.

❌ **Don't do this:**
```bash
curl -s "$URL" > output.json
if [ $? -ne 0 ]; then  # $? might be from the redirect, not curl
    echo "Failed"
fi
```

✅ **Do this:**
```bash
curl -s "$URL" > output.json
curl_exit_code=$?

if [ $curl_exit_code -ne 0 ]; then
    echo "Failed with exit code: $curl_exit_code"
fi
```

### 7. Suppress stderr for Expected Errors

**Problem:** Error messages from expected failures clutter the output and confuse users.

**Solution:** Redirect stderr to /dev/null for operations where failures are expected and handled.

**Example:**
```bash
# Check if command exists (don't show "command not found" error)
if ! command -v jq &> /dev/null; then
    echo "jq not found, using alternative method"
fi

# Try to parse JSON (don't show jq errors if it fails)
result=$(echo "$json" | jq -r .data.value 2>/dev/null)
if [ -z "$result" ]; then
    # Fall back to grep/sed
    result=$(echo "$json" | grep -o '"value":"[^"]*"' | sed 's/.*"value":"//' | sed 's/"$//')
fi
```

## AIX-Specific Considerations

### File Paths
- AIX uses `/opt/freeware` for open-source software
- System CA bundle: `/opt/freeware/etc/ssl/certs/extracted/pem/tls-ca-bundle.pem`
- Use `/tmp` for temporary files (always available)

### Package Management
- AIX may have `yum` configured, but don't rely on it
- Prefer scripts that work with standard tools only
- If packages are needed, document them clearly in prerequisites

### Terminal Behavior
- AIX terminals may have issues with copy/paste
- Use `cat > script.sh << 'EOF'` for multi-line scripts
- Test scripts with both direct execution and copy/paste

### Performance
- AIX systems may be slower than Linux
- Add progress indicators for long-running operations
- Consider batch operations to reduce overhead

## Testing Checklist

Before deploying scripts to AIX:

- [ ] Test without `set -e` to ensure graceful error handling
- [ ] Verify no jq dependency (use grep/sed/awk instead)
- [ ] Check for GNU-specific command syntax (use POSIX alternatives)
- [ ] Test with curl instead of specialized CLIs
- [ ] Verify all file paths are AIX-compatible
- [ ] Add progress indicators for long operations
- [ ] Test error scenarios (network failures, permission issues)
- [ ] Verify script continues after individual failures
- [ ] Check that exit codes are captured before use
- [ ] Ensure non-critical operations use `|| true`

## Real-World Example: Certificate Replacement Script

This example demonstrates all the principles above:

```bash
#!/bin/bash
# Note: Not using 'set -e' for graceful error handling

# Check for curl (not specialized CLI)
if ! command -v curl &> /dev/null; then
    echo "ERROR: curl not found"
    exit 1
fi

# Function with proper error handling
replace_cert() {
    local cert_path=$1
    local common_name=$2
    
    # Use curl instead of Vault CLI
    local response=$(curl -s -X POST \
        -H "X-Vault-Token: $VAULT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"common_name\":\"$common_name\",\"ttl\":\"24h\"}" \
        "$VAULT_ADDR/v1/pki/issue/sap-oracle" 2>/dev/null)
    
    local curl_exit_code=$?
    
    # Check curl exit code
    if [ $curl_exit_code -ne 0 ]; then
        echo "✗ Failed: $common_name (curl error: $curl_exit_code)"
        touch "$cert_path" 2>/dev/null || true  # Create placeholder
        return 1
    fi
    
    # Parse JSON with grep/sed (not jq)
    local cert_data=$(echo "$response" | grep -o '"certificate":"[^"]*"' | \
        sed 's/"certificate":"//' | sed 's/"$//' | sed 's/\\n/\n/g')
    
    if [ -z "$cert_data" ]; then
        echo "✗ Failed: $common_name (no certificate in response)"
        touch "$cert_path" 2>/dev/null || true
        return 1
    fi
    
    # Write certificate
    echo "$cert_data" > "$cert_path"
    chmod 644 "$cert_path" 2>/dev/null || true
    
    echo "✓ Replaced: $common_name"
    return 0
}

# Process certificates with graceful error handling
success=0
failed=0

for cert in /opt/certs/*.pem; do
    if replace_cert "$cert" "$(basename $cert .pem).example.com"; then
        ((success++))
    else
        ((failed++))
    fi
done

echo "Results: $success succeeded, $failed failed"
```

## Summary

**Key Takeaways:**
1. Use curl + REST APIs instead of specialized CLIs
2. Use grep/sed/awk instead of jq for JSON parsing
3. Use POSIX-compatible commands, not GNU extensions
4. Don't use `set -e` - handle errors explicitly
5. Use `|| true` for non-critical operations
6. Capture exit codes immediately
7. Suppress stderr for expected errors
8. Test on actual AIX systems before deployment

These practices ensure your demo scripts are portable, reliable, and work consistently across different IBM Power environments.

---

**Made with Bob - Pre-Sales Demo Builder**