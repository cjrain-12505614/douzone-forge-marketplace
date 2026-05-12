---
name: a10-load-history
description: "개발 히스토리/요구사항 이력 로드"
---

`$ARGUMENTS`에 해당하는 개발 히스토리 파일을 읽어 현재 대화 맥락으로 로드한다.

## 로드 순서

**1단계 — 항상 로드**
`{모듈명}/history/_timeline.md` 읽기

**2단계 — 특정 차수가 지정된 경우**
`{모듈명}/history/phase-N.md` 읽기
예: `modules/법무관리(LTE)/phase-2` → `modules/법무관리(LTE)/history/phase-2.md`

**3단계 — 고객 요구사항 이력이 지정된 경우**
`{모듈명}/history/requests/` 아래 해당 파일 읽기
예: `modules/법무관리(LTE)/requests/가온` → 파일명에 "가온"이 포함된 파일 탐색 후 읽기

## 인수가 없는 경우

`$ARGUMENTS`가 비어 있으면 현재 컨텍스트에서 모듈명을 추론하고
`_timeline.md`만 로드한다. 모듈명도 불분명하면 사용자에게 질문한다.

## 로드 완료 후 출력

읽은 파일과 핵심 내용을 간략히 요약한다.
예: "법무관리 히스토리 로드 완료. 3차 개발까지 진행됨. 가온 요구사항은 2026-03 반영. 현재 4차 개발 준비 중."

파일이 없으면 `templates/history/` 템플릿으로 생성할 수 있다고 안내한다.
