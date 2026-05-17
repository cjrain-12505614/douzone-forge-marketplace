---
name: a10-decision-tracker
description: >
  This skill should be used when the user says "결정사항 기록해",
  "의사결정 추가", "D-XX 확정", "미결 사항 뭐 있어",
  "컨펌 받을 거 정리해줘", "의사결정 로그 보여줘",
  or when recording, reviewing, or requesting project decisions.
  Tracks all project decisions with severity levels and approval status.
version: 0.2.0
---

# Decision Tracker

douzone-forge 프로젝트의 의사결정을 기록·조회·관리한다.

## douzone-forge 의사결정 저장 위치

douzone-forge는 중앙 decision_log.md를 사용하지 않는다.
의사결정은 **관련 프로젝트 파일과 CLAUDE.md에 분산 저장**한다.

| 의사결정 범위 | 저장 위치 |
|-------------|---------|
| 프로젝트 특정 | `projects/PRJ-*.md`의 `01. D. 이슈 & 리스크` + `03. 상세 진행현황` |
| 모듈 공통 | 해당 모듈 `module-overview.md` 또는 `tasks/_current.md` |
| 크로스 모듈 / 전체 | douzone-forge `CLAUDE.md` |
| 기술 결정 | 해당 모듈 `context/_tech-reference.md` |

## 의사결정 등급

| 등급 | 의미 | 결정자 | 예시 |
|------|------|--------|------|
| 🔴 | PM 컨펌 필수 | PM (차민수) | 전략 방향, 기능 범위, 우선순위, 일정 변경 |
| 🟡 | 판단 후 사후 보고 | 설계 리더 / 개발 리더 | 기술 선택, 산출물 형식 |
| 🟢 | 실무자 자율 | 담당자 | 구현 방법, 문서 구조 |

## 의사결정 기록 절차

### 새 결정 기록 시
1. 관련 프로젝트 파일 `projects/PRJ-*.md`를 찾는다.
2. 해당 PRJ의 `03. 상세 진행현황`에 날짜와 함께 결정 내용을 기록한다.
3. 중요한 결정이면 `01. D. 이슈 & 리스크`에도 추가한다.
4. 모듈 공통 결정이면 douzone-forge CLAUDE.md에도 기록한다.
5. 영향받는 산출물이 있으면 해당 파일에 결정 사항을 반영한다.

### PM 컨펌 요청 형식

```
PM, 의사결정이 필요한 사항이 있습니다.

**{항목}**
- 배경: {왜 이 결정이 필요한지}
- 선택지:
  A) {선택지 1} — {장단점}
  B) {선택지 2} — {장단점}
- 의견: {추천안과 근거}
- 관련 프로젝트: PRJ-YYYY-NNN
```

### 미결 사항 조회
- `projects/_dashboard.md`에서 리스크가 있는 프로젝트를 확인한다.
- 각 PRJ 파일의 `01. D. 이슈 & 리스크`를 종합한다.

## 마크다운 링크 규칙 (필수)

마크다운 파일 작성·업데이트 시 **모든 경로·파일 참조는 클릭 가능한 상대 링크**로 작성한다.

- 상대 경로는 현재 파일 위치 기준
- 코드블록 안의 폴더 구조 다이어그램은 예외 (링크 불필요)
- 상세 규칙은 douzone-forge CLAUDE.md의 "마크다운 링크 표기 규칙" 섹션 참조
