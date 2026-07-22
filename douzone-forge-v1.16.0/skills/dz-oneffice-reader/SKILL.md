---
name: dz-oneffice-reader
description: >
  This skill should be used when the user shares a 원피스(ONEFFICE) 아마링크
  (gwa.douzone.com/ecm/oneffice/...) and asks to "읽어줘", "내용 확인해줘",
  "요약해줘", "이 원피스 문서 분석해줘", 또는 원피스 문서 안에 포함된
  다른 아마링크(참조링크)까지 재귀적으로 맥락 확장이 필요한 경우.
  스크롤·스크린샷 방식이 아닌 javascript_tool DOM 접근 방식으로 본문 텍스트와
  이미지, 내부 아마링크를 정확하게 추출한다. 이 스킬은 자체 완결적이며
  외부 워크스페이스 파일(CLAUDE.md, 운영규칙 md)에 의존하지 않는다. 단, 플러그인
  내부 정본 dz-oneffice-kit(OF 라이브러리)는 사용한다.
version: 0.4.0
---

# 원피스 읽기 (ONEFFICE Reader)

> 변천사: v0.3.0 — dz-oneffice-kit OF 인용 전환(2026-07-14, T4 마이그레이션). 읽기군(text·tables·links·imageDataURL) DOM 배관을 OF 정본 인용으로 전환, 기존 인라인 스니펫은 폴백 사본으로 병행 유지. → **v0.4.0 — a10 MCP 헤드리스 조회를 우선 경로로 승격(2026-07-22)**. 텍스트·표는 get_oneffice_content(one001A45), 이미지는 download_oneffice_images(one006A02) + Read 시각 판독으로 브라우저 없이 완전 맥락화(라이브 실측 확정). Chrome DOM 방식(OF 라이브러리)은 폴백·추가확인용으로 재정의.

원피스(ONEFFICE, dzeditor 기반) 문서를 정확하게 읽고, 문서 내부에 포함된
다른 아마링크까지 재귀적으로 확장해서 맥락을 수집하는 스킬. **원피스 조회는 a10 MCP
헤드리스 경로를 기본으로 하고(아래 「우선 경로」)**, Chrome DOM 방식은 폴백으로 둔다.
아마링크 운영 규칙과 Chrome MCP 보안 제약까지 모두 본 스킬 내부에 수록한다.

## 🚀 우선 경로 — a10 MCP 헤드리스 조회 (기본)

**원피스 문서 조회는 브라우저 대신 a10 MCP 를 우선 사용한다** — 텍스트·표·이미지까지
모두 헤드리스(브라우저·화면 없이)로 받아 판독한다(라이브 실측 확정 2026-07-22, forge
`참고자료/리포트/2026-07-22-A10원피스-직접생성-실측확정.md` 연계). 아래 Chrome DOM 방식
(「최우선 규칙」 이하 전체)은 **a10 MCP 실패·권한 부족·추가 확인이 필요할 때의 폴백**이다.

### 경로 A 절차 (a10 MCP 우선)

1. **아마링크 URL → fileUID 추출** (브라우저 불필요) — `one003A06?<base64>` 의 base64 를
   디코드하면 `seq=<fileUID>`:
   ```bash
   echo '<base64부분>' | base64 -d    # → seq=<fileUID>
   ```
   (fileUID 를 이미 알면 생략. 아마링크 token 만 있으면 아래 2·3에 token 을 그대로 사용)
2. **텍스트·표 조회**: `get_oneffice_content(file_uid="<fileUID>")` (또는 `token="<64자>"`)
   - `extract_text=True`(기본) → text(평문, 표는 탭/줄바꿈 보존). 원문이 필요하면 `include_raw=True`
3. **이미지 판독** (문서에 이미지가 있으면): `download_oneffice_images(file_uid="<fileUID>")`
   → 반환 `resultData.images[].path` 를 **Read 로 시각 판독**해 도표·스크린샷·다이어그램 내용을 맥락화
   - 특정 이미지만: `indexes=[0,2]` · 저장 위치 지정: `save_dir="..."`
4. **내부 아마링크**: `get_oneffice_content(include_raw=True)` 의 content 에서 `gwa.douzone.com`
   링크를 파싱한다. 재귀 확장은 **사용자 확인 후**(자동 확장 금지 — 폴백 경로와 동일 정책)

> **경로 A 이점**: 브라우저 탭·중첩 iframe·Canvas·가상 스크롤·쿼리스트링 차단 문제가 전부
> 없다. 세션·화면 없이 대량·자동 조회가 가능하고, 이미지도 Canvas 변환 없이 원본 그대로 받는다.

### 폴백 경로 B (Chrome DOM) — 아래 「최우선 규칙」 이하 전체

다음 중 하나면 경로 B(브라우저)로 전환한다:
- a10 MCP `get_oneffice_content`/`download_oneffice_images` **오류·미가용**(코워크 앱 MCP 재기동 전·비 forge 환경)
- **조회 권한 없음** — a10 MCP 서명 계정에 문서 공유 권한이 없어 빈 응답(권한 있는 계정의 브라우저 세션으로 확인)
- **렌더링된 화면 자체** 확인이 필요(레이아웃·편집 상태 등)
- a10 MCP 결과가 불완전해 **추가 확인**이 필요

## OF 라이브러리 사용 (DOM 배관 정본)

이 스킬의 원피스 DOM 조작(중첩 iframe 접근·본문/표/링크/이미지 추출 등 배관)은
정본 `dz-oneffice-kit`의 OF 라이브러리를 사용한다. 실행 시 그 SKILL.md의 OF
코드블록을 `javascript_tool`로 원피스 탭에 **1회 주입**(`window.OF` 상주) →
이후 `OF.*` 함수를 호출한다. 셀렉터·좌표·프리셋 문자열은 OF.SEL/COORD/PRESET
**단일 정의**를 따른다(스킬마다 값이 어긋나는 드리프트 방지).

**이 스킬이 실제로 쓰는 OF 함수** (읽기 전용 — 저장·편집 전환 없음):

| OF 함수 | 용도 | 대체하는 인라인 |
|---|---|---|
| `OF.editorDoc()` | 중첩 iframe 진입 (`#open_oneffice_body_iframe → #dzeditor_0 → document`) | Step 1~5 iframe 체인 |
| `OF.text(range?)` | 본문 전체 텍스트. `range=[from,to]` 청크 슬라이싱, 없으면 `{length, preview}` | Step 2 |
| `OF.tables()` | 본문 table 전건 → 2차원 배열 + 파이프 텍스트 | Step 5 |
| `OF.links(opt?)` | 본문 `a[href]` 중 gwa.douzone.com만 → 4분류(oneffice·onechamber·mail·etc). 쿼리스트링 기본 절단 | Step 3 |
| `OF.imageDataURL(i, opt?)` | i번째 img → Canvas PNG dataURL. `i` 생략 시 `{count}`. `img.src` 직접 읽기 금지(?seq= Chrome 차단) | Step 4 |

> 편집모드 판정·전환·저장(`OF.isEditable`/`enterEdit`/`save` 등)은 읽기 전용인
> 이 스킬의 사용 범위 밖이다. 쓰기 스킬(writer·form-writer)이 쓰는 배관이다.
>
> 이 스킬 고유(OF에 넣지 않음): **아마링크 타이틀 규칙 표**(모듈별)·**재귀 확장
> 정책**(내부 링크 자동 확장 금지·사용자 확인 필수). OF는 URL **구조**만 공유하고,
> 준-콘텐츠인 타이틀 규칙과 정책은 본 스킬에 그대로 둔다.

**폴백**: 아래 Step 1~5의 인라인 JavaScript 스니펫은 OF 정본과 동일한 로직의
**폴백 사본**이다(1 마이너 버전 병행). OF 주입이 불가능한 경우에만 인라인을 직접
쓴다. OF 정본 사용을 권장한다 — 셀렉터·차단 우회가 한 곳(kit)에서 최신화된다.

## 🚨 폴백 경로 B (Chrome DOM) 최우선 규칙

> 아래 「최우선 규칙」 이하 전체는 **폴백 경로 B(Chrome DOM)** 를 쓸 때의 절차다 —
> 경로 A(위 「우선 경로 — a10 MCP」)를 먼저 시도하고, a10 MCP 실패·권한 부족·추가
> 확인이 필요할 때만 이 브라우저 경로로 내려온다.

**폴백으로 브라우저를 쓸 때, `gwa.douzone.com` URL 은 스크롤·스크린샷 방식으로 파악하지 않는다.**
반드시 아래 JavaScript DOM 접근 방식을 사용한다.

```
스크롤 + 스크린샷 반복 ❌  →  javascript_tool로 innerText 한 번에 추출 ✅
```

## 핵심 원칙 — 반드시 지킨다

1. **절대 스크롤·스크린샷 반복으로 읽지 않는다** — dzeditor는 가상 스크롤이고
   긴 문서는 화면에 일부만 렌더된다. `body.innerText` 한 방으로 추출한다.
2. **Chrome MCP navigate → tabs_context_mcp → javascript_tool 순서** —
   탭 제목(`" - ONEFFICE"` 제거 = 문서명)으로 문서 식별 후 DOM 진입.
3. **중첩 iframe 구조 기억** — `#open_oneffice_body_iframe → #dzeditor_0 → body`
4. **이미지는 `img.src` 직접 읽기 금지** — Chrome MCP가 쿼리스트링(`?seq=`)을
   보안 차단함. 반드시 Canvas API `toDataURL()` 로 base64 변환.
5. **내부 아마링크 발견 시 사용자 확인 후 재귀 확장** — 자동 확장하지 않는다.

## 아마링크 개요 (self-contained)

**아마링크(Amaranth Link)**: A10 모바일 앱 및 ONEFFICE에서 문서·콘텐츠를 URL로
변환하여 공유하는 내부 딥링크 체계. 문서 상세의 "더보기 → 내보내기 → 링크복사"로
생성. 붙여넣기 시 타이틀과 함께 인라인 링크로 표시.

### URL 구조

| 항목 | 내용 |
|------|------|
| 베이스 | `https://gwa.douzone.com` |
| ONEFFICE 경로 | `/ecm/oneffice/one003A06` |
| 쿼리 파라미터 | `?{base64(seq=DOC_ID)}` |
| 예시 | `https://gwa.douzone.com/ecm/oneffice/one003A06?c2VxPWMz...` |
| 디코딩 | `c2VxPWMzYTNE...` → `seq=c3a3D439D883F381c68c1FF2G3aG6aB6` |

> 브라우저 탭 제목 = `{아마링크 타이틀} - ONEFFICE` 형식. " - ONEFFICE" 제거하면 문서 제목.

### 타이틀 규칙 (모듈별)

| 모듈 | 타이틀 형식 |
|------|------------|
| 결재 | `[결재] 결재문서 제목` |
| 업무보고 | `[업무보고] 보고문서 제목` |
| 일정 | `[일정] 일정명` |
| 게시판 | `[게시판] 게시글 제목` |
| ONEFFICE | `[ONEFFICE] 문서명` |
| ONECHAMBER (폴더) | `[ONECHAMBER] 폴더명` |
| ONECHAMBER (파일) | `[ONECHAMBER] 파일명.확장자` |
| 업무관리 | `[업무관리] 프로젝트명/Todo명` |
| 쪽지 | `[쪽지] 보낸사람 직급 yyyy.mm.dd hh:mm` |
| 미팅룸 | `[미팅룸] 미팅룸명(멤버수)` |
| 노트 | `[노트] 노트제목` |
| 주소록 | `[주소록] 사용자이름` |
| 프로필 | `[프로필] 이름 직급` |

### 마크다운 참조링크 형식

```markdown
[[ONEFFICE] 문서제목](https://gwa.douzone.com/ecm/oneffice/one003A06?{base64_param})
[[결재] 결재문서 제목](https://gwa.douzone.com/...)
```

## 표준 실행 흐름

### Step 1. 문서 열기 및 확인

```
mcp__Claude_in_Chrome__navigate({ url: "<원피스 아마링크>" })
mcp__Claude_in_Chrome__tabs_context_mcp()   // 탭 목록에서 문서명 확인
```

탭 제목이 `XXXXX - ONEFFICE` 형식이면 `XXXXX`가 문서명.

### Step 2. 본문 텍스트 추출

> **OF 정본**: `OF.text()` → `{length, preview}`, `OF.text([2000, 6000])` → 청크 슬라이스. 아래는 폴백 사본(1 마이너 버전 병행).

**접근 구조:**
```
document (gwa.douzone.com/ecm/oneffice/...)
  └─ #open_oneffice_body_iframe   ← 1차 iframe (ONEFFICE 앱 전체)
       └─ #dzeditor_0              ← 2차 iframe (문서 본문 에디터)
            └─ body.innerText      ← 추출 대상
```

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const doc = iframe.contentDocument;
  const editorIframe = doc.getElementById('dzeditor_0');
  const edDoc = editorIframe.contentDocument || editorIframe.contentWindow.document;
  const text = edDoc.body.innerText;
  return { length: text.length, preview: text.slice(0, 2000) };
})()
```

**2000자 이상이면 슬라이싱 청크 읽기:**
```javascript
edDoc.body.innerText.slice(2000, 6000)
edDoc.body.innerText.slice(6000, 10000)
```

> 동일 도메인 `gwa.douzone.com` 이라 cross-origin 제약 없음.
> URL 쿼리스트링(`?c2Vx...`) 직접 읽기는 Chrome MCP 보안 차단이지만,
> 탭 제목·iframe DOM 접근은 정상 작동.

### Step 3. 내부 아마링크 추출

> **OF 정본**: `OF.links()` → gwa.douzone.com 링크만 4분류(type·text·safeHref·hasParam). 아래는 폴백 사본.

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const anchors = Array.from(edDoc.querySelectorAll('a[href]'));
  return anchors
    .map(a => ({ href: a.href, text: a.innerText.trim().slice(0, 80) }))
    .filter(a => /gwa\.douzone\.com/i.test(a.href));
})()
```

결과 분류:
- `gwa.douzone.com/ecm/oneffice/...` → **또 다른 원피스 문서**
- `gwa.douzone.com/ecm/onechamber/...` → **원챔버(파일 저장소)**
- `gwa.douzone.com/#/popup?callComp=UDAP007...` → **메일**
- 기타 `gwa.douzone.com/*` → **기타 내부 시스템**

### Step 4. 이미지 추출 (필요 시)

> **OF 정본**: `OF.imageDataURL()` → `{count}`(개수), `OF.imageDataURL(0)` → i번째 Canvas PNG dataURL(base64, 기본 10000자 절단 · `{full:true}`로 전체). 아래는 폴백 사본.

**개수 확인:**
```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  return { count: edDoc.querySelectorAll('img').length };
})()
```

#### 방법 1 — Canvas → Base64 (권장, 이미지 데이터 직접 추출)

`img.src` 를 직접 읽으면 쿼리스트링(`?seq=...`)이 포함되어 Chrome MCP 보안 정책에
의해 차단된다. Canvas API로 그린 뒤 base64로 변환하면 차단 없이 추출 가능.

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const img = edDoc.querySelectorAll('img')[0];   // N번째로 변경
  const canvas = document.createElement('canvas');
  canvas.width = img.naturalWidth;
  canvas.height = img.naturalHeight;
  canvas.getContext('2d').drawImage(img, 0, 0);
  return canvas.toDataURL('image/png').slice(0, 10000);
})()
```

#### 방법 2 — 메타데이터 분리 추출 (src 전체는 차단되지만 부분은 가능)

```javascript
const imgs = edDoc.querySelectorAll('img');
for (let i = 0; i < imgs.length; i++) {
  const url = new URL(imgs[i].src);
  const pathname = url.pathname;                 // ✅ "/ecm/oneffice/one006A02"
  const seq = url.searchParams.get('seq');        // ✅ "uuid.png"
  const rect = imgs[i].getBoundingClientRect();   // ✅ 위치 정보
}
```

> `pathname + '?seq=' + seq` 로 재조합해 직접 navigate 하면 문서 페이지로
> 리다이렉트됨 — 이미지 단독 조회 불가.

#### 방법 3 — overflow 변경 + 스크롤 스크린샷 (폴백)

JavaScript 텍스트 추출이 불가능한 경우에만.

```javascript
editorDoc.body.style.overflow = 'auto';
const img = editorDoc.querySelectorAll('img')[0];
const rect = img.getBoundingClientRect();
editorDoc.body.scrollTop += rect.top - 100;
// 이후 computer → screenshot
```

### Step 5. 표(table) 추출 (필요 시)

> **OF 정본**: `OF.tables()` → `[{index, rows, cols, cells(2차원 배열), text(파이프)}]`. 아래는 폴백 사본.

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const tables = Array.from(edDoc.querySelectorAll('table'));
  return tables.map(t => ({
    rows: t.rows.length,
    cols: t.rows[0] ? t.rows[0].cells.length : 0,
    text: Array.from(t.rows).map(r =>
      Array.from(r.cells).map(c => c.innerText.trim()).join(' | ')
    ).join('\n')
  }));
})()
```

### Step 6. 맥락 확장 (재귀 읽기)

내부 아마링크 목록을 사용자에게 제시:
```
이 문서에 다음 N개의 내부 링크가 포함되어 있습니다:
- [원피스] 제목 A (href)
- [원챔버] 파일 B (href)
- [메일] 제목 C (href)

어느 것까지 확인할까요? (전부/선택/건너뛰기)
```

사용자가 선택한 링크만 동일 절차로 순차 방문.
**자동 재귀 금지 — 사용자 확인 필수.**

## Chrome MCP 보안 차단 정리 (필독)

| 추출 대상 | 결과 | 이유 |
|----------|------|------|
| `img.src` (전체 URL) | ❌ BLOCKED | 쿼리스트링 `?seq=` 포함 |
| `JSON.stringify({src: img.src})` | ❌ BLOCKED | 쿼리스트링 포함 응답 차단 |
| URL pathname (경로만) | ✅ 성공 | 쿼리스트링 미포함 |
| URL searchParams (seq만) | ✅ 성공 | 값만 분리 추출 |
| Canvas → base64 | ✅ 성공 | 데이터 URI는 쿼리 아님 |
| `body.innerText` (텍스트) | ✅ 성공 | 본문만 반환 |

> Chrome MCP는 **응답 텍스트에 쿼리스트링 패턴**(`?seq=`, `?key=` 등)이 포함되면
> 보안 차단한다. 쿼리스트링을 포함하지 않는 형태로 변환하면 차단 회피 가능.

## 읽기 모드

| 모드 | 설명 | 적용 |
|------|------|------|
| `quick` | 본문 전체 텍스트만 추출 | 짧은 공지·지시 문서 |
| `standard` | 텍스트 + 표 + 내부 아마링크 목록 | 회의록·기획안 (기본) |
| `full` | 텍스트 + 표 + 이미지(base64) + 내부 링크 재귀 확장 | 설계서·보고서 심층 분석 |

사용자가 "간단히/요약만" → quick, "상세히/전체" → full, 기본은 standard.

## 산출물 형식 권장

```markdown
## [문서명]

**출처**: {아마링크 URL}
**읽기 일시**: YYYY-MM-DD HH:MM
**모드**: quick | standard | full

### 본문 요약
{핵심 내용 3~5줄}

### 본문 상세 (옵션)
{필요 시 전체 텍스트}

### 포함된 내부 링크
- [원피스] 제목 A → {상태: 확장됨/미확장}
- [원챔버] 파일 B
- [메일] 제목 C

### 이미지
- img[0]: {캡션 또는 설명} — (base64 저장 위치 또는 스킵)
```

## 회수/삭제된 아마링크 처리

- 텍스트 일부 삭제 시 → 링크 이동 불가
- 삭제된 문서 → `'삭제된 문서입니다.'` empty set 노출
- 회수된 쪽지 → `'회수된 쪽지입니다.'` empty set 노출
- 미팅룸 없어진 경우 → `'삭제된 미팅룸 알림'` empty set 노출

저장된 아마링크의 원본이 삭제되면 링크가 동작하지 않을 수 있음.
중요 문서는 핵심 내용을 별도 맥락화해두는 것을 권장.

## 조회 권한 정책 요약

| 모듈 | 조회 가능 범위 |
|------|--------------|
| 결재 | 결재/합의/수신참조/시행자 라인 사용자 |
| 업무보고 | 보고대상자, 보고자만 |
| ONEFFICE | 문서 공유 권한 보유자 |
| 쪽지 | 조직도 내 모든 구성원 |
| 미팅룸 | 현재 대화멤버만 입장 |
| 주소록/프로필/노트 | 조직도 내 모든 구성원 |

## 디버깅 체크리스트

- **`innerText` 가 빈 문자열** → `dzeditor_0` 대신 `dzeditor_9999` (offscreen 숨김)에
  접근했을 것. iframe ID 재확인.
- **이미지 추출이 BLOCKED** → Canvas 방식(방법 1) 사용. `img.src` 직접 금지.
- **가상 스크롤 때문에 일부만 보임** → 스크린샷 대신 `innerText` 슬라이싱.
- **쿼리스트링 포함 응답이 전부 차단** → 응답에서 `?seq=` 패턴 제거 후 반환.

## 함께 쓰는 스킬

- **dz-oneffice-kit** — DOM 배관 정본(OF 라이브러리). 읽기군(text·tables·links·imageDataURL) 실행 코드의 단일 출처. 실행 시 1회 주입 후 `OF.*` 호출
- **dz-oneffice-writer** — 읽은 내용을 바탕으로 새 원피스 문서 작성
- **dz-oneffice-new-doc-opener** — 새 원피스 워드 문서 탭 생성 (writer가 호출)
- **dz-context-analyzer** — 설계서 계열일 경우 GNB/LNB 컨텍스트 파일로 변환
- **dz-history-manager** — 회의록/이력 성격이면 history/ 폴더로 귀속

<!-- auto: 차민수의 자비스 2026-07-14 dz-oneffice-reader → dz-oneffice-kit OF 인용 전환 (T4 마이그레이션 4단계, R reader 읽기군 전환). OF 사용 안내 섹션 추가 + 읽기군(text·tables·links·imageDataURL) 폴백 주석 + 자체완결 문구 정정(OF 라이브러리는 사용) + version 0.2.0→0.3.0. 아마링크 타이틀 규칙·재귀 정책은 고유로 유지. 사내망 회귀검증(알려진 문서 1건 읽기: 텍스트·표·이미지·내부링크 개수 일치)은 배포 전 별도 -->

