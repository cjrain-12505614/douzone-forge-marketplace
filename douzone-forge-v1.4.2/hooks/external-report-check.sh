#!/bin/bash
# external-report-check.sh — 외부 보고 영역 워크스페이스 코드 자동 검출 Hook
#
# 의도: 외부 보고 영역 본문 작성 시 워크스페이스 내부 코드 (W-N·D-NN·AC-N·R8 등) 자동 검출 + 일반 용어 매핑 권고 출력
# 발효: 2026-05-14 (PRJ-2026-014 외부 보고 작성 표준 정착 사이클 산출)
# 의존 SSoT: 규칙/프로세스/외부-보고-작성-표준.md §2 회피 매트릭스
# 적용 영역: 외부 보고 본문 영역 (사내 ONEFFICE·메일·외부 회의 자료 등) — 본 워크스페이스 내부 본문 영역은 적용 외 영역

set -euo pipefail

# stdin 영역 — 검사 대상 본문
TARGET_TEXT="${1:-$(cat 2>/dev/null || echo '')}"

# 빈 본문 영역 회피
if [ -z "$TARGET_TEXT" ]; then
    exit 0
fi

# 검출 정규식 영역 (8 영역)
W_PATTERN='\bW-[0-9]+\b'
DGSMC_PATTERN='\b[DGSMC]-[0-9]+\b'
AC_PATTERN='\bAC-[0-9]+\b'
R8_PATTERN='\bR8\b'
RC_PATTERN='\brc\.[0-9]+\b'
SSOT_PATTERN='\bSSoT\b'
HOOK_PATTERN='\bHook\b'
AGENT_PATTERN='\b(CIPHER|MATRIX|VECTOR|TRACE|PROBE|LAUNCH|CORE|NOVA|WEAVER|PRISM|ORACLE|SYNAPSE|AEGIS|HELM|AVATAR|NEXUS)\b'

DETECTED=()

for pattern in "$W_PATTERN" "$DGSMC_PATTERN" "$AC_PATTERN" "$R8_PATTERN" "$RC_PATTERN" "$SSOT_PATTERN" "$HOOK_PATTERN" "$AGENT_PATTERN"; do
    if echo "$TARGET_TEXT" | grep -qE "$pattern"; then
        DETECTED+=("$pattern")
    fi
done

if [ ${#DETECTED[@]} -gt 0 ]; then
    cat >&2 <<EOF
[external-report-check] 외부 보고 영역 워크스페이스 코드 검출
    외부 영역 본문에 본 워크스페이스 내부 코드 영역 포함 — 일반 용어 매핑 권고

    검출 영역:
$(printf '        %s\n' "${DETECTED[@]}")

    매핑 권고:
        W-N → "이번 주" / 일자 직접 표기
        D-NN/G-NN/S-NN → 작업 항목 정식 명칭 직접 표기
        AC-N → "합격 기준 N건"
        R8 → "예상 시간" / "투입 시간"
        rc.NN → 일자 또는 버전 영역
        SSoT → "표준 정의서" / "기준 문서"
        Hook → "자동 검출 영역"
        CIPHER/MATRIX/... → 직군 영역 (분석 담당·설계 담당 등)

    SSoT: 규칙/프로세스/외부-보고-작성-표준.md
EOF
    # WARNING only — block 안 함
fi

exit 0
