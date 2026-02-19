# Log Correlation Result (2026-02-19)

## Source datasets
- `log_correlation/winevent_app_f5_7d.csv`
- `log_correlation/winevent_system_f5_7d.csv`
- `log_correlation/extracted_temp_logs/*`

## Key observations
- VPN session lifecycle events observed in Windows event logs (`RasClient`, `RasMan`):
  - dial start, adapter usage (`F5 Networks VPN Adapter`), connect success, disconnect.
- System log includes filter-driver signal:
  - `AFD 16001` referencing `\Driver\F5FltDrv`.
- Client-side runtime artifacts found in temp/roaming paths:
  - `f5Install.txt`
  - `f5InspHostCtrl.txt`
  - `f5TunnelServer.txt`
  - `f5TunnelServerX.txt`
  - `client.f5c`, `client.f5c.sig`

## Value for checklist
- Supports policy/auth/driver in-progress items with runtime timeline evidence.
- Still needs server-side APM policy/session logs to conclude bypass-class CVEs.

## File references
- `log_correlation/extracted_temp_logs_preview.txt`
- `log_correlation/extracted_temp_logs/f5Install.txt`
- `log_correlation/extracted_temp_logs/f5InspHostCtrl.txt`
- `log_correlation/extracted_temp_logs/f5TunnelServer.txt`
- `log_correlation/extracted_temp_logs/f5TunnelServerX.txt`
