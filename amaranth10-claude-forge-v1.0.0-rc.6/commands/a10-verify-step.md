---
name: a10-verify-step
description: "Step 완료 전 빌드/테스트/린트 자동 실행 + 결과 보고서 포함"
---

# /verify-step — Step 완료 검증

Step 구현 완료 후, 다음 검증을 자동 수행한다.

## 실행 순서

1. **Backend 빌드**
   ```bash
   cd backend && ./gradlew clean build
   ```
   - PASS: 다음 단계로
   - FAIL: 오류 메시지 출력, 수정 후 재실행 유도

2. **Frontend 빌드**
   ```bash
   cd frontend && npm run build
   ```

3. **테스트 결과 집계**
   - 전체 테스트 수, 통과/실패/스킵
   - 신규 테스트 수 (이번 Step에서 추가된)
   - Jacoco 커버리지 % (가능 시)

4. **Enum 일관성 체크**
   - rules/enum-consistency.md 기준으로 DDL↔Entity↔DTO↔FE Type 일치 확인

5. **보고서 자동 생성**
   - `docs/구현보고서/sprint{N}_step{M}_report.md` 템플릿에 결과 채움
   - Cowork 교차 검증 요청 체크리스트 포함

## 결과 형식

```
✅ verify-step 완료
- Backend: PASS (258건 테스트, 0 실패)
- Frontend: PASS (2.17s)
- 커버리지: 73%
- Enum 일관성: OK
- 보고서: docs/구현보고서/sprint3_step6_report.md
```
