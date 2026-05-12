---
name: a10-reject
description: "스코어링 엔진 승인 대기 큐의 항목을 기각 (유지보수 또는 미태깅 처리)"
---

`/a10-git-daily` 스코어링 엔진이 추정한 PRJ 귀속이 잘못되었을 때 기각한다. 기각된 항목은 유지보수 로그로 이동하거나 미태깅 상태로 유지된다.

## 인수 (`$ARGUMENTS`)

| 인수 | 설명 | 예시 |
|---|---|---|
| `N` | 큐 순번. 단순 기각 (미태깅으로) | `/a10-reject 2` |
| `N --maint` | 유지보수 로그로 이동 | `/a10-reject 2 --maint` |
| `N --maint CSA10-XXXXX` | 유지보수 로그 + JIRA 키 수동 부여 | `/a10-reject 2 --maint CSA10-40521` |

## 실행 절차

1. [`_projects/_mapping-queue.md`](../../../../douzone-forge/_projects/_mapping-queue.md) 에서 `#N` 행 로드
2. `--maint` 인수가 있으면 → 해당 모듈의 [`{모듈}/history/_timeline.md`](../../../../douzone-forge/) "유지보수 로그" 누적 테이블에 추가:
   ```markdown
   | {일자 HH:MM} | {레포} {브랜치} {short-sha} | [UC/SB]{저자} | {메시지} | {JIRA 키 or "-"} | 수동 기각 |
   ```
3. `--maint` 없으면 → 미태깅 리스트에만 남기고 PRJ에 반영하지 않음
4. [`_projects/_mapping-history.md`](../../../../douzone-forge/_projects/_mapping-history.md) 에 결정 기록:
   ```
   | {일자} | {sha} | {저자} | {메시지 요약} | {추정 PRJ} | {점수} | reject{-maint?} | {(유지보수) or (미태깅)} |
   ```
5. `_mapping-queue.md`에서 해당 행에 `❌ rejected by PM @ {timestamp}` 주석 부착

## 출력

```
❌ 기각 처리 완료
- SHA: d9106ea / 레포: amaranth10-kiss
- 거부된 추정 PRJ: PRJ-2026-003 (점수 68)
- 분류: 미태깅 (유지보수 이동 아님)
- _mapping-history.md 기록: reject
- 참고: 이 조합(저자×메시지 패턴)이 2회 이상 reject되면 다음 스캔에서 해당 조합 감점 보정됨 (v0.9.2)
```

유지보수 이동 시:
```
❌ 기각 처리 완료 (유지보수 이동)
- SHA: a1b2c3d / 레포: amaranth10-crm
- 분류: 유지보수 / JIRA: CSA10-40521 (수동 부여)
- 법무관리/history/_timeline.md 유지보수 로그에 append 완료
- _mapping-history.md 기록: reject-maint
```

## 에러 처리

- 큐 파일 부재 → `🔴 _mapping-queue.md가 없습니다.`
- `#N` 없음 → `🔴 순번 N이 큐에 없습니다.`
- `--maint` 시 모듈 추론 실패 (레포명에서 모듈 매핑 불가) → 사용자에게 모듈 지정 요청

## 관련

- 승인: `/a10-confirm N [PRJ-ID]` — PRJ로 귀속 확정
- 소스: [`a10-git-daily` 스킬 §학습 레이어](../../skills/a10-git-daily/SKILL.md)
