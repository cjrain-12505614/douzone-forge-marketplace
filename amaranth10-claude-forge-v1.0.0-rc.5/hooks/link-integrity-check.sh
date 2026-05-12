#!/usr/bin/env bash
# Phase R+ R-06 — 링크 무결성 즉시 탐지
# PostToolUse Write/Edit on *.md
# 단일 파일 점검 (전수 X) — Write 직후 해당 .md만 검사

FILE_PATH="${CLAUDE_FILE_PATH:-$1}"
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
    sys.stderr.write(f"    상세: skills/a10-residual-audit (정기 점검)\n")
PYEOF
exit 0
