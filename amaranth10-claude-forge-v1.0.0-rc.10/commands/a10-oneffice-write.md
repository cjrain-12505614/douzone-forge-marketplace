---
name: a10-oneffice-write
description: "HTML 또는 대화 맥락을 원피스(ONEFFICE) 워드 문서로 end-to-end 작성"
---

# /a10-oneffice-write 커맨드

HTML 파일 또는 현재 대화 맥락을 원피스 워드 문서로 만들어준다.
새 문서 생성 → (선택) 단일페이지 전환 → HTML 주입 → 꺾쇠 정렬 → 문서명 변경 →
저장 → 검증까지 한 번에 실행.

## 사용 예

```
/a10-oneffice-write Amaranth10-forge-사용가이드.html
/a10-oneffice-write 오늘 회의 요약을 원피스 문서로 만들어줘
/a10-oneffice-write --long --title "2026 AI 위원회 3차 회의록"
/a10-oneffice-write --from ./report.md --title "주간 리포트"
```

## 옵션

| 옵션 | 설명 |
|------|------|
| `--long`, `--webpage` | 단일페이지 모드 (웹페이지형 긴 문서). 기본은 A4 다중페이지. |
| `--title "..."` | 문서명 지정. 생략 시 `YYMMDD_새 문서`. |
| `--from <경로>` | HTML 또는 Markdown 파일 직접 참조. 생략 시 현재 대화 맥락에서 합성. |

인자 없이 실행하면 현재 대화에서 "방금 만든 HTML/리포트/요약"을 찾아 사용한다.

## 실행 절차

### 1. 입력 정규화 → HTML 준비

- `--from` 이 HTML이면 그대로 사용
- `--from` 이 Markdown이면 HTML로 변환 (간단한 스타일 포함)
- 인자가 자연어면 대화 맥락에서 HTML 합성 (본문 + 인라인 style)
- 모든 경우 **script/nav/button/form** 만 제거하고 `<body>` 전체 구조 보존
- `/tmp/inject_body.html` 저장

### 2. 빈 문서 탭 확보 → 스킬 `a10-oneffice-new-doc-opener` 호출

- 기존 빈 원피스 워드 탭이 있으면 재사용
- 없으면 ONEFFICE HOME에서 새 문서 생성 후 탭 열기
- 편집모드까지 진입 확인

### 3. (옵션) 단일페이지 모드 전환

`--long` / `--webpage` 옵션이 있으면:
- 리본 → 파일 → 문서 설정 → 페이지 분리 → "단일 페이지" → 확인

### 4. HTML 주입 → 정렬 → 저장 → 스킬 `a10-oneffice-writer` 호출

writer 스킬의 Step 1.9 (편집모드 가드) → Step 3-5 (주입+정렬) → Step 6 (문서명) →
Step 7 (저장+새로고침 검증) 순서로 실행.

기본 프리셋(A4 세로 / 여백 보통 / 줌 130%)에서는 캐시된 정렬값(`-1px / 644px`)
즉시 적용. 정렬이 틀어지면 실측 fallback.

### 5. 문서명 설정

`--title` 이 있으면 해당 값, 없으면 오늘 날짜 기반 `YYMMDD_새 문서`.
React controlled input 대응 (native setter + input 이벤트 dispatch).

### 6. 읽기모드 전환 후 스크린샷 반환

저장·새로고침 검증 후 읽기모드로 나와 최종 결과 스크린샷을 사용자에게 제공.

## 인식 패턴 (자동 제안)

다음 표현이 등장하면 이 커맨드를 자동 제안·실행한다:

- "원피스로 ~작성해줘"
- "ONEFFICE 문서로 만들어줘"
- "웹페이지처럼 긴 원피스 문서"
- "~를 원피스 워드로 뽑아줘"
- "이 HTML 리포트를 원피스로"
- "빈 원피스에 ~ 주입해줘"

## 의존 스킬

- `a10-oneffice-new-doc-opener` — 새 원피스 워드 문서 탭 생성
- `a10-oneffice-writer` — HTML 주입·정렬·저장 (핵심 실행부)

## 치명적 주의

- **저장 전 새로고침 금지.** writer Step 7 순서를 절대 뒤집지 말 것.
- **편집모드 가드 필수.** 읽기모드에서 저장은 silent no-op.
- **`.dze_page_main` 직접 수정 금지.** 모든 스타일은 자식 요소 인라인으로만.
- **읽기모드에서 점선(dashed outline)이 보이면** ONEFFICE 가 블록 요소에
  `outline: 1px dashed` 를 자동 주입한 것. writer 의 Step 4 Python 스니펫과
  Step 8 JS 주입으로 `* { outline: none !important; }` 를 삽입해야 한다.
  즉시 수정: Step 8 JS 스니펫을 편집모드에서 실행 후 재저장.
- **반드시 `.onex` 로 생성된 탭을 사용.** 일반 navigate 나 "새 문서" 버튼은
  `.noext` 를 만든다. opener 스킬 또는 "ONEFFICE 워드" 템플릿 버튼 경유 필수.
  저장 후 홈 화면에서 확장자 육안 확인 (Step 10.5).
