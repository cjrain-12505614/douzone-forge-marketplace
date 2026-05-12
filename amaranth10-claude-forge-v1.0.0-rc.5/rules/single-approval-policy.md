---
name: single-approval-policy
description: 자비스 검토가 단순 OK인 경우 별도 검토의견 .md 산출 X. 채팅 회신만으로 진입 결재.
paths: ["**/*검토의견*.md", "**/*검토결과*.md"]
---

# Single Approval Policy Rule

> 학습 #4 — 단순 결재 시 .md 생략, 채팅 회신만
> 발효: 2026-05-11 (Phase V V-07-01)
> SSoT: [`규칙/프로세스/자비스-운영-룰.md`](../../../Workspace/douzone-forge/규칙/프로세스/자비스-운영-룰.md) §2 학습 #4

## 룰 본문

자비스가 ⑥ 검토 단계에서 단순 OK 결재를 내릴 때, 별도 검토의견 .md 파일을 산출하지 않는다. 채팅 회신 한 줄로 ⑦ 진입 결재를 갈음한다.

### 결재 분기

| 결재 유형 | 산출 형식 |
|---|---|
| 단순 OK | 채팅 한 줄 — "⑥ 단순 OK — ⑦ 진입 OK" |
| 정정 의견 1~2건 | 채팅 본문에 정정 항목만 + .md 별도 X |
| 종합 검토 (정정 다수) | `outputs/{날짜}-{Phase}-검토의견.md` 산출 — 학습 #6 v2 갱신 시도 회피 |

## 적용 시점·범위

- 시점: 자비스 ⑥ 검토 단계 (Code 계획서 검토)
- 범위: `outputs/` 디렉토리 + 채팅 회신
- 의존: 학습 #6 (승인 단순화) 결합 — 차민수 단순 OK 시 즉시 ⑦ 적용 진입

## Why

매 사이클마다 검토의견 .md 산출은 R8 증가 요인. 단순 결재 사이클은 채팅 회신으로 갈음하여 가속한다. Phase R+ Code §11 4건 답변 채택 사례에서 효과 검증.

## 위반 시 처리

PostToolUse Write/Edit Hook (`hooks/simple-approval-md-block.sh`) 이 `*검토의견*.md` 또는 `*검토결과*.md` 신규 작성 시 stderr 경고 (block 하지 않음, 종합 검토는 허용).

```
⚠️  [simple-approval-md-block] 검토의견 .md 신규 작성 감지
    학습 #4 — 단순 결재 시 .md 생략, 채팅 회신만
    → 단순 결재면 본 .md 작성 중단, 채팅 회신으로 대체.
```

## Hook 연계

- `hooks/simple-approval-md-block.sh` — PreToolUse Write/Edit, 검토의견·검토결과 .md 신규 작성 감지

## 관련 자산

- 학습 #6 (승인 단순화) — [`rules/no-v2-rebump.md`](no-v2-rebump.md)
- 자비스 ⑥ 검토 단계 절차 — SSoT §3 워크플로우 10단계

## 변천사

- 자비스 학습 #4 — Phase R+ 발효 (Code §11 4건 답변 채택)
- Phase V V-07-01 (2026-05-11) — 본 Rule 신설로 정책 강제
