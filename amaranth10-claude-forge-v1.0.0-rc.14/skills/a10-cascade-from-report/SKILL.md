---
name: a10-cascade-from-report
description: >
  This skill should be used when the user asks to "일일보고", "주간보고", "월간보고",
  "업무보고 작성", "업무보고 체크해줘", "받은보고함", "cascade 적용",
  "Cell 멤버 보고 종합", "5단계 받은보고함 워크플로우", 또는 보고서 작성 시점
  조직 → 프로젝트 → 모듈 자동 cascade. Step 0~5 받은보고함 워크플로우 정착
  (gwa.douzone HP/HPM0220/UHA3020 + popup onefficeContents iframe + cascade ①②③④).
  4건 cascade + Phase S 4건 룰 통합 (Step 0 휴가자 / Step 2.5 헤더 / Step 3.5 재귀+댓글).
  의존: 규칙/프로세스/업무보고-체크-운영규칙.md (Phase S S-01 신설 SSoT) +
  자비스-운영-룰.md §2 학습 #31~#34 (받은보고함 워크플로우·미제출 판단·산출물 viewer·직책 cascade).
version: 2.0.0
---

# 업무보고 Cascade (a10-cascade-from-report) — v2 받은보고함 워크플로우 정착

> Phase R R-04 (2026-04-27) 본 스킬 신설 → Phase S S-05 (2026-04-27) 4건 룰 통합 (v0.2.0) → **v2.0.0 (2026-05-13) 받은보고함 워크플로우 정착 — Step 0~5 + cascade 4건**

본 스킬은 **조직 → 프로젝트 → 모듈** 흐름 자동 cascade. 받은보고함 워크플로우 정착 후 직책 cascade 모델 + cascade ①②③④ 영역 영구 자산화.

---

## 1. 트리거

description 매칭 (한글 키워드):
- "일일보고" · "주간보고" · "월간보고"
- "업무보고 작성" · "업무보고 체크해줘"
- "받은보고함" · "cascade 적용"
- "Cell 멤버 보고 종합"
- "5단계 받은보고함 워크플로우"

---

## 2. Step 0~5 받은보고함 워크플로우 (v2 신설)

5/13 시범 세션 정착 영역. 자비스 운영 룰 §2 학습 #31~#34 일관 — 인계서 §4 결정적 발견 9건 (A·B·D·E·F) 영구 자산화.

### Step 0 — 사용자 식별 + 조직도 lookup

- 자비스 메모리 `user_role_org.md` + 사용자ID-매핑 SSoT lookup → 직책 자동 산정 → 휘하 N명 확정 → N=0이면 워크플로우 비활성
- 직책 cascade 모델 (학습 #34 인용):
  - Cell 리더: 본인 Cell 멤버 N명 보고
  - Unit장: Cell 리더 4명 보고 (멤버 미제출 = Cell 리더 책임)
  - 본부장: Unit장 보고
  - 사장: 본부장 보고
  - 멤버: 자기 직접 활동 보고만

### Step 1 — 받은보고함 navigate

- URL: `https://gwa.douzone.com/#/HP/HPM0220/UHA3020`
- 모듈코드 HP — 임직원업무관리 > 마이페이지 > 업무보고 > 받은보고함
- 자비스 운영 룰 학습 #31 인용 — popupUUID 영속성 부재 + listing Canvas 영역

### Step 2 — 멤버별 검색·링크복사 6 단계 사이클

각 휘하 멤버별 반복:
- ① navigate + wait 5~6초
- ② JS로 검색 input 보고자 이름 set + Enter + wait 3~4초
- ③ 첫 row 체크박스 click
- ④ 링크복사 버튼 click
- ⑤ JS clipboard.readText() → popup URL
- ⑥ JS location.href = url

미제출자 판단 정확 (학습 #32 인용):
- listing 한 시점만으로 미제출자 판단 금지
- 활성 인원 한 명씩 보고자 검색해서 본일 entry 존재 여부 검증
- listing 정렬 = "최근 갱신/수신 순" (보고일자 desc 아님)

### Step 3 — popup 본문 + 산출물 link 추출

- iframe ID: **`onefficeContents`** (일반 ONEFFICE viewer의 `open_oneffice_body_iframe → dzeditor_0` 패턴과 다름 — 학습 #31 인용)
- 산출물 link 분류:
  - ONEFFICE doc (`/ecm/oneffice/one003A06?{base64-seq}`): ✅ 본문 추출 가능
  - ONECHAMBER PDF·HTML (`/ecm/onechamber/?token=...`): ❌ 이미지 변환 — 메타만 (학습 #33 인용)

### Step 4 — depth 2 산출물 본문 추출 (선택)

- ONEFFICE 산출물 가능 (`open_oneffice_body_iframe → dzeditor_0`)
- ONECHAMBER PDF·HTML 한계 (이미지 변환 — 제목·작성자·작성일 메타만)
- 사용자 명시 시에만 진입

### Step 5 — cascade ①②③④ 적용

- ① `조직/{본부}/{Cell}/{이름_사번}/daily/{YYYY-MM-DD}.md` — 본인 일일/주간/월간 보고 본문
- ② `Amaranth10/{모듈}/history/_timeline.md` — 모듈 timeline 1줄
- ③ `프로젝트/PRJ-*.md` "03. 상세 진행현황" — PRJ 진행 영역
- ④ `Workspace_a10` git log cross-check — 커밋 메시지 정합 검증

---

## 3. 자동 갱신 4건 (기존 본문 보존)

### 1. 본인 조직 `_index.md` 보고 내역
- 위치: `조직/{본부}/{Unit}/{Cell}/{이름_사번}/_index.md`
- 추가: "보고 내역" 섹션 (일자·유형·요약)

### 2. 보고에 언급된 PRJ `00_overview.md` §03 진행현황 1줄
- 보고 본문 PRJ 키 추출 → 매칭 PRJ 자동 갱신
- 형식: `| YYYY-MM-DD | {보고 유형} {본인 ID}: {PRJ 관련 요약} |`

### 3. 관련 모듈 `Amaranth10/{모듈}/history/_timeline.md` 1줄
- PRJ 메타 (모듈 매핑) 기반
- 형식: `- YYYY-MM-DD: {요약} ({본인 ID} {보고 유형})`

### 4. 본인 `_개인/sessions/{모듈}/_current.md` 체크포인트
- 일일·주간·월간 보고 작성 시점 자동 체크포인트
- 다음 세션 인계용

---

## 4. Phase S 4건 룰 통합 (v0.2.0 본문 보존)

### Step 0 — 휴가자 사전 인지 (룰 1)

"업무보고 체크해줘" 명령 직후:
- 도구: `mcp__apple-events__calendar_events`
- 본인 팀캘린더 lookup → 휴가자 식별 → 보고 체크 대상에서 제외
- 환경: {이름} PC 한정

### Step 2.5 — 결과 .md 헤더 표준 (룰 2)

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

### Step 3.5 — 재귀 (depth 2) + 댓글 동시 추출 (룰 3·4)

1차 추출 후 본문 아마링크 재귀 추출 (depth 2 한도) + 댓글 영역 동시 DOM 추출.
- 재귀: 본문 내 추가 아마링크 검출 → 의미 분류 → depth 2까지 자동 (depth 3+ {이름} 명시 시만)
- 댓글: `#TB_COMMENT_PANEL_0` 패널 + 본문 selector (잠정 3 후보) — 상위 의사결정자 cascade 우선순위 ↑
- 의존: `skills/a10-amalink-recursive-extract/` (S-07 신설 — 4건 룰 캡슐화)

---

## 5. 사용 사례 (기존 본문 보존)

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

---

## 6. R-02·R-03과 차이 (기존 본문 보존)

| 항목 | R-02 (context) | R-03 (prj) | R-04 (report) |
|------|---------------|------------|---------------|
| 트리거 | 업무 맥락 (회의록·결정) | PRJ 문서 변경 | 보고서 작성 |
| 흐름 | 프로젝트 → 모듈 → 조직 | 프로젝트 → 모듈 → 조직 | **조직 → 프로젝트 → 모듈** |
| 갱신 건수 | 5 | 4 | 4 |
| 시작점 | PRJ | PRJ | 본인 조직 |

---

## 7. 의존 자산

- `규칙/프로세스/사용자ID-매핑.md`
- `규칙/프로세스/업무보고-체크-운영규칙.md` (Phase S S-01 신설 SSoT — 4건 룰 통합)
- `규칙/프로세스/아마링크-참조링크-운영규칙.md` (S-03 보강 — 4건 룰 본문)
- `규칙/프로세스/ONEFFICE-댓글-멘션-플러그인-가이드.md` (S-04 보강 — 댓글 selector)
- **`규칙/프로세스/자비스-운영-룰.md` §2 학습 #31·#32·#33·#34** (v2 신설 — 받은보고함 워크플로우 + 미제출 판단 + 산출물 viewer + 직책 cascade)
- `프로젝트/_dashboard.md`
- `skills/a10-cascade-from-context/` (R-02)
- `skills/a10-cascade-from-prj/` (R-03)
- `skills/a10-amalink-recursive-extract/` (Phase S S-07 신설 — 재귀+댓글+헤더 캡슐화)
- `skills/a10-people-context/` (S-07 보강 — 본인 업무현황 lookup)
- `skills/a10-daily-digest/` — 일일보고 캐싱 (3-way 크로스 체크)

---

## 8. 변천사

- Phase R R-04 (2026-04-27) — 본 스킬 신설 (조직 → 프로젝트 → 모듈 흐름)
- Phase S S-05 (2026-04-27) — 4건 룰 통합 (Step 0 휴가자 / Step 2.5 헤더 / Step 3.5 재귀+댓글) + version 0.1.0 → 0.2.0
- **v2.0.0 (2026-05-13)** — 받은보고함 워크플로우 정착 (Step 0~5 + cascade ①②③④) + 트리거 확장 + 자비스 운영 룰 §2 학습 #31~#34 cross-ref + version 0.2.0 → 2.0.0. 본 사이클 결과서: `프로젝트/PRJ-2026-014_*/05_산출물/20260513-결과서-업무보고체크-cascade-정착.md`
