---
name: no-v2-rebump
description: {이름} 단순 OK 시 즉시 진행. v2 계획서 갱신 시도 X. v1 그대로 + 정정 1~2건만 본문 반영.
paths: ["**/*-v2.md", "**/*v2-*.md", "**/*-V2.md"]
---

# No V2 Rebump Rule

> 학습 #6 — 승인 단순화 (v2 갱신 시도 X)
> 발효: 2026-05-11 (Phase V V-07-01)
> SSoT: [`규칙/프로세스/자비스-운영-룰.md`](../../../Workspace/douzone-forge/규칙/프로세스/자비스-운영-룰.md) §2 학습 #6

## 룰 본문

{이름} 단순 OK 또는 ExitPlanMode 승인 후, 같은 사이클 내 v2 계획서 신규 작성을 금지한다. v1 파일을 그대로 두고 정정 1~2건만 본문 반영한다.

### 적용 분기

| 상황 | 처리 |
|---|---|
| {이름} 단순 OK 채팅 | Claude Code 즉시 ⑦ 적용 진입 |
| ExitPlanMode 승인 | 즉시 ⑦ 적용 진입 — 별도 v2 산출 X |
| 정정 1~2건 | v1 파일 Edit 으로 정정 사항 반영 |
| 정정 다수 (3건+) | 학습 #4 종합 검토 .md 산출 → v1 직접 정정 |

## 적용 시점·범위

- 시점: ExitPlanMode 승인 후·자비스 단순 OK 직후
- 범위: 같은 Phase 사이클 내 v2 계획서·v2 마스터·v2 지시서 신규 Write
- 예외: 다른 사이클 v2 (Phase 종료 후 다음 Phase 계획서) — 허용

## Why

ExitPlanMode 승인 자체가 단순 OK 신호. 추가 v2 갱신은 R8 손실 + 학습 #4 (단순 결재 .md 생략) 일관 위배. Phase R+ 보너스 AC-MP-1.5 채택 시점에 발효.

## 위반 시 처리

PreToolUse Write Hook (`hooks/v2-version-bump-block.sh`) 이 `*-v2.md` 또는 `*v2-*.md` 패턴 + 계획서·지시서·마스터 키워드 동반 시 차단 (exit 2).

```
🚫 [v2-version-bump-block] v2 계획서 신규 작성 차단
    학습 #6 — 승인 단순화 (v2 갱신 시도 X)
    → v1 파일을 Edit 으로 정정. 본 Write 중단.
```

### 화이트리스트

- `*변천사*`·`*변경이력*`·`*history*`·`*log*` 본문 → 통과 (변천사 기록은 v2 어휘 보존)
- archive·.bak 영역 → 통과

## Hook 연계

- `hooks/v2-version-bump-block.sh` — PreToolUse Write, exit code 2 차단

## 관련 자산

- 학습 #4 (단순 결재 .md 생략) — [`rules/single-approval-policy.md`](single-approval-policy.md)
- 자비스 ⑦ Claude Code 적용 절차 — SSoT §3 워크플로우 10단계

## 변천사

- 자비스 학습 #6 — Phase R+ 발효 (보너스 AC-MP-1.5 채택)
- Phase V V-07-01 (2026-05-11) — 본 Rule 신설로 정책 강제
