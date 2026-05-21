#!/bin/bash
# Hook: build-verify-reminder
# Trigger: PostToolUse (Edit)
# Purpose: N회 Edit 후 빌드 검증 리마인더

# --- Claude Code Hook Metadata ---
# event: PostToolUse
# tools: Edit
# ---

FILE="$CLAUDE_FILE_PATH"
COUNTER_FILE="/tmp/.forge-edit-counter"

# 소스 파일만 카운트
if [[ "$FILE" == *.java ]] || [[ "$FILE" == *.ts ]] || [[ "$FILE" == *.tsx ]]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
  COUNT=$((COUNT + 1))
  echo "$COUNT" > "$COUNTER_FILE"

  if [ $((COUNT % 5)) -eq 0 ]; then
    echo "🔨 ${COUNT}회 코드 수정 완료. 빌드 검증 추천:"
    echo "  Backend: ./gradlew clean build"
    echo "  Frontend: npm run build"
    echo "  (빌드 통과 확인 후 다음 수정으로 넘어가세요)"
  fi
fi
