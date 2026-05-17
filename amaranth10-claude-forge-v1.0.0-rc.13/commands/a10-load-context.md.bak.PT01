---
name: a10-load-context
description: "모듈/GNB/LNB 컨텍스트 로드"
---

아래 순서로 컨텍스트 파일을 읽어 현재 대화의 맥락으로 로드한다.

## 로드 순서

**1단계 — 항상 로드 (필수)**
- `$ARGUMENTS` 경로의 상위 모듈 디렉토리에서 `module-overview.md` 읽기
- 같은 위치의 `conventions.md` 읽기

**2단계 — GNB가 지정된 경우**
- 해당 GNB 디렉토리의 `_overview.md` 읽기

**3단계 — LNB가 지정된 경우**
- 해당 LNB의 `.md` 파일 읽기

## 인수 파싱 규칙

- `법무관리` → 모듈 overview + conventions만 로드
- `법무관리/소송관리` → 위 + 소송관리/_overview.md 로드
- `법무관리/소송관리/소송등록` → 위 + 소송관리/소송등록.md 로드

## 파일 경로 탐색

파일이 현재 작업 디렉토리 기준으로 없으면 아래 위치를 순서대로 탐색한다.
1. `./context/$ARGUMENTS`
2. `./$ARGUMENTS`
3. `~/amaranth10-claude-forge-data/$ARGUMENTS`

## 로드 완료 후 출력

읽은 파일 목록을 간략히 나열하고, 로드된 컨텍스트를 한 줄로 요약한다.
예: "법무관리 > 소송관리 > 소송등록 컨텍스트가 로드되었습니다. 현재 구현 상태: 기본 CRUD 완료, 판결 연동 개발 중."

파일이 존재하지 않으면 해당 경로에 파일이 없다고 알리고,
`/feature-spec` 또는 context-manager 스킬로 생성할 수 있다고 안내한다.
