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

# 대상 확장자 — v1.20.0에서 퍼블리싱 계열 확대 (차민수 수석 승인 2026-07-30)
#   배경: klago-pub-poc 실측 결과 퍼블리싱 소스는 .js 2,072 · .html 86 · .scss 6 이고
#         .ts/.tsx 는 0개라, 종전 Java/TS 한정 조건으로는 퍼블리싱Cell에 전혀 걸리지 않았다.
#   계열별로 체크 항목이 다르므로 분기한다(코드 체크리스트를 CSS 에 띄우면 소음이 된다).
case "$FILE" in
  *.java|*.ts|*.tsx|*.js|*.jsx|*.vue)
    echo "💡 코드 품질 체크리스트:"
    echo "  - [ ] 에러 핸들링: try-catch로 예외 처리했나?"
    echo "  - [ ] 입력 검증: null/빈값/범위 확인했나?"
    echo "  - [ ] 네이밍: 클래스/메서드/변수명이 명확한가?"
    echo "  - [ ] 로깅: 중요 분기점에 로그를 남겼나?"
    ;;
  *.html|*.scss|*.css)
    echo "💡 퍼블리싱 품질 체크리스트:"
    echo "  - [ ] 시맨틱 마크업: 역할에 맞는 태그를 썼나?"
    echo "  - [ ] 접근성: alt·label·aria·키보드 이동을 확인했나?"
    echo "  - [ ] 반응형: 브레이크포인트에서 레이아웃이 깨지지 않나?"
    echo "  - [ ] 크로스브라우징: 크롬 외 브라우저에서 확인했나?"
    ;;
esac
