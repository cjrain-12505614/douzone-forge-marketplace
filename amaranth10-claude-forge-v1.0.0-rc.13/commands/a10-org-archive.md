---
name: a10-org-archive
description: "퇴사 인원 처리 — 조직/{...}/{이름_ID}/ → 조직/archived/{이름_ID}/ 이동 (차민수 재확인 단계, 민감 정보 분리)"
version: 0.1.0
---

# /a10-org-archive 커맨드 (Phase Q-2 신설)

퇴사 인원 폴더를 `조직/archived/`로 이동. **차민수 재확인 단계 의무** (D3 정책).

## 사용 시점

- xlsx에서 사라진 ID (a10-org-sync가 검출)
- 퇴사 통보 수령 후 admin 처리

## 핵심 정책 (D3 일관)

- **수동 명령 + 재확인 의무** — 자동 실행 금지
- **민감 정보 분리**:
  - VPN·IP·연락처 등 → `_개인/` 본인 영역 보존
  - 공용 메타 (이름·ID·직급·R&R 이력) → `archived/` 이동
- **archived 위치 영문**: `조직/archived/{이름_ID}/` (영문 archived 결정 D3)

## 입력

- 퇴사 인원 ID (xlsx 13번 컬럼)

## 실행 흐름

1. ID 매칭 → 본인 폴더 4계층 lookup
2. **재확인 1**: "정말 archive 처리할까요? (Y/n)"
   - 실수 방지 — Y만 진행
3. 민감 정보 분리:
   - `_개인/{ID}/` 잔존물 → 본인 알림 (요청 시 본인 dump)
   - 공용 메타만 추출
4. **재확인 2**: "최종 확정 — 폴더 이동 시작? (Y/n)"
5. mv 실행 — `조직/{본부}/{Unit}/{Cell}/{이름_ID}/` → `조직/archived/{이름_ID}/`
6. archived 폴더에 _README.md 신설:
   ```
   - 퇴사일: YYYY-MM-DD
   - 마지막 R&R: ...
   - 처리자: admin (차민수)
   - 처리일: YYYY-MM-DD
   ```
7. 결과 리포트 — `참고자료/리포트/org-archive-{YYYYMMDD}-{ID}.md`

## 출력 검증

```
✅ org-archive 완료
  - ID: {ID} ({이름})
  - 이동 경로: 조직/archived/{이름_ID}/
  - 민감 정보 분리: VPN/IP/연락처 (_개인/ 본인 영역 보존)
  - _README 신설: archived 메타 포함
```

## 안전 장치

- 재확인 2회 (실수 방지)
- mv는 git tracked 영역이라 복구 가능
- 민감 정보 자동 삭제 안 함 — 별도 본인 처리

## 의존 자산

- `skills/a10-people-index/SKILL.md`
- `rules/personal-area-guard.md` (G7) — 민감 정보 분리

## 변천사

- Phase Q-2 Q-12 (2026-04-27) — 본 명령 신설 (D3 정책 정합)
