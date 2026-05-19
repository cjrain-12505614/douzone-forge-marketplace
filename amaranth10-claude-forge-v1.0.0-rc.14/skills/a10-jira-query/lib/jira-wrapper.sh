#!/usr/bin/env bash
# a10-jira-query — 공통 헬퍼 (수집기 디렉토리 탐색 + 선결 조건 검증)
# 스킬 본문에서 `source` 또는 참고용으로 사용. .env 내용은 절대 읽지 않음.

set -euo pipefail

# 1. 수집기 디렉토리 결정 (환경변수 우선, 없으면 기본 경로)
resolve_collector_dir() {
  echo "${JIRA_COLLECTOR_DIR:-$HOME/Workspace/amaranth10-workspace/_workspace/jira}"
}

# 2. 선결 조건 검증 — 4단계
verify_collector_installed() {
  local dir="$1"

  [ -d "$dir" ] \
    || { echo "[a10-jira] 수집기 디렉토리 없음: $dir"; return 1; }

  [ -f "$dir/.env" ] \
    || { echo "[a10-jira] .env 파일 없음: $dir/.env"; return 1; }

  [ -x "$dir/scripts/fetch-issues.sh" ] \
    || { echo "[a10-jira] fetch-issues.sh 실행 권한 없음"; return 1; }

  # .env 내용은 grep -q 로 존재 여부만 체크 (값 출력 금지)
  if ! grep -q "^JIRA_MODULE_FIELD_ID=customfield_" "$dir/.env"; then
    echo "[a10-jira] 🟡 JIRA_MODULE_FIELD_ID 미설정 — --find-field 모듈 필요"
  fi

  return 0
}

# 3. 한글 JQL 필드명 쌍따옴표 선검증
validate_jql_korean_fields() {
  local jql="$1"
  # "모듈" 처럼 쌍따옴표로 감싸지 않은 한글 필드가 있는지 탐지
  # 한글 문자열 뒤에 = / != / in / ~ 등 JQL 연산자가 붙으면 필드명으로 간주
  if echo "$jql" | grep -qE '(^|[^"])[가-힣]+[[:space:]]*(=|!=|~|in|not in)'; then
    cat <<EOF
🔴 JQL 문법 오류 — 한글 필드명은 반드시 쌍따옴표로 감싸야 합니다.
  예: project = CSA10 AND "모듈" = 업무관리
EOF
    return 1
  fi
  return 0
}

# 4. 오늘자 수집 폴더 존재 확인
today_output_exists() {
  local dir="$1"
  [ -d "$dir/output/$(date +%F)" ]
}

# 5. 허용 모듈 목록 체크
is_allowed_module() {
  local module="$1"
  case "$module" in
    연락처|게시판|업무관리|법무관리|CRM|_unmapped) return 0 ;;
    *) return 1 ;;
  esac
}
