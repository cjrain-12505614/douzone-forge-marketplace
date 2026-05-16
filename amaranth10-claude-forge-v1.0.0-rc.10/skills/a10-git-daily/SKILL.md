---
name: a10-git-daily
description: >
  Workspace_a10의 20개 SBUnit 관리 레포에서 전일(또는 지정 기간) git 커밋을
  수집하여 douzone-forge의 프로젝트 포트폴리오(projects/PRJ-*.md)와 모듈
  히스토리(history/_timeline.md)에 자동 반영하는 브릿지 스킬.
  "개발 현황 업데이트해줘", "어제 커밋 뭐 들어왔어?", "깃 일일분석 돌려줘",
  "PRJ-2026-010 진행현황 업데이트", "모듈별 이번 주 커밋 요약" 요청 시 사용.
  커밋 메시지의 [PRJ-NNNN/TASK-CODE] 프리픽스를 파싱하여 해당 프로젝트 파일의
  "03. 상세 진행현황" 섹션에 일자별 로그를 append하고, 미태깅 커밋은 경고로
  분리 보고한다.
version: 0.2.0
---

# Git 일일 분석 브릿지 (A10 Git Daily Bridge)

Workspace_a10(소스) ↔ douzone-forge(기획·설계) 맥락 연계를 유지하기 위한
일일 git 분석 자동화 스킬. 공통 식별자 `[PRJ-NNNN/TASK]`를 축으로 두 워크스페이스를
양방향으로 연결한다.

## 전제 조건

- **듀얼 마운트 환경**: `~/Workspace_a10/`(소스)와
  `~/Workspace/douzone-forge/`(기획·설계)가 모두 접근 가능해야 함
- **커밋 메시지 규약**: `[PRJ-NNNN/TASK-CODE] 내용` 또는 `[PRJ-NNNN] 내용` 프리픽스
  - 예: `[PRJ-2026-010/개발-P1-03] 문서 검색 API 추가`
  - 예: `[PRJ-2026-006] 영업활동 조회 수정`
- **브랜치 범위**: 기본적으로 `develop`와 `devqa`만 분석 (개인 `devqa-{사번}`·`dev-{사번}`는 제외)

## 실행 흐름

### 1단계: 수집 범위 결정

- 인수 없음: 어제 00:00 ~ 오늘 실행 시점
- `--since 2026-04-15`: 지정일부터
- `--module 법무관리`: 특정 모듈 레포만
- `--repos amaranth10-lte,klago-ui-lte-micro`: 개별 레포 지정
- `--weekly`: 직전 7일
- `--include-personal`: `devqa-{사번}`·`dev-{사번}` 브랜치 포함 (기본 제외)

### 2단계: 레포별 git fetch + log

20개 SBUnit 관리 레포 순회 (모듈별 그룹):

| 모듈 | BE | FE | MCP | 기타 |
|---|---|---|---|---|
| 법무관리 | `amaranth10-lte` | `klago-ui-lte-micro` | `amaranth10-law-mcp` | — |
| CRM | `amaranth10-crm`, `amaranth10-crmgw` | `klago-ui-crm-micro` | `amaranth10-crm-mcp` | `klago-crm-mobile` |
| 업무관리 | `amaranth10-kiss` | `klago-ui-kiss-micro`, `klago-ui-kiss-universal`, `klago-pub-kiss-universal` | — | — |
| 게시판 | `amaranth10-board` | `klago-ui-board-micro` | `amaranth10-board-mcp` | — |
| 통합연락처 | `amaranth10-ab` | `klago-ui-ab-micro` | `amaranth10-ab-mcp` | — |
| 퍼블리싱 | — | `klago-ui-micro`, `klago-pub-gw`, `klago-pub-www`, `klago-pub-poc` | — | — |

각 레포에서 실행:
```bash
cd ~/Workspace_a10/{레포}
git fetch --all --prune
git log origin/develop --since="{start}" --until="{end}" \
  --pretty=format:'%H%x09%an%x09%ai%x09%s' --no-merges
git log origin/devqa --since="{start}" --until="{end}" \
  --pretty=format:'%H%x09%an%x09%ai%x09%s' --no-merges
```

머지 커밋은 `Merge branch 'devqa' into 'sqa'` 패턴을 별도 탐지하여 "승급 이벤트"로 분류.

### 3단계: 커밋 파싱

각 커밋 메시지에서 정규식으로 식별자 추출:

**PRJ 프리픽스** (구규칙 + 2026-04-20 신규 규칙 동시 수용):
```
^\[PRJ-(\d{4}-(?:[A-Z]+-)?\d{3})(?:/([^\]]+))?\]\s*(.+)$
```
- Group 1: PRJ ID
  - 구규칙: `2026-010` (연도-순번)
  - 신규규칙: `2026-LTE-001` (연도-모듈코드-순번) — 모듈 코드: `LTE/modules/CRM/KISS/BOARD/AB/GA/PUB/DSPORTS`
- Group 2: TASK 코드 (선택, 예: `개발-P1-03`)
- Group 3: 커밋 제목
- 커밋 메시지 예: `[PRJ-2026-LTE-001/개발-01] 수금관리 필터 3-토글 구현`
- 분류: **프로젝트 커밋** → 해당 PRJ 파일 `03. 상세 진행현황` append

**유지보수 프리픽스** (명시적):
```
^\[MAINT(?:/([^\]]+))?\]\s*(.+)$
```

**유지보수 JIRA 키 (결정적 분기 — v0.9.0)**:
```
\b(CSA10|UBA|UAC|EO)-\d+\b
```
- `CSA10`: Amaranth 10 통합 유지보수
- `UBA`: Alpha 유지보수
- `UAC`: Alpha Cloud 유지보수
- `EO`: OmniEsol 통합 유지보수
- 커밋 메시지 어디에든 등장하면 **즉시 유지보수로 확정**. PRJ 반영 안 함.

**프로젝트 개발 JIRA 키 (강신호 — v0.9.0)**:
```
\b(KLAGOP1|UCAIMP|A10D)-\d+\b
```
- `KLAGOP1`: Amaranth 10 통합 개발
- `UCAIMP`: Alpha 패키지 고도화
- `A10D`: Amaranth 10 통합 개발(고도화)
- 포함 시 → 프로젝트 커밋으로 확정 후 스코어링에서 +50 보너스 (SCORING-ENGINE-v0.9.md §3.6)

**기타 예외 프리픽스**: `[OPS]`, `[HOTFIX]`, `[DOC]` → 유지보수 로그와 동일 처리

**매칭 실패** → 스코어링 엔진(3.5단계)으로 자동 추론 시도 → 40점 미만 시 미태깅 리스트.

#### 유지보수 분류 판단 보조

커밋 메시지에 프리픽스가 없더라도, 아래 휴리스틱으로 **유지보수 후보** 표시:
- JIRA `CSA-` 또는 `CSA10-` 티켓 번호 포함
- 커밋 메시지에 "버그", "오류", "보정", "수정" 등 운영성 키워드 + PRJ 범위 밖
- 작성자가 주간보고상 해당 모듈 유지보수 라인 담당자

이 경우 `⚠️ 유지보수 후보 — 규약 미준수` 라벨을 붙여 보고. PRJ에는 반영하지 않음.

### 3.5단계: 스코어링 엔진 (v0.9.0 신규)

STEP 1(프리픽스·JIRA 결정적 매칭)에서 확정되지 않은 커밋은 모든 **활성 PRJ**를
순회하며 6개 신호 가중합으로 귀속 후보를 산정한다.

**활성 PRJ 로드**: `douzone-forge/projects/_dashboard.md`에서 "진행 중" 테이블을
파싱해 PRJ ID 목록을 얻는다. 각 ID별로 `projects/PRJ-{ID}.md`의 `01.E 연계 키`
섹션을 읽어 매칭 사전을 구축.

**6개 신호 가중치**:

| 신호 | 가중치 | 판정 |
|------|-------|------|
| ① 프로젝트 JIRA 키 | +50 | 커밋에 `(KLAGOP1\|UCAIMP\|A10D)-\d+`가 있고 해당 키가 PRJ의 `jira_keys` 목록에 존재 |
| ② 경로 매칭 | +40 / +20 | 변경 파일의 ≥50% glob 일치 → 40, ≥20% → 20, 미만 → 0 |
| ③ 담당자 + 기간 | +30 / +10 | 저자가 PRJ.members + 커밋 시각 기간 내 → 30, 기간 밖 → 10 (잔불) |
| ④ 주간보고 자가신고 | +30 | (v0.9.1 예정) 해당 주차 주간보고 파서가 커밋 저자 × PRJ 자가신고 매칭 |
| ⑤ 키워드 | +20 | PRJ.keywords 중 1개 이상 메시지에 포함 |
| ⑥ 브랜치 패턴 | +10 | PRJ.branches 정규식과 브랜치명 매칭 |

```python
# 의사 코드
def score_commit(commit, prj):
    s = 0
    if has_project_jira_key(commit.msg) and key in prj.jira_keys: s += 50
    path_rate = match_path_rate(commit.files, prj.paths)
    s += 40 if path_rate >= 0.5 else (20 if path_rate >= 0.2 else 0)
    if commit.author in prj.members:
        s += 30 if in_period(commit.time, prj.period) else 10
    if weekly_report_self_report(commit.author, prj.id, commit.week):
        s += 30
    if any_keyword(commit.msg, prj.keywords): s += 20
    if match_branch(commit.branch, prj.branches): s += 10
    return s

for commit in unclassified:
    scores = {prj.id: score_commit(commit, prj) for prj in active_prjs}
    best_id, best_score = max(scores.items(), key=lambda x: x[1])
    commit.estimate = (best_id, best_score, scores)
```

**v0.9.0 현재 범위**: ①②③⑤⑥ 5신호 구현. ④(주간보고)는 v0.9.1에서 추가 —
부재 시 감점 없이 생략.

**파일 경로 glob 매칭**: Python `fnmatch` 또는 shell `case` 패턴 사용. `**`는
재귀 경로로 해석.

**경로 매칭 비율**: 변경 파일 총 개수 대비 매칭 개수 (테스트·문서 파일 포함).
삭제 파일도 `git show --stat --name-only`가 반환하므로 포함.

### 3.6단계: 임계값 분류 (v0.9.0 신규)

각 커밋의 `best_score`를 기준으로 **3분법** 처리:

| 점수 범위 | 분류 | 처리 |
|-----------|------|------|
| ≥ 70 | **자동 귀속** | PRJ 파일 `03. 상세 진행현황`에 바로 append + `_mapping-history.md`에 `auto` 기록 |
| 40 ~ 69 | **승인 대기 큐** | 레포트 `## ⚠️ 승인 대기 매핑` 섹션에 표로 나열. 사용자는 `/a10-confirm N` 또는 `/a10-reject N`으로 결정 |
| < 40 | **미태깅** | 기존 미태깅 리스트와 동일 처리 (규약 보강 권고) |

**동점 처리**: 70점 이상 다수 PRJ가 동점 → 가장 높은 단일 신호(JIRA키 > 경로 >
담당자) 우선. 여전히 동점이면 승인 대기 큐로 강등.

**멱등성 보장**: 자동 귀속 전 해당 PRJ 파일에 동일 SHA가 기록되어 있는지 grep
한 번 수행 → 있으면 스킵.

### 4단계: 레포트 생성

`~/Workspace_a10/_doc/git-daily/YYYYMMDD.md` 생성 (덮어쓰기):

```markdown
# Git 일일 분석 — 2026-04-18

> 범위: 2026-04-17 ~ 2026-04-18 (어제)
> 분석 레포: 20개 / 총 커밋: 42건 (태깅 38 / 미태깅 4)

## 모듈별 활동

### 법무관리 (12건)
- [PRJ-2025-001/개발-24] 사건등록 팝업 유효성 추가 (박현경, amaranth10-lte, develop) — a1b2c3d
- [PRJ-2026-005/기획-07] WBS 재작성 반영 (유지수, klago-ui-lte-micro, devqa) — e4f5g6h
- ...

### CRM (9건)
...

## 브랜치 승급 이벤트
- amaranth10-lte: devqa → sqa (3건 포함) @ 2026-04-17 18:42
- ...

## ⚠️ 승인 대기 매핑 (2건) — 40~69점

스코어링 엔진 추론 결과 확신이 부족한 커밋들입니다. PM 확인 후 `/a10-confirm N` 또는 `/a10-reject N`으로 결정하세요.

| # | SHA | 레포 | 저자 | 메시지 | 추정 PRJ | 점수 | 신호 내역 |
|---|-----|------|------|--------|---------|------|-----------|
| 1 | d9106ea | amaranth10-kiss | 박선명 | 메일게시판 줌인 작업 | PRJ-2026-003 | 68 | 경로40 + 담당30 − 키워드X − 브랜치X + JIRAX = 68 (주보 v0.9.1) |
| 2 | a1b2c3d | klago-ui-crm-micro | 김영묵 | 상담 목록 정렬 변경 | PRJ-2026-006 | 55 | 경로40 + 담당10(기간밖) + 키워드X + 브랜치X = 50 (_(주의: 기간밖 +10))_ |

## ⚠️ 미태깅 커밋 (2건) — <40점

프리픽스 없고 스코어링도 40점 미만입니다. 저자에게 TASK 매핑 확인 필요.

| 레포 | 브랜치 | 저자 | 시각 | 메시지 | SHA |
|---|---|---|---|---|---|
| amaranth10-kiss | develop | 김승현C | 17:22 | 메일 본문 노출 임시 수정 | 7h8i9j0 |
| ... |
```

### 5단계: douzone-forge 크로스포스트

**A. PRJ 파일 진행현황 append**

PRJ별로 커밋을 그룹화하여 `projects/PRJ-{ID}.md`의 **`## 03. 상세 진행현황`** 섹션
맨 위에 일자별 블록으로 append (최신순 유지):

```markdown
### 2026-04-18 (git-daily 자동 반영)
- **[개발-24]** 사건등록 팝업 유효성 추가 — 박현경 @ amaranth10-lte develop
- **[개발-25]** 상담목록 정렬 버그 수정 — 김용훈 @ amaranth10-lte devqa ✅ 설계검수 진입
```

**B. 모듈 history/_timeline.md append**

각 모듈 `{모듈}/history/_timeline.md`에 두 블록을 추가/갱신:

① **프로젝트 활동 요약** (PRJ 귀속 커밋만):
```markdown
## 2026-04-18 (git-daily)
- amaranth10-lte develop: 3건 (박현경 2, 김용훈 1) — PRJ-2025-001, PRJ-2026-010
- klago-ui-lte-micro devqa: 1건 (유지수) — PRJ-2025-001 ✅ 설계검수
- 상세: [Workspace_a10/_doc/git-daily/20260418.md](...)
```

② **유지보수 로그** (`[MAINT]`/`[OPS]`/`[HOTFIX]` 커밋):
```markdown
## 유지보수 로그

| 일자 | 커밋 | 저자 | 내용 | JIRA | 분류 근거 |
|------|------|------|------|------|----------|
| 2026-04-17 14:19 | amaranth10-board devqa 2682f550 | [UC]박수연 | 게시판 이동 시 즐겨찾기 해제 | CSA10-40261 | MAINT/CSA |
```

유지보수 로그는 **일자별 섹션이 아니라 누적 테이블**로 관리(최신 상단). PRJ 파일엔 기록하지 않음.

**C. _개인/sessions/{모듈}/_current.md 업데이트**

모듈별 `_개인/sessions/{모듈}/_current.md`가 존재하면 "최근 git 활동" 섹션에 요약 갱신.

### 6단계: 최종 보고

사용자에게 한 화면 요약:
```
📊 Git 일일 분석 완료 (2026-04-18)
- 분석 레포 20개 / 커밋 42건
- PRJ 반영: 8개 프로젝트 진행현황 갱신
  · PRJ-2025-001(가온): +2건 / PRJ-2026-010(법무MCP): +5건 / ...
- ⚠️ 미태깅 커밋 4건 → 저자 확인 필요 (위 레포트 참조)
- 브랜치 승급: devqa→sqa 1건 (amaranth10-lte)
```

## 출력 규칙

- **"예정"/"대기" 표현 금지**: 실제 커밋된 것만 "반영 완료"로 표기
- **추측 금지**: 메시지 프리픽스 없으면 미태깅으로 분리. TASK 임의 매핑 ❌
- **시제 정확**: 커밋 날짜 기준 과거형. 머지만 된 경우 "승급" / 실제 코드 변경은 "반영"으로 구분
- **중복 방지**: PRJ 파일에 이미 같은 커밋 SHA가 기록되어 있으면 스킵 (멱등성)

## 에러 처리

- `git fetch` 실패 (네트워크·인증) → 해당 레포 스킵, 경고 리스트에 추가
- PRJ 파일 부재 (커밋이 신규 PRJ를 참조) → 미태깅과 별도로 "**⚠️ 누락된 PRJ 파일**" 섹션에 기록
- 저자명이 조직도에 없는 사람 → `reference/조직/더존비즈온-조직구조.md` 업데이트 권고

## 보조 스킬 연계

- 결과를 바탕으로 `/a10-status` 실행 시 "미태깅 커밋 N건 경고" 자동 포함
- `/a10-start-session` 훅에서 전일 git-daily 파일 자동 로드 (있는 경우)
- 주간 합산은 `--weekly` 옵션으로 생성 → PRJ별 주간 리포트 소스

## 규약 명문화

이 스킬이 전제로 하는 커밋 메시지 규약은 별도 가이드에 명시한다:
- 개발 가이드: `reference/프로세스/깃-커밋-메시지-규약.md` (신규 작성 권고)
- 브랜치 명명 규약: `feature/PRJ-NNNN-TASK-CODE-short-desc`
- MR 제목 규약: `[PRJ-NNNN/TASK-CODE] 제목`

## 승인 큐 지속성 (v0.9.0 신규)

승인 대기 항목은 스킬 실행 종료 후에도 유지되어야 한다. 관리 파일:

**`douzone-forge/projects/_mapping-queue.md`**

```markdown
# 승인 대기 매핑 큐

> `/a10-git-daily` 실행 결과 40~69점 구간 커밋을 수집. 최신 실행 결과로 대체됨.
> 결정: `/a10-confirm N` (자동 귀속 확정) / `/a10-reject N` (유지보수·미태깅 처리)
> 수동 귀속: `/a10-confirm N PRJ-YYYY-NNN` (다른 PRJ로 이동)

## 실행: 2026-04-18 09:15 (범위 2026-04-17)

| # | SHA | 레포 | 브랜치 | 저자 | 시각 | 메시지 | 추정 PRJ | 점수 | 신호 내역 |
|---|-----|------|--------|------|------|--------|---------|------|-----------|
| 1 | d9106ea | amaranth10-kiss | develop | 박선명 | 14:22 | 메일게시판 줌인 작업 | PRJ-2026-003 | 68 | JIRA0 경로40 담당30 주보0 키워드0 브랜치0 −2 (동점감점) |
| 2 | ...  | ... | ... | ... | ... | ... | ... | ... | ... |
```

**필드 명세**:
- `#`: 큐 내부 순번 (매 실행마다 1부터 재시작)
- `SHA`: 7자리 short hash (`/a10-confirm` 인자로 사용 가능)
- `신호 내역`: 6신호 개별 점수 표기 (디버깅·규약 학습 용도)

매 `/a10-git-daily` 실행 시 이 파일은 **덮어쓰기**된다 (누적 아님). 미결 항목은
다음 실행 전까지 처리하거나, 처리 안 하면 다음 실행 시 동일 커밋에 대해 다시
큐에 올라온다.

## 학습 레이어 (v0.9.0 기본형)

**`douzone-forge/projects/_mapping-history.md`**

```markdown
# 매핑 결정 히스토리

| 일자 | SHA | 레포 | 저자 | 메시지 요약 | 추정 PRJ | 점수 | 결정 | 실제 PRJ |
|------|-----|------|------|-------------|---------|------|------|----------|
| 2026-04-18 | d9106ea | amaranth10-kiss | 박선명 | 메일게시판 줌인 | PRJ-2026-003 | 68 | auto | PRJ-2026-003 |
| 2026-04-18 | a1b2c3d | klago-ui-crm-micro | 이혜영 | mode:local 수정 | PRJ-2026-001 | 45 | reject | (유지보수) |
```

**결정 값**:
- `auto`: 70점 이상 자동 귀속
- `confirm`: 사용자가 `/a10-confirm`으로 승인
- `confirm-override`: `/a10-confirm N PRJ-...`로 다른 PRJ 지정
- `reject`: `/a10-reject`로 기각 (유지보수 or 미태깅으로 강등)
- `reject-maint`: 기각 + 유지보수 로그로 이동

이 파일은 v0.9.2 피드백 루프에서 가중치 자동 조정에 사용된다(향후).

---

## STEP 4~8 확장 (v0.2.0 — 3-way 크로스 체크 + .forge 주입)

커밋 수집 이후 단계를 확장한다. `--no-triage` 옵션으로 비활성 가능.

### STEP 4: JIRA 키 추출 & 분류

각 커밋 메시지에 대해 `a10-jira-classifier` 스킬 호출:
- 매칭된 프리픽스 → 트랙(유지보수/고도화/검수/미분류)
- 유지보수 트랙 커밋은 해당 `{모듈}/유지보수/{YYYYMMDD}-{JIRA키}-검토안.md` 존재 여부 체크
- 미분류 커밋은 `meta/reports/unclassified-jira.md` 에 append (결정 6)

### STEP 5: 3-way 조인

JIRA 키 기준으로 **검토안 × 커밋 × 일일보고** 조인:
- 일일보고 소스: `douzone-forge/deliverables/보고서/일일보고/원본캐시/YYYY-MM/*.md` frontmatter `jira_keys`
- 8케이스 매트릭스 산정 (상세는 `/a10-triage-status` 참조)

### STEP 6: 자동 상태 전이 (결정 1)

커밋이 도달한 브랜치별로 검토안 frontmatter `status` 갱신:
- develop → 개발중 / devqa → 설계검수 / sqa → QA / master → 배포완료
- 배포완료→처리완료 는 자동 전이 **금지** (수동 `/a10-triage-close`)

검토안 `## 📊 진행 로그` 테이블에 해당 일자 행 append.

### STEP 7: 이상 리포트

- **케이스 4 지연 경고**: 수용 후 7일 무커밋 (결정 2)
- **케이스 6 자동 초안**: 커밋만 있고 검토안·일일보고 없음 → `/a10-triage --auto-draft {JIRA키}` 자동 호출 (결정 3)
- **케이스 5 알림**: 커밋+일일보고 있지만 검토안 없음 → 알림만, 자동 초안 ❌
- **고도화 트랙 자동 스텁**: `KLAGOP1/A10D/UCAIMP` 새 키 발견 시 `{모듈}/tasks/enhancements/` 스텁 생성 (결정 7 — `_dashboard.md` 등록은 사용자 승인 필요)

### STEP 8: `.forge/` 브리지 호출

`a10-forge-bridge` 실행:
- 진행 중 건 주입 (수용·개발중·설계검수·QA)
- 완료·기각 건 제거
- `.gitignore` 가드

### 옵션
- `--no-triage` — STEP 4~8 생략 (커밋 수집만)
- `--no-bridge` — STEP 8 (`.forge/`) 만 생략
