# 훅 인벤토리·분류표 (HOOKS.md)

> douzone-forge 플러그인 훅 22개의 트리거·배선·성격·게이트 분류. 표준: `규칙/프로세스/플러그인-자체-개발표준.md`(forge) §6·§9. 갱신: 2026-08-13 실측(link-integrity-scan 신설).
>
> 용어: 배선(plugin.json에 등록되어 실제 작동) · 고아(orphan, 미배선) · 차단(exit 2 — 작업을 막음) · 권고(exit 0 + stderr 경고) · 게이트(`_forge-gate.sh` — 브리지/env에서만 작동) · 헬퍼(다른 훅이 source로 불러 쓰는 보조)

## 1. 배선된 훅 (plugin.json 등록 = 실제 작동, 22)

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
| `link-integrity-scan.sh` | **SessionStart(startup·resume)** | 권고 — 전수 스캔, **증가분만** 보고 | ✗ | — | (v1.21.0 신설. 짝 훅이 단건만 보는 사각 보완. 끄기 `DZ_LINKSCAN=0`) |
| `oneffice-html-facts-check.sh` | PostToolUse(Write/Edit) | 권고 — HTML→원피스 주입용 .html에 "확인 필요"·"자비스" 패턴 검출 | ✗ | ✓ | (v1.12.3 신설) |
| `dz-gitlab-sync.sh` | SessionStart·SessionEnd·UserPromptSubmit·Stop | **동작(원격 동기화)** — 읽기전용 예외 | ✗ | ✓ |
| `force-rules-inject.sh` | UserPromptSubmit | **주입(매 턴 강제원칙 4대)** — `규칙/프로세스/강제규칙-주입.md` 출력, `.claude/` 폴백 | ✗ | ✓ |
| `progress-dashboard-remind.sh` | UserPromptSubmit | **주입(매 턴 대시보드 발동 환기 1줄)** — 기본 문구 내장, `규칙/프로세스/진행대시보드-환기.md` 존재 시 우선 | ✗ | ✓ | (v1.13.0 신설) |
| `simple-approval-md-block.sh` | PreToolUse(Write/Edit) | 권고 — 검토의견/검토결과 .md 단순 결재 경고 | ✗ | — | (v1.12.0 배선) |
| `umbrella-vocab-block.sh` | PreToolUse(Write/Edit) | 권고 — "우산 X" → "마스터 X" 어휘 | ✗ | — | (v1.12.0 배선) |
| `memory-rule-content-block.sh` | PreToolUse(Write) | **차단(exit 2)** — 메모리 룰성 본문(화이트리스트 통과) | ✗ | — | (v1.12.0 배선) |
| `v2-version-bump-block.sh` | PreToolUse(Write) | **차단(exit 2)** — v2 계획서 신규(archive·변천사·Edit 예외) | ✗ | — | (v1.12.0 배선) |

## 2. 미배선 훅 (plugin.json 미등록, 4 — 헬퍼 1 + 시험 도구 1 + 구조적 예외 2)

| 훅 | 의도 트리거 | 성격 | 상태·사유 |
|---|---|---|---|
| `_forge-gate.sh` | (없음) | **헬퍼** | 리마인더 3종이 `source`로 호출하는 게이트 판정 함수. 단독 훅 아님(정상) |
| `_selftest.sh` | (수동 실행) | 시험 도구 | **구조적 예외** — 훅 회귀 시험기(v1.19.0 신설). 이벤트에 배선하지 않는 것이 정상이며, 배포 전 `bash hooks/_selftest.sh` 로 사람이 돌린다(플러그인-자체-개발표준 §10 게이트) |
| `commit-message-check.sh` | git commit-msg | 권고 | **구조적 예외** — Claude Code에 커밋 시점 이벤트 없음(배선 불가). 커밋 규약은 CLAUDE.md + 깃-커밋-메시지-규약.md(SSoT)가 안내 (룰 13종엔 커밋 규약 없음 — 2026-07-10 재검증 R11 교정) |
| `external-report-check.sh` | (스킬 보조) | 권고 | **구조적 예외** — 평문 stdin 검사기(훅 JSON 미준수·경로 필터 없음 → 배선 시 전 내부 .md 오발). dz-external-report 스킬이 참조 |

## 3. 요약

- **실제 차단(exit 2) = 3개 작동** — `db-migration-guard`(파괴적 SQL) + `memory-rule-content-block`(메모리 룰성 본문) + `v2-version-bump-block`(v2 계획서). 뒤 2개는 v1.12.0 배선(2026-07-03, 차민수 결정 — 격리 테스트 통과).
- **게이트(H3) = 리마인더 3종**(브리지 켠 개발 폴더/​`FORGE_DEV_HOOKS`에서만).
- **`set -euo pipefail` 보유 = 12/21** — 미보유 9건은 플러그인-자체-개발표준 §6 `규칙/프로세스/플러그인-자체-개발표준.md`(forge) 권고(보강은 훅별 `set -u` 테스트 후, Phase C 보류).
- **메타 헤더 형식 2종 혼재**(`# Trigger:` vs `Phase Q/R`) — 표준 §6 단일 형식(`# Trigger`·`# Tools`·`# Purpose`·`# SSoT`)으로 점진 통일 대상.

<!-- auto: 자비스 2026-06-23 — HOOKS.md 신설(스트림 4 Phase C 저위험). 21 훅 실측 분류: 배선 14·고아 7, 차단 작동 1(db-guard)·고아 차단 2, 게이트 3, set -e 12/21. -->

## 4. 고아 훅 6종 판정 (2026-07-02 — 사용자 가이드 재점검 §6-E 후속)

- **판정: 6종 전건 등록 누락(결함) 아님 — 문서화된 의도적 보류/구조적 비배선.** 실측 근거: 전 git 이력에서 등록 파일(plugin.json 인라인·hooks/hooks.json) 등재 0건(`git log -S` 6종 전건) + 워크스페이스/사용자 settings 배선 0건 — "배선됐다가 탈락"한 이력 자체가 없음.
- **구조적 배선 불가 2종**: `commit-message-check.sh`(Claude Code에 커밋 시점 이벤트 부재 + 평문 stdin 검사기)·`external-report-check.sh`(평문 stdin 검사기 — 훅 JSON 프로토콜 미준수, dz-external-report 스킬의 보조 검사기로 참조됨). 배선하려면 프로토콜 개조 필요.
- **정책 결정 대기 4종**(v1.0.0-rc.2 V-07-01 학습 강제 메커니즘 신설분): 차단 2(`memory-rule-content-block`·`v2-version-bump-block`)·경고 2(`simple-approval-md-block`·`umbrella-vocab-block`). rc.2 CHANGELOG의 "경고/차단 강제 발효" 기록은 실제로는 미발효였음(배선 누락 — 변천사 보존, 정정은 본 절로 갈음). 동반 룰 4종(single-approval-policy·no-v2-rebump·master-vocab·memory-scope)은 배포·활성 상태라 정책 자체는 룰 계층에서 작동 중이며, 훅 계층 강제(전 임직원 대상)만 관리자 결정 대기.
- 6종 각 스크립트 헤더에 동일 사유 주석 명기(2026-07-02). 상세 진단: douzone-forge `참고자료/리포트/2026-07-02-플러그인-위생이슈-3건-진단.md`
- **2026-07-03 후속 결정(차민수 수석 — 가이드 재점검 트랙 E)**: 정책 결정 대기 4종을 **배선**(경고 2 즉시 + 차단 2 격리 테스트 통과 후, v1.12.0). 구조적 배선 불가 2종(commit-message-check·external-report-check)은 예외 확정. 결과: 배선 15→19, 고아 7→3(헬퍼 1 + 예외 2)

<!-- auto: 자비스(차민수 세션) 2026-07-02 — 고아 훅 6종 판정 누적 -->

## 5. progress-dashboard-remind 신설 (2026-07-09, v1.13.0 — 차민수 결정 2안)

- **배경**: 진행 대시보드 3중 상시 인지의 셋째 다리(매 입력 환기)가 v1.3.0 당시 워크스페이스 로컬(`.claude/진행대시보드-환기.md` + settings.json 두 번째 cat)로만 구현 → `.gitignore`의 `.claude/` 전체 제외로 동기화·이력 없이 조용히 소실, 대시보드 상시 미발동 (진단: douzone-forge `참고자료/리포트/2026-07-09-진행대시보드-환기훅-소실-진단.md`)
- **조치**: force-rules-inject 패턴으로 플러그인 정식 훅 승격(UserPromptSubmit) + **기본 문구 스크립트 내장**(외부 파일 부재 시에도 침묵 불가 — 소실 재발 구조적 방지). `규칙/프로세스/진행대시보드-환기.md` 존재 시 그 내용 우선(재배포 없이 문구 갱신 전파)
- **격리 테스트 4종 통과**: 기본 문구 출력 · override 우선 · `CLAUDE_PROJECT_DIR` 미설정 set -u 내성 · 실워크스페이스 — 전건 exit 0
- 결과: 배선 20→21 (고아 3 불변 — 헬퍼 1 + 구조적 예외 2)

<!-- auto: 자비스(차민수 세션) 2026-07-09 — v1.13.0 훅 신설 누적 -->
