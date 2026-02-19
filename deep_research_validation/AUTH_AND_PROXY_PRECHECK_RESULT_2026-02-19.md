# Auth/Proxy Precheck Result (2026-02-19)

## Inputs
- `windows_validation/runs/f5_auth_replay_20260219_153345/10_lockout_rate_limit_attempts.csv`
- `windows_validation/runs/f5_auth_replay_20260219_153345/20_token_replay.csv`
- `infra_checks/pending_scenario_checks_20260219_1532/proxy_semantics_check.txt`

## Observations
- Low-intensity invalid login replay (3 attempts) returned consistent:
  - HTTP `302`
  - `Location: /my.logout.php3?errorcode=19`
  - No explicit lockout/throttle marker in client-visible response.
- Token replay check was skipped because authorized test credentials were not supplied.
- Proxy misuse precheck:
  - Explicit CONNECT-style request to `vpn.skplanet.com:443` did not behave as generic forward proxy.
  - Response redirected to APM path (`/my.policy`) instead.

## Limits
- Lockout/rate-limit cannot be concluded from 3 invalid attempts only.
- Token replay/IP-binding verdict requires authorized account + dual-egress test.
- Server-side APM logs are still required for policy-level conclusion.
