---
name: a10-status-reporter
description: >
  This skill should be used when the user asks "현황 알려줘",
  "지금 어디까지 했어", "진행 상황 보여줘", "Phase 몇이야",
  "산출물 목록", "다음에 뭐 해야 해", "전체 현황 정리해줘",
  or when a project status summary is needed.
  Generates project status reports from dashboard, project files, and module sessions.
version: 0.2.0
---

# Status Reporter

douzone-forge 프로젝트 현황을 종합하여 보고한다.
douzone-forge는 모듈별 분산 구조를 사용하므로, 프로젝트 대시보드와 각 모듈 파일을 교차 조회한다.

## 현황 보고 절차

아래 파일들을 순서대로 읽고 종합한다:

1. `projects/_dashboard.md` — 전체 프로젝트 포트폴리오 (진행률, 상태, 리스크)
2. 진행 중 프로젝트의 `projects/PRJ-*.md` — TASK 목록, 상세 진행현황, 이슈
3. 각 모듈의 `_개인/sessions/{모듈}/_current.md` — 최근 세션에서 남은 작업
4. 각 모듈의 `tasks/_current.md` — 현재 업무 목록
5. 각 모듈의 `module-overview.md` — context 파일 현황, 소스 레포 정보

## 보고 형식

```
## 프로젝트 현황 보고

**진행 중 프로젝트**: N건 (리스크 M건)
**담당 모듈**: 법무관리, CRM, 게시판, 업무관리(KISS), 통합연락처

### 프로젝트별 진행률

| PRJ ID | 프로젝트명 | 모듈 | 기간 | 진행률 | 상태 | 리스크 |
|--------|----------|------|------|--------|------|--------|

### 모듈별 업무 현황

| 모듈 | 진행 중 업무 수 | context 파일 수 | 최근 세션 | 남은 작업 |
|------|--------------|---------------|----------|----------|

### 미결 이슈 & 리스크
- PRJ-YYYY-NNN: {이슈 내용}

### 즉시 해야 할 것 (다음 TODO)
1. (우선순위 순 — sessions/_current.md의 남은 작업 + tasks/_current.md 기반)
```

## 특정 모듈 상세 보고

사용자가 특정 모듈을 지정하면 더 상세한 정보를 제공한다:

1. `module-overview.md` — GNB 목록, 라이선스, context 인덱스
2. `tasks/_current.md` — 진행 중/예정/완료 업무 상세
3. `_개인/sessions/{모듈}/_current.md` — 최근 세션 상황
4. `context/_tech-reference.md` — 기술 참조 요약
5. `history/_timeline.md` — 개발 이력 요약

## 특정 프로젝트 상세 보고

사용자가 PRJ ID를 지정하면:

1. `projects/PRJ-*.md`의 01. 프로젝트 개요 → 현재 상태 요약
2. 02. TASK 목록 → 미완료 TASK 강조
3. 03. 상세 진행현황 → 최근 3일 로그 요약
4. 04. 연결 정보 → 관련 모듈 context, history, Google Sheets 링크
5. 이슈·리스크 요약

## 산출물 인벤토리

전체 모듈을 스캔하여 산출물 목록을 생성할 때:
- 모듈별 context 파일 수
- 모듈별 문서(설계서) 수 (문서/INDEX.md 기준)
- 프로젝트별 TASK 완료율
- 세션 로그 최신 날짜

## 마크다운 링크 규칙 (필수)

마크다운 파일 작성·업데이트 시 **모든 경로·파일 참조는 클릭 가능한 상대 링크**로 작성한다.

```markdown
# 나쁜 예 (클릭 불가)
법무관리/tasks/_current.md에서 확인

# 좋은 예 (클릭 가능)
[법무관리/tasks/_current.md](../법무관리/tasks/_current.md)에서 확인
```

- 상대 경로는 현재 파일 위치 기준
- 코드블록 안의 폴더 구조 다이어그램은 예외 (링크 불필요)
- 상세 규칙은 douzone-forge CLAUDE.md의 "마크다운 링크 표기 규칙" 섹션 참조
