---
name: a10-save-session
description: "세션 중간 체크포인트 저장"
---

# /save-session

현재 세션 진행 상황을 체크포인트로 저장한다.

1. `_개인/sessions/{모듈}/_current.md` 업데이트
2. 완료된 작업 체크, 남은 작업 갱신
3. 현재 시점·재개 방법 명시

**사용 예시:**
- `/a10-save-session`
