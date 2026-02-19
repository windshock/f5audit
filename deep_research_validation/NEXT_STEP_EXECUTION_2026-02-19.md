# Next Step Execution (2026-02-19)

## Step 1: Windows Admin rerun (required)
Open Windows PowerShell **as Administrator** and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
& 'C:\Users\skplanet\Downloads\f5_deep_validation\Run-ElevatedGapClosure.ps1'
```

Then copy results into WSL:

```powershell
# PowerShell (User shell is fine)
$latest = Get-ChildItem "$env:USERPROFILE\Desktop" -Directory | Where-Object Name -like 'f5_gap_closure_*' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$latest.FullName
```

```bash
# WSL
LATEST_WIN_DIR="/mnt/c/Users/skplanet/Desktop/<PASTE_FOLDER_NAME>"
LATEST_LINUX_DIR="/home/windshock/f5_artifacts_2026-02-19/windows_validation/runs/<PASTE_FOLDER_NAME>"
mkdir -p "$LATEST_LINUX_DIR"
cp -f "$LATEST_WIN_DIR"/* "$LATEST_LINUX_DIR"/
```

## Step 2: BIG-IP version/hotfix evidence (required)
Run on BIG-IP shell (tmsh/bash) with admin privilege:

```bash
tmsh show sys version

tmsh list sys software status

tmsh list sys db | grep -Ei 'apm|hotfix|version'
```

Save outputs to:
- `infra_checks/bigip_mgmt_verify/bigip_version_dump_2026-02-19.txt`

## Step 3: APM policy/session log correlation (required)
During one controlled VPN login test window:

```bash
tail -f /var/log/apm
# in another terminal
tail -f /var/log/ltm
```

Correlate timestamps with:
- `parallel_tracks_2026-02-19/deep_research_validation/runtime_mitm/04_traffic_summary.json`
- `parallel_tracks_2026-02-19/deep_research_validation/runtime_mitm/05_inspect_first_flow.json`

## Step 4: Close checklist verdicts
Update:
- `parallel_tracks_2026-02-19/deep_research_validation/CVE_VALIDATION_CHECKLIST_2026-02-19.tsv`
- `parallel_tracks_2026-02-19/deep_research_validation/INTEGRATED_VERDICT_2026-02-19.md`

Use final states:
- `applied`
- `partial`
- `not_applied`
