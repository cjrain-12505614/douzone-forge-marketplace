---
name: dz-deck-builder
version: 0.2.3
description: HTML 발표자료 또는 본문 구조를 편집 가능한 PowerPoint(.pptx)로 만드는 스킬. 배경 광선·그라데이션 칩만 이미지로 두고 텍스트·표·카드·도형은 PowerPoint 네이티브로 생성해 발표자 자유 편집 가능. pptxgenjs 함정(불릿 [object Object] 깨짐·배경 의사요소 높이 초과·다크 저대비·옵션 객체 재사용) 자동 회피 + 좌표 변환(px/96=inch, pt=px*0.75) + 더존 폰트 매칭 + 시각 QA 서브에이전트. 사용자가 "PPTX 만들어줘"·"발표자료 파워포인트로"·"편집 가능한 ppt"·"deck 만들어줘"·"발표 슬라이드 pptx"·"이 HTML을 ppt로" 등 트리거 시 본 스킬 활성.
---

# dz-deck-builder — 편집 가능 PPTX 발표자료 생성

> **의존 SSoT (워크스페이스)**: `규칙/프로세스/발표자료-PPTX-작성-표준.md`(절차·함정 C1~C7) · `규칙/프로세스/산출물-스타일-표준.md`(더존 EQT 다크 토큰) · `규칙/폰트/_README.md`(폰트) · `규칙/프로세스/분석형-산출물-파이프라인.md`(⑥단계) — 본 스킬은 이 표준의 실행 절차다.

> **용어 풀이**: PPTX(파워포인트 발표 파일) · pptxgenjs(자바스크립트로 PPTX 만드는 도구) · 네이티브(PowerPoint가 직접 편집 가능한 요소) · run(한 줄 안 색·굵기 같은 글자 조각) · QA(품질 검증)

## 트리거

"PPTX 만들어줘" · "발표자료 파워포인트로" · "편집 가능한 ppt" · "deck 만들어줘" · "발표 슬라이드 pptx" · "이 HTML을 ppt로"

## 핵심 설계 원칙

1. **배경만 이미지, 나머지는 네이티브** — pptxgenjs는 그라데이션 미지원. 다크 배경·광선·그라데이션 칩만 PNG로 깔고, 텍스트·표·카드·도형은 `addText`·`addTable`·`addShape`로 만들어 **편집 가능**하게 한다.
2. **스타일은 산출물 스타일 표준을 따름** — 기본값은 더존 EQT 다크(미드나잇 네이비 #0C0E1A + 블루 #5B7CFF·퍼플 #A78BFA 그라데이션). **사용자 지정 스타일이 항상 우선**.
3. **시각 QA 서브에이전트 필수** — 작성자는 기대한 것만 본다. 신선한 눈으로 2회 이상.

## 도구

```bash
npm install -g pptxgenjs          # PPTX 생성 (NODE_PATH=$(npm root -g))
pip3 install Pillow numpy         # 배경 이미지
# PDF 변환·시각 QA: LibreOffice(soffice) + pdftoppm
# 시각 QA(Step 6) 전제 — 없으면 아래 맥 대안을 쓰고, 그것도 안 되면 「시각 QA 못 함」으로 보고한다
#   LibreOffice: soffice 실행 파일이 PATH 에 있어야 함 (예: brew install --cask libreoffice)
#     — pptx 스킬 변환기 soffice.py 는 PATH 에서 soffice 를 찾는다. 없으면 FileNotFoundError: 'soffice' 로 끝난다
#   poppler: pdftoppm (예: brew install poppler)
#   Python 3.10 이상: soffice.py 가 TemporaryDirectory(ignore_cleanup_errors=…) 를 써서 3.9 에서는 TypeError
#     — 기본 python3 가 3.9 인 맥이면 uv 로 설치된 판을 쓴다(Step 6 첫 줄로 SOFFICE 를 먼저 정한 뒤):
#       uv run --python 3.12 python "$SOFFICE" --headless --convert-to pdf 발표자료.pptx
#     이 맥에서는 TypeError 를 넘어 soffice 를 부르는 단계까지만 확인했다 — LibreOffice 가 없어 끝까지 변환해 본 적은 없다(2026-10-03)
#   (2026-10-02 이 맥 실측: soffice·pdftoppm 없음, 기본 python3 3.9.6, uv 의 3.10.20·3.12.13 있음, Keynote 있음)
# 맥 대안 — Keynote 로 PDF, PDFKit 으로 쪽 그림 (2026-10-03 이 순서대로 실행해 13쪽 확인). 「발표자료」는 실제 파일 이름으로 바꿔 넣는다
#   1) 열기 전에 같은 이름의 문서가 열려 있지 않은지 본다 — 0 이어야 한다(0 이 아니면 그 문서를 닫거나 멈춘다):
#      osascript -e 'tell application "Keynote" to count (documents whose name is "발표자료")'
#      같은 이름 문서가 열려 있으면 새 문서는 「발표자료 2」가 되고 3) 이 예전 문서를 내보낸다(같은 파일을 다시 열어도 새로 불러와 번호가 붙는다)
#   2) open -a Keynote "<경로>/발표자료.pptx"        # /tmp 아래 파일도 열린다
#      문서 이름은 확장자를 뺀 파일 이름이다. 1) 의 count 가 1 이 될 때까지 0.5초 간격으로 기다린다
#   3) osascript -e 'tell application "Keynote"' -e 'set d to first document whose name is "발표자료"' \
#        -e 'export d to (POSIX file "<경로>/발표자료.pdf") as PDF' -e 'close d saving no' -e 'end tell'
#      AppleScript 에서 `set d to open (POSIX file …)` 로 연 뒤 `export d …` 를 보내면 Keynote 가 죽으며 -609 가 났다
#      (2026-10-02 세 번·10-03 한 번, Keynote 를 미리 띄워 둔 상태에서도. 왜 죽는지는 확인 못 함) — 열기는 2) 의 open -a 로 한다
#   4) 쪽 그림(pdftoppm 대신): osascript -l JavaScript "<플러그인 dz-deck-builder 스킬 폴더>/templates/pdf_pages.js" "<경로>/발표자료.pdf" "<그림 폴더>"
#      그림은 sRGB 로 저장된다 — sRGB 가 아닌 색 프로필이 붙은 그림의 픽셀 값을 sRGB 로 읽어 색·대비를 잘못 잰 사고가 있었다
#      (2026-10-02: `sips` 로 PDF 를 그린 그림에는 Display P3 가 붙는다. PDFKit 그림을 변환 없이 저장하면 화면 색 프로필이 붙는다)
#   이 PC 에 DOUZONE 서체가 없으면 대체 서체로 그려지니 서체 판정에는 쓰지 않는다
```

## 표준 실행 흐름

### Step 0. 설계안 — 브랜드가 정한 것과 이번에 정할 것을 나눈다

미학 근거는 `dz-frontend-design`(Anthropic frontend-design 원문 동봉 + 더존 보강)이다. 다만 EQT 다크는 사내 브랜드 템플릿이라 아래 요소는 원본의 「피할 기본값」에 겹쳐도 **그대로 쓴다.** 근거는 EQT 발표 원본(`EQT 발표 5_4_v1.0.pdf`, 2026-05)을 2026-10-02에 쪽별로 대조한 결과다.

| 브랜드 고정 요소 (그대로) | 이번 발표에서 정할 요소 |
|---|---|
| 미드나잇 네이비 바탕·블루·퍼플, 122° 대각선 광선, DOUZONE Title·Text | 장 종류별 배치(ASCII 와이어프레임으로 비교) |
| 헤더띠 「브랜드 \| 장 제목」, 표지 왼쪽 위 브랜드 슬로건 「Authentic innovation, / AX and More」, 표지 Confidential 문구 | 장마다 실제로 강조할 한 곳 |
| 가운데 흰 제목 + 핵심 구절만 블루·퍼플 + 아래 설명 문장 | 카드로 묶을 것과 그냥 놓을 것 |
| 카드 안 영문 대문자 소제목(INPUT 등), 단계 카드의 그라데이션 머리, 하단 캡슐 강조바 | 장 제목 문장(결론 한 문장), 마지막 장(결정 요청·다음 행동) |

- 카드 안 영문 소제목(INPUT 등)은 처음부터 대문자로 적는다 — `lab()` 은 0.2.2 부터 대문자로 바꾸지 않는다(0.1.0~0.2.1 의 자동 변환이 Gartner·Amaranth 10 을 GARTNER·AMARANTH 10 으로 바꿔서 없앴다). 넓은 자간은 대문자만으로 된 라벨에만 붙는다(0.2.3).
- 표지 슬로건은 원본 문구를 쓴다. 원본 슬로건은 글자가 아니라 그림(1쪽 `/X2`)이라 PDF 글자 추출에 나오지 않으니 원본 쪽 그림으로 확인한다. 원본 첫 줄은 흰 글자(「i」 위에 파랑·보라 별 장식 둘), 둘째 줄은 하늘색→파랑→보라→자홍 가로 그라데이션 글자다. pptxgenjs(4.0.1)는 글자 채우기를 단색만 지원해서(`type: 'none'|'solid'`) 템플릿은 둘째 줄을 블루·퍼플 두 색 run 으로 흉내 내고 별 장식은 뺐다. PPTX 형식 자체는 `a:rPr` 안의 `a:gradFill` 을 허용하므로, 그라데이션이 꼭 필요하면 빌드 뒤 slide XML 을 고쳐 넣는다(2026-10-03 Keynote 에서 그라데이션으로 그려지는 것 확인, PowerPoint 는 미확인). (0.2.3 — 0.2.2 는 PDF 글자 추출만 보고 원본 표지 위쪽에 영문 문구가 없다고 판단해, 슬로건 자리에 있던 예시 문구 「Market Insight. / AI Agent & More」를 지웠다. 원본 슬로건 문구는 0.2.3 에서 처음 넣었다)
- 단계 카드의 그라데이션 머리 위 흰 글자는 14pt(18.7px) 굵게로 쓴다. 흰 글자 대비는 왼쪽 끝 4.39:1 에서 오른쪽으로 갈수록 줄어 약 80.7% 지점에서 3:1 아래로 떨어지고(80% 지점 3.03:1), 오른쪽 끝은 2.72:1 이다(템플릿 `grad_h.png` 원본 값, 2026-10-02 실측). 칩 이름은 가운데 정렬이므로 오른쪽 끝이 80% 를 넘지 않게 이름 폭을 칩 너비의 60% 이하로 짧게 쓴다(20~80% 구간 최저 3.03:1). 14pt 굵게에 3:1 은 WCAG 1.4.3(AA) 큰 글자 기준이다(AAA 1.4.6 은 4.5:1). 한글은 WCAG 정의의 「한중일 서체는 같은 크기에 해당하는 값」 단서가 걸리지만 `dz-frontend-design` §8 처럼 라틴 기준 크기를 그대로 쓴다.
- EQT 원본 10쪽 단계 칩은 칩마다 다른 색 조각이다. PDF 의 그라데이션 정의(sRGB2014)로 칩 영역 안의 흰 글자 대비를 재면 ① 왼쪽 약 2.1 → 오른쪽 약 4.8(`#46C6FF→#3B59FF`, 이름이 놓인 가운데 약 3.2), ② 4.45~6.0, ③ 4.78~6.03, ④ 4.59~4.65, ⑤ 4.26~4.46(`#A041FF→#B339FF`)이다(2026-10-03). 템플릿 끝색 `#A78BFA` 는 원본 보라 칩보다 밝다 — 토큰을 바꿀지는 따로 정한다.
- 가운데 제목 **위** 라벨은 브랜드에 없다. `centerTitle` 의 eyebrow는 헤더띠에 없는 정보가 있을 때만 글자를 넘기고, 아니면 `null` 을 넘긴다(두 번째 자리 인자라 생략할 수 없다).
- 쪽 번호 근거와 둥근 카드·번호 원·지표 칸 보충은 워크스페이스 `발표자료-PPTX-작성-표준.md` §0에 있다. 한쪽 표를 고치면 다른 쪽도 함께 고친다.
- 설계안은 작업 세션 폴더에 남기고, 빌드 뒤 스크린샷으로 `dz-frontend-design` §8 점검을 한다.

### Step 1. 좌표·단위 변환 (HTML 1280×720 → PPTX)
- 슬라이드: 커스텀 레이아웃 13.333 × 7.5 인치
- 위치·크기: `inch = px / 96`  ·  폰트: `pt = px × 0.75`

### Step 2. 배경 이미지 생성
`templates/gen_bg.py` 실행 → `bg_body.png`(본문)·`bg_cover.png`(표지)·`grad_h.png`(가로 그라데이션 칩). 베이스 #0C0E1A + 122° 대각선 가우시안 밴드 + 좌하단 글로우.

### Step 3. 빌드 스크립트 작성
`templates/build.js`를 복사해 **Step 0 설계안에 맞춰 SLIDE 블록을 고친다**(예시 13장의 배치를 그대로 쓰라는 뜻이 아니다). 헬퍼(`header`·`footer`·`centerTitle`·`card`·`chipCard`·`lab`·`embar`·`tbl`·`r`)를 재사용한다.

### Step 4. ⚠️ 함정 7건 (C1~C7) — 반드시 회피

| # | 함정 | 회피 |
|---|------|------|
| C1 | 배경 장식 의사요소가 슬라이드 높이 초과 | 장식은 슬라이드 범위(0~100%) 안에 가둠. PPTX는 배경 이미지라 무관하나 HTML 정합 시 주의 |
| C2 | 불릿 한 줄에 여러 색 → `[object Object]` 깨짐 | run 단위로 펼침: 첫 run `bullet:{indent:16}`, 끝 run `breakLine:true`. 배열을 한 run의 text 자리에 넣지 말 것 |
| C3 | 다크 배경 저대비 텍스트 | 본문 `#C2C8D6` 이상, 보조 `#9AA2B6` 이상. `#767E94` dim은 광선 밖 바탕(헤더띠·오른쪽 위) 캡션만. footer 캡션은 `#C2C8D6`, 표지 아래쪽 글자는 흰색. 그라데이션 칩 머리 위 흰 글자는 14pt 굵게 + 이름 폭은 칩 너비의 60% 이하(가운데 정렬 기준. 칩 머리 대비 실측값과 쓰는 법: 표준 §3 C3 「단계 카드의 그라데이션 칩 머리」 항목) |
| C4 | 그라데이션 표현 | 배경·칩만 이미지, 나머지 네이티브 |
| C5 | 좌표·폰트 단위 혼동 | inch=px/96, pt=px*0.75 (Step 1) |
| C6 | 옵션 객체 재사용 | 그림자 등 매번 새 객체 `const mk=()=>({...})` |
| C7 | 시각 QA 누락 | 서브에이전트 2회+ (Step 6) |

**C2 정답 패턴**:
```javascript
runs.push(r("굵은 라벨", { bullet:{indent:16}, bold:true, color:"FFFFFF" }));
runs.push(r(" 설명", { breakLine:true, color:"C2C8D6" }));
```

### Step 5. 폰트 매칭 (더존)
- PPTX는 시스템 설치 폰트. `fontFace`는 정확히 `'DOUZONE Title'`(제목)·`'DOUZONE Text'`(본문).
- 미설치 PC는 폴백 → 빌드 후 설치 여부 확인·안내. 폰트 파일·family·설치: 워크스페이스 `규칙/폰트/_README.md`.

### Step 6. 시각 QA (서브에이전트)
```bash
# pptx 스킬 변환기는 설치 위치(긴 ID 폴더)가 환경마다 다르고 갱신 때 바뀔 수 있다 — 고정 경로를 쓰지 말고 찾아서 쓴다(이 줄을 먼저 실행)
SOFFICE=$(find ~/Library/Application\ Support/Claude -name soffice.py -path '*pptx*' 2>/dev/null | head -1)
python3 "$SOFFICE" --headless --convert-to pdf 발표자료.pptx   # 기본 python3 가 3.9 면 uv run --python 3.12 python "$SOFFICE" …(도구 절)
rm -f slide-*.jpg && pdftoppm -jpeg -r 110 발표자료.pdf slide
unzip -o -q 발표자료.pptx -d _check && grep -rl "object Object\|undefined\|NaN" _check/ppt/slides/*.xml
```
LibreOffice·pdftoppm 이 없는 맥이면 도구 절의 맥 대안(Keynote → PDF → `pdf_pages.js` 쪽 그림)을 쓴다.
서브에이전트(general-purpose)에게 이미지 경로 + 각 슬라이드 예상 내용을 주고 overflow·겹침·저대비·`[object Object]`·폰트 두부(□) 검사. 수정 → 영향 슬라이드만 재검증 (한 번의 수정-검증 후 멈춤).

### Step 7. 저장
산출물은 모듈 `시장조사/`(또는 해당) 폴더, 빌드 자산은 같은 폴더 `_pptx-src/`에 보존(휘발 방지).

## 동봉 템플릿

| 파일 | 용도 |
|---|---|
| `templates/build.js` | 검증된 13장 빌드 예시 (KISS 시장조사 발표자료, 함정 C1~C7 회피 적용) — 헬퍼는 재사용하고 SLIDE 블록은 Step 0 설계안에 맞춰 고친다 |
| `templates/gen_bg.py` | 더존 EQT 다크 배경 3종 생성 (PIL+numpy) |
| `templates/pdf_pages.js` | PDF 쪽마다 PNG 그림(sRGB 저장) — pdftoppm 이 없는 맥의 시각 QA 용 (macOS PDFKit, `osascript -l JavaScript`, 플러그인 1.33.3부터) |

## cross-ref

- 워크스페이스 SSoT: `규칙/프로세스/발표자료-PPTX-작성-표준.md`(절차 정본) · `규칙/프로세스/산출물-스타일-표준.md`(디자인 토큰)
- 연계 스킬: `dz-oneffice-writer`(원피스 주입) · `dz-frontend-design`(미학 근거 — 브랜드 고정 요소는 Step 0 표가 우선) · `dz-external-report`(외부 보고 어휘)
- 도구 운영: `규칙/프로세스/디자인도구-MCP-운영가이드.md`(Figma·MCP·로컬 서버·스크린샷)
