---
name: figma-make-reviewer
description: >
  This skill should be used when the user says "Figma 확인해줘", "피그마 검증해줘",
  "디자인 산출물 점검해줘", "Figma Make 결과 봐줘", "화면설계서랑 비교해줘",
  "피그마 URL 확인", "디자인 코드 읽어줘", "Figma Make 검증",
  or when the user shares a Figma Make URL and wants it validated against the wireframe spec.
  Manages the Figma Make ↔ Cowork collaboration workflow including design verification,
  screen mapping, and design token extraction for the design application sprint.
version: 0.2.0
---

# Figma Make Reviewer

Figma Make 디자인 산출물을 검증하고, 화면설계서 대비 일치 여부를 확인하며,
디자인 적용 시 필요한 토큰 추출을 지원하는 범용 스킬.

## 협업 워크플로우

```
[PM] Figma Make에 프롬프트 입력 → 화면 생성
    ↓
[PM] Figma Make URL을 Cowork에 공유
    ↓
[Cowork] Figma MCP로 산출물 읽기 → 화면설계서 대비 검증
    ↓
[Cowork] 검증 결과 PM에게 보고 (PASS / 보정 필요)
    ↓
(디자인 적용 시) Figma → 디자인 토큰 추출 → 개발 지시서 작성
```

## Figma Make URL에서 fileKey 추출

Figma Make URL 형식: `https://www.figma.com/make/{fileKey}/{fileName}`
- fileKey를 추출하여 MCP 호출에 사용

## Figma MCP 도구 사용법

### 1. 전체 파일 목록 조회

`get_design_context` MCP 도구를 사용한다.
- **fileKey**: URL에서 추출한 fileKey
- **nodeId**: 빈 문자열 `""` (전체 파일)
- **clientFrameworks**: 프로젝트에 맞게 지정 (예: `react`, `vue`)
- **clientLanguages**: 프로젝트에 맞게 지정 (예: `typescript`, `javascript`)

결과로 소스코드 리소스 링크 목록이 반환된다.

### 2. 개별 파일 소스코드 읽기

반환된 리소스 링크의 `uri`를 사용하여 개별 컴포넌트 코드를 읽을 수 있다.
예: `file://figma/make/source/{fileKey}/src/app/pages/SomePage.tsx`

### 3. 스크린샷 확인

`get_screenshot` MCP 도구로 특정 노드의 스크린샷을 가져올 수 있다.
- URL에 node-id가 포함된 경우 사용 가능

### 4. 메타데이터 확인

`get_metadata` MCP 도구로 파일의 구조(페이지, 프레임, 컴포넌트 트리)를 확인할 수 있다.

## 검증 절차

### Step 1: 화면 존재 확인
`get_design_context`로 전체 파일 목록을 가져온 뒤, `pages/` 디렉토리 내 페이지 컴포넌트를 추출한다.
프로젝트의 화면설계서(와이어프레임)에 정의된 화면 목록과 대조하여 누락 여부를 확인한다.

### Step 2: 컴포넌트 구조 대조
화면설계서의 각 화면 섹션과 Figma Make 코드를 비교:
- 주요 UI 요소 존재 여부 (테이블, 버튼, 필터, 모달 등)
- 라우팅 경로 일치 여부
- 상태(Enum) 사용 일관성

### Step 3: 공통 구조 확인
- 레이아웃 컴포넌트 (사이드바, 헤더 등)
- UI 컴포넌트 키트 (components/ui/)
- 스타일 파일 (theme.css, tailwind.css 등)
- 라우팅 설정

### Step 4: 검증 결과 보고

```markdown
## Figma Make 검증 결과

- **검증 일시**: YYYY-MM-DD
- **fileKey**: {fileKey}
- **화면 수**: {확인된 수}/{설계서 기준 수}

### 화면별 상태
| 설계서 ID | 화면명 | Figma Make 파일 | 존재 | 구조 일치 | 비고 |
|-----------|--------|----------------|------|----------|------|

### 공통 구조
- Layout: ✅/❌
- UI Kit: ✅/❌ (N개 컴포넌트)
- Theme/Style: ✅/❌
- Routes: ✅/❌

### 발견 이슈
- (Critical/Major/Minor/Info)

### 판정
- ✅ PASS / ⚠️ CONDITIONAL PASS / ❌ FAIL
```

## 디자인 토큰 추출 워크플로우

디자인 적용 시 Figma Make 산출물에서 토큰을 추출하는 절차:

1. `styles/theme.css` 또는 유사 파일에서 CSS 변수 추출
2. `tailwind.config` 등 빌드 설정에서 커스텀 토큰 추출
3. 프로젝트의 기존 tailwind.config와 비교
4. 토큰 매핑 + 컴포넌트별 className 변경 목록 작성
5. 개발팀 지시서에 반영

## 주의사항

- Figma MCP는 **읽기 전용** — Figma 파일을 직접 수정할 수 없음
- Figma Make에 수정이 필요하면 PM이 직접 Figma Make에서 수정
- `get_design_context`로 코드를 읽고, `get_screenshot`으로 시각 확인 가능
- `generate_diagram`은 FigJam 전용 (Mermaid) — 디자인 파일에는 사용 불가
- 프로젝트별 화면 매핑 테이블은 프로젝트 문서에서 관리 (스킬에 하드코딩하지 않음)


## 마크다운 링크 규칙 (필수)

마크다운 파일 작성·업데이트 시 **모든 경로·파일 참조는 클릭 가능한 상대 링크**로 작성한다.

```markdown
# 나쁜 예 (클릭 불가)
법무관리/tasks/_current.md에서 확인

# 좋은 예 (클릭 가능)
[법무관리/tasks/_current.md](../법무관리/tasks/_current.md)에서 확인
```

- 상대 경로는 현재 파일 위치 기준
- 코드블록 안의 폴더 구조 다이어그램은 예외 (링크 불필요)
- 상세 규칙은 douzone-forge CLAUDE.md의 "마크다운 링크 표기 규칙" 섹션 참조
