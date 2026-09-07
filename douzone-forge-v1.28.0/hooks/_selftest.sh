#!/bin/bash
# hooks/_selftest.sh — 훅 발동 회귀 시험 (v1.19.0 신설)
#
# 목적: "배선돼 있으나 영구 무발동" 사고(5회 반복 — v1.9.1 CoWork 미발동 · v1.11.2 stdin 무발동 ·
#       고아 훅 6종 · v1.13.0 환기훅 소실 · v1.19.0 link-integrity/하네스 3종 죽은 env)의 재발 방지.
#       실제 Claude Code 훅 프로토콜(stdin JSON)을 그대로 파이프해 "발동하는가"를 단언한다.
# 사용: bash hooks/_selftest.sh   → 전건 PASS 시 exit 0, 실패 있으면 exit 1
# 위치: 플러그인 개발원본 hooks/. 배포 전(build.sh --deploy) 수동 실행 권장.

set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/dz-hook-selftest.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0

# ⛔ 실 발신 격리 (v1.28.0) — 시험은 어떤 경우에도 바깥으로 나가지 않는다.
#    dz-gitlab-sync 의 연속 실패 환기는 DZ_SYNC_ALERT_CMD 가 없으면 ~/.claude/dz-sync-alert.sh
#    를 자동으로 찾는다. 그 파일이 있는 기기에서 시험을 돌리면 **실제 Slack 으로 나간다.**
#    (같은 유형의 실사고: 모니터링 훅 검증에서 스텁을 두지 않아 509건이 실 서버로 갔다)
#    그래서 시험 전체를 무해한 스텁으로 고정한다. 개별 시험이 덮어써도 실 경로로는 못 간다.
#    격리가 실제로 듣는지 눈으로 보려면 로그를 TMP 밖으로 빼서 돌린다 (trap 이 TMP 를 지운다):
#      DZ_SELFTEST_ALERT_LOG=/tmp/stub.log bash hooks/_selftest.sh && cat /tmp/stub.log
ALERT_STUB="$TMP/alert-stub.sh"
ALERT_STUB_LOG="${DZ_SELFTEST_ALERT_LOG:-$TMP/alert-stub.log}"
export ALERT_STUB_LOG
{
  printf '#!/usr/bin/env bash\n'
  printf 'printf "%%s\\n" "$1" >> "${ALERT_STUB_LOG:-/dev/null}"\n'
} > "$ALERT_STUB"
chmod +x "$ALERT_STUB"
export DZ_SYNC_ALERT_CMD="$ALERT_STUB"

json() { printf '{"tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2"; }

check() { # $1=이름 $2=기대 문자열 $3=실제 출력
  if printf '%s' "$3" | grep -q "$2"; then
    echo "  PASS  $1"; PASS=$((PASS+1))
  else
    echo "  FAIL  $1 — 기대 「$2」 미검출"; FAIL=$((FAIL+1))
  fi
}

echo "[1/7] link-integrity-check — 깨진 링크 md 에서 경고가 나오는가"
BROKEN_MD="$TMP/broken.md"
printf '[존재하지 않는 파일](./no-such-file-xyz.md)\n' > "$BROKEN_MD"
OUT="$(json Write "$BROKEN_MD" | bash "$HERE/link-integrity-check.sh" 2>&1 || true)"
check "link-integrity-check(발동)" "깨진 링크" "$OUT"
OUT2="$(json Write "$TMP/ok.txt" | bash "$HERE/link-integrity-check.sh" 2>&1 || true)"
[ -z "$OUT2" ] && { echo "  PASS  link-integrity-check(비대상 무음)"; PASS=$((PASS+1)); } || { echo "  FAIL  link-integrity-check(비대상인데 출력)"; FAIL=$((FAIL+1)); }

echo "[2/7] code-quality-reminder — 게이트 켜짐 + 확장자별 체크리스트가 나오는가"
OUT="$(json Edit "$TMP/Sample.java" | FORGE_DEV_HOOKS=1 bash "$HERE/code-quality-reminder.sh" 2>&1 || true)"
check "code-quality-reminder(.java 발동)" "코드 품질" "$OUT"
# v1.20.0 퍼블리싱 계열 확대 — 코드 계열(.js)과 마크업·스타일 계열(.scss)이 각각 맞는 체크리스트를 내는가
OUT="$(json Edit "$TMP/app.js" | FORGE_DEV_HOOKS=1 bash "$HERE/code-quality-reminder.sh" 2>&1 || true)"
check "code-quality-reminder(.js 발동)" "코드 품질" "$OUT"
OUT="$(json Edit "$TMP/style.scss" | FORGE_DEV_HOOKS=1 bash "$HERE/code-quality-reminder.sh" 2>&1 || true)"
check "code-quality-reminder(.scss 퍼블리싱 체크리스트)" "퍼블리싱 품질" "$OUT"
OUT="$(json Edit "$TMP/page.html" | FORGE_DEV_HOOKS=1 bash "$HERE/code-quality-reminder.sh" 2>&1 || true)"
check "code-quality-reminder(.html 퍼블리싱 체크리스트)" "퍼블리싱 품질" "$OUT"
# 비대상 확장자는 조용해야 한다(소음 방지)
OUT2="$(json Edit "$TMP/note.md" | FORGE_DEV_HOOKS=1 bash "$HERE/code-quality-reminder.sh" 2>&1 || true)"
[ -z "$OUT2" ] && { echo "  PASS  code-quality-reminder(비대상 .md 무음)"; PASS=$((PASS+1)); } || { echo "  FAIL  code-quality-reminder(비대상인데 출력)"; FAIL=$((FAIL+1)); }
OUT2="$(json Edit "$TMP/Sample.java" | FORGE_DEV_HOOKS=0 bash "$HERE/code-quality-reminder.sh" 2>&1 || true)"
[ -z "$OUT2" ] && { echo "  PASS  code-quality-reminder(게이트 꺼짐 무음)"; PASS=$((PASS+1)); } || { echo "  FAIL  code-quality-reminder(게이트 꺼짐인데 출력)"; FAIL=$((FAIL+1)); }

echo "[3/7] security-auto-trigger — 보안 파일명에서 경고가 나오는가"
OUT="$(json Edit "$TMP/AuthService.java" | FORGE_DEV_HOOKS=1 bash "$HERE/security-auto-trigger.sh" 2>&1 || true)"
check "security-auto-trigger(발동)" "보안 민감" "$OUT"

echo "[4/7] build-verify-reminder — 5회째 편집에서 리마인더가 나오는가"
COUNTER="/tmp/.forge-edit-counter"
SAVED=""; [ -f "$COUNTER" ] && SAVED="$(cat "$COUNTER")"
echo 4 > "$COUNTER"
OUT="$(json Edit "$TMP/app.ts" | FORGE_DEV_HOOKS=1 bash "$HERE/build-verify-reminder.sh" 2>&1 || true)"
check "build-verify-reminder(.ts 5회째 발동)" "빌드 검증" "$OUT"
# v1.20.0 퍼블리싱 계열 확대 — .js/.scss 도 카운트 대상인가
echo 4 > "$COUNTER"
OUT="$(json Edit "$TMP/app.js" | FORGE_DEV_HOOKS=1 bash "$HERE/build-verify-reminder.sh" 2>&1 || true)"
check "build-verify-reminder(.js 5회째 발동)" "빌드 검증" "$OUT"
echo 4 > "$COUNTER"
OUT="$(json Edit "$TMP/style.scss" | FORGE_DEV_HOOKS=1 bash "$HERE/build-verify-reminder.sh" 2>&1 || true)"
check "build-verify-reminder(.scss 5회째 발동)" "빌드 검증" "$OUT"
# 비대상 확장자는 카운트도 출력도 없어야 한다
echo 4 > "$COUNTER"
OUT2="$(json Edit "$TMP/note.md" | FORGE_DEV_HOOKS=1 bash "$HERE/build-verify-reminder.sh" 2>&1 || true)"
[ -z "$OUT2" ] && { echo "  PASS  build-verify-reminder(비대상 .md 무음)"; PASS=$((PASS+1)); } || { echo "  FAIL  build-verify-reminder(비대상인데 출력)"; FAIL=$((FAIL+1)); }
if [ -n "$SAVED" ]; then echo "$SAVED" > "$COUNTER"; else rm -f "$COUNTER"; fi

echo ""
echo "[5/7] link-integrity-scan — 전수 스캔이 기준선·증가를 잡는가 (2026-08-13 신설)"
# 시험 대상은 「발동하는가」가 아니라 **「거짓 통과하지 않는가」**다.
# 임시 저장소는 반드시 워크스페이스 밖에 만든다 — dz-sync 가 푸시해 버린다.
SCANWS="$TMP/scanws"
mkdir -p "$SCANWS/규칙/프로세스/scripts" "$SCANWS/문서"
cp "$HERE/../../../douzone-forge/규칙/프로세스/scripts/linkcheck.py" \
   "$SCANWS/규칙/프로세스/scripts/linkcheck.py" 2>/dev/null \
  || cp "${DZ_FORGE_DIR:-$HOME/Workspace/douzone-forge}/규칙/프로세스/scripts/linkcheck.py" \
        "$SCANWS/규칙/프로세스/scripts/linkcheck.py" 2>/dev/null
if [ -f "$SCANWS/규칙/프로세스/scripts/linkcheck.py" ]; then
  printf '[깨진 링크](없는파일.md)\n' > "$SCANWS/문서/a.md"
  ( cd "$SCANWS" && git init -q . && git add -A && \
    git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1

  OUT="$(CLAUDE_PROJECT_DIR="$SCANWS" bash "$HERE/link-integrity-scan.sh" 2>&1 || true)"
  check "link-integrity-scan(최초 기준선 보고)" "기준선" "$OUT"

  OUT2="$(CLAUDE_PROJECT_DIR="$SCANWS" bash "$HERE/link-integrity-scan.sh" 2>&1 || true)"
  [ -z "$OUT2" ] && { echo "  PASS  link-integrity-scan(변화 없음 무음)"; PASS=$((PASS+1)); } \
                 || { echo "  FAIL  link-integrity-scan(변화 없는데 출력)"; FAIL=$((FAIL+1)); }

  printf '[또 깨짐](역시없음.md)\n' > "$SCANWS/문서/b.md"
  ( cd "$SCANWS" && git add -A && git -c user.email=t@t -c user.name=t commit -qm more ) >/dev/null 2>&1
  OUT="$(CLAUDE_PROJECT_DIR="$SCANWS" bash "$HERE/link-integrity-scan.sh" 2>&1 || true)"
  check "link-integrity-scan(증가 감지)" "증가" "$OUT"

  # ⚠️ cwd 회귀 — 검사기가 git ls-files 기준이라 cd 를 빠뜨리면 조용히 「0건」이 된다.
  #    훅을 저장소 밖에서 실행해도 CLAUDE_PROJECT_DIR 만으로 정상 검출돼야 PASS.
  rm -f "$SCANWS/.git/dz-linkcheck-baseline"
  OUT="$(cd /tmp && CLAUDE_PROJECT_DIR="$SCANWS" bash "$HERE/link-integrity-scan.sh" 2>&1 || true)"
  check "link-integrity-scan(cwd 함정 회귀)" "기준선" "$OUT"

  # 비-forge 프로젝트(검사기 없음) → 무음
  OUT2="$(CLAUDE_PROJECT_DIR="$TMP" bash "$HERE/link-integrity-scan.sh" 2>&1 || true)"
  [ -z "$OUT2" ] && { echo "  PASS  link-integrity-scan(비-forge 무음)"; PASS=$((PASS+1)); } \
                 || { echo "  FAIL  link-integrity-scan(비-forge인데 출력)"; FAIL=$((FAIL+1)); }
else
  echo "  SKIP  link-integrity-scan — 공식 검사기(규칙/프로세스/scripts/linkcheck.py)를 찾지 못함"
  echo "        워크스페이스 위치를 DZ_FORGE_DIR 로 지정하고 다시 실행하세요."
fi

echo ""
echo "[6/7] dz-gitlab-sync 대량 되돌림 가드 — 자산화를 지우는 커밋을 막는가 (v1.27.0)"
# 배경(실사고 2026-08-27): 중간에 죽은 `git pull` 이 작업트리만 원격판으로 덮어, 내 자산화를
#   지우는 커밋이 대기 상태로 놓였다. 20시간 동안 어느 화면에도 뜨지 않았다.
GT="$TMP/guard"; mkdir -p "$GT"
(
  set -e
  export GIT_AUTHOR_NAME='[UC]시험' GIT_AUTHOR_EMAIL=t@t
  export GIT_COMMITTER_NAME='[UC]시험' GIT_COMMITTER_EMAIL=t@t
  cd "$GT"
  git init -q --bare douzone-forge.git
  git clone -q douzone-forge.git work 2>/dev/null
  cd work
  git config user.name '[UC]시험'; git config user.email t@t
  awk 'BEGIN{for(i=0;i<400;i++) print "line " i}' > timeline.md
  awk 'BEGIN{for(i=0;i<62;i++) print "report"}' > report.md
  git add -A; git commit -qm base; git branch -M main; git push -q origin main
  git branch --set-upstream-to=origin/main main -q 2>/dev/null || true
) >/dev/null 2>&1

# ⓐ 정상 누적(추가만) — 가드가 막으면 안 된다
awk 'BEGIN{for(i=0;i<40;i++) print "새 자산화"}' >> "$GT/work/timeline.md"
OUT="$(CLAUDE_PROJECT_DIR="$GT/work" bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
if printf '%s' "$OUT" | grep -q "대량 되돌림"; then
  echo "  FAIL  대량되돌림가드(정상 작업 오차단)"; FAIL=$((FAIL+1))
else
  echo "  PASS  대량되돌림가드(정상 작업 통과)"; PASS=$((PASS+1))
fi

# ⓑ 되돌림 + 파일 삭제 — 반드시 막아야 한다
#    ⚠️ 이 값(되돌림 30줄 + 62줄 리포트 삭제 = 삭제 92줄)은 v1.27.0 이 문턱 100 에 8줄 모자라
#       그냥 통과시킨 실측 사례다(2026-08-28). 문턱을 다시 올리면 여기서 FAIL 로 잡힌다.
awk 'BEGIN{for(i=0;i<400;i++) print "line " i}' > "$GT/work/timeline.md"
rm -f "$GT/work/report.md"
OUT="$(CLAUDE_PROJECT_DIR="$GT/work" bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
check "대량되돌림가드(발동·92줄 경계)" "대량 되돌림 감지" "$OUT"
# 변경이 로컬에 보존됐는가(커밋되지 않았는가)
if [ -n "$(cd "$GT/work" && git status --porcelain)" ]; then
  echo "  PASS  대량되돌림가드(변경 로컬 보존)"; PASS=$((PASS+1))
else
  echo "  FAIL  대량되돌림가드(커밋돼 버림)"; FAIL=$((FAIL+1))
fi

# ⓒ 죽은 pull 지문 — 줄 수와 무관하게 「HEAD 앞섬 + 작업트리가 원격판 복사」를 잡는가
#    ⚠️ 재현 요령: 원격에도 있는 파일을 로컬에서만 키운 뒤, 작업트리만 원격판으로 되돌린다.
#       (checkout-index 는 원격에 없는 파일을 지우지 않으므로 「신규 파일」로는 재현되지 않는다)
(
  set -e
  export GIT_AUTHOR_NAME='[UC]시험' GIT_AUTHOR_EMAIL=t@t
  export GIT_COMMITTER_NAME='[UC]시험' GIT_COMMITTER_EMAIL=t@t
  cd "$GT/work"
  git reset -q --hard origin/main
  for i in 1 2 3; do echo "base $i" > "shared$i.md"; done
  git add -A && git commit -qm "shared base" && git push -q origin main
  for i in 1 2 3; do
    echo "내 자산화 $i" >> "shared$i.md"
    git add -A && git commit -qm "local $i"
  done
  git read-tree origin/main && git checkout-index -a -f && git read-tree HEAD
) >/dev/null 2>&1
OUT="$(CLAUDE_PROJECT_DIR="$GT/work" bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
check "대량되돌림가드(죽은 pull 지문)" "죽은 git pull" "$OUT"
(cd "$GT/work" && git reset -q --hard HEAD) >/dev/null 2>&1

# ⓓ 우회 스위치가 실제로 통과시키는가
awk 'BEGIN{for(i=0;i<400;i++) print "line " i}' > "$GT/work/timeline.md"
rm -f "$GT/work/report.md" 2>/dev/null || true
OUT="$(CLAUDE_PROJECT_DIR="$GT/work" DZ_SYNC_ALLOW_MASS_REVERT=1 bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
if [ -z "$(cd "$GT/work" && git status --porcelain)" ]; then
  echo "  PASS  대량되돌림가드(우회 스위치 동작)"; PASS=$((PASS+1))
else
  echo "  FAIL  대량되돌림가드(우회해도 안 됨)"; FAIL=$((FAIL+1))
fi

echo "[7/7] dz-gitlab-sync 연속 실패 환기 — 3회째에 방치를 알리는가 (v1.28.0)"
# 배경(실사고 2026-09-07): 같은 파일 끝을 무인 모니터 루틴과 대화형 세션이 각각 이어 붙여
#   10:24~16:22 약 6시간, 18회 연속 같은 지점에서 멈췄다. 충돌 자체보다 「아무도 몰랐다」가 피해였다.
ST="$TMP/streak"; mkdir -p "$ST"
(
  set -e
  export GIT_AUTHOR_NAME='[UC]시험' GIT_AUTHOR_EMAIL=t@t
  export GIT_COMMITTER_NAME='[UC]시험' GIT_COMMITTER_EMAIL=t@t
  cd "$ST"
  git init -q --bare douzone-forge.git
  git clone -q douzone-forge.git work 2>/dev/null
  cd work
  git config user.name '[UC]시험'; git config user.email t@t
  echo "base" > journal.md
  git add -A; git commit -qm base; git branch -M main; git push -q origin main
  git branch --set-upstream-to=origin/main main -q 2>/dev/null || true
  # 다른 기기(무인 루틴 역할)가 같은 파일 끝을 고쳐 먼저 올린 상황
  cd "$ST"; git clone -q douzone-forge.git other 2>/dev/null
  cd other; git config user.name '[UC]타인'; git config user.email o@o
  echo "원격이 붙인 줄" >> journal.md
  git add -A; git commit -qm remote; git push -q origin HEAD:main
) >/dev/null 2>&1
SF="$ST/work/.git/dz-sync-fail-streak"

# 로컬도 같은 자리를 고친다 → 이후 매 실행이 같은 지점에서 충돌한다 (오늘 사고의 모양)
echo "내가 붙인 줄" >> "$ST/work/journal.md"
O1="$(CLAUDE_PROJECT_DIR="$ST/work" bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
O2="$(CLAUDE_PROJECT_DIR="$ST/work" bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
O3="$(CLAUDE_PROJECT_DIR="$ST/work" bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"

# ⓐ 전제 — 충돌이 실제로 났는가 (안 났으면 이 시험 전체가 무의미하다)
check "연속실패환기(전제: 충돌 발생)" "충돌 감지" "$O1"
# ⓑ 문턱 전에는 조용해야 한다 — 매번 알리면 아무도 안 본다
if printf '%s' "$O1$O2" | grep -q "회 연속 실패"; then
  echo "  FAIL  연속실패환기(문턱 전에 발동)"; FAIL=$((FAIL+1))
else
  echo "  PASS  연속실패환기(1·2회째 조용)"; PASS=$((PASS+1))
fi
# ⓒ 3회째에 발동 (기본 문턱이 3인지까지 단언 — 지시받은 값이다)
check "연속실패환기(3회째 발동)" "3회 연속 실패" "$O3"

# ⓓ 발신 수단이 있으면 실제로 부르는가 — 플러그인에 웹훅을 담지 않는 설계의 핵심
cat > "$ST/alert.sh" <<'EOS'
#!/usr/bin/env bash
printf '%s' "$1" > "$(dirname "$0")/alert-received.txt"
EOS
chmod +x "$ST/alert.sh"
rm -f "$SF" "$ST/alert-received.txt"
CLAUDE_PROJECT_DIR="$ST/work" DZ_SYNC_FAIL_STREAK_N=1 DZ_SYNC_ALERT_CMD="$ST/alert.sh"   bash "$HERE/dz-gitlab-sync.sh" sync >/dev/null 2>&1 || true
if [ -s "$ST/alert-received.txt" ] && grep -q "forge 동기화" "$ST/alert-received.txt"; then
  echo "  PASS  연속실패환기(발신 명령 호출)"; PASS=$((PASS+1))
else
  echo "  FAIL  연속실패환기(발신 명령 미호출)"; FAIL=$((FAIL+1))
fi

# ⓔ 끄기 스위치 — 화면 고지도 발신도 없어야 한다
rm -f "$SF" "$ST/alert-received.txt"
O5="$(CLAUDE_PROJECT_DIR="$ST/work" DZ_SYNC_ALERT=0 DZ_SYNC_FAIL_STREAK_N=1       DZ_SYNC_ALERT_CMD="$ST/alert.sh" bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
if printf '%s' "$O5" | grep -q "회 연속 실패" || [ -s "$ST/alert-received.txt" ]; then
  echo "  FAIL  연속실패환기(끄기 스위치 무효)"; FAIL=$((FAIL+1))
else
  echo "  PASS  연속실패환기(끄기 스위치 동작)"; PASS=$((PASS+1))
fi

# ⓕ 동기화가 끝까지 성공하면 카운트가 지워지는가 — 다음 사고를 1회부터 세야 한다
(
  set -e
  export GIT_AUTHOR_NAME='[UC]시험' GIT_AUTHOR_EMAIL=t@t
  export GIT_COMMITTER_NAME='[UC]시험' GIT_COMMITTER_EMAIL=t@t
  cd "$ST/work"
  git rebase --abort >/dev/null 2>&1 || true
  git fetch -q origin main && git reset -q --hard origin/main
) >/dev/null 2>&1
printf '5|0|시험\n' > "$SF"
echo "이어 붙이는 줄" >> "$ST/work/journal.md"
CLAUDE_PROJECT_DIR="$ST/work" bash "$HERE/dz-gitlab-sync.sh" sync >/dev/null 2>&1 || true
if [ -f "$SF" ]; then
  echo "  FAIL  연속실패환기(성공했는데 카운트 잔존)"; FAIL=$((FAIL+1))
else
  echo "  PASS  연속실패환기(성공 시 카운트 초기화)"; PASS=$((PASS+1))
fi

echo ""
echo "결과: PASS $PASS · FAIL $FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
