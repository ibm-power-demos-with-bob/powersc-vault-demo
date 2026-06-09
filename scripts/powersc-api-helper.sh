#!/bin/bash
################################################################################
# PowerSC REST API Helper Script
# 
# Purpose: Interact with PowerSC Quantum Safety REST API
#          - Trigger scans
#          - Retrieve reports
#          - Check scan status
#
# Usage: ./powersc-api-helper.sh [command] [options]
#
# Commands:
#   trigger-scan <hostname>  - Trigger a Quantum Safety scan
#   get-report <hostname>    - Get the latest scan report
#   check-status <hostname>  - Check scan status
#
# Author: Pre-Sales Demo Builder
# Date: 2026-06-09
################################################################################

# PowerSC Server Configuration
# TODO: Update these with your actual PowerSC server details
POWERSC_SERVER="${POWERSC_SERVER:-powersc.example.com}"
POWERSC_PORT="${POWERSC_PORT:-8443}"
POWERSC_USER="${POWERSC_USER:-admin}"
POWERSC_PASS="${POWERSC_PASS:-password}"

# Base URL for PowerSC REST API
BASE_URL="https://${POWERSC_SERVER}:${POWERSC_PORT}/api/v1"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to make authenticated API calls
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -n "$data" ]; then
        curl -s -k -X "$method" \
            -u "${POWERSC_USER}:${POWERSC_PASS}" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "${BASE_URL}${endpoint}"
    else
        curl -s -k -X "$method" \
            -u "${POWERSC_USER}:${POWERSC_PASS}" \
            -H "Content-Type: application/json" \
            "${BASE_URL}${endpoint}"
    fi
}

# Function to trigger a Quantum Safety scan
trigger_scan() {
    local hostname=$1
    
    if [ -z "$hostname" ]; then
        echo -e "${RED}Error: Hostname required${NC}"
        echo "Usage: $0 trigger-scan <hostname>"
        exit 1
    fi
    
    echo -e "${YELLOW}Triggering Quantum Safety scan for: ${hostname}${NC}"
    
    # Trigger scan via REST API
    response=$(api_call "POST" "/quantumsafe/scan" "{\"hostname\": \"${hostname}\"}")
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Scan triggered successfully${NC}"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
    else
        echo -e "${RED}✗ Failed to trigger scan${NC}"
        echo "$response"
        exit 1
    fi
}

# Function to get the latest scan report
get_report() {
    local hostname=$1
    
    if [ -z "$hostname" ]; then
        echo -e "${RED}Error: Hostname required${NC}"
        echo "Usage: $0 get-report <hostname>"
        exit 1
    fi
    
    echo -e "${YELLOW}Retrieving Quantum Safety report for: ${hostname}${NC}"
    
    # Get report via REST API
    response=$(api_call "GET" "/quantumsafe/report?hostname=${hostname}")
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Report retrieved successfully${NC}"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
    else
        echo -e "${RED}✗ Failed to retrieve report${NC}"
        echo "$response"
        exit 1
    fi
}

# Function to check scan status
check_status() {
    local hostname=$1
    
    if [ -z "$hostname" ]; then
        echo -e "${RED}Error: Hostname required${NC}"
        echo "Usage: $0 check-status <hostname>"
        exit 1
    fi
    
    echo -e "${YELLOW}Checking scan status for: ${hostname}${NC}"
    
    # Check status via REST API
    response=$(api_call "GET" "/quantumsafe/status?hostname=${hostname}")
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Status retrieved successfully${NC}"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
    else
        echo -e "${RED}✗ Failed to check status${NC}"
        echo "$response"
        exit 1
    fi
}

# Function to configure auto-scan schedule
configure_schedule() {
    local hostname=$1
    local schedule=$2
    
    if [ -z "$hostname" ] || [ -z "$schedule" ]; then
        echo -e "${RED}Error: Hostname and schedule required${NC}"
        echo "Usage: $0 configure-schedule <hostname> <schedule>"
        echo "Example: $0 configure-schedule p1229-pvm3 daily"
        exit 1
    fi
    
    echo -e "${YELLOW}Configuring scan schedule for: ${hostname}${NC}"
    
    # Configure schedule via REST API
    response=$(api_call "PUT" "/quantumsafeScheduleConfig" "{\"hostname\": \"${hostname}\", \"schedule\": \"${schedule}\"}")
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Schedule configured successfully${NC}"
        echo "$response" | jq '.' 2>/dev/null || echo "$response"
    else
        echo -e "${RED}✗ Failed to configure schedule${NC}"
        echo "$response"
        exit 1
    fi
}

# Main script logic
case "$1" in
    trigger-scan)
        trigger_scan "$2"
        ;;
    get-report)
        get_report "$2"
        ;;
    check-status)
        check_status "$2"
        ;;
    configure-schedule)
        configure_schedule "$2" "$3"
        ;;
    *)
        echo -e "${BLUE}PowerSC REST API Helper${NC}"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  trigger-scan <hostname>           - Trigger a Quantum Safety scan"
        echo "  get-report <hostname>             - Get the latest scan report"
        echo "  check-status <hostname>           - Check scan status"
        echo "  configure-schedule <host> <sched> - Configure auto-scan schedule"
        echo ""
        echo "Examples:"
        echo "  $0 trigger-scan p1229-pvm3"
        echo "  $0 get-report p1229-pvm3"
        echo "  $0 check-status p1229-pvm3"
        echo "  $0 configure-schedule p1229-pvm3 daily"
        echo ""
        echo "Environment Variables:"
        echo "  POWERSC_SERVER - PowerSC server hostname (default: powersc.example.com)"
        echo "  POWERSC_PORT   - PowerSC API port (default: 8443)"
        echo "  POWERSC_USER   - PowerSC username (default: admin)"
        echo "  POWERSC_PASS   - PowerSC password (default: password)"
        echo ""
        exit 1
        ;;
esac

# Made with Bob