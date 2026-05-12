---
name: a10-jira
description: "JIRA 이슈 조회 (amaranth10-jira-collector PoC 래퍼)"
---

`$ARGUMENTS` 에 해당하는 JIRA 조회 모드를 `a10-jira-query` 스킬로 실행한다.
PRJ-2026-012 JIRA 연동 PoC (`amaranth10-jira-collector`, 김경엽 책임 배포)를
래핑한 조회 전용 커맨드. 이슈 생성·수정·코멘트는 정식 MCP 전환 이후.

## 사용 예

```
/a10-jira                                            # default 프리셋
/a10-jira highPriority                               # 특정 프리셋
/a10-jira --list                                     # 프리셋 목록
/a10-jira --jql 'project=CSA10 AND "모듈"=업무관리'   # 애드혹 JQL (한글 필드는 쌍따옴표 필수)
/a10-jira --read 2026-04-17/업무관리                 # 저장된 결과 조회
/a10-jira --module 게시판                            # 오늘자 모듈별 요약
/a10-jira --ping                                     # 연결 점검
```

## 인자·옵션

| 인자/옵션 | 설명 |
|-----------|------|
| `<preset>` | 프리셋 이름. 허용: `default`, `allOpen`, `recent7days`, `highPriority`, `bugAndImprovement`, `stale`, `inProgress`, `mine` |
| `--list` | 프리셋 목록 출력 |
| `--jql "<query>"` | 애드혹 JQL. 한글 필드명은 `"모듈"` 처럼 쌍따옴표 필수 |
| `--read <날짜>/<모듈>` | 저장된 `output/{date}/{module}/summary.md` 반환. 날짜·모듈 각각 생략 가능 |
| `--module <모듈>` | 오늘자 해당 모듈 요약. 허용: 연락처/게시판/업무관리/법무관리/CRM/_unmapped |
| `--ping` | JIRA 서버 연결 점검 |

## 실행 절차

### 1. 선결 조건 검증 (스킬이 첫 실행 시 자동)

- `$JIRA_COLLECTOR_DIR` 또는 `~/Workspace/amaranth10-workspace/_workspace/jira/` 확인
- `.env` 존재, `scripts/fetch-issues.sh` 실행 권한, `JIRA_MODULE_FIELD_ID` 설정 확인
- 실패 시 `a10-jira-query` SKILL.md 의 §설치 안내 메시지 출력 후 중단

### 2. 모드 분기

- 인자 없음 → default 프리셋
- 첫 인자가 프리셋명 → 프리셋 실행
- `--list`/`--jql`/`--read`/`--module`/`--ping` → 해당 모드

### 3. 수집기 호출

```bash
cd "$COLLECTOR_DIR" && ./scripts/fetch-issues.sh [옵션]
```

### 4. 결과 요약

`output/YYYY-MM-DD/INDEX.md` 또는 `summary.md` 를 Read 로 읽어 스킬의 §출력 포맷
(모듈별 분포 표 + 메타데이터) 에 맞춰 반환.

## 의존 스킬

- `a10-jira-query` — 실제 실행부 (선결 조건, 모드 분기, 출력 포맷)

## 치명적 주의

- **`.env` 는 절대 출력 금지** — 비밀번호 평문 저장. `grep -q` 로 존재 여부만 체크.
- **한글 JQL 필드명 쌍따옴표 필수** — 누락 시 서버 왕복 없이 선검증에서 경고.
- **조회 전용** — 이슈 생성·수정·코멘트 금지. 정식 MCP 전환 이후.
- **수집기 경로 하드코딩 금지** — 환경변수 우선, 기본 경로 fallback.

## 관련 자산

- [amaranth10-jira-collector PoC](../../../../douzone-forge/업무관리/p1-research/jira-integration/)
- [PRJ-2026-012](../../../../douzone-forge/_projects/PRJ-2026-012_업무관리-프로젝트관리-기능확장.md)
