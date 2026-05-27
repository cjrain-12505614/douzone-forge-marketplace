#!/bin/bash
# commit-message-check.sh — 커밋 메시지 표준 검출 Hook (2차 사이클 의제 5)
#
# 의도: 커밋 메시지 `[PRJ-NNNN/TASK-CODE]` 프리픽스 의무 검출 + AI 활용 표기 (D2) 강제
# 발효: 2026-05-14 (PRJ-2026-014 W-3 2차 사이클 의제 5 신설)
# 의존 SSoT: 규칙/프로세스/깃-커밋-메시지-규약.md

set -euo pipefail

# stdin 영역 — commit message 본문
COMMIT_MSG="${1:-$(cat 2>/dev/null || echo '')}"

# 빈 본문 영역 회피
if [ -z "$COMMIT_MSG" ]; then
    exit 0
fi

# 첫 줄 영역 추출 (메인 제목 영역)
FIRST_LINE=$(echo "$COMMIT_MSG" | head -n 1)

# 1. [PRJ-NNNN/TASK-CODE] 프리픽스 검출
PRJ_PREFIX_PATTERN='^\[PRJ-[0-9]{4}(-[A-Z]+)?-[0-9]+(/[A-Z]+-[0-9]+)?\]'
PRJ_PLAIN_PATTERN='^\[PRJ-[0-9]{4,}'

if ! echo "$FIRST_LINE" | grep -qE "$PRJ_PLAIN_PATTERN"; then
    cat >&2 <<EOF
⚠️  [commit-message-check] 커밋 메시지 표준 위반
    PRJ 프리픽스 누락 — \`[PRJ-NNNN/TASK-CODE]\` 형식 의무

    현재 메시지:
        $FIRST_LINE

    권고 패턴:
        [PRJ-2026-014/W-3] 본문 영역
        [PRJ-2026-014/W-3-M-02] 세부 영역

    SSoT: 규칙/프로세스/깃-커밋-메시지-규약.md
EOF
    # WARNING only — block 안 함
fi

# 2. AI 활용 표기 (D2) 검출
AI_TAG_PATTERN='Co-Authored-By:|AI:|Claude:|🤖'
if ! echo "$COMMIT_MSG" | grep -qE "$AI_TAG_PATTERN"; then
    cat >&2 <<EOF
⚠️  [commit-message-check] AI 활용 표기 누락 (D2)
    Co-Authored-By 또는 AI 영역 표기 권고

    권고:
        Co-Authored-By: Claude Code <noreply@anthropic.com>
EOF
fi

exit 0
