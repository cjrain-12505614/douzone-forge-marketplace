---
name: a10-sheets-manager
description: >
  This skill should be used when the user asks to "시트 불러와줘", "WBS 확인해줘",
  "요구사항 진행률 알려줘", "오류 현황 보여줘", "검수 시나리오 확인해줘",
  "Google Sheets에서 읽어줘", "시트 동기화해줘", "구글 시트로 현황 알려줘",
  또는 Google Sheets에 저장된 WBS·이슈·시나리오 데이터를 조회하거나 로컬 tasks와 연동할 때.
  google-sheets MCP 도구와 sheets-config.json을 사용해 모든 모듈에 공통 적용된다.
version: 0.2.0
---

# Google Sheets 연동 관리자 (Sheets Manager)

amaranth10-claude-forge와 연동된 Google Sheets를 읽고 로컬 tasks/context와 연결하는 방법론.
**모든 모듈에 공통 적용**되며, 연동 설정은 `amaranth10-claude-forge/sheets-config.json`에서 관리한다.

---

## 전제 조건

1. `google-sheets` MCP 가용 확인 (`mcp__google-sheets__list_sheets` 호출 가능 여부)
2. `amaranth10-claude-forge/sheets-config.json` 로드 → 이후 모든 spreadsheet_id·컬럼 정보를 여기서 읽음
3. MCP 미연결 시 → "google-sheets MCP가 연결되어 있지 않습니다." 안내 후 중단

---

## sheets-config.json 구조 이해

```json
{
  "sheets": {
    "[시트키]": {
      "spreadsheet_id": "...",
      "type": "team-wbs | customer-wbs | issue-tracker | test-scenarios",
      "module": "모듈명 (단일 모듈 전용 시트)",
      "module_sheets": { "모듈명": "시트탭명" },  // type=team-wbs일 때
      "local_task_file": "tasks/...",              // 동기화 대상 로컬 파일 (상대 경로, 모듈폴더 기준)
      "columns": { "header_row": N, "컬럼명": "열문자" },
      "read_range": "B{header_row}:R200"
    }
  },
  "module_index": {
    "모듈명": ["시트키1", "시트키2"]              // 모듈 → 연관 시트 역방향 조회
  }
}
```

**새 시트 추가 방법:** `sheets-config.json`에 항목 추가만 하면 됨. 플러그인 수정 불필요.

---

## MCP 도구 사용법

### 시트 목록 조회
```
mcp__google-sheets__list_sheets(spreadsheet_id)
```

### 범위 읽기
```
mcp__google-sheets__get_sheet_data(
  spreadsheet_id = config["sheets"][시트키]["spreadsheet_id"],
  sheet_name = ...,      // config에서 읽거나 list_sheets로 확인
  range = "B5:R200"     // config["read_range"] 참조 (header_row 치환)
)
```

### 여러 시트 일괄 읽기
```
mcp__google-sheets__get_multiple_sheet_data([
  { "spreadsheet_id": ..., "sheet_name": ..., "range": ... },
  ...
])
```

### 셀 업데이트
```
mcp__google-sheets__update_cells(
  spreadsheet_id, sheet_name,
  range = "H12",
  values = [["75%"]]
)
```

---

## 시트 타입별 읽기 패턴

### type: team-wbs (SBUnit WBS)

```python
# 1. 모듈명 → 시트탭명 조회
sheet_name = config["module_sheets"][모듈명]

# 2. 헤더 행부터 읽기
header_row = config["columns"]["header_row"]  # 5
range = f"B{header_row}:R200"

# 3. 파싱: 구분(B)이 있는 행 = 묶음 헤더, 세부업무(D)가 있는 행 = 데이터
```

출력 예시:
```
[{모듈명}] 2026년 WBS  (조회: YYYY-MM-DD)
─────────────────────────────────────
{구분}
  {세부업무}   컨셉{H}% 설계{L}% 개발{P}%   {G}/{K}/{O}
```

### type: customer-wbs (고객 요구사항 WBS)

```python
# 1. 메인 시트 읽기
sheet_name = config["main_sheet"]
header_row = config["columns"]["header_row"]  # 10
range = f"A{header_row}:P200"

# 2. 파싱: A컬럼이 숫자인 행만 실제 요구사항
#    이모지(🔴🟡🟢)로 시작하는 행 = 묶음 구분 헤더 → 건너뜀
```

출력 예시:
```
{title} ({customer})  총 {N}건
─────────────────────────────────────
🔴 A묶음 (핵심)
  #1  {요구사항명}  {우선순위}  {설계담당자}  컨셉{H}% 설계{K}% 개발{P}%
```

### type: issue-tracker (이슈 트래커)

```python
# 1. 메인 시트 읽기
sheet_name = config["main_sheet"]
header_row = config["columns"]["header_row"]  # 6
range = f"B{header_row}:I500"

# 2. 파싱: B컬럼(no)이 비어있으면 건너뜀
```

출력 예시:
```
{title}  총 {N}건
─────────────────────────────────────
No.  메뉴              내용                우선순위  설계    개발
1    영업조직도설정     마스터 권한 미조회   높음     미정    미정
```

### type: test-scenarios (검수 시나리오)

```python
# 1. 먼저 시트 목록 = 기능 목록
mcp__google-sheets__list_sheets(spreadsheet_id)

# 2. 특정 기능 시트 읽기
range = config["read_range"]  # "A1:J200"
# 행1~4: 요약 통계 (개발검수율, 설계검수율)
# 행5~: 테스트 케이스 (A=통합ID, J=결과)
```

---

## 시트 리뷰 기능 (Google Sheets Reviewer)

구글시트를 탭별로 전체 분석해 context/history/tasks에 반영 가능한 형태로 변환한다.
단순 데이터 조회를 넘어, 시트 구조를 해석하고 Amaranth 자산으로 매핑하는 기능이다.

### 사용할 때

- "이 구글시트 전체 탭 분석해줘"
- "WBS 시트 구조 파악하고 context에 반영해줘"
- "검수시나리오 시트 읽어서 리포트 만들어줘"
- "오류/개선 backlog 시트 정리해줘"

### 리뷰 작업 순서

**1단계 — 탭 목록 파악**

```
MCP 도구: list_sheets(spreadsheet_id)
→ 모든 탭명 확인
```

**2단계 — 탭 유형 분류**

각 탭을 아래 4가지로 우선 분류한다:

| 유형 | 신호 |
|------|------|
| 검수 시나리오형 | 통합테스트 ID, PASS/FAIL, 테스트 케이스 |
| 요구사항 WBS형 | 고객사명+요구사항, 설계/개발/검수/배포 열 |
| 통합 WBS형 | 월별 일정축, 담당자/진행률, 모듈별 탭 |
| 오류/개선 backlog형 | 오류, 개선사항, 우선순위, 출처 |

**3단계 — 탭별 핵심 추출**

```
MCP 도구: get_sheet_data(spreadsheet_id, range) 또는 get_multiple_sheet_data
→ 탭별 데이터 읽기
```

유형별 추출 항목:
- **검수 시나리오형**: 메뉴/기능명, 테스트 케이스 수, PASS/FAIL/검수불가/보완, 결함내용
- **요구사항 WBS형**: 요구사항명, 설계/개발/검수 상태, 목표일, 담당자, 진행률, 현재 병목
- **통합 WBS형**: 프로젝트/모듈/업무 축, 담당자, 일정, 지연 구간
- **backlog형**: 메뉴, 개선/오류 내용, 우선순위, 출처

> 요구사항 WBS형에서는 상위 묶음 행과 하위 세부 요구사항 행을 분리해서 읽는다.
> 같은 이슈가 여러 탭에 반복되면 하나로 묶고 출처 탭만 병기한다.

**4단계 — Amaranth 자산으로 매핑**

| 내용 유형 | 저장 위치 |
|---------|---------|
| 기능 사실, 화면 구조, 규칙 | `context/` |
| 변경 이유, 고객 요구, 설계 배경 | `history/requests/` |
| 운영 요약, 검수 요약, WBS 요약 | `history/reports/` |
| 현재 진행 항목, 후속 작업 | `tasks/_current.md`, `tasks/enhancements/*.md` |

**5단계 — 최종 정리**

답변에 포함할 내용:
- 읽은 탭 목록과 유형
- 핵심 발견사항 (진행형 문서는 `YYYY-MM-DD 기준` 상태 함께 명시)
- 생성/수정한 파일
- 확인이 더 필요한 자료

### 리뷰 출력 규칙

- 전체 탭 검토 완료 여부를 명확히 적는다
- 검수 시나리오는 전체 건수보다 미완료/검수불가/결함을 우선 요약한다
- 원문 표를 그대로 복사하지 말고, 사실/상태/후속 액션으로 구조화한다
- 진행형 자료는 반드시 기준 날짜를 남긴다

### 시트 유형 상세 판별 기준

참고: `references/sheet-types.md`

---

## 모듈별 연관 시트 조회

특정 모듈의 모든 시트를 조회할 때:
```python
# sheets-config.json의 module_index 활용
sheet_keys = config["module_index"][모듈명]
# → 해당 모듈과 연관된 모든 시트 키 목록
# → 각 키로 config["sheets"][키] 접근
```

---

## 로컬 tasks 연동

각 시트의 `local_task_file` 필드가 동기화 대상 로컬 파일을 지정한다.
경로는 `[모듈폴더]/` 기준 상대 경로.

| 시트키 | local_task_file | 동기화 방향 |
|-------|----------------|------------|
| `가온-요구사항-wbs` | `tasks/enhancements/가온-요구사항.md` | 시트 → 로컬 |
| `crm-issues` | `tasks/_current.md` | 시트 → 로컬 참조 |
| `sbunit-wbs` | (모듈별 `tasks/_current.md`) | 시트 → 로컬 참조 |
| `가온-검수-시나리오` | null (읽기 전용) | 조회만 |

`local_task_file: null`인 시트는 읽기 전용(조회만 가능, 동기화 미지원).

---

## 오류 처리

| 상황 | 대응 |
|-----|------|
| MCP 미연결 | 안내 후 중단. Python 직접 API 호출 불가(VM 네트워크 차단) |
| 403 Forbidden | token 만료 → 사용자에게 token 갱신 안내 |
| 시트탭명 불일치 | list_sheets로 현재 목록 확인 후 `sheets-config.json` 업데이트 필요 알림 |
| 새 모듈 시트 추가 필요 | `sheets-config.json`에 항목 추가 안내 (플러그인 수정 불필요) |


## 마크다운 링크 규칙 (필수)

마크다운 파일 작성·업데이트 시 **모든 경로·파일 참조는 클릭 가능한 상대 링크**로 작성한다.

```markdown
# 나쁜 예 (클릭 불가)
법무관리/tasks/_current.md에서 확인

# 좋은 예 (클릭 가능)
[법무관리/tasks/_current.md](../법무관리/tasks/_current.md)에서 확인
```

- 상대 경로는 현재 파일 위치 기준
- 코드블록 안의 폴더 구조 다이어그램은 예외 (링크 불필요)
- 상세 규칙은 douzone-forge CLAUDE.md의 "마크다운 링크 표기 규칙" 섹션 참조
