# Changelog

## v1.0.0-rc.5 (2026-05-13) — 함정 #6 영속화 통합 사이클 (의제 5·6·7 + AC-6)

### 배경

직전 함정 #6 변종 3건 (옛 경로 ENOENT + install 사일런트 + Anthropic directory 캐시) + sub-변종 B-③ (uninstall "not found" + install 정상) 식별 후 정식 영속화 사이클. 차민수 ⑥ 결재 Q105 A 권고안 채택 — rc.4 ⑥ 결재 후 즉시 의제 5·6·7 통합 rc.5 진입.

### 신설 자산 (3건)

- **`규칙/프로세스/플러그인-마켓플레이스-운영규칙.md`** (~580줄) — SSoT 신설 13 절
  - §1 본 SSoT 범위 · §2 마켓플레이스 이름 표준 (`douzone-forge` 단일) · §3 디렉토리 구조 · §4 plugin.json 표준 필드 · §5 CHANGELOG.md 항목 표준 · §6 build.sh `--deploy` 6 단계 흐름 · §7 CLI vs CoWork 시스템 차이 · §8 함정 #6 변종 3건 + sub-변종 B-③ 진단·해결 매트릭스 · §9 PT-01.5 build.sh 강화 + sub-변종 B-③ 인지 · §10 사용자 측 환경 동기화 절차 · §11 **검증된 사실 매트릭스 영속화 (5건)** · §12 다른 마켓플레이스 참조 · §13 변천사 (옛 이름 → 새 이름 + rc.4 → rc.5)
  - frontmatter 일관 (Forge-초기화-가이드.md 패턴) + 메타블록 (작성일·근거·상위규칙·관련문서)
- **`_plugin/CLAUDE.md` 함정 #6 보강** — 단일 변종 (PT-01.5 옛 경로 ENOENT) → **변종 A·B·C 분리 + sub-변종 B-③ 부속 매트릭스** 확장
  - 변종 B: install `already installed` 사일런트 (rc.5 신규)
  - 변종 C: Anthropic directory 캐시 (rc.5 신규)
  - sub-변종 B-③: uninstall "not found" 사일런트 + install 정상 + 캐시 정상 (rc.4 결과서 §4.1 식별)
  - 검증된 사실 매트릭스 cross-ref (의제 7 SSoT §11)
- **`build.sh` 강화** — 4 영역 추가
  - 마켓플레이스 이름 검증 (`marketplace.json` `name` = `douzone-forge` 정합)
  - uninstall + install 격상 (변종 B 차단)
  - sub-변종 B-③ 인지 (`uninstall ... || true` + 출력 grep 영역 분리)
  - 격상 후 캐시 디렉토리 본문 존재 검증

### 카운트 변화

| 자산 | 직전 (rc.4) | 본 패치 후 (rc.5) |
|------|-----------|---------------|
| Skills | 54 | 54 (변동 없음) |
| commands | 46 | 46 |
| hooks | 14 | 14 |
| rules | 12 | 12 |
| **SSoT (규칙/프로세스/)** | **7** | **8** (+1 플러그인-마켓플레이스-운영규칙.md) |

### 자비스 ⑥ 결재 반영 (의제 5건 + 보강 4건)

| 의제 | 결재 | 적용 |
|------|------|------|
| ❶ SSoT 13 절 구조 | **A** | 작업지시서 §2.3 명시 13 절 그대로 + frontmatter + 메타블록 보강 |
| ❷ 의제 7 SSoT vs 의제 5 함정 #6 본문 중복 회피 | **A** | SSoT = 정식 본문 / 함정 #6 = 요약 + cross-ref |
| ❸ build.sh `uninstall \|\| true` 본문 | **A** | `\|\| true` 격상 + 출력 grep 영역 분리 (uninstall = WARNING / install = exit 1) |
| ❹ 검증된 사실 5건 영속화 위치 | **A** | SSoT §11 박음 + 함정 #6 본문 cross-ref |
| ❺ rc.5 description 카운트 갱신 | **A** | SSoT 7 → 8 + 끝에 rc.5 본문 추가 |
| 보강 1 SSoT frontmatter name 일관성 | 수용 | 파일명 base name 한글 그대로 (`name: 플러그인-마켓플레이스-운영규칙`) |
| 보강 2 build.sh `${PLUGIN_NAME}` 변수 사전 확인 | 수용 | L4 정의 확인 — 변수 그대로 사용 |
| 보강 3 build.sh dry-run 검증 | 수용 | bash -n syntax check + 부분 단계 수동 실행 |
| 보강 4 ⑤ 실행 병렬 Write 활용 | 수용 | 라운드 1 (4 자산 병렬: Write 1 + Edit 3) + 라운드 2 (build.sh 단일 Edit) |

### AC 검증 결과 (6/6 PASS)

| AC | 검증 | 결과 |
|----|------|------|
| AC-1 | `_plugin/CLAUDE.md` 함정 #6 변종 본문 grep — 변종 A·B·C + sub-변종 B-③ 부속 매트릭스 + 진단 명령 + 해결 절차 본문 카운트 ≥ 4 | ✅ |
| AC-2 | `build.sh` 강화 grep — `grep -iE` 패턴 + `uninstall \|\| true` + install 출력 차단 + `name` 필드 검증 + 캐시 디렉토리 본문 존재 검증 모두 존재 | ✅ |
| AC-3 | SSoT 신설 13 절 grep — `grep -c "^## " 규칙/프로세스/플러그인-마켓플레이스-운영규칙.md` ≥ 13 + §11 검증된 사실 5건 모두 명시 | ✅ |
| AC-4 | plugin.json + CHANGELOG.md 갱신 — `version`: `1.0.0-rc.5` + `description` 카운트 정합 (SSoT 8) + CHANGELOG rc.5 항목 prepend | ✅ |
| AC-5 | `build.sh --deploy` 종착 정상 (격상 본문 적용) — exit 0 + rc.5 commit + `~/.claude/plugins/cache/douzone-forge/amaranth10-claude-forge/1.0.0-rc.5/` 디렉토리 **본문 존재** | ✅ |
| AC-6 | tee 로그 영속화 (자비스 ⑥ C 채택) — `/tmp/rc4-{uninstall,install}.log` → `프로젝트/PRJ-2026-014_*/05_산출물/log/` 이동 | ✅ |

### Pre-fix 자가 정정 (정찰 단계 3건 + 관찰 1건)

| # | 단계 | 본문 | 자가 정정 |
|---|------|------|---------|
| 1 | ② 정찰 | `_plugin/CLAUDE.md` 함정 #6 기존 본문 보존 vs 재구성 선택 | 옵션 A (기존 본문 → 변종 A 명명 + 변종 B·C 추가) 채택 |
| 2 | ② 정찰 | build.sh PT-01.5 기존 본문 보존 vs 재구성 | 기존 본문 보존 + 영역 교체 + 신규 추가 |
| 3 | ② 정찰 | AC-6 영속화 후 `/tmp/rc4-*.log` 원본 처리 | `cp` 채택 (mv 아님 — 원본 보존) |
| 관찰 | ② 정찰 | plugin.json description 본문 길이 ~800자 도달 | JSON 본문 가독성 영향 미미 (CLI 메타) |

### R8 실측

- ② 플랜모드 (정찰 + 계획서) — ~10분
- ⑤ 실행 (병렬 Write 4 자산 + build.sh 단일 Edit + AC 검증 + 결과서) — ~60분
- 누적 R8 ~70분 (자비스 ③ 시간 제외, 추정 ~80분 대비 -12.5%)

### 다음 사이클

- **rc.5 ⑥ 결재 후**: W-1 사이클 잔여 7 항목 (C-01 · S-01 · S-05 · S-06 · D-13 · G-02 · G-03) — 마감 2026-05-19
- 옛 자산 처리 (옛 GitHub repo archive · 옛 로컬 디렉토리 백업 · Anthropic directory 자연 만료) — 직전 결과서 §10 후속 의제 (별도 사이클)
- solo-forge·study-assistant·knowledge-forge 마켓플레이스 동일 표준 적용 — 별도 사이클

---

## v1.0.0-rc.4 (2026-05-12) — W-1 S-09 에이전트 구성·역할 정의 표준 정착

### 배경

PRJ-2026-014 W-1 (2026-05-12~05-19) 사이클 8 작업 항목 중 **S-09 (에이전트 구성·역할 정의 표준)** 산출 1·2·3·4 영역 일괄 정착. 작업지시서 [`20260512-작업지시서-S-09-에이전트구성.md`](https://github.com/) + 입력 자산 (조사보고) + 자비스 ⑥ 결재 (의제 ❶~❺ + 보강 2건) 결과 반영. 협업 표준 §3 6 단계 흐름 정합 — Cowork ① → Code ②④ → Cowork ③ → Code ⑤ → Cowork ⑥.

### 산출 영역 4건

- **산출 1 — SSoT 신설**: `규칙/프로세스/에이전트-구성-역할-정의.md` (12절 · 실측 18 헤더 · ~470줄). 3 계층 구조 + 14 업무별 매트릭스 + 2 메타 에이전트 + 하네스 본질 + Subagent 4 가치 + Multi-agent MCP 아키텍처 + 디스패치 규칙 + 표준 프롬프트 템플릿 + 정합 매트릭스 + 운영 결정 D-1~D-5 + 관련 자산
- **산출 2 — 자비스 운영 룰 §2 갱신**: 헤더 `#1~#11 통합 본문` → `#1~#22 통합 본문 (#12~#19 예약)` + 학습 #20 (하네스 본질) · #21 (Subagent 4 가치) · #22 (Multi-agent MCP) 신설. 각 학습 표준 4 헤더 (룰·Why·How to apply·출처)
- **산출 3 — 14 업무별 서브에이전트 SKILL.md 신설**:
  - `a10-oracle-agent` (ORACLE 시장조사·벤치마킹)
  - `a10-cipher-agent` (CIPHER 요구사항 접수·분석)
  - `a10-matrix-agent` (MATRIX IA 설계)
  - `a10-vector-agent` (VECTOR 화면설계·와이어프레임)
  - `a10-prism-agent` (PRISM 디자인 시스템)
  - `a10-weaver-agent` (WEAVER 퍼블리싱)
  - `a10-core-agent` (CORE 백엔드 개발)
  - `a10-nova-agent` (NOVA 프론트엔드 개발)
  - `a10-synapse-agent` (SYNAPSE MCP 개발)
  - `a10-trace-agent` (TRACE 검수 시나리오)
  - `a10-probe-agent` (PROBE 검수 진행)
  - `a10-launch-agent` (LAUNCH 배포)
  - `a10-aegis-agent` (AEGIS 정합성 검증)
  - `a10-helm-agent` (HELM 운영 거버넌스)
  - 각 SKILL.md = ~140줄 (frontmatter + 역할 + AgentDefinition 표준 필드 매트릭스 + 입력 + 산출 + 디스패치 패턴 + 호출 예시 + 관련 자산). 합계 ~1,960줄. 본문 구조 일관성 강제 (자비스 ⑥ 보강 의견 ❺)
- **산출 4 — `a10-agent-dispatch` 전면 갱신**: 5-agent (하준·서연·도윤·지호·수아) → 14+2 (ORACLE~HELM + AVATAR·NEXUS). 호환 매트릭스 (1:1 + 추가 호환) 변천사 보존. 디스패치 4 규칙 + Subagent 4 가치 정합 보강. 표준 프롬프트 7 슬롯. 출력 경로 매트릭스 = Forge 폴더 표준. 교훈 3건 (보존 2 + 하네스 본질 1). ~230줄

### 카운트 변화

| 자산 | rc.3 (직전) | rc.4 (본 사이클) |
|------|----------|---------|
| Skills | 40 | **54** (+14 a10-*-agent) |
| commands | 46 | 46 |
| hooks | 14 | 14 |
| rules | 12 | 12 |
| SSoT (규칙/프로세스/) | 6 | **7** (+1 에이전트-구성-역할-정의.md) |

### 자비스 ⑥ 결재 반영 (의제 5건 + 보강 2건)

| 의제 | 결재 | 적용 |
|------|------|------|
| ❶ 5-agent ↔ 14 호환 매핑 | **A** + 추가 호환 | 1:1 (하준→ORACLE / 서연→CIPHER / 도윤→VECTOR / 지호→CORE / 수아→AEGIS) + 추가 호환 (도윤→+PRISM / 지호→+NOVA+SYNAPSE / 수아→+TRACE+PROBE) — SSoT §3.3 + dispatch 호환 매트릭스 |
| ❷ 학습 # 점프 | **A** | #20·#21·#22 신설 (작업지시서 그대로) |
| ❸ §2 헤더 갱신 | **A** + 보강 | `#1~#22 통합 본문 (#12~#19 예약)` |
| ❹ AC-5 빌드 시점 | **B** | ⑤ 종착 보고 후 차민수 ⑥ 결재 → 본 빌드 진행 (rc.3 패턴 일관) |
| ❺ 14 SKILL.md 분량 | **A** + 보강 | ~140줄 × 14 + 본문 구조 일관성 강제 |
| 보강 1 | 수락 | 디스패치 패턴 절에 표준 프롬프트 템플릿 1건 명시 ✅ |
| 보강 2 | 수락 | Pre-fix 카운트 명시 ✅ |

### AC 검증 결과 (5/5 통과)

| AC | 검증 | 결과 |
|----|------|------|
| AC-1 | SSoT 12절 작성 | 실측 18 헤더 (≥ 12 충족) ✅ |
| AC-2 | 학습 #20·#21·#22 신설 | grep 매칭 3건 정확 ✅ |
| AC-3 | 14 SKILL.md + AgentDefinition 필드 | 14건 + 각 파일 6 필드 모두 명시 ✅ |
| AC-4 | a10-agent-dispatch 14+2 명명 + 5-agent 변천사 | 16 명명 모두 ≥ 1 매칭 + 5-agent 5건 보존 ✅ |
| AC-5 | 본 사이클 빌드·배포 (v1.0.0-rc.4) | 진행 (본 changelog 항목 + plugin.json + dist/) ✅ |

### Pre-fix 자가 정정

- ② 정찰 단계 3건:
  1. 작업지시서 §3.2 학습 #20·#21·#22 신설 전제 vs 현 §2 헤더 "#1~#11" 불일치 → 의제 ❸ §2 헤더 갱신으로 박힘
  2. 자비스 학습 # 현재 #11 + #12~#19 빈 슬롯 → 의제 ❷ 옵션 명시 + 의제 ❸ "예약" 명시
  3. a10-agent-dispatch `docs/01~05` Forge 표준 아님 → 산출 4 갱신 매트릭스에 박힘
- ⑤ 실행 단계 1건:
  4. plugin.json `version` + `description` 카운트 갱신이 ⑤ 실행 단계에 미포함 → 결과서 §8.3 명시 + 본 빌드 직전 자가 정정 적용

→ Pre-fix 총 4건 (정찰 3 + 실행 1) 모두 자가 정정 완료.

### R8 실측

- 추정 ⑤ 종착까지 75분 → 실측 ~33분 (-56%)
- 본 빌드·배포 (AC-5) = ~3분 추가 (rc.3 패턴 일관)
- 효율 향상 본질: 병렬 Write (한 메시지 5/5/4 그룹) + 직접 자료 본문 작성

### 다음 사이클

- W-1 사이클 잔여 7 항목: C-01 · S-01 · S-05 · S-06 · D-13 · G-02 · G-03
- solo-forge:solo-agent-dispatch 정합 (별도)
- 각 에이전트별 MCP 서버 권한 매트릭스 상세 (별도)
- AVATAR · NEXUS 메타 에이전트 SKILL.md 신설 (별도)

---

## v1.0.0-rc.3 (2026-05-12) — Cowork ↔ Claude Code 플러그인 상속 갭 폴백 신설 (단발 갭 패치)

### 배경

2026-05-12 차민수 수석의 PRJ-2026-013 기술위원회 AI 개발툴 TFT — Claude Enterprise 운영 환경 통합본 시각화 작업 중 실증된 갭. 코워크 자비스 답변에서 "frontend-design 스킬은 현재 Cowork 환경 직접 호출 미지원 — TASK-S-05 본질" 명시 → Claude Code 환경으로 작업 위임 후 시각화 산출 완료. 본 사이클 종료 시점에 차민수 ⑩ 결재 의제 옵션 B 채택 (옵션 C 와 병행 수용 — 옵션 C 는 차민수 본인이 코워크에서 진행).

### 신설 자산 (1건)

- **`skills/a10-frontend-design/SKILL.md`** (약 200줄) — Anthropic `claude-plugins-official / frontend-design` 본질 미러 폴백 스킬
  - 호출 우선순위: **Claude Code 환경 = 원본 `frontend-design:frontend-design` 우선** · **Cowork 환경 = 본 폴백 미러 진입**
  - 본 SKILL.md §1 환경별 우선순위 표 명시 → Claude Code 환경에서 본 스킬 호출 시 원본 위임으로 자동 거절
  - 더존 컨텍스트 보강: 한국어 본문 처리 (Pretendard Variable), 인쇄 친화 (`@media print`), ONEFFICE 환경 분리, PRJ 코드 표기 규칙 cross-ref
  - 라이선스: 원본 LICENSE.txt 준수 + 출처 명기 + 분기 (divergence) 관리 정책 §7.2 박음
  - archive 조건: Anthropic frontend-design 이 Cowork 에서도 정식 호출 가능해지면 본 스킬 폴백 의무 상실 → `_archive/` 이동 + plugin.json 제거

### 카운트 변화

| 자산 | 직전 (실측) | 본 패치 후 |
|------|----------|---------|
| Skills | 39 | **40** |
| commands | 46 | 46 |
| hooks | 14 | 14 |
| rules | 12 | 12 |

> ⚠️ rc.2 `plugin.json` description 의 "Skills 38" 표기는 발행 당시 부정확 (자연 누적 1건 반영 누락 추정). 본 패치 시점 `ls skills/ | wc -l` 실측 기준 직전 39 → 본 신설 후 40. plugin.json description 도 "Skills 40" 으로 정정.

### 정책 영향

- **`a10-html-oneffice-builder/SKILL.md` STEP 1 정책과의 관계**: 기존 "자체 미학 가이드 신설 금지 — Anthropic 공식 플러그인 1차 인용" 정책은 유지. 본 미러는 이 정책의 **Cowork 폴백 예외**로 명확히 박힘. Claude Code 환경에서는 여전히 원본 frontend-design 우선이며, 본 스킬은 자동 위임 거절로 정책 일관성 보장.
- **`a10-html-oneffice-builder/SKILL.md` cross-ref 보강**: "Cowork 환경에서 frontend-design 미가용 시 `a10-frontend-design` 폴백 가능" 안내 추가 검토 — 본 사이클 범위 외, **rc.4 또는 별도 사이클에서 처리** (차민수 수석 옵션 C 진행 결과와 묶음).

### 다음 사이클 (자비스 ⑩ 권고)

- **옵션 C 진행 결과 수신**: 차민수 수석이 코워크에서 `규칙/프로세스/cowork-to-claudecode-migration.md` SSoT 에 본 5/12 케이스를 표준 패턴으로 박음. 결과 수신 후 본 플러그인 측 cross-ref 보강 검토
- **V-08 + V-09 + V-10 통합 사이클**: 본 단발 갭 패치와 독립. 본래 다음 진입점 그대로 유효
- **Anthropic frontend-design 갱신 추적**: 분기 (divergence) 발생 시 본 미러 SKILL.md §7.2 정책에 따라 동기화 또는 분기 명시

### Pre-fix

- **1건** — 본 패치 작성 중 plugin.json description 의 직전 카운트 "Skills 38" 표기를 그대로 신뢰하여 "38 → 39" 로 1차 갱신했으나, `ls skills/ | wc -l` 실측에서 40개 확인됨 (직전 실측 39 → 본 신설 후 40). plugin.json description + CHANGELOG 카운트 표 모두 자가 정정.
- **학습**: 카운트 표기 작업 시 기존 description 본문 신뢰 X — 반드시 `ls skills/ | wc -l` 실측 선행 후 표기. 자비스 학습 #12 후보 (가정 권고 vs 실측, 2026-05-11 §A 교훈 2 연장선) 의 또 다른 사례.

---

## v1.0.0-rc.2 (2026-05-11) — Phase V V-06+V-07 통합 패치 (RC 안정화 후속)

### 배경

Phase V 진단 트랙 (V-01~V-05) 종합 발견 8건 중 Critical 2 + High 4 일괄 해소를 위한 V-06 P0 + V-07 P1 통합 사이클. 차민수 ⑩ 결재 의제 1 옵션 B 채택 (사이클 분리 비용 회피, 학습 #6 일관). 본 사이클 종료 후 V-08 (P2 위장된 룰 5건 SSoT 이전) · V-09 (P3 PARTIAL spot check 3건 보강) 는 별도 사이클.

### V-06 — 폴더 표준 P0 패치 (4 sub-트랙)

- **V-06-01 — 활성 9 모듈 루트 `_README.md` 신설** (LTE·CRM·BOARD·KISS·AB·공통·시스템설정·ONE AI·퍼블리싱): 모듈 소개·라이선스·폴더 구조·PRJ 인덱스·연관 SSoT·담당자 6 섹션 표준. 평균 64줄. SSoT 11종 인용. 차민수 본인 정보 누설 0건.
- **V-06-02 — CLAUDE.md 명칭 정합화** (옵션 a — 자비스 ① 권고 옵션 b 정정): 9건 위치 `문서/` → `_분석문서/` 정정. 실 폴더 rename X (옵션 b 비용 회피).
- **V-06-03 — `deliverables/` 골격 신설** (옵션 c): 4 폴더 (`deliverables/{보고서/일일보고/원본캐시, 보고서/주간보고, 산출물}/`) + 4 `_README.md` (41~58줄). V-04 §6.3 P0 갭 해소.
- **V-06-04 — 9×6 매트릭스 우선 채우기**: 7 모듈 `유지보수/` 사전 골격 신설 (CRM·KISS·AB·공통·시스템설정·ONE AI·퍼블리싱) + 7 `_index.md` 4컬럼 확장 스키마. 36 cell 100% 충족. `/a10-triage` 멱등성 FAIL → P1 권고 박힘 (SKILL.md §5.5 사전 골격 보장 + PostToolUse Hook 이중 방어 권고).

### V-07 — 강제력 + 메모리 위생 + 누설 환수 + High 갭 P1 패치 (4 sub-트랙)

- **V-07-01 — 학습 L 등급 4건 강제 메커니즘 신설 (Hook 4 + Rule 4)**:
  - `hooks/simple-approval-md-block.sh` (학습 #4, 경고 exit 0, 66줄)
  - `hooks/v2-version-bump-block.sh` (학습 #6, 차단 exit 2, 73줄)
  - `hooks/umbrella-vocab-block.sh` (학습 #8, 경고 exit 0, 91줄)
  - `hooks/memory-rule-content-block.sh` (학습 #11, 차단 exit 2, 86줄) — 화이트리스트 (본인·내·차민수·cjrain) false positive 회피
  - `rules/single-approval-policy.md` · `no-v2-rebump.md` · `master-vocab.md` · `memory-scope.md` (4건, 57~72줄)
  - hooks 10 → **14** / rules 8 → **12**
  - V-01 L 등급 승급: #4·#8 → M (경고 강제), #6·#11 → H (차단 강제)
- **V-07-02 — `memory-write-block` 본질 통합**: V-07-01 `memory-rule-content-block.sh` 가 마스터지시서 §5.2 본질 100% 커버. 별도 신설 X — 통합 위임. SSoT 후보 grep 정밀화 P3 권고 박힘.
- **V-07-03 — HIGH 메타 누설 2건 환수·익명화**:
  - `규칙/프로세스/cowork-to-claudecode-migration.md` (sed 광역): `/Users/cjrain/` → `$HOME/`·`com.cjrain.` → `com.${USER}.` 일괄. 환수 후 grep 매칭 **0건**.
  - `규칙/프로세스/Forge-GitLab-운영가이드.md` (Edit 정밀): `[UC]차민수` → `[UC]{사용자이름}`·`cjrain@douzone.com` → `{사번}@douzone.com` 변수형 일반화. 변천사 본문 (L3·L15·L41·L58·L129·L130·L137) 출처 보존.
  - 백업 2건 (`.bak.V07`) 신설 — 학습 #1 4영역 일관.
- **V-07-04 — High 갭 3건 해소**:
  - P1 — `skills/a10-cascade-from-context/SKILL.md` description 트리거 키워드 4건 추가 (context 갱신·LNB 수정·기능 분석·모듈 컨텍스트 갱신). 매칭 7건.
  - P2 — `commands/a10-personal-init.md` v0.4.0 §5 신설 (88줄) + `skills/a10-people-context/SKILL.md` 3단 fallback lookup. xlsx 13번 동적 lookup → `_개인/{본인이름_사번}/_R&R.md` 자동 정착. grep 매칭 18건.
  - P3 — `규칙/프로세스/Beta-3인-환경-준비.md` §3.1 신설 (143줄). amaranth10-jira-collector PoC macOS·Windows·Linux 설치 + JIRA API 토큰 + 작동 검증 + 트러블슈팅 매트릭스 7건. 변수형 13건. 차민수 본인 path/이메일 0건.

### 강제력 매트릭스 변화

| 학습 # | v1.0.0-rc.1 | v1.0.0-rc.2 |
|--------|------------|------------|
| #4 (단순 결재 .md 생략) | L | **M** (경고) |
| #6 (v2 갱신 X) | L | **H** (차단) |
| #8 (마스터 어휘) | L | **M** (경고) |
| #11 (메모리 한정) | L | **H** (차단) |

### 자비스 자인 (⑥ 채택)

- 의제 ❶ V-06-02: 자비스 ① 권고 옵션 b → Code 권고 옵션 a 정정 (CLAUDE.md 정정 9건 << 광역 폴더 rename 14건)
- 의제 ❷ V-06-03: 옵션 c (deliverables/ 골격 신설) OK
- 의제 ❸ 버전: v0.20.0 (Code 계획서 §10 가정) → **v1.0.0-rc.2** 본체 자가 정정 (실 현황 v1.0.0-rc.1 — Code 정찰 부재로 Pre-fix 1 카운트)

### 다음 사이클 권고 (자비스 ⑩)

- V-08 (P2): 위장된 룰 5건 SSoT 이전 (자비스-운영-룰 §5 + 아마링크·ONEFFICE 가이드 보강 + 신설 1건)
- V-09 (P3): PARTIAL spot check 3건 본문 명시도 보강 (자비스-운영-룰 §5 GNB hover·PDF 폰트·파일 삭제)
- /a10-triage 멱등성 패치 (V-06-04 P1 권고): SKILL.md §5.5 사전 골격 보장 + PostToolUse Hook 이중 방어

### Phase 누적

Phase Q+R+R++S+T+U+V(진단)+V(V-06+V-07 패치) 누적 R8: Phase U 4:44 + Phase V(04/28) 6:13 + Phase V 진단(05/11) 7:12 + 본 사이클 (Phase C 종착 시점 명시).

---

## v1.0.0-rc.1 (2026-04-28) — Phase V Forge 배포 준비 + 공용/개인 격차 0 (메이저 진급 RC)

### 배경

Phase U 종착 (자비스 메모리 위생·v0.19.1) 직후, 차민수 직접 명령: "사내 누구나 환경 사용 가정 + 공용/개인 영역 구분 의무". 자비스 통합 점검 결과 격차 6건 (HIGH 1·MEDIUM 3·LOW 2) 식별 → Phase V 통합 처리 + v1.0.0 RC 메이저 진급.

### 메이저 진급 의미

- v0.19.1 → **v1.0.0-rc.1** (Release Candidate)
- Beta 3인 합류 직전 안정화 게이트
- v1.0.0 정식 = Beta 3인 검증 종착 후 별도 결재

### 격차 0 정정 (D-02·D-05 강제 적용)

- **V-01 CLAUDE.md (douzone-forge) 일반화** (3건): SBUnit 22명·9 모듈 → 본 사용자 부서 + xlsx 동적 lookup 표준
- **V-01 _plugin/CLAUDE.md path 정정** (8건): `/Users/cjrain/Workspace/...` → `~/Workspace/...`
- **V-01 공용-개인-경계 §8 Cell 리더 일반화**: 4명 명시 → "각 Cell 리더 (xlsx 13번 ID 동적 참조)"
- **V-03 사용자ID-매핑 §2·§3 단축 안내**: 정태 매핑 22+21명 → xlsx 동적 참조 인용 명시 (변천사 보존)
- **V-05 플러그인 cjrain 환경 경로 8건 sed**: 절대 경로 → `~/` 변환
- **V-05 플러그인 일반화 3건**: 21명 추출·9 모듈 본문 절차 → 본 사용자 부서·활성 모듈

### 신설 자산 (V-03)

- **`규칙/프로세스/Beta-3인-환경-준비.md`** (142줄): Beta 3인 합류 환경 준비 7 STEP

### 변천사 보존 (학습 #8 일관)

- 차민수 학습 출처 인용 25건 (skills): 학습 #1·#2·#10 등 출처 명기 — rename·삭제 X
- 옛 "우산" 7건 (douzone-forge 프로젝트 메타): Phase Q·R·R+ 우산 지시서 — 변천사 보존
- 정태 매핑 22+21명 표 (사용자ID-매핑.md §2·§3): 감사·학습 추적용 보존

### 잔존 정리 인벤토리 (V-04, D-04)

- `.bak.*` 25건 + `outputs/` 4건 = 29건
- Step 12 정식 배포 직전 일괄 삭제 권고 (본 Phase는 인벤토리만)

### 자비스 자인 (⑥ 채택)

- V-05 메모리 추정 ~121건 → 실측 9건 (cjrain 8 + 21명 1)
- 학습 #9 (마켓 존재 단정 금지) 위반 자인 — Code 실측 후 광범위 정정 X

---

## v0.19.1 (2026-04-28) — Phase U U-05 frontend-design 환경 의존 차단 (D-04 강화)

### 배경

Phase T 종착 시 시나리오 (A) 확정 — 차민수 본인 다른 세션에서도 frontend-design 부재 = R-01 리스크 현실화. Phase U U-05 트랙으로 흡수. Phase U D-04: "frontend-design 환경 의존 차단 (Skill tool 매번 invoke 의무)".

### 보강 (✚)

- **T-01 SSoT (`규칙/프로세스/HTML-원피스-작성-표준.md`) §2 보강**: fallback 차단 명시 (design 7 skills 사용 금지·자체 미학 추정 금지) + Cowork Customize 사용자 환경 설치 가이드 (Plugin Marketplace → claude-plugins-official 검색 → Frontend design 활성화)
- **T-02 SKILL.md (`a10-html-oneffice-builder/SKILL.md`) STEP 1 보강**: Skill tool 매번 invoke 의무화 (세션별 활성화 자동 보장) + invoke 실패 시 차민수 결재 요청 + 자체 추정·design fallback 금지

### 의도

Phase T R-01 (frontend-design 부재 시 시나리오 A) 강화 — Phase U U-05 흡수 처리. v0.19.0 → v0.19.1 패치 (보강만).

### Phase U 동시 산출 (참고)

- 신설: `규칙/프로세스/자비스-운영-룰.md` SSoT (학습 #1~#11 통합 309줄, 11 ## 학습 # + 8 최상위 섹션)
- 신설: `프로젝트/PRJ-2026-014_*/01_기획/20260428-PhaseU-메모리-인벤토리-분류.md` (45건 분류표)
- 자비스 영역 (별도): MEMORY.md 인덱스 정리 + 메모리 25건 reference 포인터 + deprecated 1건 삭제

---

## v0.19.0 (2026-04-28) — Phase T HTML 원피스 작성 표준

### 배경

Phase S 종착 (v0.18.0) 직후, ONEFFICE HTML 원피스 작성 표준 부재 발견. 차민수 직접 관찰 (2026-04-28): "샘플은 다양성을 죽이는 수렴 장치" → 자비스 학습 #10·#11 신규 채택. frontend-design 플러그인 (claude-plugins-official 마켓) 설치 완료 → 자체 미학 가이드 신설은 중복·열위 → 1차 인용 의무 표준화.

### 추가 (✚)

| 자산 | 유형 | 설명 |
|---|---|---|
| `skills/a10-html-oneffice-builder/SKILL.md` (T-02) | Skill | ONEFFICE 원피스 HTML 작성 표준. frontend-design 1차 인용 의무 + ONEFFICE 환경 제약 5축 (dzeditor·단일페이지·꺾쇠·localStorage·5줄 헤더). 4 STEP (frontend-design Read → 제약 검토 → 작성 → 주입). 99 라인 |
| `규칙/프로세스/HTML-원피스-작성-표준.md` (T-01, douzone-forge SSoT) | SSoT | 8 섹션 (목적·의존·환경 제약·필수 CSS·HTML 가공 원칙·작성 절차 4 STEP·CDN 제약·금지·자연 점검·변경 이력). 197 라인 |

### 표준화

- **D-01 (학습 #10)**: SKILL.md 결과물 샘플 박지 말 것 — `<sample>·예시 결과·sample output` grep == 0 의무
- **D-02**: frontend-design 플러그인 1차 인용 의무 — Anthropic 공식 production-grade 미학 가이드 위임
- **D-03**: ONEFFICE 환경 제약만 본 Skill에 박음 (미학·구조는 frontend-design)
- **D-04 (학습 #11)**: SKILL.md 메모리 학습 인용 금지 — 사내 전사 배포 사용자 부재 격차 차단. SSoT .md 인용으로 대체

### 흡수 (T-03)

- `skills/a10-oneffice-writer/SKILL.md` L70~143 "HTML 가공 원칙 + ONEFFICE 전용 필수 CSS" → SSoT (`규칙/프로세스/HTML-원피스-작성-표준.md` §4·§5) 이전
- writer/SKILL.md 잔존: 주입 절차만, 5축 환경 제약은 SSoT 인용 (자비스 ⑥ 정정 채택)
- 줄수: 751 → 717 (34줄 감소, 풀 텍스트 복제 X — 학습 #4)

### 자연 점검 (T-05)

- `참고자료/리포트/PhaseT-skill-sample-audit-20260428.md` 산출
- skills 39건 + commands 46건 = 전수 85건 grep 결과 결과물 샘플 박힘 **0건**
- 자비스 학습 #10 사전 적용 효과 — 강제 변환 불요
- 향후: Phase V 결재 사이클에서 R-07 6축 확장 후보 (식별만)

---

## v0.15.0 (2026-04-27) — Phase Q-2 자동화 인프라

### 배경

Phase Q-1 종착 (구조 SSoT 정착) 직후 자비스 우산 지시서로 진입한 자동화 인프라 5 트랙. Q-1이 정착시킨 폴더 골격·ID 표준 위에 산출물 파일명 강제·폴더 README 표준·명령 4종·deliverables 폐기·트래킹 재설계를 얹어 Beta 사용자 즉시 운영 가능 상태 도달.

### 추가 (✚)

| 자산 | 유형 | 설명 |
|---|---|---|
| `rules/prj-filename-policy.md` (Q-10) | Rule | 산출물 파일명 표준 `YYYYMMDD-{주제}.md` (8자리 강제). 메타 화이트리스트 8종. 32 라인 |
| `hooks/prj-filename-policy.sh` (Q-10) | Hook | PostToolUse Write/Edit. 적용 범위 한정(프로젝트/PRJ-*/01~06_*, Amaranth10/*/history·tasks). 위배 stderr 경고. 38 라인 |
| `hooks/folder-purpose-check.sh` (Q-11) | Hook | PostToolUse. 신규 폴더 _README.md 부재 시 stderr 경고 + a10-folder-audit 안내. 24 라인 |
| `skills/a10-folder-audit/SKILL.md` (Q-11) | Skill | 워크스페이스 폴더 표준 검증 + 부재·placeholder _README 식별 + 5섹션 충족 검사. 정기 점검 리포트 생성. 87 라인 |
| `commands/a10-org-bootstrap.md` (Q-12) | Command | admin 첫 도입 시 1회 — Beta 사용자 부서 + 직속 상위 부서 폴더 신설 (사내 일괄 금지, 멱등성). 75 라인 |
| `commands/a10-org-sync.md` (Q-12) | Command | xlsx 갱신 후 admin 동기화 — 변경 행만 검출, 자동 archive 안 함, 차민수 재확인 의무. 68 라인 |
| `commands/a10-org-archive.md` (Q-12) | Command | 퇴사 인원 처리 — 조직/{...}/{이름_ID}/ → 조직/archived/{이름_ID}/ 이동 (재확인 2회, 민감 정보 분리). 87 라인 |
| `skills/a10-personal-tracking/SKILL.md` (Q-14) | Skill | PT-02 G9 a10-team-tracking 폐기 후 재설계. 본인이 부하 직원 트래킹 노트 작성 (`_개인/팀트래킹/`). 직급 매칭 (xlsx 부서 계층 분석). 109 라인 |

### 변경 (Δ)

| 자산 | 변경 |
|---|---|
| `commands/a10-personal-init.md` (v0.2.0 → v0.3.0) | 4계층 lookup + _index.md 자동 채움 + 직책 체크 시 팀트래킹 자동 신설 (a10-people-index 호출 의존) |

### 폐기 (✗)

| 자산 | 처리 |
|---|---|
| `skills/a10-team-tracking/` (PT-02 G9) | `_archive/skills-a10-team-tracking-Q14/`로 이동. PT-02 G9 12 게이트 무효화. D6 결정 — a10-personal-tracking으로 재설계 |

### 워크스페이스 영향

- `deliverables/` 폐기 (Q-13) — 91 파일 → 1차 골격 분배 (AI전략·보고서 Q-3 이연 임시 보관)
- `team-tracking/` → `_개인/팀트래킹/` (Q-14) — 6 관리자 폴더 이동
- 인용 정정 sed 86 hits (메타 보호 4영역 표준)

### 자비스 학습 #1 적용

- 광역 sed 보호 표준 4영역 — `_archive/`·`*/99_archive/`·진행 중 사이클 메타·`*.bak.*`

## v0.14.0 (2026-04-26) — 공용/개인 경계 신규 영역 (PT-02 ALL PASS)

### 배경

ST Step 1.5 + Step 02-Bfix + Step 3.5 + Step 7 결과를 플러그인 자산으로 내재화.

douzone-forge 워크스페이스 재편으로 다음 결정이 확립됨:
- **공용/개인 경계** (Step 1.5): GitLab 동기 영역(공용) vs 로컬 only 영역(`_개인/`) 명확 구분
- **4계층 조직** (Step 02-Bfix D9): `조직/{본부}/{Unit}/{Cell}/{이름_사번}/` 폴더명 형식
- **활성 9 모듈 sessions** (Step 3.5): `_개인/sessions/{모듈}/` 평탄화 (분류 폴더 common·publishing·sites 제거)
- **team-tracking 6 관리자 폴더** (Step 7 J3): 본부장-정현수 / Unit장-차민수 / Cell리더 4명 (신무광·유지수·김경엽·이정미)

PT-02는 위 ST 결과를 **플러그인 자산 4건으로 신규 내재화** — Step 11 Beta(3인) 진입을 위한 사실상 필수 트랙.

PT-00 갭분석 §3.2 v0.14.0 분담 그대로 (G7~G10 4건).

### 추가 (✚)

| 자산 | 유형 | 설명 |
|---|---|---|
| `rules/personal-area-guard.md` (G7) | Rule | `_개인/` 영역 GitLab 동기화 차단 + 사용자 안내 + `.gitignore` 자동 등록 권고. 73 라인 + Hook 강화 후보 메모 (F-PT-Nx12) |
| `skills/a10-people-index/SKILL.md` (G8) | Skill | douzone-forge `_CLAUDE/프로세스/사용자ID-매핑.md` SSoT **참조만** (R5 일관, 데이터 미보유). SBUnit 22명 + 협업 21명 사번/이름/소속/R&R 즉시 조회. 104 라인 |
| `skills/a10-team-tracking/SKILL.md` (G9) | Skill | Step 7 6 관리자 폴더에 부하 직원 트래킹 노트 표준 골격 작성. 2계층 구조 `{관리자}/{대상}/{YYYYMMDD}-{주제}.md` (Q3 (B)). G8 연계로 사번/이름 자동 채움. 143 라인 |
| `commands/a10-personal-init.md` (G10) | Command | 신규 사용자(Beta 3인 후) 첫 도입 시 `_개인/` 골격 1회 자동 생성. 활성 9 모듈 `_개인/sessions/{모듈}/` 빈 폴더 (`_current.md`는 자연 신설, Q4 (A)) + `.gitignore` 자동 등록. 멱등성 보장. 125 라인 |

### 사용 사례

- **TASK 담당자 자동 채움** (G8): 사번 `B3505` → `유지수 (B3505) — 대리 / SB설계Cell 리더`
- **PRJ PM 자동 조회** (G8 + module-Cell 매핑): 모듈 `법무관리(LTE)` → PM `유지수 (B3505)`
- **검토안 작성자 메타** (G8): `/a10-triage` 산출물 frontmatter 자동 채움
- **Cell 리더 주간 트래킹** (G9): `team-tracking/Cell리더-유지수_B3505/김영묵_B4456/20260429-주간트래킹.md` 자동 생성
- **Unit장의 4 Cell 리더 점검** (G9): `team-tracking/Unit장-차민수_B2772/유지수_B3505/20260430-1on1.md`
- **신규 사용자 환경 셋업** (G10): `/a10-personal-init` 1회 명령 → `_개인/` 골격 + 9 모듈 sessions/ + .gitignore
- **개인영역 git 가드** (G7): `_개인/` 하위 파일을 git add 시도 시 차단 + 사용자 안내

### 호환성

- 기존 commands·skills·hooks·rules 변경 0 — 본 PT-02는 신규 자산 4건만 추가
- v0.13.x 사용자 → v0.14.0 무중단 승격 가능
- **사번 SSoT는 douzone-forge 측** — 플러그인은 참조만 (R5 일관). 다른 워크스페이스에서 G8/G9 호출 시 동일 워크스페이스 마운트 필요
- Hook 5종·Rule 5종(기존) 변경 0 — Rule 1종 (`personal-area-guard`) 신규로 6종으로 확장
- v0.13.0 (forge-체계 정합화) + v0.13.1 (마켓플레이스 정합) 변천사 보존

### 마이그레이션

**v0.13.1 → v0.14.0 ⑤단계 사용자 2줄** (PT-01.5와 차이 — name 변경 없음, 첫 정상 운영):

```bash
# 1) 마켓플레이스 인덱스 갱신 (이름 변경 없음, update만)
claude plugin marketplace update douzone-forge-marketplace

# 2) v0.14.0 install
claude plugin install amaranth10-claude-forge@douzone-forge-marketplace

# 검증
ls ~/.claude/plugins/cache/douzone-forge-marketplace/amaranth10-claude-forge/
# v0.14.0 디렉토리 확인
```

PT-01·PT-01.5 대비 **`marketplace remove + add` 단계 불요** — PT-01.5 정합화 후 첫 정상 운영.

### PT 누적 게이트

PT-00 (1) + PT-01 (10) + PT-01.5 (9) + **PT-02 (12)** = **32/32**. ST 누적 112/112 유지.

### 자산 카운트 (PT-02 후)

| 자산종류 | PT-01.5 후 | PT-02 후 |
|----------|----------|---------|
| commands | 42 | **43** (+1 a10-personal-init) |
| skills | 29 | **31** (+2 a10-people-index, a10-team-tracking) |
| hooks | 5 | 5 (변경 0) |
| rules | 5 | **6** (+1 personal-area-guard) |
| **총** | 81 | **85** (+4) |

### Step 11 Beta 진입 의미

본 v0.14.0은 **Step 11 Beta(3인) 진입을 위한 사실상 필수 트랙**. 4 신규 자산이 누락되면 다음 시나리오 미작동:
- 신규 사용자가 `_개인/` 골격을 수동으로 만들어야 함 (G10 부재)
- 사번 → 이름 자동 변환 부재 (G8 부재) → TASK·PRJ 담당자 메타 수동 입력
- 관리자 트래킹 노트 표준 골격 부재 (G9 부재) → 일관성 ↓
- `_개인/` 영역 git 누출 위험 (G7 부재)

PT-03 (정합 검증)에서 RT-7~RT-10 4 시나리오 회귀 후 ST Step 11.5 (통합 정합성 검토) 진입 권고.

---

## v0.13.1 (2026-04-26) — 마켓플레이스 정합화 patch (PT-01.5 ALL PASS)

### 배경

PT-01 ⑤단계 사용자 환경 동기화에서 다음 5건의 마켓플레이스 트랜잭션 결함 발견:
- **F-PT-Nx5**: 옛 경로(`douzone-forge/_플러그인/`, 2026-04-20 제거) 마켓플레이스 등록 잔존 → `claude plugin marketplace update` 시 ENOENT
- **F-PT-Nx6**: `build.sh` `||` 핸들링이 `claude plugin ...` 비-0 종료를 무력화 (set -e 우회) → 사일런트 실패
- **F-PT-Nx7**: CHANGELOG v0.13.0 마이그레이션 섹션이 옛 경로 정정 절차 누락
- **F-PT-Nx8**: `marketplace.json` `name` = `amaranth10-forge-marketplace` ↔ 가이드 다수가 `douzone-forge-marketplace` 가정 → install 시 "Plugin not found"
- **F-PT-Nx9**: 두 이름 중 통일 방향 미결정 → Cowork 권고 `douzone-forge-marketplace` 채택

본 v0.13.1 patch는 기능 변경 0 + 트랜잭션 정합화만. PT-02(v0.14.0 신규) 진입 전 마켓플레이스를 깨끗하게 정렬.

### 변경 (✎)

| 자산 | 변경 전 | 변경 후 |
|---|---|---|
| `marketplace.json` `name` | `amaranth10-forge-marketplace` | **`douzone-forge-marketplace`** |
| `build.sh` ENOENT 검증 | `claude plugin ... \|\| echo "..."` (set -e 무력화) | `OUTPUT=$(...)` + grep `Failed\|not found\|ENOENT\|error:\|✘` + `exit 1` |
| `build.sh` SKIP_INSTALL | (없음) | `SKIP_INSTALL=1` 환경변수 — marketplace update/install 단계 건너뛰기 |
| `_plugin/CLAUDE.md` 함정 #6 | (없음) | 신규 — 옛 경로 ENOENT 진단·복구 절차 (≥ 30 라인) |
| `_plugin/CLAUDE.md` 함정 #7 | 진단 위치 (구 #6) | 진단 위치 (이름만 변경 — #6 → #7) |

### 영향 파일

- `_plugin/amaranth10-forge-marketplace/.claude-plugin/marketplace.json` — `name` 필드 1줄
- `_plugin/amaranth10-claude-forge/build.sh` — ENOENT 검증 + SKIP_INSTALL 환경변수 (~25 라인 추가/수정)
- `_plugin/CLAUDE.md` — 함정 #6 신규 (37 라인) + 기존 #6 → #7 (2 라인)
- `_plugin/amaranth10-claude-forge/.claude-plugin/plugin.json` — `version` 0.13.0 → 0.13.1
- 동시 PR `douzone-forge/CLAUDE.md` L25 — `v0.13.0` → `v0.13.1`

### 마이그레이션

**옛 경로/이름 마켓플레이스 등록 잔존 사용자용 4줄 절차** (PT-01 ⑤단계 학습 + R1 정밀화):

```bash
# 1) 옛 등록 제거 — PT-01 ⑤단계에서 사용자가 등록한 이름
claude plugin marketplace remove amaranth10-forge-marketplace

# 2) 새 이름으로 재등록 — marketplace.json `name` 변경됨 (PT-01.5 AC-1)
claude plugin marketplace add /Users/cjrain/Workspace/_plugin/amaranth10-forge-marketplace
# (디렉토리 경로는 그대로지만 marketplace.json `name`이 douzone-forge-marketplace로 변경됨 → 자동 새 이름으로 등록)

# 3) 정합된 이름으로 install
claude plugin install amaranth10-claude-forge@douzone-forge-marketplace

# 4) 검증
ls ~/.claude/plugins/cache/douzone-forge-marketplace/amaranth10-claude-forge/
# v0.13.1 디렉토리 확인
```

> ⚠️ **R1 핵심**: `marketplace remove`의 이름은 **현재 사용자 측에 등록된 이름** (`amaranth10-forge-marketplace`, PT-01 ⑤단계 add 결과). marketplace.json `name` 변경 후 add 시 자동으로 새 이름(`douzone-forge-marketplace`)으로 등록.

### 호환성

- 플러그인 자산(commands·skills·hooks·rules) 변경 0 — 기능 동작 무영향
- v0.13.0 디렉토리(`_plugin/amaranth10-forge-marketplace/amaranth10-claude-forge-v0.13.0/`) 보존 (변천사 패턴)
- GitHub repo 이름(`amaranth10-forge-marketplace`) + 로컬 디렉토리(`_plugin/amaranth10-forge-marketplace/`) 그대로 (외부 명명, 본 PT 무관)
- v0.13.0 이미 사용자에게 배포된 환경 → 위 4줄 마이그레이션 1회 실행 필요

### PT-01.5 검증 게이트 (G1~G9)

- G1 marketplace.json name 정합 ✅ / G2 가이드 cascading ✅ / G3 함정 #6 ≥ 15 라인 ✅ (37 라인) / G4 build.sh ENOENT 검증 로직 ✅ / G5 plugin.json 0.13.1 ✅ / G6 CHANGELOG v0.13.1 ≥ 30 + 마이그레이션 ≥ 8 ✅ / G7 SKIP_INSTALL=1 build.sh --deploy 종료 0 ✅ / G8 dist v0.13.1.plugin ✅ / **G9 사용자 환경 동기화 → ⑤단계 이연**

---

## v0.13.0 (2026-04-26) — 경로·용어 정합화 + Step 10 영문 골격 (PT-01 ALL PASS)

### 배경

douzone-forge 워크스페이스 재편 ST Step 1~10 (2026-04-23~26) 으로 한글 폴더가 영문 골격으로 일괄 이관됨:
- `_projects/` → `projects/` (Step 4·5)
- `_참조자료/` → `reference/` (Step 10b)
- `_업무산출물/` → `deliverables/` (Step 10b, forge-체계는 Step 10a 별도)
- `_reports/` + `_repo-check/` → `meta/{reports,repo-check}/` (Step 10b)
- 모듈 한글 폴더 → `modules/{한글}({모듈코드})/` (Step 3)
- `{모듈}/sessions/` → `_개인/sessions/{모듈}/` (Step 3.5)
- `modules/총무관리(GA)/` → `modules/_archive/총무관리(GA)/` (Step 10c 운영 종료)

플러그인 v0.12.2 자산 (commands 42 + skills 29 + hooks 5 + rules 5 + 메타 2 = 83 자산) 의 한글 경로 참조를 영문 골격에 일괄 정합화한다. PT-01 (Plugin Track 1단계) 첫 ④단계 빌드+배포.

PT-00 갭분석표 결과: 정합화 48건 + archive 1건 + no-change 35건 (Hook 5종 + Rule 3종 + commands 21 + skills 5 + 메타 1 영향 0).

### 변경 (✎)

| 자산종류 | 자산 수 | 변경 전 | 변경 후 |
|---|---|---|---|
| commands | 21 정합화 | `_projects/`·`_참조자료/`·`_업무산출물/`·`_reports/`·`_repo-check/`·`{모듈}/`·`{모듈}/sessions/` | `projects/`·`reference/`·`deliverables/`·`meta/{reports,repo-check}/`·`modules/{한글}({모듈코드})/`·`_개인/sessions/{모듈}/` |
| skills | 24 정합화 (대형 4건: a10-project-tracker 18 / a10-git-daily 15 / a10-session-protocol 15 / a10-jira-query 12) | 동일 | 동일 |
| rules (2종) | `markdown-link-policy.md` (6) + `prj-code-naming.md` (3) | 정책 본문 의도 보존 + 예시 라인 한글 | 본문 의도 보존 + 예시 라인 영문 (P9) |
| 메타 | `README.md` (7) | `{모듈}/sessions/` 등 한글 | 영문 |
| archive | `plugin-upgrade-plan.md` (v0.5 잔존) | `_plugin/amaranth10-claude-forge/` | `_plugin/amaranth10-claude-forge/_archive/plugin-upgrade-plan-v0.5.md` |

### 영향 파일

- `commands/` 21 자산 (a10-add-project, a10-confirm, a10-decision, a10-projects, a10-status, a10-load-context, a10-init-project 등)
- `skills/` 24 자산 (a10-project-tracker·a10-git-daily·a10-session-protocol·a10-jira-query [대형 4건] + a10-context-manager·a10-status-reporter 등)
- `rules/markdown-link-policy.md` + `rules/prj-code-naming.md` (의도 보존)
- `README.md` (PLUGIN_ROOT)
- `_archive/plugin-upgrade-plan-v0.5.md` (신규 archive)

### 마이그레이션

기존 v0.12.x 환경 → v0.13.0 무중단 승격 가능:
- 한글 폴더 참조는 본 v0.13.0부터 영문 골격으로 단일 매핑 (Q1 (A) alias 미도입)
- `_개인/`은 GitLab 미동기 영역 — 사용자 로컬에 없으면 자연 신설
- `modules/총무관리(GA)/` 이전 사용자는 `modules/_archive/총무관리(GA)/` 참조 (Step 10c 운영 종료, ARCHIVED.md 4섹션 참조)
- douzone-forge `CLAUDE.md` L25·L917 v0.13.0 표기 갱신 동시 PR

### 호환성

- Hook 5종 본체 변경 0 (한글 의존 0 사전 검증 — PT-00 R3 해소)
- Rule 3종 (`coding-standards`·`enum-consistency`·`verification`) 본체 변경 0
- v0.12.0 추가 자산 (`.forge/` 브리지·3-way 크로스 체크·유지보수 4컬럼) 변천사 보존
- 한글 alias 미도입 — Beta 3인은 본 PT 완료 후 새 환경 시작 (영향 0)

### PT-00·PT-01 연계

- PT-00 갭분석표 §2 84 자산 매트릭스 SSoT
- PT-01.G1~G10 게이트 ALL PASS (정합화 48 / archive 1 / Rule 의도 보존 / version 0.13.0 / CHANGELOG ≥ 50라인 / build.sh 종료 0 / dist zip / CLI 캐시 / douzone CLAUDE.md / RT-1~RT-6 6/6)
- ④단계 §X 빌드 검증 행 첫 발화 (PT 신규 표준)

---

## v0.12.2 (2026-04-22) — PRJ 코드 표기 규칙 내재화 (Rule + Hook)

### 배경
개인 메모리(`feedback_project_code_display.md`)에 "PRJ 코드 단독 표기 금지" 규칙이
기록되어 있었으나 새 세션마다 인덱스 제목만 로드되어 엄격성이 희석됨.
2026-04-22 기술위원회 3트랙 재편 작업(PRJ-2026-013/014/020/021) 중 단독 표기가
대시보드·PRJ 헤더·채팅 답변에 반복 누출되어 사용자 지적을 받음. 플러그인
레이어로 근본 보강한다.

### 추가 (+)

| 자산 | 유형 | 설명 |
|---|---|---|
| `rules/prj-code-naming.md` | Rule | PRJ 코드 단독 표기 금지 규정 · 허용 패턴 3종 · 판정 기준 · 예외 없음(채팅 포함) |
| `hooks/prj-code-naming-check.sh` | Hook (PostToolUse Write/Edit) | 마크다운 편집 후 PRJ 코드 등장 라인에 한글 프로젝트명 미동반 시 stderr 경고 (block 안 함) |

### 변경 (✎)

| 자산 | 변경 |
|---|---|
| `.claude-plugin/plugin.json` | PostToolUse 에 `prj-code-naming-check.sh` 등록 (4번째 Hook) |

### 판정 로직 (perl 정밀 매치)

PRJ 코드 패턴: `PRJ-\d{4}(-[A-Z]+)?-\d+`

각 출현 위치별 판정:
- ✅ 직전 문자가 `(` → `프로젝트명(PRJ-...)` 형태 (PASS)
- ✅ 링크 URL 내부(`](` ~ `)`) → 경로/파일명 (PASS)
- ✅ 마크다운 링크 표시텍스트에 한글 또는 영문 단어 3자+ 포함 → `[Douzone AI Radar](...)` (PASS)
- ✅ 코드블록 내부 → 무시
- ❌ 그 외 단독 출현 → ⚠️ 경고

예시:
- ✅ `Douzone AI Radar(PRJ-2026-020)` — 괄호 앞 프로젝트명
- ✅ `[Douzone AI Radar(PRJ-2026-020)](PRJ-2026-020_Douzone-AI-Radar.md)` — 링크 표시텍스트 + URL
- ✅ `가온(PRJ-2025-001) 진행 중` — 괄호 앞 한글
- ❌ `PRJ-2026-013 연계 포인트` — 단독 출현
- ❌ `참고: PRJ-2026-LTE-001 을 확인` — 단독 출현

### 호환성
- 기존 Hook/Rule 4개 유지 · 신규 추가만
- block 하지 않고 경고만 출력 → 기존 워크플로우 무영향

### 3중 방어 체계
1. **CLAUDE.md** (douzone-forge) — 세션 시작 강제 로드, 채팅 답변까지 커버
2. **Rule** (plugin) — Claude 작업 시 규정 참조
3. **Hook** (plugin) — 파일 편집 직후 자동 스캔 경고

### 마이그레이션
- `build.sh --deploy` 재배포 → CoWork 앱에서 플러그인 업데이트 클릭
- 재배포 없이도 소스 경로에서 바로 동작

---

## v0.12.1 (2026-04-20) — 일일보고 캐시 경로 정정

### 배경
v0.12.0 는 일일보고 원본캐시를 `douzone-forge/업무관리/일일보고/YYYY-MM/` 에
저장했으나, `업무관리/` 는 Amaranth 10 **KISS 모듈 폴더**이고 SBUnit 전사 자산은
`_` 프리픽스 폴더(`_업무산출물/`, `_참조자료/`, `_projects/` 등)를 사용하는
규칙과 충돌했다. 모듈 폴더 오염을 제거하고 SBUnit 보고서 자산으로 정상화한다.

### 변경 (✎)

| 자산 | 변경 전 | 변경 후 |
|---|---|---|
| 일일보고 원본캐시 경로 | `douzone-forge/업무관리/일일보고/YYYY-MM/` | `douzone-forge/_업무산출물/보고서/일일보고/원본캐시/YYYY-MM/` |
| PM 분석 경로 | _(암묵적, 없음)_ | `douzone-forge/_업무산출물/보고서/일일보고/YYYYMMDD-SBUnit-일일보고-분석.md` |
| 주간보고 구조 | `주간업무정리/` + `주간회의/` (2축 혼재) | `주간보고/` 단일 (파일명 `YYYYMMDD-주간보고-W##[-W##]-{주제}.{ext}`) |

### 영향 파일

- `skills/a10-daily-digest/SKILL.md` — 캐시 경로 · tree 다이어그램 재작성
- `skills/a10-git-daily/SKILL.md` — frontmatter 역검색 경로
- `commands/a10-daily-digest.md` — 저장 경로 · 디렉토리 권한 안내
- `commands/a10-triage-sync.md` — 일일보고 역검색 경로
- `commands/a10-triage-status.md` — 3-way 조인 소스 경로

### 마이그레이션
기존 `douzone-forge/업무관리/일일보고/YYYY-MM/` 아래 파일은 수동으로
`_업무산출물/보고서/일일보고/원본캐시/YYYY-MM/` 으로 이동한 뒤 빈 상위 폴더
(`업무관리/일일보고/`)를 제거한다. v0.12.1 부터 스킬 출력은 신규 경로 기준.

### 호환성
- Hook/Rule/Permission 변경 없음 — 경로 문자열만 정정
- v0.12.0 이미 배포 환경은 `/plugin install` 로 무중단 승격 가능

---

## v0.12.0 (2026-04-20) — 3-way 크로스 체크 + `.forge/` 브리지

### 배경
v0.11.0 에서 유지보수 검토안 표준이 수립되었으나 검토안·소스 커밋·일일보고 3자가
분리 운용되어 "수용 후 실제 개발 진행 여부"·"무허가 커밋"·"지연된 건" 추적이
PM 수동 감사에 의존했다. 본 릴리즈로 3-way 크로스 체크 + 자동 상태 전이 +
소스 레포 `.forge/` 경량 복제를 도입한다.

### 추가 (+) — 스킬 3

| 스킬 | 설명 |
|---|---|
| `a10-jira-classifier` | JIRA 프리픽스 → 트랙(유지보수/고도화/검수/미분류) 단일 원천 라우팅 |
| `a10-forge-bridge` | 진행 중 검토안·고도화를 소스 레포 `.forge/` 에 경량 복제 + `.gitignore` 가드 |
| `a10-daily-digest` | ONEFFICE 일일보고 → `douzone-forge/_업무산출물/보고서/일일보고/원본캐시/YYYY-MM/` 로컬 캐싱 |

### 추가 (+) — 커맨드 4

| 커맨드 | 설명 |
|---|---|
| `/a10-daily-digest` | 일일보고 수집 실행 |
| `/a10-triage-status` | 3-way 크로스 체크 리포트 + 자동 상태 전이 + `.forge/` 주입 |
| `/a10-triage-sync` | 수동 동기화 (브랜치 재스캔으로 상태·진행 로그 재작성) |
| `/a10-triage-close` | 처리완료/기각/복구 수동 전이 |

### 변경 (✎)

| 자산 | 변경 |
|---|---|
| `a10-git-daily` SKILL (v0.2.0) | STEP 4~8 확장: JIRA 키 추출·3-way 조인·자동 전이·이상 리포트·`.forge/` 주입 |
| `/a10-git-daily` 커맨드 | `--no-triage`, `--no-bridge` 옵션 추가 |
| `/a10-triage` 커맨드 | `--auto-draft` 옵션 (케이스 6 자동 초안용) |
| `a10-maintenance-triage` SKILL (v0.2.0) | 상태 머신·브랜치 매핑·`.forge` 연계 섹션 추가 |
| `triage-review.md` 템플릿 | frontmatter(`status`/`jira_key`/`module`) + `## 📊 진행 로그` 테이블 |
| `lite-review.md` 템플릿 (신규) | `.forge/` 경량 복제본 (~50줄) |
| `.claude-plugin/plugin.json` | version 0.11.0 → 0.12.0 |

### 핵심 설계

**8케이스 매트릭스** — 검토안·커밋·일일보고 3축 조합별 진단·자동 액션 정의.

**상태 머신**
```
수용 → 개발중 → 설계검수 → QA → 배포완료 → 처리완료
        (자동·브랜치 기반)           (수동)
```
- develop/devqa/sqa/master 도달 기준 자동 전이
- 배포완료→처리완료는 고객사 회신 필요 → 수동만 (`/a10-triage-close`)

**자동 액션 규칙** (승인된 7가지 결정)
1. 상태 전이: 수용→개발중→설계검수→QA→배포완료 자동, 처리완료 수동
2. 지연 경고: 수용 후 7일 무커밋
3. 케이스 6(커밋만 있음)만 자동 초안, 케이스 5(커밋+보고)는 알림만
4. 일일보고 ONEFFICE 유지 + 로컬 캐싱
5. `.forge/` 주입 범위: 진행 중만 (완료·기각 제외)
6. JIRA 분류 실패 시 경고만, 자동 라우팅 금지
7. 고도화 자동 스텁 생성하되 `_dashboard.md` 등록은 사용자 승인

### `.forge/` 브리지

소스 레포 루트에 경량 복제 주입:
```
{레포}/.forge/
├── maintenance/   ← 진행 중 검토안 ~50줄 복제
└── enhancements/  ← 진행 중 고도화 스펙
```
- `.gitignore` 에 `.forge/` 자동 추가 (커밋 방지)
- 완료·기각 건은 자동 삭제 (원본은 douzone-forge 에 보존)

### 라우팅 테이블 (a10-jira-classifier 단일 원천)

| 프리픽스 | 트랙 | 저장 위치 |
|---|---|---|
| CSA10/UBA/UAC/EO | 유지보수 | `{모듈}/유지보수/YYYYMMDD-{KEY}-검토안.md` |
| KLAGOP1/A10D/UCAIMP | 고도화 | `{모듈}/tasks/enhancements/` + `_projects/PRJ-*.md` |
| BC10 | 검수 | `{모듈}/tasks/검수/` |
| 기타 | 미분류 | `_reports/unclassified-jira.md` |

### 연계

- `a10-git-daily` 가 3-way 조인의 커밋 축
- `a10-daily-digest` 가 일일보고 축
- `a10-maintenance-triage` 가 검토안 축
- `a10-forge-bridge` 가 3축 교차 결과를 소스 레포에 전파

---

## v0.11.0 (2026-04-20) — 유지보수 접수 검토 표준화

### 배경
CSA10-44921/44945 분석 중 "접수 수용여부 판단"과 "수정안 검토"가 PM 재량에만 의존
되어 표준 없이 진행되던 문제 확인. 유지보수 6개 프로젝트(CSA10/UBA/UAC/EO/BC10 +
고도화 이관처 A10D/UCAIMP/KLAGOP1) 간 라우팅 규칙도 문서화 부재.

### 추가 (+)

| 자산 | 설명 |
|------|------|
| 스킬 `a10-maintenance-triage` | 오류/개선 판정 체크리스트 + 2~3단계 검토 워크플로우 + 이관 규칙 |
| 템플릿 `triage-review.md` | 접수개요 / 수용여부 판단 / 수정안 / 이관 판단 / 고객사 회신 / 검토 서명 6섹션 |
| 커맨드 `/a10-triage` | JIRA 키 입력 → `a10-jira` 조회 + 소스 연계 분석 + 검토안 저장 + 인덱스 갱신 |

### 핵심 설계

**오류 4요소 체크리스트**: 오류 명백성 / 재현성 / 타 고객 영향 / 유사 이력 → 판정 매트릭스

**개선 5요소 체크리스트**: 전 고객 유익성 / 패키지 수용성 / 접수 빈도 / 패키지 영향도 / 대체 수단 → 판정 매트릭스

**이관 규칙**
- CSA10 (A10) → **A10D** (고도화) 또는 **KLAGOP1** (신규·대규모)
- UBA/UAC (Alpha) → **UCAIMP** (Alpha 고도화), 단 Alpha 2017 단종 예정으로 이관 지양
- EO (OmniEsol) → 미정, 사내 합의 후 처리

### 산출물 저장 경로

- 검토안: `{모듈}/유지보수/{YYYYMMDD}-{JIRA키}-검토안.md`
- 인덱스: `{모듈}/유지보수/_index.md`

### 안전 장치

- JIRA 상태·댓글·티켓 생성 **자동 금지** — 검토안은 의사결정 지원 산출물에 한정
- 원인 단정 금지 — 신뢰도 표기 필수 (매우 높음/높음/중간/낮음)
- 고객사 회신은 초안만 생성, 발송은 운영Unit 수동

### 연계

- `a10-jira-query` — JIRA 조회 위임
- `a10-git-daily` — 과거 해결 커밋 검색
- `a10-task-manager` — `{모듈}/tasks/` 계층 관리

---

## v0.10.0 (2026-04-20) — 하네스 4계층 복원: Rules + Hooks

### 배경
2026-04-20 YouTube 짐코딩 영상 계기 심층조사
([`_참조자료/프로세스/20260420-claudecode-하네스4계층-심층조사.md`](../../douzone-forge/_참조자료/프로세스/20260420-claudecode-하네스4계층-심층조사.md))
결과, 하네스는 **3계층이 아닌 4계층**(CLAUDE.md·Rules·Permissions·Hooks)이며 v0.4.0 이후 Rules·Hooks가
실수로 번들에서 누락되어 있었음을 확인. 본 릴리즈로 복원 + 현대화 + 신규 Rule 1종 추가.

### 복원된 Rules (+4)
| Rule | paths scope | 설명 |
|------|-------------|------|
| `verification` | Java/TS/Gradle/SQL | 검증 없이 완료 선언 금지 (fresh evidence 필수) |
| `coding-standards` | Java/TS/JS | Surgical Changes, Small Functions, Immutability, A10 기술스택 |
| `enum-consistency` | Java/TS + Flyway SQL + OpenAPI YAML | DDL↔Entity↔DTO↔FE↔OpenAPI 5레이어 Enum 동일 |
| `markdown-link-policy` (신규) | **/*.md | douzone-forge 상대링크 + URL 인코딩 필수 |

v0.4.0 대비 개선: 각 Rule에 `paths:` 프런트매터 추가 → 해당 파일 작업 시에만 로드되어
CLAUDE.md 토큰 절약(맥락 오염 감소).

### 복원된 Hooks (+4)
| Hook | Event | Matcher | 정책 |
|------|-------|---------|------|
| `db-migration-guard` | **PreToolUse** | Write/Edit/Bash | **차단** (exit 2 + JSON decision=block) |
| `code-quality-reminder` | PostToolUse | Write/Edit | 알림 (Java/TS 체크리스트) |
| `security-auto-trigger` | PostToolUse | Write/Edit | 알림 (Security/JWT/Auth 파일 감지) |
| `build-verify-reminder` | PostToolUse | Write/Edit | 알림 (5회마다) |

v0.4.0 대비 개선:
- `db-migration-guard` 현대화 — 환경변수(`CLAUDE_BASH_COMMAND`) 대신 **stdin JSON** + **exit 2 + JSON stdout**
  으로 Claude Code 현행 hook 프로토콜 반영. `Bash`뿐 아니라 `Write`/`Edit`까지 커버.
- Flyway 경로 패턴 확장 (`db/migration`, `src/main/resources/db/migration`, `flyway`)
- 단위 동작 검증 완료 (DROP TABLE → block / 안전 ALTER → pass / Bash TRUNCATE → block)

### plugin.json 변경
- `hooks` 필드 복원 (`${CLAUDE_PLUGIN_ROOT}` 변수 사용)
- 설명 업데이트: "하네스 4계층 자가진화 체계" 명시

### build.sh 변경
- 번들 zip에 `hooks/`, `rules/` 디렉토리 조건부 포함 (v0.5.0 회귀 방지)

### v0.5.0 회귀 원인 (후행 기록)
v0.4.0 → v0.5.0 릴리즈 시 프로젝트 포트폴리오 기능 추가에 집중하며 `hooks/`, `rules/` 디렉토리를
`build.sh`에서 명시하지 않아 번들에서 탈락. 2026-04-20 심층조사 전까지 문서(`CLAUDE.md`)에는 활성
상태로 남아 있어 **문서-현실 갭**이 5개월간 유지됨. 금번 릴리즈로 해소.

### 후속 로드맵 (v0.11.0~)
- **v0.11.0** Forge 전용 hooks 5종 (`session-checkpoint`, `context-cascade-checker`, `markdown-link-validator`, `prj-progress-sync`, `jira-key-reminder`)
- **v0.12.0** CLAUDE.md 다이어트 (700 → 400줄), compliance 측정 대시보드
- **v0.13.0** `a10-harness-evolver` 스킬 + `/a10-evolve*` 커맨드 (자가진화 엔진)
- **v1.0.0** 자동 생성 Rules/Skills 성과 리포트 + 외부 릴리즈

### 상세 계획
- [`_참조자료/프로세스/20260420-하네스-3계층-적용계획.md`](../../douzone-forge/_참조자료/프로세스/20260420-하네스-3계층-적용계획.md)
- [`_참조자료/프로세스/20260420-claudecode-하네스4계층-심층조사.md`](../../douzone-forge/_참조자료/프로세스/20260420-claudecode-하네스4계층-심층조사.md)
- [`PRJ-2026-014_Amaranth10-Claude-Forge-구축.md`](../../douzone-forge/_projects/PRJ-2026-014_Amaranth10-Claude-Forge-구축.md)

---

## v0.9.0 (2026-04-19) — 비대칭 매핑 + 스코어링 엔진 실구현

### 배경
"PRJ 코드는 douzone-forge에서만 관리되며 개발자는 유지보수 JIRA 키만 남기고 프로젝트 커밋은 프리픽스를 남기지 않는다"는 현실 반영. v0.8.x의 prefix 기반 결정적 매칭은 유지보수에만 유효했으며, 프로젝트 커밋은 **추론 기반 매칭**이 필요함.

### 1) 비대칭 매핑 체계
- 커밋 규약 v2 (`깃-커밋-메시지-규약.md` §2): 유지보수(JIRA 필수) / 프로젝트(prefix 권장이되 강제 아님) 비대칭 분리
- **JIRA 프로젝트 코드 체계 확정 (2026-04-19)**:
  - 유지보수 4종: `CSA10`(A10) / `UBA`(Alpha) / `UAC`(Alpha Cloud) / `EO`(OmniEsol) → 결정적 분기
  - 프로젝트 3종: `KLAGOP1`(A10 통합) / `UCAIMP`(Alpha 고도화) / `A10D`(A10 고도화) → +50점 강신호
- PRJ 12건에 `01.E 연계 키` 섹션 추가

### 2) 스코어링 엔진 실구현 (a10-git-daily SKILL.md)
- **STEP 1** 결정적 매칭 → **STEP 2** 6신호 스코어링 → **STEP 3** 임계 분류(≥70 자동 / 40~69 큐 / <40 미태깅)
- 6신호: JIRA키(+50) · 경로(+40/+20) · 담당자+기간(+30/+10) · 주간보고(+30, v0.9.1) · 키워드(+20) · 브랜치(+10)
- 승인 큐 파일: `_projects/_mapping-queue.md` (매 실행 덮어쓰기)
- 학습 이력: `_projects/_mapping-history.md` (결정값 `auto`/`confirm`/`confirm-override`/`reject`/`reject-maint` 누적)

### 3) PM 승인 큐 커맨드 (신규)
- `/a10-confirm N [PRJ-ID]` — 추정 승인 or 다른 PRJ 수동 귀속
- `/a10-confirm all-high` — 60점 이상 일괄 승인
- `/a10-reject N [--maint [JIRA키]]` — 기각(유지보수 이동 or 미태깅 유지)

### 4) JIRA 스킬 보강 (a10-jira-query)
- 프로젝트 코드 체계 표 반영
- 담당자 JIRA ID: **조직구조.md 단일 원천 참조 방식** 채택 (중복 표 제거)
- 기존 추정 정정: `dus3062`=박수연(not 유지수), `doban7`=이혜영

### 드라이런 검증
- `skills/a10-git-daily/DRYRUN-20260417.md` — 게시판 샘플 4건
- v0.8.1 미태깅 75% → **v0.9.0 미태깅 0%** (자동 25% / 유지보수 25% / 승인 대기 50%)

### 마이그레이션
- 기존 사용자: 조치 불필요. `/a10-git-daily` 실행 시 자동 적용
- 개발자: 유지보수 커밋에 JIRA 키(CSA10 등) 필수. 프로젝트 커밋은 자유
- PM: 실행 후 `_mapping-queue.md` → `/a10-confirm`/`/a10-reject` 처리

### 후속 로드맵
- **v0.9.1** 주간보고 자가신고 파서 (+30 신호 활성화)
- **v0.9.2** 학습 피드백 루프 (3회 override → 연계 키 자동 제안, 2회 reject → 감점)
- **v1.0.0** GitLab webhook 실시간 분석

---

## v0.8.1 (2026-04-18)

### `a10-git-daily` 규약 보강 — 유지보수 분기 룰

초기 dry-run 결과 미태깅 100% + 박수연 `2682f550` 건(JIRA CSA10-40261)을
계기로 "유지보수 vs 프로젝트" 분류 룰을 명문화.

- `[MAINT]` / `[MAINT/CSA번호]` 프리픽스 추가 → 모듈 `history/_timeline.md` "유지보수 로그" 누적 테이블에 기록, PRJ 파일 미건드림
- 휴리스틱: JIRA CSA 티켓·운영성 키워드·유지보수 라인 담당자 → ⚠️ 유지보수 후보 라벨
- 규약 문서 보강: `_참조자료/프로세스/깃-커밋-메시지-규약.md` 3.4 "유지보수 vs 프로젝트 판단 기준"
- 스킬 파싱·출력 로직에 유지보수 분기 추가

---

## v0.8.0 (2026-04-18)

### `a10-git-daily` 스킬 + `/a10-git-daily` 커맨드 추가

Workspace_a10(소스) ↔ douzone-forge(기획·설계) 맥락 연계 자동화 스킬.
공통 식별자 `[PRJ-NNNN/TASK-CODE]`를 축으로 일일 git 커밋을 수집하여
PRJ 포트폴리오 `03. 상세 진행현황`과 모듈 `history/_timeline.md`에 자동 반영.
미태깅 커밋은 경고 리스트로 분리 보고(멱등성 보장, 추측 반영 금지).

- 스킬: `skills/a10-git-daily/SKILL.md`
- 커맨드: `commands/a10-git-daily.md`
- 지원 옵션: `--since`, `--weekly`, `--module`, `--repos`, `--dry-run`, `--include-personal`
- 보조 문서(douzone-forge): `_참조자료/프로세스/깃-커밋-메시지-규약.md` (팀 공지용)

**배경**: 2026-04-18 연계 체계 감사 결과 25칸 매트릭스 중 "TASK↔git" 고리가
5/5 전면 미구축으로 드러남. 이 스킬이 해당 고리를 자동화하고, 검수시나리오 ↔ 소스,
실시간 history 반영 등 후속 연계의 기초가 됨.

---

## v0.7.0 (2026-04-18)

### `a10-jira-query` 스킬 + `/a10-jira` 커맨드 추가

PRJ-2026-012 JIRA 연동 PoC (`amaranth10-jira-collector`, 김경엽 책임 배포 2026-04-17)
를 래핑한 조회 전용 스킬. Claude 세션 중 애드혹 JQL, 8종 프리셋, 일일 배치 결과
로드를 지원한다. 정식 JIRA MCP 전환(05/08 기획-15 이후) 전까지의 실증 단계.

- 스킬: `skills/a10-jira-query/` (SKILL.md + examples 3종 + lib/jira-wrapper.sh)
- 커맨드: `commands/a10-jira.md`
- 6가지 모드: default / 프리셋 / `--list` / `--jql` / `--read` / `--module` / `--ping`
- 조회 전용 (이슈 생성·수정·코멘트 금지), `.env` 비공개, 한글 JQL 필드 쌍따옴표 선검증

---

## v0.6.2 (2026-04-17)

### `a10-oneffice-comment` 스킬 + `/a10-post-comment` 커맨드 추가

ONEFFICE 문서에 멘션(@이름) 포함 댓글을 자동 게시하는 스킬. 멘션 자동완성 팝업이
신뢰된 네이티브 키 이벤트로만 뜨는 제약을 `type("@이름 ")` → `Backspace` 2회
패턴으로 우회한다. 2026-04-17 PRJ-005 분할 안내 댓글 작성에서 검증된 절차 표준화.

- 스킬: `skills/a10-oneffice-comment/SKILL.md`
- 커맨드: `commands/a10-post-comment.md`

---

## v0.6.1 (2026-04-16)

### 공개 마켓플레이스 배포 파이프라인 추가

- `build.sh --deploy` 시 `amaranth10-forge-marketplace` GitHub 레포에 자동 push
- 외부 사용자 설치: `claude plugin marketplace add --github cjrain-12505614/amaranth10-forge-marketplace`
- 버전업 테스트 릴리즈

---

## v0.6.0 (2026-04-16)

### `a10-oneffice-writer` ONEFFICE outline 자동 주입 대응 (0.3.0 유지, 수정 내장)

ONEFFICE(dzeditor) 가 블록 요소(`.doc-header`, `.section`, `.footer` 등)에
`outline: 1px dashed` 를 자동 주입하여 읽기모드에서 점선이 보이는 문제 대응.
Step 4 Python 전처리, Step 8 JS 주입, 디버깅 체크리스트, HTML 가공 원칙에 수정 내장.

- **Step 4 Python 스니펫** — `<style>` 내부 추출 후 `* { outline: none !important; }`
  자동 삽입. `style.group(0)` (태그 전체) vs `style.group(1)` (내부만) 혼동 방지를
  위해 `style_inner` 변수 분리.
- **Step 8 JS 주입** — `* { outline: none !important; }` 포함 `<style>` 태그를
  dzeditor `<head>` 에 동적 삽입. 편집모드 중 즉시 효과, 재저장 필요.
- **디버깅 체크리스트** — "읽기모드에서 점선이 보임" 증상·원인·즉시 수정법 추가.
- **HTML 가공 원칙** — "★ ONEFFICE 전용 필수 CSS" 섹션 신설 (outline, 다크→라이트,
  슬라이드형 min-height). 처음부터 HTML 작성 시 포함 권장.

### `/a10-oneffice-write` 커맨드 보강

- "치명적 주의" 에 outline 점선 증상 + 즉시 수정법 항목 추가.
- `.noext` 방지 규칙 항목 추가 (opener 경유, Step 10.5 확장자 육안 확인).

---

## v0.5.9 (2026-04-16)

### 플러그인 배포 인프라 전면 수정 + `/a10-plugin-save` 커맨드 추가

2026-04-16 배포 시스템 삽질 세션에서 발견한 구조적 문제 4건 수정.
`bash build.sh --deploy` 한 줄로 CoWork 자동 반영까지 완전 자동화 달성.

- **`/a10-plugin-save` 커맨드 신설** — CoWork에서 "플러그인 저장해줘",
  "업데이트해줘" 등 자연어 요청 시 `present_files` 로 저장 UI를 항상 띄움.
  빌드 → `present_files` 제시까지 원스톱.

### `build.sh` 개선

- **`claude plugin install` 자동 실행 추가** — `--deploy` 시 마켓플레이스
  갱신 후 `claude plugin install` 까지 실행. CoWork가 별도 조작 없이
  즉시 새 버전을 반영함 (UI "업데이트" 버튼 클릭 불필요).
- **`.claude-plugin/marketplace.json` zip 제외** — 플러그인 번들 내부에
  stale marketplace.json 이 패키징되던 문제 수정.
- **marketplace 갱신 경로 수정** — `_플러그인/marketplace.json` (top-level,
  EISDIR 에러) → `_플러그인/.claude-plugin/marketplace.json` (표준 위치).

---

## v0.5.6 (2026-04-15)

### `a10-oneffice-writer` 실전 교훈 반영 (0.2.0 → 0.3.0)

2026-04-15 로폼 5차 미팅 회의록 원피스 생성 세션에서 발생한 3대 문제
(`.noext` 확장자, 꺾쇠 1.3 배 오차, 탭 간 HTML 전달 블로킹) 재발 방지.
약 6회 왕복 재작업의 실전 교훈을 스킬 본문에 내장.

- **`.onex` 확장자 강제** — Step 0 을 "아마링크 navigate" 에서 "ONEFFICE 워드
  템플릿 버튼 클릭 경유" 로 교체. 상단 치명적 함정 목록에 0번 항목 추가.
  Step 10.5 `.onex` 홈 화면 육안 검증 + `.noext` 복구 절차 신설 (삭제 금지,
  localStorage 로 복제).
- **zoom 보정 필수화** — Step 7 에 `.dze_document_container` 의 `transform:
  matrix(zoom)` 직접 감지 추가. BCR(viewport px) vs CSS(unzoomed px) 단위
  혼동 경고 박스. "1.3 배 오차 무한 누적" 경고.
- **컨테이너 보존 주입 (모드 B) 을 기본으로 승격** — `<style>` + `.container`
  통째 보존, `.container` 하나에만 inline style. 원본 CSS 전부 보존.
  기존 플랫 주입은 `.container` 없는 HTML 전용 레거시 (모드 A) 로 강등.
- **Step 3.5 신설: 탭 간 HTML 복제 `localStorage['__doc_extract__']` 우회**
  — Chrome MCP 의 `[BLOCKED: Cookie/query string data]` 차단 회피. 기존
  원피스 문서 innerHTML 을 새 `.onex` 에 즉시 복제. `.slice()`, `btoa()`
  실패 사례 명시.
- **디버깅 체크리스트 4 항목 추가** — 1.3 배 오차 / 탭 간 블로킹 /
  `.noext` 증상 / 모드 A 주입 시 `.container` CSS 깨짐.
- **검증된 상수 요약 테이블 확장** — zoom 감지, 기본 zoom, 탭 간 전달,
  확장자 검증 방법 행 추가.

### `a10-oneffice-new-doc-opener` 보강 (0.1.0 유지)

- **`.noext` 방지 경고** — Step 4 하단에 "버튼 텍스트 정확히 `'ONEFFICE 워드'`
  매칭 유지, 느슨하게 바꾸지 말 것" 박스 추가.
- **Simple path** — Step 3 상단에 "빈 `.onex` 만 필요하면 payload/XHR swap
  스킵하고 버튼 클릭만" 경로 추가. writer Step 0 의 기본 경로로 권장.

---

## v0.5.5 (2026-04-15)

### 원피스(ONEFFICE) 쓰기 워크플로우 end-to-end 화

2026-04-15 법무관리 작업 중 확립된 실전 노하우를 스킬·커맨드로 내장.
**모든 스킬은 자체 완결적이며 외부 메모리 파일에 의존하지 않는다** — 검증된
셀렉터·좌표·프리셋 값·코드 스니펫을 SKILL.md 본문에 전부 임베드했다.

**변경: `a10-oneffice-writer` (0.1.0 → 0.2.0)**
- **Step 0 추가** — 새 문서 자동 생성 (`a10-oneffice-new-doc-opener` 호출)
- **Step 1.5 추가** — 단일페이지 모드 전환 (웹페이지형 긴 문서 필수)
- **Step 1.9 추가** — 편집모드 가드 (`main.isContentEditable === true`). 읽기모드 저장 silent no-op 함정 차단
- **Step 2 개선** — A4 세로/여백 보통/줌 130% 프리셋 캐시(`-1px / 644px`) 기본 적용, 실측은 fallback
- **Step 6 추가** — 문서명 변경 (native setter + dispatchEvent, React controlled input 대응)
- **Step 7 경고** — 저장 전 새로고침 금지 / 순서 엄수 명시
- **HTML 가공 원칙 명문화** — `.container` 강제 대신 `<body>` 전체 보존, script/nav/button/form만 제거 ("원본 그대로 주입해야 이쁘다" 원칙)
- description에 자동 인식 패턴 확장

**추가: 스킬 `a10-oneffice-new-doc-opener`**
- ONEFFICE HOME에서 새 워드 문서를 XHR body swap으로 생성
- 기존 빈 탭 재사용 체크 포함
- writer 스킬 Step 0에서 호출되며 단독 사용도 가능

**변경: `a10-oneffice-reader` (0.1.0 → 0.2.0)**
- 외부 워크스페이스 파일 의존 제거 (douzone-forge `CLAUDE.md`, `_참조자료/프로세스/아마링크-참조링크-운영규칙.md` 참조 삭제)
- 아마링크 URL 구조·모듈별 타이틀 규칙 13종 테이블 내장
- Chrome MCP 보안 차단 정리 테이블 내장 (쿼리스트링 차단 이유·회피 방법)
- 이미지 추출 방법 3종 (Canvas base64 / 메타데이터 분리 / overflow+스크린샷 폴백)
- 회수/삭제된 아마링크 처리, 조회 권한 정책 요약 포함
- 자체 완결 선언 — 이제 Peekly·SCU 등 다른 워크스페이스에서도 그대로 작동

**추가: 커맨드 `/a10-oneffice-write`**
- HTML/Markdown/자연어 → 원피스 워드 문서 end-to-end
- 옵션: `--long`/`--webpage`, `--title`, `--from`
- 자동 인식 패턴: "원피스로 ~작성해줘", "ONEFFICE 문서로 만들어줘", "웹페이지처럼 긴 원피스 문서", "~를 원피스 워드로 뽑아줘"

---

## v0.5.3 (2026-04-14)

### 추가: 원피스(ONEFFICE) 읽기/쓰기 스킬 2종

원피스 문서를 정확히 읽고 쓰는 표준 절차를 스킬로 내장. 2026-04-14 법무관리 4/15 미팅 준비
HTML 리포트를 원피스 빈 문서에 주입하는 과정에서 확립한 기법을 재사용 가능하게 일반화.

| 스킬 | 설명 |
|------|------|
| `a10-oneffice-reader` | 원피스 아마링크 본문 텍스트·표·이미지·내부 아마링크 추출 (javascript_tool DOM 접근 방식) |
| `a10-oneffice-writer` | 완성된 HTML을 원피스 편집모드 빈 문서에 주입 (꺾쇠 기반 폭 측정 + 인라인 style 주입) |

**핵심 원칙 (쓰기)**
1. `.dze_page_main` 구조 절대 건드리지 않음 (새로고침 시 리셋)
2. `dze_page_margin_indicator_*` 꺾쇠 좌표로 실제 컨텐츠 폭 측정
3. 클래스·`<style>` 태그 대신 **인라인 style 속성**만 사용 (저장 시 보존되는 유일한 경로)
4. 40KB+ HTML은 로컬 CORS 서버(`127.0.0.1:8765`)로 서빙 후 fetch 주입

**핵심 원칙 (읽기)**
1. 스크롤·스크린샷 반복 금지 → `innerText` 슬라이싱
2. 중첩 iframe: `#open_oneffice_body_iframe → #dzeditor_0 → body`
3. 이미지 추출은 Canvas → `toDataURL()` (img.src 직접 접근 불가)
4. 내부 아마링크는 자동 재귀 금지 — 사용자 확인 후 확장

---

## v0.5.2 (2026-03-29)

### 패치: 세션/현황 스킬 경로 수정 — solo-forge 잔재 제거

세션 시작/종료/현황 보고 기능이 solo-forge 시절의 `docs/00_관리/` 중앙화 구조를 참조하고 있어
douzone-forge의 모듈별 분산 구조와 불일치하는 문제를 수정.

### 수정된 커맨드 (3개)

| 커맨드 | 변경 내용 |
|--------|----------|
| `a10-start-session` | `docs/00_관리/sessions/` → `[모듈]/sessions/_current.md` + `_projects/_dashboard.md` |
| `a10-end-session` | `docs/00_관리/sessions/` → `[모듈]/sessions/_current.md` + `_projects/PRJ-*.md` 연동 |
| `a10-status` | `docs/00_관리/team_plan.md` → `_projects/_dashboard.md` + 모듈별 교차 조회 |

### 수정된 스킬 (2개)

| 스킬 | 변경 내용 |
|------|----------|
| `a10-session-protocol` | 전면 재작성 — 모듈별 `sessions/_current.md` 기반 시작/종료 프로토콜 |
| `a10-status-reporter` | 전면 재작성 — `_dashboard.md` + `PRJ-*.md` + 모듈별 교차 조회 |

---

## v0.5.1 (2026-03-29)

### 패치: 연쇄 업데이트 규칙(Cascade) 스킬 내장

맥락 구조 종합 점검(진단보고서 20260329)에서 발견된 "계층 간 맥락 단절" 문제를 해소하기 위해,
3개 핵심 스킬에 Cascade Update 규칙을 내장.

### 변경된 스킬 (3개)

| 스킬 | 변경 내용 |
|------|----------|
| `a10-context-analyzer` | 7단계 "연쇄 업데이트 (Cascade R1 + R2)" 추가 — context 생성 후 module-overview.md 갱신, PRJ 연결 정보 확인, 문서/INDEX.md 반영 |
| `a10-project-tracker` | 새 프로젝트 등록 9단계 "Cascade R2" 추가 — PRJ 04.연결정보에 context/, history/, INDEX.md, _tech-reference.md, Google Sheets 링크 |
| `a10-context-manager` | "연쇄 업데이트 규칙 (Cascade)" 섹션 신설 — R1(context→module-overview), R3(담당자 5파일 동시 갱신), R4(소스분석→douzone-forge) |

### 배경

douzone-forge CLAUDE.md에 R1~R5 연쇄 업데이트 규칙이 추가되었으나(v0.5.0 이후),
스킬 실행 시 자동으로 cascade를 수행하려면 각 스킬 SKILL.md에도 규칙이 내장되어야 함.

---

## v0.5.0 (2026-03-29)

### 주요 변경: 프로젝트 포트폴리오 관리 + 마크다운 링크 규칙

프로젝트를 포트폴리오 레벨에서 관리하는 체계를 추가.
모듈별 고도화, 크로스 모듈, 수명업무 등 모든 프로젝트 유형을 `_projects/` 폴더에서 통합 추적.

### 추가된 스킬 (+1)

| 스킬 | 설명 |
|------|------|
| `a10-project-tracker` | 프로젝트 포트폴리오 관리 — 대시보드, 프로젝트 등록/업데이트/완료, TASK↔상세진행현황 관계 |

### 추가된 커맨드 (+3)

| 커맨드 | 설명 |
|--------|------|
| `a10-projects` | 프로젝트 포트폴리오 대시보드 조회 (ID 지정 시 상세) |
| `a10-add-project` | 새 프로젝트 등록 (템플릿 기반) |
| `a10-update-project` | 프로젝트 진행현황 업데이트 (TASK + 일자별 로그) |

### 전체 스킬 공통 변경

- **마크다운 링크 규칙** 추가: 모든 스킬에서 경로·파일 참조 시 클릭 가능한 상대 링크 필수
- douzone-forge CLAUDE.md에 `## 마크다운 링크 표기 규칙` 섹션 추가
- douzone-forge CLAUDE.md에 `## 프로젝트 포트폴리오 관리` 섹션 추가
- 세션 시작 체크리스트에 `_projects/_dashboard.md` 확인 단계 추가

### 추가된 douzone-forge 파일

```
_projects/
├── _dashboard.md            ← 전체 프로젝트 포트폴리오 대시보드
├── _templates/
│   └── project-detail.md    ← 프로젝트 상세 템플릿
├── _archive/                ← 완료된 프로젝트 보관
└── PRJ-2025-001_가온-요구사항.md  ← 샘플 (가온 프로젝트)
```

---

## v0.4.0 (2026-03-23)

### 주요 변경: a10-project 플러그인 통합 + Claude Code 개발 지원

D-31 의사결정에 따라 a10-project 플러그인을 amaranth10-claude-forge에 통합.
회사 업무(Amaranth 10 모듈 운영 + 프로젝트 관리)를 단일 플러그인으로 지원.

### 추가된 스킬 (+8, 기존 a10-project에서 이관)

| 스킬 | 설명 |
|------|------|
| `a10-agent-dispatch` | 서브에이전트 팀 투입 (병렬/순차 작업 분배) |
| `a10-decision-tracker` | 의사결정 3단계 심각도 추적 및 관리 |
| `a10-deliverable-management` | 산출물 버전 관리, 명명 규칙, 품질 게이트 |
| `a10-figma-make-reviewer` | Figma Make ↔ 화면설계서 교차 검증 |
| `a10-lessons-learned` | 교훈·패턴 기록 및 재발 방지 |
| `a10-project-bootstrap` | CLAUDE.md 스캐폴드 + 워크스페이스 초기 설정 |
| `a10-session-protocol` | 세션 시작/종료 프로토콜 (컨텍스트 복원·저장) |
| `a10-status-reporter` | 프로젝트 현황 종합 보고 |

### 추가된 커맨드 (+13)

| 커맨드 | 설명 | 출처 |
|--------|------|------|
| `a10-decision` | 의사결정 기록/컨펌 요청 | a10-project |
| `a10-dev-instructions` | 현재 스프린트 구현 지시서 확인 | a10-project |
| `a10-dispatch` | 에이전트 투입 | a10-project |
| `a10-end-session` | 세션 종료 + 로그 저장 | a10-project |
| `a10-extract-design-tokens` | Figma Make 디자인 토큰 추출 | a10-project |
| `a10-guide` | 현재 상태 기반 다음 단계 안내 | a10-project |
| `a10-init-project` | 프로젝트 초기 설정 | a10-project |
| `a10-lesson` | 교훈 기록 | a10-project |
| `a10-review-figma` | Figma Make 검증 실행 | a10-project |
| `a10-start-session` | 세션 시작 프로토콜 | a10-project |
| `a10-status` | 프로젝트 현황 보고 | a10-project |
| `a10-tdd` | RED→GREEN→REFACTOR TDD 워크플로우 | 신규 |
| `a10-verify-step` | Step 완료 빌드/테스트/Enum 검증 | 신규 |

### 추가된 Hooks (+4, Claude Code 개발 품질 지원)

| Hook | 트리거 | 설명 |
|------|--------|------|
| `code-quality-reminder` | PostToolUse (Write/Edit) | Java/TS 파일 수정 시 품질 체크리스트 알림 |
| `security-auto-trigger` | PostToolUse (Write/Edit) | Security/JWT/Auth 파일 감지 시 보안 리뷰 유도 |
| `db-migration-guard` | PreToolUse (Write/Edit) | Flyway SQL에서 DROP TABLE/TRUNCATE 차단 |
| `build-verify-reminder` | PostToolUse (Write/Edit) | 5회 편집마다 빌드 검증 리마인더 |

### 추가된 Rules (+3, Claude Code 코딩 표준)

| Rule | 설명 |
|------|------|
| `verification` | 검증 없이 완료 선언 금지 — 실행 증거 필수 |
| `coding-standards` | Surgical Changes, Small Functions, Immutability 원칙 |
| `enum-consistency` | D-28 기반 Enum 5레이어 일관성 (DDL↔Entity↔DTO↔FE↔OpenAPI) |

### 네이밍 변경 (전체)

모든 스킬(18개)과 커맨드(27개)에 `a10-` 접두어 추가.
다른 플러그인(solo-forge, study-assistant 등)과의 네임스페이스 충돌 방지.

- 스킬: `context-manager` → `a10-context-manager` 등
- 커맨드: `load-context` → `a10-load-context` 등

### 통계

| 항목 | v0.3.0 | v0.4.0 | 변화 |
|------|--------|--------|------|
| 스킬 | 10 | 18 | +8 |
| 커맨드 | 14 | 27 | +13 |
| Hooks | 0 | 4 | +4 |
| Rules | 0 | 3 | +3 |
| Scripts | 3 | 3 | 0 |

---

## v0.3.0 (2026-03-21)

초기 안정화 버전. 모듈 맥락 관리(GNB/LNB), Google Sheets 연동, 문서 큐레이션, 세션 관리 기능 제공.
