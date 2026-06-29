# 훅 인벤토리·분류표 (HOOKS.md)

> douzone-forge 플러그인 훅 21개의 트리거·배선·성격·게이트 분류. 표준: [`규칙/프로세스/플러그인-자체-개발표준.md`](../../../../../Workspace/douzone-forge/규칙/프로세스/플러그인-자체-개발표준.md) §6·§9. 갱신: 2026-06-23 실측(스트림 4 Phase C).
>
> 용어: 배선(plugin.json에 등록되어 실제 작동) · 고아(orphan, 미배선) · 차단(exit 2 — 작업을 막음) · 권고(exit 0 + stderr 경고) · 게이트(`_forge-gate.sh` — 브리지/env에서만 작동) · 헬퍼(다른 훅이 source로 불러 쓰는 보조)

## 1. 배선된 훅 (plugin.json 등록 = 실제 작동, 14)

| 훅 | 트리거 | 성격 | 게이트 | set -e |
|---|---|---|---|---|
| `db-migration-guard.sh` | PreToolUse(Write/Edit/Bash) | **차단(exit 2)** — 파괴적 SQL | ✗(기본 차단·`FORGE_DB_GUARD=off` opt-out) | ✓ |
| `structure-awareness.sh` | PreToolUse(Write/Edit) | 권고 | ✗ | — |
| `code-quality-reminder.sh` | PostToolUse(Write/Edit) | 권고 | **✓ (H3)** | — |
| `security-auto-trigger.sh` | PostToolUse(Write/Edit) | 권고 | **✓ (H3)** | — |
| `build-verify-reminder.sh` | PostToolUse(Edit) | 권고 | **✓ (H3)** | — |
| `prj-code-naming-check.sh` | PostToolUse(Write/Edit) | 권고 | ✗ | — |
| `answer-tone-check.sh` | PostToolUse(Write/Edit) | 권고 | ✗ | ✓ |
| `output-location-policy.sh` | PostToolUse(Write/Edit) | 권고 | ✗ | — |
| `prj-filename-policy.sh` | PostToolUse(Write/Edit) | 권고 | ✗ | — |
| `folder-purpose-check.sh` | PostToolUse(Write/Edit) | 권고 | ✗ | — |
| `folder-structure-check.sh` | PostToolUse(Write/Edit) | 권고 | ✗ | ✓ |
| `rules-protection-check.sh` | PostToolUse(Write/Edit) | 권고 | ✗ | ✓ |
| `link-integrity-check.sh` | PostToolUse(Write/Edit) | 권고 | ✗ | — |
| `dz-gitlab-sync.sh` | SessionStart·SessionEnd·UserPromptSubmit·Stop | **동작(원격 동기화)** — 읽기전용 예외 | ✗ | ✓ |
| `force-rules-inject.sh` | UserPromptSubmit | **주입(매 턴 강제원칙 4대)** — `규칙/프로세스/강제규칙-주입.md` 출력, `.claude/` 폴백 | ✗ | ✓ |

## 2. 고아 훅 (plugin.json 미배선, 7)

| 훅 | 의도 트리거 | 성격 | 상태·사유 |
|---|---|---|---|
| `_forge-gate.sh` | (없음) | **헬퍼** | 리마인더 3종이 `source`로 호출하는 게이트 판정 함수. 단독 훅 아님(정상) |
| `commit-message-check.sh` | git commit-msg | 권고 | **보류** — Claude Code에 커밋 시점 이벤트 없음. 배선 방식 결정 대기(H3 사용자 보류) |
| `external-report-check.sh` | PostToolUse(추정) | 권고 | 미배선 — 배선 여부 검토 필요 |
| `memory-rule-content-block.sh` | PreToolUse | **차단(exit 2)** | 미배선 — 학습 강제 차단 훅. 배선·opt-out 정책 결정 대기 |
| `v2-version-bump-block.sh` | PreToolUse | **차단(exit 2)** | 미배선 — 학습 강제 차단 훅. 배선·opt-out 정책 결정 대기 |
| `simple-approval-md-block.sh` | PreToolUse | 권고(이름과 달리 exit 2 없음) | 미배선 — 배선 여부 검토 필요 |
| `umbrella-vocab-block.sh` | PreToolUse | 권고(이름과 달리 exit 2 없음) | 미배선 — 배선 여부 검토 필요 |

## 3. 요약

- **실제 차단(exit 2) = `db-migration-guard` 1개만 작동** — 나머지 차단 훅 2개(memory-rule-content-block·v2-version-bump-block)는 고아(미작동).
- **게이트(H3) = 리마인더 3종**(브리지 켠 개발 폴더/​`FORGE_DEV_HOOKS`에서만).
- **`set -euo pipefail` 보유 = 12/21** — 미보유 9건은 [플러그인-자체-개발표준 §6](../../../../../Workspace/douzone-forge/규칙/프로세스/플러그인-자체-개발표준.md) 권고(보강은 훅별 `set -u` 테스트 후, Phase C 보류).
- **메타 헤더 형식 2종 혼재**(`# Trigger:` vs `Phase Q/R`) — 표준 §6 단일 형식(`# Trigger`·`# Tools`·`# Purpose`·`# SSoT`)으로 점진 통일 대상.

<!-- auto: 자비스 2026-06-23 — HOOKS.md 신설(스트림 4 Phase C 저위험). 21 훅 실측 분류: 배선 14·고아 7, 차단 작동 1(db-guard)·고아 차단 2, 게이트 3, set -e 12/21. -->
