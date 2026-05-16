---
name: a10-org-bootstrap
description: "admin 첫 도입 시 1회 — Beta 사용자 부서 + 직속 상위 부서 폴더 신설 (사내 일괄 생성 금지, 멱등성 보장)"
version: 0.1.0
---

# /a10-org-bootstrap 커맨드 (Phase Q-2 신설)

admin (차민수) 첫 도입 시 1회 — Beta 사용자가 진입하기 전 조직 폴더 골격을 점진 신설.

## 사용 시점

| 시점 | 사용 |
|------|------|
| Beta 3인 첫 도입 직전 | Beta 사용자 부서·Unit·Cell 폴더 사전 신설 |
| 신규 인원 부서 추가 | 단일 ID 입력 → 해당 인원 + 직속 상위 부서만 |
| 정식 배포 후 신규 부서 편입 | 부서 단위 점진 확장 |

## 핵심 정책 (D4 일관)

- **사내 4,156명 일괄 생성 금지** — on-demand 점진 확장
- **멱등성 보장** — 이미 존재하는 폴더는 무시 (덮어쓰기 안 함)
- **xlsx 13번 컬럼 ID 표준** — Phase Q-1 Q-01 결정 일관

## 입력

- Beta 사용자 ID (xlsx 13번 컬럼) 1~N건

## 실행 흐름

1. xlsx 로드 — `참고자료/조직정보/Amaranth_10_OrganizationChart_*.xlsx`
2. 입력 ID 매칭 → 본인 4계층 (`{본부}/{Unit}/{Cell}`) 추출
3. 직속 상위 부서 식별 (Cell 리더·Unit장·본부장)
4. 폴더 사전 신설:
   - `조직/{본부}/`
   - `조직/{본부}/{Unit}/`
   - `조직/{본부}/{Unit}/{Cell}/`
   - `조직/{본부}/{Unit}/{Cell}/{이름}_{ID}/`
5. 각 신설 폴더에 `_README.md` 표준 5섹션 placeholder 자동 작성

## 출력 검증

```
✅ admin bootstrap 완료
  - 신설 폴더: N건 (멱등성 검증 — 기존 보존 M건)
  - _README placeholder: N건
  - 다음: Beta 사용자 진입 시 a10-personal-init 자가 실행
```

## 의존 자산

- `skills/a10-people-index/SKILL.md` (G8) — ID 매핑 조회
- `참고자료/조직정보/*.xlsx` — SSoT
- `rules/personal-area-guard.md` (G7) — 개인 영역 가드

## 변천사

- Phase Q-2 Q-12 (2026-04-27) — 본 명령 신설 (D4·D7 정책)
