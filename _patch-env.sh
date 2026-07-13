#!/bin/bash
ENV=/home/cecuser/powersc-vault-demo/ui/.env.local
grep -q '^POWERSC_USER=' "$ENV" || echo 'POWERSC_USER=powersc-admin'      >> "$ENV"
grep -q '^POWERSC_PASS=' "$ENV" || echo 'POWERSC_PASS=qu3knx0h_Q7h+gg'   >> "$ENV"
grep -q '^AIX_HOSTNAME='  "$ENV" || echo 'AIX_HOSTNAME=p1294-pvm3'        >> "$ENV"
echo "=== .env.local (PASS redacted) ==="
grep -v 'PASS' "$ENV"
