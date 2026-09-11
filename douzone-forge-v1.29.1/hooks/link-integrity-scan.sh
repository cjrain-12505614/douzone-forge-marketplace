#!/usr/bin/env bash
# douzone-forge — 전수 링크 스캔 (세션 1회) · link-integrity-scan
#
# 왜 필요한가: 짝 훅 link-integrity-check.sh 는 PostToolUse 로 **방금 쓴 파일 1개**만 본다(그 훅 L4).
#   이미 있던 파일의 파손은 누가 다시 쓰기 전까지 영원히 안 걸린다. 실측 — 2026-08-02 기준선 76건이
#   2026-08-13 129건으로 11일 만에 +53건 늘었다. 두 층은 경쟁이 아니라 보완이다.
#
# 구조: 메커니즘 = 플러그인 / 검사 로직 = 동기화되는 워크스페이스 공식 검사기
#       (force-rules-inject.sh 와 같은 패턴 — 내용은 워크스페이스, 배선은 플러그인)
#
# ⛔ 자체 정규식으로 세지 않는다 — `_개인/점검/정기종합점검-규격.md` 항목 11의 함정 조항.
#    자체 집계는 직전 회차 수치와 비교가 끊기고, 정규식은 CommonMark 균형 괄호를 오탐한다.
#
# 보고 방식: **증가분(델타)만** 알린다. 현재 123건 중 48건이 Workspace_a10 소스를 가리키는
#   의도된 참조라 영구 잔존한다 — 절대값 0을 목표로 삼으면 매 세션 소음이 되어 무시된다.
#
# Trigger: SessionStart (startup|resume) · Tools: python3, git · 종료코드 항상 0(권고형)
# SSoT: 규칙/프로세스/scripts/linkcheck.py (검사기) · 규칙/프로세스/경로-비종속-운영-표준.md §4.4
# 끄기: DZ_LINKSCAN=0
set -uo pipefail

[ "${DZ_LINKSCAN:-1}" = "0" ] && exit 0

DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
CHECKER="$DIR/규칙/프로세스/scripts/linkcheck.py"

# forge 가 아닌 프로젝트 — 조용히 통과
[ -f "$CHECKER" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

# ⚠️ cd 필수 — 검사기가 `git ls-files` 기준이라 cwd 가 어긋나면 대상 0건이 되어
#    「깨짐 0건」으로 거짓 통과한다. 저장소가 아니면 아예 빠진다.
cd "$DIR" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

OUT="$(python3 "$CHECKER" active 2>/dev/null)" || exit 0
TOT="$(printf '%s' "$OUT" | sed -n '1s/.*내부 링크 \([0-9,]*\)건.*/\1/p' | tr -d ,)"
CUR="$(printf '%s' "$OUT" | sed -n '1s/.*깨짐 \([0-9]*\)건.*/\1/p')"

# 모수 0 = 검사기가 헛돌았다는 신호. 「이상 없음」으로 보고하지 않고 그냥 빠진다.
[ -n "$TOT" ] && [ -n "$CUR" ] && [ "$TOT" -gt 0 ] 2>/dev/null || exit 0

# 기준선은 .git 안에 둔다 — 커밋·동기화 대상이 아니라 기기별 로컬 상태로 남고,
# _개인/sync-log.md 류의 다기기 병합 충돌을 만들지 않는다.
BASE="$(git rev-parse --git-dir)/dz-linkcheck-baseline"
PREV="$(cat "$BASE" 2>/dev/null || true)"
printf '%s' "$CUR" > "$BASE" 2>/dev/null || true

if [ -z "$PREV" ]; then
  echo "🔗 링크 전수 스캔 기준선: 깨진 링크 ${CUR}건 / 내부 링크 ${TOT}건"
  echo "   전건 확인: python3 규칙/프로세스/scripts/linkcheck.py active"
elif [ "$CUR" -gt "$PREV" ] 2>/dev/null; then
  echo "⚠️ 깨진 링크 증가: ${PREV}건 → ${CUR}건 (+$((CUR - PREV)))"
  printf '%s\n' "$OUT" | sed -n '2,13p'
  echo "   전건 확인: python3 규칙/프로세스/scripts/linkcheck.py active"
fi

exit 0
