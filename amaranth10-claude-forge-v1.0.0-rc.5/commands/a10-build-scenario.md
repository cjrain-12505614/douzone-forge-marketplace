---
name: a10-build-scenario
description: "QA 검수시나리오 시트 생성"
---

# /build-scenario

검수시나리오 시트를 생성한다.

1. 대상 화면설계서(PDF 또는 context 파일) 확인
2. sheets-config.json에서 템플릿 시트 정보 로드
3. `a10-qa-scenario-builder` 스킬 호출하여 시나리오 생성

**사용 예시:**
- `/a10-build-scenario 상담관리`
- `/a10-build-scenario CRM 고객관리`
