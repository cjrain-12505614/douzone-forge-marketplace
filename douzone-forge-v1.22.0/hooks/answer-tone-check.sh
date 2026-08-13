#!/bin/bash
# Hook: answer-tone-check
# Trigger: PostToolUse (Write, Edit)
# Purpose: 답변 언어 톤 표준 4 룰 자동 검출 — WARNING 만 (block 안 함)
#
# 검출 영역 (rules/prj-code-naming.md 와 분리 영역):
#   1. 영문 두문자 ≥ 4자 + 한글 풀이 부재 → WARNING (룰 2 외국어 약어 풀이)
#   2. 사번·티켓 ID 단독 표기 (CSA10·KLAGOP1·A10D·UBA·UAC·EO·BC10) → WARNING (룰 3 코드 단독 회피 — PRJ 외 패턴)
#
# 입력: stdin JSON
#   { "tool_name": "...", "tool_input": { "file_path": "..." } }
# 동작: block 하지 않음. stderr 경고만 (exit 0).
#
# 본 hook 본문은 prj-code-naming-check.sh 패턴 일관 (의제 ❶ A 채택).
# 본 SSoT: 규칙/프로세스/답변-언어-톤-표준.md

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

[[ "$FILE_PATH" == *.md ]] || exit 0
[[ -f "$FILE_PATH" ]] || exit 0

# 룰 2 — 영문 두문자 ≥ 4자 검출 (간단 패턴, 코드블록·링크·frontmatter 영역도 포함 — false positive 허용, WARNING 만)
ABBREV_VIOLATIONS="$(grep -nE '\b[A-Z]{4,}\b' "$FILE_PATH" 2>/dev/null | head -3 || true)"
if [[ -n "$ABBREV_VIOLATIONS" ]]; then
  cat >&2 <<EOF
⚠️  [answer-tone-check] 영문 두문자 ≥ 4자 검출 (룰 2 — 한글 풀이 병기 점검 권고)
    파일: $FILE_PATH
    의심 라인 (최대 3건):
$ABBREV_VIOLATIONS
    → 한글 풀이 + 약어 병기 패턴 검토 (예: "표준 정의(SSoT)" — 첫 등장 시 풀이 의무).
    → 본 SSoT: 규칙/프로세스/답변-언어-톤-표준.md §2 룰 2
    → 본 hook 은 block 하지 않음 (WARNING 만, 자가 점검 1차).
EOF
fi

# 룰 3 — 사번·티켓 ID 패턴 검출 (PRJ 코드 외 영역, prj-code-naming-check.sh 와 분리)
TICKET_VIOLATIONS="$(grep -nE '\b(CSA10|KLAGOP1|A10D|UBA|UAC|EO|BC10)-[0-9]+\b' "$FILE_PATH" 2>/dev/null | head -3 || true)"
if [[ -n "$TICKET_VIOLATIONS" ]]; then
  cat >&2 <<EOF
⚠️  [answer-tone-check] 사번·티켓 ID 패턴 검출 (룰 3 — 풀네임 병기 점검 권고)
    파일: $FILE_PATH
    의심 라인 (최대 3건):
$TICKET_VIOLATIONS
    → 풀네임 + ID 병기 패턴 검토 (예: "CRM 데이터 삭제 이슈(CSA10-12345)").
    → 본 SSoT: 규칙/프로세스/답변-언어-톤-표준.md §2 룰 3
    → 본 hook 은 block 하지 않음 (WARNING 만, 자가 점검 1차).
EOF
fi

# rc.11 신규 — 금지 어휘 5건 검출 (답변-언어-톤-표준 §5 SSoT)
FORBIDDEN_VIOLATIONS="$(grep -nE '박혔다|박음|박힘|박아두다|본질|영속화' "$FILE_PATH" 2>/dev/null | head -5 || true)"
if [[ -n "$FORBIDDEN_VIOLATIONS" ]]; then
  cat >&2 <<EOF
⚠️  [answer-tone-check] 금지 어휘 5건 검출 (rc.11 신규 — 대체 어휘 안내)
    파일: $FILE_PATH
    의심 라인 (최대 5건):
$FORBIDDEN_VIOLATIONS
    → 대체 어휘:
        박혔다 → 기록되었습니다 · 추가되었습니다
        박음 → 수록되었습니다 · 포함되었습니다
        박힘 → 포함되었습니다 · 명시되었습니다
        박아두다 → 보존 · 영구 보관
        본질 → 핵심 · 의도 · 목적
        영속화 → 영구히 기록 · 영구 자산
    → 본 SSoT: 규칙/프로세스/답변-언어-톤-표준.md §5 (rc.7 신설)
    → 본 Rule: _plugin/douzone-forge/rules/answer-tone-self-check.md (rc.11 신규)
    → 본 hook 은 block 하지 않음 (WARNING 만, 자가 점검 1차).
    → 변천사 본문 인용 영역·외부 컨텐츠 인용·사용자 발화 인용 영역은 적용 외 (§1.2 사용자 본인 어휘 보호).
EOF
fi

exit 0
