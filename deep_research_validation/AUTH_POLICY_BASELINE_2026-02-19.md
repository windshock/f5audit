# Auth/Policy Baseline (2026-02-19)

## Sources
- `windows_live_exports/config.f5c`
- `auth_policy_checks/tls_cert_vpn_skplanet_com.txt`
- `auth_policy_checks/test_netconnection_vpn_443.txt`

## Findings
- VPN portal in client config: `https://vpn.skplanet.com`
- Client config (`config.f5c`) confirms:
  - server entry exists (`vpn.skplanet.com`)
  - update mode enabled (`<UPDATE><MODE>YES</MODE>`)
- TLS certificate baseline for `vpn.skplanet.com:443`:
  - subject: `CN=*.skplanet.com`
  - issuer: `GlobalSign GCC R3 DV TLS CA 2020`
  - validity: `2025-02-27` to `2026-03-31`
  - SHA256 fingerprint captured.
- Connectivity baseline:
  - `Test-NetConnection` to `vpn.skplanet.com:443` succeeded.

## Interpretation
- CVE-2023-24461 (cert validation class): baseline cert/connectivity evidence collected, but active MITM-resilience validation still pending.
- CVE-2023-36858 (server list integrity class): server list baseline collected, tamper-resistance runtime validation still pending.
