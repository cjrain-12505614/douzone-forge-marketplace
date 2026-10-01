#!/bin/bash
# Hook: db-migration-guard
# Trigger: PreToolUse (Bash, Write, Edit)
# Purpose: Flyway 마이그레이션 SQL에서 파괴적 명령(DROP TABLE / TRUNCATE / 무조건 DELETE) 차단
#
# 입력: stdin으로 JSON 전달 (Claude Code 현행 hook 표준)
#   { "tool_name": "...", "tool_input": { ... } }
# 차단: stdout에 JSON { continue:false, decision:"block", reason:"..." } + exit 2

set -euo pipefail

# H-4 opt-out: 운영 DB 손실 방어라 다른 훅과 달리 기본 차단 유지(게이트로 안 묶음).
# 명시적 opt-out 일 때만 우회하며, 우회 사실을 가시 경고로 남긴다(우회=본인 책임).
case "${FORGE_DB_GUARD:-}" in
  off|OFF|0|false|FALSE|no|NO)
    echo "⚠️ [db-migration-guard] FORGE_DB_GUARD=off — 파괴적 SQL 차단을 우회합니다(opt-out). 운영 DB 손실 위험은 본인 책임." >&2
    exit 0 ;;
esac

# stdin JSON 파싱 (jq 없으면 fallback)
INPUT_JSON="$(cat || true)"

extract_field() {
  local key="$1"
  if command -v jq >/dev/null 2>&1; then
    echo "$INPUT_JSON" | jq -r "$key // empty" 2>/dev/null || echo ""
  else
    echo "$INPUT_JSON" | grep -oE "\"${key##*.}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
      | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/'
  fi
}

TOOL_NAME="$(extract_field '.tool_name')"
FILE_PATH="$(extract_field '.tool_input.file_path')"
CONTENT="$(extract_field '.tool_input.content')"
COMMAND="$(extract_field '.tool_input.command')"

MIG_PATH_PAT='db/migration|src/main/resources/db/migration|flyway'
DANGER_PAT='(DROP[[:space:]]+TABLE|TRUNCATE[[:space:]]+TABLE|TRUNCATE[[:space:]]+[A-Za-z_]|DELETE[[:space:]]+FROM[[:space:]]+[A-Za-z_]+[[:space:]]*;)'

block() {
  local reason="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg r "$reason" '{continue:false, decision:"block", reason:$r}'
  else
    printf '{"continue":false,"decision":"block","reason":"%s"}\n' "$reason"
  fi
  exit 2
}

case "$TOOL_NAME" in
  Write|Edit)
    if echo "$FILE_PATH" | grep -qiE "$MIG_PATH_PAT" && \
       echo "$FILE_PATH" | grep -qiE '\.sql$' && \
       echo "$CONTENT" | grep -qiE "$DANGER_PAT"; then
      block "Flyway 마이그레이션에 파괴적 명령 감지 (DROP TABLE/TRUNCATE/무조건 DELETE). 운영 데이터 손실 위험 → 주석으로 사유 명시 후 승인 받은 경우에만 진행. file=$FILE_PATH"
    fi
    ;;
  Bash)
    if echo "$COMMAND" | grep -qiE "$DANGER_PAT"; then
      block "Bash 커맨드에 파괴적 SQL 감지. command=$COMMAND"
    fi
    ;;
esac

exit 0
