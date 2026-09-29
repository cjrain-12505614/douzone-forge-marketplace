---
name: dz-review-figma
description: "Figma Make 산출물 검증 실행"
---

# /review-figma 커맨드

Figma Make 산출물을 화면설계서 대비 검증합니다.

## 입력

사용자가 Figma Make URL을 제공하거나, 이전에 공유된 URL이 있으면 그것을 사용합니다.
URL 형식: `https://www.figma.com/make/{fileKey}/{fileName}`

## 0. 선행 확인 (⛔ 빠뜨리면 조회 자체가 안 된다)

- **원격 Figma MCP(`mcp.figma.com`)는 비공개 파일을 읽지 못한다.** 필요한 것은 **로컬 Dev Mode MCP** — Figma 데스크톱 앱이 여는 `127.0.0.1:3845`.
  ```bash
  lsof -nP -iTCP -sTCP:LISTEN | grep 3845
  curl -s -o /dev/null -w "%{http_code}\n" --max-time 3 http://127.0.0.1:3845/sse   # 200 기대
  ```
  등록·진단 절차 정본: `규칙/프로세스/디자인도구-MCP-운영가이드.md`(forge) §1
- 도구 인자 이름이 거부되면 **추정해 바꾸지 말고 도구 스키마를 먼저 확인한다** (서버 판에 따라 인자 없이 「현재 선택 노드」 기준으로 동작할 수 있다).

## 실행 절차

1. **fileKey 추출**
   - URL에서 `/make/{fileKey}/` 부분을 추출

2. **MCP로 전체 파일 목록 조회**
   - `get_design_context` 호출 — `fileKey` · `nodeId=""` · **`clientFrameworks="react"`** · **`clientLanguages="typescript"`**
   - A10 프런트는 **React 16 + TypeScript 4.4**, 번들러 `klago-ui-micro` 가 마이크로 모듈(`klago-ui-{모듈}-micro`)을 묶어 구동한다 — `규칙/프로세스/개발환경-구성-표준.md`(forge)

3. **페이지 컴포넌트 추출**
   - 결과에서 `pages/` 경로에 있는 파일들을 목록화
   - Placeholder, NotFound 등 유틸리티 페이지는 별도 분류

4. **화면설계서와 대조**
   - 프로젝트의 화면설계서(와이어프레임) 파일을 찾아 읽기
   - 설계서에 정의된 화면 목록 vs Figma Make 페이지 목록 비교
   - 누락/추가 화면 식별

5. **공통 구조 확인**
   - Layout 컴포넌트 존재 여부
   - UI 컴포넌트 키트 (components/ui/) 존재 및 개수
   - 스타일 파일 (theme.css, tailwind.css 등) 존재 여부
   - 라우팅 설정 파일 존재 여부

5-1. **⛔ A10 이식 가능성 판정 (필수 — 이게 없으면 검증이 반쪽이다)**

   Figma Make 기본 산출은 **Tailwind + `components/ui/`(shadcn) 골격**이다. **A10은 그 계층이 아니다.**

   | 확인 | 근거 |
   |---|---|
   | A10 퍼블리싱은 SCSS + luna-orbit(OBT) 오버라이드이며 **BEM·유틸리티퍼스트(Tailwind) 아님** | `규칙/프로세스/퍼블리싱-코드스타일.md`(forge) §2 |
   | 산출 컴포넌트마다 대응 OBT 컴포넌트와 `pub*` 공통 프리셋이 있는지 대조 | 같은 표준 §3.1·§4 |
   | **prop·컴포넌트명은 추정 금지** — 실사용례를 grep해 확인 | 같은 표준 §6 (잘못된 prop은 빌드를 깨뜨린다) |
   | 플랫폼 정합 — 모바일용 컴포넌트를 웹 화면에 그대로 인스턴스화하지 않는다 | `규칙/프로세스/와이어프레임-작성-표준.md`(forge) |

   → 이식 불가 컴포넌트는 아래 「발견 이슈」에 **Major** 로 올린다. 그대로 옮기라고 제안하지 않는다.

6. **검증 결과 보고**

```markdown
## Figma Make 검증 결과

- **검증 일시**: (오늘 날짜)
- **fileKey**: {fileKey}
- **화면 수**: N/M (Figma Make / 설계서 기준)

### 화면별 상태
| 설계서 ID | 화면명 | Figma Make 파일 | 존재 | 비고 |
|-----------|--------|----------------|------|------|

### 공통 구조
- Layout: ✅/❌
- UI Kit: ✅/❌ (N개 컴포넌트)
- Theme/Style: ✅/❌
- Routes: ✅/❌

### 발견 이슈
- (있으면 기재)

### 판정
- ✅ PASS / ⚠️ CONDITIONAL PASS / ❌ FAIL
```

## 산출 위치·게이트

- 저장: `프로젝트/PRJ-NNNN_*/05_산출물/{날짜}-{주제}-Figma검증.md`(forge) — PRISM 산출 규격(`skills/dz-prism-agent/SKILL.md`)
- 이 판정은 **디자인 단계의 합격 게이트**다. FAIL·CONDITIONAL 이면 퍼블리싱(WEAVER)으로 넘기지 않는다.
- 하류 계약: WEAVER 는 **디자인 토큰 적용률 90% 이상**으로 채점한다(`skills/dz-weaver-agent/SKILL.md`) — 미매핑 항목을 발견 이슈에 남겨 넘긴다.

## 사용 예시

```
/dz-review-figma https://www.figma.com/make/ABC123/My-Project
```

URL 없이 실행하면, 프로젝트 문서에서 이전에 기록된 Figma Make URL을 찾아 사용합니다.

## 관련

- 도구 진단: `규칙/프로세스/디자인도구-MCP-운영가이드.md`(forge) §1
- 이식 판정 기준: `규칙/프로세스/퍼블리싱-코드스타일.md`(forge) §2·§3.1·§4·§6
- 대조 기준(화면 목록·라이선스 분기): `규칙/프로세스/화면설계서-작성-표준.md`(forge)
- 짝 스킬: `skills/dz-figma-make-reviewer/SKILL.md`
- ⚠️ 상위 정본 **D-09 디자인 표준은 아직 없다**(`규칙/프로세스/디자인-표준.md` 미존재 — `화면설계-표준.md` 가 계속 참조만 한다). 본 커맨드는 그 공백을 하위 표준 직접 인용으로 메운다. D-09 신설 시 이 절을 그쪽으로 인계한다. _(확인 필요 2026-08-13)_
