#!/bin/bash
# Hook: oneffice-html-facts-check
# Trigger: PostToolUse (Write, Edit)
# Purpose: HTML→원피스(ONEFFICE) 주입용 HTML 파일에 자비스-사용자 소통 흔적
#          (확인 필요·자비스 등)이 섞여 있으면 경고 — WARNING 만 (block 안 함)
#
# 배경: 2026-07-06 차민수 수석 확정 원칙 — md(회의록·계획서 등 작업 기록)까지는
# 다각도 작성 허용, HTML을 만들어 원피스로 주입하는 단계부터는 반드시 확정 사실만
# 담아야 함. SSoT: skills/dz-oneffice-writer/SKILL.md 「콘텐츠 원칙」 섹션.
#
# 입력: stdin JSON
#   { "tool_name": "...", "tool_input": { "file_path": "..." } }
# 동작: block 하지 않음. stderr 경고만 (exit 0).
#
# 본 hook 본문은 answer-tone-check.sh 패턴 일관.

set -euo pipefail

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

case "$TOOL_NAME" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

[[ "$FILE_PATH" == *.html ]] || exit 0
[[ -f "$FILE_PATH" ]] || exit 0

VIOLATIONS="$(grep -nE '확인 필요|자비스' "$FILE_PATH" 2>/dev/null | head -3 || true)"

if [[ -n "$VIOLATIONS" ]]; then
  cat >&2 <<EOF
⚠️  [oneffice-html-facts-check] 내부 소통 흔적 의심 패턴 검출
    파일: $FILE_PATH
    의심 라인 (최대 3건):
$VIOLATIONS
    → 이 HTML이 원피스(ONEFFICE)로 주입될 예정이면, 자비스-사용자 소통 흔적
      ("확인 필요"·"자비스" 등)을 제거하고 확정된 사실만 남겨야 함.
    → md(회의록·계획서 등 작업 기록) 단계라면 이 경고는 해당 없음 — 무시 가능.
    → 본 SSoT: skills/dz-oneffice-writer/SKILL.md 「콘텐츠 원칙」 섹션 (2026-07-06 확정)
    → 본 hook 은 block 하지 않음 (WARNING 만, 자가 점검 1차).
EOF
fi

exit 0
