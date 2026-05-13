---
name: a10-cascade-from-report
description: >
  This skill should be used when the user asks to "일일보고", "주간보고", "월간보고",
  "업무보고 작성", "업무보고 체크해줘", or 보고서 작성 시 조직 → 프로젝트 → 모듈 자동 cascade.
  4건 cascade + Phase S 4건 룰 통합 (Step 0 휴가자 인지 / Step 2.5 헤더 표준 /
  Step 3.5 재귀(depth 2) + 댓글 동시 추출). SBUnit 한정 표현 0.
  의존: 규칙/프로세스/업무보고-체크-운영규칙.md (Phase S S-01 신설 SSoT).
version: 0.2.0
---

# 업무보고 Cascade (a10-cascade-from-report) — Phase R R-04 신설

보고서 작성 시 **조직 → 프로젝트 → 모듈** 흐름으로 자동 cascade. R-02·R-03과 흐름 방향이 다름 (조직 시작점).

## 트리거

description 매칭 (한글 키워드):
- "일일보고"
- "주간보고"
- "월간보고"
- "업무보고 작성"

## Cascade 흐름 (조직 → 프로젝트 → 모듈) + Phase S 4건 룰 통합

### Step 0 — 휴가자 사전 인지 (Phase S S-05 신설, 룰 1)

"업무보고 체크해줘" 명령 직후 **Step 0**:
- 도구: `mcp__apple-events__calendar_events`
- 본인 팀캘린더 lookup → 휴가자 식별 → 보고 체크 대상에서 제외
- 환경: 차민수 PC 한정

### 자동 갱신 4건

#### 1. 본인 조직 `_index.md` 보고 내역
- 위치: `조직/{본부}/{Unit}/{Cell}/{이름_사번}/_index.md`
- 추가: "보고 내역" 섹션 (일자·유형·요약)

#### 2. 보고에 언급된 PRJ `00_overview.md` §03 진행현황 1줄
- 보고 본문 PRJ 키 추출 → 매칭 PRJ 자동 갱신
- 형식: `| YYYY-MM-DD | {보고 유형} {본인 ID}: {PRJ 관련 요약} |`

#### Step 2.5 — 결과 .md 헤더 표준 (Phase S S-05 신설, 룰 2)

ONEFFICE 추출 결과 .md 상단 5줄 frontmatter 의무:
```yaml
---
원본: <ONEFFICE 아마링크>
재귀_추출: depth-N
댓글_추출: 포함/미포함
추출일: YYYY-MM-DD HH:MM
추출자: <ID>
---
```

#### 3. 관련 모듈 `Amaranth10/{모듈}/history/_timeline.md` 1줄
- PRJ 메타 (모듈 매핑) 기반
- 형식: `- YYYY-MM-DD: {요약} ({본인 ID} {보고 유형})`

#### Step 3.5 — 재귀 (depth 2) + 댓글 동시 추출 (Phase S S-05 신설, 룰 3·4)

1차 추출 후 본문 아마링크 재귀 추출 (depth 2 한도) + 댓글 영역 동시 DOM 추출.
- 재귀: 본문 내 추가 아마링크 검출 → 의미 분류 → depth 2까지 자동 (depth 3+ 차민수 명시 시만)
- 댓글: `#TB_COMMENT_PANEL_0` 패널 + 본문 selector (잠정 3 후보) — 상위 의사결정자 cascade 우선순위 ↑
- 의존: `skills/a10-amalink-recursive-extract/` (S-07 신설 — 4건 룰 캡슐화)

#### 4. 본인 `_개인/sessions/{모듈}/_current.md` 체크포인트
- 일일·주간·월간 보고 작성 시점 자동 체크포인트
- 다음 세션 인계용

## 사용 사례

### 일일보고 작성 (4 cascade)
```
입력: 04/27 일일보고 작성 — PRJ-013·014·020 진행
→ (1) 본인 조직/_index.md 보고 내역
→ (2) PRJ-013·014·020 각 00_overview.md (3건 동시)
→ (3) 관련 모듈 history/_timeline.md (공통·법무관리 등)
→ (4) _개인/sessions/공통/_current.md
```

### 주간보고 작성 (4 cascade)
```
입력: 4/22 ~ 4/26 주간보고
→ (1) 본인 조직 보고 내역 (주간 요약)
→ (2) 주간 진행 PRJ 다수 cascade
→ (3) 모듈 timeline
→ (4) 본인 sessions
```

## R-02·R-03과 차이

| 항목 | R-02 (context) | R-03 (prj) | R-04 (report) |
|------|---------------|------------|---------------|
| 트리거 | 업무 맥락 (회의록·결정) | PRJ 문서 변경 | 보고서 작성 |
| 흐름 | 프로젝트 → 모듈 → 조직 | 프로젝트 → 모듈 → 조직 | **조직 → 프로젝트 → 모듈** |
| 갱신 건수 | 5 | 4 | 4 |
| 시작점 | PRJ | PRJ | 본인 조직 |

## 의존 자산

- `규칙/프로세스/사용자ID-매핑.md`
- `규칙/프로세스/업무보고-체크-운영규칙.md` (Phase S S-01 신설 SSoT — 4건 룰 통합)
- `규칙/프로세스/아마링크-참조링크-운영규칙.md` (S-03 보강 — 4건 룰 본문)
- `규칙/프로세스/ONEFFICE-댓글-멘션-플러그인-가이드.md` (S-04 보강 — 댓글 selector)
- `프로젝트/_dashboard.md`
- `skills/a10-cascade-from-context/` (R-02)
- `skills/a10-cascade-from-prj/` (R-03)
- `skills/a10-amalink-recursive-extract/` (Phase S S-07 신설 — 재귀+댓글+헤더 캡슐화)
- `skills/a10-people-context/` (S-07 보강 — 본인 업무현황 lookup)
- `skills/a10-daily-digest/` — 일일보고 캐싱 (3-way 크로스 체크)

## 변천사

- Phase R R-04 (2026-04-27) — 본 스킬 신설 (조직 → 프로젝트 → 모듈 흐름)
- **Phase S S-05 (2026-04-27)** — 4건 룰 통합 (Step 0 휴가자 / Step 2.5 헤더 / Step 3.5 재귀+댓글) + version 0.1.0 → 0.2.0
