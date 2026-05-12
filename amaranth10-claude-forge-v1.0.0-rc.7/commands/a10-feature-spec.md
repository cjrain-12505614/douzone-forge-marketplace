---
name: a10-feature-spec
description: "기능 스펙 문서 생성"
---

현재 로드된 컨텍스트를 바탕으로 `$ARGUMENTS`에 해당하는 기능의 스펙 문서를 생성한다.

## 실행 전 확인

현재 대화에 아래 컨텍스트가 로드되어 있는지 확인한다.
- module-overview.md
- conventions.md
- 관련 GNB/LNB 컨텍스트

로드되지 않은 경우 사용자에게 `/load-context {모듈명/GNB명/LNB명}` 실행을 먼저 요청한다.

## 스펙 생성

feature-planning 스킬의 기능 스펙 구조를 따라 문서를 작성한다.

로드된 컨텍스트에서 아래 정보를 자동으로 반영한다.
- 모듈의 라이선스 구분 규칙 (conventions.md)
- 기존 구현 상태 (LNB 컨텍스트 파일)
- 연관 테이블 및 컴포넌트 (conventions.md)
- 기술스택 제약사항

불명확한 항목은 스펙 내 "미결 사항"에 명시하고, 사용자에게 결정을 요청한다.

## 파일 저장

작성된 스펙을 아래 경로에 저장한다.
`{모듈명}/specs/{날짜}_{기능명}.md`

날짜 형식: YYYYMMDD
파일명 기능명: 한글은 영문으로 변환 (예: 소송등록 → lawsuit-registration)

저장 후 파일 경로를 사용자에게 알린다.
