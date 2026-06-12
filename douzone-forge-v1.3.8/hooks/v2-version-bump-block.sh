#!/usr/bin/env bash
# Hook: v2-version-bump-block
# 학습 #6 — 승인 단순화 (v2 갱신 시도 X)
# SSoT: 규칙/프로세스/자비스-운영-룰.md §2 학습 #6
#
# Trigger: PreToolUse (Write)
# Target: *-v2.md 또는 *v2-*.md 패턴 — 같은 사이클 내 v2 계획서 신규 작성
# Action: 차단 (exit 2)
# Exit: 2 (차단 — v2 갱신 자체가 학습 #6 위배)

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

# Write 만 대상 (Edit 은 기존 파일 갱신 — 정정 사항 반영 허용)
[ "$TOOL_NAME" = "Write" ] || exit 0

# 빈 경로 스킵
[ -z "$FILE_PATH" ] && exit 0

BASENAME="$(basename "$FILE_PATH")"

# archive·.bak·변천사 보호
case "$FILE_PATH" in
  */_archive/*|*/99_archive/*|*.bak.*) exit 0 ;;
esac

# 변천사·로그 본문 예외 (계획서 본문 아님)
case "$BASENAME" in
  *변천사*|*변경이력*|*history*|*log*) exit 0 ;;
esac

# v2 계획서 패턴 매칭
IS_V2_PLAN=0
case "$BASENAME" in
  *-v2.md|*-v2-*.md|*v2-계획서*.md|*v2-마스터*.md|*v2-지시서*.md) IS_V2_PLAN=1 ;;
  *-V2.md|*-V2-*.md) IS_V2_PLAN=1 ;;
esac

# 계획서·지시서·마스터 키워드 동반 검증 (false positive 회피)
HAS_PLAN_KEYWORD=0
case "$BASENAME" in
  *계획서*|*지시서*|*마스터*) HAS_PLAN_KEYWORD=1 ;;
esac

if [ "$IS_V2_PLAN" = "1" ] && [ "$HAS_PLAN_KEYWORD" = "1" ]; then
  cat >&2 <<EOF
🚫 [v2-version-bump-block] v2 계획서 신규 작성 차단
    파일: $FILE_PATH
    학습 #6 — 승인 단순화 (v2 갱신 시도 X)
    - ExitPlanMode 승인 자체가 단순 OK 신호
    - 추가 v2 갱신은 R8 손실 + 학습 #4 일관 위배
    - v1 그대로 + 정정 1~2건만 본문 반영
    SSoT: 규칙/프로세스/자비스-운영-룰.md §2 학습 #6
    → v1 파일을 Edit 으로 정정. 본 Write 중단.
EOF
  exit 2
fi

exit 0
