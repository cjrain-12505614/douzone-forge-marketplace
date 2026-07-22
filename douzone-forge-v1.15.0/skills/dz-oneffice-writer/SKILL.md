---
name: dz-oneffice-writer
description: >
  This skill should be used when the user asks to "원피스에 주입", "원피스 편집모드에 HTML 넣어줘",
  "이 HTML 리포트를 원피스 문서로 만들어줘", "빈 원피스에 내용 집어넣어줘", "원피스로 ~작성해줘",
  "ONEFFICE 문서로 만들어줘", "웹페이지처럼 긴 원피스 문서", "~를 원피스 워드로 뽑아줘",
  또는 완성된 HTML 문서를 ONEFFICE(dzeditor) 빈 문서에 직접 주입하여 원피스 문서로
  만들어야 할 때. 새 .onex 문서 생성부터 단일페이지 모드 전환, 꺾쇠 정렬(zoom 보정),
  컨테이너 보존 주입, 탭 간 localStorage 복제, 문서명 변경, 저장까지 end-to-end를
  담당한다. 이 스킬은 외부 워크스페이스/메모리 파일에 의존하지 않는다. 단, 원피스
  DOM 배관(중첩 iframe 진입·편집모드 판정/전환·주입·정렬·저장 등)은 플러그인 내부
  정본 dz-oneffice-kit(OF 라이브러리)를 사용한다.
version: 0.6.0
---

# 원피스 쓰기 (ONEFFICE Writer)

완성된 HTML 콘텐츠를 원피스(ONEFFICE, dzeditor) 문서에 주입하여
"원피스 문서"로 저장 가능한 형태로 만드는 스킬. 2026-04-15 {이름} 계정에서
검증된 절차·값을 수록한다. **원피스 DOM 배관(중첩 iframe 접근·편집모드 판정/전환·
주입·정렬·문서설정·저장 등)과 셀렉터·좌표·프리셋 상수는 이제 정본
`dz-oneffice-kit`(OF 라이브러리)를 단일 출처로 인용한다** (아래 「OF 라이브러리 인용」
섹션). 본 스킬 본문의 인라인 스니펫은 되돌림 안전판(폴백)으로 병행 유지한다.

## 🚀 우선 경로 — A10 직접 생성 (`create_oneffice_doc`)

**신규 원피스 발행은 이 브라우저 DOM 주입 대신 a10 MCP `create_oneffice_doc`
도구(원피스 생성 API `one001A01`)를 우선 사용한다.** 함수 한 번으로 문서 생성 +
본문(HTML) 주입 + 저장이 모두 끝나며(라이브 실측 확정 2026-07-22, forge
`참고자료/리포트/2026-07-22-A10원피스-직접생성-실측확정.md`), 아래 이 스킬의 브라우저
배관(탭 확보·편집모드 전환·꺾쇠 정렬·저장 버튼 클릭·문서명 커밋)이 **전부 불필요**하다.
저장 클릭 함정·읽기모드 no-op·체크아웃 경쟁도 **원천적으로 없다**.

```
create_oneffice_doc(title="<문서명>", html="<인라인 스타일 본문 HTML>", folder_uid="")
  → {resultCode, resultData:{fileUID, docUID, editorUrl, folderUID, name}}
# folder_uid 비우면 내문서함 루트(PR_ROOT). HTML은 <dze_doc_property> 래퍼 없이 순수 본문만.
```

**아래 DOM 주입 절차(이 스킬 본문 전체)는 다음 폴백·재편집 용도로 유지한다:**

1. a10 MCP `create_oneffice_doc` **미가용** — 플러그인 갱신 후 코워크 앱 MCP 재기동 전, 또는 비 forge 환경
2. **기존 문서 재편집** — `one001A01`은 신규 생성 전용. 이미 있는 문서의 내용 수정은 이 스킬의 저장 배관(`one001A17`)만 가능
3. **단일페이지 등 특수 문서설정** / **회의록 골격**(단일페이지+좁은 여백) 정밀 재현

> HTML 형식은 두 경로 **공통**이다 — 「콘텐츠 원칙」(사실 전용 + 인포그래픽) + **모드 C(평면 주입)**
> = 인라인 스타일 + 화이트리스트 태그. `create_oneffice_doc`에 넘길 HTML은 이 스킬 **모드 C 산출물과 동일**하다.
> 볼드는 `<b>` 대신 `style="font-weight:bold"`(재편집 시 언랩 방지, 치명적 함정 5).

> **v0.6.0 변천사 (2026-07-22 A10 직접 생성 전환)**: 원피스 생성 API `one001A01`을
> a10 MCP 도구(`create_oneffice_doc`)로 자산화(리트머스 미경유·헤드리스, 라이브 실측
> 확정)하고, **신규 발행 우선 경로를 트랙 A(A10 직접)로 승격**. 이 스킬의 브라우저
> DOM 주입은 폴백·재편집용으로 재정의(위 「우선 경로」). `/dz-oneffice-write` 커맨드도
> 2-트랙(A 직접 / B 브라우저)으로 개편. HTML 형식·콘텐츠 원칙·모드 C는 두 경로 공통.
>
> **v0.5.4 변천사 (2026-07-14, T4 마이그레이션)**: dz-oneffice-kit OF 인용 전환 —
> 중첩 iframe 진입·편집모드 판정/전환·주입·꺾쇠 정렬·문서설정·문서명·저장(2단계)·
> 탭 간 복제·CORS 서버 배관을 정본 OF 라이브러리(`OF.*`) 호출로 안내하고, 기존
> 인라인 스니펫은 폴백으로 병행 유지. 셀렉터·좌표·프리셋은 OF.SEL/COORD/PRESET
> 단일 정의를 참조(드리프트 제거). 자체완결 문구를 "OF 라이브러리는 사용한다"로
> 정직 정정.

> **v0.5.2 변천사 (2026-07-06 사장님 주간보고 대응 사이클)**: "md는 다각도 허용,
> HTML→원피스 변환부터는 사실 전용" 원칙을 차민수 수석이 명시적으로 확정 —
> 기존에는 "회의록 프리셋" 한정으로만 있던 "공유 가능한 사실만" 규칙을 **모든
> HTML→원피스 변환**에 적용하는 신규 「콘텐츠 원칙」 섹션 추가(자비스-사용자 소통
> 흔적·`_(확인 필요)_`·내부 코드 제거 + 인포그래픽 삽입 4원칙).
>
> **v0.5.1 변천사 (2026-07-06 리걸테크에디션 개발현황 원피스 재작업 실측)**: 모드
> B(컨테이너 보존, `width:973px !important` 고정)로 만든 문서가 편집 화면은 정상이나
> 모바일·PDF 변환 시 우측 여백 과다 증상(v0.4.0 문서화 증상)이 재발해 모드 C로
> 재작업하며 **기존 미문서화 함정 3건** 발견·수록. ① **치명적 함정 5 신설** — 저장
> 직렬화 시 빈 장식용 `<span>`은 삭제, `<b>`/`<strong>`은 통째 언랩(unwrap), `<div>`만
> 항상 생존. ② **모드 C 4원칙 보강** — `getComputedStyle()`로 값을 구울 때 넓은
> 브라우저 창 기준으로 `margin:auto`·`grid-template-columns`(`1fr` 등 상대값)이 절대
> px 로 고정돼 오버플로가 재발하는 함정. ③ **Step 5 CORS 서버 보강** — `charset=utf-8`
> 누락 시 한글이 영구 손상(재로드로도 복구 안 됨)되는 함정, `guess_type` 오버라이드
> 스니펫 추가.

> **v0.5.3 변천사 (2026-07-14 라이브 실측 — 재편집 저장 원인 규명·정정)**: v0.5.0이
> "재편집 저장은 실제 마우스만 유효"로 본 것을 사내망 실측으로 정정. 실제 원인은
> **재열람 문서가 읽기(R)모드로 열림**(`isContentEditable=false`)이며, **편집 토글을 JS
> `.click()`으로 전환**하면(신뢰 이벤트 불필요) JS 저장이 `one001A17`로 정상 작동한다.
> 단 다른 창/세션이 편집 중이면(체크아웃 경쟁, "다른 창에서 편집 중" 팝업) 편집 전환
> 후에도 실패 → 실제 마우스 폴백. **저장 = 2단계**(편집 전환→JS 저장 / 실패 시 폴백).
> 저장 API = `one001A17 updateDocumentContent`. 상세: forge `참고자료/리포트/2026-07-13-원피스-사내망-API규명-점검.md` §7.
>
> **v0.5.0 변천사 (2026-07-02 재편집 저장 함정 실측)**: 저장된 문서를 재열람 후
> 편집하는 세션에서 **JS `.click()`·Cmd+S 저장이 조용히 무시**되는 함정을 실측으로
> 확정·수록 (치명적 함정 4 · Step 10(b) 경고 · 디버깅 체크리스트). 재편집 저장은
> **실제 마우스 클릭**만 유효, 판정 = 탭 제목 "데이터를 저장하고 있습니다." 전환,
> 검증 = 새로고침 후 DOM (a10 MCP 조회 API 는 캐시 구버전 반환 가능). 회의록 발행은
> forge `규칙/프로세스/회의록-원피스-템플릿-표준.md`(네이비 브리프형) 준수 —
> `/dz-oneffice-write` 커맨드의 「회의록 프리셋」 참조.

> **v0.4.0 변천사 (2026-05-27 자비스 보강 사이클)**: 모드 B 로 만든 문서가 편집 화면에서는
> 정상이지만 인쇄·PDF 변환·줌 변경 시 사이즈가 깨지는 사이즈 문제 발견 후 보강.
> ① **모드 C — 평면 주입 (인쇄·PDF·줌 친화)** Step 6 에 신규 추가. `<style>` 태그·
> `.container` 래퍼·`width` 고정·`!important` 모두 제거하고 본문 요소를 `main` 직계
> 자식으로 평탄화. 사용자가 ONEFFICE 안에서 직접 복사·붙여넣기로 만드는 패턴과 동일.
> ② **Step 9 문서명 변경 — `blur()` + blur 이벤트 dispatch 필수** 추가. native setter
> + Enter keydown 만으로는 ONEFFICE 의 React 상태에 commit 되지 않아 저장 시 원복되는
> 경우 발견. ③ **디버깅 체크리스트** 에 사이즈 문제·blur 누락 항목 추가.

## 🔗 OF 라이브러리 인용 — 원피스 DOM 배관 정본 (dz-oneffice-kit)

이 스킬의 원피스 DOM 조작(중첩 iframe 접근·편집모드 판정/전환·주입·꺾쇠 정렬·
문서설정·문서명·저장 등 **배관 전반**)은 정본 `dz-oneffice-kit`의 OF 라이브러리를
사용한다. writer 는 OF 의 **최대 소비자**로, OF 의 쓰기·배관 함수 대부분이 원래
이 스킬에서 이관된 것이다.

**소비 방식**: 실행 시 `dz-oneffice-kit` SKILL.md §1 의 OF 코드블록을
`javascript_tool` 로 **원피스 탭에 1회 주입**(`window.OF` 상주) → 이후 `OF.*` 를
호출한다. 셀렉터·좌표·프리셋 문자열은 **OF.SEL / OF.COORD / OF.PRESET 단일 정의**를
참조한다(스킬마다 값이 어긋나는 드리프트 제거).

**이 스킬이 사용하는 OF 함수·상수** (이관된 쓰기·배관 전량):

| OF 항목 | 대응 단계 | 용도 |
|---|---|---|
| `OF.bodyDoc()`·`OF.editorDoc()`·`OF.main()` | Step 1·2·6·7 등 | 중첩 iframe 진입(바깥=리본·저장·문서명·편집토글 / 안쪽=main·꺾쇠·zoom) |
| `OF.isEditable()`·`OF.enterEdit()`·`OF.assertEditable()` | Step 2, 재편집(치명적 함정 4) | 편집모드 판정·읽기→편집 JS `.click()` 전환·주입/저장 전 하드 가드 |
| `OF.pageSetup(cfg)` | Step 3 | 문서설정 팝업(페이지분리·여백·용지 방향). ⚠️ 용지 A4↔A3 콤보박스는 OF 범위 밖(좌표 클릭) |
| `OF.injectHTML(html, mode)` | Step 6 (모드 A/B/C) | main.innerHTML 교체 + 진단 반환(주입 전 `assertEditable` 하드 가드) |
| `OF.alignBracket(opt)` | Step 7·8 (**모드 B 한정**) | 꺾쇠 정렬 `<style>`+!important 2단 셀렉터 주입. `opt.preset` 없으면 BCR÷zoom 실측 |
| `OF.zoom()`·`OF.brackets()` | Step 7 실측 fallback | transform matrix zoom 파싱·좌우 꺾쇠 BCR(편집모드만 렌더) |
| `OF.setTitle(name)` | Step 9 | native setter + `blur()` dispatch 로 문서명 commit |
| `OF.save(opt)` | Step 10 | **저장 2단계**(읽기모드면 enterEdit 편집전환 폴링 → 저장버튼 click → 탭 제목 판정 → 실패 시 `needsPhysicalClick`) |
| `OF.stashMain(key)`·`OF.applyStash(key)` | Step 3.5 | 탭 간 localStorage 복제(JS 반환값 Chrome MCP 차단 우회) |
| `OF.corsServer` | Step 5 | charset=utf-8 포함 CORS 서버 문자열(한글 손상 방지) |
| `OF.SEL`·`OF.PRESET`·`OF.COORD` | 전 단계 | 셀렉터·폭 프리셋·좌표 폴백 단일 상수 |

> 아래 각 Step 본문의 인라인 JS 스니펫은 **되돌림 안전판(폴백 사본, 1 마이너 버전
> 병행)** 으로 삭제하지 않고 유지한다. OF 정본을 우선 쓰되, OF 주입 실패·회귀 시
> 인라인으로 즉시 복구할 수 있게 남겨둔다. 셀렉터·좌표·프리셋의 **값이 어긋날 때는
> OF 의 정의를 정본으로 본다**.

## 🎯 기본 워크플로우 (사용자 표준 요청 = "원피스로 작성해줘")

새 원피스 문서는 항상 아래 디폴트로 만들어진다:

| 항목 | 디폴트 값 |
|---|---|
| 용지 | **A4** |
| 페이지분리 | **다중 페이지** |
| 여백 | **보통 (20mm)** |

사용자가 "원피스로 만들어줘" 라고만 하면 이 디폴트 위에서 아래 순서로 진행한다:

1. **Step 0**: 새 `.onex` 탭 확보 (`dz-oneffice-new-doc-opener` 스킬)
2. **Step 3**: 리본 `파일 → 문서 설정 → 페이지분리 → 단일 페이지` 로 전환
   — 긴 HTML 보고서를 A4 여러 장에 쪼개지 않고 웹페이지처럼 이어 붙이기 위해 필수
3. **Step 4~6**: HTML 가공 → **주입 모드 선택** (모드 B 컨테이너 보존 / 모드 C 평면 주입)
4. **Step 7**: 꺾쇠 정렬 — 모드 B 만 적용. **모드 C 는 정렬 단계 생략** (width 픽셀 고정이 사이즈 문제의 원인)
5. **Step 9~10**: 문서명 변경 (native setter + **`blur()` 필수**) → 저장 버튼 클릭 → 저장 완료 확인

> **주입 모드 선택 가이드** (v0.4.0 보강, 2026-05-27):
>
> | 용도 | 권장 모드 |
> |---|---|
> | **인쇄·PDF 변환·줌 변경에 사이즈 정상** (보고서·외부 공유) | **모드 C (평면)** ★ |
> | 편집 화면 미관 우선 + 외부 공유·인쇄 없음 | 모드 B (컨테이너 보존) |
> | 짧은 메모·서식 없는 단순 문서 | 모드 C |
> | 컨테이너 디자인 (그라데이션·카드·shadow) 편집 화면 한정 필수 | 모드 B |
>
> 사용자가 인쇄·PDF·외부 공유 의도를 명시하면 **모드 C 가 기본**. 모드 B 는 편집 화면
> 한정 미관이 필요할 때만 선택.

> 사용자가 나중에 용지/여백을 바꾸면 → 같은 탭에서 Step 7 만 재실행해
> 새 `cssTargetWidth` 로 오버라이드를 **교체**한다 (이전 블록 정규식 제거 후 append).
> 모드 C 는 Step 7 자체를 건너뛰므로 해당 없음.

## ⚠️ 치명적 함정 — 시작 전 필독

0. **반드시 `.onex` 확장자로 생성된 문서만 사용한다.** 일반 아마링크 `navigate`
   나 "새 문서" 일반 버튼은 **`.noext`** 를 만든다. 저장해도 원피스 워드로 인식되지
   않는다. ONEFFICE 홈의 **"ONEFFICE 워드" 템플릿 버튼** 클릭(또는
   `dz-oneffice-new-doc-opener` 스킬 호출)으로 생성된 탭만 사용할 것.
   Step 0 을 건너뛰고 기존 탭을 재사용할 때도 그 탭이 `.onex` 인지 Step 10.5 에서
   반드시 확인.
1. **저장 전에 새로고침하면 모든 주입 내용이 유실된다.** 저장 → 새로고침 순서는
   절대 뒤집지 말 것. Step 10 을 지킬 때까지 navigate/reload 호출 금지.
2. **주입·저장 전에 반드시 편집모드를 확인한다.** 읽기모드에서 저장 버튼을 눌러도
   아무 일도 일어나지 않는다 (silent no-op). Step 2 가드 체크를 건너뛰지 말 것.
3. **`.dze_page_main` 구조는 절대 건드리지 않는다.** width/padding/max-width를
   main 에 직접 주면 새로고침 시 리셋되며 저장도 안 된다. 스타일은 **모드 B 의
   `.container`** 또는 **모드 A 의 `main > div.main`** 인라인 속성으로만 전달.
4. **저장된 문서를 재열람하면 읽기(R)모드로 열린다 → 저장 전 편집모드 전환 필요**
   (2026-07-14 라이브 실측으로 v0.5.0 정정). 재열람 문서는 `isContentEditable=false`
   (우상단 "읽기" 토글 selected)라 저장이 무효다. **① 편집 토글**(`#open_oneffice_body_iframe`
   내부 문서의 `.dze_style_editmode_toolbar_normal`, 텍스트 "편집")을 **JS `.click()`으로
   전환**(신뢰 이벤트 불필요 — 실측) → `isContentEditable=true` 확인 → `TB_FILE_SAVE_REMOTE_0`
   JS `.click()` 저장이 정상 작동(`one001A17` 호출). **② 편집 전환 후에도 저장 신호가
   없으면 = 체크아웃 경쟁**("해당 문서가 다른 창에서 편집 중입니다" 팝업 — 다른 창/세션 편집 중):
   강제 전환 금지, 다른 편집창을 먼저 정리하거나 `computer` 실제 마우스 폴백.
   저장 발생 판정 = **탭 제목이 "데이터를 저장하고 있습니다." 로 전환**되는지 관찰
   (이 전환이 안 보이면 저장은 안 나간 것). DOM 직접 수정(td.textContent 등)도 실제
   마우스 저장이면 함께 직렬화·저장된다. 검증은 **브라우저 새로고침 후 DOM 확인**이
   정본 — a10 MCP `get_oneffice_content`(one001A45)는 캐시된 구버전을 반환할 수 있어
   저장 직후 판정에 쓰면 "저장 실패"로 오판한다.
5. **저장 시 빈 장식용 `<span>`은 삭제되고 `<b>`/`<strong>`은 통째 언랩된다** (v0.5.1
   실측, 2026-07-06). 모드 C 평탄화 과정에서 타임라인 점 마커 같은 빈 `<span>`으로
   장식하면 저장 후 새로고침 시 소리 없이 사라지고, `<b>`/`<strong>`으로 감싼 볼드
   라벨은 태그만 벗겨져(unwrap) 부모 안에서 의도치 않은 줄바꿈이 생긴다. `<div>`는
   항상 생존한다. **해결**: 장식용 span·b·strong은 전부 `<div style="display:inline">`
   또는 `<div style="display:inline-block">`로 치환할 것. **검증은 저장 직후가 아니라
   반드시 새로고침(navigate) 후 DOM 재조회**로 — 저장 직전 캐시 상태에서는 이 문제가
   보이지 않는다.

## 배경 — dzeditor의 특수성

원피스는 표준 브라우저 편집 API(contentEditable, designMode)를 쓰지 않는
**커스텀 에디터**다:

- 키 입력을 가로채서 자체 모델로 관리 → execCommand/paste 안 먹음
- `.dze_page_main` 의 width/padding 인라인 변경은 **새로고침 시 리셋**
- 저장되는 건 main 직계 자식의 인라인 `style` 속성과 innerHTML
- **브라우저 줌은 `.dze_document_container` 의 `transform: matrix(...)` 로 걸려 있음**
  → `getBoundingClientRect` 는 transform **이후** viewport px 를 돌려준다 (Step 7 참조)

## ⛔ 콘텐츠 원칙 — 사실 전용 + 인포그래픽 (모든 HTML→원피스 변환 필수, v0.5.2)

> **2026-07-06 확정 (차민수 수석)**: **md 파일(회의록·계획서 등 작업 기록)까지는
> 다각도로 자유롭게 작성해도 된다** — 내부 결정 과정·확인 필요 사항·자비스와의 논의
> 흔적을 담는 것은 문제 없다. **그러나 HTML을 만들어 원피스로 주입하는 단계부터는
> 반드시** 아래 원칙을 지킨다. 원피스로 발행되는 순간 그 문서는 경영진·타 임직원이
> 직접 읽는 외부 산출물이 되기 때문이다.

1. **사실 전용** — 자비스와 사용자 간 소통 흔적(질의·비판적 검토·"확인 필요"라고
   지적한 메타 서술·검증 과정 서술)을 HTML에 그대로 옮기지 않는다. 확정된 사실·
   숫자·결정사항만 담는다.
2. **내부 코드·미확정 항목 제거** — `_(확인 필요)_` 태그, 내부 전용 코드(PRJ 코드
   단독 표기, 에이전트·스킬 코드명 등)를 그대로 노출하지 않는다. 확정되지 않은
   내용은 HTML에서 빼거나, 애매하면 사용자에게 먼저 확정 여부를 확인한다.
3. **인포그래픽 삽입** — 흐름·비교·구성비·시계열처럼 시각화가 이해를 높이는
   지점에는 표만 두지 말고 인포그래픽(막대·다이어그램·타임라인 등)을 인라인
   HTML/CSS로 삽입한다. 기존에 확립된 패턴 4종은
   [`회의록-인포그래픽-패턴.html`](../../../규칙/프로세스/템플릿/회의록-인포그래픽-패턴.html)
   (`규칙/프로세스/회의록-원피스-템플릿-표준.md` §7) 참고.
4. **적용 경계** — md(작업 기록) 작성 단계에서는 이 원칙에 얽매이지 않는다.
   **HTML을 만들기 시작하는 순간부터 원피스 주입 완료까지**만 적용한다.

기존 "회의록 프리셋"(`/dz-oneffice-write --template minutes`)의 "원피스에는 공유
가능한 사실만" 규칙은 이 원칙의 특수 사례다 — 회의록뿐 아니라 보고서·계획서 등
**모든** HTML→원피스 변환에 동일하게 적용한다.

## HTML 가공 원칙 + ONEFFICE 전용 필수 CSS — SSoT 인용

> **Phase T (2026-04-28) 흡수 처리**: HTML 가공 원칙·필수 CSS 3건·Python 가공 스니펫은 SSoT로 이전됨. 본 Skill은 주입 절차에 집중.

상세 SSoT: `규칙/프로세스/HTML-원피스-작성-표준.md`
- §4 ONEFFICE 전용 필수 CSS 3건 (outline 제거 + 라이트 테마 + min-height 해제)
- §5 HTML 가공 원칙 (script/nav/button/form 제거 + style 통째 보존 + container 래퍼 유지)

Python 가공 스니펫은 본 Skill의 Step 4 (HTML 가공) 본문에 잔존 — 주입 절차로 통합.

미학·구조 가이드는 frontend-design 플러그인 (claude-plugins-official 마켓) 1차 인용. 본 Skill은 ONEFFICE-specific 환경 제약과 주입 절차만.

## 표준 실행 흐름 (13 단계)

### Step 0. 새 `.onex` 문서 탭 확보 — opener 스킬 호출 필수

**단순 `navigate` 금지.** `https://gwa.douzone.com/ecm/oneffice/one003A06?...` 같은
아마링크를 여는 것은 **기존 문서를 여는 것**이고, ONEFFICE HOME UI 의 "새 문서"
일반 버튼을 누르면 `.noext` 가 만들어진다. 반드시 다음 둘 중 하나를 사용:

**(a) `dz-oneffice-new-doc-opener` 스킬 호출** — 기존 탭 재사용 체크 포함, 권장

**(b) 직접 ONEFFICE HOME 에서 "ONEFFICE 워드" 버튼 클릭** — 텍스트가 정확히
일치해야 함:

```javascript
(() => {
  const btn = Array.from(document.querySelectorAll('button'))
    .find(el => (el.textContent || '').trim() === 'ONEFFICE 워드');
  if (!btn) return { error: 'ONEFFICE 워드 버튼 없음 — HOME 탭 아닐 수 있음' };
  btn.click();
  return { ok: true };
})()
```

새 탭이 `YYMMDD_새 문서 (N) - ONEFFICE` 형태 제목으로 뜨며, **자동으로 편집모드**
로 들어간다 — 별도 편집 버튼 클릭 불필요.

- **빈 `.onex` 만 필요**: opener 의 XHR body swap 을 생략하고 버튼 클릭만 수행
  (payload 필드 오류로 인한 `.noext` 위험 제거, 가장 안전)
- **사전 HTML seed 가 필요**: opener 스킬의 XHR swap 경로 사용

> 검증: 주입 직전 탭 제목에 ` - ONEFFICE` 가 붙어 있는지, 저장 후 Step 10.5 에서
> 홈 화면의 확장자 아이콘이 `.onex` 인지 확인.

### Step 1. 탭 전환 + (필요 시) 편집 탭 클릭

```
mcp__Claude_in_Chrome__tabs_context_mcp   // 대상 탭 찾기
```

opener 로 만든 탭은 자동으로 편집모드이지만, 기존 탭 재사용 시에는 수동 클릭
필요:
- **편집 탭 좌표: `left_click [1361, 20]`** (2026-04-15 {이름} 계정 1920×1080 기준)
- 해상도/레이아웃이 다르면 스크린샷으로 재확인

### Step 2. 편집모드 가드 (필수)

주입·저장 전 반드시 통과.

> **OF 정본**: `OF.isEditable()`(판정) / 읽기모드면 `OF.enterEdit()`(편집 토글 JS
> `.click()` 전환) / 주입·저장 직전 하드 가드는 `OF.assertEditable()`. 재열람 문서는
> `enterEdit` 반영에 ~2초 지연이 있어(kit §3.5) 편집 전환 후 폴링 대기 → 그다음 주입.
> 아래는 폴백 사본.

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  return {
    editable: main && main.isContentEditable === true,
    mainExists: !!main
  };
})()
```

`editable: true` 아니면 **절대 Step 5 이후로 넘어가지 말 것.** 편집모드가 아니면
주입은 시각적으로 보여도 저장 시 전량 유실된다.

### Step 3. 문서 설정 (페이지분리 / 용지 / 여백) — 같은 팝업에서 일괄 조정

원피스 새 문서 디폴트: **A4 / 다중페이지 / 보통(20mm)**. 디폴트와 다른 조합이
필요하면 **`파일 리본 → [문서 설정]` 팝업 하나에서 세 항목을 모두 조정**한다.

**UI 경로:**
```
파일 리본 → [문서 설정] 팝업 열기
  ├─ 페이지분리 탭 → "단일 페이지" / "다중 페이지"
  ├─ 용지       탭 → A4 / A3 / Letter 등
  └─ 여백       탭 → 좁게 / 보통(20mm) / 넓게 / 사용자 지정
→ [확인]
```

**★ 완전 자동화 (검증됨 2026-04-20)** — 팝업 전체를 JS 로 조작 가능:

| UI 요소 | 셀렉터 (모두 outer iframe `#open_oneffice_body_iframe` contentDocument 기준) |
|---|---|
| 파일 리본 탭 | `#TB_MENU_RIBBON_0` |
| 문서설정 버튼 | `#TB_SETTING_0` |
| 용지 세로 / 가로 | `#dze_idx_paper_direction_type1` / `type2` |
| 페이지분리 다중 / 단일 | `#dze_idx_onepagemode_off` / `_on` |
| 자동맞춤 on / off | `#dze_idx_pgContentsOverflow_off` / `_on` |
| 여백 좁게(10mm) / 보통(20mm) / 넓게(30mm) / 사용자 | `#dze_idx_print_margin_type1` / `2` / `3` / `999` |
| 확인 버튼 | `.duzon_dialog_buttonbox.new_ver input.duzon_dialog_btn_new_ok_normal` |
| 취소 버튼 | `.duzon_dialog_buttonbox.new_ver input.duzon_dialog_btn_new_normal` |

> **OF 정본**: `OF.pageSetup({ split:'single', margin:'narrow', paper:'portrait' })`
> — 페이지분리·여백·용지 방향 라디오를 한 번에 조정하고 `padL` 을 반환한다. ⚠️ 용지
> 크기(A4↔A3)는 콤보박스라 OF 범위 밖 — 아래 콤보박스 함정 주석대로 좌표 클릭. 아래는 폴백 사본.

**원샷 자동화 스니펫** — A4·단일페이지·좁은여백으로 전환 (다른 조합은 셀렉터만 교체):

```javascript
(async () => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const doc = iframe.contentDocument;
  // 1. 파일 리본 → 문서설정
  doc.getElementById('TB_MENU_RIBBON_0').click();
  await new Promise(r => setTimeout(r, 200));
  doc.getElementById('TB_SETTING_0').click();
  await new Promise(r => setTimeout(r, 300));
  // 2. 라디오 선택 (원하는 조합)
  doc.getElementById('dze_idx_onepagemode_on').click();   // 단일 페이지
  doc.getElementById('dze_idx_print_margin_type1').click(); // 좁게
  // (용지 변경 필요 시) doc.getElementById('dze_idx_paper_direction_type1').click();
  // 3. 확인
  doc.querySelector('.duzon_dialog_buttonbox.new_ver input.duzon_dialog_btn_new_ok_normal').click();
  return { ok: true };
})()
```

적용 완료 후 편집모드 iframe 의 `main` padding 으로 여백 검증:
`padL=76` → 보통 / `padL=38` → 좁게 / `padL=114` → 넓게

**의사결정 가이드**:
- **긴 HTML 보고서** (웹페이지형, 표·섹션 많음) → **단일 페이지** 필수
  (아니면 A4 한 장씩 잘려 레이아웃 파괴)
- **짧은 계약서·보고서** (페이지 번호 필요) → 다중 페이지 유지
- **표·다이어그램이 와이드** → A3 로 승격
- **여백은 항상 컨텐츠 적정폭 기준**으로 선택 (너무 좁아보이면 좁게, 너무 퍼지면 넓게)

> **⚠️ 용지 크기(A4↔A3) 변경은 위 셀렉터 표와 다르다 — 콤보박스다** (2026-06-02 법무관리 PoC 실측):
> - 위 표의 `dze_idx_paper_direction_type1/2`는 **방향(세로/가로)**일 뿐, **용지 크기(A4/A3/A5/B4...)는 커스텀 콤보박스** `.tbComboBox_AreaLabel_4`("A4 (210mm x 297mm)" 텍스트)다.
> - **DOM 클릭(`label.parentElement.click()` + option)이 불안정** → 실패 시 용지가 A4로 남는다. **좌표 클릭 권장**: 문서설정 팝업 열기 → 용지 크기 콤보 클릭(드롭다운 펼침) → 스크린샷으로 A3 옵션 좌표 확인 → A3 클릭 → 확인 버튼.
> - **🚨 가장 큰 함정**: `.container` 의 `width` 만 973 으로 키우고 **용지를 A4로 두면 컨텐츠가 A4 용지(인쇄폭 ~644) 밖으로 삐져나온다.** A3 폭(973)을 쓰려면 **반드시 용지 크기 콤보도 A3로 전환**해야 한다. 검증: 전환 후 `padL=76`(보통 여백) + 꺾쇠 폭(`bracketW`) == `.container.offsetWidth`(973), `diff=0`.

변경 후:
- 단일 전환 성공 시 하단이 `1/1 페이지` 로 바뀜
- 용지·여백 변경 후 **편집모드 꺾쇠(`.dze_page_margin_indicator_*`) 위치가 즉시 이동**
  → Step 7 실측 fallback 또는 아래 프리셋으로 폭 **재적용** 필수

**검증된 프리셋** (Step 7 테이블 참조, 줌 1.3 기준):

| 용지·여백 | 폭 | shift |
|---|---|---|
| A4·보통 | 644 | -1 |
| A4·좁게 | 720 | -1 |
| A3·보통 | 973 | -1 |
| A3·넓게 | 897 | -1 |

> 디폴트(A4·다중·보통)에서 단일만 바꾸는 게 가장 흔한 케이스. 용지·여백까지
> 바꾸면 "같은 팝업 한 번에" 다 바꾸고 나서 Step 7 폭 오버라이드를 **교체**한다
> (이전 `/* ONEFFICE A... 프리셋 */` 블록을 정규식으로 제거 후 새 블록 append).

### Step 3.3. (선택) 다른 원피스 문서 URL 수집 — 문서간 하이퍼링크용

"A 문서에서 B 문서 링크 걸어줘" 같은 요청 시. **원피스 아마링크는 단일 규칙**:
`https://gwa.douzone.com/ecm/oneffice/one003A06?<base64seq>` (95자 고정).
새 문서 생성 시 탭 URL = 그 문서의 영구 아마링크다. 다른 문서 링크를 걸 땐
**대상 문서의 탭 URL을 그대로 `<a href>` 에** 쓴다 — 추측·변형 금지.

**ONEFFICE 홈(`#/UO/UOA/OFA1000`) 에서 수집:**

```javascript
// 1. 클립보드 후킹 (한 번만)
(() => {
  if (window.__clipHook) return;
  window.__clipTexts = [];
  const orig = navigator.clipboard.writeText.bind(navigator.clipboard);
  navigator.clipboard.writeText = t => { window.__clipTexts.push(t); return orig(t); };
  window.__clipHook = true;
})()

// 2. 대상 문서들의 링크복사 아이콘 클릭
// li.oneffice_tit 각 항목의 3번째 <img> 가 링크복사
const titles = ['문서명1', '문서명2', ...];
const items = Array.from(document.querySelectorAll('li.oneffice_tit'));
titles.forEach(title => {
  const li = items.find(x => x.querySelector('span.ellipsis')?.textContent.trim() === title);
  const imgs = li.querySelectorAll('img');
  imgs[2].click(); // 링크복사
});

// 3. 쿼리스트링 차단 우회 — char array 로 반환
window.__clipTexts.map(t => t.split(''))
```

char array 로 받아 `join('')` 해서 사용. 절대로 쿼리스트링을 그대로 문자열로
반환하려 하면 `[BLOCKED]` 로 잘린다.

### Step 3.5. (선택) 기존 원피스 문서 → 새 문서 콘텐츠 복제 (localStorage 우회)

"다른 원피스 문서에 있는 내용을 새 문서에 그대로 옮겨" 요청이면, 원본 HTML 파일을
다시 가공하지 말고 기존 문서의 `main.innerHTML` 을 그대로 복제하는 게 가장 안전하다
(저장된 inline style 까지 보존).

> **⚠️ Chrome MCP `javascript_tool` 은 반환값에 쿼리스트링/Base64 비슷한 패턴이
> 포함되면 `[BLOCKED: Cookie/query string data]` 로 응답을 전량 삭제한다.** 원피스
> 문서 innerHTML 에는 거의 항상 `seq=`/`?...` 패턴이 있어 JS 반환값으로는 전달
> 불가. `.slice()`, `btoa()` 로 회피 시도해도 계속 차단된다.

**해결: 동일 오리진(`gwa.douzone.com`) 탭 간 `localStorage` 공유.**

> **OF 정본**: 탭 A(원본)에서 `OF.stashMain('__doc_extract__')` → 탭 B(새 문서)에서
> `OF.applyStash('__doc_extract__')`(내부에서 `assertEditable` 가드 후 주입·키 제거).
> 아래는 폴백 사본.

```javascript
// 탭 A (원본 문서) — 추출 + 저장
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc  = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main   = edDoc.querySelector('.dze_page_main');
  localStorage.setItem('__doc_extract__', main.innerHTML);
  return { saved: localStorage.getItem('__doc_extract__').length };
})()

// 탭 B (새 .onex 문서) — 꺼내서 주입
(() => {
  const html = localStorage.getItem('__doc_extract__');
  if (!html) return { error: 'not in localStorage' };
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc  = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main   = edDoc.querySelector('.dze_page_main');
  main.innerHTML = html;
  localStorage.removeItem('__doc_extract__');
  return { len: html.length, kids: main.children.length };
})()
```

CORS 서버·파일 쓰기 없이 즉시 복제된다. 복제 완료 후 Step 7 (정렬) 로 진행.

### Step 4. HTML 가공 → /tmp/inject_body.html 준비

위 "HTML 가공 원칙" 의 Python 스니펫 실행. `<style>` 과 `<div class="container">`
래퍼를 **보존** 한 채 `<script>`/`<nav>`/`<button>` 만 제거.

### Step 5. CORS 서버 기동 (40KB+ 인 경우)

40KB 미만이면 `javascript_tool` text 인자에 직접 넣어도 됨. 이상이면 필수:

> **⚠️ `charset=utf-8` 누락 시 한글 영구 손상** (v0.5.1 실측, 2026-07-06) —
> `SimpleHTTPRequestHandler` 의 기본 `Content-Type` 응답에는 charset 이 없어 브라우저가
> 인코딩을 오추정하면 주입된 한글이 `U+FFFD`(�)로 깨진다. **재로드해도 복구되지
> 않으며**, 캐시버스트 쿼리스트링(`?v=N`)을 붙여 강제 재요청해야 복구된다.
> `guess_type` 을 오버라이드해 `text/*` 응답에 항상 `charset=utf-8` 을 붙일 것 —
> 아래 스니펫에 반영됨.

> **OF 정본**: OF 라이브러리의 `OF.corsServer` 문자열이 동일한 서버 스니펫(charset=utf-8
> 포함)을 담고 있다 — Bash 로 그 문자열을 실행하면 된다. 아래는 폴백 사본.

```bash
python3 -c "
import http.server, socketserver, os
class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()
    def guess_type(self, path):
        # text/* 응답에 charset=utf-8 강제 — 없으면 한글이 U+FFFD 로 영구 손상
        ctype = super().guess_type(path)
        if isinstance(ctype, tuple):  # 일부 환경에서 (type, encoding) 튜플 반환 대비
            ctype = ctype[0]
        if ctype and ctype.startswith('text/'):
            return ctype + '; charset=utf-8'
        return ctype
os.chdir('/tmp')
socketserver.TCPServer(('127.0.0.1', 8765), H).serve_forever()
" &
```

### Step 6. HTML 주입 — 두 가지 모드

> **OF 정본**: `OF.injectHTML(html, mode)` — 내부에서 `assertEditable()` 하드 가드
> 후 `main.innerHTML` 를 교체하고 진단(`kids`·`firstTag`·`containerExists`·
> `styleTagExists`)을 반환한다. 모드 B/C/A 는 준비한 `html` 성격의 차이일 뿐 함수는
> 하나다(반환 진단으로 구분: B=2 자식 / C=10~30 평면 / A=본문 수). 40KB+ 는 먼저
> `await fetch('http://127.0.0.1:8765/...')` 로 받아 `OF.injectHTML(text, 'B')` 에 넘긴다.
> 아래 각 모드 스니펫은 폴백 사본.

#### 모드 B. 컨테이너 보존 주입 (★ 권장, 기본)

원본 HTML 의 `<style>` + `<div class="container">…</div>` 를 **통째로** main.innerHTML
에 주입한다. main 직계 자식은 `[<style>, .container]` 2 개뿐이므로 dzeditor 가 블록
단위로 정상 인식하며, `<style>` 안 `.container` CSS (shadow/padding/hero/section 등)
가 전부 살아난다.

**이번 세션(2026-04-15 로폼 5차 미팅 회의록)에서 최종 정답이었던 방식.**

```javascript
(async () => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  if (!main.isContentEditable) return { error: 'not editable — abort' };
  const html = await (await fetch('http://127.0.0.1:8765/inject_body.html')).text();
  main.innerHTML = html;   // <style> + .container 통째 포함
  return { ok: true, len: html.length, kids: main.children.length };  // 기대: 2
})()
```

정렬(Step 7)은 `main > div.main` 대신 **`.container`** 에만 inline style 을 박는다.

#### 모드 A. 플랫 주입 (레거시 — `.container` 없는 HTML 전용)

원본에 `.container` 래퍼가 없는 경우에만 사용. `<body>` 직계 자식들을 main.innerHTML
에 풀어넣고 `main > div.main` (rootDiv) 에 inline style 을 적용 (v0.2.0 방식).
단점: 원본 `<style>` 의 `.container` 관련 선택자는 무력화되어 디자인이 깨진다.

```javascript
(async () => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  if (!main.isContentEditable) return { error: 'not editable — abort' };
  const html = await (await fetch('http://127.0.0.1:8765/inject_body.html')).text();
  main.innerHTML = html;
  return { ok: true, len: html.length, kids: main.children.length };
})()
```

#### 모드 C. 평면 주입 (★ 인쇄·PDF·줌 친화, 보고서·외부 공유 권장) — v0.4.0 신설

원본 HTML 의 `<style>` 과 `<div class="container">` 래퍼를 **모두 제거**하고,
본문 요소들(`<h1>`, `<table>`, `<section>` 내부 요소 등)을 **`main.innerHTML` 직계
자식으로 평탄화**하여 주입한다. 각 요소의 디자인은 **인라인 `style` 속성**으로만
표현한다 (`!important`·`width` 픽셀 고정·`@media print` 모두 금지).

**언제 사용해야 하는가** (2026-05-27 자비스 보강 사이클 발견):

모드 B 로 주입한 문서는 **편집 화면에서는 정상 보이지만, 인쇄/PDF 변환/줌 변경
시 사이즈가 깨지는 사이즈 문제**가 발생한다. 원인 3 가지:

1. `.container` 래퍼의 `width:644px !important` 가 ONEFFICE 의 인쇄·PDF·줌 시스템과
   충돌 — 페이지 크기와 무관하게 픽셀 고정되어 페이지에 안 맞음
2. `<style>` 안의 `* { box-sizing }`, `body { padding }`, `@media print` 규칙이
   ONEFFICE 의 페이지 모델과 이중 충돌
3. `main > .container > [본문]` 2 단 중첩 구조는 ONEFFICE 가 본문을 재계산할 때 혼선

→ **사용자 검증 패턴**: 사용자가 ONEFFICE 안에서 직접 복사·붙여넣기로 작성한 문서는
`main` 직계 자식이 H1·HR·H2·TABLE·OL·DL 등 **평면 본문 요소**다. `<style>` 태그
없고 `.container` 없고 `width` 고정 없고 `!important` 없다. 인쇄·PDF·줌 모두 정상.
모드 C 는 이 패턴을 그대로 따라간다.

**모드 C 의 4 원칙**:

1. **`<style>` 태그 제거** — 모든 CSS 를 각 요소의 `style="..."` 인라인 속성으로 직접 부여
2. **컨테이너 래퍼 제거** — `.container`/`.page`/`div.main` 없이 본문 요소를 `main`
   직계 자식으로 평탄화
3. **`width` 픽셀 고정 제거** — 본문은 `.dze_page_main` 자연 폭(예: A4·보통 = 642px) 에
   맞춰 자연 fit. 표는 `width:100%` 만 허용 (`width:644px` 같은 픽셀 고정 금지)
4. **`!important` 전면 금지** — ONEFFICE 의 페이지 모델과 우선순위 충돌 회피.
   `@media print` 미디어 쿼리도 금지 (ONEFFICE 인쇄 처리와 이중 충돌)

> **⚠️ `getComputedStyle()` 로 값을 구울 때 절대값 고정 주의** (v0.5.1 실측,
> 2026-07-06): 평탄화 가공을 `getComputedStyle()` 자동화로 하면, 그 순간의 **브라우저
> 창 크기(viewport)를 기준으로 계산된 절대 px 값**이 그대로 구워진다. 원본 CSS 의
> `margin:auto`(가운데 정렬)나 `grid-template-columns`의 `1fr`(상대 비율)처럼
> **컨테이너 크기에 따라 달라지는 상대값**이 있으면, 넓은 창에서 구울 경우 엉뚱한
> 절대값으로 고정돼버린다 (예: `.wrap{max-width:920px; margin:0 auto}` →
> `margin-left:820px`로 구워져, 좁은 `.dze_page_main` 폭에서 오버플로가 재발한다).
> **대응**: `margin:auto`·`grid-template-columns`를 쓰는 클래스를 가공 전에
> 목록화해서, 구워진 절대값 대신 **원본 CSS 의 상대 표현(`margin:0 auto`, `1fr` 등)
> 으로 명시 오버라이드**한다.

**HTML 평탄화 가공 패턴**:

원본 보고용 HTML 에 `<style>` + `<article>`/`<div class="container">` 가 있으면,
`<style>` 안 CSS 규칙을 각 본문 요소(`<h1>`, `<table>`, `<th>`, `<td>`, `<p>` 등)에
인라인 `style` 속성으로 풀어서 부여한다. 각 요소를 `main` 직계 자식으로 배치하도록
래퍼 제거. Python/BeautifulSoup 또는 수기 작성 가능 (양식 단순하면 수기가 빠름).

평면 HTML 예시 (보고용 회의록 표지):

```html
<h1 style="font-size:18pt;font-weight:700;text-align:center;letter-spacing:0.4em;padding-bottom:10px;border-bottom:2px solid #1a1a1a;margin:0 0 8px 0;color:#1a1a1a;">회 의 록</h1>
<p style="font-size:11pt;text-align:center;color:#555555;margin:0 0 24px 0;">부제 — 협의 안건</p>
<table style="width:100%;border-collapse:collapse;margin:0 0 28px 0;font-size:11pt;">
  <tr>
    <th style="background:#f4f4f4;padding:7px 10px;border:1px solid #999;font-weight:600;width:90px;">일시</th>
    <td style="padding:7px 12px;border:1px solid #999;">2026-MM-DD HH:MM</td>
  </tr>
</table>
<h3 style="font-size:12pt;font-weight:700;padding-bottom:4px;border-bottom:1px solid #888;margin:0 0 10px 0;">1. 회의 목적</h3>
<p style="font-size:11pt;color:#2a2a2a;line-height:1.7;margin:0 0 20px 0;">본문 ...</p>
```

**주입 스니펫** (모드 B 와 동일 fetch 패턴, 다만 결과 자식 수가 다름):

```javascript
(async () => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  if (!main.isContentEditable) return { error: 'not editable — abort' };
  const html = await (await fetch('http://127.0.0.1:8765/inject_flat.html')).text();
  main.innerHTML = html;
  return {
    ok: true,
    len: html.length,
    mainChildren: main.children.length,                                     // 기대: N (보통 10~30 평면 자식)
    firstChildTag: main.children[0] ? main.children[0].tagName : null,      // 기대: H1·P·TABLE 등 본문 태그
    containerExists: !!main.querySelector(':scope > .container'),           // 기대: false
    styleTagExists: !!main.querySelector(':scope > style'),                 // 기대: false
    firstChildW: main.children[0] ? main.children[0].offsetWidth : null     // 기대: main 자연 폭 (642 등)
  };
})()
```

**모드 C 이후 Step 7 꺾쇠 정렬은 생략한다.** width 픽셀 고정 자체가 사이즈 문제의
원인이므로, 본문이 `.dze_page_main` 자연 폭에 자연 fit 되도록 둔다 (각 자식 요소가
`computedWidth: 642px` 처럼 main 폭에 맞춰짐). Step 9 (문서명) → Step 10 (저장) 으로 바로 진행.

**모드 B vs 모드 C 검증 차이** (2026-05-27 비교 진단 결과):

| 항목 | 모드 B (컨테이너 보존) | 모드 C (평면) |
|---|---|---|
| `main.children.length` | 2 (style + container) | 10~30 (평면 본문 요소) |
| `<style>` 태그 | 있음 | 없음 |
| `.container` 래퍼 | 있음 | 없음 |
| `width: 644px !important` | 있음 | 없음 |
| `!important` 사용 | 다수 | 0 |
| `@media print` | 있음 | 없음 |
| 인쇄·PDF·줌 변환 | **사이즈 문제 발생** | **정상** |
| 편집 화면 디자인 | 컨테이너 미관 유지 | 본문 단정 (디자인 단순) |

### Step 7. 꺾쇠 정렬 — zoom 보정 필수 (모드 B 한정, 모드 C 는 생략)

> **OF 정본**: `OF.alignBracket({ preset: 'A4-normal' })` — 프리셋 지정 시 `OF.PRESET`
> 폭/shift 를, 없으면 `OF.brackets()`·`OF.zoom()` 실측(BCR÷zoom)을 사용해 `<style>`+
> !important 2단 셀렉터(`main.innerHTML` 내부)를 주입한다. **모드 C 는 호출 금지**(정렬
> 생략). ⚠️ 실측상 zoom 이 문서마다 다르므로(kit §3.5, 1.1 관측) **프리셋 하드코딩보다
> 실측 fallback 이 안전**하다 — 프리셋 폭이 꺾쇠와 안 맞으면 `preset` 생략 호출. 아래는
> Step 7·8 을 한 번에 처리하는 폴백 사본.

> **⚠️ 단위 혼동 주의** — shift/width 는 항상 **CSS px (unzoomed)**.
> `getBoundingClientRect` 는 `.dze_document_container` 의 `transform: matrix(zoom)`
> 이후 **viewport px (zoomed)** 를 돌려준다. 혼동하면 1.3 배 오차가 무한 누적된다
> (2026-04-15 로폼 세션에서 6회 왕복 발생). BCR 값을 `zoom` 으로 나눠서 CSS px
> 로 환산해야 한다.

**검증된 기본값 (2026-04-15 / 04-20 재검증, {이름} 계정, 브라우저 줌 130%):**

| 용지 | 여백 모드 | `padL/padR` | `cssTargetWidth` | `cssShiftLeft` |
|---|---|---|---|---|
| **A4** | 보통 (20mm) | 76px | **644** | **-1** |
| **A4** | 좁게 | 38px | **720** | **-1** |
| **A3** | 보통 (20mm) | 76px | **973** | **-1** |
| **A3** | 넓게 | 114px | **897** | **-1** |
| 기타 | — | — | Step 7 실측 fallback 사용 | — |

공통: `zoom = 1.3`, `cssShiftLeft = -1` 은 모든 조합에서 유지. main 내부 content box 는 항상 브래킷보다 좁음 → 꼭 음수 margin + `max-width:none` 로 탈출. 용지·여백이 위 조합에 없으면 Step 7 실측 fallback 스니펫으로 계산.

---

#### ⚠️ 가장 흔한 실수 — inline `width:644px` 가 `!important` 에 덮인다

**2026-04-20 세션에서 5건 연속 재현된 실패 패턴**:

1. Step 7 에서 `target.style.cssText = 'width:644px;max-width:644px;...'` (inline) 적용 → OK 보임
2. Step 8 에서 `.page, .page * { max-width:100% !important }` 주입 → **inline `width:644px` 가 `max-width:100% !important` 에 패배**
3. 결과: `computed width = 490px` (main content box 크기로 수축) → **왼쪽 꺾쇠는 맞는데 오른쪽이 빔**

**원인**: CSS 스펙상 `!important` > inline. Step 8 에서 자기가 주입한 와일드카드가 Step 7 의 폭 지정을 무효화한다. 여기에 원본 HTML 의 `<style>` 에도 `.page { max-width:1180px }` 같은 선언이 있으면 상황이 더 꼬인다.

**해결 — 폭·정렬은 inline 이 아니라 `<style>` 태그 + `!important` + 구체적 셀렉터로 박는다. 그리고 그 `<style>` 은 반드시 `main.innerHTML` 내부에 넣어야 저장 시 살아남는다** (에디터 iframe `head` 에 넣으면 저장 후 증발).

검증된 오버라이드 (A4·단일페이지·보통여백·줌 130% 기본):

```css
/* main.innerHTML 안에 <style> 로 주입할 것. 에디터 head 주입은 저장 후 소실. */
.dze_page_main > .page {
  width: 644px !important;
  max-width: none !important;
  margin: 0 0 0 -1px !important;
  padding: 0 !important;
  box-sizing: border-box !important;
}
.dze_page_main > .page img   { max-width: 100% !important; height: auto !important; }
.dze_page_main > .page table { max-width: 100% !important; table-layout: fixed !important; }
.dze_page_main > .page pre   { white-space: pre-wrap !important; word-break: break-word !important; }
```

> **루트 클래스가 `.page` 가 아니면** (`.container` / `div.main` 등) — 같은 패턴을
> 그 클래스에 맞춰 치환한다. 핵심은 ① `.dze_page_main > <루트>` 의 2단 셀렉터,
> ② `!important`, ③ `main.innerHTML` 내부 `<style>` 삽입 3가지.

**바로 적용 (프리셋이 맞을 때, 권장 = `.page` 루트 기준):**

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  if (!main.isContentEditable) return { error: 'not editable — abort' };
  const root = main.querySelector(':scope > .page')
            || main.querySelector(':scope > .container')
            || main.querySelector(':scope > div.main');
  if (!root) return { error: 'no root (.page/.container/div.main)' };
  const cls = root.className.split(' ')[0];   // 첫 클래스만 셀렉터로
  const override = `\n/* ONEFFICE A4 단일 보통여백 프리셋 (zoom 1.3, 644px) */\n`
    + `.dze_page_main > .${cls} { width:644px !important; max-width:none !important; `
    + `margin:0 0 0 -1px !important; padding:0 !important; box-sizing:border-box !important; }\n`
    + `.dze_page_main > .${cls} img { max-width:100% !important; height:auto !important; }\n`
    + `.dze_page_main > .${cls} table { max-width:100% !important; table-layout:fixed !important; }\n`
    + `.dze_page_main > .${cls} pre { white-space:pre-wrap !important; word-break:break-word !important; }\n`
    + `* { outline: none !important; }\n`;
  // 기존 <style> 있으면 append, 없으면 main 맨 앞에 새로 삽입
  const existing = main.querySelector(':scope > style');
  if (existing) existing.textContent += override;
  else {
    const s = edDoc.createElement('style');
    s.textContent = override;
    main.insertBefore(s, main.firstChild);
  }
  return { ok: true, rootClass: cls, offsetW: root.offsetWidth };  // 기대: 644
})()
```

> **이 스니펫은 Step 7 과 Step 8 을 한 번에 해결한다.** 아래 "레거시 inline 방식"
> 은 구버전 호환·참고용으로만 남겨둔다.

---

**레거시 inline 방식 (Step 8 의 `!important` 와 함께 쓰면 실패 — 참고용):**

```javascript
// 모드 B 기준 (권장)
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  const container = main.querySelector(':scope > .container');
  if (!container) return { error: 'no .container (모드 A 라면 div.main 사용)' };
  container.style.cssText =
    'box-sizing:border-box;margin:0 0 0 -1px;padding:0;' +
    'width:644px;max-width:644px;';
  return { ok: true };
})()
```

```javascript
// 모드 A (레거시) 기준
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  const rootDiv = main.querySelector(':scope > div.main');
  if (!rootDiv) return { error: 'no rootDiv' };
  rootDiv.setAttribute('style',
    'box-sizing:border-box;padding:0;margin:0 0 0 -1px;width:644px;max-width:none;');
  return { ok: true };
})()
```

**Fallback — 프리셋이 안 맞으면 실측 (zoom 환산 필수):**

`-1 / 644` 는 `zoom=1.3` 환경 한정 고정값이다. 값이 이 근방이 아니면 줌/여백이
다른 것이므로 **하드코딩 금지** — 아래 실측 코드로 교체한다.

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  const lt = edDoc.querySelector('.dze_page_margin_indicator_lt');
  const rt = edDoc.querySelector('.dze_page_margin_indicator_rt');

  // ⚠️ 필수: transform matrix(zoom) 감지
  const docContainer = edDoc.querySelector('.dze_document_container');
  const tm = getComputedStyle(docContainer).transform.match(/matrix\(([^,]+)/);
  const zoom = tm ? parseFloat(tm[1]) : 1;   // 보통 1.3 (130%)

  const ltR = lt.getBoundingClientRect();
  const rtR = rt.getBoundingClientRect();
  const mR  = main.getBoundingClientRect();
  const padL = parseFloat(getComputedStyle(main).paddingLeft);

  // BCR 은 zoom 이후 viewport px → CSS px 로 환산 (zoom 나누기)
  const cssTargetWidth = (rtR.left - ltR.right) / zoom;
  const cssShiftLeft   = (ltR.right - (mR.left + padL * zoom)) / zoom;

  // 모드 B: .container / 모드 A: div.main
  const target = main.querySelector(':scope > .container')
               || main.querySelector(':scope > div.main');
  target.style.cssText =
    `box-sizing:border-box;margin:0 0 0 ${cssShiftLeft}px;padding:0;` +
    `width:${cssTargetWidth}px;max-width:${cssTargetWidth}px;`;
  return { zoom, cssShiftLeft, cssTargetWidth, targetClass: target.className };
})()
```

> 꺾쇠(`.dze_page_margin_indicator_*`)는 **편집모드에서만** DOM 에 렌더된다.
> 읽기모드에서 측정 시도 금지.

### Step 8. (Step 7 에 통합됨) !important 제약 + outline 보험

> **⚠️ 변경 사항 (2026-04-20)**: Step 7 의 "바로 적용" 스니펫이 이미 `!important`
> 제약·outline 제거·이미지/테이블/pre overflow 방지까지 **한 번에** 처리한다.
> 예전처럼 Step 7(inline width) 과 Step 8(`<style>` 주입) 을 나눠서 적용하면
> `max-width:100% !important` 가 inline `width:644px` 를 덮어 **오른쪽 꺾쇠가 빈다**.
>
> **Step 7 스니펫을 한 번 실행하면 Step 8 은 스킵해도 된다.** 별도로 추가 제약이
> 필요할 때만 아래 참고용 규칙을 같은 `<style>` 에 덧붙인다.

참고용 — 루트가 `.page` 가 아닌 레거시 HTML 에 추가할 때:

```css
/* main.innerHTML 안의 <style> 에 append. 에디터 head 주입은 저장 후 소실. */
* { outline: none !important; }
.container, .container * { max-width:100% !important; box-sizing:border-box !important; }
.container img { max-width:100% !important; height:auto !important; }
.container table { max-width:100% !important; table-layout:fixed !important; }
.container pre { white-space:pre-wrap !important; word-break:break-word !important; }
```

이미지·테이블·pre 요소가 꺾쇠 폭을 뚫는 걸 막고, ONEFFICE 자동 outline 도 제거한다.

### Step 9. (선택) 문서명 변경

편집모드에서만 가능. React/프레임워크 감지용 **native setter 필수** — 단순
`inp.value = '...'` 는 저장 시 이전 이름으로 복귀.

**⚠️ v0.4.0 보강 (2026-05-27 자비스 사이클 학습)**: native setter + Enter keydown 만으로는
ONEFFICE 의 React 내부 상태에 commit 되지 않는 경우가 있다. 저장 후 탭 제목이
`260527_새 문서 - ONEFFICE` 로 복귀하면 **`blur()` 호출 + `blur` 이벤트 dispatch 를
추가**해야 commit 된다. 본 스니펫은 1차 시도부터 blur 패턴을 포함한다.

> **OF 정본**: `await OF.setTitle('<원하는 문서명>')` — iframe 안 window prototype 의
> native setter + input/change/Enter keydown·keypress·keyup + `blur()` dispatch 를
> 모두 포함한다. 아래는 폴백 사본.

```javascript
(async () => {
  const idoc = document.getElementById('open_oneffice_body_iframe').contentDocument;
  const inp = idoc.getElementById('dze_ribbon_menu_title_text');
  if (!inp) return { error: 'title input not found' };
  const win = idoc.defaultView;   // ★ iframe 안 window 의 prototype 사용
  const nativeSetter = Object.getOwnPropertyDescriptor(
    win.HTMLInputElement.prototype, 'value'
  ).set;
  inp.focus();
  await new Promise(r => setTimeout(r, 100));
  nativeSetter.call(inp, '<원하는 문서명>');
  inp.dispatchEvent(new Event('input', { bubbles: true }));
  inp.dispatchEvent(new Event('change', { bubbles: true }));
  inp.dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', keyCode: 13, bubbles: true }));
  inp.dispatchEvent(new KeyboardEvent('keypress', { key: 'Enter', keyCode: 13, bubbles: true }));
  inp.dispatchEvent(new KeyboardEvent('keyup', { key: 'Enter', keyCode: 13, bubbles: true }));
  await new Promise(r => setTimeout(r, 200));
  inp.blur();                                                       // ★ commit 트리거
  inp.dispatchEvent(new Event('blur', { bubbles: true }));          // ★ 명시 dispatch
  await new Promise(r => setTimeout(r, 300));
  return { ok: true, value: inp.value };
})()
```

핵심 3 가지: ① `defaultView.HTMLInputElement.prototype` (iframe 안 window 의 prototype)
② keydown·keypress·keyup 모두 dispatch (Enter 처리 보장) ③ **`inp.blur()` + `blur` 이벤트
명시 dispatch** 가 React/ONEFFICE 내부 상태에 commit 을 트리거한다.

**타이틀 input ID: `#dze_ribbon_menu_title_text`** (검증됨).

### Step 10. 정렬 검증 → 저장 → 새로고침 검증 — 순서 엄수

**절대 순서: 주입 → 정렬 → 저장 → 새로고침.** 저장 전 새로고침하면 유실.

**(a) 정렬 확인** (모드 B 기준, 모드 A 면 `.container` → `div.main`):

```javascript
(() => {
  const iframe = document.getElementById('open_oneffice_body_iframe');
  const edDoc = iframe.contentDocument.getElementById('dzeditor_0').contentDocument;
  const main = edDoc.querySelector('.dze_page_main');
  const target = main.querySelector(':scope > .container')
              || main.querySelector(':scope > div.main');
  const r = target.getBoundingClientRect();
  const lt = edDoc.querySelector('.dze_page_margin_indicator_lt').getBoundingClientRect();
  const rt = edDoc.querySelector('.dze_page_margin_indicator_rt').getBoundingClientRect();
  return {
    aligned: Math.abs(r.left - lt.right) < 2 && Math.abs(r.right - rt.left) < 2,
    targetL: r.left, targetR: r.right, bracketL: lt.right, bracketR: rt.left
  };
})()
```

**(b) 저장 버튼 클릭 — 검증된 셀렉터:**

> **OF 정본 — 저장 = 2단계** (`OF.save()`): 내부에서 ① 읽기모드면 `OF.enterEdit()` 로
> 편집 전환 후 반영을 최대 3초 폴링(재열람 문서는 반영 ~2초 지연) → ② 저장버튼
> `TB_FILE_SAVE_REMOTE_0` JS `.click()`(`one001A17`) → **탭 제목 "데이터를 저장하고
> 있습니다." 전환**으로 저장 발생을 판정. 편집 전환 후에도 신호가 없으면
> `{ needsPhysicalClick: true, checkoutConflict }` 를 반환한다 → 그때만 호출부가
> `computer` **실제 마우스**로 저장 버튼을 폴백 클릭(체크아웃 경쟁 = "다른 창에서
> 편집 중" 팝업이면 다른 편집창부터 정리). ⚠️ `OF.save()` 는 async 라 `javascript_tool`
> 반환이 `{}` 로 비어 올 수 있으니(kit §3.5) **판정은 반환값이 아니라 탭 제목 전환
> 관찰**로 한다. 아래 JS 클릭은 편집모드에서만 동작하는 폴백 사본.

```javascript
document.getElementById('open_oneffice_body_iframe')
  .contentDocument.getElementById('TB_FILE_SAVE_REMOTE_0').click();
```

**저장 버튼 ID: `#TB_FILE_SAVE_REMOTE_0`** (검증됨).

> **⚠️ 재편집 세션은 읽기모드로 열림 → 편집 전환 후 저장 (v0.5.3, 2026-07-14 실측 정정)** —
> 위 JS 클릭은 편집모드에서만 동작한다. 저장된 문서를 새로고침·재열람하면 **읽기(R)모드**
> (`isContentEditable=false`)로 열려 저장이 무효다. **① 편집 토글**(`.dze_style_editmode_toolbar_normal`,
> 텍스트 "편집")을 **JS `.click()`으로 전환**(실측 — 신뢰 이벤트 불필요) → 위 JS 저장이 정상 작동
> (`one001A17` 호출). **② 편집 전환 후에도 탭 제목 전환이 없으면 체크아웃 경쟁**("다른 창에서
> 편집 중" 팝업) → 다른 편집창 정리 또는 `computer` 실제 마우스 폴백 (치명적 함정 4 참조).

**(c) 저장 완료 루프:**
1. 탭 제목이 `데이터를 저장하고 있습니다.` 로 변경
2. 3초 대기
3. 제목이 문서명으로 복귀 = 저장 완료
4. (재편집 세션) 검증은 **브라우저 새로고침 후 DOM 확인**으로 — a10 MCP 문서 조회
   API 는 캐시된 구버전을 반환할 수 있어 저장 직후 판정 금지

**(d) 그 후에만** 새로고침 또는 읽기모드 전환.

### Step 10.5. `.onex` 확장자 최종 육안 검증

저장·새로고침 후 **ONEFFICE 홈 화면**에서 방금 만든 문서를 찾아 파일명 옆
아이콘/확장자가 `.onex` 로 표기되는지 확인한다. 현재 API 레벨에서 확장자를
조회할 방법을 찾지 못해 **홈 화면 육안 확인만이 유일한 검증 경로**다.

`.noext` 로 보이면 Step 0 의 템플릿 버튼을 거치지 않은 것. 복구 절차:

1. 문제의 `.noext` 문서를 **삭제하지 말 것** (localStorage 에 내용이 남아 있지
   않을 수 있어 재추출 경로를 잃으면 안 됨)
2. opener 스킬을 올바르게 호출해 새 `.onex` 탭 생성
3. `.noext` 탭에서 Step 3.5 의 `localStorage.setItem('__doc_extract__', main.innerHTML)` 실행
4. 새 `.onex` 탭으로 전환, `localStorage.getItem` 으로 꺼내 주입
5. Step 7~10 반복 → 새로고침 → Step 10.5 로 재검증
6. 성공 확인 후에만 `.noext` 문서 삭제

### Step 11. 최종 검증 + 스크린샷

읽기모드 탭 클릭 → 스크린샷으로 최종 확인. 인라인 style 지속 여부 확인.

**새로고침 후 인라인 style 이 날아갔다면** — 해당 원피스 버전은 DOM 주입으로
영구 저장 불가능. 대안:
- 레이아웃 메뉴로 용지 여백 수동 변경
- 원챔버 업로드 후 원피스엔 링크만
- PDF/DOCX 첨부로 전환

### Step 12. 정리

```bash
pkill -f "http.server" || true
```

## 검증된 상수 요약 (한눈에)

| 항목 | 값 |
|------|-----|
| 편집 탭 클릭 좌표 | `[1361, 20]` |
| dzeditor iframe | `#open_oneffice_body_iframe → #dzeditor_0` |
| **주입 모드 — 모드 B** (컨테이너 보존) | 편집 화면 미관 우선. 인쇄·PDF·줌 시 사이즈 문제 발생 가능 |
| **주입 모드 — 모드 C** (평면, ★ v0.4.0 권장) | `<style>` 태그·`.container` 래퍼·`width` 픽셀 고정·`!important` 모두 없음. 인쇄·PDF·줌 친화. 보고서·외부 공유 기본 |
| 스타일 대상 (모드 B 한정) | `main > .page` (또는 `.container` / `div.main` — 원본 루트 클래스). 모드 C 는 정렬 대상 없음 |
| 스타일 주입 위치 (모드 B 한정) | **반드시 `main.innerHTML` 내부 `<style>`** — 에디터 iframe `head` 는 저장 시 증발 |
| 모드 C 의 스타일 위치 | 각 요소의 인라인 `style="..."` 속성만 사용 — `<style>` 태그 자체 없음 |
| 꺾쇠 셀렉터 | `.dze_page_margin_indicator_lt/rt` (편집모드에서만) |
| zoom 감지 셀렉터 | `.dze_document_container` 의 `transform: matrix(zoom, ...)` |
| 기본 zoom | `1.3` (브라우저 줌 130%) |
| 기본 프리셋 (A4·단일페이지·보통여백·줌 130%) | `.dze_page_main > .<루트> { width:644px !important; max-width:none !important; margin:0 0 0 -1px !important; padding:0 !important; box-sizing:border-box !important; }` |
| 타이틀 input | `#dze_ribbon_menu_title_text` |
| 저장 버튼 | `#TB_FILE_SAVE_REMOTE_0` |
| 문서설정 팝업 열기 | `#TB_MENU_RIBBON_0` → `#TB_SETTING_0` |
| 페이지분리 단일 / 다중 | `#dze_idx_onepagemode_on` / `_off` |
| 여백 좁게/보통/넓게 | `#dze_idx_print_margin_type1` / `2` / `3` |
| 용지 세로/가로 | `#dze_idx_paper_direction_type1` / `2` |
| 문서설정 확인 | `.duzon_dialog_buttonbox.new_ver input.duzon_dialog_btn_new_ok_normal` |
| CORS 서버 | `127.0.0.1:8765`, cwd `/tmp` — 응답에 `charset=utf-8` 필수(누락 시 한글 영구 손상, v0.5.1) |
| 탭 간 HTML 전달 | `localStorage['__doc_extract__']` (JS 반환값은 Chrome MCP 차단) |
| 확장자 검증 | 홈 화면 육안 확인만 가능 (API 미제공) |

## 사용하는 도구

| 단계 | 도구 |
|------|------|
| 새 탭 생성 | `dz-oneffice-new-doc-opener` (스킬 호출) |
| 탭 전환 | `mcp__Claude_in_Chrome__tabs_context_mcp` |
| DOM 접근 | `mcp__Claude_in_Chrome__javascript_tool` |
| UI 클릭 | `mcp__Claude_in_Chrome__left_click` (편집 탭, 리본 등) |
| 화면 확인 | `mcp__Claude_in_Chrome__computer` (screenshot) |
| CORS 서버 | `Bash` (`python3 http.server` 개조) |
| HTML 가공 | `Bash` (`python3 -c`) |

## 디버깅 체크리스트

- **`editable: false`** → 아직 편집모드 아님. 읽기모드 저장은 no-op. Step 1 재실행.
- **주입했는데 안 보임** → `dzeditor_0` 인지 확인. `dzeditor_9999` 는 offscreen 숨김.
- **폭이 이상함** → 줌/여백이 프리셋과 다름. Step 7 실측 fallback 으로 전환.
- **왼쪽은 맞는데 오른쪽 꺾쇠까지 안 채워짐 / `computed width = 490px`** → inline
  `width:644px` 가 `!important` 에 덮였다. 원인은 ① 원본 HTML `<style>` 의
  `.page { max-width: ... }`, ② Step 8 의 `.page * { max-width:100% !important }` 자가
  오버라이드. **해결**: Step 7 의 "바로 적용" 스니펫으로 `main.innerHTML` 내부
  `<style>` 에 `.dze_page_main > .<루트> { width:644px !important; max-width:none !important }`
  를 박는다. 에디터 `head` 에 주입한 style 은 저장 시 증발하므로 **반드시 main 내부**.
  (2026-04-20 AI위원회 5건 발행 시 재현·해결)
- **꺾쇠 rect 가 `{right:0}`** → 읽기모드에서 측정 시도함. 편집모드 재진입.
- **긴 문서가 페이지마다 잘림** → Step 3 단일페이지 모드 스킵했을 것.
- **이미지가 꺾쇠 뚫음** → Step 8 `!important` 제약 누락.
- **새로고침 후 리셋** → 저장 전에 새로고침했거나 `.dze_page_main` 직접 수정.
- **제목이 저장 후 원복** → Step 9 native setter 대신 `inp.value=` 직접 대입했거나,
  **`blur()` + blur 이벤트 dispatch 누락**. native setter + blur 패턴 모두 필요
  (2026-05-27 v0.4.0 보강). React/ONEFFICE 내부 상태 commit 트리거가 blur 이벤트.
- **저장 후 인쇄·PDF 변환·줌 변경 시 사이즈가 깨짐 (편집 화면은 정상)** → 모드 B 의
  `.container` 안 `width:644px !important` 가 ONEFFICE 인쇄·PDF·줌 시스템과 충돌
  (페이지 크기와 무관하게 픽셀 고정). 진단 — `main.children.length === 2` (style +
  container) 면 모드 B, `10+` 평면이면 모드 C. **해결**: 모드 C (평면 주입) 로 재작성.
  `<style>` 태그·`.container` 래퍼·`width` 픽셀 고정·`!important` 모두 제거, 본문
  요소를 `main` 직계 자식으로 평탄화. 사용자가 ONEFFICE 안에서 직접 복사·붙여넣기로
  만든 문서는 항상 평면 패턴이라 인쇄·PDF·줌 정상. (2026-05-27 v0.4.0 보강 — 자비스
  AWS 회의록 사이즈 문제 사이클에서 발견·해결)
- **fetch 실패** → CORS 서버 cwd 가 `/tmp` 인지, 포트 8765 살아있는지 확인.
- **모드 C 평탄화 후에도 우측 여백 과다·오버플로 재발** → `getComputedStyle()`로
  구운 값이 원본의 `margin:auto`·`grid-template-columns`(`1fr` 등) 상대값을 그 순간
  viewport 기준 절대 px 로 고정해버렸을 가능성. grid/auto-margin 을 쓰는 클래스를
  원본 상대값으로 명시 오버라이드할 것. (2026-07-06 v0.5.1 실측)
- **저장 후 새로고침하니 타임라인 점 마커가 사라짐 / 볼드 라벨에 의도치 않은
  줄바꿈이 생김** → 빈 장식용 `<span>`은 저장 시 삭제, `<b>`/`<strong>`은 통째
  언랩된다. `<div style="display:inline">`(또는 `inline-block`)로 치환할 것. 검증은
  저장 직후가 아니라 새로고침 후 DOM 재조회로. (2026-07-06 v0.5.1 실측)
- **주입된 한글이 `�`(U+FFFD)로 깨짐, 재로드해도 복구 안 됨** → Step 5 CORS 서버가
  `charset=utf-8` 없이 응답한 것. `guess_type` 오버라이드로 `text/*` 에 charset 을
  붙이고, 캐시버스트 쿼리스트링(`?v=N`)으로 강제 재요청할 것. (2026-07-06 v0.5.1 실측)
- **폭이 1.3 배씩 어긋남 / `diffL=29`·`diffR=280` 같은 엉뚱한 값이 반복됨**
  → `.dze_document_container` 의 `transform: matrix(1.3, ...)` 미반영. Step 7 의
  BCR→CSS px 환산(`/ zoom`) 코드로 교체. 하드코딩 `644 / -1` 은 `zoom=1.3` 환경
  한정 프리셋임을 기억.
- **탭 간 JS 반환값이 `[BLOCKED: Cookie/query string data]` 로 삭제됨** → innerHTML
  에 쿼리스트링 비슷한 문자열 포함. `.slice()`, `btoa()` 도 안 먹힌다. Step 3.5
  의 `localStorage['__doc_extract__']` 우회법 사용.
- **저장은 됐는데 `.noext` 로 보임** → Step 0 에서 "ONEFFICE 워드" 버튼을 거치지
  않고 일반 아마링크만 열었기 때문. 반드시 템플릿 버튼 경유. Step 10.5 복구 절차
  참조.
- **재편집 세션에서 저장을 눌러도 반영 안 됨 (탭 제목 전환 없음)** → 재열람 문서가
  **읽기(R)모드**로 열렸기 때문(`isContentEditable=false`). **① 편집 토글**
  (`.dze_style_editmode_toolbar_normal`, "편집")을 **JS `.click()` 전환**(실측 — 신뢰
  이벤트 불필요) 후 JS 저장이 `one001A17`로 정상 작동. **② 편집 전환 후에도 무효면 체크아웃
  경쟁**("다른 창에서 편집 중" 팝업) → 다른 편집창 정리 또는 `computer` 실제 마우스 폴백.
  검증은 새로고침 후 DOM (a10 MCP 조회는 캐시 구버전 오판 주의).
  (2026-07-14 v0.5.3 라이브 실측 — forge `참고자료/리포트/2026-07-13-원피스-사내망-API규명-점검.md` §7)
- **주입 후 `.container` CSS 가 깨짐** → 모드 A 로 주입했기 때문. `.container`
  래퍼가 있는 HTML 은 모드 B (Step 6 권장) 로 통째 주입할 것.
- **읽기모드에서 카드/섹션에 점선(dashed outline)이 보임** → ONEFFICE 가 블록 요소에
  `outline: 1px dashed` 를 자동 주입한 것. Step 4 Python 스니펫에
  `* { outline: none !important; }` 가 포함됐는지 확인.
  즉시 수정: Step 8 JS 스니펫으로 편집모드에서 `<style>` 태그 주입 후 재저장.

## 함께 쓰는 스킬

- **dz-oneffice-kit** — 원피스 DOM 배관 정본(OF 라이브러리). 실행 시 그 SKILL.md §1 의
  OF 코드블록을 1회 주입 → `OF.*` 호출. 셀렉터·좌표·프리셋 단일 출처(위 「OF 라이브러리 인용」)
- **dz-oneffice-new-doc-opener** — Step 0 새 `.onex` 문서 탭 생성
- **dz-oneffice-reader** — 기존 원피스 문서 내용을 초안으로 쓸 때 (Step 3.5 와 조합 가능)
- **dz-figma-make-reviewer** — Figma Make 산출물을 HTML 로 먼저 뽑을 때

## 관련 Command

- **`/dz-oneffice-write`** — 이 스킬을 포함한 end-to-end 워크플로우 커맨드
