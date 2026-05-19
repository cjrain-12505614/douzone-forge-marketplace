---
name: a10-curate-docs
description: "문서 폴더 정리 (파일명 정규화, 버전 분류)"
---

# /curate-docs

문서 폴더를 정리한다.

1. 대상 모듈의 `문서/` 폴더 스캔
2. `a10-document-curator` 스킬 호출
3. 파일명 정규화, 버전 그룹핑, 삭제 후보 분류

**사용 예시:**
- `/a10-curate-docs 법무관리`
- `/a10-curate-docs CRM`
