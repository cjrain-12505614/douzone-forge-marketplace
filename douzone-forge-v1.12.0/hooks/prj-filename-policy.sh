#!/usr/bin/env bash
# Phase Q-2 Q-10 — 산출물 파일명 표준 검증
# PostToolUse Write/Edit hook
# 표준: YYYYMMDD-{주제}.md (8자리 강제, 메타 화이트리스트 제외)
# 정책: rules/prj-filename-policy.md

FILE_PATH="${CLAUDE_FILE_PATH:-$1}"
[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename "$FILE_PATH")

# 메타 화이트리스트
case "$BASENAME" in
  _README.md|_index.md|_dashboard.md|00_overview.md|CHANGELOG.md|README.md)
    exit 0 ;;
  .gitignore|*.bak.*)
    exit 0 ;;
esac

# 적용 범위 한정 (외부 인용 영향 차단)
case "$FILE_PATH" in
  */프로젝트/PRJ-*/0[1-6]_*/*) ;;
  */Amaranth10/*/history/*|*/Amaranth10/*/tasks/*|*/Amaranth10/*/_분석문서/*) ;;
  */참고자료/*|*/_개인/*) ;;
  *)
    exit 0 ;;
esac

# .md 한정
case "$BASENAME" in
  *.md) ;;
  *) exit 0 ;;
esac

# YYYYMMDD-* 패턴 검증
if [[ ! "$BASENAME" =~ ^[0-9]{8}- ]]; then
  echo "⚠️  파일명 표준 위배: $FILE_PATH" >&2
  echo "    표준: YYYYMMDD-{주제}.md (8자리 강제)" >&2
  echo "    상세: rules/prj-filename-policy.md" >&2
fi
exit 0
