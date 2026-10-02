#!/bin/bash
# Hook: prj-code-naming-check
# Trigger: PostToolUse (Write, Edit)
# Purpose: 마크다운 편집 후 PRJ 코드 단독 표기(프로젝트명 미동반) 자동 감지 + 경고
#
# 입력: stdin JSON
#   { "tool_name": "...", "tool_input": { "file_path": "..." } }
# 동작: block 하지 않음. stderr 경고만 (exit 0)
#
# 판정 (각 PRJ 코드 출현 위치별):
#   ✅ OK: 직전 문자가 '(' → "프로젝트명(PRJ-...)" 형태
#   ✅ OK: '](' 와 '.md)' 사이에 위치 → 링크 URL/파일명 부분
#   ✅ OK: 파일명 형태(`PRJ-....md`) — 전체 토큰이 파일명
#   ❌ 경고: 위 조건 외 단독 출현

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

# perl 필수 (정규식 lookbehind/lookahead 정확성)
command -v perl >/dev/null 2>&1 || exit 0

violations="$(perl -ne '
  BEGIN { $in_code = 0; }
  # 코드블록 토글
  if (/^```/) { $in_code = 1 - $in_code; next; }
  next if $in_code;
  # frontmatter 내부(최상단 --- 사이) 스킵은 단순화상 생략

  my $line_no = $.;
  my $line = $_;
  chomp $line;

  # PRJ 코드 모든 출현 위치 검사
  while ($line =~ /(PRJ-\d{4}(?:-[A-Z]+)?-\d+)/g) {
    my $end = pos($line);
    my $match = $1;
    my $start = $end - length($match);
    my $before = substr($line, 0, $start);
    my $after  = substr($line, $end);

    # 케이스 A: 직전 문자가 "(" → 프로젝트명(PRJ-...) 형태 — OK
    next if $before =~ /\($/;

    # 케이스 B: 링크 URL 내부 — "](" 뒤~ ")" 전 사이
    # before 에 "](" 가 있고, 그 이후 ")" 가 아직 안 닫혔는가?
    if ($before =~ /\]\(([^)]*)$/) {
      # 링크 URL 내부 → OK (파일명/경로)
      next;
    }

    # 케이스 C: 파일명 형태 (PRJ-....md 또는 PRJ-..._이름.md)
    if ($after =~ /^(?:_[^\s)]*)?\.md/) {
      # 단, 링크 밖에서 본문에 직접 노출된 파일명도 단독 표기로 간주
      # before 에 "[" 가 아직 안 닫혔으면 링크 표시텍스트 내부 가능성 있음 → 한글 동반 검사
      if ($before =~ /\[([^\]]*)$/) {
        my $link_text = $1;
        # 링크 표시텍스트에 한글 또는 영문 프로젝트명 포함 여부
        # 최소 3자 이상의 단어 또는 한글 1자 이상
        if ($link_text =~ /[가-힣]/ || $link_text =~ /[A-Za-z]{3,}/) {
          next; # OK
        }
      }
      # 링크 밖 단독 파일명 언급 → 경고 대상
    }

    # 케이스 D: 마크다운 링크 전체가 "[표시텍스트](...PRJ-...)" 형태에서
    # 표시텍스트에 프로젝트명이 있는가? — before 를 거꾸로 올라가 "[" 찾기
    if ($before =~ /\[([^\[\]]*)\]\([^)]*$/) {
      my $display = $1;
      if ($display =~ /[가-힣]/ || $display =~ /[A-Za-z]{3,}/) {
        next;
      }
    }

    # 그 외 — 위반
    (my $trimmed = $line) =~ s/^\s+//;
    $trimmed = substr($trimmed, 0, 120);
    print "  L${line_no} [$match]: $trimmed\n";
    last; # 한 라인에 여러 위반 있어도 1건만 출력
  }
' "$FILE_PATH")"

if [[ -n "$violations" ]]; then
  cat >&2 <<EOF
⚠️  [prj-code-naming] PRJ 코드 단독 표기 의심 (프로젝트명 미동반)
    파일: $FILE_PATH
    규칙: rules/prj-code-naming.md — 허용: "프로젝트명(PRJ-YYYY-NNN)" 또는 "[프로젝트명(PRJ-...)](...)"
    의심 라인:
$violations
    → 프로젝트명 병기로 교정 검토. (block 하지 않음, 알림 전용)
EOF
fi

exit 0
