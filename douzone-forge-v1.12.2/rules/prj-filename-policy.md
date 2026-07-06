---
name: prj-filename-policy
description: 산출물 파일명 표준 강제 — YYYYMMDD-{주제}.{확장자} (8자리)
---

# 산출물 파일명 표준 정책

## 적용 범위

다음 경로 하위 신규 .md 파일 (Hook PostToolUse Write/Edit 시 자동 검증):

- `프로젝트/PRJ-*/01_기획/`·`02_설계/`·`03_개발/`·`04_미팅/`·`05_산출물/`·`06_의사결정/`
- `Amaranth10/{모듈}/history/`·`tasks/`·`_분석문서/`
- `참고자료/`·`_개인/` 산출물

## 표준

- 파일명: **`YYYYMMDD-{주제}.{확장자}`** (8자리 강제)
- 6자리 YYMMDD 혼용 금지
- 주제는 한글 또는 영문 — 공백 대신 `-` 또는 `_`
- 예: `20260427-PhaseQ2-계획서.md`·`20260420-가온-MCP-설계.md`

## 예외 (메타 화이트리스트)

다음 파일은 표준 적용 제외:

| 메타 파일 | 사유 |
|----------|------|
| `_README.md`·`_index.md`·`_dashboard.md` | 폴더 메타 — 자체 명명 규칙 |
| `00_overview.md` | PRJ 표준 골격 |
| `CHANGELOG.md` | 변경 이력 |
| `.gitignore`·`.bak.*` | 시스템 파일 |

## Hook 동작

`hooks/prj-filename-policy.sh` (PostToolUse Write/Edit):
- 신규 .md 파일이 적용 범위 내 + 메타 화이트리스트 외이면 `^[0-9]{8}-` 패턴 검증
- 위배 시 stderr 경고 (차단 아님 — 작성자 자율 정정 유도)

## 변천사

- Phase Q-2 Q-10 (2026-04-27) — 본 정책 신설
