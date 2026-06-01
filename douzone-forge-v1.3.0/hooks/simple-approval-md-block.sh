#!/usr/bin/env bash
# Hook: simple-approval-md-block
# 학습 #4 — 단순 결재 시 .md 생략, 채팅 회신만
# SSoT: 규칙/프로세스/자비스-운영-룰.md §2 학습 #4
#
# Trigger: PreToolUse (Write, Edit)
# Target: *검토의견*.md 또는 *검토결과*.md 패턴
# Action: 단순 결재 .md 신규 작성 검출 시 stderr 경고 (block X)
# Exit: 0 (경고만 — 종합 검토 시 .md 산출은 허용)

set -uo pipefail

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

# Write/Edit 만 대상
case "$TOOL_NAME" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

# 빈 경로 스킵
[ -z "$FILE_PATH" ] && exit 0

BASENAME="$(basename "$FILE_PATH")"

# archive·.bak 보호
case "$FILE_PATH" in
  */_archive/*|*/99_archive/*|*.bak.*) exit 0 ;;
esac

# 검토의견·검토결과 .md 패턴 매칭
IS_REVIEW_MD=0
case "$BASENAME" in
  *검토의견*.md|*검토결과*.md) IS_REVIEW_MD=1 ;;
esac

[ "$IS_REVIEW_MD" = "0" ] && exit 0

# Write 신규 작성만 경고 (Edit 은 기존 종합 검토 갱신일 수 있어 보다 관대)
if [ "$TOOL_NAME" = "Write" ] && [ ! -f "$FILE_PATH" ]; then
  cat >&2 <<EOF
⚠️  [simple-approval-md-block] 검토의견 .md 신규 작성 감지
    파일: $FILE_PATH
    학습 #4 — 단순 결재 시 .md 생략, 채팅 회신만
    - 단순 OK: 채팅 한 줄 ("⑥ 단순 OK — ⑦ 진입 OK")
    - 정정 의견 1~2건: 채팅 본문만 + .md 별도 X
    - 종합 검토 (정정 다수): .md 산출 허용
    SSoT: 규칙/프로세스/자비스-운영-룰.md §2 학습 #4
    → 단순 결재면 본 .md 작성 중단, 채팅 회신으로 대체. (block 하지 않음)
EOF
fi

exit 0
