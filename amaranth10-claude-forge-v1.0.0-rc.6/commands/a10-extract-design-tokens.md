---
name: a10-extract-design-tokens
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
   ```

4. **현재 프로젝트 설정과 비교**
   - 프로젝트의 tailwind.config 파일 읽기
   - 추가/변경 필요한 토큰 식별
   - 충돌하는 값 표시

5. **디자인 적용 지시서 초안 작성**
   - 토큰 매핑 테이블
   - 컴포넌트별 className 변경 목록
   - 적용 우선순위 제안

## 사용 예시

```
/extract-design-tokens https://www.figma.com/make/ABC123/My-Project
```

## 주의사항

- Figma MCP는 읽기 전용 — 토큰 추출만 가능하고 Figma 수정은 PM이 직접 수행
- 추출된 토큰은 개발 환경의 빌드 설정에 맞게 변환 필요
