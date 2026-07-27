---
name: dz-save-session
description: "세션 중간 체크포인트 저장"
---

# /save-session

현재 세션 진행 상황을 체크포인트로 저장한다.

1. `_개인/sessions/{모듈}/_current.md` 업데이트
2. 완료된 작업 체크, 남은 작업 갱신
3. 현재 시점·재개 방법 명시
4. **GitLab 동기화** — 중간 정리분을 중앙 저장소(GitLab, 사내 원격 저장소)에 반영하고 결과를 보고한다:
   ```bash
   SYNC=$(find ~/.claude/plugins -name dz-gitlab-sync.sh 2>/dev/null | head -1); bash "$SYNC" sync
   ```
   충돌 시 자동 병합하지 않고 `backup/sync-시각` 브랜치에 보관 + 관리자 문의 안내 (데이터 보존). 정책 SSoT: [`Forge-GitLab-운영가이드.md`](../../규칙/프로세스/Forge-GitLab-운영가이드.md) §6

**사용 예시:**
- `/dz-save-session`
