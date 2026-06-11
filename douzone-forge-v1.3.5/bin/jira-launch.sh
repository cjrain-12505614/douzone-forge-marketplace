#!/bin/bash
# douzone-forge 플러그인 동봉 jira-mcp 실행 launcher.
# 플러그인 설치 시 함께 배포되는 vendor/ 의 wheel 을 uvx 로 격리 실행한다(개발 venv 무관).
# 위치 기준 ../vendor 의 wheel 을 가리키므로 각 PC 의 플러그인 캐시 경로에 자동 적응.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WHEEL="$DIR/../vendor/jira_mcp-0.1.0-py3-none-any.whl"

# uvx(uv 도구 실행기) 위치 자동 탐색 — PATH 우선, 없으면 표준 설치 위치들
UVX="$(command -v uvx 2>/dev/null)"
if [ -z "$UVX" ]; then
  for c in "$HOME/.local/bin/uvx" "$HOME/.cargo/bin/uvx" /opt/homebrew/bin/uvx /usr/local/bin/uvx; do
    [ -x "$c" ] && UVX="$c" && break
  done
fi
[ -z "$UVX" ] && { echo "uvx(uv) 미설치 — https://astral.sh/uv 에서 uv 를 먼저 설치하세요" >&2; exit 1; }

exec "$UVX" --from "$WHEEL" jira-mcp "$@"
