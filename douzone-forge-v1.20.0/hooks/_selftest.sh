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

echo "[1/4] link-integrity-check — 깨진 링크 md 에서 경고가 나오는가"
BROKEN_MD="$TMP/broken.md"
printf '[존재하지 않는 파일](./no-such-file-xyz.md)\n' > "$BROKEN_MD"
OUT="$(json Write "$BROKEN_MD" | bash "$HERE/link-integrity-check.sh" 2>&1 || true)"
check "link-integrity-check(발동)" "깨진 링크" "$OUT"
OUT2="$(json Write "$TMP/ok.txt" | bash "$HERE/link-integrity-check.sh" 2>&1 || true)"
[ -z "$OUT2" ] && { echo "  PASS  link-integrity-check(비대상 무음)"; PASS=$((PASS+1)); } || { echo "  FAIL  link-integrity-check(비대상인데 출력)"; FAIL=$((FAIL+1)); }

echo "[2/4] code-quality-reminder — 게이트 켜짐 + 확장자별 체크리스트가 나오는가"
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

echo "[3/4] security-auto-trigger — 보안 파일명에서 경고가 나오는가"
OUT="$(json Edit "$TMP/AuthService.java" | FORGE_DEV_HOOKS=1 bash "$HERE/security-auto-trigger.sh" 2>&1 || true)"
check "security-auto-trigger(발동)" "보안 민감" "$OUT"

echo "[4/4] build-verify-reminder — 5회째 편집에서 리마인더가 나오는가"
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
echo "결과: PASS $PASS · FAIL $FAIL"
[ "$FAIL" -eq 0 ] || exit 1
exit 0
