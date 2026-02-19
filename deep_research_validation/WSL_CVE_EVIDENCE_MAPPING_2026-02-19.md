# WSL Static CVE Evidence Mapping (2026-02-19)

## Scope
- Source artifacts:
  - `triage_rabin2_2026-02-19/high_risk_imports.tsv`
  - `ghidra_decompile_outputs/*.txt`
- Method: static call/API evidence only (no runtime exploit test).

## Mapping Table

| Checklist item | Static evidence found | Binaries | Initial verdict |
|---|---|---|---|
| CVE-2022-28714 (DLL hijacking / installer chain) | process spawn + registry writes + dynamic loading imports (`CreateProcess*`, `LoadLibrary*`, `RegSetValueEx*`) | `F5CustomDialer64.dll`, `f5instd.exe`, `InstallerControl.dll`, `f5unistall.exe` | `NEEDS_WINDOWS_VALIDATION` |
| CVE-2021-23022 (temp/installer permission) | installer/service-oriented binaries and privileged operation imports confirmed | `F5InstallerService.exe`, `f5instd.exe`, `f5unistall.exe` | `NEEDS_WINDOWS_VALIDATION` |
| CVE-2024-28883 / 2025-23415 (endpoint/policy bypass class) | inspection/COM modules with network+registry interaction (`WinHttp*`, `RegSetValueEx*`) | `f5OesisInspectorCom.dll`, `f5InspectionHost.dll` | `NEEDS_WINDOWS_VALIDATION` |
| CVE-2023-24461 / 2023-36858 (auth channel/server integrity) | client/auth modules expose internet/http stack and config mutation APIs | `f5fpapi.dll`, `f5fpclientW.exe`, `F5DialSrv.exe` | `NEEDS_WINDOWS_VALIDATION` |
| Legacy ActiveX/COM risks (P1) | COM registration + hook lifecycle confirmed (`DllRegisterServer`, `CoCreateInstance`, `SetWindowsHookExW`) | `F5InstP.dll`, `f5fpapi.dll`, `HookDll.dll`, `f5OesisInspectorCom.dll` | `STATIC_EVIDENCE_COMPLETE` |

## High-confidence static findings
- `HookDll.dll`: `InstallHook` -> `SetWindowsHookExW`, `RemoveWindowsHook` -> `UnhookWindowsHookEx`.
- `f5fpapi.dll`: `DllRegisterServer` path repeatedly calls `CoCreateInstance`.
- `F5CustomDialer64.dll`: `RasCustomEntryDlg` includes `ShellExecuteExW`; `InstallCustomDialer` includes multiple `RegCreateKeyExW/RegSetValueExW`.
- `f5OesisInspectorCom.dll`: imports include `WinHttpOpen/WinHttpConnect/WinHttpOpenRequest/WinHttpSendRequest` (from triage import map).

## Limits
- This mapping does not prove exploitability by itself.
- P0 rows require Windows runtime/config evidence to reach final pass/fail.
