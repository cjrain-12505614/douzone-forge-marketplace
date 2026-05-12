---
name: personal-area-guard
description: _개인/ 영역 GitLab 동기화 차단 + 사용자 안내. 공용/개인 경계 정책 강제.
paths: ["**/_개인/**", "**/.gitignore"]
---

# Personal Area Guard Rule

## 정책

`_개인/` 하위의 모든 파일과 폴더는 **GitLab 중앙 동기화 대상이 아닙니다**.

ST Step 1.5 + 02-Bfix 결정으로 워크스페이스는 **공용/개인 경계** 가 명확히 구분됩니다:
- **공용** (GitLab 중앙): `modules/`·`projects/`·`reference/`·`deliverables/`·`meta/`·`조직/`·`team-tracking/`
- **개인** (로컬 only): `_개인/` — 각 사용자 로컬에 본인 영역만 존재

본 Rule은 Claude가 작업 중 `_개인/` 하위 파일을 git 동기화 흐름(예: `git add`·`git commit -A`)에 포함시키지 않도록 강제합니다.

## 위반 시 행동

### Claude 측 자체 차단

`_개인/` 하위 파일을 git 동기화 명령에 포함하기 전에 다음을 검증:
1. 대상 경로가 `_개인/` 으로 시작하는가? → **차단**
2. `git add .` / `git add -A` 등 광범위 명령에 `_개인/` 이 포함되는가? → **차단** + 명시적 제외 권고
3. `.gitignore` 에 `_개인/` 라인이 있는가? → 없으면 **자동 추가 권고**

### 사용자 안내 메시지 (표준)

```
⚠️ `_개인/` 영역은 GitLab 동기화 대상이 아닙니다 (ST Step 1.5 결정).

대안:
1. 공유가 필요한 진행 보고 → `조직/{...}/{이름_사번}/daily,weekly,monthly/`
2. 관리자 트래킹 → `team-tracking/{관리자}/{대상}/`
3. 임시 메모/학습/개인 PRJ → `_개인/` (로컬 보존)

git 명령 실행 전 `.gitignore` 에 `_개인/` 라인 확인 필요.
```

## .gitignore 자동 등록 권고

워크스페이스 루트 `.gitignore` 에 다음 라인 필수:

```
# 개인 영역 — GitLab 동기화 금지 (ST Step 1.5)
_개인/
```

본 Rule이 발화될 때 `.gitignore` 에 위 라인이 없으면 **자동 추가 권고**를 사용자에게 전달합니다.

## 예외

**없음** (Step 1.5 결정 그대로). `_개인/` 하위 모든 파일은 100% 로컬 전용입니다.

`_개인/sessions/` (Step 3.5에서 추가) 도 동일 — Claude 작업 체크포인트가 GitLab으로 누출되지 않도록 보장.

## 관련 문서

- 공용/개인 경계 정책 SSoT: `_CLAUDE/프로세스/공용-개인-경계-규칙.md` (douzone-forge, ST Step 1.5)
- `_개인/_README.md` — `_개인/` 폴더 사용 가이드
- ST Step 1.5 산출 + 02-Bfix 한글 전환 (`_personal/` → `_개인/`) 변천사

## 변천사

- ST Step 1.5 (2026-04-25) — 공용/개인 경계 정립 + `_개인/` 정의
- ST Pre-fix 02-Bfix (2026-04-25) — 한글 폴더 전환
- ST Step 3.5 (2026-04-25) — `_개인/sessions/{모듈}/` 추가
- PT-02 (2026-04-26) — 본 Rule 신설로 정책 강제 (G7)

## Hook 강화 후보 (v0.14.x patch — F-PT-Nx12)

본 Rule은 Claude 자체 판단 의존. 향후 강화: PreToolUse Bash Hook에서 `git add _개인/` 패턴 검출 시 즉시 차단 (F-PT-Nx12, PT-03 정합 검증 후 또는 v0.14.x patch에서 검토).
