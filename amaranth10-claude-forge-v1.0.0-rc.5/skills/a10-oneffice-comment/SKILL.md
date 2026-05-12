---
name: a10-oneffice-comment
description: >
  Use this skill when the user asks to post a comment on an ONEFFICE document,
  mention a coworker (@이름) in an ONEFFICE comment thread, or any phrasing like
  "원피스 댓글 달아줘", "ONEFFICE 댓글 작성", "@XXX 멘션해서 댓글 남겨줘",
  "원피스 문서에 댓글 달아줘". Handles the mention autocomplete trigger that
  ONEFFICE requires (trusted native keystrokes only — execCommand/value=/dispatchEvent
  all fail) and posts comments with or without mentions end-to-end via Chrome MCP.
version: 0.1.0
---

# 원피스 댓글 작성 (ONEFFICE Comment)

ONEFFICE 문서의 댓글 패널에 멘션(@이름) 포함 댓글을 자동 게시하는 스킬.
2026-04-17 PRJ-005 분할 안내 댓글 (@유지수 대상) 자동화에서 검증된 패턴을 표준화.

## 사전 조건

- **Chrome MCP 연결 필수** (`mcp__Claude_in_Chrome__*` 도구군). 없으면 스킬 중단하고
  사용자에게 안내.
- 대상 탭이 ONEFFICE 문서 (`gwa.douzone.com/ecm/oneffice/...`) 여야 함.
- 문서가 댓글 허용 상태 (`#TB_COMMENT_PANEL_0` 존재).

## ⚠️ 치명적 함정 — 시작 전 필독

1. **멘션 팝업은 신뢰된 네이티브 키 이벤트로만 뜬다.** `execCommand`, `inp.value = ...`,
   `dispatchEvent(new KeyboardEvent(...))` 모두 ❌. Chrome MCP 의 `type` + `key`
   (실제 키 이벤트) 만 동작.
2. **`@이름` 단독 type 은 IME 조합 중 입력이 잘리거나 팝업이 안 뜨는 경우가 있다.**
   → `@이름 ` (공백 포함) 으로 IME 확정 후, `Backspace` 2회로 자동완성 재진입.
3. **등록 버튼 좌표 `(1411, 290)` 하드코딩은 1920×1080 / 130% 줌 환경 한정.**
   해상도·줌이 다르면 DOM 셀렉터로 재탐색 필요 (후보: 댓글 패널 내 `button` /
   `onclick*="saveComment"`).
4. **confirm_before_submit 기본 true.** 공개 업무 문서에 잘못된 댓글이 올라가지
   않도록, 등록 직전 스크린샷 + 사용자 확인을 받는다. 사용자가 명시적으로
   `--no-confirm` 플래그를 줄 때만 자동 등록.

## 배경 — ONEFFICE 댓글 멘션 구조

- 댓글 패널 열기 버튼: `#TB_COMMENT_PANEL_0`
- 입력창: `#rpText` (contenteditable `<div>`)
- 멘션 자동완성 팝업: `.mentionListBox.type02` (2글자 이상 감지 시 표시)
- 선택된 멘션 태그 삽입 결과:
  ```html
  <input type="button" id="mention" name="mentionSpan"
         class="naSed" compseq="..." deptseq="..."
         empseq="344710302" value="유지수">
  ```
- 등록 버튼: 화면 우상단 좌표 `(1411, 290)` (현재 좌표 기반; DOM 셀렉터 조사 TODO)

## 입력 파라미터

| 파라미터 | 필수 | 설명 |
|----------|------|------|
| `url` | ✅ | ONEFFICE 문서 URL |
| `body` | ✅ | 댓글 본문. 멘션 위치에 `{{@이름}}` 플레이스홀더 삽입 |
| `mentions` | 선택 | 멘션할 이름 배열. `body` 의 `{{@이름}}` 와 매칭 |
| `confirm_before_submit` | 기본 true | 등록 직전 스크린샷 + 사용자 확인 |

### body 예시

```
{{@유지수}} PRJ-005 분할 완료했습니다. 확인 부탁드립니다.
```

## 표준 실행 흐름

### Step 0. Chrome MCP 연결 확인

`mcp__Claude_in_Chrome__tabs_context_mcp` 호출이 성공하면 OK. 실패 시 즉시 중단하고
사용자에게 "Chrome MCP 확장 설치/연결 필요" 안내.

### Step 1. 대상 탭 전환

```
mcp__Claude_in_Chrome__navigate(url)
```

이미 열린 탭이면 `tabs_context_mcp` → `switch` 로 이동. 탭 제목에서 ` - ONEFFICE`
접미사를 벗긴 값을 "문서명" 으로 기록.

### Step 2. 댓글 패널 열기

```javascript
(() => {
  const btn = document.getElementById('TB_COMMENT_PANEL_0');
  if (!btn) return { error: 'comment panel button not found' };
  btn.click();
  return { ok: true };
})()
```

`#rpText` 가 DOM 에 나타날 때까지 최대 2초 대기.

### Step 3. 입력창 포커스

`mcp__Claude_in_Chrome__left_click` 또는 `find` → `click`:

```javascript
document.getElementById('rpText').focus();
```

Chrome MCP 의 `type`/`key` 는 **현재 포커스된 엘리먼트** 에 입력되므로 반드시 먼저
포커스를 잡을 것.

### Step 4. body 파싱 + 순차 입력

`body` 를 `{{@이름}}` 토큰 기준으로 split. 각 세그먼트에 대해:

- 일반 텍스트 세그먼트: `mcp__Claude_in_Chrome__type(텍스트)`
- `{{@이름}}` 토큰: **Step 5 멘션 시퀀스** 실행

### Step 5. 멘션 트리거 시퀀스 ★핵심

이름당 1회:

1. `type("@<이름> ")` — 공백 포함, IME 확정용
2. `key("Backspace")` — 공백 제거 → `@<이름>`
3. `key("Backspace")` — 이름 마지막 글자 제거 → `@<이름-1>`
   - 이 시점 keyup 으로 `.mentionListBox.type02` 자동완성 팝업 표시
4. 300~500ms 대기
5. 팝업에서 첫 번째 항목 (동명이인일 경우 사용자 확인) 클릭
6. 멘션 태그가 `#rpText` 에 삽입됨

**팝업 미출현 시 재시도:**

```javascript
// 500ms 대기 후 팝업 없으면 Backspace 1회 추가 → 재대기 1회
```

2회 실패 시 사용자에게 수동 개입 요청.

**멘션 후 캐럿을 끝으로 이동:**

```javascript
(() => {
  const el = document.getElementById('rpText');
  el.focus();
  const range = document.createRange();
  range.selectNodeContents(el);
  range.collapse(false);
  const sel = window.getSelection();
  sel.removeAllRanges();
  sel.addRange(range);
  return { ok: true };
})()
```

### Step 6. 등록 직전 확인 (confirm_before_submit=true)

`mcp__Claude_in_Chrome__screenshot` 으로 입력 상태 캡처 → 사용자에게
"이대로 등록할까요?" 확인 질문. 사용자가 승인한 경우에만 Step 7.

### Step 7. 등록 버튼 클릭

우선 DOM 셀렉터 시도:

```javascript
(() => {
  // 후보 셀렉터 순차 시도
  const candidates = [
    'button[onclick*="saveComment"]',
    '#rpCommentSave',
    '.comment-panel button.register',
  ];
  for (const sel of candidates) {
    const btn = document.querySelector(sel);
    if (btn) { btn.click(); return { ok: true, used: sel }; }
  }
  return { error: 'no selector matched — fallback to coords' };
})()
```

실패 시 좌표 fallback:

```
mcp__Claude_in_Chrome__left_click(1411, 290)
```

### Step 8. 게시 검증

3초 대기 후 댓글 목록 조회:

```javascript
(() => {
  const list = document.querySelectorAll('.commentItem, .comment-item');
  const last = list[list.length - 1];
  return {
    count: list.length,
    lastText: last ? last.textContent.slice(0, 200) : null
  };
})()
```

방금 작성한 본문 일부가 `lastText` 에 포함되면 성공. 미확인 시 1회 재시도, 그래도
없으면 경고 후 수동 확인 요청.

### Step 9. 결과 보고

사용자에게:
- 문서명 (탭 제목에서 파싱)
- 멘션 대상 이름·`empseq`
- 게시된 본문
- 게시 시각 (로컬 시간)

## 오류·재시도 매트릭스

| 상황 | 처리 |
|------|------|
| `#TB_COMMENT_PANEL_0` 없음 | 댓글 비활성 문서. 스킬 중단 후 사용자 안내 |
| `#rpText` 없음 | 패널이 안 열렸거나 DOM 변경. 재클릭 1회 → 실패 시 중단 |
| 멘션 팝업 미출현 | Backspace 1회 추가 → 재대기 → 실패 시 수동 개입 |
| 자동완성 결과 여러 명 | 첫 항목 자동 선택 금지, 후보 목록을 사용자에게 제시 |
| 등록 후 댓글 미확인 | 3초 대기 후 1회 재조회, 그래도 없으면 경고 |
| Chrome MCP 연결 끊김 | 스킬 중단, 재연결 안내 |

## 검증된 상수 요약

| 항목 | 값 |
|------|-----|
| 댓글 패널 열기 버튼 | `#TB_COMMENT_PANEL_0` |
| 입력창 | `#rpText` (contenteditable) |
| 자동완성 팝업 | `.mentionListBox.type02` |
| 멘션 태그 | `<input id="mention" name="mentionSpan" empseq="...">` |
| 등록 버튼 좌표 (1920×1080, 130%) | `(1411, 290)` |
| 멘션 트리거 | `@이름<공백>` → `Backspace` 2회 |
| 팝업 대기 시간 | 300~500ms |
| 게시 검증 대기 | 3초 |

## 사용하는 도구

| 단계 | 도구 |
|------|------|
| 탭 전환·포커스 | `mcp__Claude_in_Chrome__tabs_context_mcp`, `navigate` |
| DOM 조작 | `mcp__Claude_in_Chrome__javascript_tool` |
| 키 입력 | `mcp__Claude_in_Chrome__type`, `key` |
| 클릭 | `mcp__Claude_in_Chrome__left_click`, `find` |
| 확인 | `mcp__Claude_in_Chrome__screenshot` |

## 디버깅 체크리스트

- **팝업 안 뜸** → IME 확정 누락. `@이름 ` 공백 포함 type → Backspace 2회 재확인.
- **멘션 태그 삽입 안 됨** → `.mentionListBox.type02` 존재는 하지만 클릭이 안 갔을
  가능성. `javascript_tool` 로 `.mentionListBox.type02 li` 첫 항목 `.click()` 직접 호출.
- **등록 버튼 좌표 빗나감** → 해상도/줌 변경. DOM 셀렉터 후보 재조사 필요.
- **잘못된 사람 멘션됨** → 동명이인. 다음 호출부터 `empseq` 확인 후 직접 선택하도록
  개선 필요.
- **댓글 2번 등록됨** → 등록 버튼 더블클릭. Step 7 을 단일 클릭으로 고정.

## 후속 개선 TODO

- 등록 버튼 DOM 셀렉터 확정 (현재 좌표 fallback)
- 멘션 `empseq` 캐시 (동일 이름 반복 멘션 시 재확인 스킵)
- 동명이인 후보 선택 UI (현재는 사용자 확인 요청)
- 멘션 대상 다중 검색 API 직접 호출 전환 (네트워크 탭에서 엔드포인트 식별)

## 함께 쓰는 스킬

- **a10-oneffice-reader** — 댓글 작성 전 문서 내용 확인
- **a10-oneffice-writer** — 댓글을 쓸 문서가 먼저 만들어져야 할 때

## 관련 Command

- **`/a10-post-comment`** — 이 스킬을 래핑한 슬래시 커맨드
