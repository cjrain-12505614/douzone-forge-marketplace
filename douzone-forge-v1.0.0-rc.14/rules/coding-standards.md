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

### 4. 기술 스택 규칙 (Amaranth 10)
- **Backend**: Spring Boot 3.x, JPA/QueryDSL, OpenJDK 21
- **Frontend**: React 18 + TypeScript + Tailwind CSS + Zustand
- **DB**: MariaDB + Flyway (DDL SSOT), ddl-auto=none
- **API**: RESTful, OpenAPI 3.0 명세 필수

### 5. 테스트
- 새 기능에는 반드시 테스트를 작성한다.
- 테스트 이름은 `should_동작_when_조건` 패턴을 따른다.
- Mock은 최소한으로, 가능하면 통합 테스트를 선호한다.

## 적용 범위

- Workspace_a10 하위 소스 파일에서만 활성화 (paths 프런트매터)
- 기획·설계 문서 작업에는 로드되지 않음
