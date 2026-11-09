#!/bin/bash
################################################################################
# lib-env.sh — load per-deployment values for the helper/diagnostic scripts
#
# Every TechZone deployment gets new hostnames, a new OS user and new PowerSC
# passwords. setup.sh writes them to ui/.env.local; the scripts read them here
# instead of hardcoding anything.
#
# Usage (from another script):
#   source "$(dirname "${BASH_SOURCE[0]}")/lib-env.sh"
#
# Provides: POWERSC_URL POWERSC_USER POWERSC_PASS AIX_HOST AIX_USER
#           POWERSC_HOST (short FQDN of PowerSC server)  API_BASE  SCAN_FOLDER
# Override the file location with ENV_FILE=/path/to/.env.local
################################################################################

ENV_FILE="${ENV_FILE:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/ui/.env.local}"

[[ -f "$ENV_FILE" ]] || { echo "lib-env.sh: $ENV_FILE not found — run scripts/setup.sh first" >&2; exit 1; }

# Parse KEY=value literally (do NOT 'source': TechZone passwords contain ( ) * $ etc.)
envget() { grep -E "^$1=" "$ENV_FILE" | head -1 | cut -d= -f2- | tr -d '\r'; }

POWERSC_URL="${POWERSC_URL:-$(envget POWERSC_URL)}"
POWERSC_USER="${POWERSC_USER:-$(envget POWERSC_USER)}"
POWERSC_PASS="${POWERSC_PASS:-$(envget POWERSC_PASS)}"
AIX_HOST="${AIX_HOST:-$(envget AIX_HOST)}"
AIX_USER="${AIX_USER:-$(envget AIX_USER)}"
AIX_USER="${AIX_USER:-$(whoami)}"

POWERSC_HOST="${POWERSC_URL#https://}"; POWERSC_HOST="${POWERSC_HOST#http://}"
API_BASE="${POWERSC_URL}/ws/powerscui"
SCAN_FOLDER="${SCAN_FOLDER:-/home/${AIX_USER}/demo-certs}"

for v in POWERSC_URL POWERSC_USER POWERSC_PASS AIX_HOST; do
  [[ -n "${!v}" ]] || { echo "lib-env.sh: $v is empty in $ENV_FILE" >&2; exit 1; }
done
