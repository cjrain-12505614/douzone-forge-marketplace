---
name: dz-extract-design-tokens
description: "Figma Make에서 디자인 토큰 추출 (디자인 적용 스프린트용)"
---

# /extract-design-tokens 커맨드

Figma Make 산출물에서 디자인 토큰(색상, 폰트, 간격 등)을 추출하여
개발팀 디자인 적용 지시서를 준비합니다.

## 입력

사용자가 Figma Make URL을 제공하거나, 이전에 공유/기록된 URL을 사용합니다.

## 실행 절차

1. **Figma Make 소스 파일 조회**
   - `get_design_context`로 전체 파일 목록 조회
   - 스타일 관련 파일 식별: theme.css, tailwind.css, fonts.css, index.css 등

2. **스타일 파일 읽기**
   - CSS 변수(--color-*, --font-*, --spacing-* 등) 추출
   - Tailwind 커스텀 설정 추출
   - 폰트 패밀리, 웨이트, 사이즈 정보 추출

3. **디자인 토큰 정리**

   ```markdown
   ## 디자인 토큰

   ### 색상
   | 토큰명 | 값 | 용도 |
   |--------|-----|------|

   ### 폰트
   | 토큰명 | 값 | 용도 |
   |--------|-----|------|

   ### 간격/크기
   | 토큰명 | 값 | 용도 |
   |--------|-----|------|

   ### 라운드(radius)
   | 토큰명 | 값 | 용도 |
   |--------|-----|------|

   ### 그림자(shadow)
   | 토큰명 | 값 | 용도 |
   |--------|-----|------|
   ```

   **5 카테고리를 모두 채운다** — color · typography · spacing · **radius** · **shadow**. 색은 **WCAG AA 대비**(본문 4.5 이상)까지 확인한다. 근거: `skills/dz-prism-agent/SKILL.md` 산출·AC 규격.

4. **A10 현행 토큰과 비교 (⛔ `tailwind.config` 아님 — A10에는 Tailwind가 없다)**

   비교 기준은 아래 3곳이다.

   | 대조 대상 | 무엇 | 근거 |
   |---|---|---|
   | designcenter-figma `tokens/source/{base,semantic}/*.json` | 제품 토큰 정본 — **W3C DTCG 포맷**(`$name`·`$type`·`$value`) + Tokens Studio 메타, **base(원시) → semantic(별칭)** 2계층, **Style Dictionary 3** 빌드 | `Amaranth10/_소스분석/designcenter-figma-분석.md`(forge) |
   | `klago-pub-www/src/www/css/klago.scss` | 퍼블리싱 착지점 — **CSS 변수(`--`) 108건 / Sass 변수(`$`) 0건**, 색·치수 하드코딩 관행 | `규칙/프로세스/퍼블리싱-코드스타일.md`(forge) §6 |
   | `참고자료/디자인자산/화면설계서표준-디자인토큰.json`(forge) | 화면설계서 표준 Figma 실측 토큰 (같은 폴더 인벤토리 md와 짝) | `참고자료/디자인자산/INDEX.md`(forge) |

   - **base 값(hex)을 컴포넌트에 직접 넣지 않는다** — semantic 별칭(`{base.blue.600}` 꼴)을 만들어 참조시킨다.
   - 충돌이 보이면 「덮어쓰기」를 제안하기 전에 **범위를 먼저 가른다.** A10 제품·WEHAGO Web·더존 CI·화면설계서 표준은 서로 다른 문서의 서로 다른 주어이며 주 색상이 다르다(`참고자료/디자인자산/A10-디자인시스템-라이브러리-구조-설계.md`(forge)).
   - 추가/변경 필요 토큰과 충돌 값을 표로 남긴다.

5. **디자인 적용 지시서 초안 작성**
   - 토큰 매핑 테이블
   - 컴포넌트별 className 변경 목록
   - 적용 우선순위 제안

## 사용 예시

```
/dz-extract-design-tokens https://www.figma.com/make/ABC123/My-Project
```

## 산출 위치·하류 계약

- 저장: `프로젝트/PRJ-NNNN_*/02_설계/{날짜}-{주제}-디자인토큰.md`(forge) — PRISM 산출 규격(`skills/dz-prism-agent/SKILL.md`)
- 다음 단계(WEAVER 퍼블리싱)는 **디자인 토큰 적용률 90% 이상**으로 채점한다(`skills/dz-weaver-agent/SKILL.md`) → **미매핑 토큰을 표에 남겨 넘긴다.** 빠뜨리면 하류에서 채점이 안 된다.

## 주의사항

- **원격 Figma MCP는 비공개 파일을 못 읽는다** — 로컬 Dev Mode MCP(`127.0.0.1:3845`)를 쓴다. 진단 절차 `규칙/프로세스/디자인도구-MCP-운영가이드.md`(forge) §1
- Figma 변수 자체를 뽑을 때는 `get_variable_defs` 계열을 쓴다 — CSS 파일 파싱만으로는 변수 등록 여부를 알 수 없다.
- Figma MCP는 읽기 전용 — 토큰 추출만 가능하고 Figma 수정은 PM이 직접 수행
- 추출된 토큰은 **Style Dictionary 3** 빌드(`tokens/source` → `tokens/dist`, web은 JS + CSS 변수)를 거쳐 소비된다 — "빌드 설정에 맞게"가 아니라 이 도구 기준이다.
- ⚠️ 상위 정본 **D-09 디자인 표준은 아직 없다**(`규칙/프로세스/디자인-표준.md` 미존재). 본 커맨드는 그 공백을 하위 표준 직접 인용으로 메운다 — D-09 신설 시 이 절을 그쪽으로 인계한다. _(확인 필요 2026-08-13)_

## 관련

- 토큰 정본 분석: `Amaranth10/_소스분석/designcenter-figma-분석.md`(forge)
- 퍼블리싱 착지점: `규칙/프로세스/퍼블리싱-코드스타일.md`(forge) §6
- forge 로컬 대조본: `참고자료/디자인자산/`(forge) — 화면설계서표준 토큰 json · 인벤토리 md · 라이브러리 구조 설계
- 짝 에이전트: `skills/dz-prism-agent/SKILL.md`(디자인 토큰) · `skills/dz-weaver-agent/SKILL.md`(퍼블리싱 적용)
