---
name: a10-daily-digest
description: >
  ONEFFICE 일일보고를 수집·파싱하여 `douzone-forge/deliverables/보고서/일일보고/원본캐시/YYYY-MM/YYYYMMDD-{사번}.md`에
  로컬 캐싱한다. 3-way 크로스 체크(검토안↔커밋↔일일보고)의 일일보고 축을 담당.
  "일일보고 긁어줘", "어제 보고 내용 로컬로", "daily-digest 돌려줘" 요청 시 사용.
  원본은 ONEFFICE에 유지하고, Claude 세션은 캐시 복사본을 참조한다(결정 4).
version: 0.1.0
---

# 일일보고 수집·파싱 (Daily Digest)

ONEFFICE 아마링크 일일보고를 로컬 캐시로 복제하여 교차 분석에 사용한다.
원본 편집은 하지 않음 — 읽기·추출 전용.

## 수집 원천

- 아마링크 구조: SBUnit 업무현황 게시판 → 사원별 일일보고 문서
- 경로 인덱스: `douzone-forge/SBUnit-업무현황-아마링크.md` (조직별 링크 테이블)
- 읽기 방식: `a10-oneffice-reader` 스킬 활용 (`innerText` 추출)

## 로컬 캐시 경로

```
douzone-forge/
└── _업무산출물/
    └── 보고서/
        └── 일일보고/
            ├── YYYYMMDD-SBUnit-일일보고-분석.md  ← PM 분석(차민수 관점, 기존 컨벤션)
            └── 원본캐시/
                ├── _index.md                    ← 월별·사원별 수집 현황
                └── YYYY-MM/
                    └── YYYYMMDD-{사번}.md        ← 일일보고 1건 = 파일 1개
```

> **참고**: `modules/업무관리(KISS)/` 는 Amaranth 10 **업무관리(KISS) 모듈** 전용 폴더. 모듈 외의
> SBUnit 운영 자산은 모두 `_` 접두사 규칙 폴더(`_업무산출물`, `_참조자료`, `_projects`, `_plugin`)를 사용.

### 캐시 파일 포맷

```markdown
---
date: 2026-04-20
employee_id: "2505614"
name: 최현복
team: SBUnit
source_url: https://gwa.douzone.com/ecm/oneffice/...
captured_at: 2026-04-20T09:15:00+09:00
jira_keys: [CSA10-44921, KLAGOP1-1234]
prj_refs: [PRJ-2026-010]
---

## 오늘 한 일
(innerText 본문)

## 내일 할 일
...

## 이슈
...
```

Frontmatter의 `jira_keys`, `prj_refs` 는 본문 정규식 추출 결과 — 3-way 조인 키.

## 실행 절차

### STEP 1: 수집 범위 결정
- 인수 없음 → 어제 1일치
- `--date YYYY-MM-DD` → 지정일
- `--since YYYY-MM-DD` → 지정일~어제
- `--employee {사번}` → 특정 사원만 (기본 SBUnit 전원)

### STEP 2: 아마링크 목록 해석
`SBUnit-업무현황-아마링크.md` 에서 대상 사원·날짜의 문서 URL을 구한다.
문서명 패턴 미확정 시 사용자에게 확인 요청.

### STEP 3: ONEFFICE 본문 추출
각 문서에 대해 `a10-oneffice-reader` 절차:
- Chrome MCP navigate
- `#open_oneffice_body_iframe → #dzeditor_0 → body.innerText`
- 실패(권한·회수) 시 스킵 + 경고

### STEP 4: 파싱 & Frontmatter 생성
- JIRA 키: `\b(CSA10|UBA|UAC|EO|KLAGOP1|A10D|UCAIMP|BC10)-\d+\b`
- PRJ 키: `\bPRJ-\d{4}-\d{3}\b`
- 섹션 추출: "오늘 한 일", "내일 할 일", "이슈" 헤더 기준 (없으면 본문 그대로)

### STEP 5: 캐시 저장
- 멱등: 같은 `{date}-{사번}` 파일 존재 시 내용 diff 후 갱신만
- 월별 디렉토리 자동 생성
- `_index.md` 테이블 갱신

### STEP 6: 보고
```
📥 Daily Digest 수집 완료 (2026-04-20)
- SBUnit 22명 중 18명 보고 확인
- 4명 미보고: 홍길동, 김철수, ...
- JIRA 키 42건 / PRJ 참조 15건 추출
- 캐시: douzone-forge/_업무산출물/보고서/일일보고/원본캐시/2026-04/ (18 files)
```

## 교차 분석 인터페이스

다른 스킬이 이 캐시를 사용하는 표준 쿼리:

```
# 특정 JIRA 키가 언급된 보고 찾기
grep -r "CSA10-44921" douzone-forge/_업무산출물/보고서/일일보고/원본캐시/

# 특정 사원의 최근 7일 보고
ls douzone-forge/_업무산출물/보고서/일일보고/원본캐시/2026-04/*-2505614.md
```

`a10-triage-status` 커맨드가 이 캐시를 기반으로 3-way 매트릭스를 구축한다.

## `_index.md` 포맷

```markdown
# 일일보고 수집 인덱스

## 2026-04

| 날짜 | 수집 건수 | 미보고 | 마지막 수집 |
|---|---|---|---|
| 2026-04-20 | 18/22 | 홍길동, 김철수, ... | 2026-04-20 09:15 |
| 2026-04-19 | 20/22 | ... | 2026-04-19 22:00 |
```

## 주의

- **원본 수정 금지** — ONEFFICE 문서는 읽기만 수행
- **캐시는 보조 수단** — 정합성 이슈 시 ONEFFICE 원본이 진실
- 사원이 보고를 수정하면 다음 실행 시 자동 갱신됨 (1일 1회 실행 권장)
- 미보고 사원은 경고로만 표기 (결정 4: 자동 독촉 금지)

## 연계 스킬

- `a10-oneffice-reader` — 본문 추출 위임
- `a10-triage-status` — 3-way 크로스 체크에서 이 캐시를 소비
- `a10-git-daily` — JIRA 키·PRJ 참조 교차 매칭
