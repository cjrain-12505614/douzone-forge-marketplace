---
name: a10-jira-classifier
description: >
  JIRA 이슈 키 또는 커밋 메시지에서 JIRA 프리픽스를 추출하여 트랙(유지보수/고도화/검수/미분류)을
  판정하고 douzone-forge 저장 위치를 결정한다. "이 JIRA 어디로 가야 해?", "CSA10-xxx는 유지보수
  맞지?", "라우팅 테이블 적용해줘" 요청 시 사용. 분류 실패 시 경고만 발행하고 자동 라우팅은
  수행하지 않는다(결정 7).
version: 0.1.0
---

# JIRA 트랙 분류기 (JIRA Track Classifier)

JIRA 프리픽스 → 트랙 → douzone-forge 저장 경로 매핑을 단일 소스로 제공한다.
`a10-git-daily`, `a10-maintenance-triage`, `a10-forge-bridge` 가 공통 참조한다.

## 라우팅 테이블 (단일 원천)

| 프리픽스 | 트랙 | 저장 위치 | 비고 |
|---|---|---|---|
| `CSA10-` | 유지보수 | `{모듈}/유지보수/{YYYYMMDD}-{KEY}-검토안.md` | Amaranth 10 통합 유지보수 |
| `UBA-` | 유지보수 | 동상 | Alpha 유지보수 |
| `UAC-` | 유지보수 | 동상 | Alpha Cloud 유지보수 |
| `EO-` | 유지보수 | 동상 | OmniEsol 유지보수 |
| `KLAGOP1-` | 기능개선/고도화 | `{모듈}/tasks/enhancements/` + `projects/PRJ-*.md` | A10 통합 개발 |
| `A10D-` | 기능개선/고도화 | 동상 | A10 기능 고도화 (유지보수 이관 주 대상) |
| `UCAIMP-` | 기능개선/고도화 | 동상 | Alpha 패키지 고도화 |
| `BC10-` | 검수 | `{모듈}/tasks/검수/` | 릴리스 직전 통합 검수 이슈 |
| **기타/미매칭** | 미분류 | `meta/reports/unclassified-jira.md` | 경고 리포트만, 자동 라우팅 금지 |

## 정규식

```
JIRA_KEY_RE = \b(CSA10|UBA|UAC|EO|KLAGOP1|A10D|UCAIMP|BC10)-\d+\b
```

우선순위: 커밋·문맥에 여러 키가 동시 등장 시 **유지보수 > 검수 > 고도화** 순.
(유지보수 고객 접수 우선 보호 원칙)

## 입력 / 출력

### 입력
- JIRA 키 문자열 (단일/복수) 또는 자유 텍스트(커밋 메시지·설명)
- 선택: `module` 힌트 (없으면 호출자가 추론)

### 출력 (JSON 유사 구조)
```
{
  "key": "CSA10-44921",
  "prefix": "CSA10",
  "track": "유지보수",           // 유지보수 | 고도화 | 검수 | 미분류
  "target_path_template": "{모듈}/유지보수/{YYYYMMDD}-{KEY}-검토안.md",
  "confidence": "high"          // high | medium | low
}
```

미매칭 시:
```
{ "key": null, "track": "미분류", "warning": "프리픽스 인식 실패: <원문>" }
```

## 실행 절차

1. 입력 문자열에서 정규식으로 모든 매칭 키 추출
2. 매칭이 없으면 `미분류` 결과 반환 + 호출자 경고
3. 여러 매칭 시 우선순위(유지보수>검수>고도화) 적용
4. 프리픽스 → 트랙 → 저장 경로 템플릿 치환
5. 호출자는 반환값만 사용. **이 스킬이 파일을 생성하지 않는다.**

## 미분류 처리 규칙 (결정 7)

- `meta/reports/unclassified-jira.md` 에 append만 수행
- 자동 라우팅·자동 파일 생성 **금지**
- PM이 수동으로 라우팅 결정

미분류 리포트 포맷:
```markdown
# 미분류 JIRA 경고

| 수집일 | 원문 | 출처 | 조치 |
|---|---|---|---|
| 2026-04-20 | FOO-123 | amaranth10-lte develop a1b2c3d | PM 수동 확인 |
```

## 연계 스킬

- `a10-git-daily` — 커밋 파싱에서 이 스킬 호출
- `a10-maintenance-triage` — 유지보수 검토안 저장 경로 확정
- `a10-forge-bridge` — 진행 중 건을 소스 레포로 주입

## 주의

- **트랙 정의 변경 금지** — 정의는 이 파일 한 곳에서만 수정. 다른 스킬은 참조만.
- 프리픽스 추가는 `douzone-forge/reference/프로세스/깃-커밋-메시지-규약.md` 와 동기화 필요
