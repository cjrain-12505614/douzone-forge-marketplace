---
name: verification
description: 검증 없이 완료 선언 금지. 모든 구현은 fresh evidence로 뒷받침해야 한다.
paths: ["**/*.java", "**/*.ts", "**/*.tsx", "**/*.gradle", "**/*.sql"]
---

# Verification Rule

## 원칙: "검증 없이 완료라고 말하지 마라"

1. **Fresh Evidence 필수**: 빌드 통과, 테스트 결과, 서버 기동 로그 등 실제 증거 없이 "완료"라고 선언하지 않는다.
2. **확률적 언어 금지**: "아마 될 겁니다", "문제없을 것 같습니다" 대신 "빌드 통과 확인했습니다", "테스트 258건 전체 통과"처럼 구체적으로 보고한다.
3. **빌드 ≠ 런타임**: `./gradlew build` 통과가 서버 정상 기동을 보장하지 않는다. Step 0 직후 반드시 런타임 검증(서버 기동 + 로그인)을 수행한다.
4. **교차 검증 대기**: v1.0 이상 산출물은 반드시 교차 검증(Cowork)을 거친 후 "완료" 처리한다.
5. **테스트 커버리지**: DoD 기준 70% 이상. Jacoco 리포트로 수치를 확인하고 보고서에 포함한다.

## 적용 범위

- Workspace_a10 하위의 Java/TypeScript/Gradle/SQL 파일 작업 시 활성화 (paths 프런트매터)
- douzone-forge 기획·설계 문서에는 적용되지 않음 (해당 영역은 `a10-deliverable-management` 스킬이 품질 게이트 담당)
