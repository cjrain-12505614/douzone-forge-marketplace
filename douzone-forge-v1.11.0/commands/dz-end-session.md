---
name: dz-end-session
description: "세션 종료 - 로그 저장 및 상태 갱신"
---

세션 종료 프로토콜을 실행한다. 아래 순서대로 수행하라.

1. 이번 세션에서 작업한 모듈의 `_개인/sessions/{모듈}/_current.md`를 업데이트한다.
   - 완료된 작업에 체크 추가
   - 남은 작업 갱신
   - 현재 시점·재개 방법 명시
   - 날짜 업데이트
2. 관련 프로젝트가 있으면 `projects/PRJ-*.md`의 `03. 상세 진행현황`에 일자별 로그를 추가한다.
3. 관련 프로젝트의 TASK 진행률, `01. C. 진행률`을 갱신한다.
4. `projects/_dashboard.md`의 진행률·상태를 갱신한다.
5. PM 피드백이나 교훈이 있으면 기록한다.
6. PM에게 "세션 저장 완료" 보고한다. 다음 세션에서 이어할 TODO 1~2건을 언급한다.
7. **GitLab 동기화 + 결과 보고** — 세션 변경을 중앙 저장소(GitLab, 사내 원격 저장소)에 반영한다.
   - 플러그인 동기화 엔진을 sync 모드로 실행:
     ```bash
     SYNC=$(find ~/.claude/plugins -name dz-gitlab-sync.sh 2>/dev/null | head -1); bash "$SYNC" sync
     ```
   - 출력을 보고 한국어로 요약 보고한다:
     - ✅ 반영 완료
     - ⚠️ 충돌 → 관리자에게 문의 (작업은 `backup/sync-시각` 브랜치에 보존됨)
     - ⚠️ 올리기 실패 → 로컬에 보존됨, 다음 동기화 때 재시도
   - 동기화 정책 SSoT: [`Forge-GitLab-운영가이드.md`](../../규칙/프로세스/Forge-GitLab-운영가이드.md) §6
