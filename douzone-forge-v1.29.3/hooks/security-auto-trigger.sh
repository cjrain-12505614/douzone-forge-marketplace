#!/bin/bash
# Hook: security-auto-trigger
# Trigger: PostToolUse (Edit, Write)
# Purpose: 보안 관련 파일 수정 시 보안 리뷰 제안

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

SECURITY_PATTERNS=(
  "SecurityConfig"
  "JwtToken"
  "AuthService"
  "AuthController"
  "PermissionChecker"
  "password"
  "secret"
  "credential"
)

for pattern in "${SECURITY_PATTERNS[@]}"; do
  if [[ "$FILE" == *"$pattern"* ]]; then
    echo "🔒 보안 민감 파일 수정 감지: $FILE"
    echo "  - [ ] 인증/인가 로직 검증"
    echo "  - [ ] 하드코딩된 시크릿/비밀번호 없는지 확인"
    echo "  - [ ] CORS/CSRF 설정 영향도 확인"
    echo "  - [ ] JWT 토큰 검증 로직 정상 여부"
    break
  fi
done
