# x64dbg MCP Setup (wasdubya) - 2026-02-19

## Installed components
- x64dbg (winget): `x64dbg.x64dbg 2025.08.19`
- MCP plugin binaries (release v1.0.0):
  - `.../release/x64/plugins/MCPx64dbg.dp64`
  - `.../release/x32/plugins/MCPx64dbg.dp32`
- MCP python bridge:
  - `/home/windshock/tools/x64dbgMCP_release_20260219/x64dbg.py`
- Launcher:
  - `/home/windshock/.local/bin/x64dbg-mcp-wasdubya`

## Verification pointers
1. Start x64dbg from Windows.
2. Open log window in x64dbg (`Alt+L`) and verify plugin load message.
3. Ensure plugin HTTP endpoint is reachable at `http://127.0.0.1:8888/`.

## MCP client config example
```json
{
  "mcpServers": {
    "x64dbg-wasdubya": {
      "command": "/home/windshock/.local/bin/x64dbg-mcp-wasdubya"
    }
  }
}
```

## Optional endpoint override
```bash
X64DBG_URL=http://127.0.0.1:8888/ /home/windshock/.local/bin/x64dbg-mcp-wasdubya
```

## Notes
- This bridge script uses `X64DBG_URL` env var for target endpoint selection.
- Do not pass endpoint URL as argv when starting MCP server; use env var.
