---
name: a10-oneffice-new-doc-opener
description: >
  This skill should be used when the user asks to "원피스 새 문서 만들어줘",
  "새 원피스 워드 문서 열어줘", "빈 원피스 문서 하나 만들어줘" 또는 다른 스킬(특히
  a10-oneffice-writer)이 주입 대상 빈 문서 탭을 확보해야 할 때. ONEFFICE HOME에서
  "ONEFFICE 워드" 버튼 클릭을 XHR body swap으로 가로채 새 문서 탭을 편집모드까지
  진입시킨다. 직접 fetch는 인증 헤더(wehago-sign HMAC) 때문에 601로 실패하므로
  앱의 XHR을 가로채는 방식만 작동한다.
version: 0.1.0
---

# 원피스 새 문서 열기 (ONEFFICE New Doc Opener)

ONEFFICE HOME에서 빈 워드 문서 탭을 만들고 편집모드까지 진입시키는 전용 스킬.
`a10-oneffice-writer`의 Step 0에서 호출된다.

## ⚠️ 왜 직접 fetch가 안 되는가

`/ecm/oneffice/one001A01` 는 다음 헤더를 요구한다:
- `Authorization`
- `timestamp`
- `transaction-id`
- `wehago-sign` (HMAC 서명)

직접 `fetch('/ecm/oneffice/one001A01', {method:'POST', ...})` 로 호출하면
**`601: 허용된 쿠키 인증 URL이 아닙니다`** 로 실패한다. 앱이 "ONEFFICE 워드"
버튼을 누를 때 자동으로 붙는 이 헤더들을 재현할 수 없으므로, **앱의 XHR을
가로채서 body만 교체하는 방식**을 사용한다.

## 사전 조건

ONEFFICE HOME 탭(`moduleCode=UO`)이 열려 있어야 한다. 없으면 먼저 navigate:

```
https://gwa.douzone.com/#/UO/UOA/OFA1000?specialLnb=Y&moduleCode=UO&menuCode=UOA&pageCode=UOA1000
```

navigate 후 1~2초 대기.

## 필요한 값

| 이름 | 설명 | 기본값 |
|------|------|--------|
| `folder_no` | 저장할 폴더 ID (내문서함) | `954aFG1c645a` (차민수 계정, 2026-04-15 확인) |
| `doc_name` | 문서 제목 | 사용자 지정 또는 `YYMMDD_새 문서` |
| `fileType` | 파일 타입 | `word` |
| `content` | 초기 본문 HTML | 빈 문서면 `dze_doc_property` 프리픽스만 |

> **계정이 바뀌면 `folder_no` 최초 1회 캡처 필요.** HOME에서 평소처럼 새 워드를
> 한 번 만들어 `read_network_requests`로 `one001A01` POST body의 `folder_no` 확인.

## 실행 흐름

### Step 1. 기존 빈 탭 재사용 체크

```
mcp__Claude_in_Chrome__tabs_context_mcp
```

편집모드 가능한 빈 원피스 워드 탭이 이미 있으면 그 탭을 반환하고 종료.

### Step 2. ONEFFICE HOME 탭 확보

```
mcp__Claude_in_Chrome__navigate({
  url: "https://gwa.douzone.com/#/UO/UOA/OFA1000?specialLnb=Y&moduleCode=UO&menuCode=UOA&pageCode=UOA1000"
})
```

`moduleCode=UO` 탭이 이미 있으면 switch.

### Step 3. payload 준비 (사전 seed 가 필요할 때만)

> **Simple path — 빈 `.onex` 만 필요한 경우**: Step 3 (payload 준비) 과 Step 4 의
> XHR body swap 부분을 **전부 스킵**하고, 아래 버튼 클릭 한 줄만 수행해도 된다.
> 앱이 자기 기본 payload 로 올바른 `.onex` 를 생성한다. writer 스킬의 Step 0 에서
> "빈 탭만 필요" 인 경우 이 경로가 **가장 안전**하다 (사용자가 만든 payload 필드
> 오류로 인한 `.noext` 위험 제거).
>
> ```javascript
> const btn = Array.from(document.querySelectorAll('button'))
>   .find(el => (el.textContent || '').trim() === 'ONEFFICE 워드');
> if (!btn) return { error: 'ONEFFICE 워드 버튼 없음 — HOME 탭 아닐 수 있음' };
> btn.click();
> ```
>
> 이후 Step 5 (편집모드 가드) 로 바로 진행. 사전 HTML seed 가 필요할 때만 아래
> payload/XHR swap 경로를 사용한다.

빈 문서의 최소 content (dze_doc_property 프리픽스):

```html
<dze_doc_property class="dze_document_property"
  printmargin="20,20,20,20,10,12.5"
  papersize="210,297"
  pagecolor="#FFFFFF"
  watermarksrc=""
  dze_onepage_mode="false"
  pgcontentsoverflowvisible="false"></dze_doc_property>
```

`dze_onepage_mode="true"` 면 단일페이지 모드로 바로 시작 가능.

payload 전달 (10KB 미만은 인라인, 이상이면 CORS 서버):

```bash
# 크면 /tmp/oneffice_content.json 에 {folder_no, doc_name, fileType, content} 저장
# CORS 서버는 writer 스킬과 동일하게 127.0.0.1:8765 재사용
```

```javascript
// 브라우저 컨텍스트에서 payload 로드 (작으면 직접 대입)
const r = await fetch('http://127.0.0.1:8765/oneffice_content.json');
window.__payload = await r.json();
```

### Step 4. XHR body 교체 + "ONEFFICE 워드" 버튼 클릭

**검증된 방식 (2026-04-15):**

```javascript
if (!window.__sendSwapped) {
  const origOpen = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function(...a) {
    this.__url = a[1];
    return origOpen.apply(this, a);
  };
  const origSend = XMLHttpRequest.prototype.send;
  XMLHttpRequest.prototype.send = function(body) {
    if (String(this.__url || '').includes('one001A01') && window.__swapNextBody) {
      window.__swapNextBody = false;
      this.addEventListener('load', () => {
        try {
          window.__swappedFileUID = JSON.parse(this.responseText).resultData?.fileUID;
        } catch(e) {}
      });
      return origSend.apply(this, [JSON.stringify(window.__payload)]);
    }
    return origSend.apply(this, [body]);
  };
  window.__sendSwapped = true;
}
window.__swapNextBody = true;
[...document.querySelectorAll('button')]
  .find(b => b.textContent.includes('ONEFFICE 워드'))
  .click();
```

앱이 자동으로
`window.open('/ecm/oneffice/one003A06?<base64(seq=<fileUID>&ref=new_document)>', '_blank')`
를 호출 → 새 탭이 뜬다.

> **⚠️ `.noext` 방지 — 버튼 텍스트 매칭을 느슨하게 바꾸지 말 것.**
> 이 스킬이 `.onex` 확장자를 보장하는 유일한 이유는 **텍스트가 정확히 `'ONEFFICE 워드'`
> 인 버튼**을 클릭하기 때문이다. 일반 "새 문서", "문서 만들기", "오피스 워드" 등
> 다른 버튼으로는 `.noext` 가 생성되어 원피스 워드로 인식되지 않는다. `includes`
> 매칭은 유지하되, 다른 버튼이 먼저 매칭되지 않도록 주의하고, 필요시 아래처럼
> trim + 정확히 일치 검사로 강화할 것:
>
> ```javascript
> const btn = Array.from(document.querySelectorAll('button'))
>   .find(el => (el.textContent || '').trim() === 'ONEFFICE 워드');
> ```
>
> 저장 후 홈 화면에서 파일명 옆 아이콘이 `.onex` 인지 **반드시 육안 확인**
> (writer 스킬 Step 10.5 참조).

### Step 5. 새 탭 전환 및 편집모드 가드

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  if (!iframe) return { ready: false, reason: 'no oneffice iframe' };
  const ed = iframe.contentDocument.getElementById('dzeditor_0');
  if (!ed) return { ready: false, reason: 'no dzeditor_0' };
  const main = ed.contentDocument.querySelector('.dze_page_main');
  return {
    ready: !!main && main.isContentEditable === true,
    fileUID: window.opener?.__swappedFileUID
  };
})()
```

`ready: false`면 편집 탭 클릭으로 편집모드 진입:
- 편집 탭 좌표: `left_click [1361, 20]` (검증됨)

### Step 6. 정리

작업 종료 시 CORS 서버 정리:

```bash
pkill -f "http.server" || true
```

## 반환 형식

```json
{
  "tabId": "<chrome tab id>",
  "fileUID": "<oneffice file UID>",
  "editable": true
}
```

## 주의

- 직접 `fetch('/ecm/oneffice/one001A01', ...)` 호출 금지 (601 실패)
- `window.__sendSwapped` 재등록 방지 체크 필수 (중복 등록 시 무한 루프 위험)
- `window.__swapNextBody = true` 는 **버튼 클릭 직전에만 세트** — 다른 XHR이
  먼저 끼어들면 엉뚱한 요청이 스왑됨
- 편집 탭 좌표 `[1361, 20]` 는 해상도/레이아웃 따라 달라질 수 있음 — 실패 시
  스크린샷으로 재확인

## 관련 API

- `POST /ecm/oneffice/one001A01` — 빈 워드 문서 생성 (fileUID 반환)
- `POST /ecm/oneffice/one001A03` — 최근 문서 목록 조회 (생성 자체엔 불필요)
- `GET /ecm/oneffice/one003A06?<base64>` — 에디터 화면

## 함께 쓰는 스킬

- **a10-oneffice-writer** — 이 스킬로 만든 빈 문서에 HTML을 주입·정렬·저장
