# Codex SWARM Playbook (F5 Binary RE/Vuln Analysis)

## 목적
- 하나의 Codex 세션에서 서브 에이전트를 `swarm`처럼 운용해 디컴파일/취약점 분석을 병렬화한다.
- 최종 산출물은 재현 가능한 근거 중심 보고서로 통합한다.

## 역할 구성
1. Coordinator (메인 Codex)
- 전체 태스크 분배, 우선순위 관리, 중간 산출물 병합
- 충돌/중복 제거, 최종 보고서 승인

2. Agent A (정적 분석)
- 함수 맵, 호출 흐름, 위험 API/패턴 식별
- 산출물: `FUNCTION_MAP.md`, `HIGH_RISK_SITES.md`, `TAINT_PATHS.md`

3. Agent B (동적 분석)
- 입력면 식별, 크래시 재현, 최소 PoC 작성
- 산출물: `ENTRYPOINTS.md`, `CRASH_LOG.md`, `REPRO_STEPS.md`

4. Agent C (트리아지/리포트)
- A/B 결과를 취약점 단위로 병합, exploitability/우선순위 판정
- 산출물: `TRIAGE_TABLE.md`, `VULN_REPORT.md`, `PATCH_IDEAS.md`

## 공통 규칙
- 추정과 사실을 분리해서 기록한다.
- 모든 주장에 근거를 붙인다: `함수명@주소`, 로그, 명령어, 입력 해시.
- 이슈 ID 형식: `VULN-001`, `VULN-002`, ...
- 소유 파일 외 수정 금지(파일 소유권 침범 금지).
- 동기화 주기: 60~90분마다 아래 4항목 공유
  - 새 발견
  - 폐기 가설
  - 다음 실험
  - 필요 지원

## 핸드오프 포맷
```text
[HANDOFF]
Agent: A|B|C
Time: YYYY-MM-DD HH:MM
New Findings:
- ...
Discarded Hypotheses:
- ...
Next Experiments:
- ...
Support Needed:
- ...
Evidence:
- function@0xADDR / command / input_hash / stack
```

## Coordinator 실행 절차
1. 분석 대상 바이너리/환경 확인
- 바이너리 경로, 실행 인자, 필수 라이브러리, 디버깅 가능 여부 확인

2. Agent A/B/C 병렬 시작
- A: 정적 우선 분석 Top 10 함수 도출
- B: 입력면 매핑 + 재현 가능한 크래시 수집
- C: 트리아지 테이블 틀 먼저 작성 후 증거 대기

3. 1차 동기화
- 중복 이슈 병합, 가설 폐기, 추가 실험 지시

4. 2차 검증
- 재현성 확인(최소 2회), 환경 조건 명시, 영향도 재평가

5. 최종 통합
- `VULN_REPORT.md`에 이슈별 근거/재현/영향/완화/수정안 확정

## 다른 Codex에 전달용 요약(짧은 버전)
```text
한 세션 SWARM 운영:
- Coordinator: 분배/병합/최종 보고
- A(정적): FUNCTION_MAP/HIGH_RISK/TAINT_PATHS
- B(동적): ENTRYPOINTS/CRASH_LOG/REPRO_STEPS
- C(트리아지): TRIAGE_TABLE/VULN_REPORT/PATCH_IDEAS
규칙:
- 근거 필수(function@addr, command, input hash, stack)
- 파일 소유권 침범 금지
- 60~90분마다 handoff(새 발견/폐기 가설/다음 실험/필요 지원)
```

