#!/usr/bin/env bash
# Phase R+ R-06 — 링크 무결성 즉시 탐지
# PostToolUse Write/Edit on *.md
# 단일 파일 점검 (전수 X) — Write 직후 해당 .md만 검사

# v1.19.0: stdin JSON(tool_input.file_path) 우선 — 죽은 환경변수(CLAUDE_FILE_PATH) 단독 의존이
# 만든 영구 무발동 수복 (v1.14.1 교정 3종에서 누락됐던 훅. 2026-07-28 링크 17건 장기 잔존 실사고 배경)
INPUT_JSON="$(cat 2>/dev/null || true)"
FILE_PATH=""
if [ -n "$INPUT_JSON" ]; then
  if command -v jq >/dev/null 2>&1; then
    FILE_PATH="$(printf '%s' "$INPUT_JSON" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
  else
    FILE_PATH="$(printf '%s' "$INPUT_JSON" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*:[[:space:]]*"([^"]*)".*/\1/')"
  fi
fi
[ -z "$FILE_PATH" ] && FILE_PATH="${CLAUDE_FILE_PATH:-${1:-}}"
[ -z "$FILE_PATH" ] && exit 0

# 비-마크다운 파일 스킵
case "$FILE_PATH" in
  *.md|*.MD) ;;
  *) exit 0 ;;
esac

# 보호 영역 스킵 (학습 #1 표준)
case "$FILE_PATH" in
  */_archive/*|*/99_archive/*|*.bak.*) exit 0 ;;
esac

# 파일 미존재 (삭제 직후 등) 스킵
[ -f "$FILE_PATH" ] || exit 0

# Python 깨진 링크 검출
python3 - "$FILE_PATH" <<'PYEOF'
import os, re, sys
from urllib.parse import unquote

LINK = re.compile(r'\[([^\]]*)\]\(([^)]+)\)')
broken = []
fp = sys.argv[1]
base = os.path.dirname(fp) or '.'

try:
    with open(fp, encoding='utf-8') as f:
        for ln, line in enumerate(f, 1):
            for m in LINK.finditer(line):
                p = m.group(2).split('#')[0].split('?')[0]
                if not p or p.startswith(('http://', 'https://', 'mailto:', '#')):
                    continue
                target = os.path.normpath(os.path.join(base, unquote(p)))
                if not os.path.exists(target):
                    broken.append((ln, p))
except Exception:
    sys.exit(0)

if broken:
    sys.stderr.write(f"⚠️  깨진 링크 검출: {fp}\n")
    for ln, p in broken[:5]:
        sys.stderr.write(f"    L{ln}: {p}\n")
    if len(broken) > 5:
        sys.stderr.write(f"    ... +{len(broken)-5}건\n")
    sys.stderr.write("    전수 확인: python3 규칙/프로세스/scripts/linkcheck.py active\n")
    sys.stderr.write("    (세션 시작 시 link-integrity-scan.sh 가 증가분을 자동 보고)\n")
PYEOF
exit 0
