#!/usr/bin/env bash
# douzone-forge — GitLab 동기화 엔진 (dz-gitlab-sync)
#
# 목적:
#   비개발자 사용자도 세션 시작/종료 시 GitLab(중앙 원격 저장소)과 안전하게 최신화한다.
#     - pull 모드 : 원격 변경 받기만 (세션 시작용)
#     - sync 모드 : 자동 커밋 → 원격 받기 → 올리기 (세션 종료/중간 정리용)
#   충돌(같은 파일을 둘이 수정해 자동 병합 불가)이 나면 자동 병합하지 않고 멈춘다.
#   대신 변경을 백업 브랜치에 보관하고 "관리자에게 문의" 안내를 띄운다.
#   어떤 경우에도 사용자 변경을 버리지 않는다 — 데이터 보존이 최우선.
#
# 정책 SSoT(단일 출처): 규칙/프로세스/Forge-GitLab-운영가이드.md
#
# 사용:
#   dz-gitlab-sync.sh [pull|sync]        # 인자 없으면 sync
#   DZ_SYNC_DRYRUN=1 dz-gitlab-sync.sh   # 시늉만(실제 커밋/push 안 함) — 검증용
#
# 안전 가드:
#   - git 레포가 아니면 건너뜀
#   - 원격(origin)이 douzone-forge 가 아니면 건너뜀 (오작동 방지)
#   - 분리된 HEAD(브랜치 없는 상태)면 건너뜀
#   - 항상 exit 0 — 세션 시작/종료를 막지 않는다 (문제는 메시지로만 알림)
#
set -uo pipefail

MODE="${1:-sync}"
DRYRUN="${DZ_SYNC_DRYRUN:-0}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

cd "$PROJECT_DIR" 2>/dev/null || { echo "[dz-sync] 대상 폴더 접근 불가: $PROJECT_DIR"; exit 0; }

# ---- 로그 (개인 영역 _개인/ 에만 — GitLab 동기화 미대상) ----
LOG_DIR="$PROJECT_DIR/_개인"
LOG_FILE="$LOG_DIR/sync-log.md"
say() { echo "[dz-sync] $*"; }
record() {
  [ -d "$LOG_DIR" ] || return 0
  printf -- "- %s | %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$LOG_FILE" 2>/dev/null || true
}

# ---- 안전 가드 ----
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { say "git 레포 아님 — 건너뜀"; exit 0; }
ORIGIN="$(git remote get-url origin 2>/dev/null || true)"
case "$ORIGIN" in
  *douzone-forge*) : ;;
  *) say "origin 이 douzone-forge 가 아님 — 안전상 건너뜀: ${ORIGIN:-(없음)}"; exit 0 ;;
esac
BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
[ -n "$BRANCH" ] || { say "분리된 HEAD 상태 — 건너뜀"; exit 0; }

WHO="$(git config user.name 2>/dev/null || echo '사용자')"
TS="$(date '+%Y-%m-%d %H:%M')"

# ---- 1. 로컬 변경 자동 커밋 (sync 모드) ----
commit_local() {
  if [ -z "$(git status --porcelain)" ]; then
    say "로컬 변경 없음 — 커밋 생략"
    return 0
  fi
  say "로컬 변경 감지 → 자동 커밋"
  if [ "$DRYRUN" = "1" ]; then
    echo "    (dryrun) git add -A && git commit -m 'chore(sync): $WHO $TS 세션 동기화'"
    return 0
  fi
  git add -A
  # 여기서 .githooks/pre-commit 비밀스캔이 작동한다(비밀 감지 시 커밋 자동 차단).
  if git commit -m "chore(sync): $WHO $TS 세션 동기화" >/dev/null 2>&1; then
    say "커밋 완료"
    record "commit by $WHO"
    return 0
  fi
  say "⚠️ 커밋 실패(비밀스캔 차단 가능성) — 중단. 변경은 로컬에 그대로 보존됨"
  record "commit BLOCKED (보존)"
  return 1
}

# ---- 2. 원격 받기 (rebase + autostash) → 0=성공 2=충돌 3=기타실패 ----
pull_rebase() {
  say "원격 받기: git pull --rebase --autostash origin $BRANCH"
  if [ "$DRYRUN" = "1" ]; then echo "    (dryrun) git pull --rebase --autostash"; return 0; fi
  if git pull --rebase --autostash origin "$BRANCH" >/dev/null 2>&1; then
    say "원격 받기 완료"
    return 0
  fi
  local rm ra
  rm="$(git rev-parse --git-path rebase-merge 2>/dev/null)"
  ra="$(git rev-parse --git-path rebase-apply 2>/dev/null)"
  if [ -d "$rm" ] || [ -d "$ra" ]; then return 2; fi
  return 3
}

# ---- 3. 충돌 처리: 멈춤 + 백업 브랜치 + 관리자 안내 ----
handle_conflict() {
  local bk="backup/sync-$(date +%Y%m%d-%H%M%S)"
  say "⚠️ 충돌 감지 — 자동 병합하지 않습니다 (안전 정책)"
  git rebase --abort >/dev/null 2>&1 || true
  git branch "$bk" >/dev/null 2>&1 || true
  say "변경을 백업 브랜치에 보관: $bk"
  say "👉 관리자에게 문의하세요. 작업 내용은 보존되어 있습니다 (브랜치: $bk)."
  record "CONFLICT → backup $bk → 관리자 문의 필요"
}

# ---- 4. 올리기 ----
push_remote() {
  say "올리기: git push origin $BRANCH"
  if [ "$DRYRUN" = "1" ]; then echo "    (dryrun) git push"; return 0; fi
  if git push origin "$BRANCH" >/dev/null 2>&1; then
    say "✅ GitLab 반영 완료"
    record "push OK"
    return 0
  fi
  say "⚠️ 올리기 실패(네트워크·인증) — 로컬 커밋은 보존됨. 다음 동기화 때 재시도됩니다"
  record "push FAIL (보존)"
  return 4
}

# ================= 메인 =================
[ "$DRYRUN" = "1" ] && DRYTAG=" [DRYRUN]" || DRYTAG=""
say "모드=$MODE 대상=$PROJECT_DIR 사용자=$WHO$DRYTAG"

case "$MODE" in
  pull)
    rc=0; pull_rebase || rc=$?
    case "$rc" in
      0) : ;;
      2) handle_conflict ;;
      *) say "⚠️ 원격 받기 실패(네트워크 등) — 현재 상태 유지"; record "pull FAIL" ;;
    esac
    ;;
  sync|push|*)
    if commit_local; then
      rc=0; pull_rebase || rc=$?
      case "$rc" in
        0) push_remote || true ;;
        2) handle_conflict ;;
        *) say "⚠️ 원격 받기 실패(네트워크 등) — 로컬 커밋 보존, 올리기 보류"; record "pull FAIL (보존)" ;;
      esac
    fi
    ;;
esac
exit 0
