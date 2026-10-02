#!/bin/bash
# Hook: build-verify-reminder
# Trigger: PostToolUse (Edit)
# Purpose: N회 Edit 후 빌드 검증 리마인더

# --- Claude Code Hook Metadata ---
# event: PostToolUse
# tools: Edit
# ---

# v1.19.0: stdin JSON(tool_input.file_path) 우선 — 죽은 환경변수 단독 의존 무발동 수복
INPUT_JSON="$(cat 2>/dev/null || true)"
FILE=""
if [ -n "$INPUT_JSON" ]; then
  if command -v jq >/dev/null 2>&1; then
    FILE="$(printf '%s' "$INPUT_JSON" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
  else
    FILE="$(printf '%s' "$INPUT_JSON" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')"
  fi
fi
[ -z "$FILE" ] && FILE="${CLAUDE_FILE_PATH:-${1:-}}"
[ -z "$FILE" ] && exit 0

# H3 비강제 게이트 — 하네스를 켠 폴더(_forge 심링크)/env 에서만 동작, 아니면 무음 통과
_GATE="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)/_forge-gate.sh"
[ -f "$_GATE" ] && . "$_GATE"
if command -v forge_gate_on >/dev/null 2>&1; then
  forge_gate_on "$FILE" || exit 0
fi
COUNTER_FILE="/tmp/.forge-edit-counter"

# 소스 파일만 카운트 — v1.20.0에서 퍼블리싱 계열 확대 (차민수 수석 승인 2026-07-30)
case "$FILE" in
  *.java|*.ts|*.tsx|*.js|*.jsx|*.vue|*.html|*.scss|*.css)
    COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
    COUNT=$((COUNT + 1))
    echo "$COUNT" > "$COUNTER_FILE"

    if [ $((COUNT % 5)) -eq 0 ]; then
      echo "🔨 ${COUNT}회 코드 수정 완료. 빌드 검증 추천:"
      echo "  Backend: ./gradlew clean build"
      echo "  Frontend·퍼블리싱: npm run build"
      echo "  (빌드 통과 확인 후 다음 수정으로 넘어가세요)"
    fi
    ;;
esac
