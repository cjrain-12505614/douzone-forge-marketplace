#!/usr/bin/env bash
# Hook: memory-rule-content-block
# 학습 #11 — 메모리 한정 (사람 기준만)
# SSoT: 규칙/프로세스/자비스-운영-룰.md §2 학습 #11 + §6.2
#
# Trigger: PreToolUse (Write)
# Target: */.claude/projects/*/memory/*.md 패턴
# Action: 룰성 본문 키워드 검출 시 차단 (exit 2)
# Exit: 2 (차단 — 메모리는 사람 기준만, 룰성 본문은 SSoT 이전)
# 화이트리스트: "본인·내 ~·차민수·본인 R&R·본인 KPI·본인 일일보고" 매칭 시 통과

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
    echo "$INPUT_JSON" | jq -r '.tool_input.content // empty' 2>/dev/null || echo ""
  else
    echo ""
  fi
}

TOOL_NAME="$(extract_field '.tool_name')"
FILE_PATH="$(extract_field '.tool_input.file_path')"

# Write 만 대상 (Edit 은 기존 메모리 정정 — 학습 #11 적용 후 정리 트랙 허용)
[ "$TOOL_NAME" = "Write" ] || exit 0

[ -z "$FILE_PATH" ] && exit 0

# 메모리 경로 패턴 매칭 (.claude/projects/.../memory/...)
IS_MEMORY=0
case "$FILE_PATH" in
  */.claude/projects/*/memory/*.md) IS_MEMORY=1 ;;
esac

[ "$IS_MEMORY" = "0" ] && exit 0

# MEMORY.md 인덱스 자체는 통과 (인덱스는 사람 기준 메모리 목록 — 룰성 본문 X)
case "$FILE_PATH" in
  */memory/MEMORY.md) exit 0 ;;
esac

CONTENT="$(extract_content)"
[ -z "$CONTENT" ] && exit 0

# 화이트리스트 검사 우선 — 사람 기준 메모리 키워드 매칭 시 통과
if echo "$CONTENT" | grep -E "(본인|내[[:space:]]+(역할|R&R|KPI|일일보고|업무|PRJ|결정|호칭|부서|상사)|차민수|cjrain)" > /dev/null 2>&1; then
  # 사람 기준 메모리로 인정 → 통과
  exit 0
fi

# 룰성 본문 키워드 검출
RULE_HITS=""
if echo "$CONTENT" | grep -E "(전[[:space:]]*사용자|범용[[:space:]]*룰|운영[[:space:]]*워크플로우|매번|의무|표준|일관|강제|배포[[:space:]]*사용자)" > /dev/null 2>&1; then
  RULE_HITS="$(echo "$CONTENT" | grep -nE "(전[[:space:]]*사용자|범용[[:space:]]*룰|운영[[:space:]]*워크플로우|매번|의무|표준|일관|강제|배포[[:space:]]*사용자)" | head -5 || true)"
fi

if [ -n "$RULE_HITS" ]; then
  cat >&2 <<EOF
🚫 [memory-rule-content-block] 메모리에 룰성 본문 감지 — Write 차단
    파일: $FILE_PATH
    학습 #11 — 메모리 한정 (사람 기준만)
    - 메모리 허용: 차민수 본인 역할·호칭 / 본인 부서 사람 매핑 / 본인 PRJ 비전·KPI / 본인 일일보고 메타
    - 메모리 금지: 범용 워크플로우·운영 룰·도구 사용법·범용 매핑·자비스 학습 룰
    SSoT: 규칙/프로세스/자비스-운영-룰.md §2 학습 #11 + §6.2
    감지 본문 라인:
$RULE_HITS
    → 룰성 본문은 douzone-forge/규칙/프로세스/ SSoT 로 이전. 메모리에는 포인터 스텁만 잔존.
    배포 사용자(SBUnit 21명 + 사내 4,157명)에게 부재할 룰을 메모리에 두면 격차 발생.
EOF
  exit 2
fi

exit 0
