#!/bin/bash
# _forge-gate.sh — 개발자 하네스 비강제 게이트 판정 (H3, 2026-06-23)
#
# 목적: 코드 편집 리마인더 훅(code-quality·security·build-verify)을
#       "하네스를 켠 사람만" 동작시키는 스위치. source 로 호출.
#       함수 forge_gate_on 이 0(켜짐) / 1(꺼짐) 을 반환한다.
#
# 켜짐 판정 (H-1 결정 = 둘 다):
#   1) 환경변수 override 우선
#        FORGE_DEV_HOOKS=1|on|true|yes  → 강제 켜짐
#        FORGE_DEV_HOOKS=0|off|false|no → 강제 꺼짐
#   2) env 미설정이면 _forge 심링크 자동 감지
#        편집 파일 경로($1 또는 $CLAUDE_FILE_PATH)의 디렉토리부터 상위로
#        올라가며 '_forge' 심링크(브리지 마커)가 있으면 켜짐.
#   3) 아무 신호도 없으면 꺼짐 → 호출 훅이 무음 통과(exit 0).
#
# db-migration-guard 는 이 게이트로 묶지 않는다(H-4: 안전 가드라 기본 차단 유지).
#
# 의존 SSoT: 규칙/프로세스/forge-bridge/ (브리지가 _forge 심링크 생성)
#            참고자료/리포트/2026-06-20-개발자하네스-설계안.md §3 3단계

forge_gate_on() {
  local f="${1:-${CLAUDE_FILE_PATH:-}}"

  # 1) 환경변수 override
  case "${FORGE_DEV_HOOKS:-}" in
    1|on|ON|true|TRUE|yes|YES)      return 0 ;;
    0|off|OFF|false|FALSE|no|NO)    return 1 ;;
  esac

  # 2) _forge 심링크 상향 탐색
  [ -n "$f" ] || return 1
  local dir
  dir="$(cd "$(dirname "$f")" 2>/dev/null && pwd)" || return 1
  while [ -n "$dir" ] && [ "$dir" != "/" ]; do
    [ -L "$dir/_forge" ] && return 0
    dir="$(dirname "$dir")"
  done

  # 3) 신호 없음 → 꺼짐
  return 1
}
