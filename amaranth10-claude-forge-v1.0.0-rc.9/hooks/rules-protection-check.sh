#!/bin/bash
# Hook: rules-protection-check
# Trigger: PostToolUse (Write, Edit)
# Purpose: 규칙 폴더 운영 권한 표준 자동 검출 — WARNING 만 (block 안 함)
#
# 검출 영역 (관리자 영역, SSoT §3 매트릭스 14 영역):
#   1. 워크스페이스 SSoT (`규칙/프로세스/*.md`)
#   2. 플러그인 자산 (rules·hooks·skills·commands·plugin.json)
#   3. CLAUDE.md (워크스페이스·플러그인·모듈 3 위치)
#   4. 모듈 메타 (`module-overview.md`)
#   5. 작업항목 INDEX (관리자 인덱스)
#
# 입력: stdin JSON
#   { "tool_name": "...", "tool_input": { "file_path": "..." } }
# 동작: block 하지 않음. stderr 경고 + 협업 표준 §3 6 단계 흐름 cross-ref 안내
#
# 본 hook 본문은 prj-code-naming + answer-tone + folder-structure 패턴 일관.
# 본 SSoT: 규칙/프로세스/규칙폴더-운영권한-표준.md

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

[[ -n "$FILE_PATH" ]] || exit 0

# 관리자 영역 검출 (SSoT §3 매트릭스 14 영역)
PROTECTION_AREA=""
case "$FILE_PATH" in
  */규칙/프로세스/*.md)
    PROTECTION_AREA="워크스페이스 SSoT (규칙/프로세스/*.md)"
    ;;
  */_plugin/amaranth10-claude-forge/rules/*.md)
    PROTECTION_AREA="플러그인 rules"
    ;;
  */_plugin/amaranth10-claude-forge/hooks/*.sh)
    PROTECTION_AREA="플러그인 hooks"
    ;;
  */_plugin/amaranth10-claude-forge/skills/*/SKILL.md)
    PROTECTION_AREA="플러그인 skills (SKILL.md)"
    ;;
  */_plugin/amaranth10-claude-forge/commands/*.md)
    PROTECTION_AREA="플러그인 commands"
    ;;
  */_plugin/amaranth10-claude-forge/.claude-plugin/plugin.json)
    PROTECTION_AREA="plugin.json"
    ;;
  */CLAUDE.md)
    PROTECTION_AREA="CLAUDE.md 지침 (워크스페이스·플러그인·모듈)"
    ;;
  */module-overview.md)
    PROTECTION_AREA="모듈 메타 (module-overview.md)"
    ;;
  */05_산출물/20260512-작업항목-INDEX.md)
    PROTECTION_AREA="작업항목 INDEX (관리자 인덱스)"
    ;;
esac

if [[ -n "$PROTECTION_AREA" ]]; then
  cat >&2 <<EOF
⚠️  [rules-protection-check] 관리자 영역 진입 검출 — $PROTECTION_AREA
    파일: $FILE_PATH
    → Douzone Forge 관리자 영역. 운영 주체: 차민수 (Forge 관리자)
    → 변경 요청자가 임직원이면 거부 + 관리자 경유 의무 안내
    → 변경 흐름: 협업 표준 §3 6 단계 흐름 적용 의무
      ① 작업지시서 작성 (자비스)
      ② 플랜모드 계획서 (Code)
      ③ 자비스 검토
      ④ 수정 계획서 (필요 시)
      ⑤ 실행 + 결과서 (Code)
      ⑥ 결과 검토 (자비스)
    → 본 SSoT: 규칙/프로세스/규칙폴더-운영권한-표준.md
    → 본 hook 은 block 하지 않음 (WARNING 만, 자가 점검 1차)
EOF
fi

exit 0
