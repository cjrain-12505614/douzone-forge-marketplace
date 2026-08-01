---
name: dz-cascade-from-context
description: >
  This skill should be used when the user asks to "회의록 작성", "PRJ 진행현황 갱신",
  "검토 의견 기록", "결정 기록", "작업 시작", "context 갱신", "LNB 수정",
  "기능 분석", "모듈 컨텍스트 갱신",
  or 업무 맥락 발생 시 프로젝트 → 모듈 → 조직 자동 cascade 갱신 필요할 때.
  CLAUDE.md L362 R1·R2·R3 cascade 자산화. SBUnit 한정 표현 0.
version: 0.2.0
---

# 업무 맥락 Cascade (dz-cascade-from-context) — Phase R R-02 신설 + Phase V V-07-04 키워드 보강

업무 맥락 발생 시 **프로젝트 → 모듈 → 조직** 흐름으로 자동 갱신. CLAUDE.md L362 R1·R2·R3 cascade 규칙 자산화.

## 트리거

description 매칭 (한글 키워드):

### 기존 키워드 (Phase R R-02 신설)
- "회의록 작성"
- "PRJ 진행현황 갱신"
- "검토 의견 기록"
- "결정 기록"
- "작업 시작"

### 보강 키워드 (Phase V V-07-04 추가 — 갭 4-1 해결)
- "context 갱신" — 모듈 컨텍스트 파일(`_overview.md`·`[LNB명].md`) 변경 시 R1 cascade 자동 트리거
- "LNB 수정" — LNB 단위 기능 명세 수정 시 R1 cascade (context → module-overview.md 동시 반영)
- "기능 분석" — 기능 분석 결과 context/ 신설·변경 시 R1 cascade
- "모듈 컨텍스트 갱신" — 모듈 단위 종합 컨텍스트 갱신 시 R1 cascade 자동 작동

## Cascade 흐름 (프로젝트 → 모듈 → 조직)

### 자동 갱신 5건

#### 1. PRJ `00_overview.md` §03 상세 진행현황 1줄 append
- 위치: `프로젝트/PRJ-{NNN}_{제목}/00_overview.md`
- 형식: `| YYYY-MM-DD | 작업 요약 | 링크 |`

#### 2. PRJ 분기 `_index.md` 1줄 등록
- 04_미팅·05_산출물·06_의사결정 분기 별로
- 위치: `프로젝트/PRJ-{NNN}_*/0[4-6]_*/_index.md`

#### 3. 모듈 `Amaranth10/{모듈}/history/_timeline.md` 1줄
- 형식: `- YYYY-MM-DD: {요약} (PRJ-{NNN})`

#### 4. 담당자 `조직/{...}/{이름_사번}/_index.md` "진행 중 PRJ" 섹션
- Q-3 Q-15 보강 섹션 활용
- 본인이 PM 또는 담당자인 PRJ 추가

#### 5. 본인 `_개인/sessions/{모듈}/_current.md` 체크포인트
- 작업 시작 시 + 단계 완료 직후 갱신
- 다음 세션에 컨텍스트 인계

## 사용 사례

### 회의록 작성 (4 cascade)
```
입력: PRJ-2026-013 04/22 정기회의 회의록
→ (1) PRJ-013/00_overview.md 03 진행현황
→ (2) PRJ-013/04_미팅/_index.md
→ (3) Amaranth10/공통/history/_timeline.md (PRJ-013 컨텍스트)
→ (4) 본인 조직/_index.md 진행 중 PRJ
```

### 결정 기록 (5 cascade)
```
입력: PRJ-2026-014 결정 기록
→ (1) PRJ-014/00_overview.md
→ (2) PRJ-014/06_의사결정/_index.md
→ (3) 모듈 history/_timeline.md
→ (4) 본인 조직/_index.md
→ (5) _개인/sessions/공통/_current.md (결정 시점 체크포인트)
```

## 의존 자산

- `규칙/프로세스/사용자ID-매핑.md` — 본인 ID 식별
- `규칙/프로세스/Forge-초기화-가이드.md` — 7단계 SSoT
- `skills/dz-people-context/` (Q-15) — 사람 시점 lookup

## 변천사

- Phase R R-02 (2026-04-27) — 본 스킬 신설 (CLAUDE.md L362 R1·R2·R3 자산화)
- Phase V V-07-04 (2026-05-11) — 트리거 키워드 4건 보강 (context 갱신·LNB 수정·기능 분석·모듈 컨텍스트 갱신) — V-05 갭 4-1 해결


## R13 소스 연쇄 (2026-05-25 — 소스분석 레이어 편입)
<!-- r13-hook -->
본 cascade 완료 후 **소스 분석 레이어 정합**을 위해 forge 루트에서 실행한다:
- `python3 "Amaranth10/_소스분석/_tools/gen_crosslinks.py"` — 연결매트릭스·각 `_source-architecture.md` 관계헤더 재생성
> 근거: `규칙/프로세스/연쇄-갱신-명확화.md` **R13** · 소스 SSoT=`Amaranth10/_소스분석/`
