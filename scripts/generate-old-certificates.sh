#!/bin/sh
################################################################################
# PowerSC + Vault Demo: Generate Weak Certificates
#
# Purpose: Generate 150 self-signed certificates with deliberately weak crypto
#          (SHA-1 signature, RSA 1024-bit keys) across SAP/Oracle/Integration
#          paths on the AIX client. PowerSC classifies these as WEAK based on
#          algorithm and key size — not certificate age — giving a clear BEFORE
#          state regardless of issue date.
#
#          NOTE: Backdating is intentionally NOT used. AIX OpenSSL refuses
#          past Not Before dates. The weak algorithm + key size is sufficient
#          for PowerSC to flag these as needing remediation.
#
# Usage: Run on AIX client as root or cecuser with sudo
#        sudo ./generate-old-certificates.sh
#
# Author: EMEA AI on IBM Power Squad
# Date: 2026-07-11
################################################################################

# On AIX, toolbox binaries live in /opt/freeware/bin — add to PATH if present
if [ -d /opt/freeware/bin ]; then
  export PATH="/opt/freeware/bin:$PATH"
fi

# Check openssl is available
if ! command -v openssl >/dev/null 2>&1; then
  echo "ERROR: openssl not found. Install IBM AIX Toolbox OpenSSL."
  exit 1
fi

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

echo "========================================"
echo "PowerSC + Vault Demo Setup"
echo "Generating 150 Weak Old Certificates"
echo "========================================"
echo ""

# Clean up existing demo directories
echo "Cleaning up old certificate directories..."
for dir in /opt/sap /opt/oracle /opt/integration /opt/loadbalancer /opt/proxy; do
  if [ -d "$dir" ]; then
    echo "  Removing $dir"
    rm -rf "$dir"
  fi
done
echo "Cleanup complete."
echo ""

# Temporary working directory
WORK_DIR="/tmp/demo-certs-$$"
mkdir -p "$WORK_DIR"

# Counter
CERT_COUNT=0

# -------------------------------------------------------------------
# generate_weak_cert <cert_path> <key_path> <common_name>
#
# Generates a self-signed certificate with:
#   - RSA 1024-bit key  (weak — below modern 2048-bit standard)
#   - SHA-1 signature   (weak — deprecated, fails quantum safety checks)
#
# PowerSC classifies these as WEAK on both algorithm and key size grounds.
# No backdating — AIX OpenSSL refuses past Not Before dates and it is not
# needed: algorithm + key size alone triggers the WEAK classification.
# -------------------------------------------------------------------
generate_weak_cert() {
  cert_path="$1"
  key_path="$2"
  cn="$3"

  # Create parent directory
  mkdir -p "$(dirname "$cert_path")" 2>/dev/null || true

  # Build a minimal openssl config — avoids interactive prompts on AIX
  cfg="$WORK_DIR/cert-$$.cnf"
  cat > "$cfg" << SSLCFG
[req]
default_bits       = 1024
default_md         = sha1
prompt             = no
distinguished_name = dn
[dn]
CN=$cn
O=Demo Organisation
OU=IT Security
C=GB
SSLCFG

  # Generate RSA 1024 key
  openssl genrsa -out "$key_path" 1024 >/dev/null 2>&1

  # Self-signed cert with SHA-1 — current date, 10 year validity
  openssl req -new -x509 \
    -key "$key_path" \
    -out "$cert_path" \
    -config "$cfg" \
    -sha1 \
    -days 3650 \
    -set_serial "$CERT_COUNT" \
    >/dev/null 2>&1

  rm -f "$cfg"

  # Verify it was created
  if [ -f "$cert_path" ] && [ -s "$cert_path" ]; then
    chmod 644 "$cert_path" 2>/dev/null || true
    chmod 600 "$key_path"  2>/dev/null || true
    CERT_COUNT=$((CERT_COUNT + 1))
    return 0
  else
    echo "  WARNING: Failed to generate $cert_path"
    return 1
  fi
}

echo "Generating SAP Application Layer Certificates (60 certs)..."

# SAP App Server 1 (10 certs)
echo "  SAP App Server 1..."
generate_weak_cert "/opt/sap/app01/certs/server.pem"         "/opt/sap/app01/certs/server-key.pem"         "sap-app01.howdens.local"         
generate_weak_cert "/opt/sap/app01/certs/client.pem"         "/opt/sap/app01/certs/client-key.pem"         "sap-client01.howdens.local"      
generate_weak_cert "/opt/sap/app01/certs/icm.pem"            "/opt/sap/app01/certs/icm-key.pem"            "icm.sap.howdens.local"           
generate_weak_cert "/opt/sap/app01/certs/gateway.pem"        "/opt/sap/app01/certs/gateway-key.pem"        "gateway.sap.howdens.local"       
generate_weak_cert "/opt/sap/app01/certs/rfc.pem"            "/opt/sap/app01/certs/rfc-key.pem"            "rfc.sap.howdens.local"           
generate_weak_cert "/opt/sap/app01/certs/message-server.pem" "/opt/sap/app01/certs/message-server-key.pem" "ms.sap.howdens.local"            
generate_weak_cert "/opt/sap/app01/certs/enqueue.pem"        "/opt/sap/app01/certs/enqueue-key.pem"        "enqueue.sap.howdens.local"       
generate_weak_cert "/opt/sap/app01/certs/web.pem"            "/opt/sap/app01/certs/web-key.pem"            "web.sap.howdens.local"           
generate_weak_cert "/opt/sap/app01/certs/fiori.pem"          "/opt/sap/app01/certs/fiori-key.pem"          "fiori.sap.howdens.local"         
generate_weak_cert "/opt/sap/app01/certs/sso.pem"            "/opt/sap/app01/certs/sso-key.pem"            "sso.sap.howdens.local"           

# SAP App Server 2 (10 certs)
echo "  SAP App Server 2..."
generate_weak_cert "/opt/sap/app02/certs/server.pem"         "/opt/sap/app02/certs/server-key.pem"         "sap-app02.howdens.local"         
generate_weak_cert "/opt/sap/app02/certs/client.pem"         "/opt/sap/app02/certs/client-key.pem"         "sap-client02.howdens.local"      
generate_weak_cert "/opt/sap/app02/certs/icm.pem"            "/opt/sap/app02/certs/icm-key.pem"            "icm2.sap.howdens.local"          
generate_weak_cert "/opt/sap/app02/certs/gateway.pem"        "/opt/sap/app02/certs/gateway-key.pem"        "gateway2.sap.howdens.local"      
generate_weak_cert "/opt/sap/app02/certs/rfc.pem"            "/opt/sap/app02/certs/rfc-key.pem"            "rfc2.sap.howdens.local"          
generate_weak_cert "/opt/sap/app02/certs/message-server.pem" "/opt/sap/app02/certs/message-server-key.pem" "ms2.sap.howdens.local"           
generate_weak_cert "/opt/sap/app02/certs/enqueue.pem"        "/opt/sap/app02/certs/enqueue-key.pem"        "enqueue2.sap.howdens.local"      
generate_weak_cert "/opt/sap/app02/certs/web.pem"            "/opt/sap/app02/certs/web-key.pem"            "web2.sap.howdens.local"          
generate_weak_cert "/opt/sap/app02/certs/fiori.pem"          "/opt/sap/app02/certs/fiori-key.pem"          "fiori2.sap.howdens.local"        
generate_weak_cert "/opt/sap/app02/certs/sso.pem"            "/opt/sap/app02/certs/sso-key.pem"            "sso2.sap.howdens.local"          

# SAP App Server 3 (10 certs)
echo "  SAP App Server 3..."
generate_weak_cert "/opt/sap/app03/certs/server.pem"         "/opt/sap/app03/certs/server-key.pem"         "sap-app03.howdens.local"         
generate_weak_cert "/opt/sap/app03/certs/client.pem"         "/opt/sap/app03/certs/client-key.pem"         "sap-client03.howdens.local"      
generate_weak_cert "/opt/sap/app03/certs/icm.pem"            "/opt/sap/app03/certs/icm-key.pem"            "icm3.sap.howdens.local"          
generate_weak_cert "/opt/sap/app03/certs/gateway.pem"        "/opt/sap/app03/certs/gateway-key.pem"        "gateway3.sap.howdens.local"      
generate_weak_cert "/opt/sap/app03/certs/rfc.pem"            "/opt/sap/app03/certs/rfc-key.pem"            "rfc3.sap.howdens.local"          
generate_weak_cert "/opt/sap/app03/certs/message-server.pem" "/opt/sap/app03/certs/message-server-key.pem" "ms3.sap.howdens.local"           
generate_weak_cert "/opt/sap/app03/certs/enqueue.pem"        "/opt/sap/app03/certs/enqueue-key.pem"        "enqueue3.sap.howdens.local"      
generate_weak_cert "/opt/sap/app03/certs/web.pem"            "/opt/sap/app03/certs/web-key.pem"            "web3.sap.howdens.local"          
generate_weak_cert "/opt/sap/app03/certs/fiori.pem"          "/opt/sap/app03/certs/fiori-key.pem"          "fiori3.sap.howdens.local"        
generate_weak_cert "/opt/sap/app03/certs/sso.pem"            "/opt/sap/app03/certs/sso-key.pem"            "sso3.sap.howdens.local"          

# SAP Dev (8 certs)
echo "  SAP Dev/QA..."
generate_weak_cert "/opt/sap/dev/certs/server.pem"           "/opt/sap/dev/certs/server-key.pem"           "sap-dev.howdens.local"           
generate_weak_cert "/opt/sap/dev/certs/client.pem"           "/opt/sap/dev/certs/client-key.pem"           "sap-dev-client.howdens.local"    
generate_weak_cert "/opt/sap/dev/certs/icm.pem"              "/opt/sap/dev/certs/icm-key.pem"              "icm-dev.sap.howdens.local"       
generate_weak_cert "/opt/sap/dev/certs/gateway.pem"          "/opt/sap/dev/certs/gateway-key.pem"          "gw-dev.sap.howdens.local"        
generate_weak_cert "/opt/sap/dev/certs/rfc.pem"              "/opt/sap/dev/certs/rfc-key.pem"              "rfc-dev.sap.howdens.local"       
generate_weak_cert "/opt/sap/dev/certs/web.pem"              "/opt/sap/dev/certs/web-key.pem"              "web-dev.sap.howdens.local"       
generate_weak_cert "/opt/sap/dev/certs/fiori.pem"            "/opt/sap/dev/certs/fiori-key.pem"            "fiori-dev.sap.howdens.local"     
generate_weak_cert "/opt/sap/dev/certs/sso.pem"              "/opt/sap/dev/certs/sso-key.pem"              "sso-dev.sap.howdens.local"       

# SAP QAS (8 certs)
generate_weak_cert "/opt/sap/qas/certs/server.pem"           "/opt/sap/qas/certs/server-key.pem"           "sap-qas.howdens.local"           
generate_weak_cert "/opt/sap/qas/certs/client.pem"           "/opt/sap/qas/certs/client-key.pem"           "sap-qas-client.howdens.local"    
generate_weak_cert "/opt/sap/qas/certs/icm.pem"              "/opt/sap/qas/certs/icm-key.pem"              "icm-qas.sap.howdens.local"       
generate_weak_cert "/opt/sap/qas/certs/gateway.pem"          "/opt/sap/qas/certs/gateway-key.pem"          "gw-qas.sap.howdens.local"        
generate_weak_cert "/opt/sap/qas/certs/rfc.pem"              "/opt/sap/qas/certs/rfc-key.pem"              "rfc-qas.sap.howdens.local"       
generate_weak_cert "/opt/sap/qas/certs/web.pem"              "/opt/sap/qas/certs/web-key.pem"              "web-qas.sap.howdens.local"       
generate_weak_cert "/opt/sap/qas/certs/fiori.pem"            "/opt/sap/qas/certs/fiori-key.pem"            "fiori-qas.sap.howdens.local"     
generate_weak_cert "/opt/sap/qas/certs/sso.pem"              "/opt/sap/qas/certs/sso-key.pem"              "sso-qas.sap.howdens.local"       

# SAP Web Dispatcher (6 certs)
echo "  SAP Web Dispatcher / Gateway..."
generate_weak_cert "/opt/sap/webdispatcher/certs/server.pem"      "/opt/sap/webdispatcher/certs/server-key.pem"      "webdisp.sap.howdens.local"  
generate_weak_cert "/opt/sap/webdispatcher/certs/backend.pem"     "/opt/sap/webdispatcher/certs/backend-key.pem"     "backend.sap.howdens.local"  
generate_weak_cert "/opt/sap/webdispatcher/certs/ssl.pem"         "/opt/sap/webdispatcher/certs/ssl-key.pem"         "ssl.sap.howdens.local"      
generate_weak_cert "/opt/sap/webdispatcher/certs/client-auth.pem" "/opt/sap/webdispatcher/certs/client-auth-key.pem" "auth.sap.howdens.local"     
generate_weak_cert "/opt/sap/webdispatcher/certs/admin.pem"       "/opt/sap/webdispatcher/certs/admin-key.pem"       "admin.sap.howdens.local"    
generate_weak_cert "/opt/sap/webdispatcher/certs/monitoring.pem"  "/opt/sap/webdispatcher/certs/monitoring-key.pem"  "monitor.sap.howdens.local"  

# SAP Gateway (8 certs)
generate_weak_cert "/opt/sap/gateway/certs/server.pem"  "/opt/sap/gateway/certs/server-key.pem"  "gw.sap.howdens.local"   
generate_weak_cert "/opt/sap/gateway/certs/odata.pem"   "/opt/sap/gateway/certs/odata-key.pem"   "odata.sap.howdens.local"
generate_weak_cert "/opt/sap/gateway/certs/rest.pem"    "/opt/sap/gateway/certs/rest-key.pem"    "rest.sap.howdens.local" 
generate_weak_cert "/opt/sap/gateway/certs/soap.pem"    "/opt/sap/gateway/certs/soap-key.pem"    "soap.sap.howdens.local" 
generate_weak_cert "/opt/sap/gateway/certs/mobile.pem"  "/opt/sap/gateway/certs/mobile-key.pem"  "mob.sap.howdens.local"  
generate_weak_cert "/opt/sap/gateway/certs/b2b.pem"     "/opt/sap/gateway/certs/b2b-key.pem"     "b2b.sap.howdens.local"  
generate_weak_cert "/opt/sap/gateway/certs/edi.pem"     "/opt/sap/gateway/certs/edi-key.pem"     "edi.sap.howdens.local"  
generate_weak_cert "/opt/sap/gateway/certs/idoc.pem"    "/opt/sap/gateway/certs/idoc-key.pem"    "idoc.sap.howdens.local" 

echo ""
echo "Generating Oracle Database Layer Certificates (50 certs)..."

echo "  Oracle Prod DB 1..."
generate_weak_cert "/opt/oracle/prod01/certs/server.pem"     "/opt/oracle/prod01/certs/server-key.pem"     "ora-prod01.howdens.local"    
generate_weak_cert "/opt/oracle/prod01/certs/listener.pem"   "/opt/oracle/prod01/certs/listener-key.pem"   "listener.ora.howdens.local"  
generate_weak_cert "/opt/oracle/prod01/certs/wallet.pem"     "/opt/oracle/prod01/certs/wallet-key.pem"     "wallet.ora.howdens.local"    
generate_weak_cert "/opt/oracle/prod01/certs/tns.pem"        "/opt/oracle/prod01/certs/tns-key.pem"        "tns.ora.howdens.local"       
generate_weak_cert "/opt/oracle/prod01/certs/sqlnet.pem"     "/opt/oracle/prod01/certs/sqlnet-key.pem"     "sqlnet.ora.howdens.local"    
generate_weak_cert "/opt/oracle/prod01/certs/em.pem"         "/opt/oracle/prod01/certs/em-key.pem"         "em.ora.howdens.local"        
generate_weak_cert "/opt/oracle/prod01/certs/apex.pem"       "/opt/oracle/prod01/certs/apex-key.pem"       "apex.ora.howdens.local"      
generate_weak_cert "/opt/oracle/prod01/certs/ords.pem"       "/opt/oracle/prod01/certs/ords-key.pem"       "ords.ora.howdens.local"      
generate_weak_cert "/opt/oracle/prod01/certs/dataguard.pem"  "/opt/oracle/prod01/certs/dataguard-key.pem"  "dg.ora.howdens.local"        
generate_weak_cert "/opt/oracle/prod01/certs/rman.pem"       "/opt/oracle/prod01/certs/rman-key.pem"       "rman.ora.howdens.local"      
generate_weak_cert "/opt/oracle/prod01/certs/goldengate.pem" "/opt/oracle/prod01/certs/goldengate-key.pem" "gg.ora.howdens.local"        
generate_weak_cert "/opt/oracle/prod01/certs/asm.pem"        "/opt/oracle/prod01/certs/asm-key.pem"        "asm.ora.howdens.local"       

echo "  Oracle Prod DB 2..."
generate_weak_cert "/opt/oracle/prod02/certs/server.pem"     "/opt/oracle/prod02/certs/server-key.pem"     "ora-prod02.howdens.local"    
generate_weak_cert "/opt/oracle/prod02/certs/listener.pem"   "/opt/oracle/prod02/certs/listener-key.pem"   "listener2.ora.howdens.local" 
generate_weak_cert "/opt/oracle/prod02/certs/wallet.pem"     "/opt/oracle/prod02/certs/wallet-key.pem"     "wallet2.ora.howdens.local"   
generate_weak_cert "/opt/oracle/prod02/certs/tns.pem"        "/opt/oracle/prod02/certs/tns-key.pem"        "tns2.ora.howdens.local"      
generate_weak_cert "/opt/oracle/prod02/certs/sqlnet.pem"     "/opt/oracle/prod02/certs/sqlnet-key.pem"     "sqlnet2.ora.howdens.local"   
generate_weak_cert "/opt/oracle/prod02/certs/em.pem"         "/opt/oracle/prod02/certs/em-key.pem"         "em2.ora.howdens.local"       
generate_weak_cert "/opt/oracle/prod02/certs/apex.pem"       "/opt/oracle/prod02/certs/apex-key.pem"       "apex2.ora.howdens.local"     
generate_weak_cert "/opt/oracle/prod02/certs/ords.pem"       "/opt/oracle/prod02/certs/ords-key.pem"       "ords2.ora.howdens.local"     
generate_weak_cert "/opt/oracle/prod02/certs/dataguard.pem"  "/opt/oracle/prod02/certs/dataguard-key.pem"  "dg2.ora.howdens.local"       
generate_weak_cert "/opt/oracle/prod02/certs/rman.pem"       "/opt/oracle/prod02/certs/rman-key.pem"       "rman2.ora.howdens.local"     
generate_weak_cert "/opt/oracle/prod02/certs/goldengate.pem" "/opt/oracle/prod02/certs/goldengate-key.pem" "gg2.ora.howdens.local"       
generate_weak_cert "/opt/oracle/prod02/certs/asm.pem"        "/opt/oracle/prod02/certs/asm-key.pem"        "asm2.ora.howdens.local"      

echo "  Oracle Dev/QA..."
generate_weak_cert "/opt/oracle/dev/certs/server.pem"   "/opt/oracle/dev/certs/server-key.pem"   "ora-dev.howdens.local" 
generate_weak_cert "/opt/oracle/dev/certs/listener.pem" "/opt/oracle/dev/certs/listener-key.pem" "lst-dev.ora.howdens.local"
generate_weak_cert "/opt/oracle/dev/certs/wallet.pem"   "/opt/oracle/dev/certs/wallet-key.pem"   "wlt-dev.ora.howdens.local"
generate_weak_cert "/opt/oracle/dev/certs/tns.pem"      "/opt/oracle/dev/certs/tns-key.pem"      "tns-dev.ora.howdens.local"
generate_weak_cert "/opt/oracle/dev/certs/sqlnet.pem"   "/opt/oracle/dev/certs/sqlnet-key.pem"   "sql-dev.ora.howdens.local"
generate_weak_cert "/opt/oracle/dev/certs/em.pem"       "/opt/oracle/dev/certs/em-key.pem"       "em-dev.ora.howdens.local" 
generate_weak_cert "/opt/oracle/dev/certs/apex.pem"     "/opt/oracle/dev/certs/apex-key.pem"     "apex-dev.ora.howdens.local"
generate_weak_cert "/opt/oracle/dev/certs/ords.pem"     "/opt/oracle/dev/certs/ords-key.pem"     "ords-dev.ora.howdens.local"
generate_weak_cert "/opt/oracle/qas/certs/server.pem"   "/opt/oracle/qas/certs/server-key.pem"   "ora-qas.howdens.local" 
generate_weak_cert "/opt/oracle/qas/certs/listener.pem" "/opt/oracle/qas/certs/listener-key.pem" "lst-qas.ora.howdens.local"
generate_weak_cert "/opt/oracle/qas/certs/wallet.pem"   "/opt/oracle/qas/certs/wallet-key.pem"   "wlt-qas.ora.howdens.local"
generate_weak_cert "/opt/oracle/qas/certs/tns.pem"      "/opt/oracle/qas/certs/tns-key.pem"      "tns-qas.ora.howdens.local"
generate_weak_cert "/opt/oracle/qas/certs/sqlnet.pem"   "/opt/oracle/qas/certs/sqlnet-key.pem"   "sql-qas.ora.howdens.local"
generate_weak_cert "/opt/oracle/qas/certs/em.pem"       "/opt/oracle/qas/certs/em-key.pem"       "em-qas.ora.howdens.local" 
generate_weak_cert "/opt/oracle/qas/certs/apex.pem"     "/opt/oracle/qas/certs/apex-key.pem"     "apex-qas.ora.howdens.local"
generate_weak_cert "/opt/oracle/qas/certs/ords.pem"     "/opt/oracle/qas/certs/ords-key.pem"     "ords-qas.ora.howdens.local"

echo "  Oracle Listeners..."
generate_weak_cert "/opt/oracle/listener/certs/listener01.pem" "/opt/oracle/listener/certs/listener01-key.pem" "lst01.ora.howdens.local"
generate_weak_cert "/opt/oracle/listener/certs/listener02.pem" "/opt/oracle/listener/certs/listener02-key.pem" "lst02.ora.howdens.local"
generate_weak_cert "/opt/oracle/listener/certs/scan01.pem"     "/opt/oracle/listener/certs/scan01-key.pem"     "scan01.ora.howdens.local"
generate_weak_cert "/opt/oracle/listener/certs/scan02.pem"     "/opt/oracle/listener/certs/scan02-key.pem"     "scan02.ora.howdens.local"
generate_weak_cert "/opt/oracle/listener/certs/vip01.pem"      "/opt/oracle/listener/certs/vip01-key.pem"      "vip01.ora.howdens.local" 
generate_weak_cert "/opt/oracle/listener/certs/vip02.pem"      "/opt/oracle/listener/certs/vip02-key.pem"      "vip02.ora.howdens.local" 
generate_weak_cert "/opt/oracle/listener/certs/grid.pem"       "/opt/oracle/listener/certs/grid-key.pem"       "grid.ora.howdens.local"  
generate_weak_cert "/opt/oracle/listener/certs/crs.pem"        "/opt/oracle/listener/certs/crs-key.pem"        "crs.ora.howdens.local"   
generate_weak_cert "/opt/oracle/listener/certs/scan03.pem"     "/opt/oracle/listener/certs/scan03-key.pem"     "scan03.ora.howdens.local"
generate_weak_cert "/opt/oracle/listener/certs/vip03.pem"      "/opt/oracle/listener/certs/vip03-key.pem"      "vip03.ora.howdens.local" 

echo ""
echo "Generating Integration/Middleware Certificates (30 certs)..."

echo "  IBM MQ..."
generate_weak_cert "/opt/integration/mq/certs/qmgr01.pem"       "/opt/integration/mq/certs/qmgr01-key.pem"       "qmgr01.mq.howdens.local" 
generate_weak_cert "/opt/integration/mq/certs/qmgr02.pem"       "/opt/integration/mq/certs/qmgr02-key.pem"       "qmgr02.mq.howdens.local" 
generate_weak_cert "/opt/integration/mq/certs/channel-sap.pem"  "/opt/integration/mq/certs/channel-sap-key.pem"  "ch-sap.mq.howdens.local" 
generate_weak_cert "/opt/integration/mq/certs/channel-ora.pem"  "/opt/integration/mq/certs/channel-ora-key.pem"  "ch-ora.mq.howdens.local" 
generate_weak_cert "/opt/integration/mq/certs/channel-web.pem"  "/opt/integration/mq/certs/channel-web-key.pem"  "ch-web.mq.howdens.local" 
generate_weak_cert "/opt/integration/mq/certs/listener.pem"     "/opt/integration/mq/certs/listener-key.pem"     "lst.mq.howdens.local"    
generate_weak_cert "/opt/integration/mq/certs/client.pem"       "/opt/integration/mq/certs/client-key.pem"       "client.mq.howdens.local" 
generate_weak_cert "/opt/integration/mq/certs/admin.pem"        "/opt/integration/mq/certs/admin-key.pem"        "admin.mq.howdens.local"  
generate_weak_cert "/opt/integration/mq/certs/monitoring.pem"   "/opt/integration/mq/certs/monitoring-key.pem"   "mon.mq.howdens.local"    
generate_weak_cert "/opt/integration/mq/certs/cluster.pem"      "/opt/integration/mq/certs/cluster-key.pem"      "cluster.mq.howdens.local"

echo "  API Gateway / ESB / B2B..."
generate_weak_cert "/opt/integration/api/certs/gateway.pem"   "/opt/integration/api/certs/gateway-key.pem"   "gw.api.howdens.local"    
generate_weak_cert "/opt/integration/api/certs/portal.pem"    "/opt/integration/api/certs/portal-key.pem"    "portal.api.howdens.local"
generate_weak_cert "/opt/integration/api/certs/manager.pem"   "/opt/integration/api/certs/manager-key.pem"   "mgr.api.howdens.local"   
generate_weak_cert "/opt/integration/api/certs/analytics.pem" "/opt/integration/api/certs/analytics-key.pem" "analytics.api.howdens.local"
generate_weak_cert "/opt/integration/api/certs/oauth.pem"     "/opt/integration/api/certs/oauth-key.pem"     "oauth.api.howdens.local" 
generate_weak_cert "/opt/integration/api/certs/jwt.pem"       "/opt/integration/api/certs/jwt-key.pem"       "jwt.api.howdens.local"   
generate_weak_cert "/opt/integration/api/certs/backend.pem"   "/opt/integration/api/certs/backend-key.pem"   "be.api.howdens.local"    
generate_weak_cert "/opt/integration/api/certs/developer.pem" "/opt/integration/api/certs/developer-key.pem" "dev.api.howdens.local"   
generate_weak_cert "/opt/integration/esb/certs/server.pem"        "/opt/integration/esb/certs/server-key.pem"        "esb.howdens.local"       
generate_weak_cert "/opt/integration/esb/certs/sap-adapter.pem"   "/opt/integration/esb/certs/sap-adapter-key.pem"   "sap-esb.howdens.local"   
generate_weak_cert "/opt/integration/esb/certs/oracle-adapter.pem" "/opt/integration/esb/certs/oracle-adapter-key.pem" "ora-esb.howdens.local" 
generate_weak_cert "/opt/integration/esb/certs/http-adapter.pem"  "/opt/integration/esb/certs/http-adapter-key.pem"  "http-esb.howdens.local"  
generate_weak_cert "/opt/integration/esb/certs/soap-adapter.pem"  "/opt/integration/esb/certs/soap-adapter-key.pem"  "soap-esb.howdens.local"  
generate_weak_cert "/opt/integration/esb/certs/rest-adapter.pem"  "/opt/integration/esb/certs/rest-adapter-key.pem"  "rest-esb.howdens.local"  
generate_weak_cert "/opt/integration/b2b/certs/gateway.pem"  "/opt/integration/b2b/certs/gateway-key.pem"  "b2b.howdens.local"      
generate_weak_cert "/opt/integration/b2b/certs/edi.pem"      "/opt/integration/b2b/certs/edi-key.pem"      "edi.b2b.howdens.local"  
generate_weak_cert "/opt/integration/b2b/certs/as2.pem"      "/opt/integration/b2b/certs/as2-key.pem"      "as2.b2b.howdens.local"  
generate_weak_cert "/opt/integration/b2b/certs/sftp.pem"     "/opt/integration/b2b/certs/sftp-key.pem"     "sftp.b2b.howdens.local" 
generate_weak_cert "/opt/integration/b2b/certs/partner-a.pem" "/opt/integration/b2b/certs/partner-a-key.pem" "pa.b2b.howdens.local"  
generate_weak_cert "/opt/integration/b2b/certs/partner-b.pem" "/opt/integration/b2b/certs/partner-b-key.pem" "pb.b2b.howdens.local"  

echo ""
echo "Generating Infrastructure Certificates (10 certs)..."

generate_weak_cert "/opt/loadbalancer/certs/lb01.pem"      "/opt/loadbalancer/certs/lb01-key.pem"      "lb01.howdens.local"    
generate_weak_cert "/opt/loadbalancer/certs/lb02.pem"      "/opt/loadbalancer/certs/lb02-key.pem"      "lb02.howdens.local"    
generate_weak_cert "/opt/loadbalancer/certs/vip-sap.pem"   "/opt/loadbalancer/certs/vip-sap-key.pem"   "vip-sap.howdens.local" 
generate_weak_cert "/opt/loadbalancer/certs/vip-oracle.pem" "/opt/loadbalancer/certs/vip-oracle-key.pem" "vip-ora.howdens.local"
generate_weak_cert "/opt/loadbalancer/certs/admin.pem"     "/opt/loadbalancer/certs/admin-key.pem"     "admin.lb.howdens.local"
generate_weak_cert "/opt/proxy/certs/proxy01.pem"    "/opt/proxy/certs/proxy01-key.pem"    "proxy01.howdens.local"  
generate_weak_cert "/opt/proxy/certs/proxy02.pem"    "/opt/proxy/certs/proxy02-key.pem"    "proxy02.howdens.local"  
generate_weak_cert "/opt/proxy/certs/frontend.pem"   "/opt/proxy/certs/frontend-key.pem"   "fe.proxy.howdens.local" 
generate_weak_cert "/opt/proxy/certs/backend.pem"    "/opt/proxy/certs/backend-key.pem"    "be.proxy.howdens.local" 
generate_weak_cert "/opt/proxy/certs/ssl-offload.pem" "/opt/proxy/certs/ssl-offload-key.pem" "ssl.proxy.howdens.local"

# Cleanup
rm -rf "$WORK_DIR"

echo ""
echo "========================================"
echo "Certificate Deployment Complete!"
echo "========================================"
echo ""
echo "Total certificates generated: $CERT_COUNT"
echo ""
echo "Distribution:"
echo "  SAP Application Layer:   60 certificates"
echo "  Oracle Database Layer:   50 certificates"
echo "  Integration/Middleware:  30 certificates"
echo "  Infrastructure:          10 certificates"
echo "  ─────────────────────────────────────"
echo "  TOTAL:                  150 certificates"
echo ""
echo "Certificate characteristics:"
echo "  Algorithm: SHA-1 + RSA 1024-bit (WEAK — classified by PowerSC)"
echo "  Issued:    Today (current date � age is not the weakness, algorithm is)"
echo "  Domains:   *.howdens.local"
echo ""
echo "Next step: trigger PowerSC Quantum Safety scan on this host"
echo ""
