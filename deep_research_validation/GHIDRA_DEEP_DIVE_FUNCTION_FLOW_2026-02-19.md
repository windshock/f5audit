# Ghidra Deep Dive Function Flow (2026-02-19)

## Scope
- Static deep-dive from Ghidra decompile outputs (function-level control flow)
- Focused on non-CVE remaining tracks: update trust chain / auth retry semantics / proxy path

## f5fpapi.dll
Source: `ghidra_decompile_outputs/f5fpapi_targets.c.txt`

### DllRegisterServer @ `10007850`
Key flow observed:
1. Iterates registration callback tables (`piRam10234260`, `piRam10226890..894`) and invokes function pointers under `_guard_check_icall`.
2. Executes COM registration path using repeated `CoCreateInstance(...)` calls with multiple CLSID/IID pairs.
3. Final cleanup via `func_0x1016b210()`.

Security-relevant notes:
- Indirect-call guarded dispatch pattern exists (`_guard_check_icall`).
- COM object registration is central, so registration-time trust decisions matter for installer/update chain.

### DllWebLogonEntryPoint @ `10066f70`
- Thin wrapper calling `func_0x10062230()` only.
- Suggests core auth/logon behavior is inside internal helper functions, not this exported stub.

## F5CustomDialer64.dll
Source: `ghidra_decompile_outputs/F5CustomDialer64_targets.c.txt`

### RasCustomEntryDlg @ `18000ca60`
Key flow observed:
1. Validates parameters and process token context (`GetCurrentProcess`, helper checks).
2. Builds shell execution structure and invokes `ShellExecuteExW`, then waits (`WaitForSingleObject`) and gets process exit code (`GetExitCodeProcess`).
3. Reads configuration from file/INI style sections via internal parsers (`func_0x...8990`, `...88bc`, etc.).
4. Populates multiple callback/function tables and state blocks before invoking deeper dialog/network logic.

Security-relevant notes:
- Explicit process spawning + wait/exit-code handling indicates external helper execution path.
- Config-driven behavior is significant (parsing sections/keys), which is relevant for update/proxy/auth behavior toggles.

### RasCustomDial @ `180008f20`
- Export is a wrapper to `FUN_180008f60()`; core dial behavior hidden in internal function.

## F5InstP.dll
Source: `ghidra_decompile_outputs/F5InstP_targets.c.txt`

### DllGetClassObject / DllRegisterServer
- Both are direct RPC proxy registration wrappers (`NdrDllGetClassObject`, `NdrDllRegisterProxy`).
- Indicates COM/RPC proxy registration component role (installer-control related plumbing).

## HookDll.dll
Source: `ghidra_decompile_outputs/HookDll_targets.c.txt`

### InstallHook @ `10006ed0`
- Calls `SetWindowsHookExW(...)` and broadcasts via `PostMessageW(0xffff, 0x65a8, ...)`.
- Returns `0xffffffff` on hook failure.

### RemoveWindowsHook @ `10006f50`
- Unhooks with `UnhookWindowsHookEx` and rebroadcasts post message.

Security-relevant notes:
- Global hook install/remove path is explicit and operationally sensitive.

## Depth status
- This pass is function-level flow analysis over exported targets and decompiled internals visible in current dumps.
- Full deep reverse (cross-function graph of all internal callees like `func_0x10062230`, `FUN_180008f60`) still requires additional Ghidra extraction for those internal symbols.
