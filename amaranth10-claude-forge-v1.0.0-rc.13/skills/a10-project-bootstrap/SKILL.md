---
name: a10-project-bootstrap
description: >
  This skill should be used when the user says "새 프로젝트 시작", "CLAUDE.md 만들어줘",
  "프로젝트 초기 설정", "뭐부터 해야 해?", "프로젝트 세팅해줘", "init",
  "프로젝트 구조 잡아줘", "온보딩", "처음이야",
  or when starting a new project from scratch and needing to set up the workspace
  structure that all other plugin skills depend on.
  Creates module folders, project files, and guides the user through initial setup.
version: 0.3.0
---

# Project Bootstrap

douzone-forge에 새 모듈 또는 새 프로젝트를 초기화하는 스킬.

## 왜 필요한가

이 플러그인의 모든 스킬과 커맨드는 douzone-forge의 모듈별 분산 구조에 의존한다.
새 모듈이나 프로젝트를 시작할 때 표준 구조를 먼저 갖춰야 다른 기능이 제대로 동작한다.

### 핵심 의존 관계

| 파일/폴더 | 의존하는 스킬/커맨드 |
|---------|-------------------|
| `CLAUDE.md` (루트) | session-protocol, status-reporter, 전체 |
| `projects/_dashboard.md` | project-tracker, status-reporter, session-protocol |
| `[모듈]/module-overview.md` | context-manager, context-analyzer |
| `_개인/sessions/{모듈}/_current.md` | session-protocol, session-manager |
| `[모듈]/tasks/_current.md` | task-manager |
| `[모듈]/context/` | context-manager, context-analyzer |
| `[모듈]/history/` | history-manager |

## 두 가지 초기화 유형

### 유형 A: 새 모듈 초기화

기존에 없는 모듈 폴더를 douzone-forge에 생성한다.

#### 워크스페이스 표준 구조

```
[모듈명]/
├── module-overview.md      ← 모듈 전체 개요, 라이선스 구분, GNB 목록
├── context/                ← GNB/LNB 기능 컨텍스트
│   └── [GNB명]/
│       ├── _overview.md
│       └── [LNB명].md
├── history/                ← 개발 이력·의사결정
│   ├── _timeline.md
│   ├── phases/
│   ├── requests/
│   ├── plans/
│   ├── meetings/
│   └── reports/
├── tasks/                  ← 고도화 업무 관리
│   ├── _current.md
│   └── enhancements/
├── sessions/               ← 에이전트 작업 체크포인트 (Claude 자동 관리)
│   ├── _current.md
│   └── archive/
└── 문서/                   ← 원본 문서 보관
    ├── INDEX.md
    ├── 01_신규/
    ├── 02_삭제가능/
    └── 03_장기참조/
```

#### Step 1: 기본 정보 수집
사용자에게 질문한다:
1. **모듈명**: 어떤 모듈인가?
2. **라이선스 구분**: 라이선스에 따라 기능이 다른가?
3. **주요 GNB 목록**: 초안 수준으로 파악된 메뉴 목록
4. **담당자**: 개발자/설계자 (조직구조.md 참조)

#### Step 2: 폴더 구조 생성
```bash
mkdir -p [모듈명]/context
mkdir -p [모듈명]/history/{phases,requests,plans,meetings,reports}
mkdir -p [모듈명]/tasks/enhancements
mkdir -p [모듈명]/sessions/archive
mkdir -p "[모듈명]/문서"/{01_신규,02_삭제가능,03_장기참조}
```

#### Step 3: 초기 파일 생성
- `module-overview.md` — 기본 정보, 라이선스 구분, GNB 목록, 빠른 네비게이션 링크
- `문서/INDEX.md` — 빈 문서 인덱스
- `history/_timeline.md` — 빈 타임라인
- `tasks/_current.md` — 빈 업무 목록
- `_개인/sessions/{모듈}/_current.md` — 초기 세션 체크포인트

#### Step 4: 연쇄 업데이트 (Cascade R1)
- douzone-forge CLAUDE.md의 모듈 관련 섹션을 확인하고 필요 시 갱신

#### Step 5: 온보딩 안내
설계서 PDF가 있으면 `a10-context-analyzer`로 분석 시작을 권장.
스크린샷만 있으면 운영 화면 분석부터 시작.

### 유형 B: 새 프로젝트 등록

`projects/`에 새 프로젝트 파일을 생성한다.

#### Step 1: ID 채번
`projects/_dashboard.md`에서 최신 ID를 확인하고 아래 규칙으로 다음 순번 부여.

- **신규 규칙** (2026-04-20~, 단일 모듈 귀속 PRJ): `PRJ-{YYYY}-{모듈코드}-{NNN}` — 모듈별 독립 채번
  - 모듈 코드: LTE, CRM, KISS, BOARD, AB, GA, PUB, DSPORTS (상세는 `_dashboard.md` "ID 채번 규칙")
  - 예: 법무관리 2026년 10번째 → `PRJ-2026-LTE-010`
- **구규칙** (수명업무·크로스모듈 등): `PRJ-{YYYY}-{NNN}` — 연도 내 전체 누적

#### Step 2: 기본 정보 수집
1. **프로젝트명**
2. **유형**: 고객대응 / 고도화 / 크로스모듈 / 수명업무 / 사이트
3. **관련 모듈**
4. **기간**
5. **PM / 담당자**

#### Step 3: 프로젝트 파일 생성
`projects/_templates/project-detail.md`를 복사하여 채번 규칙에 맞는 파일명으로 생성 (신규 `PRJ-{YYYY}-{모듈코드}-{NNN}_{프로젝트명}.md` 또는 구규칙 `PRJ-YYYY-NNN_{프로젝트명}.md`).
01. 프로젝트 개요와 02. TASK 목록 초안을 작성.

#### Step 4: 연쇄 업데이트 (Cascade R2)
- `projects/_dashboard.md`에 행 추가
- 해당 모듈 `tasks/_current.md`에 프로젝트 참조 추가
- PRJ `04. 연결 정보`에 관련 모듈 context/, history/, 문서/INDEX.md, _tech-reference.md 링크 추가

## 어떤 커맨드를 언제 쓰는가

| 상황 | 커맨드 |
|------|--------|
| 모듈/프로젝트 처음 시작 | `/a10-init-project` |
| 지금 뭐 해야 하지? | `/a10-guide` |
| 세션 시작 | `/a10-start-session` |
| 세션 끝날 때 | `/a10-end-session` |
| 현황 보고 | `/a10-status` |
| 의사결정 기록 | `/a10-decision` |
| 에이전트 투입 | `/a10-dispatch 하준 경쟁사 조사` |
| 교훈 기록 | `/a10-lesson 내용` |
| 설계서 분석 | context-analyzer 스킬 |
| 맥락 로드 | `/a10-load-context` |

## 마크다운 링크 규칙 (필수)

마크다운 파일 작성·업데이트 시 **모든 경로·파일 참조는 클릭 가능한 상대 링크**로 작성한다.

- 상대 경로는 현재 파일 위치 기준
- 코드블록 안의 폴더 구조 다이어그램은 예외 (링크 불필요)
- 상세 규칙은 douzone-forge CLAUDE.md의 "마크다운 링크 표기 규칙" 섹션 참조
