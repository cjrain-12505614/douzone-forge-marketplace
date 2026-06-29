---
name: dz-deck-builder
version: 0.1.0
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
```

## 표준 실행 흐름

### Step 1. 좌표·단위 변환 (HTML 1280×720 → PPTX)
- 슬라이드: 커스텀 레이아웃 13.333 × 7.5 인치
- 위치·크기: `inch = px / 96`  ·  폰트: `pt = px × 0.75`

### Step 2. 배경 이미지 생성
`templates/gen_bg.py` 실행 → `bg_body.png`(본문)·`bg_cover.png`(표지)·`grad_h.png`(가로 그라데이션 칩). 베이스 #0C0E1A + 122° 대각선 가우시안 밴드 + 좌하단 글로우.

### Step 3. 빌드 스크립트 작성
`templates/build.js`를 복사해 **SLIDE 블록의 본문 데이터만 교체**한다. 헬퍼(`header`·`footer`·`centerTitle`·`card`·`chipCard`·`lab`·`embar`·`tbl`·`r`)를 재사용한다.

### Step 4. ⚠️ 함정 7건 (C1~C7) — 반드시 회피

| # | 함정 | 회피 |
|---|------|------|
| C1 | 배경 장식 의사요소가 슬라이드 높이 초과 | 장식은 슬라이드 범위(0~100%) 안에 가둠. PPTX는 배경 이미지라 무관하나 HTML 정합 시 주의 |
| C2 | 불릿 한 줄에 여러 색 → `[object Object]` 깨짐 | run 단위로 펼침: 첫 run `bullet:{indent:16}`, 끝 run `breakLine:true`. 배열을 한 run의 text 자리에 넣지 말 것 |
| C3 | 다크 배경 저대비 텍스트 | 본문 `#C2C8D6` 이상, 보조 `#9AA2B6` 이상 (`#767E94` dim은 캡션만) |
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
python3 <pptx-skill>/scripts/office/soffice.py --headless --convert-to pdf 발표자료.pptx
rm -f slide-*.jpg && pdftoppm -jpeg -r 110 발표자료.pdf slide
unzip -o -q 발표자료.pptx -d _check && grep -rl "object Object\|undefined\|NaN" _check/ppt/slides/*.xml
```
서브에이전트(general-purpose)에게 이미지 경로 + 각 슬라이드 예상 내용을 주고 overflow·겹침·저대비·`[object Object]`·폰트 두부(□) 검사. 수정 → 영향 슬라이드만 재검증 (한 번의 수정-검증 후 멈춤).

### Step 7. 저장
산출물은 모듈 `시장조사/`(또는 해당) 폴더, 빌드 자산은 같은 폴더 `_pptx-src/`에 보존(휘발 방지).

## 동봉 템플릿

| 파일 | 용도 |
|---|---|
| `templates/build.js` | 검증된 13장 빌드 정본 (KISS 시장조사 발표자료, 함정 C1~C7 회피 적용) — SLIDE 본문만 교체 |
| `templates/gen_bg.py` | 더존 EQT 다크 배경 3종 생성 (PIL+numpy) |

## cross-ref

- 워크스페이스 SSoT: `규칙/프로세스/발표자료-PPTX-작성-표준.md`(절차 정본) · `규칙/프로세스/산출물-스타일-표준.md`(디자인 토큰)
- 연계 스킬: `dz-oneffice-writer`(원피스 주입) · `dz-frontend-design`(미학 1차 인용) · `dz-external-report`(외부 보고 어휘)
- 도구 운영: `규칙/프로세스/디자인도구-MCP-운영가이드.md`(Figma·MCP·로컬 서버·스크린샷)
