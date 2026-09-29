#!/usr/bin/env bash
# dz-module-devenv — node-sass(네이티브) 로드 실패 시 dart-sass 폴백
#   Apple Silicon + Node16에서 node-sass 4.14.1은 prebuilt 없음(404)+소스컴파일 불가(V8헤더×clang,
#   번들 node-gyp 3.8.0 python2 요구)로 깨질 수 있다. node-sass를 옆으로 치우면
#   sass-loader 8이 require.resolve('node-sass') 실패 → 이미 설치된 dart-sass(sass)로 자동 폴백.
# 사용: bash fix-node-sass.sh [번들러루트]
set -uo pipefail
ROOT="${1:-$PWD}"
cd "$ROOT" || { echo "!! 경로 없음: $ROOT"; exit 1; }

if node -e "require('node-sass')" >/dev/null 2>&1; then
  echo "node-sass 정상 로드 — 변경 없음(폴백 불요)"; exit 0
fi
if [ ! -d node_modules/sass ]; then
  echo "!! node-sass 깨짐 + dart-sass(sass) 미설치 → 폴백 불가. 'yarn add -W sass' 후 재시도."; exit 1
fi

moved=0
while IFS= read -r d; do
  [ -z "$d" ] && continue
  mv "$d" "${d}.broken" && { echo "  [move] $d → .broken"; moved=1; }
done < <(find . -type d -name node-sass -not -path "*/node-sass/node_modules/*" 2>/dev/null)
[ "$moved" = 0 ] && echo "  (이동 대상 node-sass 없음)"

if node -e "require('node-sass')" >/dev/null 2>&1; then
  echo "⚠️ node-sass가 아직 resolve됨(다른 위치 잔존) — 추가 확인 필요"; exit 2
fi
ver=$(node -e "console.log(require('sass').info.split('\n')[0])" 2>/dev/null)
echo "✅ node-sass 비활성화 → sass-loader가 dart-sass 사용 (${ver:-dart-sass})"
