#!/usr/bin/env bash
# Phase Q-2 Q-11 — 폴더 _README.md 부재 경고
# PostToolUse Write/Edit hook (신규 폴더 생성 시)
# 표준: 모든 폴더 _README.md 의무 (5섹션 — 목적·소유자·콘텐츠·규칙·관련)

FILE_PATH="${CLAUDE_FILE_PATH:-$1}"
[ -z "$FILE_PATH" ] && exit 0

DIR=$(dirname "$FILE_PATH")
[ "$DIR" = "." ] && exit 0
[ "$DIR" = "/" ] && exit 0

# 화이트리스트 (검증 제외)
case "$DIR" in
  */_archive*|*/99_archive*) exit 0 ;;
  */.git*|*/.git/*|*/node_modules*) exit 0 ;;
  */dist|*/dist/*) exit 0 ;;
  */.bak.*) exit 0 ;;
esac

if [ ! -f "$DIR/_README.md" ]; then
  echo "⚠️  폴더 _README.md 부재: $DIR" >&2
  echo "    /a10-folder-audit 명령으로 일괄 신설 가능" >&2
  echo "    표준 5섹션: 목적·소유자·콘텐츠 분류·신규 추가 규칙·관련 폴더" >&2
fi
exit 0
