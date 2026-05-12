---
name: a10-triage-status
description: "검토안↔커밋↔일일보고 3-way 크로스 체크 리포트 생성 + 자동 상태 전이"
---

유지보수 검토안, git 커밋, 일일보고 3자를 JIRA 키·PRJ 키·기간 기준으로 조인하여
**8케이스 매트릭스**를 산정하고 `meta/reports/triage-status-YYYYMMDD.md` 를 생성한다.

## 인수 (`$ARGUMENTS`)

| 인수 | 설명 |
|---|---|
| (없음) | 어제 하루 + 진행 중 전체 상태 재계산 |
| `--module {모듈}` | 특정 모듈만 |
| `--since YYYY-MM-DD` | 지정일부터 |
| `--no-transition` | 자동 상태 전이 비활성 (리포트만) |
| `--no-bridge` | `.forge/` 주입 생략 |

## 실행 절차

### STEP 1: 데이터 로드
- 검토안: `douzone-forge/{모듈}/유지보수/*.md` 전체 (상태 프론트매터)
- 커밋: `Workspace_a10/_doc/git-daily/YYYYMMDD.md` (직전 `/a10-git-daily` 결과)
- 일일보고: `douzone-forge/deliverables/보고서/일일보고/원본캐시/YYYY-MM/` 캐시

### STEP 2: 조인 키 생성
각 건을 JIRA 키(우선) 또는 PRJ 키로 해시. 커밋 메시지에서 `a10-jira-classifier` 정규식 사용.

### STEP 3: 8케이스 매트릭스 판정

| # | 검토안 | 커밋 | 일일보고 | 진단 | 자동 액션 |
|---|:---:|:---:|:---:|---|---|
| 1 | ✅ | ✅ | ✅ | 정상 | 진행상태 자동 승격 |
| 2 | ✅ | ✅ | ❌ | 보고 누락 | 리마인드 |
| 3 | ✅ | ❌ | ✅ | 커밋 미반영 | 확인 요청 |
| 4 | ✅ | ❌ | ❌ | 착수 전/지연 | 수용 후 7일 경과 시 경고 |
| 5 | ❌ | ✅ | ✅ | 검토안 누락 | 알림만 |
| 6 | ❌ | ✅ | ❌ | 무허가 커밋 | 🚨 자동 초안 (`/a10-triage --auto-draft`) |
| 7 | ❌ | ❌ | ✅ | 보고만 존재 | 정합성 확인 |
| 8 | ❌ | ❌ | ❌ | - | - |

### STEP 4: 자동 상태 전이 (결정 1)

커밋이 도달한 브랜치 기준으로 검토안 frontmatter `status` 갱신:

| 브랜치 | 진행상태 |
|---|---|
| `develop` | 개발중 |
| `devqa` | 설계검수 |
| `sqa` | QA |
| `master` | 배포완료 |

- 수용 → 개발중 → 설계검수 → QA → 배포완료: **자동**
- 배포완료 → 처리완료: **수동만** (`/a10-triage-close`)

### STEP 5: 진행 로그 업데이트
각 검토안 파일의 `## 진행 로그` 테이블에 일자별 행 append:

```markdown
| 2026-04-20 | devqa | a1b2c3d | ✅ | 설계검수 |
```

### STEP 6: 케이스 6 자동 초안 (결정 3)
커밋만 있고 검토안·일일보고 모두 없는 건 → `/a10-triage --auto-draft {JIRA키}` 자동 실행.
케이스 5(커밋+일일보고)는 **알림만**, 자동 초안 ❌.

### STEP 7: `.forge/` 브리지 (결정 5)
상태 전이 완료 후 `a10-forge-bridge` 호출:
- 진행 중 건 주입
- 배포완료·처리완료·기각 건 제거

### STEP 8: 리포트 생성
`douzone-forge/meta/reports/triage-status-YYYYMMDD.md`

```markdown
# 3-way 크로스 체크 리포트 — 2026-04-20

## 요약
- 진행 중 건: 12 / 신규 전이: 3 / 경고: 2

## 케이스 분포
| 케이스 | 건수 | 조치 |
|---|---|---|
| 1 정상 | 8 | - |
| 4 착수 전/지연 | 2 | 🚨 7일 경과 |
| 6 무허가 커밋 | 1 | 자동 초안 생성 |

## 자동 전이
| JIRA키 | 이전 | 이후 | 근거 |
|---|---|---|---|
| CSA10-44921 | 수용 | 개발중 | a1b2c3d @ develop |

## ⚠️ 경고
- CSA10-44950 · 수용 후 8일 경과, 커밋 0건 — 담당자 확인 필요
- (케이스 6) KLAGOP1-9999 · 검토안 누락 → 자동 초안 생성됨

## 미분류 JIRA
- FOO-123 (amaranth10-lte) → `_reports/unclassified-jira.md`
```

## 출력

```
✅ 3-way 크로스 체크 완료
- 진행 중 건: 12
- 상태 전이: 3 (CSA10-44921→개발중 외 2건)
- 지연 경고: 1건 (7일+)
- 케이스 6 자동 초안: 1건
- .forge 주입: 5개 레포 갱신
- 리포트: douzone-forge/_reports/triage-status-20260420.md
```

## 관련

- 스킬: [`a10-maintenance-triage`](../skills/a10-maintenance-triage/SKILL.md), [`a10-daily-digest`](../skills/a10-daily-digest/SKILL.md), [`a10-forge-bridge`](../skills/a10-forge-bridge/SKILL.md), [`a10-jira-classifier`](../skills/a10-jira-classifier/SKILL.md)
- 선행: [`/a10-git-daily`](a10-git-daily.md), [`/a10-daily-digest`](a10-daily-digest.md)
- 수동 동기화: [`/a10-triage-sync`](a10-triage-sync.md)
- 완료 전이: [`/a10-triage-close`](a10-triage-close.md)
