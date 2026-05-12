---
name: a10-triage
description: "유지보수 접수건 수용여부 판단 → 수정안 검토 → 이관 판단까지 구조화된 검토안 생성"
---

`a10-maintenance-triage` 스킬을 실행하여 JIRA 유지보수 티켓(CSA10/UBA/UAC/EO/BC10)을
**2단계(오류) 또는 3단계(개선) 검토안**으로 산출한다. 조회는 `/a10-jira`에 위임,
소스 연계 분석은 `a10-git-daily` 히스토리를 활용한다.

## 인수 (`$ARGUMENTS`)

| 인수 | 설명 | 예시 |
|---|---|---|
| `<JIRA키>` | 단일 티켓 검토 | `/a10-triage CSA10-44921` |
| `<JIRA키1>,<JIRA키2>` | 복수 티켓 일괄 검토 | `/a10-triage CSA10-44921,CSA10-44945` |
| `--module <모듈>` | 모듈 수동 지정 (자동 추론 실패 시) | `/a10-triage BC10-12345 --module 게시판` |
| `--list-recent <모듈> <N>` | 해당 모듈 최근 N일 미판정 접수 나열 | `/a10-triage --list-recent 게시판 30` |
| `--skip-source` | 소스 연계 분석 생략 (JIRA 기반만) | `/a10-triage CSA10-XXXX --skip-source` |
| `--auto-draft` | 커밋·일일보고 트리거로 비대화 자동 초안 생성 (케이스 6 용) | `/a10-triage CSA10-XXXX --auto-draft` |

## 실행 절차

1. **JIRA 원본 로드** — `a10-jira` 스킬로 `key in (...)` 조회. description, comments, components, fixVersions, labels 획득
2. **접수 유형 판정** — 오류 / 개선 / 문의 / 데이터 작업 분류 (`a10-maintenance-triage` §접수 유형 판정)
3. **모듈 추론** — 티켓 본문·커스텀 필드 `모듈` 기준, 실패 시 사용자에게 확인
4. **유사 이력 검색** — 같은 모듈 최근 1년 유사 요약 3~5건 조회 (JIRA 애드혹)
5. **소스 연계 분석** (오류·대형 개선 한정, `--skip-source`로 생략 가능)
   - Workspace_a10의 해당 모듈 레포에서 관련 파일 식별
   - 과거 해결 커밋(동일 JIRA 키 패턴) git log 검색
6. **검토안 생성** — `skills/a10-maintenance-triage/templates/triage-review.md` 복제 후 섹션 채움
7. **저장** — `{모듈}/유지보수/{YYYYMMDD}-{JIRA키}-검토안.md`
8. **인덱스 갱신** — `{모듈}/유지보수/_index.md`에 행 추가 (없으면 생성)
9. **요약 보고** — 판정·확신도·다음 액션·파일 경로

## 출력

```
✅ 유지보수 검토안 생성 완료

■ CSA10-44921 · [라인건설] 게시판 인쇄 오류
- 접수 유형: 오류 (UC)
- 판정: 수용 · 확신도 높음
- 원인 가설 1순위: 비동기 이미지 로드 타이밍 (신뢰도 높음)
- 선행 조사: 문제 게시글 HTML 덤프 + DevTools 로딩 실패 리소스 확인
- 저장: 게시판/유지보수/20260420-CSA10-44921-검토안.md

■ CSA10-44945 · [민주화운동기념사업회] 작성자 수정 불가
- 접수 유형: 오류 (설정↔동작 불일치)
- 판정: 수용(조건부) · 확신도 중간
- 원인 가설 1순위: artMbrId ↔ empSeq 포맷 불일치 (신뢰도 매우 높음)
- 선결 조사: DB 값 대조, 타 고객사 재현 여부
- 저장: 게시판/유지보수/20260420-CSA10-44945-검토안.md

인덱스: 게시판/유지보수/_index.md (2건 추가)
```

## 에러 처리

- JIRA 연결 실패 → `a10-jira` 스킬의 선결 조건 안내 재사용
- 모듈 추론 실패 → `--module` 옵션 요청
- 소스 레포 없음 → `--skip-source` 권고 후 JIRA 기반만 생성
- 티켓 키 형식 오류 → 예상 포맷 안내 (CSA10/UBA/UAC/EO/BC10-숫자)

## `--auto-draft` 모드

`/a10-triage-status` 가 케이스 6(검토안 없음 + 커밋만 있음)을 감지하면
내부적으로 이 옵션으로 본 커맨드를 호출한다.

- 상호작용 없이 조용히 수행
- JIRA·커밋 메시지·(있으면) 일일보고에서 증상·영향 파일 자동 추출
- 신뢰도 낮음으로 표시, frontmatter `status: 보류` 로 저장
- PM 확인 후 수동으로 `수용` 전환 필요

케이스 5(커밋+일일보고 있음, 검토안 없음)는 **알림만** 발행하며 자동 초안 ❌.

## 관련

- 스킬: [`a10-maintenance-triage`](../skills/a10-maintenance-triage/SKILL.md)
- 템플릿: [`triage-review.md`](../skills/a10-maintenance-triage/templates/triage-review.md), [`lite-review.md`](../skills/a10-maintenance-triage/templates/lite-review.md)
- JIRA 분류: [`a10-jira-classifier`](../skills/a10-jira-classifier/SKILL.md)
- JIRA 조회: [`/a10-jira`](a10-jira.md)
- 모듈 업무: [`/a10-load-tasks`](a10-load-tasks.md)
- 3-way 체크: [`/a10-triage-status`](a10-triage-status.md)
