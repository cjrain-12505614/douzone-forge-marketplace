---
name: dz-verify-step
description: "Step 완료 전 빌드/테스트/린트 자동 실행 + 결과 보고서 포함"
---

# /verify-step — Step 완료 검증

Step 구현 완료 후, 다음 검증을 자동 수행한다.

> **레포 구조 자동 감지 (H4 파라미터화)**: 경로는 레포 종류에 따라 다르다. 고정 `cd backend/frontend` 가정을 쓰지 말고 아래로 판별한다.
> - **A10 백엔드**(`amaranth10-{모듈}`): 레포 **루트에 `build.gradle`** → 루트에서 `./gradlew clean build` (별도 `backend/` 폴더 없음)
> - **A10 프런트**(`klago-ui-{모듈}-micro` + 번들러 `klago-ui-micro`): 번들러 작업공간에서 `npm run build` — 상세는 `규칙/프로세스/개발환경-구성-표준.md`(forge)·`dz-module-devenv` 스킬
> - **forge 자체 PM 프로젝트**: 기존대로 `backend/`·`frontend/` 폴더 분리 구조일 수 있음 → 실제 폴더 존재로 판별

## 실행 순서

1. **백엔드 빌드** (build.gradle 있는 디렉토리에서)
   ```bash
   ./gradlew clean build      # A10: amaranth10-{모듈} 루트 / forge PM: cd backend 후
   ```
   - PASS: 다음 단계로
   - FAIL: 오류 메시지 출력, 수정 후 재실행 유도

2. **프런트엔드 빌드** (package.json 있는 디렉토리 / A10은 번들러 경유)
   ```bash
   npm run build
   ```

3. **테스트 결과 집계**
   - 전체 테스트 수, 통과/실패/스킵
   - 신규 테스트 수 (이번 Step에서 추가된)
   - 커버리지 %는 **해당 레포에 커버리지 도구가 설정된 경우만**(A10 모듈 레포는 Jacoco 미설정이 일반 — 없으면 생략)

4. **Enum 일관성 체크**
   - rules/enum-consistency.md 원칙(확정 Enum 5레이어 동일)으로 확인 — **확정 Enum 목록은 해당 프로젝트 SSoT**(A10은 모듈 context·coding-rules INDEX) 기준

5. **결과 보고**
   - A10 모듈 작업: forge `프로젝트/PRJ-NNNN_*/03_개발/{날짜}-{주제}.md` 또는 콘솔 요약 (레포 안에 `docs/구현보고서/`를 가정하지 않는다)
   - forge PM 프로젝트: 기존 `docs/구현보고서/...` 구조가 있으면 그대로
   - 교차 검증 요청 체크리스트 포함

## 결과 형식

```
✅ verify-step 완료
- 백엔드: PASS (258건 테스트, 0 실패)
- 프런트엔드: PASS (2.17s)
- 커버리지: 73% (도구 설정 시 / A10 모듈은 보통 생략)
- Enum 일관성: OK (프로젝트 SSoT 기준)
- 보고: 프로젝트/PRJ-NNNN_*/03_개발/{날짜}-{주제}.md (A10) 또는 콘솔 요약
```
