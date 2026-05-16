---
name: a10-cascade-from-prj
description: >
  PRJ 문서(00_overview.md 또는 0X_* 분기) 변경 시 프로젝트 → 모듈 → 조직 자동 cascade.
  CLAUDE.md R2·R3·R5 cascade 규칙 자산화. 4건 자동 갱신. SBUnit 한정 표현 0.
version: 0.1.0
---

# 프로젝트 원피스 Cascade (a10-cascade-from-prj) — Phase R R-03 신설

PRJ 문서 변경 시 **프로젝트 → 모듈 → 조직** 자동 cascade. CLAUDE.md R2·R3·R5 자산화.

## 트리거

PRJ 문서 변경 감지:
- `프로젝트/PRJ-{NNN}_*/00_overview.md` 수정
- `프로젝트/PRJ-{NNN}_*/0[1-6]_*/` 분기 .md 수정
- PRJ 신설 (`/a10-add-project`)

## Cascade 흐름 (프로젝트 → 모듈 → 조직)

### 자동 갱신 4건

#### 1. PRJ 분기 `_index.md` 변경 시점·내용
- 위치: `프로젝트/PRJ-{NNN}_*/0[1-6]_*/_index.md`
- 형식: 변경 일자 + 변경 본문 1줄

#### 2. PRJ `00_overview.md` §03 진행현황 1줄
- 분기 변경 → overview 진행현황 자동 append
- 형식: `| YYYY-MM-DD | {분기} 갱신: {요약} |`

#### 3. 모듈 `history/_timeline.md` 1줄
- PRJ 메타 (모듈 매핑) 기반 자동 모듈 식별
- 위치: `Amaranth10/{모듈}/history/_timeline.md`

#### 4. 담당자 조직 `_index.md` "진행 중 PRJ"
- PRJ `01.B 담당자` 섹션 기반 자동 갱신
- 위치: `조직/{...}/{이름_사번}/_index.md`

## 사용 사례

### PRJ 진행률 갱신 (4 cascade)
```
입력: PRJ-014 진행률 80% → 90%
→ (1) PRJ-014/01_기획/_index.md 변경 시점
→ (2) PRJ-014/00_overview.md §03 진행현황
→ (3) Amaranth10/공통/history/_timeline.md
→ (4) 차민수 조직/_index.md 진행 중 PRJ
```

### 신규 산출물 추가 (4 cascade)
```
입력: PRJ-013/05_산출물/20260427-XYZ.md 신설
→ (1) PRJ-013/05_산출물/_index.md
→ (2) PRJ-013/00_overview.md §03
→ (3) 모듈 history/_timeline.md
→ (4) 담당자 조직/_index.md
```

## 의존 자산

- `규칙/프로세스/사용자ID-매핑.md`
- `프로젝트/_dashboard.md` — PRJ 메타
- `skills/a10-cascade-from-context/` (R-02) — 업무 맥락 cascade
- `skills/a10-cascade-from-report/` (R-04) — 업무보고 cascade

## 변천사

- Phase R R-03 (2026-04-27) — 본 스킬 신설 (CLAUDE.md R2·R3·R5 자산화)
