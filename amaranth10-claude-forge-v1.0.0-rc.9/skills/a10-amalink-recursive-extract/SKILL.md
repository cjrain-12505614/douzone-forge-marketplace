---
name: a10-amalink-recursive-extract
description: >
  This skill should be used when the user asks to "아마링크 추출", "재귀 추출",
  "댓글 영역 같이 추출", "본인 업무현황 추출", "depth 2 추출",
  "헤더 표준 적용", "아마링크 추출 결과 검증",
  or 4건 룰 (헤더 표준·재귀·댓글·휴가자 인지) 통합 워크플로우 필요 시.
  ONEFFICE 아마링크 본문 + 댓글 영역 + 재귀 추출 (depth 2) + 5줄 헤더 자동 캡슐화.
  의존: 규칙/프로세스/업무보고-체크-운영규칙.md (Phase S S-01 SSoT) +
       skills/a10-cascade-from-report (R-04 + S-05) +
       skills/a10-people-context (S-07 보강 — 본인 업무현황 lookup).
version: 0.1.0
---

# 아마링크 재귀 추출 (a10-amalink-recursive-extract) — Phase S S-07 신설

ONEFFICE 아마링크 추출 시 차민수 수석 4건 룰 통합 자동화. **재귀 + 댓글 + 헤더 + 휴가자 인지** 캡슐화.

## 트리거

description 매칭 (한글 키워드):
- "아마링크 추출"
- "재귀 추출"
- "댓글 영역 같이 추출"
- "본인 업무현황 추출"
- "depth 2 추출"
- "헤더 표준 적용"
- "아마링크 추출 결과 검증"

## 4 모드 트리거

### 1. 재귀 모드 ("재귀 추출", "depth 2 추출")
1차 추출 후 본문 내 추가 아마링크 검출 → 의미 분류 (참조·인용·후속) → 재귀 추출 (depth 2 한도).

### 2. 댓글 모드 ("댓글 영역 같이 추출")
본문 + 댓글 영역 동시 DOM 추출. selector:
- 패널: `#TB_COMMENT_PANEL_0`
- 본문 (잠정 후보): `#TB_COMMENT_PANEL_0 .comment-item, ul > li, [class*="comment"]`
- 의사결정자 cascade 우선순위 ↑

### 3. 헤더 모드 ("헤더 표준 적용")
모든 추출 결과 .md 상단 5줄 frontmatter 자동 적용:
```yaml
---
원본: <ONEFFICE 아마링크>
재귀_추출: depth-N
댓글_추출: 포함/미포함
추출일: YYYY-MM-DD HH:MM
추출자: <ID>
---
```

### 4. 검증 모드 ("아마링크 추출 결과 검증")
R-07 `a10-residual-audit` Skill 5축 (S-06 확장) 호출 — 헤더 표준 미준수 검출.

## 통합 워크플로우 (4건 룰 동시 작동)

```
사용자: "업무보고 체크해줘" 또는 "아마링크 재귀 추출"
    ↓
Step 0 — 휴가자 사전 인지 (룰 1)
  • mcp__apple-events__calendar_events lookup
  • 차민수 PC 한정 (본인 환경)
    ↓
Step 1 — 1차 추출 (depth 1)
  • Chrome MCP javascript_tool
  • iframe 2중 + #dzeditor_0 innerText
    ↓
Step 2 — 본문 + 댓글 동시 추출 (룰 4)
  • 본문: #dzeditor_0 innerText
  • 댓글: #TB_COMMENT_PANEL_0 (selector 잠정)
  • 의사결정자 식별 → cascade 우선순위
    ↓
Step 3 — 재귀 추출 (룰 3, depth 2)
  • 본문 내 추가 아마링크 검출
  • 의미 분류 (참조·인용·후속)
  • depth 2까지 자동 (depth 3+ 차민수 명시 시만)
    ↓
Step 4 — 헤더 표준 적용 (룰 2)
  • 결과 .md 상단 5줄 frontmatter 자동 삽입
  • 검사 영역: 참고자료/외부조직/·참고자료/리포트/·참고자료/아마링크-추출/
    ↓
Step 5 — R-04 cascade 트리거 (보고 시점에)
  • a10-cascade-from-report Skill 호출
  • 본인 조직/PRJ/모듈/sessions 4건 cascade
    ↓
Step 6 — R-07 검증 (선택, 검증 모드)
  • a10-residual-audit 5축 dry-run
  • 헤더 미준수 카운트 보고
```

## 사용 사례

### 일일보고 체크 (4건 룰 통합)
```
입력: "업무보고 체크해줘"
→ Step 0: 휴가자 인지 (애플 캘린더)
→ Step 1: 본인이 속한 부서 인원 본인 업무현황 ONEFFICE 추출 (depth 1, xlsx 동적 lookup)
→ Step 2: 댓글 영역 동시 추출 (의사결정자 우선순위)
→ Step 3: 재귀 (depth 2) — 본문 내 참조 아마링크
→ Step 4: 5줄 헤더 자동 적용
→ Step 5: R-04 cascade 4건 자동 갱신
→ 결과: 참고자료/리포트/일일보고체크-{YYYYMMDD}.md
```

### 본인 업무현황 추출 (단일 멤버)
```
입력: "신무광 본인 업무현황 추출"
→ a10-people-context lookup (본인 _index.md "본인 진행 보고" 섹션)
→ 자비스 메모리 reference_sbunit_21_member_reports.md 인용
→ ONEFFICE 본인 업무현황 아마링크 (자비스 cascade 채움 결과)
→ 본 Skill 4 모드 통합 추출
```

## 의존 자산

- `규칙/프로세스/업무보고-체크-운영규칙.md` (Phase S S-01 신설 SSoT)
- `규칙/프로세스/아마링크-참조링크-운영규칙.md` (S-03 보강 — 4건 룰 본문)
- `규칙/프로세스/ONEFFICE-댓글-멘션-플러그인-가이드.md` (S-04 보강 — 댓글 selector)
- `skills/a10-cascade-from-report/` (R-04 + S-05 보강 — Step 0·2.5·3.5 통합)
- `skills/a10-people-context/` (S-07 보강 — 본인 업무현황 lookup)
- `skills/a10-residual-audit/` (R-07 + S-06 5축 — 헤더 검증)

## 변천사

- Phase S S-07 (2026-04-27) — 본 스킬 신설 (4건 룰 통합 캡슐화)
- 차민수 수석 4건 맥락 누적 (2026-04-27 야간) → 자비스 통합 처리 결정
