#!/bin/bash
# Hook: code-quality-reminder
# Trigger: PostToolUse (Edit, Write)
# Purpose: Java/TypeScript 코드 수정 후 품질 셀프체크 리마인더

# --- Claude Code Hook Metadata ---
# event: PostToolUse
# tools: Edit,Write
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

# Java/TypeScript 파일에만 적용
if [[ "$FILE" == *.java ]] || [[ "$FILE" == *.ts ]] || [[ "$FILE" == *.tsx ]]; then
  echo "💡 코드 품질 체크리스트:"
  echo "  - [ ] 에러 핸들링: try-catch로 예외 처리했나?"
  echo "  - [ ] 입력 검증: null/빈값/범위 확인했나?"
  echo "  - [ ] 네이밍: 클래스/메서드/변수명이 명확한가?"
  echo "  - [ ] 로깅: 중요 분기점에 로그를 남겼나?"
fi
