# Script Updates - June 9, 2026

## Summary
Updated `replace-with-vault-certificates.sh` to match AIX compatibility fixes from `generate-old-certificates.sh` and replaced Vault CLI with curl for better portability.

## Changes Made

### 0. Replaced Vault CLI with curl (Critical for AIX)
**Reason:** Vault CLI is not installed on the AIX client, and installing it would add unnecessary complexity. Using curl to call Vault's REST API is more portable and universally available.

**Before:**
```bash
# Check if vault CLI is available
if ! command -v vault &> /dev/null; then
    echo -e "${RED}ERROR: Vault CLI not found${NC}"
    exit 1
fi

# Issue certificate
local vault_output=$(vault write -format=json pki/issue/sap-oracle \
    common_name="$common_name" \
    ttl=24h 2>/dev/null)
```

**After:**
```bash
# Check if curl is available (more universal than vault CLI)
if ! command -v curl &> /dev/null; then
    echo -e "${RED}ERROR: curl not found${NC}"
    exit 1
fi

# Issue certificate using Vault REST API
local vault_output=$(curl -s -X POST \
    -H "X-Vault-Token: $VAULT_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"common_name\":\"$common_name\",\"ttl\":\"24h\"}" \
    "$VAULT_ADDR/v1/pki/issue/sap-oracle" 2>/dev/null)
```

**Benefits:**
- No need to install Vault CLI on AIX
- Uses standard HTTP REST API
- More portable across different systems
- Easier to debug (can test with curl directly)

### 1. Removed `set -e` (Line 23)
**Before:**
```bash
set -e  # Exit on error
```

**After:**
```bash
# Note: Not using 'set -e' to allow graceful error handling
# This ensures the script continues even if individual certificate issuance fails
```

**Reason:** AIX compatibility. The `set -e` flag causes the script to exit on the first error, which is problematic when:
- Some Vault certificate issuances might fail
- We want to continue processing remaining certificates
- We need graceful degradation rather than complete failure

### 2. Enhanced Error Handling in `replace_with_vault_cert()` Function

**Before:**
```bash
if [ $? -ne 0 ]; then
    echo -e "${RED}  ✗ Failed to issue certificate for $common_name${NC}"
    return 1
fi
```

**After:**
```bash
local vault_exit_code=$?

if [ $vault_exit_code -ne 0 ]; then
    echo -e "${RED}  ✗ Failed to issue certificate for $common_name (exit code: $vault_exit_code)${NC}"
    # Create empty files so the script can continue
    touch "$cert_path" "$key_path" 2>/dev/null || true
    return 1
fi
```

**Improvements:**
- Captures exit code in a variable for better debugging
- Creates placeholder files on failure to prevent downstream errors
- Uses `|| true` to prevent touch failures from stopping the script

### 3. Added Error Handling for JSON Parsing

**Before:**
```bash
echo "$vault_output" | jq -r .data.certificate > "$cert_path"
echo "$vault_output" | jq -r .data.private_key > "$key_path"
```

**After:**
```bash
if ! echo "$vault_output" | jq -r .data.certificate > "$cert_path" 2>/dev/null; then
    echo -e "${RED}  ✗ Failed to extract certificate for $common_name${NC}"
    touch "$cert_path" "$key_path" 2>/dev/null || true
    return 1
fi

if ! echo "$vault_output" | jq -r .data.private_key > "$key_path" 2>/dev/null; then
    echo -e "${RED}  ✗ Failed to extract private key for $common_name${NC}"
    touch "$key_path" 2>/dev/null || true
    return 1
fi
```

**Improvements:**
- Checks if jq parsing succeeds before continuing
- Provides specific error messages for certificate vs key extraction failures
- Creates placeholder files on failure
- Suppresses stderr to avoid cluttering output

### 4. Added Error Suppression for chmod

**Before:**
```bash
chmod 644 "$cert_path"
chmod 600 "$key_path"
```

**After:**
```bash
chmod 644 "$cert_path" 2>/dev/null || true
chmod 600 "$key_path" 2>/dev/null || true
```

**Reason:** Prevents chmod failures from stopping the script, especially useful if files don't exist or permissions can't be changed.

## Testing Recommendations

1. **Transfer updated script to AIX:**
   ```bash
   scp powersc-vault-demo/scripts/replace-with-vault-certificates.sh cecuser@<AIX_HOST>:/home/cecuser/
   ```

2. **SSH to AIX and set environment:**
   ```bash
   ssh cecuser@<AIX_HOST>
   export VAULT_ADDR="http://<VAULT_HOST>:8200"
   export VAULT_TOKEN="hvs.your-token-here"
   ```

3. **Run the script:**
   ```bash
   chmod +x replace-with-vault-certificates.sh
   sudo ./replace-with-vault-certificates.sh
   ```

4. **Expected behavior:**
   - Script continues even if some certificates fail to issue
   - Clear error messages for any failures
   - Total count of successfully replaced certificates at the end
   - No script crashes or early exits

## Alignment with generate-old-certificates.sh

Both scripts now follow the same error handling philosophy:
- ✅ No `set -e` - graceful degradation
- ✅ Explicit error checking with informative messages
- ✅ Continue processing on individual failures
- ✅ Create placeholder files to prevent downstream errors
- ✅ Suppress non-critical errors with `|| true`
- ✅ AIX-compatible command syntax

## Next Steps

1. Test the updated script on AIX
2. Verify all 150 certificates are replaced successfully
3. Trigger PowerSC rescan to capture "AFTER" state
4. Compare BEFORE vs AFTER results to demonstrate Vault's impact

---

**Made with Bob - Pre-Sales Demo Builder**
