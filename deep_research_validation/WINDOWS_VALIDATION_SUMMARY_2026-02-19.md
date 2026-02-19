# Windows Validation Summary (2026-02-19)

## Run info
- Script: `windows_validation/Run-DeepResearchChecks.ps1`
- Run output: `windows_validation/runs/f5_deep_validation_20260219_145159`

## Key findings
- Installed products detected:
  - `BIG-IP Edge Client Components (All Users)` version `72.2025.1009.1418`
  - `BIG-IP Edge Client` version `72.25.1009.1418`
- F5-related services running:
  - `F5 Networks Component Installer`
  - `F5 DNS Relay Proxy Service`
  - `F5 Networks Pre-Logon Helper Service`
  - `F5 Networks Traffic Control Service`
  - `Image SAFER 5.0 Service`
- Signature inventory:
  - total binary entries: 79
  - `Valid` signatures: 74
  - `NotSigned`: 0
  - `UnknownError`: 0
- COM/registration evidence:
  - `F5 Networks Credential Provider` CLSID mapped to `C:\Program Files (x86)\F5 VPN\F5CredProv64.dll`
  - `C:\Windows\Downloaded Program Files\F5InstP64.dll` registration path observed
  - `C:\Windows\Downloaded Program Files\f5Hook64.dll` registration path observed
- Driver surface evidence (separate CIM query):
  - `F5FltDrv` running
  - `urvpndrv` running (`covpnv64.sys`)
  - `f5ipfw` installed (stopped)

## Gaps / limits from this run
- `C:\Windows\Temp` ACL check returned access denied in current run context.
- Network map for F5 processes (`61_net_process_map.txt`) was empty snapshot at execution time.
- BIG-IP management plane(TGUI/TMUI/iControl) exposure/patch cannot be concluded from this endpoint-only run.
