---
name: dz-personal-init
description: "_개인/ 골격 + 자기 조직 폴더 4계층 자동 lookup (xlsx 13번 ID) + _index.md 자동 채움 + 본인 R&R 자동 정착 + 본인 부서 맥락 진입점 자동 정착 + 직책 체크 시 팀트래킹 신설 + .gitignore + git 신원(Amaranth 10 ID)·core.hooksPath 자동 + MCP(jira·a10) 등록·⛔인증 게이트(건너뛰기 금지 — jira 편집기 입력 안내·a10 크롬 자동 시드 자비스 주도) + 얕은 클론(--depth 1) 온보딩 표준 인지 + 본인 식별 신호 우선순위 폴백 (v0.10.3)"
version: 0.10.3
---

# /dz-personal-init 커맨드 (Phase Q-2 v0.3.0 + Phase V V-07-04 v0.4.0 + 시나리오 B v0.6.0 + 인증 게이트 v0.10.0 확장)

신규 사용자 첫 도입 시 워크스페이스에 `_개인/` 골격 + 자기 조직 폴더 4계층 자동 셋업 + **본인 R&R 자동 정착 + 본인 부서 맥락 진입점 자동 정착**.

## v0.3.0 확장 (Q-12)

기존 v0.2.0 (`_개인/` 빈 폴더 신설)에서 다음 4 단계 추가:

1. **dz-people-index 호출** — 사용자 ID(xlsx 13번 컬럼) 기반 본인 매핑 조회
2. **4계층 lookup** — `조직/{본부}/{Unit}/{Cell}/{이름}_{ID}/` 폴더 신설 (D9 변천사 일관)
3. **_index.md 자동 채움** — frontmatter (ID·사번·이름·직급·소속·R&R) 기본 메타
4. **직책 체크** — "하위 멤버 존재 + 상위 직책자" 식별 시 `_개인/팀트래킹/` 자동 신설

## v0.4.0 확장 (V-07-04 — V-05 갭 1-2 해결, 본인 R&R 자동 정착)

본인 R&R 자가 확보 흐름을 다음 단계로 정착:

5. **본인 R&R 자가 확보** — xlsx 13번 동적 lookup 결과를 `_개인/{본인이름}_{ID}/_R&R.md` 본문에 기록. 일일보고·dz-people-context 등 후속 스킬이 본 메타 파일을 lookup하여 본인 부하 직원 명단 자동 식별.

## v0.6.0 확장 (시나리오 B — CLAUDE.md 보편화 cascade, 2026-05-27)

본인 부서 맥락 자동 로드 진입점을 `_R&R.md` 본문에 추가 정착:

6. **본인 부서 맥락 진입점 자동 정착** — 본인 Unit `_README.md`·본인 Cell `_README.md`·본인 담당 모듈 `module-overview.md` 링크를 `_R&R.md` §7로 자동 채움. CLAUDE.md(워크스페이스 보편 운영 지침)에서 SBUnit 한정 R&R(담당 모듈·Bizbox Alpha 범위·모바일 개발 방식·관리대상 레포 등)이 본인 Unit `_README.md`로 이전된 시점부터 세션 시작 시 본인 부서 맥락이 본 §7 진입점을 통해 자동 로드된다.

  - 다른 Unit 사용자 호환: 본인 본부·Unit·Cell이 어디든(SBUnit·공통UCUnit·QAUnit 등) 4계층 lookup 결과에 따라 본인 Unit `_README.md` 경로가 동적으로 정착됨.
  - 본인 담당 모듈 자동 식별: 본인 Cell의 담당 영역(예: SB개발Cell = 법무·CRM·사이트)을 `_README.md`에서 lookup하여 module-overview 링크 자동 첨부.

## v0.10.0 확장 (⛔ 인증 게이트 — 2026-07-02, 온보딩 실측 보완)

실제 임직원 온보딩 실측에서 **MCP 등록까지는 되는데 자격증명 인증(§8.3 jira 입력·§8.5 a10 시드)을 건너뛰어 진행이 멈추는 사례가 다발**했다 — 명시적 지시가 문서에 없으면 자비스가 인증 단계를 생략하고, 크롬 확장이 미연결이면 조용히 통과해 버린다. 이를 막기 위해:

7. **⛔ 인증 게이트** — §8 서두에 건너뛰기 금지 게이트 신설. 자가 진단(§9)에서 jira·a10 자격증명이 ✅로 확인되기 전에는 §8을 완료로 선언하지 않는다.
8. **jira 인증 자비스 주도 3단계** — 편집기 열기 → 입력 안내·완료 응답 대기 → 채움 확인(값 미열람) (§8.3).
9. **a10 인증 자비스 주도 5단계** — 크롬 확장 연결 판정 → 미연결 시 설치·재연결 안내(설치·로그인 후에도 미연결이면 클로드 데스크탑 앱 ⌘Q 완전 종료 재시작) → A10 로그인 판정 → 쿠키 시드 → 검증 (§8.5).

## 의존 SSoT

| 항목 | SSoT |
|------|------|
| `_개인/` 정의 | ST Step 1.5 + 02-Bfix (`_personal/` → `_개인/` 한글 전환) |
| 활성 9 모듈 (Step 3.5) | 법무관리(LTE)·CRM·게시판(BOARD)·업무관리(KISS)·통합연락처(AB)·공통·ONE AI·퍼블리싱·D-Sports |
| 공용/개인 경계 정책 | `규칙/프로세스/공용-개인-경계-규칙.md` |
| 개인영역 git 가드 | `rules/personal-area-guard.md` (G7, PT-02 신설) |

## 실행 절차

### 1. 사용자 워크스페이스 루트 확인

```bash
pwd
# 예: ~/Workspace/douzone-forge · ~/douzone 등 본인 클론 위치 (경로 비종속 — 워크스페이스 안 모든 자동화 동작)
```

### 2. `_개인/` 디렉토리 신설 (멱등)

```bash
mkdir -p _개인
```

이미 존재 시 보존 (Q4 (A) 빈 폴더만 정책 일관 — 덮어쓰기 안 함).

### 3. `_개인/sessions/{모듈}/` 9 폴더 신설 (Step 3.5 활성 9 모듈)

```bash
for m in "법무관리(LTE)" "CRM" "게시판(BOARD)" "업무관리(KISS)" "통합연락처(AB)" "공통" "ONE AI" "퍼블리싱" "D-Sports"; do
  mkdir -p "_개인/sessions/${m}"
  mkdir -p "_개인/sessions/${m}/archive"
done
```

각 모듈별 빈 폴더만 생성. **`_current.md` 는 자연 신설** (Q4 (A) — Claude가 첫 작업 체크포인트 저장 시점에 자동 작성).

### 4. `_개인/{기타 골격}/` 신설 (선택)

```bash
mkdir -p _개인/임시조사
mkdir -p _개인/학습메모
mkdir -p _개인/개인프로젝트
mkdir -p _개인/기타
```

본인 사용 시점에 자유롭게 활용 (사용자ID 매핑.md `_개인/_README.md` §3 참조).

### 5. 본인 R&R 자동 정착 (V-07-04 v0.4.0 신설)

본 단계는 V-05 갭 1-2 (본인 부하 직원 자동 lookup 미정착) 해결을 위함.

#### 5.1 xlsx 13번 ID 동적 lookup으로 본인 식별

```bash
# 사용자ID-매핑 SSoT 의존
# 위치: 규칙/프로세스/사용자ID-매핑.md §2 단축 안내 (Q-01 표준)
# 본인 ID = xlsx 13번 컬럼 "사원명(ID)"
# 본인 사번 = xlsx 22번 컬럼
```

**본인이 누구인지의 신호 우선순위 (v0.10.3 신설 — 질문 없이 자가 식별 우선)**: lookup의 입력이 되는 "본인"은 아래 순서로 확보하고, 상위 신호가 있으면 질문하지 않는다.

1. `git config user.email` — `{ID}@douzone.com` 형식이면 ID 확정 (이미 신원이 정착된 클론)
2. `git credential fill` — GitLab 원격에 저장된 계정명에서 ID 후보 확보
3. 대화 맥락 — 사용자가 이름·ID를 이미 밝혔으면 그 값 사용
4. 위 신호가 전부 없을 때만 **1문 질문** ("성함 또는 Amaranth 10 ID를 알려주세요")

dz-people-index Skill을 호출하여 본인 ID 기반 다음 메타 자가 확보:
- 본인 한글 이름
- 본인 사번 (xlsx 22번)
- 본인 부서 4계층 (본부 / Unit / Cell / 본인)
- 본인 직급
- 본인 R&R (한 문장 — module-overview.md 또는 _index.md 매핑 기반)
- 본인 직속 상관 (Cell 멤버 → Cell 리더 / Cell 리더 → Unit장 / Unit장 → 본부장)
- 본인 부하 직원 목록 (직책자만 — Cell 리더 / Unit장 / 본부장)

#### 5.2 `_개인/{본인이름}_{ID}/_R&R.md` 본문 정착

`_개인/{본인이름}_{ID}/_R&R.md` 파일을 신설하고 본문 7 섹션 표준 구조로 기록 (v0.6.0 §7 본인 부서 맥락 진입점 추가):

> **폴더명 정본 = `{이름}_{ID}`** (ID = xlsx 13번 사원명(ID), Amaranth 10 ID — **사번 아님**. 예: `차민수_cjrain`). 근거: 사용자ID-매핑.md §1 Q-01 표준(ID 최우선) + 같은 문서 폴더명 예시(`신무광_smkgood2`) + 조직 트리·`_개인/` 정착 실측 전건 일치 (2026-07-03 재실행 실측, v1.11.3 정정 — 종전 `{이름}_{사번}` 표기는 D9 변천사 어휘 잔존이었음). 사번(xlsx 22번)은 frontmatter `사번:` 메타로만 기록.

```markdown
---
이름: {한글 이름}
사번: {xlsx 22번}
ID: {xlsx 13번 사원명(ID)}
부서: {본부}/{Unit}/{Cell}
직급: {직급}
직책: {Cell 리더 / Unit장 / 본부장 / 멤버}
갱신일: YYYY-MM-DD
---

# 본인 R&R — {한글 이름} ({직급})

## 1. 본인 식별
- ID: {xlsx 13번}
- 사번: {xlsx 22번}
- 부서 4계층: {본부} / {Unit} / {Cell} / {본인}
- 직급: {직급}

## 2. 본인 R&R (한 문장)
{한 문장 R&R 요약 — module-overview.md 또는 조직 _index.md 매핑 기반}

## 3. 직속 상관
- {상관 이름} ({상관 ID}) — {상관 직책}

## 4. 부하 직원 (직책자만 작성)
{Cell 리더 / Unit장 / 본부장만 작성. 멤버는 본 섹션 생략 가능}
- {부하 이름} ({부하 ID}) — {부하 직책 / 소속 Cell}
- ...

## 5. 담당 모듈 (R&R 기반)
{Cell 리더 / 설계자 / 개발리더 시 본인 담당 모듈 명시}
- {모듈명} — {역할: 설계자 / 개발리더 / Cell 리더 / 멤버}

## 6. 변천사
- YYYY-MM-DD — dz-personal-init v0.4.0 자동 정착
- YYYY-MM-DD — dz-personal-init v0.6.0 §7 본인 부서 맥락 진입점 자동 정착 (시나리오 B cascade)

## 7. 본인 부서 맥락 진입점 (v0.6.0 신설 — 세션 시작 시 본 _R&R.md 다음으로 로드)

> 본 워크스페이스 CLAUDE.md(보편 운영 지침)에서 Unit 한정 R&R(담당 모듈·Bizbox Alpha 범위·모바일 개발 방식·관리대상 레포 등)이 본인 Unit `_README.md`로 이전됨. 세션 시작 시 본 §7 진입점을 통해 본인 부서 맥락이 자동 로드된다.

- **본인 본부**: [`{본부} _README.md`](../../조직/{본부}/_README.md) — 본부 메타 + 변천사 + 1·2센터 구조 (해당 시)
- **본인 Unit**: [`{Unit} _README.md`](../../조직/{본부}/{Unit}/_README.md) — Unit R&R 자산 (담당 모듈·Bizbox Alpha 범위·모바일 개발 방식·작업 범위·관리대상 레포 매핑 등)
- **본인 Cell**: [`{Cell} _README.md`](../../조직/{본부}/{Unit}/{Cell}/_README.md) — Cell 인원 + Cell 담당 영역
- **본인 담당 모듈 module-overview** (Cell 담당 영역에서 동적 lookup):
  - {모듈명1} — [`Amaranth10/{모듈1}/module-overview.md`](../../Amaranth10/{모듈1}/module-overview.md)
  - {모듈명2} — [`Amaranth10/{모듈2}/module-overview.md`](../../Amaranth10/{모듈2}/module-overview.md)
  - ...
- **본인 Unit 관리대상 레포** (해당 시): [`{Unit}/_관리레포-매핑.md`](../../조직/{본부}/{Unit}/_관리레포-매핑.md)

> 본인 부서·Cell·담당 모듈 변경 시 `/dz-personal-init` 재실행으로 본 §7 경로 자동 갱신.
```

→ 본 _R&R.md 파일은 **개인 영역** (`_개인/`)에 저장되어 GitLab 동기화 미대상. 본인 로컬에서만 lookup.

#### 5.3 후속 스킬 의존 명시

본 _R&R.md 파일은 다음 후속 스킬·룰이 lookup하여 본인 부하 직원 명단 자동 식별:
- **dz-people-context** — 본인 종합 현황 lookup 시 `_개인/{본인이름}_{ID}/_R&R.md` 우선 참조 (xlsx 직접 lookup 대체)
- **dz-cascade-from-report** — 일일보고 보고 대상 자동 식별 시 본 메타 §4 "부하 직원" 섹션 사용
- **dz-personal-tracking** — 트래킹 노트 작성 시 본 메타 §4 부하 직원 ID 매핑

본 _R&R.md 파일이 없으면 후속 스킬은 fallback으로 xlsx 13번 동적 lookup 직접 호출.

#### 5.4 _R&R.md 신설 가이드 출력

```
✅ _개인/{본인이름}_{ID}/_R&R.md 본인 R&R 메타 신설 완료:
  - xlsx 13번 ID 동적 lookup 기반 7 섹션 자동 채움 (v0.6.0: §7 본인 부서 맥락 진입점 추가)
  - 본인 부하 직원 명단 자동 식별 (직책자 한정)
  - 본인 부서 맥락 진입점 자동 정착 (본부·Unit·Cell _README + 담당 모듈 module-overview)
  - 후속 스킬(dz-people-context·dz-cascade-from-report·dz-personal-tracking) lookup 의존

⚠️ Beta 사용자는 본 _R&R.md 본문 정독 후 본인 R&R 한 문장(§2) 보강 검토 필요.
   xlsx 매핑이 본인 실제 R&R과 차이 있으면 본 _R&R.md를 SSoT로 보강.
```

### 6. `.gitignore` 자동 추가 (해당 시)

워크스페이스 루트 `.gitignore` 에 `_개인/` 라인이 없으면 자동 추가:

```bash
if ! grep -q "^_개인/" .gitignore 2>/dev/null; then
  echo "" >> .gitignore
  echo "# 개인 영역 — GitLab 동기화 금지 (ST Step 1.5)" >> .gitignore
  echo "_개인/" >> .gitignore
  echo "✅ .gitignore 에 _개인/ 라인 추가"
fi
```

### 7. git 신원 + 비밀 스캔 훅 + 세션 동기화 기본값 자동 설정 (v0.5.0 신설 / rc.17 동기화 확장)

§5.1 lookup 결과(이름·Amaranth 10 ID·본부)로 워크스페이스 git 신원·비밀 스캔 훅·세션 동기화 기본값을 멱등 설정. **user.name·이메일은 Amaranth 10 ID 기반 — 사번 아님** (SSoT: [`Forge-GitLab-운영가이드.md`](../../규칙/프로세스/Forge-GitLab-운영가이드.md) §2·§6 · [`사용자ID-매핑.md`](../../규칙/프로세스/사용자ID-매핑.md)).

```bash
# (a) 본부 → prefix: ERP개발본부 = [ERP], 그 외(DWP개발본부 등 UC) = [UC]
PREFIX="[UC]"   # 본인 본부가 ERP개발본부면 "[ERP]"
git config user.name  "${PREFIX}{본인 한글 이름}"        # 예: [UC]차민수
git config user.email "{Amaranth10ID}@douzone.com"      # xlsx 13번 사원명(ID) — 사번 아님 (예: cjrain@douzone.com)

# (b) 비밀 스캔 pre-commit 훅 활성화 (멱등) + 한글 경로 NFC
if [ -d .githooks ]; then git config core.hooksPath .githooks; fi
git config core.precomposeunicode true

# (c) 세션 자동 동기화 기본값 (rc.17) — 받기는 rebase, 받기 전 로컬 변경은 자동 임시보관 후 복원
git config pull.rebase true
git config rebase.autoStash true

# (d) 자격증명 저장 (macOS 키체인) — push 때마다 비밀번호를 다시 묻지 않도록
git config credential.helper osxkeychain   # Windows면 manager, Linux면 store 등 OS별 치환
```

- `.git` 미초기화(설치만 한 경우)면 본 단계 건너뜀. 이미 설정돼 있어도 멱등 덮어쓰기.
- 이로써 **clone → 플러그인 설치 → `dz-personal-init` 한 번**으로 신원·비밀훅·세션 동기화·개인영역이 모두 정착.
- clone은 **얕은 클론(`git clone --depth 1`)이 온보딩 표준**(2026-07-22 경량화 2단계 — 수신 ~0.7GiB·디스크 점유 ~1.8GiB 실측). 얕은 클론에서도 본 단계 (a)~(d)와 동기화 엔진(pull·push)이 전부 정상 동작(실측). 과거 이력이 필요하면 `git fetch --unshallow` 1회 — 본 커맨드 동작에는 영향 없음(멱등). 근거: 워크스페이스 `규칙/프로세스/바이너리-원본-원챔버-보존-정책.md` §3
- (c)·(d) 정착 후 세션 시작 시 자동 받기(pull), 종료/정리 시 자동 올리기(push)가 동작한다 (엔진: `hooks/dz-gitlab-sync.sh`, 정책 §6).

### 8. MCP 서버 등록 (jira·a10) + 자격증명 인증 (v0.7.0 / v0.8.0 내장 / v0.9.0 a10·S3 / v0.10.0 ⛔인증 게이트)

**워크스페이스 내장** jira-mcp(`.jira-mcp/`)·a10-mcp(`.a10-mcp/`)를 Claude Code(`~/.claude.json`) + Cowork(`claude_desktop_config.json`) **양쪽에 등록**한다. 본체가 워크스페이스에 있어(GitLab 클론에 포함) **플러그인 버전과 무관 — 경로가 고정**이라 플러그인을 업데이트해도 등록이 안 깨진다(구 동봉 방식의 "Could not attach" 결함 해소). Cowork 는 플러그인 `.mcp.json` 자동로드를 안 하므로(검증됨), 본 단계가 양쪽 설정 파일을 직접 써서 등록한다.

> ### ⛔ 인증 게이트 (v0.10.0 — 건너뛰기 금지)
>
> §8.0~§8.6은 **전부 순차 실행 의무**다. 특히 **자격증명 인증(§8.3 jira 입력·§8.5 a10 시드)은 "등록"과 별개의 완수 대상**이다 — 등록만 하고 인증을 건너뛰면 MCP 도구가 전부 무용지물이 되고, 실측상 대부분의 온보딩 중단이 여기서 발생했다.
>
> 1. **건너뛰기 금지** — 사용자가 명시적으로 "보류"를 선언하지 않는 한, 인증이 확인될 때까지 §8을 완료로 선언하지 않는다.
> 2. **실패 = 종료가 아니라 안내** — 전제 미충족(크롬 확장 미연결·A10 미로그인·uv 미설치 등)이면 **그 자리에서 해결 절차를 사용자에게 안내**하고, 해결되면 이어서 재시도한다. 이 세션에서 해결이 불가하면 자가 진단(§9)에 ⬜ + 재시도 방법을 남긴다 — **말없이 건너뛰는 것을 금지**한다.
> 3. **완수 판정 = 자가 진단 ✅** — §9 체크리스트에서 "jira 자격증명 입력됨"·"a10 자격증명 시드됨"이 ✅여야 인증 완수다.

#### 8.0 런타임 점검 (uv·python — MCP 실행 전제)
```bash
command -v uvx >/dev/null 2>&1 \
  && echo "✅ uv 런타임 OK" \
  || echo "⚠️ uv 미설치 → 'curl -LsSf https://astral.sh/uv/install.sh | sh' 실행 후 재시도 (jira-mcp 실행에 필요)"
```

#### 8.1 워크스페이스 내장 launcher 경로 확보
```bash
WS="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"   # 워크스페이스 루트(1단계 확인 위치)
JIRA_LAUNCHER="$WS/.jira-mcp/bin/jira-launch.sh"
[ -x "$JIRA_LAUNCHER" ] || echo "⚠️ jira launcher 없음 ($JIRA_LAUNCHER) — GitLab 클론·워크스페이스 위치 확인"
```

#### 8.2 양쪽 설정에 jira 등록 (멱등)
```bash
python3 - "$JIRA_LAUNCHER" "$WS" << 'PYEOF'
import json, sys, os
launcher, ws = sys.argv[1], sys.argv[2]
entry = {"command": launcher, "args": [],
         "env": {"JIRA_ENV_FILE": os.path.join(ws, "_개인/.jira-mcp/.env")}}
targets = [os.path.expanduser("~/.claude.json"),
           os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")]
for p in targets:
    if not os.path.exists(p):
        continue
    cfg = json.load(open(p))
    cfg.setdefault("mcpServers", {})["jira"] = entry
    with open(p, "w") as f:
        json.dump(cfg, f, ensure_ascii=False, indent=2)
    print("✅ jira 등록:", p)
PYEOF
```

#### 8.3 jira 자격증명 — `.env` 생성 + 편집기 입력 안내 (자비스 주도 3단계, v0.10.0 게이트)
> ⚠️ **Write 도구 금지 — 반드시 bash 로 생성한다.** 그래야 Claude file-tracking(파일 변경 알림) 밖이라 직원이 채운 비밀번호가 Claude 에 노출되지 않는다. **Claude 는 `.env` 내용을 절대 Read 하지 않는다** — jira-mcp(프로그램)만 읽는다.

```bash
WS="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
mkdir -p "$WS/_개인/.jira-mcp"
ENV="$WS/_개인/.jira-mcp/.env"
if [ ! -f "$ENV" ]; then
  cat > "$ENV" << 'ENVEOF'
# JIRA 로그인 정보 — 아래 두 칸을 채우고 저장(Cmd+S) 후 이 창을 닫으세요
JIRA_USER=
JIRA_PASSWORD=
# ── 아래는 자동 설정 (수정 불필요) ──
JIRA_BASE_URL=http://jira.duzon.com:8080
JIRA_PROJECTS=BC10,CSA10
JIRA_MODULE_FIELD_ID=customfield_10825
JIRA_MODULES=연락처,게시판,업무관리,법무관리,CRM
JIRA_MAX_RESULTS=500
ENVEOF
  chmod 600 "$ENV"
fi
open -e "$ENV" 2>/dev/null || echo "텍스트편집기로 $ENV 를 열어 JIRA_USER/PASSWORD 를 채우세요"
```

**자비스 실행 지시 3단계 (건너뛰기 금지 — v0.10.0):**

1. **열기 + 안내** — 위 bash 실행으로 텍스트 편집기(macOS 기본 텍스트 편집기 — 윈도우의 메모장에 해당)가 열린다. 사용자에게 아래 안내를 **그대로 출력**한다:
   > 📝 방금 텍스트 편집기(메모장) 창이 열렸습니다. **JIRA_USER(사번)·JIRA_PASSWORD(비밀번호)** 두 칸만 채우고 **저장(Cmd+S)** 후 창을 닫아 주세요. 아래쪽 항목들은 자동 설정이니 그대로 두시면 됩니다. **입력을 마치시면 "됐어"라고 알려주세요 — 이어서 진행해 드립니다.**
2. **대기** — 사용자의 완료 응답을 기다린다. 완료 응답 전에 다음 단계(§8.4~)로 임의 진행하지 않는다.
3. **확인(값 미열람)** — 완료 응답을 받으면 **채워졌는지 여부만** 확인한다 (값은 절대 출력·열람 금지):
   ```bash
   WS="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
   ENV="$WS/_개인/.jira-mcp/.env"
   grep -q "^JIRA_USER=." "$ENV" && grep -q "^JIRA_PASSWORD=." "$ENV" \
     && echo "✅ jira 자격증명 입력 확인 — 새 세션부터 mcp__jira__* 도구 사용 가능" \
     || echo "⬜ 아직 비어 있음"
   ```
   ⬜이면 저장(Cmd+S)을 안 했거나 다른 파일을 연 경우가 대부분 — 1번 안내를 다시 출력하고 재대기한다.

- **uv(uvx — 파이썬 도구 실행기) 미설치 시** launcher 가 안내하므로 https://astral.sh/uv 설치 1회 필요(`curl -LsSf https://astral.sh/uv/install.sh | sh`).

#### 8.4 a10 launcher 경로 + 양쪽 설정 등록 (멱등)
```bash
WS="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
A10_LAUNCHER="$WS/.a10-mcp/bin/a10-launch.sh"
[ -x "$A10_LAUNCHER" ] || echo "⚠️ a10 launcher 없음 ($A10_LAUNCHER) — GitLab 클론·워크스페이스 위치 확인"
python3 - "$A10_LAUNCHER" "$WS" << 'PYEOF'
import json, sys, os
launcher, ws = sys.argv[1], sys.argv[2]
entry = {"command": launcher, "args": [],
         "env": {"A10_ENV_FILE": os.path.join(ws, "_개인/.a10-mcp/.env")}}
for p in [os.path.expanduser("~/.claude.json"),
          os.path.expanduser("~/Library/Application Support/Claude/claude_desktop_config.json")]:
    if not os.path.exists(p):
        continue
    cfg = json.load(open(p))
    cfg.setdefault("mcpServers", {})["a10"] = entry
    with open(p, "w") as f:
        json.dump(cfg, f, ensure_ascii=False, indent=2)
    print("✅ a10 등록:", p)
PYEOF
```

#### 8.5 a10 자격증명 — 크롬 쿠키 자동 시드 (자비스 주도 5단계, v0.10.0 게이트)
> a10 는 인증이 토큰 14키라 수동 입력 불가 — 크롬 A10 로그인 세션에서 자동 추출한다.
> **자비스가 아래 (1)~(5)를 직접 진행한다 — 사용자에게 명령을 복붙시키지 않는다.**
> **자격증명 값은 스크립트가 직접 `.env` 에 기록(Claude 미열람), 성공 여부만 출력.**

**(1) 크롬 확장 연결 판정** — 현재 세션 도구 목록에 `mcp__claude-in-chrome__*`(브라우저 MCP)가 있는지 확인한다.

- **케이스 A — 확장 미설치·미연결 (도구 없음)**: 아래 안내를 **그대로 출력**하고 본 단계를 이 자리에서 보류한다(§9 자가 진단에 ⬜ + 재시도 방법 기록). **말없이 건너뛰기 금지.**
  > 🔌 a10 인증에는 크롬 연결이 필요한데, 아직 크롬 확장이 연결되지 않았습니다. 아래 순서로 연결해 주세요:
  > 1. **Chrome을 실행**하고, Chrome 웹스토어에서 **Claude 확장(Claude in Chrome — Anthropic 공식)** 을 설치합니다.
  > 2. 확장 아이콘을 눌러 **Claude 계정으로 로그인**합니다.
  > 3. 연결이 되면 저에게 **"a10 인증 다시 해줘"** 라고 말씀해 주세요 — 이어서 진행해 드립니다.
- **케이스 B — 확장 설치·로그인까지 했는데도 연결 안 됨**: 앱↔확장 연결이 갱신되지 않은 상태다(온보딩 실측 다발). 아래 안내를 **그대로 출력**한다:
  > 🔁 확장 설치와 로그인까지 하셨는데도 연결이 안 될 때가 있습니다. **클로드 데스크탑 앱을 완전 종료(⌘Q)** 하신 뒤 다시 실행해 주세요. 새 세션에서 **"a10 인증 다시 해줘"** 라고 말씀해 주시면 이어서 진행해 드립니다.
- **연결됨(도구 있음)** → (2)로 진행.

**(2) A10 로그인 상태 판정** — 자비스가 크롬 MCP로 직접 `https://gwa.douzone.com` 탭을 열고(navigate) 페이지를 읽어(get_page_text 등) 로그인 여부를 판정한다. 아이디/비밀번호 입력 폼이 보이면 미로그인.
- **미로그인**: 아래 안내를 출력하고 사용자 응답을 대기한다:
  > 🔐 방금 연 크롬 탭에서 **Amaranth 10에 로그인**해 주세요. 로그인이 되면 **"됐어"라고 알려주세요 — 이어서 진행해 드립니다.**
  ⚠️ 비밀번호는 사용자가 직접 입력한다 — 자비스가 대신 입력하지 않는다(자격증명은 사람 몫).
- **로그인됨** → (3)으로 진행.

**(3) 쿠키 시드 실행** — 워크스페이스 내장 헬퍼(경로 고정 — GitLab 클론에 포함):

```bash
WS="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
A10_ENV_FILE="$WS/_개인/.a10-mcp/.env" \
  uvx --with browser-cookie3 python3 "$WS/.a10-mcp/scripts/seed_from_cookie.py"
```

- 실행 중 macOS가 **"Chrome Safe Storage" 키체인 접근 허용**을 물을 수 있다 — 사용자에게 "**허용**을 눌러 주세요(크롬 쿠키 복호화용, 최초 1회)" 안내.
- `oAuthToken/signKey 쿠키를 찾지 못했습니다` 출력 시 → 로그인이 안 됐거나 세션이 만료된 것 — (2)로 돌아가 재확인 후 재실행.

**(4) 시드 검증(값 미열람)** — 채워졌는지 여부만 확인한다:

```bash
WS="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
ENV="$WS/_개인/.a10-mcp/.env"
grep -q "^A10_OAUTH_TOKEN=." "$ENV" && grep -q "^A10_SIGN_KEY=." "$ENV" \
  && echo "✅ a10 자격증명 시드 완료" || echo "⬜ 시드 실패 — (2)부터 재시도"
```

**(5) 완료 안내** — 사용자에게 출력:
> ✅ a10 인증 완료 — **새 세션부터** `mcp__a10__*` 도구를 사용할 수 있습니다. **토큰 만료 시**(도구가 인증 오류를 낼 때) 크롬에서 A10 재로그인 후 **"a10 인증 다시 해줘"** 한 마디면 재시드해 드립니다.

#### 8.6 플러그인 자동 업데이트 활성 (v1.4.2 — 전 직원 상시 최신화)
> 커스텀 마켓플레이스는 자동 업데이트 기본 OFF라, 새 플러그인 버전이 나와도 각자 수동 업데이트해야 한다(누락 다발). 본 단계가 사용자 설정에 `autoUpdate: true`를 멱등 기록 → **시작 시 자동으로 최신 플러그인 적용**(맥락 동기화 v1.4.1 등 신규 기능이 수동 없이 전파).

```bash
python3 - << 'PYEOF'
import json, os
p = os.path.expanduser("~/.claude/settings.json")
os.makedirs(os.path.dirname(p), exist_ok=True)
cfg = {}
if os.path.exists(p):
    try: cfg = json.load(open(p))
    except Exception: cfg = {}
mk = cfg.setdefault("extraKnownMarketplaces", {})
entry = mk.setdefault("douzone-forge-marketplace", {})
entry.setdefault("source", {"source": "git",
    "url": "https://github.com/cjrain-12505614/douzone-forge-marketplace.git"})
entry["autoUpdate"] = True
with open(p, "w") as f:
    json.dump(cfg, f, ensure_ascii=False, indent=2)
print("✅ douzone-forge-marketplace autoUpdate 활성:", p)
PYEOF
```

- 이 설정 후부터 플러그인 신버전은 **자동 적용**(다음 시작 시). 새 훅·MCP 즉시 반영이 필요하면 `/reload-plugins`.
- ⚠️ 부트스트랩: 이 단계(8.6) 자체가 v1.4.2에 포함되므로, **각 직원은 딱 한 번 수동 업데이트**(`/plugin marketplace update douzone-forge-marketplace` → `/reload-plugins`) 후 dz-personal-init 재실행하면, 이후로는 전부 자동.

### 9. 환경 자가 진단 요약 (v0.7.0 — 멱등 점검 체크리스트)

모든 정착·점검 항목을 ✅/⬜ 로 출력. **재실행해도 된 항목은 ✅, 미충족만 ⬜ + 안내** — 직원이 본인 환경 상태를 한눈에 확인(관리자가 전직원 일일이 확인 불필요).

```bash
echo "═══════ dz-personal-init 자가 진단 ═══════"
WS="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
# 본인 정체성
find "$WS/_개인" -name "_R&R.md" 2>/dev/null | grep -q . && echo "✅ 본인 R&R 정착" || echo "⬜ 본인 R&R — §5 재실행"
# git 환경
git config user.name >/dev/null 2>&1 && echo "✅ git 신원" || echo "⬜ git 신원 — §7 (.git 미초기화면 정상)"
# 런타임
command -v uvx >/dev/null 2>&1 && echo "✅ uv 런타임" || echo "⬜ uv 미설치 → curl -LsSf https://astral.sh/uv/install.sh | sh"
python3 -c "import sys; exit(0 if sys.version_info>=(3,10) else 1)" 2>/dev/null && echo "✅ python 3.10+" || echo "⬜ python 3.10+ 필요"  # 버전 판정 — 이름 매칭(python3.10~3.12) 방식은 3.13+ 환경에서 거짓 ⬜ (v1.11.3 교정)
# 플러그인 버전
PV=$(ls -d "$HOME"/.claude/plugins/cache/douzone-forge-marketplace/douzone-forge/*/ 2>/dev/null | sort -V | tail -1 | xargs -I{} basename {})
echo "ℹ️ 플러그인 버전: ${PV:-미설치}"
# 플러그인 자동 업데이트 (§8.6)
python3 -c "import json,os; e=json.load(open(os.path.expanduser('~/.claude/settings.json'))).get('extraKnownMarketplaces',{}).get('douzone-forge-marketplace',{}); print('✅ 플러그인 자동업데이트 ON' if e.get('autoUpdate') else '⬜ 자동업데이트 OFF — §8.6 실행')" 2>/dev/null || echo "⬜ 자동업데이트 미설정 — §8.6"
# MCP 등록 (jira·a10)
python3 -c "import json,os; m=json.load(open(os.path.expanduser('~/.claude.json'))).get('mcpServers',{}); print('✅ jira MCP 등록' if 'jira' in m else '⬜ jira MCP 미등록 — §8'); print('✅ a10 MCP 등록' if 'a10' in m else '⬜ a10 MCP 미등록 — §8.4')" 2>/dev/null || echo "⬜ ~/.claude.json 확인 필요"
# 자격증명 (값 노출 없이 '채워졌는지'만)
{ [ -f "$WS/_개인/.jira-mcp/.env" ] && grep -q "^JIRA_PASSWORD=." "$WS/_개인/.jira-mcp/.env"; } 2>/dev/null && echo "✅ jira 자격증명 입력됨" || echo "⬜ jira .env — 편집기에서 ID/PW 채우기 (§8.3)"
{ [ -f "$WS/_개인/.a10-mcp/.env" ] && grep -q "^A10_OAUTH_TOKEN=." "$WS/_개인/.a10-mcp/.env"; } 2>/dev/null && echo "✅ a10 자격증명 시드됨" || echo "⬜ a10 — 크롬 로그인 후 seed 실행 (§8.5)"
# 사내망 접근
curl -s -m 5 -o /dev/null http://jira.duzon.com:8080 2>/dev/null && echo "✅ 사내망(jira) 접근" || echo "⬜ 사내망 접근 불가 — 사내망/VPN 연결 확인"
echo "═════════════════════════════════════════"
```

> **브라우저 MCP(크롬 확장)·코워크 MCP 연결**은 bash 로 판정할 수 없으므로 Claude 가 현재 세션 도구 목록으로 판정해 **체크리스트에 줄을 추가 출력**한다 (v0.10.0 의무):
> - 크롬 확장: `mcp__claude-in-chrome__*` 도구 존재 → "✅ 크롬 확장 연결" / 부재 → "⬜ 크롬 확장 미연결 — §8.5 (1) 케이스 A(웹스토어에서 Claude 확장 설치 → 확장 로그인 → 'a10 인증 다시 해줘'). 설치·로그인까지 했는데도 안 되면 케이스 B(클로드 데스크탑 앱 ⌘Q 완전 종료 후 재실행)"
> - 코워크 MCP: 세션에 a10·jira 등 MCP 도구 노출 여부로 판정(미노출이면 새 세션 권장).
> - **⬜가 하나라도 있으면 그 자리에서 해당 § 재시도 안내까지 출력한다 — 말없이 종료 금지 (⛔ 인증 게이트).**

⚠️ `_current.md` 는 자연 신설(본인 작업 시점 Claude 자동 작성) · `_R&R.md` 본문 정독 후 §2 한 문장 보강 검토.

**다음 액션** (⬜ 항목 처리 후): `/dz-start-session` 첫 세션 · `/dz-people-context` 본인 종합 현황 첫 호출.

## 멱등성

본 명령은 재실행 시 기존 폴더·파일을 **보존** 합니다 (덮어쓰기 안 함):
- `mkdir -p` — 이미 존재하면 무시
- `_current.md` — Q4 (A) 자연 신설 (본 명령에서 작성 안 함)
- `.gitignore` — 라인 없을 때만 추가

## 사용 시점

| 시점 | 사용 사례 |
|------|------|
| **Beta 3인 첫 도입** | SBUnit 3인 ({이름} + 2명) 첫 환경 셋업 — Step 11 진입 시 |
| **신규 사용자 환경 셋업** | 정식 배포 후 신규 인원 |
| **로컬 환경 재구축** | 디스크 재포맷·신규 PC 셋업 시 |

## 활성 모듈 변경 시 갱신 (R14 메모)

ST 결정으로 활성 모듈 추가/제거 시 본 명령 SKILL.md 활성 모듈 목록 동기화 필요. 다만 본 명령은 멱등이라 기존 사용자 환경 무영향 (덮어쓰기 안 함).

## 관련 스킬·커맨드

- `rules/personal-area-guard.md` (G7) — 개인 영역 git 가드 정책
- `skills/dz-people-index/` (G8) — 사번 SSoT 참조 (douzone-forge 필요)
- `skills/dz-personal-tracking/` (G9) — 관리자 트래킹 (사용자가 관리자인 경우)
- `commands/dz-start-session.md` — 첫 세션 시작
- `commands/dz-resume-session.md` — 세션 재개

## 관련 문서

- ST Step 1.5 산출 (`_개인/` 정의)
- ST Step 02-Bfix 산출 (한글 전환)
- ST Step 3.5 산출 (활성 9 모듈 + `_개인/sessions/{모듈}/` 이전)
- `_개인/_README.md` (사용자 가이드, 사용자 워크스페이스에 자연 신설)

## 관련 SSoT (Q-4 Q-18 양방향 인용)

본 명령은 Forge 초기화 가이드 7단계 중 **Step 2·3·4 자동 수행**:

- `규칙/프로세스/Forge-초기화-가이드.md` — Forge 첫 도입 7단계 SSoT (Q-18)
- `규칙/프로세스/리더-식별-룰.md` — Step 4 직책 체크 SSoT (Q-19) — 본 명령 v0.3.0 직책 체크 의존
- `규칙/프로세스/사용자ID-매핑.md` — Step 3 4계층 lookup SSoT

## 변천사

- ST Step 1.5 (2026-04-25) — `_개인/` 정의 + 공용/개인 경계 결정
- ST Step 02-Bfix (2026-04-25) — `_personal/` → `_개인/` 한글 전환
- ST Step 3.5 (2026-04-25) — 활성 9 모듈 sessions/ → `_개인/sessions/{모듈}/` 이전
- PT-02 (2026-04-26) — 본 명령 신설 (G10, Q4 (A) 빈 폴더만)
- Phase Q-2 Q-12 (2026-04-27) — v0.2.0 → v0.3.0 (4계층 lookup + _index 자동 + 직책 체크)
- **Phase Q-4 Q-18 (2026-04-27)** — Forge-초기화-가이드.md + 리더-식별-룰.md 양방향 인용 추가
- **Phase V V-07-04 (2026-05-11)** — v0.3.0 → v0.4.0 (본인 R&R 자동 정착 단계 추가 — V-05 갭 1-2 해결, `_개인/{본인이름_사번}/_R&R.md` xlsx 13번 동적 lookup 기반 6 섹션 자동 채움)
- **2026-05-17** — v0.4.0 → v0.4.1 (개인 영역 운영 모델 확정 사이클 정합 — 의존 SSoT 경로 `_CLAUDE/` → `규칙/` 정정 + `_개인/팀트래킹/` 개인 재분류 일관)
- **2026-05-27 (시나리오 B cascade)** — v0.4.1 → v0.6.0 (본인 부서 맥락 진입점 §7 자동 정착 추가 — CLAUDE.md에서 SBUnit 한정 R&R이 본인 Unit `_README.md`로 이전된 시점부터 세션 시작 시 본인 부서 맥락 자동 로드. 본 _R&R.md §7은 본인 본부·Unit·Cell `_README.md` + 담당 모듈 `module-overview.md` 링크를 4계층 lookup으로 동적 채움. 다른 Unit 사용자도 동일하게 본인 Unit·Cell 경로가 적용됨)
- **2026-07-02 (플러그인 v1.10.0)** — v0.7.0(frontmatter 방치분 — §8 내부 라벨은 v0.9.0까지 진행돼 있던 불일치 정정) → v0.10.0 (⛔ 인증 게이트 신설 — 배경: 실제 임직원 온보딩에서 MCP 등록 후 자격증명 인증을 건너뛰어 진행이 멈추는 사례 다발. ① §8 서두 건너뛰기 금지 게이트, ② §8.3 jira 자비스 주도 3단계(편집기 열기·안내 → 완료 응답 대기 → 채움 확인(값 미열람)), ③ §8.5 a10 자비스 주도 5단계(크롬 확장 연결 판정 → 미연결 케이스 A(확장 설치 안내)·케이스 B(설치·로그인 후에도 미연결 → 클로드 데스크탑 앱 ⌘Q 완전 종료 재시작 안내) → A10 로그인 판정 → 쿠키 시드 → 검증), ④ §9 크롬 확장 연결 체크 항목 + 말없이 종료 금지. 동반 조치: 시드 헬퍼 `.a10-mcp/scripts/seed_from_cookie.py` 워크스페이스 복원 — 2026-06-16 빌드본 전용 전환(b445ddf) 때 MCP 소스와 함께 오삭제되어 §8.5가 깨진 경로를 참조하고 있었음(a10 인증 실패의 근본 원인))
- **2026-07-03 (플러그인 v1.11.3)** — v0.10.0 → v0.10.1 (재실행 실측 결함 2건 교정: ① §9 python 버전 체크를 이름 매칭(`command -v python3.12||3.11||3.10`) → 버전 판정(`python3 -c "import sys; exit(0 if sys.version_info>=(3,10) else 1)"`)으로 교체 — python 3.13+ 설치 환경에서 거짓 ⬜(미충족) 오탐 해소. ② §5.2 폴더명 규정 `{본인이름}_{사번}` → `{본인이름}_{ID}` 정정(§5.3·§5.4·서두 요약 포함 5곳) — 정본 = {이름}_{ID}(ID = xlsx 13번 사원명(ID)). 판정 근거: 사용자ID-매핑.md §1 Q-01 ID 최우선 표준 + 같은 문서 폴더명 예시(신무광_smkgood2 = ID 형식) + 정착 실측(`_개인/차민수_cjrain/`·조직 트리 재적자 전건 {이름}_{ID}, 사번 형식은 archived 퇴사자 2건뿐). 동반: dz-people-context v0.3.1 동일 표기 4곳 정정. 참고: _R&R.md 변천사 "a10-personal-init" 스킬명 오타는 플러그인 원본에 부재(정착본 한정 오타 — 2026-07-03 재정착으로 이미 해소, 전 워크스페이스 grep 0건 확인). 잔여 과제: `조직/{이름_사번}` 표기(워크스페이스 CLAUDE.md·사용자ID-매핑.md 문구·dz-org-* 등 광범위)는 동일 계열 어휘 잔존 — 별도 승인 사이클로 이관)
