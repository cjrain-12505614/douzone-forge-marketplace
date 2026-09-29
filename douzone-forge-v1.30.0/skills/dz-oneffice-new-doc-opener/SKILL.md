---
name: dz-oneffice-new-doc-opener
description: >
  This skill should be used when the user asks to "원피스 새 문서 만들어줘",
  "새 원피스 워드 문서 열어줘", "빈 원피스 문서 하나 만들어줘" 또는 다른 스킬(특히
  dz-oneffice-writer)이 주입 대상 빈 문서 탭을 확보해야 할 때. ONEFFICE HOME에서
  "ONEFFICE 워드" 버튼 클릭을 XHR body swap으로 가로채 새 문서 탭을 편집모드까지
  진입시킨다. 직접 fetch는 인증 헤더(wehago-sign HMAC) 때문에 601로 실패하므로
  앱의 XHR을 가로채는 방식만 작동한다.
version: 0.2.1
---

# 원피스 새 문서 열기 (ONEFFICE New Doc Opener)

ONEFFICE HOME에서 빈 워드 문서 탭을 만들고 편집모드까지 진입시키는 전용 스킬.
`dz-oneffice-writer`의 Step 0(트랙 B, 브라우저 DOM 주입)에서 호출된다.

> **참고 (2026-07-22)**: 신규 원피스 발행은 a10 MCP `create_oneffice_doc`(생성 API
> `one001A01`, 헤드리스)가 **우선 경로**이며, 이 경우 빈 문서 탭 확보 자체가 불필요하다.
> 이 스킬은 **브라우저 DOM 주입(`dz-oneffice-writer` 트랙 B)·특수 문서설정 경로**에서
> 사용한다. 우선 경로 판단은 `/dz-oneffice-write` 커맨드 「트랙 선택 규칙」 참조.

> **변천사**: v0.1.0 신설 → **v0.2.0 dz-oneffice-kit OF 인용 전환(2026-07-14, T4 마이그레이션)** — 원피스 DOM 배관(중첩 iframe 접근·편집모드 판정/전환·CORS 서버)을 정본 `dz-oneffice-kit`의 OF 라이브러리로 인용. XHR body swap·"ONEFFICE 워드" 매칭·payload 구조는 이 스킬 고유로 유지. → **v0.2.1 A10 직접 생성 우선 참고 추가(2026-07-22)** — 신규 발행은 create_oneffice_doc 우선, 본 스킬은 트랙 B 폴백용임을 명시.

## 🔧 원피스 DOM 배관은 정본 dz-oneffice-kit(OF 라이브러리) 사용

이 스킬의 원피스 DOM 조작(중첩 iframe 접근·편집모드 판정/전환·CORS 서버 스니펫 등 **배관**)은 정본 [`dz-oneffice-kit`](../dz-oneffice-kit/SKILL.md)의 **OF 라이브러리**를 사용한다. 실행 시 그 SKILL.md의 OF 코드블록을 `javascript_tool`로 원피스 탭에 **1회 주입**(`window.OF` 상주)한 뒤 `OF.*`를 호출한다. 셀렉터·좌표·프리셋은 `OF.SEL`/`OF.COORD`/`OF.PRESET` 단일 정의를 따른다.

**이 스킬이 실제로 쓰는 OF 함수:**

| OF 함수/상수 | 이 스킬에서의 쓰임 | 대체하는 인라인 |
|---|---|---|
| `OF.editorDoc()` · `OF.main()` | 새 탭 전환 후 dzeditor 문서·`.dze_page_main` 접근 | Step 5 iframe 체인 |
| `OF.isEditable()` | 편집모드 진입 여부 판정(`main.isContentEditable`) | Step 5 편집 가드 |
| `OF.assertEditable()` / `OF.enterEdit()` | 읽기모드면 편집 토글 전환 후 재확인 | Step 5 가드 보강 |
| `OF.COORD.editTab` | 편집 탭 좌표 폴백(`[1361,20]`, 정본) | Step 5 하드코딩 좌표 |
| `OF.corsServer` | payload seed용 CORS 서버 스니펫(`charset=utf-8` 포함) | Step 3 CORS 서버 |

> **경계**: OF는 **DOM 배관만** 제공한다. 빈 `.onex` 생성의 핵심 — **XHR body swap**·"ONEFFICE 워드" 정확 텍스트 매칭·payload 구조(`folder_no`/`doc_name`/`fileType`/`content`) — 는 이 스킬 고유이므로 OF로 옮기지 않고 그대로 둔다.

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
| `folder_no` | 저장할 폴더 ID (내문서함) | `954aFG1c645a` ({이름} 계정, 2026-04-15 확인) |
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

> **CORS 서버는 OF 정본 사용 권장** — 큰 payload를 seed할 때는 `dz-oneffice-kit`의
> `OF.corsServer` 문자열(`charset=utf-8` 포함, 한글 손상 방지)을 Bash로 실행한다.
> writer 스킬과 동일한 `127.0.0.1:8765`·cwd `/tmp` 정의가 키트 한 곳에만 존재한다.
> 아래는 폴백 사본(1 마이너 버전 병행) — OF 부재 시에만 참조.

```bash
# 크면 /tmp/oneffice_content.json 에 {folder_no, doc_name, fileType, content} 저장
# CORS 서버는 writer 스킬과 동일하게 127.0.0.1:8765 재사용
# → 정본: dz-oneffice-kit OF.corsServer (charset=utf-8 포함)
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

**OF 정본 사용 권장** — 새 탭에 OF 라이브러리를 1회 주입한 뒤 아래처럼 판정한다.
읽기모드면 `OF.enterEdit()`가 편집 토글을 JS `.click()`으로 전환한다(반영에 ~2초 걸릴 수
있어 폴링 확인 권장 — kit §3.5 실측):

```javascript
(() => {
  if (!window.OF) return { ready: false, reason: 'OF 미주입 — 키트 코드블록 먼저 주입' };
  const main = OF.main();
  if (!main) return { ready: false, reason: 'no main (dzeditor 미도달)' };
  let ready = OF.isEditable();
  if (!ready) { OF.enterEdit(); ready = OF.isEditable(); }  // 반영 지연 시 폴링 후 재확인
  return { ready: ready, fileUID: window.opener?.__swappedFileUID };
})()
```

`ready: false`면 편집 탭 클릭으로 편집모드 진입 (좌표는 최후 폴백):
- 편집 탭 좌표: `OF.COORD.editTab` = `left_click [1361, 20]` (정본, 검증됨)

> **폴백 사본(1 마이너 버전 병행)** — OF 미주입 환경에서만 아래 인라인 iframe 체인 사용.
> 정본은 위 `OF.main()`·`OF.isEditable()`·`OF.enterEdit()`이다.
>
> ```javascript
> (() => {
>   const iframe = document.getElementById('open_oneffice_body_iframe');
>   if (!iframe) return { ready: false, reason: 'no oneffice iframe' };
>   const ed = iframe.contentDocument.getElementById('dzeditor_0');
>   if (!ed) return { ready: false, reason: 'no dzeditor_0' };
>   const main = ed.contentDocument.querySelector('.dze_page_main');
>   return {
>     ready: !!main && main.isContentEditable === true,
>     fileUID: window.opener?.__swappedFileUID
>   };
> })()
> ```

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
- 편집 탭 좌표 `OF.COORD.editTab`(`[1361, 20]`)는 해상도/레이아웃 따라 달라질 수 있음
  — DOM(`OF.enterEdit()`) 우선, 좌표는 최후 폴백. 실패 시 스크린샷으로 재확인

## 관련 API

- `POST /ecm/oneffice/one001A01` — 빈 워드 문서 생성 (fileUID 반환)
- `POST /ecm/oneffice/one001A03` — 최근 문서 목록 조회 (생성 자체엔 불필요)
- `GET /ecm/oneffice/one003A06?<base64>` — 에디터 화면

## 함께 쓰는 스킬

- **dz-oneffice-kit** — 원피스 DOM 배관 정본(OF 라이브러리). 이 스킬은 `OF.editorDoc`·`OF.main`·`OF.isEditable`/`OF.assertEditable`·`OF.enterEdit`·`OF.COORD.editTab`·`OF.corsServer`를 인용한다
- **dz-oneffice-writer** — 이 스킬로 만든 빈 문서에 HTML을 주입·정렬·저장
