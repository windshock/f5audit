import anyio, json, pathlib, subprocess, time
from mcp.client.session import ClientSession
from mcp.client.stdio import StdioServerParameters, stdio_client

OUT = pathlib.Path('/home/windshock/f5_artifacts_2026-02-19/parallel_tracks_2026-02-19/deep_research_validation/runtime_mitm')
OUT.mkdir(parents=True, exist_ok=True)

async def main():
    params = StdioServerParameters(command='/home/windshock/.local/bin/mitmproxy-mcp-venv', args=[])
    async with stdio_client(params) as (r, w):
        async with ClientSession(r, w) as s:
            await s.initialize()
            tools = await s.list_tools()
            (OUT/'tools.json').write_text(json.dumps([t.name for t in tools.tools], indent=2), encoding='utf-8')

            r1 = await s.call_tool('start_proxy', {'port': 8080})
            (OUT/'01_start_proxy.txt').write_text(str(r1.content[0].text if r1.content else r1), encoding='utf-8')

            r2 = await s.call_tool('set_scope', {'allowed_domains':['vpn.skplanet.com']})
            (OUT/'02_set_scope.txt').write_text(str(r2.content[0].text if r2.content else r2), encoding='utf-8')

            # generate benign traffic through proxy
            cmds = [
                ['curl','-k','-I','--proxy','http://127.0.0.1:8080','https://vpn.skplanet.com/'],
                ['curl','-k','--proxy','http://127.0.0.1:8080','https://vpn.skplanet.com/','-o','/dev/null','-s','-w','%{http_code}\\n'],
            ]
            outs = []
            for c in cmds:
                p = subprocess.run(c, capture_output=True, text=True)
                outs.append({'cmd':c,'rc':p.returncode,'stdout':p.stdout[:2000],'stderr':p.stderr[:2000]})
            (OUT/'03_curl_via_proxy.json').write_text(json.dumps(outs, indent=2), encoding='utf-8')

            r3 = await s.call_tool('get_traffic_summary', {'limit': 20})
            txt3 = r3.content[0].text if r3.content else '{}'
            (OUT/'04_traffic_summary.json').write_text(txt3, encoding='utf-8')

            # inspect first flow if possible
            first_id = None
            try:
                arr = json.loads(txt3)
                if isinstance(arr, list) and arr:
                    first_id = arr[0].get('id')
            except Exception:
                pass

            if first_id:
                r4 = await s.call_tool('inspect_flow', {'flow_id': first_id})
                (OUT/'05_inspect_first_flow.json').write_text(r4.content[0].text if r4.content else '{}', encoding='utf-8')
                (OUT/'05_first_flow_id.txt').write_text(first_id, encoding='utf-8')

            r5 = await s.call_tool('stop_proxy', {})
            (OUT/'06_stop_proxy.txt').write_text(str(r5.content[0].text if r5.content else r5), encoding='utf-8')

anyio.run(main)
