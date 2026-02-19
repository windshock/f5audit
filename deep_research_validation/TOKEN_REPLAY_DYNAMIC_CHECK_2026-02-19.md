# Token Replay Dynamic Check (2026-02-19)

## Objective
- F5 세션 쿠키(`MRHSession`) 재사용 시 접근 가능 여부를 기술적으로 확인.

## Source token
- mitm 캡처 flow: `49fc63b6-a059-419f-ad14-f2b9acc6ef8c`
- response headers:
  - `Set-Cookie: LastMRH_Session=4d5eda12`
  - `Set-Cookie: MRHSession=4b49111d79103b90137784c94d5eda12`

## Replay checks
1. `GET /` with replayed cookie
- Request cookie:
  - `LastMRH_Session=4d5eda12; MRHSession=4b49111d79103b90137784c94d5eda12`
- Result:
  - `HTTP/1.0 302 Found`
  - `Location: /my.policy`
  - new cookies re-issued (`LastMRH_Session`, `MRHSession`)

2. `GET /my.policy` with same replayed cookie
- Result:
  - `HTTP/1.0 302 Found`
  - `Location: /my.logout.php3?errorcode=20`

## Interpretation
- 비인증/초기 단계에서 얻은 `MRHSession` 재사용으로는 보호 리소스 접근이 성립하지 않음.
- 다만 이 결과만으로 "인증 완료 세션 토큰 재사용 불가"를 단정할 수는 없음.

## Limitation
- 현재 캡처는 OTP 이후 "설치 페이지" 단계의 인증 완료 세션 쿠키를 포함하지 않음.
- 최종 결론(인증 완료 세션 재사용 가능/불가)을 위해서는 다음이 필요:
  1. OTP 완료 직후의 실제 인증 세션 쿠키 캡처
  2. 동일 쿠키 replay 시 접근 결과 비교
  3. (선택) 출발지 IP 변경 replay 비교
