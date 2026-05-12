---
name: a10-git-daily
description: "Workspace_a10 레포의 전일 git 커밋을 수집해 douzone-forge PRJ/히스토리에 자동 반영"
---

Workspace_a10의 17개 SBUnit 관리 레포에서 커밋을 수집하여 douzone-forge의
프로젝트 포트폴리오와 모듈 히스토리에 일자별 진행현황을 append한다.

`a10-git-daily` 스킬의 전체 흐름을 따른다.

## 인수 (`$ARGUMENTS`)

| 인수 | 설명 | 예시 |
|---|---|---|
| (없음) | 어제 00:00 ~ 지금 | `/a10-git-daily` |
| `--since YYYY-MM-DD` | 지정일부터 현재까지 | `/a10-git-daily --since 2026-04-15` |
| `--weekly` | 직전 7일 | `/a10-git-daily --weekly` |
| `--module {모듈명}` | 특정 모듈 레포만 | `/a10-git-daily --module 법무관리` |
| `--repos a,b,c` | 개별 레포 지정 | `/a10-git-daily --repos amaranth10-lte` |
| `--dry-run` | 레포트만 생성, douzone-forge 수정 없음 | `/a10-git-daily --dry-run` |
| `--include-personal` | `devqa-{사번}`·`dev-{사번}` 개인 브랜치 포함 | `/a10-git-daily --include-personal` |
| `--no-triage` | 3-way 크로스 체크·상태 전이 생략 (커밋 수집만) | `/a10-git-daily --no-triage` |
| `--no-bridge` | `.forge/` 주입만 생략 | `/a10-git-daily --no-bridge` |

## 실행 결과

1. `/Users/cjrain/Workspace_a10/_doc/git-daily/YYYYMMDD.md` 생성
2. 커밋 프리픽스 `[PRJ-NNNN/TASK]` 파싱 결과에 따라 해당 PRJ 파일 `03. 상세 진행현황` append
3. 모듈별 `history/_timeline.md` append
4. 미태깅 커밋은 경고 리스트로 분리 보고
5. (v0.2.0) JIRA 키 추출 → `a10-jira-classifier` 로 트랙 분류
6. (v0.2.0) 검토안×커밋×일일보고 3-way 조인 → 8케이스 매트릭스 산정
7. (v0.2.0) 브랜치 도달 지점에 따라 검토안 `status` 자동 전이 + `## 📊 진행 로그` append
8. (v0.2.0) 케이스 6 자동 초안, 케이스 4 지연 경고, 고도화 자동 스텁
9. (v0.2.0) `a10-forge-bridge` 호출하여 `.forge/` 주입·정리

## 주의사항

- **멱등성 보장**: 같은 SHA가 PRJ 파일에 이미 있으면 재반영하지 않음
- **추측 금지**: 프리픽스 없는 커밋을 임의로 PRJ에 매핑하지 않음
- **기본 제외 브랜치**: `devqa-{사번}`, `dev-{사번}` 개인 브랜치 (필요 시 `--include-personal`)
- **머지 커밋 처리**: `Merge branch 'devqa' into 'sqa'` 류는 별도 "승급 이벤트"로 분류

## 선행 조건 미비 시 안내

- 커밋 메시지 규약이 팀에 공지되지 않은 경우 → 실행 전 사용자에게
  `_참조자료/프로세스/깃-커밋-메시지-규약.md` 작성을 권고하고 확인받는다.
- 미태깅 비율이 50% 이상이면 규약 정착이 덜 되었다는 신호 → 보고서 상단에 경고.
