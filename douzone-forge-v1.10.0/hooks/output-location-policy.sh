#!/usr/bin/env bash
# Phase R R-05 — 산출물 위치 정합 (자비스 학습 #7 자산화)
# PostToolUse Write hook
# 산출물(계획서·완료보고서·검토의견 등) 모듈 하위 저장 시 stderr 경고

FILE_PATH="${CLAUDE_FILE_PATH:-$1}"
[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename "$FILE_PATH")

# archive·.bak 영역 보호
case "$FILE_PATH" in
  */_archive/*|*/99_archive/*|*.bak.*) exit 0 ;;
esac

# 산출물 패턴 8개 매칭
IS_OUTPUT=0
case "$BASENAME" in
  *-우산지시서.md|*-계획서.md|*-검토의견*.md|*-완료보고서.md) IS_OUTPUT=1 ;;
  *-종착보고서.md|*-Pre-fix-카운터.md|*-sed-로그.md|*-결과검토.md) IS_OUTPUT=1 ;;
esac

# 모듈 하위 저장 여부
IS_MODULE=0
case "$FILE_PATH" in
  */Amaranth10/*) IS_MODULE=1 ;;
esac

if [ "$IS_OUTPUT" = "1" ] && [ "$IS_MODULE" = "1" ]; then
  echo "⚠️  산출물이 모듈 하위에 저장됨: $FILE_PATH" >&2
  echo "    표준 위치:" >&2
  echo "      - 프로젝트/PRJ-{NNN}_*/01_기획/  (계획서·검토의견·완료보고서)" >&2
  echo "      - 프로젝트/PRJ-{NNN}_*/0[2-6]_*/  (분기별 산출물)" >&2
  echo "    상세: 자비스 학습 #7" >&2
fi
exit 0
