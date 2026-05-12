---
name: a10-org-sync
description: "xlsx 갱신 후 admin 동기화 — 변경 행만 검출, 영향받는 폴더만 갱신 (자동 archive 안 함, 차민수 재확인 의무)"
version: 0.1.0
---

# /a10-org-sync 커맨드 (Phase Q-2 신설)

xlsx 조직도 갱신 후 admin이 워크스페이스 조직 폴더를 동기화. 자동 archive 금지 (D3 정책).

## 사용 시점

- xlsx 갱신 (월간 또는 분기) 직후
- 신규 인원 입사 / 기존 인원 부서 변경 / 퇴사자 검출

## 핵심 정책 (D3·D4 일관)

- **변경 행만 검출** — diff 기반 (이전 xlsx vs 현재)
- **영향받는 폴더만 갱신** — 사내 전체 4,156명 동기화 금지
- **자동 archive 안 함** — 퇴사 후보 발견 시 알림만, 실제 archive는 `/a10-org-archive` 별도 명령 + 차민수 재확인
- **민감 정보 분리** — VPN·IP 등은 _개인/ 보존, 공용 메타만 동기화

## 입력

- 이전 xlsx 백업 경로 (선택, 미지정 시 `참고자료/조직정보/이전버전/` 자동 검색)
- 현재 xlsx 경로 (필수)

## 실행 흐름

1. 이전 xlsx vs 현재 xlsx diff (행 단위)
2. 변경 분류:
   - **신규**: 신규 인원 → `a10-org-bootstrap` 호출 권장
   - **부서 변경**: 폴더 이름 변경 (`조직/{이전 경로}/` → `조직/{신규 경로}/`)
   - **메타 변경**: `_index.md` frontmatter 갱신 (직급·R&R 등)
   - **퇴사 후보**: xlsx에서 사라진 ID — 알림만, archive는 별도 명령
3. 각 변경에 admin 확인 (대화형 — Y/n)
4. 적용 후 결과 리포트 — `참고자료/리포트/org-sync-{YYYYMMDD}.md`

## 출력 검증

```
✅ org-sync 완료
  - 신규 후보: N건 (a10-org-bootstrap 권장)
  - 부서 변경: N건 (적용 또는 보류)
  - 메타 변경: N건
  - 퇴사 후보: N건 (a10-org-archive 별도 명령 필수)
```

## 의존 자산

- `skills/a10-people-index/SKILL.md`
- `참고자료/조직정보/*.xlsx`

## 관련 명령

- `/a10-org-bootstrap` — 신규 인원 폴더 신설
- `/a10-org-archive` — 퇴사 인원 처리

## 변천사

- Phase Q-2 Q-12 (2026-04-27) — 본 명령 신설 (D3·D7 정책)
