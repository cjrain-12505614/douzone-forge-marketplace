---
name: a10-excel-reviewer
description: >
  This skill should be used when the user provides an Excel workbook (.xlsx, .xlsm) and asks to
  "엑셀 분석해줘", "숨김 시트 확인해줘", "워크북 구조 파악해줘", "엑셀에서 context 뽑아줘",
  "병합셀 확인해줘", "검수시나리오 엑셀 읽어줘", "WBS 엑셀 분석해줘",
  또는 Excel 파일의 구조(숨김 시트, 병합셀, 데이터 검증 등)를 파악하고
  Amaranth 10 context/history/tasks로 변환할 때.
  Google Sheets가 아닌 .xlsx/.xlsm 파일 기반 정밀 분석 스킬이다.
version: 0.1.0
---

# 엑셀 리뷰어 (Excel Reviewer)

엑셀 워크북을 읽어, 보이는 데이터뿐 아니라 숨김 시트, 병합 구조, 데이터 검증,
시트 메타까지 포함한 구조를 Amaranth 자산으로 바꾸는 스킬이다.

## 사용할 때

- `.xlsx` 또는 `.xlsm` 파일 경로를 받았을 때
- 구글시트 URL만으로는 숨김 탭이나 구조를 정확히 볼 수 없을 때
- 검수 시나리오, WBS, backlog가 엑셀 파일로 전달됐을 때
- 병합셀, 숨김 시트, 드롭다운 값, 시트 상태가 중요한 경우

## 역할 구분

- 구글시트 URL/MCP 기반 검토는 `sheets-manager` 스킬
- 엑셀 파일 기반 정밀 검토는 `excel-reviewer` 스킬

둘 다 있는 경우:
1. MCP로 전체 구조를 본다
2. 엑셀 파일로 숨김 시트와 정밀 구조를 검증한다

## 기본 원칙

1. 먼저 워크북 메타를 본다
2. 시트별 상태(visible, hidden)를 분리한다
3. 숨김 시트도 실제 맥락 자산 후보로 본다
4. 보이는 내용과 구조 메타를 따로 정리한다
5. 라이브러리 파싱이 깨지면 zip/xml fallback으로 최소 구조라도 복원한다

## 작업 순서

### 1. 메타 구조 확인

먼저 `scripts/inspect_workbook.py`를 실행한다:

```bash
pip install openpyxl --break-system-packages -q
python3 "${CLAUDE_PLUGIN_ROOT}/skills/excel-reviewer/scripts/inspect_workbook.py" "{엑셀파일경로}"
```

이 단계에서 확인:
- 시트명 목록, 숨김 시트 여부
- 행/열 개수, 병합셀 개수
- 숨김 행/열 개수, 데이터 검증 개수

### 2. 파싱 경로 선택

- `openpyxl`이 정상 동작하면 셀 값을 읽는다
- `openpyxl`이 실패하면 zip/xml fallback 결과를 우선 사용한다
- fallback에서는 최소한 아래를 확보한다:
  - 시트 목록, 숨김 여부
  - 일부 worksheet XML 미리보기
  - 병합/데이터검증 존재 여부

fallback 기준은 `references/fallback-strategy.md`를 본다.

### 3. 시트 유형 판별

엑셀 안의 시트도 아래 분류를 우선 적용한다:
- **검수 시나리오형**: PASS/FAIL 드롭다운, 테스트 케이스 구조
- **요구사항 WBS형**: 상위 묶음 + 하위 세부행, 날짜/진행률/담당자
- **통합 WBS형**: 월별 일정축, 프로젝트 묶음 반복
- **오류/개선 backlog형**: 카테고리/항목 교차, 우선순위/일정

판별 기준은 `references/workbook-signals.md`를 본다.

### 4. Amaranth 자산화

| 내용 유형 | 저장 위치 |
|---------|---------|
| 기능 구조와 규칙 | `context/` |
| 변경 배경과 요청 흐름 | `history/requests/` |
| 검수/WBS/운영 요약 | `history/reports/` |
| 진행형 후속 작업 | `tasks/_current.md`, `tasks/enhancements/*.md` |

### 5. 최종 정리

최종 답변에는 아래를 포함한다:
- 읽은 파일 경로
- 시트 목록과 숨김 시트 목록
- 주요 유형 분류
- 생성/수정한 파일
- 파싱 제약 또는 추가 자료 필요 여부

## 출력 규칙

- 숨김 시트는 별도 섹션으로 반드시 적는다
- 병합셀과 데이터 검증이 중요한 시트는 그 사실을 남긴다
- 파싱 실패가 있으면 어느 경로(openpyxl 또는 zip/xml fallback)를 썼는지 적는다
- 구조가 복잡해 값 해석이 불완전하면 csv 재내보내기나 해당 시트 캡처를 요청한다

## 참고 파일

- 워크북 신호와 판별 기준: `references/workbook-signals.md`
- 파싱 실패 대응: `references/fallback-strategy.md`
- 워크북 메타 점검 스크립트: `scripts/inspect_workbook.py`


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
