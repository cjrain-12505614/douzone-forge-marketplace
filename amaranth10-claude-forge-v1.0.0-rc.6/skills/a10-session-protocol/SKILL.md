---
name: a10-session-protocol
description: >
  This skill should be used when the user says "세션 시작", "이어서 하자",
  "세션 종료", "세션 저장", "오늘 여기까지", "다음에 이어서",
  or when a new session begins and context needs to be restored,
  or when work is done and progress needs to be saved.
  Manages the full session lifecycle: start protocol (context restoration)
  and end protocol (progress saving) for the project.
version: 0.2.0
---

# Session Protocol

douzone-forge 프로젝트의 세션 시작/종료 절차를 관리한다.
douzone-forge는 **모듈별 분산 구조**를 사용한다. 세션 정보는 각 모듈의 `sessions/` 폴더에 저장된다.

## 핵심 파일 매핑

| 역할 | 경로 |
|------|------|
| 프로젝트 지침 | `CLAUDE.md` (douzone-forge 루트) |
| 프로젝트 포트폴리오 | `projects/_dashboard.md` |
| 프로젝트 상세 | `projects/PRJ-YYYY-NNN_*.md` |
| 모듈 세션 체크포인트 | `_개인/sessions/{모듈}/_current.md` |
| 모듈 업무 목록 | `[모듈]/tasks/_current.md` |
| 모듈 개요 | `[모듈]/module-overview.md` |

## 세션 시작 프로토콜

새 세션이 시작되면 아래 단계를 **순서대로** 수행한다.

1. **CLAUDE.md 확인**: `CLAUDE.md`를 읽어 프로젝트 지침·폴더 구조·연쇄 업데이트 규칙을 파악한다.
2. **프로젝트 대시보드 확인**: `projects/_dashboard.md`를 읽어 전체 프로젝트 현황을 파악한다.
3. **모듈 세션 체크포인트 확인**: 작업 대상 모듈의 `_개인/sessions/{모듈}/_current.md`를 읽는다.
   - **존재하면** → 이전 진행 상황(완료/남은 작업)을 파악한다. "다음에 할 일" 섹션이 이번 세션의 출발점이다.
   - **없으면** → 새 세션 시작. 해당 모듈의 `module-overview.md`와 `tasks/_current.md`를 로드한다.
4. **모듈 업무 확인**: `tasks/_current.md`를 읽어 현재 진행 중인 업무를 파악한다.
5. **PM에게 보고**: 아래 형식으로 간략히 보고한다.

```
PM에게 보고합니다.

**이전 세션**: (날짜, 주요 완료 사항 1~2줄 — sessions/_current.md 기반)
**진행 중 프로젝트**: (PRJ-YYYY-NNN 목록 — _dashboard.md 기반)
**현재 업무**: (tasks/_current.md 기반 주요 항목)
**이번 세션 목표 제안**: (이전 세션 남은 작업 또는 tasks 기반 1~3건)

이 방향으로 진행할까요?
```

### 모듈 미지정 시

사용자가 특정 모듈을 지정하지 않았으면:
1. 모든 모듈의 `_개인/sessions/{모듈}/_current.md` 존재 여부를 확인
2. 가장 최근 수정된 `_current.md`가 있는 모듈을 최근 작업 모듈로 판단
3. 여러 모듈에 진행 중 세션이 있으면 목록을 보여주고 선택을 요청

## 세션 종료 프로토콜

세션을 종료할 때 아래 단계를 수행한다.

1. **모듈 세션 체크포인트 갱신**: 작업한 모듈의 `_개인/sessions/{모듈}/_current.md`를 업데이트한다.
   - 완료된 작업에 체크 추가
   - 남은 작업 갱신
   - 현재 시점·재개 방법 명시
   - 날짜 업데이트
   - 미결 사항은 `_(확인 필요)_` 태그로 기록

2. **프로젝트 진행현황 갱신**: 관련 프로젝트가 있으면:
   - `projects/PRJ-*.md`의 `03. 상세 진행현황`에 일자별 로그 추가 (최신순)
   - `02. TASK 목록` 진행률 갱신
   - `01. C. 진행률` 전체 수치 갱신
   - 이슈 발생 시 `01. D. 이슈 & 리스크` 추가

3. **대시보드 갱신**: `projects/_dashboard.md`의 진행률·상태·리스크 갱신

4. **교훈 기록**: PM 피드백이나 실수에서 배운 것이 있으면 기록한다.

5. **PM에게 종료 보고**: "세션 저장 완료. 다음 세션에서 [TODO 1~2건]부터 이어서 진행합니다."

## 핵심 규칙

- `_개인/sessions/{모듈}/_current.md`의 "남은 작업"이 가장 중요하다. 다음 세션의 나 자신이 읽을 브리핑 문서.
- "무엇을 했는지"보다 **"왜 그렇게 했는지"**와 **"다음에 무엇을 해야 하는지"**를 우선한다.
- 여러 모듈을 동시에 작업했으면 각 모듈의 `_개인/sessions/{모듈}/_current.md`를 모두 업데이트한다.
- `_개인/sessions/{모듈}/_current.md`는 **Claude가 자동으로 관리**한다. 사람이 직접 편집하지 않는다.

## 마크다운 링크 규칙 (필수)

마크다운 파일 작성·업데이트 시 **모든 경로·파일 참조는 클릭 가능한 상대 링크**로 작성한다.

```markdown
# 나쁜 예 (클릭 불가)
법무관리/tasks/_current.md에서 확인

# 좋은 예 (클릭 가능)
[법무관리/tasks/_current.md](../법무관리/tasks/_current.md)에서 확인
```

- 상대 경로는 현재 파일 위치 기준
- 코드블록 안의 폴더 구조 다이어그램은 예외 (링크 불필요)
- 상세 규칙은 douzone-forge CLAUDE.md의 "마크다운 링크 표기 규칙" 섹션 참조
