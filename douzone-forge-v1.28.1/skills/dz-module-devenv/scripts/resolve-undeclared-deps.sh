#!/usr/bin/env bash
# dz-module-devenv — 미선언 워크스페이스 의존 연쇄 자동 해소
#   번들러(klago-ui-micro) 루트에서 실행. packages/·common/ 의 src가 import하지만
#   package.json에 선언 안 된 klago-/luna-/lux- 패키지를 찾아
#   ① common/에 클론(microfront→ui→KLAGO 순) ② import하는 패키지의 package.json에 "*" 선언 추가.
#   ②가 핵심: 선언이 있어야 config-overrides babelTargets(선언 * 재귀 수집)에 들어가 src JSX가 변환됨.
# 사용: bash resolve-undeclared-deps.sh [번들러루트]   (기본=현재 디렉터리)
set -uo pipefail
ROOT="${1:-$PWD}"
cd "$ROOT" || { echo "!! 경로 없음: $ROOT"; exit 1; }
[ -d packages ] || { echo "!! packages/ 없음 — 번들러 루트에서 실행하세요"; exit 1; }
mkdir -p common
GL="http://14.41.55.45:8089"
GROUPS=(microfront ui KLAGO)

avail() { (ls micro-common 2>/dev/null; ls common 2>/dev/null; ls packages 2>/dev/null; \
  ls node_modules 2>/dev/null | grep -iE '^(klago|luna|lux)-') | sort -u; }

clone_pkg() { # $1=패키지명
  local p="$1" g
  for g in "${GROUPS[@]}"; do
    if git ls-remote "$GL/$g/$p.git" HEAD >/dev/null 2>&1; then
      git clone "$GL/$g/$p.git" "common/$p" >/dev/null 2>&1 && { echo "  [clone] $p ($g)"; return 0; }
    fi
  done
  echo "  [clone-FAIL] $p — microfront/ui/KLAGO 어디에도 없음(이름 다를 수 있음, 수동 확인)"; return 1
}

add_star() { # $1=패키지디렉터리 $2=의존명  (추가했으면 exit 0, 아니면 exit 3)
  node -e '
    const fs=require("fs"); const p=process.argv[1], d=process.argv[2];
    const j=JSON.parse(fs.readFileSync(p,"utf8")); j.dependencies=j.dependencies||{};
    if(j.dependencies[d]===undefined){ j.dependencies[d]="*";
      fs.writeFileSync(p, JSON.stringify(j,null,2)+"\n"); process.exit(0); }
    process.exit(3);
  ' "$1/package.json" "$2"
}

for iter in $(seq 1 20); do
  A="$(avail)"; changed=0
  for d in packages/*/ common/*/; do
    [ -d "${d}src" ] || continue
    pj="${d}package.json"; [ -f "$pj" ] || continue
    own=$(grep -m1 '"name"' "$pj" 2>/dev/null | sed -E 's/.*"name" *: *"([^"]+)".*/\1/')
    imports=$(grep -rhoE "from ['\"](klago-[a-z0-9-]+|luna-[a-z0-9-]+|lux-[a-z0-9-]+)" "${d}src" 2>/dev/null \
      | sed -E "s/from ['\"]//" | sort -u)
    declared=$(grep -oE '"(klago-[a-z0-9-]+|luna-[a-z0-9-]+|lux-[a-z0-9-]+)" *:' "$pj" 2>/dev/null | sed -E 's/" *:.*//; s/"//')
    for imp in $imports; do
      [ -z "$imp" ] && continue
      [ "$imp" = "$own" ] && continue   # 자기 자신 import 제외
      if ! printf '%s\n' "$A" | grep -qx "$imp"; then
        clone_pkg "$imp" && { changed=1; A="$(avail)"; }
      fi
      if ! printf '%s\n' "$declared" | grep -qx "$imp"; then
        if add_star "${d%/}" "$imp"; then echo "  [decl] $imp → ${d%/}/package.json"; changed=1; fi
      fi
    done
  done
  if [ "$changed" = 0 ]; then echo "✅ 미선언/누락 의존 0 (반복 $iter) — 해소 완료"; exit 0; fi
done
echo "⚠️ 20회 반복 후에도 변동 — 순환/이름불일치 의심, 로그 확인"; exit 2
