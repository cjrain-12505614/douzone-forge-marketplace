# a10-git-daily v0.9.0 — 비대칭 스코어 매칭 엔진 설계서

> 상태: **Draft (2026-04-18)**
> 전임: v0.8.1 (prefix 기반 결정적 매칭)
> 전환 사유: "PRJ 코드는 douzone-forge에서만 관리. 개발자는 유지보수만 JIRA 키를 남기고, 프로젝트 커밋은 프리픽스를 남기지 않는다"

---

## 1. 설계 원칙

1. **비대칭 처리**: 유지보수 = JIRA 키 결정적 매칭 / 프로젝트 = 다신호 스코어링
2. **douzone-forge가 진실의 원천**: 각 PRJ 파일의 `01.E 연계 키` 섹션이 매핑 규칙의 소스
3. **학습 가능**: PM 확정/기각 이력을 `_projects/_mapping-history.md`에 누적 → 다음 스캔의 가중치 조정
4. **멱등성**: 동일 SHA는 두 번 기록되지 않음 (PRJ 파일 내 SHA 검색 후 스킵)

---

## 2. 파이프라인 (커밋 1건당)

```
[커밋 수신]
   ↓
[STEP 1] Prefix / JIRA 키 결정적 매칭 시도
   - [PRJ-xxxx/TASK]                        → 즉시 확정 (점수 +100, PRJ 반영)
   - [MAINT], (CSA10|UBA|UAC|EO)-\d+        → 즉시 확정 (유지보수 로그 반영)
   - (KLAGOP1|UCAIMP|A10D)-\d+              → 프로젝트 커밋 확정, 매핑은 STEP 2로 (+50 보너스)
   - 없음                                   → STEP 2로
   ↓
[STEP 2] 프로젝트 스코어링 (활성 PRJ 전체 순회)
   for each PRJ in active_projects:
       score = 0
       if has_dev_jira_key(commit.msg) and jira_key in PRJ.integration_keys.jira_keys:
                                                                      score += 50   # ★ 신호⑥
       if match_paths(commit.files, PRJ.integration_keys.paths):      score += 40
       if commit.author in PRJ.members and in_period(commit.time):    score += 30
       if author_reported_prj_in_weekly(commit.author, PRJ.id):       score += 30
       if match_keywords(commit.msg, PRJ.integration_keys.keywords):  score += 20
       if match_branch(commit.branch, PRJ.integration_keys.branches): score += 10
       record(PRJ.id, score)
   ↓
[STEP 3] 최고 점수 PRJ 선택 + 분류
   best = argmax(scores)
   if best.score >= 70:   자동 귀속 → PRJ 파일 append
   elif best.score >= 40: 승인 큐 → pending_queue.md
   else:                  미태깅 → untagged_list
```

---

## 3. 신호(Signal) 세부 명세

### 3.1 경로 매칭 (가중치 40)

- `git show --stat --name-only {SHA}`로 변경 파일 목록 추출
- PRJ.integration_keys.paths는 glob 패턴 리스트 (예: `src/**/mobile/mail/**`)
- **매칭 규칙**: 변경 파일 중 N% 이상이 패턴과 일치하면 성립
  - N ≥ 50%: 전체 점수 40
  - N ≥ 20%: 절반 점수 20
  - N < 20%: 0

### 3.2 담당자 + 기간 매칭 (가중치 30)

- PRJ.integration_keys.members는 `{name, author_email_or_handle}` 리스트
- PRJ.period는 `{start, end}` (YYYY-MM-DD)
- 커밋 저자(`git log %ae` 또는 `%an`)가 리스트에 있고 커밋 시각이 기간 내면 +30
- 기간 밖이면 +10만 부여 (잔불 작업 가능성)

### 3.3 주간보고 자가신고 (가중치 30) ★v0.9.0 신규★

- `a10-weekly-report-parser` 보조 스킬이 ONEFFICE 주간보고 파싱
- 각 담당자의 "이번 주 작업 라인"에서 PRJ 언급 추출:
  ```
  "박선명 — PRJ-2026-003 모바일메일 줌인 작업" → {author: 박선명, prj: PRJ-2026-003}
  ```
- 커밋 주차의 주간보고 자가신고 매칭 시 +30
- 주간보고 미접근 시 signal 생략 (감점 없음)

### 3.4 키워드 매칭 (가중치 20)

- PRJ.integration_keys.keywords는 단어 리스트 (예: `["모바일메일", "줌인", "mobile-mail"]`)
- 커밋 메시지에 1개 이상 포함 → +20

### 3.5 브랜치 매칭 (가중치 10)

- PRJ.integration_keys.branches는 정규식 패턴 (예: `^feature/mobile-mail-.*$`)
- 커밋 브랜치가 패턴에 매칭 → +10

### 3.6 프로젝트 JIRA 키 매칭 (가중치 50) ★최강 신호★

- 프로젝트 개발 JIRA 코드: `KLAGOP1`, `UCAIMP`, `A10D`
- 정규식: `(KLAGOP1|UCAIMP|A10D)-\d+`
- 커밋 메시지에 존재 시 해당 키를 PRJ.integration_keys.jira_keys 리스트와 대조
- 매칭 PRJ에 +50 부여 → 타 신호 1~2개만 있어도 70점 돌파
- **유지보수 JIRA 코드**(`CSA10|UBA|UAC|EO`)는 STEP 1에서 유지보수로 확정되므로 여기 도달하지 않음

### JIRA 키와 PRJ 연결 방법

각 PRJ 파일 `01.E 연계 키`에 JIRA 키 섹션 추가:
```markdown
**JIRA 키 (프로젝트 개발 Epic/Story)**
- KLAGOP1-123
- KLAGOP1-456
- A10D-789
```

이 리스트에 있는 키를 포함하는 커밋은 해당 PRJ로 +50점 귀속.

---

## 4. PRJ `01.E 연계 키` 섹션 스키마

```markdown
## 01.E 연계 키 (git-daily 자동 매핑용)

> `/a10-git-daily`가 이 PRJ로 커밋을 자동 귀속시키기 위한 지표.
> PM이 수동 관리. 누락/오탐 발생 시 이 섹션을 보강.

### 레포
- `amaranth10-kiss`
- `klago-ui-kiss-universal`
- `klago-ui-kiss-micro`

### 브랜치 패턴
- `^feature/mobile-mail-.*$`
- `^feature/PRJ-2026-003-.*$`

### 파일 경로 패턴 (glob)
- `src/**/mobile/mail/**`
- `src/**/board/mobile/**`
- `packages/kiss-universal/src/mobile/**`

### 키워드
모바일메일, 모바일게시판, 줌인, mobile-mail, pinch-zoom, 메일게시판

### 담당자 (이메일/핸들)
| 이름 | Git 저자명 | 이메일 |
|------|-----------|--------|
| 박선명 | seonmyeong | seonmyeong@douzone.com |
| 김승현C | kimsh_c | kimsh_c@douzone.com |

### 기간
2026-02-24 ~ 2026-04-16

### GitLab 메타 (선택)
- Milestone: `-`
- Label: `-`

### JIRA 키 (프로젝트 개발 Epic/Story)
- KLAGOP1-123
- A10D-456
```

---

## 5. PM 승인 큐 운영

git-daily 리포트 말미에 큐 섹션:
```markdown
## ⚠️ 승인 대기 매핑 (N건)

| # | SHA | 저자 | 메시지 | 추정 PRJ | 점수 | 신호 내역 | 액션 |
|---|-----|------|--------|---------|------|-----------|------|
| 1 | d9106ea | 박선명 | 메일게시판 줌인 | PRJ-2026-003 | 68 | 경로40+담당30-주보X+키워드20-브랜치X-10=68 | `/a10-confirm 1` / `/a10-reject 1` |
```

- `/a10-confirm N` → 해당 PRJ 파일에 반영 + `_mapping-history.md`에 확정 기록
- `/a10-reject N` → 미태깅으로 보냄 + 기각 기록 (다음 스캔에서 해당 저자+패턴 조합 감점 -10)
- `/a10-confirm N PRJ-YYYY-NNN` → 추정이 잘못됐을 때 다른 PRJ로 수동 귀속

---

## 6. 학습 레이어 (`_projects/_mapping-history.md`)

```markdown
| 일자 | SHA | 저자 | 메시지 요약 | 추정 PRJ | 점수 | PM 결정 | 실제 PRJ |
|------|-----|------|-------------|---------|------|---------|----------|
| 2026-04-18 | d9106ea | 박선명 | 메일게시판 줌인 | PRJ-2026-003 | 68 | confirm | PRJ-2026-003 |
| 2026-04-18 | a1b2c3d | 이혜영 | mode:local 수정 | PRJ-2026-001 | 45 | reject  | (유지보수) |
```

**환류**:
- 특정 저자×경로 조합이 3회 이상 특정 PRJ로 confirm되면 연계 키에 자동 추가 제안
- 특정 저자×메시지 패턴이 2회 이상 reject되면 해당 조합 감점 보정

---

## 7. 구현 단위 (마일스톤)

| v | 범위 | 상태 |
|---|------|------|
| v0.8.1 | Prefix 결정적 매칭 + 유지보수 로그 | ✅ |
| **v0.9.0** | **경로/담당자/키워드/브랜치 4신호 스코어링 + 승인 큐** | 🚧 설계 완료 |
| v0.9.1 | 주간보고 자가신고 파서 연동 (5번째 신호) | ⏳ |
| v0.9.2 | 학습 레이어(`_mapping-history.md`) 피드백 루프 | ⏳ |
| v1.0.0 | GitLab webhook 실시간 분석 | ⏳ |

---

## 8. 검증 계획

1. **드라이런 회귀**: 04-17 커밋 5건에 대해 v0.8.1 결과(100% 미태깅) vs v0.9.0 결과 비교
   - 기대: d9106ea → PRJ-2026-003 70점 이상으로 자동 귀속
   - 기대: d3689ca3 → PRJ-2026-005 70점 이상
   - 기대: CSA10 유지보수 커밋은 동일하게 유지보수 로그
2. **오탐 테스트**: 퍼블리싱(klago-pub-www) 스타일 커밋이 법무·CRM PRJ에 걸리지 않음 확인
3. **누락 테스트**: 연계 키 미기입 PRJ에 대해서는 담당자+기간만으로도 40점 이상 안정 매칭되는지 확인
