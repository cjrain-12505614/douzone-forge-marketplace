---
name: enum-consistency
description: Enum은 DDL, Entity, DTO, FE Type, OpenAPI 전 레이어에서 동일해야 한다.
paths: ["**/*.java", "**/*.ts", "**/*.tsx", "**/migration/**/*.sql", "**/openapi*.yaml", "**/openapi*.yml"]
---

# Enum Consistency Rule

## 원칙: Enum은 전 레이어 동일

D-28 교훈 기반. Enum 값이 레이어마다 다르면 교차 검증에서 Critical 발생.

## 확정 Enum 목록은 프로젝트별 — SSoT 위임 (H4)

> **주의(H4 파라미터화)**: 아래 표는 **forge 자체 PM 도구 프로젝트 전용 예시**다. A10 모듈 레포(amaranth10-{모듈}·klago-ui-{모듈}-micro)에는 이 Enum이 없거나 다르므로 **이 목록으로 A10 코드를 판정하지 않는다.** A10 모듈의 확정 Enum은 해당 모듈 context(`Amaranth10/{모듈}/context/`)와 코딩규칙 단일 출처 `Amaranth10/_소스분석/coding-rules/INDEX.md`(forge — 브리지 세션에선 `_forge/` 경유)를 출처로 삼는다. 이 규칙이 강제하는 것은 **"확정 Enum이 무엇이든 5레이어에서 동일해야 한다"는 원칙**이지, 특정 값 목록이 아니다.

### forge PM 프로젝트 전용 예시 (A10 아님)

| Enum | 값 | 비고 |
|------|-----|------|
| TaskStatus | OPEN, IN_PROGRESS, IN_REVIEW, COMPLETED, ON_HOLD, CANCELLED | 6상태 12전환 |
| TaskPriority | CRITICAL, HIGH, MEDIUM, LOW | ~~URGENT~~ 사용 금지 |
| MemberRole | OWNER, EDITOR, COMMENTER, VIEWER, GUEST | D-16 GUEST 권한 |
| ProjectStatus | PLANNING, ACTIVE, ON_HOLD, COMPLETED, ARCHIVED | |
| MilestoneStatus | PLANNED, ACTIVE, COMPLETED, MISSED | D-28 확정 |

## 체크 대상 레이어

1. **DDL** (Flyway SQL): `ENUM('OPEN','IN_PROGRESS',...)`
2. **Entity** (Java): `public enum TaskStatus { OPEN, IN_PROGRESS, ... }`
3. **DTO** (Java): Request/Response에서 동일 enum 사용
4. **FE Type** (TypeScript): `type TaskStatus = 'OPEN' | 'IN_PROGRESS' | ...`
5. **OpenAPI 명세** (YAML): `enum: [OPEN, IN_PROGRESS, ...]`

## 금지 사항

- 레이어마다 다른 이름 사용 금지 (예: BE에 CRITICAL, FE에 URGENT)
- Enum 변경 시 반드시 5개 레이어 동시 반영
- 새 Enum 추가 시 프로젝트 CLAUDE.md Enum 섹션에도 반영

## 적용 범위

- Java/TS 소스 + Flyway migration SQL + OpenAPI YAML에서만 활성화 (paths 프런트매터)
