---
name: a10-confirm
description: "스코어링 엔진 승인 대기 큐의 항목을 확정하여 PRJ 파일에 반영"
---

`/a10-git-daily` 실행 결과 40~69점 구간으로 분류되어 [`_projects/_mapping-queue.md`](../../../../douzone-forge/_projects/_mapping-queue.md)에 대기 중인 항목을 PM이 확인하여 PRJ에 귀속시킨다.

## 인수 (`$ARGUMENTS`)

| 인수 | 설명 | 예시 |
|---|---|---|
| `N` | 큐 순번. 추정 PRJ 그대로 승인 | `/a10-confirm 1` |
| `N PRJ-YYYY-NNN` | 추정이 틀렸을 때 다른 PRJ로 수동 귀속 | `/a10-confirm 3 PRJ-2026-010` |
| `all-high` | 큐 내 60점 이상 전체 일괄 승인 | `/a10-confirm all-high` |

## 실행 절차

1. [`_projects/_mapping-queue.md`](../../../../douzone-forge/_projects/_mapping-queue.md) 의 최신 실행 블록에서 `#N` 행 로드
2. 인수에 PRJ ID가 명시되면 그 PRJ로, 아니면 `추정 PRJ` 값 사용
3. 멱등성 체크: 해당 `_projects/PRJ-{ID}.md`의 `03. 상세 진행현황`에 이미 같은 SHA가 있으면 스킵
4. PRJ 파일 `03. 상세 진행현황` 맨 위에 아래 형식으로 append:
   ```markdown
   ### {커밋 일자} (git-daily 승인 반영)
   - **[자동-추론]** {메시지} — {저자} @ {레포} {브랜치} · SHA {short-sha} · 점수 {N}
   ```
5. [`_projects/_mapping-history.md`](../../../../douzone-forge/_projects/_mapping-history.md) 에 결정 기록:
   ```
   | {일자} | {sha} | {저자} | {메시지 요약} | {추정 PRJ} | {점수} | confirm | {실제 PRJ} |
   ```
   - 추정과 실제 PRJ가 다르면 결정 값은 `confirm-override`
6. `_mapping-queue.md`에서 해당 행에 `✅ confirmed by PM @ {timestamp}` 주석 부착 (행은 유지 — 다음 `/a10-git-daily` 실행 시 덮어씀)

## 출력

```
✅ 승인 처리 완료
- SHA: d9106ea / 레포: amaranth10-kiss
- 귀속 PRJ: PRJ-2026-003 (모바일메일)
- 03. 상세 진행현황 append 완료
- _mapping-history.md 기록: confirm
```

추정이 틀렸던 경우:
```
✅ 승인 처리 완료 (수동 귀속)
- SHA: d9106ea
- 추정 PRJ: PRJ-2026-003 → 실제 PRJ: PRJ-2026-010 (override)
- _mapping-history.md 기록: confirm-override
- 참고: 이 조합(저자×경로×키워드)이 3회 이상 동일 override되면 다음 스캔에서 연계 키 보강 제안됨 (v0.9.2)
```

## 에러 처리

- 큐 파일 부재 → `🔴 _mapping-queue.md가 없습니다. 먼저 /a10-git-daily를 실행하세요.`
- `#N` 없음 → `🔴 순번 N이 큐에 없습니다. 현재 큐 크기: M`
- PRJ 파일 부재 (override 지정 시) → `🔴 PRJ-{ID} 파일이 존재하지 않습니다.`
- 이미 처리됨 (SHA 중복) → `🟡 SHA {sha}는 이미 {PRJ-ID}에 기록되어 있습니다. 스킵.`

## 관련

- 기각: `/a10-reject N` — 유지보수 또는 미태깅으로 강등
- 소스: [`a10-git-daily` 스킬 §승인 큐 지속성](../../skills/a10-git-daily/SKILL.md)
