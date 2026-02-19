# Interview Decisions (2026-02-19)

- BIG-IP 장비: 전 장비 패치 완료 진술 -> mgmt-plane 3개 CVE는 `partial` 처리
- OTP: 장애 시 fail-open 운영 진술 -> `OTP fail-open / AAA fallback`은 `not_applied`
- Token/IP binding: 발급자 Public IP binding 미적용 진술 -> `phishing token reuse/IP binding`은 `not_applied`
- IPSec 비대상 확정 -> `peer_tunnel`, `ike_mode` 시나리오는 체크리스트 scope에서 제외
