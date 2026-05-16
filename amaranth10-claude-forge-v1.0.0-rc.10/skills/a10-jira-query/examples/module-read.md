# 예시 — 저장된 결과 조회 (`--read`, `--module`)

## 입력 A — 특정 날짜·모듈

```
/a10-jira --read 2026-04-17/업무관리
```

## 내부 동작 A

```bash
cat "$COLLECTOR_DIR/output/2026-04-17/업무관리/summary.md"
```

## 기대 출력 A

```markdown
## JIRA — 업무관리 (2026-04-17 수집)

- **BE 레포**: amaranth10-task-be
- **FE 레포**: amaranth10-task-fe
- **건수**: 20 (BE 12 / FE 8)

| Key | 유형 | 우선순위 | 상태 | 담당자 | 요약 | 업데이트 |
|-----|------|---------|------|-------|------|---------|
| CSA10-1234 | Bug  | High   | In Progress | 김경엽 | 업무 목록 페이징 오류 | 2026-04-17 |
| CSA10-1235 | Task | Medium | To Do       | 유지수 | 필터 UI 개선       | 2026-04-16 |
| ...
```

---

## 입력 B — 오늘자 모듈 요약 (수집 미실행 상태에서)

```
/a10-jira --module 게시판
```

## 내부 동작 B

```bash
# 오늘자 수집 없으면 먼저 실행
[ -d "$COLLECTOR_DIR/output/$(date +%F)" ] || \
  (cd "$COLLECTOR_DIR" && ./scripts/fetch-issues.sh)
cat "$COLLECTOR_DIR/output/$(date +%F)/게시판/summary.md"
```

## 기대 출력 B

입력 A 와 동일한 구조. 상단에 `🟢 default 프리셋 선실행 완료` 안내 추가.

---

## 입력 C — INDEX.md 만

```
/a10-jira --read 2026-04-17
```

## 기대 출력 C

해당 날짜의 INDEX.md 전체 (모듈별 분포 표 + 메타데이터).

---

## 오류 사례

### 존재하지 않는 날짜

입력: `/a10-jira --read 2025-12-31/업무관리`

출력:
```
🔴 output/2025-12-31/업무관리/summary.md 없음.
   해당 날짜에 수집 실행 기록이 없습니다.
   가능한 날짜 목록: 2026-04-15, 2026-04-16, 2026-04-17, 2026-04-18
```

### SBUnit R&R 외 모듈

입력: `/a10-jira --module 총무관리`

출력:
```
🟡 '총무관리' 는 SBUnit R&R 제외 모듈입니다.
   허용: 연락처, 게시판, 업무관리, 법무관리, CRM, _unmapped
```
