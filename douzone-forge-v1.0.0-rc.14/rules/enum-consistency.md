---
name: enum-consistency
description: Enum은 DDL, Entity, DTO, FE Type, OpenAPI 전 레이어에서 동일해야 한다.
paths: ["**/*.java", "**/*.ts", "**/*.tsx", "**/migration/**/*.sql", "**/openapi*.yaml", "**/openapi*.yml"]
---

# Enum Consistency Rule

## 원칙: Enum은 전 레이어 동일

D-28 교훈 기반. Enum 값이 레이어마다 다르면 교차 검증에서 Critical 발생.

## 확정 Enum 목록

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
