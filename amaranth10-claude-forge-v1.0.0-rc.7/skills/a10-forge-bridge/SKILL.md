---
name: a10-forge-bridge
description: >
  douzone-forge의 진행 중 유지보수·고도화 건을 Workspace_a10 소스 레포의 `.forge/`
  디렉토리에 경량 복제본으로 주입한다. 개발자가 IDE에서 즉시 소비 가능한 50줄 이내
  요약을 생성. "포지 브리지 돌려줘", ".forge 동기화", "소스 레포에 검토안 반영"
  요청 시 사용. 진행 중(수용·개발중·설계검수·QA)만 주입하고 완료·기각 건은 제거한다(결정 5).
version: 0.1.0
---

# Forge Bridge — 설계 맥락 → 소스 레포 주입

douzone-forge의 검토안·고도화 태스크를 소스 레포 루트의 `.forge/` 디렉토리에
**경량 복제**로 주입하여 개발자가 IDE에서 즉시 참조할 수 있게 한다.

## 주입 대상

### 유지보수 트랙
- 원본: `douzone-forge/{모듈}/유지보수/{YYYYMMDD}-{JIRA키}-검토안.md`
- 조건: 판정 = `수용` / `수용(조건부)` **AND** 진행상태 ∈ {수용, 개발중, 설계검수, QA}
- 제외: 진행상태 ∈ {배포완료, 처리완료, 기각}

### 고도화 트랙
- 원본: `douzone-forge/{모듈}/tasks/enhancements/{TASK}.md`
- 조건: 상태 ∈ {진행중, 설계검수, QA}

## 대상 레포 매핑 (모듈 → 레포)

`a10-git-daily` SKILL의 모듈→레포 테이블 재사용. 주입 대상은 **BE/FE 각 레포 루트**.

| 모듈 | 주입 대상 레포 |
|---|---|
| 법무관리 | `amaranth10-lte`, `klago-ui-lte-micro` |
| CRM | `amaranth10-crm`, `amaranth10-crmgw`, `klago-ui-crm-micro`, `klago-crm-mobile` |
| 업무관리 | `amaranth10-kiss`, `klago-ui-kiss-micro` |
| 게시판 | `amaranth10-board`, `klago-ui-board-micro` |
| 통합연락처 | `amaranth10-ab`, `klago-ui-ab-micro` |

MCP 레포·퍼블리싱 레포는 주입 대상 **제외** (기능 로직 비보유).

## 디렉토리 구조 (각 레포 루트)

```
.forge/
├── README.md                       ← 자동 생성 (갱신 일시, 관리 규칙)
├── maintenance/
│   ├── _index.md                   ← 진행 중 검토안 인덱스
│   └── {YYYYMMDD}-{JIRA키}.md      ← 경량 복제본 (~50줄)
└── enhancements/
    ├── _index.md
    └── {TASK}.md
```

## 경량 복제 규칙

원본(전체) → `.forge/` (요약 50줄)
- 포함: 접수 개요, 판정, 원인 가설 1순위, 수정 방향 1순위, 선행 조사, 최근 진행 로그 3행
- 제외: 판단 체크리스트 상세, 이관 판단, 고객사 회신 초안, 서명
- 말미에 **원본 링크** 명시: `douzone-forge/{모듈}/유지보수/{파일}.md`

템플릿은 [`a10-maintenance-triage/templates/lite-review.md`](../a10-maintenance-triage/templates/lite-review.md) 참조.

## 실행 절차

### STEP 1: 진행 중 건 수집
- `douzone-forge/{모듈}/유지보수/_index.md` 파싱 → 진행상태 컬럼으로 필터
- `douzone-forge/{모듈}/tasks/enhancements/` 스캔 → frontmatter `status` 확인

### STEP 2: 모듈 → 레포 해석

### STEP 3: `.forge/` 주입

각 대상 레포에 대해:
1. `.forge/maintenance/` 또는 `.forge/enhancements/` 디렉토리 보장
2. 경량 복제본 생성 (`lite-review.md` 템플릿)
3. `_index.md` 갱신 (진행 중 건만)
4. `.forge/README.md` 갱신 (타임스탬프 + 규칙 안내)

### STEP 4: 폐기 건 제거

진행상태 = 배포완료·처리완료·기각인 파일은 `.forge/` 에서 **삭제** (원본은 douzone-forge에 보존).

### STEP 5: .gitignore 가드

각 대상 레포의 `.gitignore` 를 확인:
- `.forge/` 항목이 없으면 **맨 끝에 추가**
- 이미 있으면 스킵
- 개발자가 `.forge/` 내용을 실수로 커밋하는 것을 방지

```
# amaranth10-claude-forge bridge (do not commit)
.forge/
```

## 입력 인수

- `--module {모듈명}` — 특정 모듈만
- `--dry-run` — 주입 없이 대상 목록만 출력
- `--cleanup-only` — 폐기 건 제거만 수행

## 출력 보고

```
🌉 Forge Bridge 실행 완료 (2026-04-20 14:00)

주입:
  amaranth10-board
    .forge/maintenance/20260420-CSA10-44921.md (신규)
    .forge/maintenance/20260420-CSA10-44945.md (갱신)
  klago-ui-board-micro
    .forge/maintenance/20260420-CSA10-44921.md (신규)

제거 (완료/기각):
  amaranth10-lte
    .forge/maintenance/20260301-CSA10-40000.md (배포완료)

.gitignore 가드: 2개 레포에 `.forge/` 항목 추가
```

## 주의

- `.forge/` 는 **커밋 금지 영역**. `.gitignore` 주입을 반드시 수행
- 원본(`douzone-forge/`) 은 **절대 수정하지 않는다** — 읽기 전용 복제
- 개발자가 `.forge/` 를 수정해도 다음 실행 시 덮어쓰기됨 (피드백은 douzone-forge 원본에 반영해야 함)
- 듀얼 마운트 전제 — Workspace_a10 경로 접근 불가 시 해당 레포 스킵
