---
name: a10-load-from-sheet
description: "구글시트에서 데이터 로드"
---

# /load-from-sheet

Google Sheets에서 데이터를 로드한다.

1. sheets-config.json에서 시트 설정 확인
2. `a10-sheets-manager` 스킬로 데이터 읽기
3. 로컬 tasks 파일과 비교·요약

**사용 예시:**
- `/a10-load-from-sheet WBS`
- `/a10-load-from-sheet 법무관리 이슈`
