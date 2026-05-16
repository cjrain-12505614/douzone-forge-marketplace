#!/usr/bin/env bash
# output-registry-update.sh — 산출물 .md Write/Edit 시 산출물 레지스트리 자동 갱신
# PostToolUse Write|Edit hook
# 산출물 관리 체계 (Obsidian x LLM 위키 연결) — douzone-forge 전용
#
# 산출물이 생성·수정되면 _개인/산출물-레지스트리.md 에 경로 키로 행을 upsert(갱신·삽입)한다.

FILE_PATH="${CLAUDE_FILE_PATH:-$1}"
[ -z "$FILE_PATH" ] && exit 0

WORKSPACE="/Users/cjrain/Workspace/douzone-forge"
REGISTRY="$WORKSPACE/_개인/산출물-레지스트리.md"

# douzone-forge 워크스페이스 .md 만 대상
case "$FILE_PATH" in
  "$WORKSPACE"/*) ;;
  *) exit 0 ;;
esac
case "$FILE_PATH" in
  *.md) ;;
  *) exit 0 ;;
esac
[ -f "$REGISTRY" ] || exit 0
[ -f "$FILE_PATH" ] || exit 0

# ── 제외 판정 (백필 스크립트와 동일 기준) ──
case "$FILE_PATH" in
  *.bak.*|*/_archive/*|*/99_archive/*|*/GitCheck/*|*/.obsidian/*) exit 0 ;;
esac
case "$(basename "$FILE_PATH")" in
  ._*|CLAUDE.md|INDEX.md|_dashboard.md|_index.md|_timeline.md|_current.md) exit 0 ;;
  산출물-레지스트리.md|산출물-홈.md) exit 0 ;;
esac

# ── 메타 추정 함수 ──
guess_type() { case "$1" in
  *검토안*)                              echo "검토안" ;;
  *작업지시서*|*지시서*)                  echo "작업지시서" ;;
  *완료보고서*|*결과서*|*종착보고서*)      echo "결과서" ;;
  *계획서*|*계획.md|*로드맵*)              echo "계획서" ;;
  */context/*)                           echo "context" ;;
  */history/*|*/meetings/*)              echo "history" ;;
  *기능*스펙*|*feature-spec*|*기능소개서*) echo "기능스펙" ;;
  */AI트렌드/*)                          echo "트렌드" ;;
  *회의*)                                echo "회의록" ;;
  *조사*|*분석*)                          echo "분석문서" ;;
  *)                                     echo "기타" ;;
esac; }

guess_area() {
  local prj
  prj=$(printf '%s' "$1" | grep -oE 'PRJ-[0-9]{4}(-[A-Z]+)?-[0-9]+' | head -1)
  if [ -n "$prj" ]; then printf '%s' "$prj"; return; fi
  case "$1" in
    */Amaranth10/*) printf '%s' "$1" | sed -E 's#.*/Amaranth10/([^/]+)/.*#\1#' ;;
    *)              printf '공통' ;;
  esac
}

guess_created() {
  local b d
  b=$(basename "$1"); d=$(printf '%s' "$b" | grep -oE '[0-9]{8}' | head -1)
  if [ -n "$d" ]; then
    printf '%s-%s-%s' "${d:0:4}" "${d:4:2}" "${d:6:2}"
  else
    stat -f '%Sm' -t '%Y-%m-%d' "$1" 2>/dev/null || date '+%Y-%m-%d'
  fi
}

# ── 머리말 값 우선 읽기 ──
read_fm() {
  if [ "$(head -1 "$1" 2>/dev/null)" = "---" ]; then
    awk -v k="$2" 'NR==1{next} /^---[[:space:]]*$/{exit} {if($0 ~ "^"k":"){sub("^"k":[[:space:]]*","");print;exit}}' "$1"
  fi
}

rel="${FILE_PATH#"$WORKSPACE"/}"
name=$(basename "$FILE_PATH" .md)
TYPE=$(read_fm "$FILE_PATH" type);     [ -z "$TYPE" ]    && TYPE=$(guess_type "$FILE_PATH")
AREA=$(read_fm "$FILE_PATH" area);     [ -z "$AREA" ]    && AREA=$(guess_area "$FILE_PATH")
CREATED=$(read_fm "$FILE_PATH" created);[ -z "$CREATED" ] && CREATED=$(guess_created "$FILE_PATH")
STATUS=$(read_fm "$FILE_PATH" status); [ -z "$STATUS" ]  && STATUS="작성중"
MODIFIED=$(stat -f '%Sm' -t '%Y-%m-%d' "$FILE_PATH" 2>/dev/null || date '+%Y-%m-%d')

enc=$(printf '%s' "$rel" | sed 's/ /%20/g; s/(/%28/g; s/)/%29/g; s/\[/%5B/g; s/\]/%5D/g')
new_row="| $MODIFIED | $CREATED | $name | [$rel]($enc) | $TYPE | $AREA | $STATUS |"

# ── upsert — 구분선(|---) 기준 헤더/데이터 분리 후 재정렬 ──
sep=$(grep -n '^|---' "$REGISTRY" | head -1 | cut -d: -f1)
[ -z "$sep" ] && exit 0

tmp=$(mktemp)
{
  head -n "$sep" "$REGISTRY"
  {
    echo "$new_row"
    tail -n +$((sep+1)) "$REGISTRY" | grep -vF "]($enc) |"
  } | sort -t'|' -k2,2 -r
} > "$tmp" && mv "$tmp" "$REGISTRY"

echo "📇 산출물 레지스트리 갱신: $rel ($TYPE / $AREA)" >&2
exit 0
