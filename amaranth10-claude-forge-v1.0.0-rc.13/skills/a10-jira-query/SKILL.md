---
name: a10-jira-query
description: >
  This skill should be used when the user asks to "JIRA 이슈 조회", "CSA10/KLAGOP1/A10D 이슈",
  "모듈별 이슈", "오늘 등록된 버그", "JIRA에서 가져와줘", 또는 amaranth10-jira-collector
  PoC를 통해 사내 JIRA 이슈를 조회·요약해야 할 때. PRJ-2026-012 JIRA 연동 PoC
  (김경엽 책임 배포, 2026-04-17) 수집기를 래핑하여 세션 중 애드혹 JQL 조회, 프리셋
  실행, 일일 배치 결과 로드를 지원한다. 조회 전용 — 이슈 생성·수정·코멘트는 정식
  MCP 전환 이후 과제.
version: 0.1.0
---

# a10-jira-query — JIRA 이슈 조회 스킬

## 목적

사내 JIRA(`jira.duzon.com:8080`)의 Amaranth 10 / Alpha 계열 프로젝트 미해결 이슈를
`모듈` 커스텀 필드 기준으로 수집·요약한다. 2026-04-17 김경엽 책임이 배포한
`amaranth10-jira-collector` (Java 21 + Gradle) PoC 를 래핑하여, Claude 세션 중
애드혹 JQL 조회와 일일 배치 결과(매일 09:00 launchd) 로드를 지원한다.

정식 JIRA MCP 전환은 05/08 기획-15 착수 시 재검토 — 본 스킬은 **PoC 단계** 의
조회 전용 래퍼.

## JIRA 프로젝트 코드 체계 (2026-04-19 확정)

| 분류 | 코드 | 프로젝트 | SBUnit 관리 대상 |
|---|---|---|---|
| **프로젝트 개발** | `KLAGOP1` | Amaranth 10 통합 개발 | ✅ |
| | `UCAIMP` | Alpha 패키지 고도화 | ⚠ 연관(Alpha 연계) |
| | `A10D` | Amaranth 10 통합 개발(고도화) | ✅ |
| **유지보수** | `CSA10` | Amaranth 10 통합 유지보수 | ✅ 주력 |
| | `UBA` | Alpha 유지보수 | ⚠ 연관 |
| | `UAC` | Alpha Cloud 유지보수 | ⚠ 연관 |
| | `EO` | OmniEsol 통합 유지보수 | ❌ |

이슈 키 패턴: `(KLAGOP1|UCAIMP|A10D|CSA10|UBA|UAC|EO)-\d+`

`a10-git-daily` 스코어링 엔진(v0.9.0+)이 커밋 메시지 내 이 패턴을 인식해
프로젝트 개발 커밋은 PRJ 자동 귀속(+50), 유지보수 커밋은 유지보수 로그로 분기한다.

## 트리거 조건

- 사용자가 "JIRA", "CSA10", "KLAGOP1", "A10D", "모듈별 이슈", "버그 N건", "오늘 이슈" 등
  JIRA 관련 요청을 할 때
- `/a10-jira` 커맨드가 명시적으로 호출될 때

## 선결 조건 확인 절차

스킬 첫 실행 시 아래 4단계를 순차 검증. 하나라도 실패하면 `§설치 안내` 메시지
출력 후 중단.

```bash
# 1. 수집기 디렉토리 확인
COLLECTOR_DIR="${JIRA_COLLECTOR_DIR:-$HOME/Workspace/amaranth10-workspace/_workspace/jira}"
[ -d "$COLLECTOR_DIR" ] || fail "수집기 디렉토리 없음"

# 2. .env 파일 존재 (내용은 읽지 않음 — 비밀번호 평문)
[ -f "$COLLECTOR_DIR/.env" ] || fail ".env 파일 없음"

# 3. fetch-issues.sh 실행 권한
[ -x "$COLLECTOR_DIR/scripts/fetch-issues.sh" ] || fail "fetch-issues.sh 실행 권한 없음"

# 4. (선택) customfield ID 미설정 경고 — grep -q 로 존재만 확인, 값 출력 금지
grep -q "^JIRA_MODULE_FIELD_ID=customfield_" "$COLLECTOR_DIR/.env" \
  || warn "JIRA_MODULE_FIELD_ID 미설정 — --find-field 모듈 필요"
```

### 설치 안내 메시지

```
[a10-jira] JIRA 수집기 PoC가 설치되어 있지 않습니다.

설치 방법:
1. douzone-forge/업무관리/p1-research/jira-integration/amaranth10-jira-collector.tar.gz 를
   원하는 위치(권장: ~/Workspace/amaranth10-workspace/_workspace/jira/) 에 해제
2. .env.example → .env 복사 후 JIRA_USER, JIRA_PASSWORD, JIRA_MODULE_FIELD_ID 채우기
3. ./scripts/fetch-issues.sh --ping 으로 연결 확인
4. ./scripts/fetch-issues.sh --find-field 모듈 으로 customfield ID 확인 후 .env 에 반영

운영 가이드: 업무관리/p1-research/jira-integration/jira-integration-guide.html
```

## 실행 모드 (5가지)

### 모드 1. 무인자 (default 프리셋)

```bash
cd "$COLLECTOR_DIR" && ./scripts/fetch-issues.sh
```

후속: `output/YYYY-MM-DD/INDEX.md` 를 Read 로 읽어 모듈별 분포·건수 요약. 복수 모듈
이슈·미매핑 이슈를 하이라이트.

### 모드 2. 특정 프리셋

```bash
cd "$COLLECTOR_DIR" && ./scripts/fetch-issues.sh <preset>
```

허용 프리셋: `default`, `allOpen`, `recent7days`, `highPriority`, `bugAndImprovement`,
`stale`, `inProgress`, `mine`.

목록 조회: `/a10-jira --list` → 프리셋 8종과 각 프리셋의 요약 JQL 출력.

### 모드 3. 애드혹 JQL

```bash
cd "$COLLECTOR_DIR" && ./scripts/fetch-issues.sh --jql "<query>"
```

**한글 필드명은 반드시 쌍따옴표 감싸기** — JQL 문법 요구사항. 예:

```
/a10-jira --jql 'project = CSA10 AND "모듈" = 업무관리 AND created >= -14d'
```

쌍따옴표 누락 시 (예: `... AND 모듈 = 업무관리 ...`):
```
🔴 JQL 문법 오류 — 한글 필드명 "모듈" 은 반드시 쌍따옴표로 감싸야 합니다.
  수정: ... AND "모듈" = 업무관리 ...
```

### 모드 4. 저장된 결과 조회 (`--read <날짜>/<모듈>`)

```
/a10-jira --read 2026-04-17/업무관리
/a10-jira --read 2026-04-17           # INDEX.md 반환
/a10-jira --read 업무관리              # 오늘자 해당 모듈
```

내부: `{COLLECTOR_DIR}/output/{YYYY-MM-DD}/{모듈}/summary.md` 를 Read 로 읽음.

### 모드 5. 모듈별 오늘 요약 (`--module <모듈명>`)

허용 모듈: `연락처`, `게시판`, `업무관리`, `법무관리`, `CRM`, `_unmapped`.

```bash
# 오늘자 수집 없으면 default 프리셋 먼저 실행
[ -d "$COLLECTOR_DIR/output/$(date +%F)" ] || ./scripts/fetch-issues.sh
```

SBUnit R&R 외 모듈(예: `총무관리`) 지정 시:
```
🟡 '총무관리' 는 SBUnit R&R 제외 모듈입니다. 허용: 연락처/게시판/업무관리/법무관리/CRM/_unmapped
```

### 모드 6. 연결 점검 (`--ping`)

```bash
cd "$COLLECTOR_DIR" && ./scripts/fetch-issues.sh --ping
```

401/403 응답 시:
```
🔴 JIRA 인증 실패 — CAPTCHA 해제 필요. 운영 가이드 §3 참조.
```

## 출력 포맷

### 기본 출력 (프리셋·JQL 실행 후)

```markdown
## JIRA 수집 결과 — {YYYY-MM-DD}

- **프리셋**: {preset}
- **JQL**: `{실행된 JQL}`
- **담당자 필터**: {.env JIRA_ASSIGNEES 값} (자동 주입)
- **서버 총 건수 / 수집 건수**: {total} / {fetched}
- **복수 모듈 이슈**: {N}건
- **미매핑 이슈**: {N}건

### 모듈별 분포
| 모듈 | BE | FE | 건수 | 보기 |
|------|----|----|------|------|
| 업무관리 | ... | ... | ... | `/a10-jira --read {date}/업무관리` |
| ... |
```

### 모듈별 상세 (`--module`·`--read`)

상단에 모듈명·BE/FE 레포명 추가 후, `summary.md` 표(Key/유형/우선순위/상태/담당자/요약/업데이트)
원본 그대로 반환.

### 경고·오류 이모지

- 🔴 **오류** — 연결 실패, 인증 실패, JQL 문법 오류
- 🟡 **경고** — 미매핑 이슈 발생(비정상 다발 시 `--find-field 모듈` 재실행 권고),
  SBUnit R&R 미포함 모듈 지정, default 프리셋 README vs yml 불일치 _(확인 필요)_
- 🟢 **정보** — 정상 수집 완료, 복수 모듈 이슈 안내

## 주의사항

1. **`.env` 보안** — `.env` 내용을 읽거나 출력에 포함하지 말 것. `grep -q` 로 존재
   여부만 체크. 비밀번호 평문 저장되어 있음.
2. **한글 JQL 필드명 쌍따옴표** — 사용자 입력에 `"모듈"` 처럼 쌍따옴표가 없으면
   실행 전에 경고·수정 제안.
3. **조회 전용** — 이슈 생성·수정·코멘트 작성 불가. 정식 MCP 전환(기획-15 이후)
   까지 **엄격히 금지**.
4. **수집기 경로 하드코딩 금지** — `$JIRA_COLLECTOR_DIR` 환경변수 우선, 없으면
   `~/Workspace/amaranth10-workspace/_workspace/jira/` 기본 탐색.
5. **launchd 배치 중복** — 매일 09:00 자동 실행과 수동 호출이 같은 날짜 폴더를
   덮어써도 문제 없음 (멱등). 스킬은 수동 실행만.
6. **페이지네이션** — `overallCap` 초과 대량 수집도 수집기가 자동 처리. 스킬이
   JSON 구조나 페이지 파라미터에 개입 금지.
7. **customfield ID 변동 대비** — 수집 결과 `_unmapped` 비율이 비정상 다발
   (예: 전체 50% 이상) 시 `--find-field 모듈` 재실행을 권고 메시지로 출력.
8. **담당자 자동 주입** — `.env` 의 `JIRA_ASSIGNEES` 가 모든 프리셋에 자동 주입됨.
   스킬이 직접 `assignee` 조건을 추가하지 말 것.
9. **UTF-8 인코딩** — 한글 모듈명·필드명 Bash 전달 시 UTF-8 유지. macOS
   `LANG=ko_KR.UTF-8` 전제.

## 관련 자산

- **PoC 원본**: [`modules/업무관리(KISS)/p1-research/jira-integration/amaranth10-jira-collector.tar.gz`](../../../../douzone-forge/modules/업무관리(KISS)/p1-research/jira-integration/amaranth10-jira-collector.tar.gz)
- **운영 가이드**: [`modules/업무관리(KISS)/p1-research/jira-integration/jira-integration-guide.html`](../../../../douzone-forge/modules/업무관리(KISS)/p1-research/jira-integration/jira-integration-guide.html)
- **PoC 해설 (forge)**: [`modules/업무관리(KISS)/p1-research/jira-integration/README.md`](../../../../douzone-forge/modules/업무관리(KISS)/p1-research/jira-integration/README.md)
- **프로젝트 상세**: [`PRJ-2026-012_업무관리-프로젝트관리-기능확장.md`](../../../../douzone-forge/projects/PRJ-2026-012_업무관리-프로젝트관리-기능확장.md)

## 함께 쓰는 스킬

- **a10-task-manager** — JIRA 이슈를 고도화 업무 트래킹에 반영할 때
- **a10-sheets-manager** — JIRA 수집 결과를 업무관리 시트에 연동할 때
- **a10-project-tracker** — PRJ-2026-012 진행 상태 갱신 시

## 관련 Command

- **`/a10-jira`** — 이 스킬의 엔트리 커맨드 (무인자, 프리셋, JQL, --read, --module, --ping, --list)

## 확인 필요 사항 _(2026-04-18 기준 미해결)_

아래 3건은 김경엽 책임과 차민수 수석이 별도 확인 중. 스킬은 무관하게 동작하며,
결정되면 본 SKILL.md 주석으로 반영한다:

1. _(확인 필요)_ **default 프리셋 정책** — README 는 "오늘 등록 건", 실제 yml 은
   `created >= -7d AND statusCategory != Done` (최근 7일 미해결). 어느 쪽이 기본 정책인지.
2. ✅ **JIRA 프로젝트 코드 체계 확정 (2026-04-19)** — 본 SKILL.md 상단 표 참조.
   프로젝트 개발 `KLAGOP1`/`UCAIMP`/`A10D`, 유지보수 `CSA10`/`UBA`/`UAC`/`EO`.

## 담당자 JIRA ID 조회 원칙

**단일 원천 (Single Source of Truth)**: [`reference/조직/더존비즈온-조직구조.md`](../../../../douzone-forge/reference/조직/더존비즈온-조직구조.md) 의 각 Cell 표에서 **이름 옆 괄호 안의 ID**가 곧 JIRA ID이며, 사내 이메일 프리픽스(`{id}@douzone.com`)와 동일하다.

```
예) SB설계Cell 표에서 "대리 | 유지수 (jisu2423)" →
    JIRA ID = jisu2423
    이메일 = jisu2423@douzone.com
```

### 조회 절차

담당자 JIRA ID가 필요할 때:
1. 사용자에게 묻지 말고 먼저 `reference/조직/더존비즈온-조직구조.md` 에서 이름으로 Grep
2. 괄호 안 ID를 JIRA ID로 사용
3. 조직도에 없으면 → "조직도 미등재" 경고 + 원본 엑셀(`Amaranth_10_OrganizationChart_*.xlsx`) 재분석 권고

### 기존 추정 정정 이력 (참고)

초기 PoC 시점 추정 → 2026-04-19 조직도 교차검증으로 확정:
- `dus3062` = **박수연** (이전 추정: 유지수 ❌)
- `doban7` = **이혜영** (이전: ? → 확정)

> 인원 변동이 있어도 조직구조.md가 최신이면 JIRA ID 유추 가능. 본 SKILL.md는 매핑 표를 별도 관리하지 않는다.

## 변경 이력

| 날짜 | 내용 |
|------|------|
| 2026-04-18 | 초기 버전 — 김경엽 책임 `amaranth10-jira-collector` PoC 래핑 |
