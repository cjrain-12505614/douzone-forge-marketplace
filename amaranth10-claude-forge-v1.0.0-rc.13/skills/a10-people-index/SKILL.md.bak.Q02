---
name: a10-people-index
description: >
  This skill should be used when the user asks to "사번 알려줘", "이 사람 누구야",
  "B2772 누구지", "유지수 사번", "차민수 R&R", "Cell 리더 누구야",
  "담당자 자동 채워줘", "이름→사번 변환", or when TASK·PRJ·검토안·일일보고에
  사번/이름/소속/R&R 메타가 필요할 때.
  douzone-forge `_CLAUDE/프로세스/사용자ID-매핑.md` SSoT를 **참조만** 하여 SBUnit 22명 + 협업 21명을 즉시 조회.
  사번 데이터는 플러그인 외부 (사용자 워크스페이스 SSoT) — 본 스킬은 데이터 미보유.
version: 0.1.0
---

# 사번 인덱스 (a10-people-index)

douzone-forge `_CLAUDE/프로세스/사용자ID-매핑.md` SSoT를 참조하여 SBUnit 22명 + 협업 조직 21명의 사번/이름/소속/R&R을 조회하는 헬퍼 스킬.

**플러그인은 사번 데이터를 보유하지 않습니다** — SSoT 파일을 읽기만 합니다 (R5 일관). 조직 변경 시 douzone-forge 측 SSoT 갱신만으로 자동 반영됩니다.

## 목적

- TASK 담당자 / PRJ PM / 검토안 작성자 사번 자동 조회 + 이름 변환
- Cell 리더·Unit장·본부장 R&R 빠른 확인
- 조직 4계층 (본부 / Unit / Cell / 멤버) 메타 조회

## SSoT 경로 (외부 참조)

| 항목 | 경로 |
|------|------|
| 사번 매핑 SSoT | `~/Workspace/douzone-forge/_CLAUDE/프로세스/사용자ID-매핑.md` (절대) |
| douzone-forge 마운트 시 | `_CLAUDE/프로세스/사용자ID-매핑.md` (상대) |
| 조직구조 보조 출처 | `~/Workspace/douzone-forge/reference/조직-원본/더존비즈온-조직구조.md` |

⚠️ 본 스킬은 **douzone-forge 워크스페이스 마운트를 가정**. 다른 워크스페이스에서 호출 시 SSoT 접근 불가.

## 입력 / 출력

### 입력

- 사번 (예: `B2772`, `155`, `599`, `H250625`)
- 이름 단축어 (예: `차민수`, `유지수`, `정현수`)
- 역할 키워드 (예: `Unit장`, `SB설계 Cell 리더`, `사장`)

### 출력

```
{이름} ({사번}) — {직급} / {본부} / {Unit} / {Cell}
역할: {R&R 요약}
GitLab ID: {gitlab_id}
```

예시:
```
차민수 (B2772) — 수석연구원 / DWP개발본부 / SBUnit / Unit장
역할: SBUnit 전체 총괄 + Forge 구축 PM + 기술위원회 UC 트랙 PM
GitLab ID: cjrain
```

## SSoT 갱신 정책 (보강 B)

- 본 스킬은 SSoT 파일을 **읽기만** 함 (데이터 미보유 — R5 일관)
- douzone-forge 측 SSoT 갱신 시 → **자동 반영** (참조 방식, 본 스킬 변경 0)
- 본 스킬 SKILL.md 자체 변경은 SSoT 경로가 바뀌거나 출력 형식이 바뀔 때만 필요
- 조직 개편 시 R3 캐스케이드(R&R 5개 파일)는 douzone-forge 측 책임 — 본 스킬 무관

## 사용 사례

### 1. TASK 담당자 자동 채움

PRJ 또는 검토안 작성 시 담당자 컬럼에 사번만 입력하면 이름·소속 자동 조회:
- 입력: `B3505`
- 출력: `유지수 (B3505) — 대리 / DWP개발본부 / SBUnit / SB설계Cell 리더 (2026-04-13~)`

### 2. PRJ PM 자동 조회 (Cell 리더 → 모듈 PM 매핑)

| 모듈 | Cell 리더 (PM) |
|------|------|
| 법무관리(LTE) | 유지수 (B3505) |
| CRM | 김영묵 (B4456) — 부리더 |
| 게시판(BOARD) | 최서아 (155) |
| 업무관리(KISS) | 손예진 (B6276) |
| 통합연락처(AB) | 이수영A (B6287) |

### 3. 검토안 작성자 표기 (사번 → 이름·소속)

`/a10-triage` 산출 검토안에 작성자 메타 자동 채움:
- frontmatter: `작성자: 김영묵 (B4456)` + `소속: SBUnit / SB설계Cell`

## R&R 매핑 (SSoT 참조)

douzone-forge 측 `사용자ID-매핑.md` §2 (SBUnit 22명) + §3 (협업 21명) + Step 7 보강 (3 출처 통합 — `사용자ID-매핑` + `CLAUDE.md` + dashboard) 활용.

본 스킬은 R&R 본문을 직접 보유하지 않으며, `사용자ID-매핑.md` 비고 컬럼 + `조직/{...}/{이름_사번}/_index.md` (Step 7 메타) 를 참조.

## 관련 스킬

- `a10-team-tracking` (G9) — 본 스킬 호출하여 관리자·트래킹 대상 사번/이름 자동 조회
- `a10-decision-tracker` — 의사결정자 메타 자동 채움
- `a10-task-manager` — 고도화 건 담당자 사번 자동 채움

## 변천사

- ST Step 1.5 (2026-04-25) — 사번 SSoT 산출 + 14,399 bytes
- ST Step 7 (2026-04-26) — 26 _index.md R&R 메타 보강 (3 출처 통합)
- PT-02 (2026-04-26) — 본 스킬 신설 (G8)
