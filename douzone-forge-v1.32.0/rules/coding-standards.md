---
name: coding-standards
description: 코드 작성 핵심 원칙. Surgical Changes, Small Functions, 일관성을 지킨다.
paths: ["**/*.java", "**/*.ts", "**/*.tsx", "**/*.js", "**/*.jsx"]
---

# Coding Standards Rule

## 핵심 원칙

### 1. Surgical Changes (수술적 변경)
- 요청받은 것만 정확히 변경한다. 관련 없는 코드를 리팩터링하지 않는다.
- 변경 전후 diff를 최소화한다.
- 이유 없는 import 정리, 공백 변경, 스타일 수정은 하지 않는다.

### 2. Small Functions
- 함수 하나가 한 가지 일만 한다. 50줄을 넘기면 분리를 검토한다.
- 네이밍은 동작을 설명한다: `calculateProgress()`, `validateStatusTransition()`.
- 주석은 "왜"를 설명한다. "무엇"은 코드 자체가 설명해야 한다.

### 3. Immutability & Safety
- DTO는 불변 객체로 설계한다.
- null 반환 대신 Optional 또는 빈 컬렉션을 사용한다.
- 외부 입력은 반드시 검증한다 (Bean Validation, @NotNull, @Size 등).

### 4. 기술 스택 규칙 (Amaranth 10) — SSoT 위임 (H4)

> **주의(H4 파라미터화)**: A10 실제 스택은 모듈·레이어마다 다르고 일반 가정과 어긋난다(예: 영속성은 **MyBatis** 중심, DB 변경은 **dbPatch** 방식, FE는 **번들러 klago-ui-micro** 구조). 이 규칙에 특정 스택 값을 하드코딩하지 않는다 — 실제 값의 단일 출처(SSoT)는 아래를 따른다(중복 정의 시 불일치 재발).
> - 코딩 표준·스택 정본: `Amaranth10/_소스분석/coding-rules/INDEX.md` (forge · 브리지 자동 로드)
> - 개발환경·번들러·Node/sass 제약: `규칙/프로세스/개발환경-구성-표준.md` (forge)
> - 모듈별 아키텍처: `Amaranth10/{모듈}/context/_source-architecture.md` (forge)
>
> (위는 forge 워크스페이스 경로 — 브리지 켠 개발 세션에선 `_forge/` 바로가기로 접근)
>
> 공통 불변값(언어 레벨): OpenJDK 21 · Spring Boot 3.x · MariaDB. 그 외 영속성·FE·DB변경 방식은 위 SSoT 확인 후 적용.

### 5. 테스트
- 새 기능에는 반드시 테스트를 작성한다.
- 테스트 이름은 `should_동작_when_조건` 패턴을 따른다.
- Mock은 최소한으로, 가능하면 통합 테스트를 선호한다.

## 적용 범위

- Workspace_a10 하위 소스 파일에서만 활성화 (paths 프런트매터)
- 기획·설계 문서 작업에는 로드되지 않음
