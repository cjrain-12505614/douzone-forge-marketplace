#!/usr/bin/env bash
# douzone-forge — 강제 작업 수행 원칙 매 턴 주입 훅 (force-rules-inject)
#
# 목적:
#   매 입력(UserPromptSubmit)마다 "작업수행 강제원칙 4대"를 맥락에 주입해, 전 임직원이
#   세션당 1회(CLAUDE.md)를 넘어 **턴당 1회**로 원칙을 강화 적용받게 한다.
#
# 설계(왜 플러그인 + 동기화 파일인가):
#   - 메커니즘(매 턴 출력하는 훅) = 플러그인이 제공 → 설치/업데이트만으로 전 직원 자동 배선.
#   - 내용(출력할 원칙) = forge의 동기화되는 규칙 파일에서 읽음 → GitLab 동기화만으로 갱신 전파
#     (내용을 고쳐도 플러그인 재배포 불필요). 압축본 전환도 그 파일 1곳만 수정.
#   - 과거 로컬 전용(.claude/, gitignore)이라 전사 미전파였던 한계를 해소.
#
# 내용 SSoT(단일 출처): 규칙/프로세스/강제규칙-주입.md (동기화 대상)
#   원칙 본문 SSoT: 규칙/프로세스/작업수행-강제원칙.md
#
# 안전:
#   - 파일이 없어도 조용히 통과(프롬프트를 막지 않음). 항상 exit 0.
set -uo pipefail

DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# 1순위: 동기화 내용 파일(규칙/프로세스) · 2순위(폴백): 구 로컬 파일(.claude)
SYNCED="$DIR/규칙/프로세스/강제규칙-주입.md"
LEGACY="$DIR/.claude/강제규칙-주입.md"

if [ -f "$SYNCED" ]; then
  cat "$SYNCED" 2>/dev/null || true
elif [ -f "$LEGACY" ]; then
  cat "$LEGACY" 2>/dev/null || true
fi

exit 0
