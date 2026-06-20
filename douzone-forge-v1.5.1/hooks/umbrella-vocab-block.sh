#!/usr/bin/env bash
# Hook: umbrella-vocab-block
# 학습 #8 — "마스터 X" 어휘 표준 (옛 "우산 X" → "마스터 X")
# SSoT: 규칙/프로세스/자비스-운영-룰.md §2 학습 #8
#
# Trigger: PreToolUse (Write, Edit)
# Target: 모든 .md 파일 — 본문에 "우산 지시서·우산 계획서·우산 PRJ" 신규 작성
# Action: stderr 경고 (block X)
# Exit: 0 (경고만)
# 화이트리스트: 변천사·인용·grep 결과 본문 표현 통과

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

extract_content() {
  if command -v jq >/dev/null 2>&1; then
    echo "$INPUT_JSON" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null || echo ""
  else
    # jq 없으면 빈 문자열 (경고 못함)
    echo ""
  fi
}

TOOL_NAME="$(extract_field '.tool_name')"
FILE_PATH="$(extract_field '.tool_input.file_path')"

case "$TOOL_NAME" in
  Write|Edit) ;;
  *) exit 0 ;;
esac

[ -z "$FILE_PATH" ] && exit 0
[[ "$FILE_PATH" == *.md ]] || exit 0

# archive·.bak·변천사 보호
case "$FILE_PATH" in
  */_archive/*|*/99_archive/*|*.bak.*) exit 0 ;;
esac

BASENAME="$(basename "$FILE_PATH")"

# 변천사·history·changelog 본문 예외 (옛 우산 X 어휘 보존)
case "$BASENAME" in
  *변천사*|*변경이력*|*history*|*changelog*|*변경기록*) exit 0 ;;
esac

# 자비스-운영-룰.md 자체는 본문에 "우산 X" 인용 (SSoT — 옛 어휘 보존)
case "$FILE_PATH" in
  */자비스-운영-룰.md) exit 0 ;;
esac

CONTENT="$(extract_content)"
[ -z "$CONTENT" ] && exit 0

# "우산 지시서·우산 계획서·우산 PRJ" 패턴 검출
UMBRELLA_HITS=""
if echo "$CONTENT" | grep -E "우산[[:space:]]*(지시서|계획서|PRJ|마스터)" > /dev/null 2>&1; then
  # 화이트리스트 검사 — 변천사 표현 동반 시 통과
  if echo "$CONTENT" | grep -E "(옛[[:space:]]*우산|변천사|보존|구[[:space:]]*어휘|이전[[:space:]]*어휘)" > /dev/null 2>&1; then
    # 변천사 보존 표현 동반 → 통과
    exit 0
  fi
  UMBRELLA_HITS="$(echo "$CONTENT" | grep -nE "우산[[:space:]]*(지시서|계획서|PRJ|마스터)" | head -3 || true)"
fi

if [ -n "$UMBRELLA_HITS" ]; then
  cat >&2 <<EOF
⚠️  [umbrella-vocab-block] "우산 X" 어휘 감지 (마스터 X 어휘로 통일 권고)
    파일: $FILE_PATH
    학습 #8 — "마스터 X" 어휘 표준
    - 신규 자비스 산출: "마스터 PRJ"·"마스터 계획서"·"마스터 지시서"
    - 옛 "우산 X" 어휘: 변천사 보존만 (이미 작성된 Phase Q·R·R+ 자산)
    SSoT: 규칙/프로세스/자비스-운영-룰.md §2 학습 #8
    의심 라인:
$UMBRELLA_HITS
    → "우산" → "마스터" 치환 검토. (block 하지 않음, 알림 전용)
EOF
fi

exit 0
