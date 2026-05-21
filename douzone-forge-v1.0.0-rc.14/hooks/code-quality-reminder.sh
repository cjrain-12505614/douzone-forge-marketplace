#!/bin/bash
# Hook: code-quality-reminder
# Trigger: PostToolUse (Edit, Write)
# Purpose: Java/TypeScript 코드 수정 후 품질 셀프체크 리마인더

# --- Claude Code Hook Metadata ---
# event: PostToolUse
# tools: Edit,Write
# ---

FILE="$CLAUDE_FILE_PATH"

# Java/TypeScript 파일에만 적용
if [[ "$FILE" == *.java ]] || [[ "$FILE" == *.ts ]] || [[ "$FILE" == *.tsx ]]; then
  echo "💡 코드 품질 체크리스트:"
  echo "  - [ ] 에러 핸들링: try-catch로 예외 처리했나?"
  echo "  - [ ] 입력 검증: null/빈값/범위 확인했나?"
  echo "  - [ ] 네이밍: 클래스/메서드/변수명이 명확한가?"
  echo "  - [ ] 로깅: 중요 분기점에 로그를 남겼나?"
fi
