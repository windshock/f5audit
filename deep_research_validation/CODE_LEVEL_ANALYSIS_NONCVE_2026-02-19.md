# Code-Level Analysis (Non-CVE Scope) - 2026-02-19

## Targets
- installer/update trust chain
- credential stuffing / brute-force
- VPN proxy misuse

## 1) installer/update trust chain
Static evidence indicates signature-verification and update/download control paths exist in client modules.

Evidence:
- `parallel_tracks_2026-02-19/top5/raw/C__ProgramData__F5 Networks__f5unistall.exe.I.txt:29` -> `signed   true`
- `parallel_tracks_2026-02-19/top5/raw/C__ProgramData__F5 Networks__f5unistall.exe.z.txt:1942` -> `Failed to get signature of "%1", error 0x80092009`
- `parallel_tracks_2026-02-19/top5/raw/C__ProgramData__F5 Networks__f5unistall.exe.z.txt:7403` -> `(is not trusted)`
- `parallel_tracks_2026-02-19/top5/raw/C__ProgramData__F5 Networks__f5unistall.exe.z.txt:1907` -> `CertVerifyCertificateChainPolicy`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.imports.txt:477` -> `CRYPT32!CertVerifyCertificateChainPolicy`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.z.txt:1849` -> `Auto Update`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.z.txt:2196` -> `OnStartDownload`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.z.txt:2197` -> `OnDownloadProgress`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.z.txt:2198` -> `OnFinishDownload`

Interpretation:
- 업데이트/프리컨피그 다운로드와 서명체인 검증 경로가 존재.
- 다만 "검증 실패 시 항상 hard-fail"인지까지는 현재 정적 증거만으로 단정 불가.

## 2) credential stuffing / brute-force
Client-visible 결과와 코드 문자열 기준으로, 재시도/재연결 파라미터는 보이지만 lockout/throttle 강제 로직은 확인되지 않음.

Evidence:
- `windows_validation/runs/f5_auth_replay_20260219_153345/10_lockout_rate_limit_attempts.csv:2` -> invalid_1 => `302 /my.logout.php3?errorcode=19`
- `windows_validation/runs/f5_auth_replay_20260219_153345/10_lockout_rate_limit_attempts.csv:3` -> invalid_2 => `302 /my.logout.php3?errorcode=19`
- `windows_validation/runs/f5_auth_replay_20260219_153345/10_lockout_rate_limit_attempts.csv:4` -> invalid_3 => `302 /my.logout.php3?errorcode=19`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__F5CustomDialer64.dll.z.txt:1278` -> `RedialAttempts=`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__F5CustomDialer64.dll.z.txt:1339` -> `TryNextAlternateOnFail=`
- `log_correlation/extracted_temp_logs/f5InspHostCtrl.txt:221` -> `_control.attempts < 2` + retry comment

Interpretation:
- 클라이언트 관찰면에서는 실패 응답이 동일 패턴으로 반복됨.
- 클라이언트 내 재시도 관련 키는 존재하지만, 계정 잠금/속도제한 정책은 서버(APM/AAA) 로그/정책으로 최종 확인 필요.

## 3) VPN proxy misuse
프록시 관련 제어 경로(설정/탐지/PAC/자격증명 처리)는 코드와 런타임 로그에서 명확히 확인됨.

Evidence:
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__F5CustomDialer64.dll.z.txt:1203` -> `PROXY_TYPE`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__F5CustomDialer64.dll.z.txt:1205` -> `PROXY_AUTO_CONFIG`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__F5CustomDialer64.dll.z.txt:1343` -> `ProxyServer=`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.imports.txt:496` -> `WININET!InternetSetOptionA`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.imports.txt:495` -> `WININET!InternetConnectA`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.z.txt:4901` -> `CPACParser::FindProxyForURL`
- `parallel_tracks_2026-02-19/top5/raw/C__Program Files (x86)__F5 VPN__f5fpapi.dll.z.txt:4699` -> `dont use proxy`
- `log_correlation/extracted_temp_logs/f5TunnelServer.txt:218` -> `command, FindProxyForURL`
- `log_correlation/extracted_temp_logs/f5TunnelServer.txt:258` -> `dont use proxy`

Interpretation:
- 프록시 오용 여부는 "기능 존재"가 아니라 "운영 설정과 정책 강제"로 결정됨.
- 코드상 프록시 경로는 충분히 존재하므로, 운영 정책 미스설정 시 리스크 표면이 형성될 수 있음.

## Practical conclusion for remaining 3 items
- `installer/update trust chain`: code-level evidence 확보(검증/업데이트 경로 존재), final verdict 위해 fail-open/fail-close 동작 확인 필요.
- `credential stuffing / brute-force`: code-level + small replay evidence 확보, final verdict 위해 APM/AAA rate-limit/lockout policy 증적 필요.
- `VPN proxy misuse`: code-level proxy stack evidence 확보, final verdict 위해 운영 정책/토폴로지 강제 증적 필요.
