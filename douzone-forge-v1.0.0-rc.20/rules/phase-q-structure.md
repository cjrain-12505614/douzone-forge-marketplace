---
name: phase-q-structure
description: Phase Q 종착 후 새 구조 강제 — 옛 경로 사용 차단 + 새 경로 SSoT 인용
---

# Phase Q 새 구조 정책 (Phase R R-01 신설)

Phase Q (Q-1·Q-2·Q-3·Q-4) 종착 결과 워크스페이스 폴더 구조가 한글화 + 카테고리 재편됨. 본 정책은 옛 경로 사용 시도를 자동 차단하여 새 구조 정착을 강제.

## 차단 대상 옛 경로 패턴 (총 11)

| # | 옛 경로 | → 새 경로 | Phase Q 트랙 |
|---|---------|----------|------------|
| 1 | `_CLAUDE/` | `규칙/` | Q-1 Q-04 |
| 2 | `_projects/` | `프로젝트/` | Q-1 Q-08 |
| 3 | `reference/` | `참고자료/` | Q-1 Q-05 |
| 4 | `modules/` | `Amaranth10/` | Q-1 Q-06 |
| 5 | `deliverables/` | (분배 폐기 — `_개인/` 또는 PRJ) | Q-2 Q-13 |
| 6 | `meta/repo-check/` | `GitCheck/` | Q-1 Q-05 |
| 7 | `meta/reports/` | `참고자료/리포트/` | Q-1 Q-05 |
| 8 | `meta/sessions/` | `_개인/sessions/공통/` | Q-1 Q-05 |
| 9 | 모듈 한글명 단독 prefix (`통합연락처(AB)/history/` 등) | `Amaranth10/통합연락처(AB)/history/` | Q-1 Q-06 |
| 10 | `문서/01_신규/`·`02_삭제가능/`·`03_장기참조/` | `Amaranth10/{모듈}/_분석문서/` | Q-1 Q-07 |
| 11 | `team-tracking/` (공용) | `_개인/팀트래킹/` (개인 영역) | Q-2 Q-14 |

## Hook 동작

`hooks/structure-awareness.sh` (PreToolUse Write/Edit):
- 옛 경로 패턴 매칭 시 stderr 경고 (차단 아님 — 작성자 자율 정정)
- archive·.bak 영역은 보호 (역사 보존)

## 새 경로 SSoT 인용

- [`규칙/프로세스/Forge-초기화-가이드.md`](../../../douzone-forge/규칙/프로세스/Forge-초기화-가이드.md) (Q-4 Q-18) — 7단계 사용자 환경 셋업
- [`규칙/프로세스/Forge-GitLab-운영가이드.md`](../../../douzone-forge/규칙/프로세스/Forge-GitLab-운영가이드.md) — GitLab 레포 정보·user.name·배포

## 적용 범위

- 사용자 워크스페이스 (`douzone-forge`) 내 신규 .md·기타 파일
- archive·99_archive·.bak.* 영역은 보호 (히스토리 기록)

## 변천사

- Phase R R-01 (2026-04-27) — 본 정책 신설 (Phase Q 4 사이클 종착 직후)
