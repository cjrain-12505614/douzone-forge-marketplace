---
name: a10-review-figma
description: "Figma Make 산출물 검증 실행"
---

# /review-figma 커맨드

Figma Make 산출물을 화면설계서 대비 검증합니다.

## 입력

사용자가 Figma Make URL을 제공하거나, 이전에 공유된 URL이 있으면 그것을 사용합니다.
URL 형식: `https://www.figma.com/make/{fileKey}/{fileName}`

## 실행 절차

1. **fileKey 추출**
   - URL에서 `/make/{fileKey}/` 부분을 추출

2. **MCP로 전체 파일 목록 조회**
   - `get_design_context` 호출 (fileKey, nodeId="", clientFrameworks=프로젝트에 맞게, clientLanguages=프로젝트에 맞게)

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

## 사용 예시

```
/review-figma https://www.figma.com/make/ABC123/My-Project
```

URL 없이 실행하면, 프로젝트 문서에서 이전에 기록된 Figma Make URL을 찾아 사용합니다.
