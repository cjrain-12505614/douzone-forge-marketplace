#!/usr/bin/env bash
# Phase R R-01 — Phase Q 새 구조 자동 인지
# PreToolUse Write/Edit hook
# 옛 경로 패턴 사용 시도 시 stderr 경고
# 정책: rules/phase-q-structure.md

# 입력: stdin JSON { "tool_input": { "file_path": "..." } } — 표준 훅 프로토콜 (v1.11.2 전환)
#   (선재 결함: 종전엔 CLAUDE_FILE_PATH env/$1만 읽어 배선돼 있어도 경로가 항상 비어 조용히 무발동이었음.
#    env/$1은 수동 호출·테스트 하위 호환용 폴백으로 유지.)
FILE_PATH="${CLAUDE_FILE_PATH:-${1:-}}"
if [ -z "$FILE_PATH" ] && [ ! -t 0 ]; then
  INPUT_JSON="$(cat || true)"
  if command -v jq >/dev/null 2>&1; then
    FILE_PATH="$(echo "$INPUT_JSON" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")"
  else
    FILE_PATH="$(echo "$INPUT_JSON" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"'       | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)".*//')"
  fi
fi
[ -z "$FILE_PATH" ] && exit 0

# archive·.bak 영역 보호 (역사 보존)
case "$FILE_PATH" in
  */_archive/*|*/99_archive/*|*.bak.*) exit 0 ;;
esac

WARN=0
PATTERN=""

# 옛 경로 패턴 12개 매칭 (+ 시스템 경로 제외 1)
case "$FILE_PATH" in
  */.claude/projects/*) : ;;  # Claude 시스템 경로(메모리 등) — 옛 경로 아님, 검사 제외 (v1.11.2)
  */_CLAUDE/*) WARN=1; PATTERN="_CLAUDE/ → 규칙/" ;;
  */_projects/*) WARN=1; PATTERN="_projects/ → 프로젝트/" ;;
  */projects/*) WARN=1; PATTERN="projects/ → 프로젝트/ (R14 — v1.11.1 잔존 33파일 교정 재발 방지)" ;;
  */reference/*) WARN=1; PATTERN="reference/ → 참고자료/" ;;
  */modules/*) WARN=1; PATTERN="modules/ → Amaranth10/" ;;
  */deliverables/*) WARN=1; PATTERN="deliverables/ → 분배 폐기 (Q-2 Q-13)" ;;
  */meta/repo-check/*) WARN=1; PATTERN="meta/repo-check/ → GitCheck/" ;;
  */meta/reports/*) WARN=1; PATTERN="meta/reports/ → 참고자료/리포트/" ;;
  */meta/sessions/*) WARN=1; PATTERN="meta/sessions/ → _개인/sessions/공통/" ;;
  */team-tracking/*) WARN=1; PATTERN="team-tracking/ → _개인/팀트래킹/ (Q-2 Q-14)" ;;
esac

# 모듈 한글명 단독 prefix (Amaranth10/ 누락) — 한글 모듈명 직접 시작
case "$FILE_PATH" in
  */법무관리\(LTE\)/history/*|*/CRM/history/*|*/게시판\(BOARD\)/history/*) WARN=1; PATTERN="모듈 한글명 단독 → Amaranth10/{모듈}/" ;;
  */업무관리\(KISS\)/history/*|*/통합연락처\(AB\)/history/*) WARN=1; PATTERN="모듈 한글명 단독 → Amaranth10/{모듈}/" ;;
esac

# 옛 문서/0X_* 패턴 (Q-1 Q-07 폐기)
case "$FILE_PATH" in
  */문서/01_신규/*|*/문서/02_삭제가능/*|*/문서/03_장기참조/*) WARN=1; PATTERN="문서/0X_* → Amaranth10/{모듈}/_분석문서/" ;;
esac

if [ "$WARN" = "1" ]; then
  echo "⚠️  Phase Q 옛 경로 패턴 사용: $FILE_PATH" >&2
  echo "    정정: $PATTERN" >&2
  echo "    상세: rules/phase-q-structure.md" >&2
fi
exit 0
