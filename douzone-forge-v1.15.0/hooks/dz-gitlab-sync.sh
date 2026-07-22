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
#   DZ_SYNC_CONNECT_TIMEOUT=5            # 원격 도달성 선점검 타임아웃(초). 무응답이면 오프라인 처리(기본 5).
#   DZ_SYNC_GIT_TIMEOUT=15              # git 전송 저속 지속 한도(초, 연결 후 정체 대비, 기본 15).
#   DZ_SYNC_AUTORESOLVE=1               # 미해결(unmerged) 충돌 자동 복구 (1=켬 기본, 0=끔 — 끄면 안내만).
#
# 안전 가드:
#   - git 레포가 아니면 건너뜀
#   - 원격(origin)이 douzone-forge 가 아니면 건너뜀 (오작동 방지)
#   - 분리된 HEAD(브랜치 없는 상태)면 건너뜀
#   - 원격 도달 불가(망 밖)면 git 네트워크 명령을 부르지 않고 즉시 보존 (세션 시작 지연 방지)
#   - 항상 exit 0 — 세션 시작/종료를 막지 않는다 (문제는 메시지로만 알림)
#
set -uo pipefail

MODE="${1:-sync}"
DRYRUN="${DZ_SYNC_DRYRUN:-0}"
AUTORESOLVE="${DZ_SYNC_AUTORESOLVE:-1}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CONNECT_TIMEOUT="${DZ_SYNC_CONNECT_TIMEOUT:-5}"
GIT_LOWSPEED_TIME="${DZ_SYNC_GIT_TIMEOUT:-15}"

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

# git 네트워크 명령 공통 옵션 (연결 후 전송이 저속으로 정체하면 중단)
GIT_NET=(-c http.lowSpeedLimit=1000 -c "http.lowSpeedTime=${GIT_LOWSPEED_TIME}")

# ---- 원격 도달성 선점검 — 망 밖에서 세션 시작이 길게 멈추는 것 방지 → 0=도달 1=불가 ----
# origin 프로토콜(http/https)을 그대로 따라 점검한다 (http origin을 https로 시도하면 SSL 핸드셰이크 실패로 오판).
remote_reachable() {
  command -v curl >/dev/null 2>&1 || return 0   # curl 없으면 점검 생략(git에 위임)
  local scheme host
  case "$ORIGIN" in
    https://*) scheme=https ;;
    http://*)  scheme=http  ;;
    *)         return 0 ;;   # SSH 등 비-HTTP origin은 점검 생략(git에 위임)
  esac
  host=$(printf '%s' "$ORIGIN" | sed -E 's#^https?://([^/]+)/.*#\1#')
  host="${host##*@}"   # user:pass@ 자격정보 제거
  curl -ksS -o /dev/null --connect-timeout "$CONNECT_TIMEOUT" --max-time "$((CONNECT_TIMEOUT + 5))" "${scheme}://$host" >/dev/null 2>&1
}

# ---- 0.5 미해결(unmerged) 충돌 자동 복구 (rc.24 / v1.12.4) ----
# autostash(자동 임시보관) 복원 충돌 등으로 미해결 파일이 남으면 git 이 pull 자체를 거부해
# 자동 동기화가 전면 중단된다 (2026-07-09 실사고 — 포지교육 회의록 파일명 변경+수정 중 pull).
# 복구 정책 (데이터 무유실):
#   1) 충돌 파일의 세 판(마커 포함 현재본·원격 판·로컬 판)을 전부 _개인/sync-conflict-백업/ 에 보관
#   2) "로컬 작업 판" 채택으로 자가 해소 — 원격 판은 git 이력에 그대로 있어 언제든 복원 가능,
#      로컬 판은 커밋 전이라 여기서 버리면 영구 유실되므로 로컬 우선이 안전하다
#   3) 사용자에게 백업 위치·검토 필요를 안내하고 sync-log 에 기록
# 끄기: DZ_SYNC_AUTORESOLVE=0 (안내만 하고 멈춤 — 기존 동작)
auto_recover_unmerged() {
  local files
  # core.quotePath=false 필수 — 기본값이면 한글 경로가 8진수 이스케이프+따옴표로 나와 파일명이 빗나간다
  files="$(git -c core.quotePath=false diff --name-only --diff-filter=U 2>/dev/null)"
  [ -n "$files" ] || return 0
  if [ "$AUTORESOLVE" != "1" ]; then
    say "⚠️ 미해결(unmerged) 충돌 파일이 있어 동기화가 막혀 있습니다 (자동 복구 꺼짐 DZ_SYNC_AUTORESOLVE=0):"
    printf '%s\n' "$files" | while IFS= read -r f; do [ -n "$f" ] && echo "    - $f"; done
    say "👉 파일 내 충돌 마커를 해소하고 git add 후 다시 동기화하거나, 관리자에게 문의하세요."
    record "UNMERGED present (autoresolve off) → manual fix needed"
    return 1
  fi
  if [ "$DRYRUN" = "1" ]; then
    echo "    (dryrun) 자동 복구 대상: $(printf '%s' "$files" | tr '\n' ' ')"
    return 0
  fi
  local ts bk side n=0 f safe
  ts="$(date +%Y%m%d-%H%M%S)"
  bk="$PROJECT_DIR/_개인/sync-conflict-백업/$ts"
  mkdir -p "$bk" 2>/dev/null || bk="${TMPDIR:-/tmp}/dz-sync-conflict-$ts" && mkdir -p "$bk" 2>/dev/null
  # 판 선택: 병합(merge) 중이면 ours=로컬 브랜치 작업 / 그 외(autostash 복원 등)는 theirs=임시보관된 로컬 작업
  if [ -f "$(git rev-parse --git-path MERGE_HEAD 2>/dev/null)" ]; then side="--ours"; else side="--theirs"; fi
  say "⚠️ 미해결 충돌 감지 → 자동 복구 시작 (로컬 작업 판 채택, 양측 백업: $bk)"
  printf '%s\n' "$files" > "$bk/충돌파일목록.txt" 2>/dev/null || true
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    safe="$(printf '%s' "$f" | tr '/' '_')"
    [ -f "$f" ] && cp "$f" "$bk/${safe}.충돌마커본" 2>/dev/null
    git show ":2:$f" > "$bk/${safe}.ours본" 2>/dev/null || true
    git show ":3:$f" > "$bk/${safe}.theirs본" 2>/dev/null || true
    if git checkout "$side" -- "$f" 2>/dev/null; then
      git add -- "$f" 2>/dev/null
    else
      # 채택할 판에 파일이 없음(한쪽 삭제 충돌) → 삭제로 해소 (내용은 백업에 보존됨)
      git rm -q -- "$f" 2>/dev/null || git rm -q --cached -- "$f" 2>/dev/null || true
      say "  · $f — 채택 판에 없는 파일(삭제 충돌) → 삭제로 해소 (백업 보존)"
    fi
    n=$((n+1))
  done <<EOF_FILES
$files
EOF_FILES
  # 복구 성공 자가 검증 — 미해결이 남았으면 성공으로 보고하지 않는다 (정직한 실패)
  if [ -n "$(git ls-files -u 2>/dev/null)" ]; then
    say "⚠️ 자동 복구 미완 — 일부 충돌이 남아 수동 해소가 필요합니다 (백업: $bk)"
    record "AUTO-RECOVER incomplete (${n} tried) → manual fix needed, backup $bk"
    return 1
  fi
  say "✅ 자동 복구 ${n}건 완료 — 원격 판이 필요하면 백업($bk) 또는 git 이력에서 확인하세요"
  record "AUTO-RECOVER ${n} files ($side 채택) → backup $bk"
  return 0
}

# ---- 1. 로컬 변경 자동 커밋 (sync 모드) ----
# 흐름: git add -A → .githooks/pre-commit 사전 점검 → 차단 파일은 격리(unstage)하고 사용자 보고 → 나머지로 커밋
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

  # 비밀스캔 사전 점검 — 차단 파일을 staged 에서 격리하고 나머지만 진행 (rc.21)
  local hook="$PROJECT_DIR/.githooks/pre-commit"
  if [ -x "$hook" ]; then
    local scan_output blocked_files blocked_count=0
    scan_output=$(bash "$hook" 2>&1 || true)
    blocked_files=$(printf '%s\n' "$scan_output" | sed -nE 's/^[[:space:]]*✗ 차단\([^)]+\): (.*)$/\1/p' | sort -u)
    if [ -n "$blocked_files" ]; then
      blocked_count=$(printf '%s\n' "$blocked_files" | sed '/^$/d' | wc -l | tr -d ' ')
      say "⚠️ 비밀스캔이 ${blocked_count}개 파일을 차단했습니다 — 격리 후 나머지만 진행합니다:"
      printf '%s\n' "$blocked_files" | while IFS= read -r f; do
        [ -n "$f" ] && echo "    - $f"
      done
      say "처리 방안:"
      say "  • 오탐이면 → 해당 파일을 .gitignore 에 추가 또는 *.example 로 분리"
      say "  • 진탐이면 → 비밀을 ~/.claude/ 등 트리 밖으로 옮기고 경로로 참조"
      say "  • 정책 SSoT(단일 출처): 규칙/프로세스/비밀정보-관리-표준.md"
      # 격리: staged 에서만 제거 (working tree 파일은 그대로 보존)
      printf '%s\n' "$blocked_files" | while IFS= read -r f; do
        [ -n "$f" ] && git restore --staged -- "$f" 2>/dev/null
      done
      record "BLOCKED ${blocked_count} files isolated → manual review needed"
      printf '%s\n' "$blocked_files" | while IFS= read -r f; do
        [ -n "$f" ] && record "  blocked: $f"
      done
      # 남은 staged 가 0이면 중단 (모두 차단된 경우)
      if [ -z "$(git diff --cached --name-only)" ]; then
        say "⚠️ 모든 변경이 비밀스캔에 차단됨 — 커밋할 게 남지 않아 중단 (작업은 로컬 보존)"
        return 1
      fi
      say "${blocked_count} 파일 격리 완료, 나머지로 커밋 진행"
    fi
  fi

  # 커밋 (pre-commit 이 다시 작동하지만, 차단 대상은 이미 격리됨)
  if git commit -m "chore(sync): $WHO $TS 세션 동기화" >/dev/null 2>&1; then
    say "커밋 완료"
    record "commit by $WHO"
    return 0
  fi
  say "⚠️ 커밋 실패 — 변경은 로컬에 그대로 보존됨"
  record "commit FAIL (보존)"
  return 1
}

# ---- 2. 원격 받기 (rebase + autostash) → 0=성공 2=충돌 3=기타실패 ----
pull_rebase() {
  say "원격 받기: git pull --rebase --autostash origin $BRANCH"
  if [ "$DRYRUN" = "1" ]; then echo "    (dryrun) git pull --rebase --autostash"; return 0; fi
  if git "${GIT_NET[@]}" pull --rebase --autostash origin "$BRANCH" >/dev/null 2>&1; then
    # git 은 autostash 복원 충돌이 나도 pull 을 성공(0)으로 끝낼 수 있다 → 잔존 미해결 즉시 복구 (rc.24)
    if [ -n "$(git ls-files -u 2>/dev/null)" ]; then
      say "받기는 끝났으나 autostash 복원 충돌 잔존 → 자동 복구 시도"
      auto_recover_unmerged || return 3
    fi
    say "원격 받기 완료"
    return 0
  fi
  local rm ra
  rm="$(git rev-parse --git-path rebase-merge 2>/dev/null)"
  ra="$(git rev-parse --git-path rebase-apply 2>/dev/null)"
  if [ -d "$rm" ] || [ -d "$ra" ]; then return 2; fi
  # autostash 복원(stash pop) 충돌로 미해결 파일이 남은 경우 → 자동 복구 후 1회 재시도 (rc.24)
  if [ -n "$(git ls-files -u 2>/dev/null)" ]; then
    if auto_recover_unmerged; then
      if git "${GIT_NET[@]}" pull --rebase --autostash origin "$BRANCH" >/dev/null 2>&1; then
        say "원격 받기 완료 (자동 복구 후 재시도 성공)"
        return 0
      fi
      rm="$(git rev-parse --git-path rebase-merge 2>/dev/null)"
      ra="$(git rev-parse --git-path rebase-apply 2>/dev/null)"
      if [ -d "$rm" ] || [ -d "$ra" ]; then return 2; fi
    fi
  fi
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
  if git "${GIT_NET[@]}" push origin "$BRANCH" >/dev/null 2>&1; then
    say "✅ GitLab 반영 완료"
    record "push OK"
    return 0
  fi
  say "⚠️ 올리기 실패(네트워크·인증) — 로컬 커밋은 보존됨. 다음 동기화 때 재시도됩니다"
  record "push FAIL (보존)"
  return 4
}

# ---- 오프라인(원격 도달 불가) 빠른 보존 ----
offline_pull() {
  say "오프라인(원격 ${CONNECT_TIMEOUT}s 내 무응답) — 받기 건너뜀, 현재 상태 유지"
  record "offline (pull skip)"
}
offline_sync() {
  say "오프라인(원격 ${CONNECT_TIMEOUT}s 내 무응답) — 로컬 커밋 보존, 올리기 보류 (망 연결 후 자동 재시도)"
  record "offline (commit kept, push deferred)"
}

# ================= 메인 =================
[ "$DRYRUN" = "1" ] && DRYTAG=" [DRYRUN]" || DRYTAG=""
say "모드=$MODE 대상=$PROJECT_DIR 사용자=$WHO$DRYTAG"

# 원격 도달성 선점검 (dryrun은 실제 네트워크를 쓰지 않으므로 점검 생략)
NET_OK=1
if [ "$DRYRUN" != "1" ]; then
  if remote_reachable; then NET_OK=1; else NET_OK=0; fi
fi

# 이전 세션에서 남은 미해결(unmerged) 충돌이 있으면 무엇보다 먼저 자동 복구 (rc.24 —
# 방치 시 모든 pull 이 "unmerged files" 로 거부되어 자동 동기화가 조용히 전면 중단된다)
[ -n "$(git ls-files -u 2>/dev/null)" ] && auto_recover_unmerged || true

case "$MODE" in
  pull)
    if [ "$NET_OK" = "0" ]; then
      offline_pull
    else
      rc=0; pull_rebase || rc=$?
      case "$rc" in
        0) : ;;
        2) handle_conflict ;;
        *) say "⚠️ 원격 받기 실패(네트워크 등) — 현재 상태 유지"; record "pull FAIL" ;;
      esac
    fi
    ;;
  sync|push|*)
    if commit_local; then
      if [ "$NET_OK" = "0" ]; then
        offline_sync
      else
        rc=0; pull_rebase || rc=$?
        case "$rc" in
          0) push_remote || true ;;
          2) handle_conflict ;;
          *) say "⚠️ 원격 받기 실패(네트워크 등) — 로컬 커밋 보존, 올리기 보류"; record "pull FAIL (보존)" ;;
        esac
      fi
    fi
    ;;
esac
exit 0
