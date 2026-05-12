---
name: a10-folder-audit
description: >
  This skill should be used when the user asks to "폴더 점검", "_README 점검",
  "폴더 표준 검증", "audit", or 정기 점검 시점.
  워크스페이스 모든 폴더를 순회하여 _README.md 부재 + placeholder 식별 +
  명시 목적과 실제 콘텐츠 불일치 리포트 생성.
version: 0.1.0
---

# 폴더 점검 (a10-folder-audit)

워크스페이스 모든 폴더 표준 검증 + 부재·placeholder _README.md 자동 식별.

## 점검 항목

| # | 항목 | 검증 |
|---|------|------|
| 1 | _README.md 존재 | `ls $DIR/_README.md` |
| 2 | 5 섹션 충족 | 목적·소유자·콘텐츠 분류·신규 추가 규칙·관련 폴더 |
| 3 | placeholder 식별 | "**본 _README는 Phase Q-2 자동 추론 placeholder**" 메타 표기 grep |
| 4 | 명시 목적과 실제 파일 종류 일치 | 본문 분류 키워드 vs ls 결과 비교 (수동 판정) |

## 화이트리스트 (점검 제외)

- `_archive/`·`99_archive/` (보존 영역)
- `.git/`·`node_modules/` (시스템)
- `dist/` (빌드 산출)
- `*.bak.*` (백업)

## 출력 위치

`참고자료/리포트/folder-audit-{YYYYMMDD}.md`

## 출력 형식

```markdown
# 폴더 점검 리포트 — YYYY-MM-DD

## 1. 부재 _README.md (즉시 신설 권고)
- {폴더 경로}
- ...

## 2. Placeholder _README.md (정밀화 권고)
- {폴더 경로} — Phase Q-2 자동 추론, 후속 정밀화 대기
- ...

## 3. 5 섹션 미충족 _README.md
- {폴더 경로} — 누락 섹션: {목적·소유자·...}

## 4. 점검 통과
- {폴더 경로}
- ...

## 합계
- 부재: N건
- Placeholder: N건
- 미충족: N건
- 통과: N건 / 전체 N건 (커버리지 N%)
```

## 실행 흐름

1. 워크스페이스 루트에서 `find . -type d` (화이트리스트 제외)
2. 각 폴더 _README.md 검증 4 항목
3. 리포트 .md 생성

## 사용 시점

- 정기 점검 (주간 권장, 또는 사용자 결정)
- Q-2 종착 직후 placeholder 식별 + 정밀화 대기 리스트
- 신규 폴더 다수 추가 후 일괄 검증

## 관련 자산

- `hooks/folder-purpose-check.sh` (G11) — 신규 폴더 _README 부재 경고
- `rules/prj-filename-policy.md` (Q-10) — 산출물 파일명 표준

## 변천사

- Phase Q-2 Q-11 (2026-04-27) — 본 스킬 신설 (G11 5섹션 표준 + audit)
