#!/usr/bin/env bash
# Phase Q-2 Q-10 — 산출물 파일명 표준 검증
# PostToolUse Write/Edit hook
# 표준: YYYYMMDD-{주제}.md (8자리 강제, 메타 화이트리스트 제외)
# 정책: rules/prj-filename-policy.md

# 입력: stdin JSON { "tool_input": { "file_path": "..." } } — 표준 훅 프로토콜
#   (선재 결함: 종전엔 CLAUDE_FILE_PATH env/$1만 읽어 배선돼 있어도 경로가 항상 비어 조용히 무발동.
#    structure-awareness.sh는 v1.11.2에서 교정됐으나 본 훅은 누락 → v1.14.1 동일 교정. 2026-07-14 실측.)
FILE_PATH="${CLAUDE_FILE_PATH:-${1:-}}"
if [ -z "$FILE_PATH" ] && [ ! -t 0 ]; then
  INPUT_JSON="$(cat || true)"
  if command -v jq >/dev/null 2>&1; then
    FILE_PATH="$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")"
  else
    FILE_PATH="$(echo "$INPUT_JSON" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"([^"]*)"$/\1/')"
  fi
fi
[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename "$FILE_PATH")

# 메타 화이트리스트 (v1.14.3: _current.md 추가 — 세션 체크포인트 표준 파일명)
case "$BASENAME" in
  _README.md|_index.md|_dashboard.md|00_overview.md|CHANGELOG.md|README.md|_current.md)
    exit 0 ;;
  .gitignore|*.bak.*)
    exit 0 ;;
esac

# 적용 범위 한정 (외부 인용 영향 차단)
# v1.14.3 정교화: PRJ 0X_ 아래는 "직속 파일만" 검사 — 하위 묶음 폴더(날짜 폴더·연구 묶음 등)는
# 폴더가 맥락을 담보하므로 면제 (2026-07-15 파일명 표준화 배치 — 감사 §C-10 권고)
case "$FILE_PATH" in
  */프로젝트/PRJ-*/0[1-6]_*/*/*) exit 0 ;;
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
