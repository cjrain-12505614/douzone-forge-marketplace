---
name: a10-personal-init
description: "_개인/ 골격 1회 초기화 (Beta 3인 첫 도입용 + Step 3.5 활성 9 모듈 sessions/ + .gitignore)"
---

# /a10-personal-init 커맨드

신규 사용자(SBUnit Beta 3인 후 22명+) 첫 도입 시 워크스페이스에 `_개인/` 골격을 1회 명령으로 자동 생성합니다. ST Step 1.5 + 02-Bfix + 3.5 결정 일관 — Q4 (A) **빈 폴더만 생성** (`_current.md`는 본인 사용 시점에 자연 신설).

## 의존 SSoT

| 항목 | SSoT |
|------|------|
| `_개인/` 정의 | ST Step 1.5 + 02-Bfix (`_personal/` → `_개인/` 한글 전환) |
| 활성 9 모듈 (Step 3.5) | 법무관리(LTE)·CRM·게시판(BOARD)·업무관리(KISS)·통합연락처(AB)·공통·ONE AI·퍼블리싱·D-Sports |
| 공용/개인 경계 정책 | `_CLAUDE/프로세스/공용-개인-경계-규칙.md` |
| 개인영역 git 가드 | `rules/personal-area-guard.md` (G7, PT-02 신설) |

## 실행 절차

### 1. 사용자 워크스페이스 루트 확인

```bash
pwd
# 예: /Users/cjrain/Workspace/douzone-forge
```

### 2. `_개인/` 디렉토리 신설 (멱등)

```bash
mkdir -p _개인
```

이미 존재 시 보존 (Q4 (A) 빈 폴더만 정책 일관 — 덮어쓰기 안 함).

### 3. `_개인/sessions/{모듈}/` 9 폴더 신설 (Step 3.5 활성 9 모듈)

```bash
for m in "법무관리(LTE)" "CRM" "게시판(BOARD)" "업무관리(KISS)" "통합연락처(AB)" "공통" "ONE AI" "퍼블리싱" "D-Sports"; do
  mkdir -p "_개인/sessions/${m}"
  mkdir -p "_개인/sessions/${m}/archive"
done
```

각 모듈별 빈 폴더만 생성. **`_current.md` 는 자연 신설** (Q4 (A) — Claude가 첫 작업 체크포인트 저장 시점에 자동 작성).

### 4. `_개인/{기타 골격}/` 신설 (선택)

```bash
mkdir -p _개인/임시조사
mkdir -p _개인/학습메모
mkdir -p _개인/개인프로젝트
mkdir -p _개인/기타
```

본인 사용 시점에 자유롭게 활용 (사용자ID 매핑.md `_개인/_README.md` §3 참조).

### 5. `.gitignore` 자동 추가 (해당 시)

워크스페이스 루트 `.gitignore` 에 `_개인/` 라인이 없으면 자동 추가:

```bash
if ! grep -q "^_개인/" .gitignore 2>/dev/null; then
  echo "" >> .gitignore
  echo "# 개인 영역 — GitLab 동기화 금지 (ST Step 1.5)" >> .gitignore
  echo "_개인/" >> .gitignore
  echo "✅ .gitignore 에 _개인/ 라인 추가"
fi
```

### 6. 검증 출력

```
✅ _개인/ 골격 초기화 완료:
  - sessions/{9 모듈}/ + archive/ 신설
  - 임시조사·학습메모·개인프로젝트·기타 신설
  - .gitignore 등록 확인

⚠️ _current.md 는 자연 신설 — 본인 작업 시점에 Claude가 자동 작성 (Step 3.5 패턴 일관)

다음 액션:
- /a10-start-session 으로 첫 세션 시작
- /a10-people-index 사번 매핑 SSoT 확인 (douzone-forge 마운트 필수)
```

## 멱등성

본 명령은 재실행 시 기존 폴더·파일을 **보존** 합니다 (덮어쓰기 안 함):
- `mkdir -p` — 이미 존재하면 무시
- `_current.md` — Q4 (A) 자연 신설 (본 명령에서 작성 안 함)
- `.gitignore` — 라인 없을 때만 추가

## 사용 시점

| 시점 | 사용 사례 |
|------|------|
| **Beta 3인 첫 도입** | SBUnit 3인 (차민수 + 2명) 첫 환경 셋업 — Step 11 진입 시 |
| **신규 사용자 환경 셋업** | SBUnit 22명 정식 배포 시 — Step 12 진입 후 신규 인원 |
| **로컬 환경 재구축** | 디스크 재포맷·신규 PC 셋업 시 |

## 활성 모듈 변경 시 갱신 (R14 메모)

ST 결정으로 활성 모듈 추가/제거 시 본 명령 SKILL.md 9 모듈 목록 동기화 필요. 다만 본 명령은 멱등이라 기존 사용자 환경 무영향 (덮어쓰기 안 함).

## 관련 스킬·커맨드

- `rules/personal-area-guard.md` (G7) — 개인 영역 git 가드 정책
- `skills/a10-people-index/` (G8) — 사번 SSoT 참조 (douzone-forge 필요)
- `skills/a10-team-tracking/` (G9) — 관리자 트래킹 (사용자가 관리자인 경우)
- `commands/a10-start-session.md` — 첫 세션 시작
- `commands/a10-resume-session.md` — 세션 재개

## 관련 문서

- ST Step 1.5 산출 (`_개인/` 정의)
- ST Step 02-Bfix 산출 (한글 전환)
- ST Step 3.5 산출 (활성 9 모듈 + `_개인/sessions/{모듈}/` 이전)
- `_개인/_README.md` (사용자 가이드, 사용자 워크스페이스에 자연 신설)

## 변천사

- ST Step 1.5 (2026-04-25) — `_개인/` 정의 + 공용/개인 경계 결정
- ST Step 02-Bfix (2026-04-25) — `_personal/` → `_개인/` 한글 전환
- ST Step 3.5 (2026-04-25) — 활성 9 모듈 sessions/ → `_개인/sessions/{모듈}/` 이전
- PT-02 (2026-04-26) — 본 명령 신설 (G10, Q4 (A) 빈 폴더만)
