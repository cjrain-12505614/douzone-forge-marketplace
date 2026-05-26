---
name: dz-personal-init
description: "_개인/ 골격 + 자기 조직 폴더 4계층 자동 lookup (xlsx 13번 ID) + _index.md 자동 채움 + 본인 R&R 자동 정착 + 직책 체크 시 팀트래킹 신설 + .gitignore + git 신원(Amaranth 10 ID)·core.hooksPath 자동 (v0.5.0)"
version: 0.5.0
---

# /dz-personal-init 커맨드 (Phase Q-2 v0.3.0 + Phase V V-07-04 v0.4.0 확장)

신규 사용자 첫 도입 시 워크스페이스에 `_개인/` 골격 + 자기 조직 폴더 4계층 자동 셋업 + **본인 R&R 자동 정착**.

## v0.3.0 확장 (Q-12)

기존 v0.2.0 (`_개인/` 빈 폴더 신설)에서 다음 4 단계 추가:

1. **dz-people-index 호출** — 사용자 ID(xlsx 13번 컬럼) 기반 본인 매핑 조회
2. **4계층 lookup** — `조직/{본부}/{Unit}/{Cell}/{이름}_{ID}/` 폴더 신설 (D9 변천사 일관)
3. **_index.md 자동 채움** — frontmatter (ID·사번·이름·직급·소속·R&R) 기본 메타
4. **직책 체크** — "하위 멤버 존재 + 상위 직책자" 식별 시 `_개인/팀트래킹/` 자동 신설

## v0.4.0 확장 (V-07-04 — V-05 갭 1-2 해결, 본인 R&R 자동 정착)

본인 R&R 자가 확보 흐름을 다음 단계로 정착:

5. **본인 R&R 자가 확보** — xlsx 13번 동적 lookup 결과를 `_개인/{본인이름_사번}/_R&R.md` 본문에 박음. 일일보고·dz-people-context 등 후속 스킬이 본 메타 파일을 lookup하여 본인 부하 직원 명단 자동 식별.

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
# 예: ~/Workspace/douzone-forge
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

dz-people-index Skill을 호출하여 본인 ID 기반 다음 메타 자가 확보:
- 본인 한글 이름
- 본인 사번 (xlsx 22번)
- 본인 부서 4계층 (본부 / Unit / Cell / 본인)
- 본인 직급
- 본인 R&R (한 문장 — module-overview.md 또는 _index.md 매핑 기반)
- 본인 직속 상관 (Cell 멤버 → Cell 리더 / Cell 리더 → Unit장 / Unit장 → 본부장)
- 본인 부하 직원 목록 (직책자만 — Cell 리더 / Unit장 / 본부장)

#### 5.2 `_개인/{본인이름_사번}/_R&R.md` 본문 정착

`_개인/{본인이름}_{사번}/_R&R.md` 파일을 신설하고 본문 6 섹션 표준 구조로 박음:

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
```

→ 본 _R&R.md 파일은 **개인 영역** (`_개인/`)에 저장되어 GitLab 동기화 미대상. 본인 로컬에서만 lookup.

#### 5.3 후속 스킬 의존 명시

본 _R&R.md 파일은 다음 후속 스킬·룰이 lookup하여 본인 부하 직원 명단 자동 식별:
- **dz-people-context** — 본인 종합 현황 lookup 시 `_개인/{본인이름_사번}/_R&R.md` 우선 참조 (xlsx 직접 lookup 대체)
- **dz-cascade-from-report** — 일일보고 보고 대상 자동 식별 시 본 메타 §4 "부하 직원" 섹션 사용
- **dz-personal-tracking** — 트래킹 노트 작성 시 본 메타 §4 부하 직원 ID 매핑

본 _R&R.md 파일이 없으면 후속 스킬은 fallback으로 xlsx 13번 동적 lookup 직접 호출.

#### 5.4 _R&R.md 신설 가이드 출력

```
✅ _개인/{본인이름_사번}/_R&R.md 본인 R&R 메타 신설 완료:
  - xlsx 13번 ID 동적 lookup 기반 6 섹션 자동 채움
  - 본인 부하 직원 명단 자동 식별 (직책자 한정)
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
- (c)·(d) 정착 후 세션 시작 시 자동 받기(pull), 종료/정리 시 자동 올리기(push)가 동작한다 (엔진: `hooks/dz-gitlab-sync.sh`, 정책 §6).

### 8. 검증 출력

```
✅ _개인/ 골격 초기화 완료:
  - sessions/{활성 모듈}/ + archive/ 신설
  - 임시조사·학습메모·개인프로젝트·기타 신설
  - _개인/{본인이름_사번}/_R&R.md 본인 R&R 메타 자동 정착 (V-07-04)
  - .gitignore 등록 확인
  - git 신원([UC]이름/{Amaranth10ID}@douzone.com) + core.hooksPath 비밀훅 자동 설정 (v0.5.0)
  - 세션 자동 동기화 기본값(pull.rebase·rebase.autoStash·credential.helper) 설정 (rc.17)

⚠️ _current.md 는 자연 신설 — 본인 작업 시점에 Claude가 자동 작성 (Step 3.5 패턴 일관)
⚠️ _R&R.md 본문 정독 후 §2 본인 R&R 한 문장 보강 검토 (xlsx 매핑이 본인 실제 R&R과 차이 가능)

다음 액션:
- /dz-start-session 으로 첫 세션 시작
- /dz-people-index 사번 매핑 SSoT 확인 (douzone-forge 마운트 필수)
- /dz-people-context 본인 종합 현황 첫 호출 — _R&R.md 정합 검증
```

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
