# amaranth10-claude-forge

Amaranth 10 모듈 개발을 위한 업무 맥락 관리 프레임워크.
GNB/LNB 메뉴 계층 구조를 기반으로 모듈 컨텍스트를 분할 관리하고, 기획·설계 단계를 체계적으로 지원합니다.

---

## 개념

모듈 전체 컨텍스트를 한 번에 로드하려 하면 Claude의 컨텍스트 창 한계에 부딪힙니다.
amaranth10-claude-forge는 **GNB/LNB 메뉴 단위로 컨텍스트를 분할**해, 작업하는 기능에 필요한 맥락만 정밀하게 주입합니다.

```
항상 로드   →  module-overview.md + conventions.md  (모듈 전체 요약)
GNB 작업 시 →  {GNB}/_overview.md 추가 로드
LNB 작업 시 →  {GNB}/{LNB}.md 추가 로드
```

---

## 핵심 개념 — tasks vs sessions 구분

| 구분 | 위치 | 목적 | 관리 주체 |
|-----|------|------|---------|
| `tasks/` | `[모듈]/tasks/` | 실제 업무 관리 (고도화 건, 일정, 담당자) | PM / 기획자 |
| `sessions/` | `_개인/sessions/{모듈}/` | 에이전트 작업 진행 상황 (어디까지 분석했는지) | Claude 에이전트 자동 관리 |

**에이전트 세션 체크포인트 원칙:**
에이전트는 명시적 커맨드 없이도 작업 시작 전·후에 자동으로 `_개인/sessions/{모듈}/_current.md`를 읽고 씁니다.
토큰 소진·네트워크 순단으로 세션이 끊겨도 다음 세션에서 이어서 작업할 수 있습니다.

---

## 구성 요소

### 스킬

| 스킬 | 트리거 | 역할 |
|-----|--------|------|
| `context-manager` | "컨텍스트 로드", "GNB/LNB 구조로 정리" | 컨텍스트 파일 구조 안내 및 관리 방법론 제공 |
| `feature-planning` | "기능 기획", "스펙 작성", "요구사항 정리" | 로드된 컨텍스트 기반 기능 스펙 생성 |
| `session-manager` | "세션 저장", "이어서 하자", "저번에 뭐 했지" | 에이전트 작업 진행 상황 저장·복원 |
| `sheets-manager` | "시트 불러와줘", "WBS 확인해줘", "구글 시트 동기화" | Google Sheets MCP로 WBS·이슈·시나리오 조회 및 tasks 연동 |

### 커맨드

| 커맨드 | 사용법 | 역할 |
|-------|--------|------|
| `/load-context` | `/load-context modules/법무관리(LTE)/소송관리/소송등록` | GNB/LNB 경로로 컨텍스트 파일 로드 |
| `/update-context` | `/update-context modules/법무관리(LTE)/소송관리/소송등록` | 작업 완료 후 컨텍스트 파일 자동 업데이트 |
| `/feature-spec` | `/feature-spec 계약서 버전 관리` | 로드된 컨텍스트 기반 기능 스펙 문서 생성 |
| `/add-task` | `/add-task 법무관리 계약서OCR인식` | 새 고도화 건 등록 및 _current.md 반영 |
| `/load-tasks` | `/load-tasks 법무관리` | 현재 고도화 업무 목록 로드 |
| `/update-task` | `/update-task 법무관리 가온요구사항` | 진행 중인 고도화 건 진행률·상태 업데이트 |
| `/load-history` | `/load-history 법무관리 2차` | 개발 히스토리/요구사항 이력 로드 |
| `/save-session` | `/save-session 법무관리` | 현재 에이전트 진행 상황을 _개인/sessions/{모듈}/_current.md에 저장 |
| `/resume-session` | `/resume-session 법무관리` | 이전 세션 상황 복원 및 다음 단계 제안 |
| `/load-from-sheet` | `/load-from-sheet wbs 법무관리` | Google Sheets에서 WBS·이슈·시나리오 현황 조회 |
| `/sync-sheets` | `/sync-sheets 법무관리` | 시트 데이터 → 로컬 tasks 파일 동기화 |

---

## 사용 방법

### 1단계: 모듈 컨텍스트 파일 준비

`templates/context/` 아래 템플릿을 복사해 모듈별 컨텍스트 파일을 만듭니다.

```
{모듈명}/
├── module-overview.md     ← templates/context/module-overview.md 복사 후 작성
├── conventions.md         ← templates/context/conventions.md 복사 후 작성
└── context/
    └── {GNB명}/
        ├── _overview.md   ← templates/context/gnb-overview.md 복사 후 작성
        └── {LNB명}.md     ← templates/context/lnb-detail.md 복사 후 작성
```

### 2단계: 작업 시작 시 컨텍스트 로드

```
/load-context 법무관리/소송관리/소송등록
```

### 3단계: 기획 작업

```
/feature-spec 소송 문서 일괄 다운로드
```

### 4단계: 작업 완료 후 컨텍스트 업데이트

```
/update-context 법무관리/소송관리/소송등록
```

---

## 적용 가능 모듈

이 프레임워크는 Amaranth 10의 모든 모듈에 적용 가능합니다.
모듈별로 컨텍스트 파일만 채우면 동일한 방식으로 사용할 수 있습니다.

- 법무관리 (법무법인용 / 기업법무팀용)
- CRM
- 게시판
- 업무관리 (KISS)
- 통합연락처

---

## 개발 단계 (claude-forge 연계)

기획·설계·운영은 amaranth10-claude-forge로 관리하고, 실제 코드 개발은 claude-forge를 사용합니다.
더존 코드 컨벤션은 `conventions.md`를 claude-forge 세션에 참고 파일로 주입해 사용합니다.

---

## 파일 구조

```
amaranth10-claude-forge/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── context-manager/SKILL.md
│   ├── feature-planning/SKILL.md
│   ├── session-manager/SKILL.md   ← 에이전트 세션 관리
│   ├── history-manager/SKILL.md
│   ├── task-manager/SKILL.md
│   ├── context-analyzer/SKILL.md
│   └── sheets-manager/SKILL.md   ← Google Sheets MCP 연동
├── commands/
│   ├── load-context.md
│   ├── update-context.md
│   ├── feature-spec.md
│   ├── add-task.md
│   ├── load-tasks.md
│   ├── update-task.md             ← 고도화 건 진행률·상태 업데이트
│   ├── load-history.md
│   ├── save-session.md            ← 세션 저장
│   ├── resume-session.md          ← 세션 복원
│   ├── load-from-sheet.md         ← Google Sheets 조회
│   └── sync-sheets.md             ← 시트 → 로컬 동기화
├── templates/
│   ├── context/
│   ├── history/
│   ├── tasks/
│   └── sessions/
│       └── session-progress.md    ← 세션 진행 상황 템플릿
└── README.md
```

### 모듈 작업 폴더 구조 (워크스페이스)

```
[모듈명]/
├── module-overview.md
├── context/[GNB명]/
├── history/
├── tasks/              ← 실제 업무 관리 (PM/기획자 관리)
│   ├── _current.md
│   └── enhancements/
└── sessions/           ← 에이전트 진행 상황 (Claude 자동 관리)
    ├── _current.md
    └── archive/
```
