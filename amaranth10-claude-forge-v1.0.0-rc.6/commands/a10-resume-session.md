---
name: a10-resume-session
description: "이전 세션 또는 체크포인트에서 이어서 시작"
---

# /resume-session

이전 세션에서 이어서 시작한다.

1. `_개인/sessions/{모듈}/_current.md` 존재 확인
2. 파일 읽고 진행 상황 요약
3. 남은 작업 목록 제시 후 재개

**사용 예시:**
- `/a10-resume-session`
- `/a10-resume-session 법무관리`
