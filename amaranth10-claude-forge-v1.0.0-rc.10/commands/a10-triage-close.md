---
name: a10-triage-close
description: "검토안 처리완료 수동 전이 (배포완료→처리완료, 수용→완료 마킹)"
---

`배포완료` 이후 단계는 자동 전이되지 않는다(결정 1). 고객사 회신·운영 승인이 필요하므로
PM이 이 커맨드로 수동 마킹한다.

## 인수 (`$ARGUMENTS`)

| 인수 | 설명 |
|---|---|
| `{JIRA키}` | 대상 검토안 |
| `--reason "회신 완료"` | 완료 사유 (진행 로그에 기록) |
| `--reject` | 완료 대신 기각 처리 |
| `--reopen` | 처리완료/기각 → 수용으로 되돌림 |

## 실행 절차

### 처리완료 전이 (기본)
1. `{모듈}/유지보수/{YYYYMMDD}-{JIRA키}-검토안.md` 로드
2. frontmatter `status: 처리완료` + `closed_at: YYYY-MM-DD HH:MM`
3. 진행 로그 마지막 행 추가: `처리완료 | 수동 | - | ✅ | {reason}`
4. `_index.md` 진행상태 컬럼 갱신
5. `a10-forge-bridge --cleanup-only` 호출 → `.forge/` 에서 제거

### 기각 전이 (`--reject`)
1. `status: 기각`
2. 진행 로그에 사유 append
3. `.forge/` 에서 제거

### 복구 (`--reopen`)
1. `status: 수용` 으로 되돌림
2. 진행 로그에 `reopen` 행 append
3. `.forge/` 재주입 (다음 `/a10-triage-status` 실행 시)

## 가드

- 현재 상태 != `배포완료` 인데 처리완료로 전이하려는 경우 → **경고 + 확인 요청**
- 진행 로그 없이 바로 완료 처리 → `--force` 없으면 거부

## 출력

```
✅ 처리완료 전이
- CSA10-44921 (게시판): 배포완료 → 처리완료
- 사유: 고객사 회신 완료
- .forge 제거: amaranth10-board, klago-ui-board-micro
- _index.md 갱신됨
```

## 관련

- [`/a10-triage-status`](a10-triage-status.md)
- [`/a10-triage-sync`](a10-triage-sync.md)
- 스킬: [`a10-maintenance-triage`](../skills/a10-maintenance-triage/SKILL.md)
