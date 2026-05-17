# 예시 — 애드혹 JQL

## 입력

```
/a10-jira --jql 'project = CSA10 AND "모듈" = 업무관리 AND created >= -14d'
```

## 핵심 규칙

- **한글 필드명 `"모듈"` 은 반드시 쌍따옴표** — JQL 문법 요구사항
- 담당자 조건은 자동 주입되므로 사용자가 `assignee in (...)` 를 쓸 필요 없음
- `$JIRA_COLLECTOR_DIR/.env` 의 `JIRA_ASSIGNEES` 가 자동으로 `AND assignee in (...)` 로 append

## 내부 동작

```bash
cd "$COLLECTOR_DIR" && ./scripts/fetch-issues.sh \
  --jql 'project = CSA10 AND "모듈" = 업무관리 AND created >= -14d'
```

## 기대 출력

```markdown
## JIRA 수집 결과 — 2026-04-18

- **프리셋**: (custom jql)
- **JQL**: `project = CSA10 AND "모듈" = 업무관리 AND created >= -14d AND assignee in (kykim, ...)`
- **서버 총 건수 / 수집 건수**: 14 / 14
- **복수 모듈 이슈**: 0건
- **미매핑 이슈**: 0건

### 모듈별 분포
| 모듈 | BE | FE | 건수 | 보기 |
|------|----|----|------|------|
| 업무관리 | 9 | 5 | 14 | `/a10-jira --read 2026-04-18/업무관리` |
```

## 오류 사례

### 쌍따옴표 누락

입력:
```
/a10-jira --jql 'project = CSA10 AND 모듈 = 업무관리'
```

출력:
```
🔴 JQL 문법 오류 — 한글 필드명 "모듈" 은 반드시 쌍따옴표로 감싸야 합니다.
  수정: project = CSA10 AND "모듈" = 업무관리
```

수집기 실행 전 스킬이 선검증하여 즉시 안내 (서버 왕복 없이).

### 문법 오류 (JIRA 응답)

```
🔴 JIRA 응답 400 — JQL 문법 오류:
"Field '모듈' does not exist or you do not have permission to view it."
```
