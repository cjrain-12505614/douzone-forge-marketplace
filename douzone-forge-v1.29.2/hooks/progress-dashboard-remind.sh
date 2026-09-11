#!/usr/bin/env bash
# Trigger: UserPromptSubmit
# Tools: — (프롬프트 이벤트 — 도구 매처 없음)
# Purpose: 매 입력마다 진행 대시보드(dz-progress-dashboard) 발동 판단 환기 1줄 주입 — 3중 상시 인지의 셋째 다리
# SSoT: douzone-forge/CLAUDE.md 「진행 대시보드 운영」 + skills/dz-progress-dashboard/SKILL.md (설계 근거: 참고자료/리포트/2026-06-01-dz-progress-dashboard-스킬설계안.md §11.8)
#
# 배경(v1.13.0 신설 — 2026-07-09):
#   3중 상시 인지(CLAUDE.md·스킬·매 입력 환기) 중 셋째 다리가 v1.3.0(2026-06-01) 당시
#   워크스페이스 로컬(.claude/진행대시보드-환기.md + settings.json 두 번째 cat)로만 구현돼
#   gitignore(.claude/ 전체 제외) 영역에서 조용히 소실 → 대시보드 상시 미발동
#   (진단: douzone-forge 참고자료/리포트/2026-07-09-진행대시보드-환기훅-소실-진단.md).
#   본 훅은 force-rules-inject 패턴(플러그인=메커니즘)으로 승격하되, **기본 문구를 스크립트에
#   내장**해 외부 파일 부재 시에도 절대 침묵하지 않는다(소실 사고 구조적 재발 방지).
#
# 내용 우선순위:
#   1순위: 규칙/프로세스/진행대시보드-환기.md (동기화 파일 — 존재 시 문구 교체를 재배포 없이 전파)
#   2순위(기본): 아래 내장 1줄
#
# 안전: 읽기 전용 · 항상 exit 0 (프롬프트를 막지 않음).
set -euo pipefail

DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SYNCED="$DIR/규칙/프로세스/진행대시보드-환기.md"

if [ -f "$SYNCED" ]; then
  cat "$SYNCED" 2>/dev/null || true
else
  echo '[진행 대시보드 환기] 이번 작업이 신호 3개 이상(단계 3개+ · 다영역/다파일 · 장시간·다세션 · 산출물 다수 · "복잡" 언급)이면 dz-progress-dashboard 자동 발동을 검토할 것 — 상위 대시보드가 있으면 신규 생성 없이 그 항목만 갱신, 켤 때 "대시보드로 추적하겠습니다" 1줄 고지.'
fi

exit 0
