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

json() { printf '{"tool_name":"%s","tool_input":{"file_path":"%s"}}' "$1" "$2"; }

check() { # $1=이름 $2=기대 문자열 $3=실제 출력
  if printf '%s' "$3" | grep -q "$2"; then
    echo "  PASS  $1"; PASS=$((PASS+1))
  else
    echo "  FAIL  $1 — 기대 「$2」 미검출"; FAIL=$((FAIL+1))
  fi
}

echo "[1/6] link-integrity-check — 깨진 링크 md 에서 경고가 나오는가"
BROKEN_MD="$TMP/broken.md"
printf '[존재하지 않는 파일](./no-such-file-xyz.md)\n' > "$BROKEN_MD"
OUT="$(json Write "$BROKEN_MD" | bash "$HERE/link-integrity-check.sh" 2>&1 || true)"
check "link-integrity-check(발동)" "깨진 링크" "$OUT"
OUT2="$(json Write "$TMP/ok.txt" | bash "$HERE/link-integrity-check.sh" 2>&1 || true)"
[ -z "$OUT2" ] && { echo "  PASS  link-integrity-check(비대상 무음)"; PASS=$((PASS+1)); } || { echo "  FAIL  link-integrity-check(비대상인데 출력)"; FAIL=$((FAIL+1)); }

echo "[2/5] code-quality-reminder — 게이트 켜짐 + 확장자별 체크리스트가 나오는가"
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

echo "[3/5] security-auto-trigger — 보안 파일명에서 경고가 나오는가"
OUT="$(json Edit "$TMP/AuthService.java" | FORGE_DEV_HOOKS=1 bash "$HERE/security-auto-trigger.sh" 2>&1 || true)"
check "security-auto-trigger(발동)" "보안 민감" "$OUT"

echo "[4/5] build-verify-reminder — 5회째 편집에서 리마인더가 나오는가"
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
echo "[5/5] link-integrity-scan — 전수 스캔이 기준선·증가를 잡는가 (2026-08-13 신설)"
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
echo "[6/6] dz-gitlab-sync 대량 되돌림 가드 — 자산화를 지우는 커밋을 막는가 (v1.27.0)"
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
awk 'BEGIN{for(i=0;i<400;i++) print "line " i}' > "$GT/work/timeline.md"
rm -f "$GT/work/report.md"
OUT="$(CLAUDE_PROJECT_DIR="$GT/work" bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
check "대량되돌림가드(발동)" "대량 되돌림 감지" "$OUT"
# 변경이 로컬에 보존됐는가(커밋되지 않았는가)
if [ -n "$(cd "$GT/work" && git status --porcelain)" ]; then
  echo "  PASS  대량되돌림가드(변경 로컬 보존)"; PASS=$((PASS+1))
else
  echo "  FAIL  대량되돌림가드(커밋돼 버림)"; FAIL=$((FAIL+1))
fi

# ⓒ 우회 스위치가 실제로 통과시키는가
OUT="$(CLAUDE_PROJECT_DIR="$GT/work" DZ_SYNC_ALLOW_MASS_REVERT=1 bash "$HERE/dz-gitlab-sync.sh" sync 2>&1 || true)"
if [ -z "$(cd "$GT/work" && git status --porcelain)" ]; then
  echo "  PASS  대량되돌림가드(우회 스위치 동작)"; PASS=$((PASS+1))
else
  echo "  FAIL  대량되돌림가드(우회해도 안 됨)"; FAIL=$((FAIL+1))
fi

echo ""
echo "결과: PASS $PASS · FAIL $FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
