---
name: a10-triage-sync
description: "검토안 상태를 수동 재계산하여 인덱스·진행 로그를 강제 동기화"
---

`/a10-triage-status` 의 자동 전이 결과를 신뢰할 수 없거나, 오프라인에서 개발된 건을
일괄 반영해야 할 때 사용. 브랜치 상태·`_index.md`·`.forge/` 를 원천에서 재계산한다.

## 인수 (`$ARGUMENTS`)

| 인수 | 설명 |
|---|---|
| `{JIRA키}` | 특정 검토안만 재계산 |
| `--module {모듈}` | 모듈 전체 재계산 |
| `--all` | 전 모듈 재계산 |
| `--dry-run` | 변경 목록만 출력 |

## 실행 절차

1. 대상 검토안 파일 로드 (frontmatter + 진행 로그)
2. 해당 JIRA 키를 포함한 커밋 전체 검색 (Workspace_a10 모든 관리 레포 `git log --all --grep`)
3. 브랜치별 최신 도달 지점 확인 → 진행상태 재판정
4. 진행 로그 테이블 **전체 재작성** (append 아님, 정합성 최우선)
5. `_index.md` 4컬럼(진행상태·브랜치·최근커밋·마지막보고) 갱신
6. `a10-forge-bridge` 호출하여 `.forge/` 동기화

## 일일보고 참조
해당 JIRA 키가 언급된 일일보고 캐시를 `douzone-forge/_업무산출물/보고서/일일보고/원본캐시/` 에서 역검색.
마지막 보고 일자를 `_index.md` `마지막보고` 컬럼에 반영.

## 출력

```
🔄 수동 동기화 완료
- 대상: CSA10-44921 (게시판)
- 상태 변경: 개발중 → 설계검수 (devqa 도달 2026-04-19)
- 진행 로그: 5행 재작성
- 일일보고 마지막 언급: 2026-04-19 (최현복)
- .forge 주입: amaranth10-board, klago-ui-board-micro
```

## 사용 시나리오

- `/a10-triage-status` 가 놓친 커밋 발견
- 개인 브랜치(`dev-{사번}`) 작업이 있어 `--include-personal` 로 재조사 필요
- 검토안 파일을 수동 편집한 뒤 정합성 복구

## 관련

- [`/a10-triage-status`](a10-triage-status.md)
- [`/a10-triage-close`](a10-triage-close.md)
- 스킬: [`a10-maintenance-triage`](../skills/a10-maintenance-triage/SKILL.md)
