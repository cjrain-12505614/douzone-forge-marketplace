#!/bin/bash
# Hook: folder-structure-check
# Trigger: PostToolUse (Write, Edit)
# Purpose: 워크스페이스 폴더 구조 표준 자동 검출 — WARNING 만 (block 안 함)
#
# 검출 영역:
#   1. 워크스페이스 루트 신규 폴더 (정본 루트 = 공용 7 + _ 영역 3, + .bak.* 외) — 룰 1
#   2. `_개인/{사번}/` 형식 사번 prefix (B[0-9]+ 또는 숫자만, 정합 `이름_사번/` 형식 제외) — 룰 4
#
# 입력: stdin JSON
#   { "tool_name": "...", "tool_input": { "file_path": "..." } }
# 동작: block 하지 않음. stderr 경고만 (exit 0).
#
# 본 hook 본문은 prj-code-naming-check.sh + answer-tone-check.sh 패턴 일관 (의제 ❶ A 채택).
# 본 SSoT: 규칙/프로세스/워크스페이스-폴더-구조-표준.md

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

# 룰 4 — `_개인/{사번}/` 사번 prefix 검출 (정합 `_개인/이름_사번/` 형식 제외)
# 매칭 패턴: /_개인/B숫자/ 또는 /_개인/숫자만/
# 미매칭 (정합): /_개인/이름_사번/ — `_` 포함 형식은 정합
if [[ "$FILE_PATH" =~ /_개인/(B?[0-9]+)/ ]]; then
  cat >&2 <<EOF
⚠️  [folder-structure-check] 사번 prefix 검출 (룰 4 — 사번 prefix 미사용)
    파일: $FILE_PATH
    매칭: ${BASH_REMATCH[1]}
    → \`_개인/\` 본문 직접 사용 (각 사용자 로컬 본인 영역, 사번별 격리 불필요).
    → 정합 형식: \`조직/{본부}/{Unit}/{Cell}/{이름}_{사번}/\` (\`조직/\` 메타 영역만 — 보강 3)
    → 본 SSoT: 규칙/프로세스/워크스페이스-폴더-구조-표준.md §2 룰 4
EOF
fi

# 룰 1 — 워크스페이스 루트 신설 폴더 정합 검출
# 정본 루트: Amaranth10 · GitCheck · deliverables · 규칙 · 참고자료 · 프로젝트 · 조직 (공용 7) + _개인 · _분석요청문서 · _운영 (_ 영역 3)
# .bak.* 패턴: 변천사 보존 영역
if [[ "$FILE_PATH" =~ /douzone-forge/([^/]+)/ ]]; then
  ROOT_FOLDER="${BASH_REMATCH[1]}"
  case "$ROOT_FOLDER" in
    Amaranth10|GitCheck|deliverables|규칙|참고자료|프로젝트|조직|_개인|_분석요청문서|_운영)
      # 정본 루트 — 공용 7 + _ 영역 3 (2026-05-22 실측 정본화)
      ;;
    *.bak.*)
      # .bak.* 패턴 — 변천사 보존 정합
      ;;
    法무관리|법무관리)
      # 옛 모듈 잔존 (Step 3 이관 후) — 본 SSoT §7.1 후속 인계 명시
      cat >&2 <<EOF
⚠️  [folder-structure-check] 옛 모듈 잔존 검출 (룰 1·룰 3 — \`법무관리/\` 루트 잔존)
    경로: $FILE_PATH
    → Step 3 이관 후 옛 위치 잔존. 정합 위치: \`Amaranth10/법무관리(LTE)/\`
    → 본 SSoT: 규칙/프로세스/워크스페이스-폴더-구조-표준.md §7.1 후속 정합화 인계
EOF
      ;;
    *)
      cat >&2 <<EOF
⚠️  [folder-structure-check] 워크스페이스 루트 정합 외 폴더 검출 (룰 1)
    경로: $FILE_PATH
    폴더: $ROOT_FOLDER
    → 영문 골격 3 (Amaranth10·GitCheck·deliverables) + 한글 정합 3 (규칙·참고자료·프로젝트) + 조직 (공용 7) + _ 영역 3 (_개인·_분석요청문서·_운영) 외 신규 검토.
    → 본 SSoT: 규칙/프로세스/워크스페이스-폴더-구조-표준.md §2 룰 1
EOF
      ;;
  esac
fi

exit 0
