# Codex Handoff - 2026-02-19

## User Request Context
- User asked to decompile `f5_artifacts` with Ghidra.
- User then asked to evaluate `rabin2` similarly and proceed, plus install MCP skills.

## Environment
- OS: Ubuntu 24.04.4 LTS
- `sudo` requires password (no root install path used)
- Working dir: `/home/windshock`

## Artifact Discovery
- Target folder: `/home/windshock/f5_artifacts_2026-02-19`
- Actual PE files exist under:
  - `/home/windshock/f5_artifacts_2026-02-19/windows_root/...`
- Example discovered binaries include `.exe` and `.dll` (F5 components).

## Skills / MCP Investigation
- Opened skill: `/home/windshock/.codex/skills/.system/skill-installer/SKILL.md`
- Curated skill list fetched successfully via:
  - `python3 .../list-skills.py`
- Experimental list failed:
  - `--path skills/.experimental` -> path not found upstream
- No direct curated MCP/Ghidra skill found in returned list.

## Installed Tooling (local, no sudo)

### Java (for Ghidra)
- Installed under:
  - `/home/windshock/.local/share/jdk-21`
- Source: Adoptium Temurin 21 (GitHub release tarball)

### Ghidra
- Installed under:
  - `/home/windshock/.local/share/ghidra_12.0.3_PUBLIC`
- Release used:
  - `ghidra_12.0.3_PUBLIC_20260210.zip`
- ZIP extraction done with Python `zipfile` (because `unzip` missing).
- Wrapper scripts created:
  - `/home/windshock/.local/bin/ghidra`
  - `/home/windshock/.local/bin/analyzeHeadless`
- Wrapper behavior:
  - sets `JAVA_HOME=/home/windshock/.local/share/jdk-21`
  - prepends `$JAVA_HOME/bin` to `PATH`

### radare2 / rabin2
- Installed by extracting deb (no root):
  - `/home/windshock/.local/share/radare2`
- Intended wrapper path:
  - `/home/windshock/.local/bin/rabin2`
- Current blocker:
  - `rabin2` invocation still shows recursive/self-exec symptom:
    - `/home/windshock/.local/share/radare2/usr/bin/rabin2: line 5: ... Argument list too long`
  - This indicates wrapper/script confusion around real binary resolution.

## Known Issues / Blockers
1. `rabin2` not yet in clean working state due to recursion path issue.
2. `analyzeHeadless`/`ghidra` verification was started but not fully captured after wrapper changes.
3. MCP skill installation not completed; curated list lacks direct MCP/Ghidra skill.

## Recommended Next Steps for Next Codex
1. Fix `rabin2` pathing:
   - Verify actual ELF binary location with `file` under `/home/windshock/.local/share/radare2/usr/bin/`.
   - Ensure wrapper at `/home/windshock/.local/bin/rabin2` execs the real ELF, not another wrapper/symlink loop.
   - Set `LD_LIBRARY_PATH=/home/windshock/.local/share/radare2/usr/lib`.
2. Re-verify tools:
   - `rabin2 -v`
   - `analyzeHeadless ... -help`
3. Run sample analysis on one PE file from:
   - `/home/windshock/f5_artifacts_2026-02-19/windows_root/...`
4. Complete MCP request:
   - If user wants Ghidra MCP specifically, install a chosen repo/path via `skill-installer` script:
     - `/home/windshock/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py`
   - Then note: restart Codex to pick up newly installed skills.

## Key Paths
- Artifacts: `/home/windshock/f5_artifacts_2026-02-19`
- Skills home: `/home/windshock/.codex/skills`
- Installer skill: `/home/windshock/.codex/skills/.system/skill-installer`
- Local binaries: `/home/windshock/.local/bin`
- Tool archives/cache: `/home/windshock/tools`

