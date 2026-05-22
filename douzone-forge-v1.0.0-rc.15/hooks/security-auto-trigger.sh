#!/bin/bash
# Hook: security-auto-trigger
# Trigger: PostToolUse (Edit, Write)
# Purpose: 보안 관련 파일 수정 시 보안 리뷰 제안

# --- Claude Code Hook Metadata ---
# event: PostToolUse
# tools: Edit,Write
# ---

FILE="$CLAUDE_FILE_PATH"

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
