#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/home/windshock/f5_artifacts_2026-02-19/parallel_tracks_2026-02-19/deep_research_validation"
RUN_ID="$(date +%Y%m%d_%H%M%S)"
OUT_DIR="${BASE_DIR}/runtime_x64dbg/${RUN_ID}"
WIN_PY_SCRIPT_DEFAULT='C:\Users\skplanet\Downloads\f5_deep_validation\x64dbg.py'
WIN_PY_SCRIPT="${WIN_PY_SCRIPT:-$WIN_PY_SCRIPT_DEFAULT}"

mkdir -p "$OUT_DIR"

{
  echo "run_id=${RUN_ID}"
  echo "out_dir=${OUT_DIR}"
  echo "win_py_script=${WIN_PY_SCRIPT}"
  echo "wsl_user=$(whoami)"
  echo "wsl_host=$(hostname)"
  echo "wsl_kernel=$(uname -a)"
  echo "timestamp_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "timestamp_local=$(date +%Y-%m-%dT%H:%M:%S%z)"
} >"${OUT_DIR}/00_meta.txt"

run_check() {
  local out_file="$1"
  local tool="$2"
  local tries=0
  local max_tries=5
  local tmp_file
  tmp_file="$(mktemp)"

  while (( tries < max_tries )); do
    tries=$((tries + 1))
    powershell.exe -NoProfile -Command "python \"${WIN_PY_SCRIPT}\" ${tool}" >"$tmp_file" 2>&1 || true

    if ! grep -q "UtilBindVsockAnyPort" "$tmp_file"; then
      cp -f "$tmp_file" "$out_file"
      rm -f "$tmp_file"
      return 0
    fi
    sleep 1
  done

  cp -f "$tmp_file" "$out_file"
  rm -f "$tmp_file"
  return 0
}

run_check "${OUT_DIR}/01_is_debug_active.txt" "IsDebugActive"
run_check "${OUT_DIR}/02_is_debugging.txt" "IsDebugging"
run_check "${OUT_DIR}/03_module_list.txt" "GetModuleList"
run_check "${OUT_DIR}/04_thread_list.txt" "GetThreadList"
run_check "${OUT_DIR}/05_call_stack.txt" "GetCallStack"
run_check "${OUT_DIR}/06_tcp_connections.txt" "EnumTcpConnections"
run_check "${OUT_DIR}/07_breakpoints.txt" "GetBreakpointList"
run_check "${OUT_DIR}/08_register_dump.txt" "GetRegisterDump"

ACTIVE="$(tr -d '\r' < "${OUT_DIR}/01_is_debug_active.txt" | tail -n 1 || true)"
DEBUGGING="$(tr -d '\r' < "${OUT_DIR}/02_is_debugging.txt" | tail -n 1 || true)"

{
  echo "# x64dbg Dynamic Auto Check Summary"
  echo
  echo "- run_id: ${RUN_ID}"
  echo "- output_dir: ${OUT_DIR}"
  echo "- IsDebugActive: ${ACTIVE}"
  echo "- IsDebugging: ${DEBUGGING}"
  echo
  echo "## Manual actions needed"
  echo "- If IsDebugging is false, load target process in x64dbg and break once."
  echo "- Re-run this script after loading target to capture module/thread/stack/register evidence."
} >"${OUT_DIR}/99_summary.md"

echo "${OUT_DIR}"
