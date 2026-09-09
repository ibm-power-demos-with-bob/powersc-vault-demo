# TechZone Bug Report — Poughkeepsie Power10 504 Gateway Timeout (Systems On-Prem)

> Draft email to: techzone.help@ibm.com
> From: david.spurway@uk.ibm.com
> Date: 2026-09-07

---

**Subject: Persistent 504 Gateway Timeout on ICIC/PowerVC authentication — Poughkeepsie Power10 pool (systems-onprem)**

Hi TechZone Support,

I am experiencing consistent provisioning failures across multiple reservation attempts today against the Poughkeepsie (pok) Power10 on-premises pool (`systems-onprem` / `pok-onprem-systems`). Every attempt fails within 2–3 minutes of starting provisioning with identical Terraform errors. Retrying has not resolved the issue, which suggests an infrastructure-side problem rather than a transient spike.

## Errors observed

Both errors appear together on every failed attempt:

**Error 1 — Unable to Authenticate with ICIC**
```
providers.tf line 12
An unexpected error occurred when authenticating with the ICIC API.
ICIC Client Error: authentication failed with status 504:
504 Gateway Timeout — The gateway did not receive a timely response
from the upstream server or application.
```

**Error 2 — Unable to Authenticate with PowerVC**
```
providers.tf line 19
An unexpected error occurred when authenticating with the PowerVC API.
PowerVC Client Error: authentication failed with status 504:
504 Gateway Timeout — The gateway did not receive a timely response
from the upstream server or application.
```

## Affected reservations

| Request ID | Platform | Time (UTC) | Status |
|---|---|---|---|
| `6a9eb02e64ad79a10b380b8b` | PowerSC Lab (`6a8f57b95f542b07f9121623`) | 2026-09-07 12:40–12:43 | Failed |
| [second reservation ID — please add] | [platform] | 2026-09-07 [time] | Failed |

## Pattern

- Both ICIC and PowerVC authentication fail simultaneously with 504
- Failure occurs within 2–3 minutes of provisioning starting — before any VMs are created
- Consistent across multiple reservations today, different platforms, same underlying pool (`pok-onprem-systems`)
- This pattern has also been observed on previous dates (noted in our internal deployment logs)

## Impact

- Unable to provision any IBM Power on-premises environments from TechZone today
- Blocking pre-sales demo preparation and a planned Level 3 Stand and Deliver recording

## Request

Please investigate the health of the ICIC and PowerVC APIs on the Poughkeepsie Power10 pool (`pok-onprem-systems` / datacenter `pok`). Both services appear to be returning 504s to the Terraform provider on authentication, which suggests either the services are down or under severe load.

Please advise on expected resolution time and whether there is an alternative datacenter or pool that can be used in the interim.

Thanks,
David Spurway
IBM Technology Sales — EMEA AI on IBM Power Squad
david.spurway@uk.ibm.com
