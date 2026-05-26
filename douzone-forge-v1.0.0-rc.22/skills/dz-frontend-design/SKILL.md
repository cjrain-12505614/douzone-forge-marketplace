---
name: dz-frontend-design
description: Cowork 환경에서 Anthropic 공식 frontend-design 플러그인 직접 호출이 불가할 때의 폴백 미러. 더존비즈온 보고서·대시보드·HTML 산출물의 고품질 시각화를 차분한 엔터프라이즈 톤으로 작성. "프론트 디자인 적용", "고품질 HTML 작성", "보고서 시각화", "대시보드 디자인", "frontend-design 폴백" 트리거. 원본 Anthropic frontend-design (claude-plugins-official) 핵심 미러 + 한국어/더존 컨텍스트 보강.
version: 0.1.0
source: Anthropic claude-plugins-official / frontend-design (v1, 2026-04 시점 미러)
license: 원본 frontend-design 라이선스 준수 (Complete terms in original LICENSE.txt — claude-plugins-official 마켓플레이스)
---

# dz-frontend-design

Anthropic 공식 `frontend-design` 플러그인의 핵심을 douzone-forge 플러그인 안으로 흡수한 미러 스킬. **Cowork 환경에서 원본 frontend-design 직접 호출이 불가한 갭 (TASK-S-05 핵심) 의 폴백 수단** 으로 신설.

---

## 1. When to use — 호출 우선순위

본 스킬은 **원본 frontend-design 의 폴백**이다. 호출 우선순위는 환경에 따라 다르다.

| 환경 | 1차 권장 | 2차 폴백 |
|------|---------|---------|
| **Claude Code** (CLI · IDE 확장) | `frontend-design:frontend-design` 원본 직접 호출 | 본 스킬 사용 안 함 |
| **Cowork** (데스크탑 자율 에이전트) | Anthropic frontend-design 플러그인 활성화 후 원본 호출 (Customize Marketplace 가이드 참고) | **본 스킬 dz-frontend-design 폴백** |

> **원본 우선 원칙**: 본 스킬은 라이선스·유지보수 비용을 감수한 미러이므로, 원본이 호출 가능한 환경에서는 항상 원본을 우선한다. 원본 frontend-design 이 향후 Cowork 에서도 정식 호출 가능해지면 본 스킬은 폴백 의무를 잃고 archive 대상이 된다.

### 트리거

다음 표현이 등장하면 본 스킬 또는 원본 frontend-design 을 호출:

- "프론트 디자인 적용해줘"
- "고품질 HTML 작성해줘"
- "보고서를 시각화해줘"
- "대시보드 디자인해줘"
- "frontend-design 적용"
- "이 데이터를 잘 보이게 정리해줘 / 시각화"
- "발표 자료용 HTML"
- "엔터프라이즈 보고서 만들어줘"

### When NOT to use — 본 스킬을 호출하지 않는 경우

- **단순 마크다운 정리** — 시각화 없이 텍스트만 정돈하는 작업은 본 스킬 불필요
- **ONEFFICE 환경 대상** — `dz-html-oneffice-builder` 가 ONEFFICE 제약 (dzeditor 컨테이너 보존 등) 까지 통합 처리한다. 본 스킬은 ONEFFICE 외부 자체완결 HTML 산출물 전용
- **그래프·차트 라이브러리 핵심 작업** — Chart.js·D3 등 라이브러리 사용이 핵심인 경우, 본 미학 가이드는 보조적으로만 적용

---

## 2. Design Thinking — BOLD 미학 방향 우선 결정

코드 작성 전에 컨텍스트를 파악하고 **명확한 미학 방향을 선택**한다. 절충안 금지.

### 2.1 4축 파악

- **Purpose**: 이 인터페이스가 풀어야 하는 문제는? 누가 사용하는가?
- **Tone**: 극단을 선택한다. brutally minimal / maximalist chaos / retro-futuristic / organic-natural / luxury-refined / playful-toy / editorial-magazine / brutalist-raw / art-deco-geometric / soft-pastel / industrial-utilitarian — 등에서 영감을 받되, 컨텍스트에 진정으로 맞는 방향을 새로 정의한다.
- **Constraints**: 기술 요구사항 (프레임워크 · 성능 · 접근성 · 인쇄)
- **Differentiation**: 이 디자인을 **잊을 수 없게** 만드는 한 가지는?

### 2.2 더존비즈온 컨텍스트 — 기본 톤 권장

본 플러그인의 주 사용 영역은 **엔터프라이즈 거버넌스 · 기획·설계 보고서 · 본부장/CPO 의사결정 자료**다. 다음 톤이 기본 권장 후보:

- **Editorial Gravity** — FT Weekend × 금융 연차보고서 × 건축 매거진 톤. 차분한 권위감. {이름} 수석의 보고서·발표 자료에 적합.
- **Refined Minimalism** — 흰 여백 + 정밀 그리드 + 한정된 색상. 공식 발표·이사회 보고에 적합.
- **Industrial Utilitarian** — Bloomberg Terminal 톤. 고밀도 데이터 모니터링 대시보드.
- **Soft Editorial Light** — 따뜻한 페이퍼 톤 + 세리프 헤드라인. 통합본·운영 가이드.

> ⚠️ **기본 톤 권장은 출발점일 뿐**. 사용자가 명시적으로 maximalist · playful · brutalist 등 다른 방향을 요청하면 그대로 따른다. 본 컨텍스트 안내가 미학 다양성을 제약하면 안 된다.

### 2.3 CRITICAL — 명확한 방향, 정밀 실행

> Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work — the key is intentionality, not intensity.

미학 의도가 명확하면 어느 극단이든 통한다. 중간 어딘가에서 머뭇거리는 디자인은 항상 실패한다.

---

## 3. Frontend Aesthetics Guidelines

### 3.1 Typography — 글꼴은 가장 큰 미학 결정

- **회피 폰트**: Inter · Roboto · Arial · system fonts · Space Grotesk — 모두 AI 슬롭의 시그니처. 매 세션마다 흔한 선택으로 수렴하지 말 것
- **권장 페어링**: 특징적 디스플레이 폰트 + 정제된 본문 폰트 조합
- **한국어 본문**: **Pretendard Variable** (cdn.jsdelivr.net/gh/orioncactus/pretendard) 기본. Noto Sans KR 가능. 한국어 가독성·자간·문자 폭 우수
- **한국어 디스플레이/세리프**: Noto Serif KR · 본명조 (조선일보 명조 톤) 또는 한국어 미지원 세리프(Fraunces · Bricolage · Newsreader 등)와 Pretendard 의 영문/한글 분리 운용
- **영문 디스플레이 권장 후보**: Fraunces (가변 SOFT/opsz, 편집디자인 적합) · Newsreader · Bricolage Grotesque · IBM Plex Serif · Spectral · Crimson Pro · Instrument Serif
- **모노스페이스**: JetBrains Mono · IBM Plex Mono (Consolas·Courier 회피)
- **font-feature-settings**: `"ss01", "tnum"` 등으로 숫자 폭 통일 (재무·표 표시에 결정적)

### 3.2 Color & Theme — 단일 강조색 + 헤어라인

- CSS variables 로 일관성 보장
- **지배 색 + 날카로운 강조색** 이 균등 분포 팔레트보다 우수
- **회피 컬러**: 보라색 그라데이션 + 흰 배경 (AI 슬롭 시그니처) · 무의미한 무지개 그라데이션
- 다크/라이트 모드는 컨텍스트에 따라 결정 — 매번 다크에 수렴 금지
- 더존 권장: 따뜻한 페이퍼 톤 (#f4ecdc 류) + 잉크 블랙 + burnt sienna(#b54822) 단일 강조 / 또는 차가운 다크 네이비 + 호박색 강조 등
- 헤어라인 (1px @ 12% opacity) 으로 정보 구분 — 박스·shadow 남발보다 우수

### 3.3 Motion — 임팩트 모먼트 1회

- HTML 은 CSS-only 우선. React 는 Motion (framer-motion) 사용 가능 시 활용
- **고임팩트 1회 > 산만한 마이크로 모먼트** — 초기 페이지 로드 시 staggered reveal (animation-delay) 한 번이 호버 위글 100개보다 우수
- 스크롤 트리거 · 호버 상태는 surprise 요소가 있을 때만 사용
- **`prefers-reduced-motion: reduce`** 미디어 쿼리로 모션 비활성화 옵션 반드시 제공
- 엔터프라이즈 거버넌스 톤에서는 모션 최소화 (fade-in 캐스케이드 정도만)

### 3.4 Spatial Composition — 예상 깨기

- 비대칭 · 그리드 깨기 · 의도적 오버랩 · 대각 흐름
- 12컬럼 그리드 기반에서 의도적으로 spans 깨기
- 관대한 음의 공간 OR 통제된 고밀도 — 중간 어딘가 회피

### 3.5 Backgrounds & Visual Details — 분위기와 깊이

- 단색 배경 디폴트 금지
- 컨텍스트에 맞는 텍스처 적용: gradient mesh · noise texture · 기하학 패턴 · layered transparency · dramatic shadow · 장식 보더 · custom cursor · grain overlay
- 페이퍼 톤에서는 **SVG noise filter** 로 종이 질감 부여 (`feTurbulence` + `feColorMatrix`)
- 엔터프라이즈 톤에서는 절제 — grain · subtle 만 사용, 화려한 텍스처 회피

### 3.6 일반 금지사항 (AI 슬롭 회피)

- 흔한 폰트 (Inter · Roboto · Arial · system)
- 진부한 컬러 스킴 (특히 보라색 그라데이션 + 흰 배경)
- 예측 가능한 레이아웃·컴포넌트 패턴
- 컨텍스트 특화 캐릭터가 없는 쿠키 커터 디자인

---

## 4. 구현 결과물 요건

다음 4축을 모두 충족해야 한다:

1. **Production-grade and functional** — 실제 동작하는 코드. 데모용 더미 X
2. **Visually striking and memorable** — 미학적으로 강렬하고 기억에 남는다
3. **Cohesive with a clear aesthetic point-of-view** — 일관된 미학 관점
4. **Meticulously refined in every detail** — 모든 디테일이 정밀하게 다듬어짐

### 4.1 복잡도 매칭

> Match implementation complexity to the aesthetic vision.

- **Maximalist** 디자인: 풍부한 코드 + 광범위한 애니메이션·효과
- **Minimalist / Refined** 디자인: 절제 · 정밀 · 간격·타이포·서브틀 디테일에 집중

우아함은 비전을 잘 실행하는 데서 나온다 — 분량이 아니라.

---

## 5. 더존비즈온 컨텍스트 보강

### 5.1 한국어 본문 처리

- 본문 한국어 + 영문 혼용 시 **Pretendard Variable** 단일 폰트로 처리 (자체 영문 글리프 우수)
- 한국어 줄높이 1.55 ~ 1.65 권장 (라틴 1.4 ~ 1.5 보다 약간 높게)
- 영문 강조 (이탤릭 · 굵게) 시 한국어와 폰트 분리 시 자간·줄높이 미스매치 점검

### 5.2 인쇄 친화

- 더존 보고서는 PDF 변환·인쇄 동반 — `@media print` 블록 필수
- 배경 grain · 노이즈는 인쇄 시 제거
- `page-break-inside: avoid` 로 섹션·테이블 페이지 단절 방지
- 링크는 인쇄 시 underline 제거 또는 출력 URL 병기 옵션

### 5.3 ONEFFICE 환경 분리

- 본 스킬은 **자체완결 HTML 산출물 전용**
- ONEFFICE 문서 주입 (편집모드 HTML 삽입) 이 핵심인 작업은 `dz-html-oneffice-builder` 또는 `dz-oneffice-writer` 호출 — 본 스킬과 혼동 금지

### 5.4 PRJ 코드 표기 규칙 준수

본 스킬로 작성되는 HTML 산출물에서도 [`규칙/프로세스/공용-개인-경계-규칙.md`](../../../../../Workspace/douzone-forge/규칙/프로세스/공용-개인-경계-규칙.md) 및 PRJ 코드 표기 규칙 (CLAUDE.md "PRJ 코드 표기 규칙" 섹션) 준수. **PRJ 코드 단독 사용 금지** — 항상 프로젝트명과 함께 표기. 예: `Amaranth10-Claude-Forge 구축(PRJ-2026-014)`.

---

## 6. 검증 체크리스트 (작성 후)

산출 직전 자가 점검:

- [ ] 폰트 선택이 Inter · Roboto · Arial · Space Grotesk 회피했는가?
- [ ] 컬러 팔레트가 보라색 그라데이션 + 흰 배경 진부 패턴이 아닌가?
- [ ] 미학 방향이 한 가지로 명확한가 (절충 회피)?
- [ ] 한국어 본문 폰트 처리가 가독성 우수한가 (Pretendard 등)?
- [ ] `prefers-reduced-motion` 미디어 쿼리가 있는가?
- [ ] `@media print` 블록으로 인쇄 친화가 되어 있는가?
- [ ] PRJ 코드 단독 사용 없는가 (프로젝트명과 병기)?
- [ ] 결과물이 "쿠키 커터 AI 디자인" 으로 보이지 않는가?

---

## 7. 라이선스 · 유지보수 정책

### 7.1 라이선스

본 스킬은 **Anthropic `claude-plugins-official` 마켓플레이스의 `frontend-design` 플러그인 핵심을 미러한 폴백 수단**이다. 원본 라이선스 (`LICENSE.txt`) 의 조건을 그대로 준수한다.

원본 위치: `~/.claude/plugins/cache/claude-plugins-official/frontend-design/unknown/skills/frontend-design/SKILL.md`

- 본 미러는 원본 핵심 보존을 우선으로 하되, 한국어 풀이 · 더존 컨텍스트 보강은 본 플러그인 (douzone-forge) 자체 작업으로 추가
- 원본의 라이선스 조항을 위반하는 사용은 금지
- 본 스킬을 외부 재배포할 경우 원본 출처 명기 의무

### 7.2 유지보수 정책 — 분기 (Divergence) 관리

- **원본 변경 감지**: Anthropic 측 frontend-design 갱신 시 본 미러를 검토하고 동기화 필요
- **분기 정책**: 본 미러가 원본과 의미 있게 분기 (예: 한국어 컨텍스트 핵심 추가) 한 경우, SKILL.md 본문 상단에 분기 명시
- **archive 조건**: Anthropic frontend-design 이 Cowork 에서도 정식 호출 가능해지면 본 스킬은 폴백 의무를 잃는다. 그 시점에 `_archive/` 로 이동, plugin.json 에서 제거

### 7.3 본 스킬 신설 사유 (히스토리)

- **2026-05-12** — {이름} 수석 옵션 B 결재 (Cowork ↔ Claude Code 플러그인 상속 갭 폴백 신설). PRJ-2026-013 기술위원회 AI 개발툴 TFT 트랙의 부산물로 식별된 갭. 옵션 C (cowork-to-claudecode-migration.md SSoT 갱신) 와 병행 채택.

---

## 8. 본 스킬 vs 관련 스킬

| 스킬 | 핵심 | 본 스킬과의 관계 |
|------|------|----------------|
| **원본 `frontend-design:frontend-design`** (Anthropic) | 1차 권장 — Claude Code 환경에서 우선 호출 | 본 스킬이 미러하는 출처 |
| **`dz-html-oneffice-builder`** | ONEFFICE 원피스 HTML 작성 표준 | ONEFFICE 환경 제약 통합 처리. 본 스킬은 ONEFFICE 외부 자체완결 HTML 전용 |
| **`dz-oneffice-writer`** | 원피스 편집모드 HTML 주입 | 산출물 주입 단계 — 본 스킬로 HTML 생성 후 호출 가능 |
| **`dz-figma-make-reviewer`** | Figma Make 산출물 검증 | 디자인 시스템 적합성 검증 — 본 스킬의 산출물에 후속 적용 가능 |

---

## 9. 호출 예시

### 9.1 Cowork 환경에서 폴백 사용 — 보고서 시각화

> 사용자: "이 통합본을 frontend-design 으로 시각화해줘"

1. Cowork 환경 인지 → 원본 frontend-design 활성화 여부 확인 (실패 시 본 폴백 진입)
2. 본 스킬 §2 Design Thinking 4축 파악 → 미학 방향 결정 (예: Editorial Gravity)
3. §3 Aesthetics Guidelines 적용 → 폰트 · 컬러 · 모션 · 레이아웃 결정
4. §5 더존 컨텍스트 보강 (한국어 처리 · 인쇄 친화 · PRJ 표기) 적용
5. §6 검증 체크리스트 통과 후 산출

### 9.2 Claude Code 환경에서는 본 스킬 호출 거절

> 사용자: "/dz-frontend-design 으로 디자인해줘" (Claude Code 환경)

→ 응답: "Claude Code 환경에서는 `frontend-design:frontend-design` 원본 직접 호출이 우선입니다. 본 폴백 스킬은 Cowork 환경 전용입니다. 원본으로 진행하겠습니다." → 원본 호출로 위임.

---

_본 SKILL.md 는 Anthropic `frontend-design` 플러그인 핵심을 douzone-forge 플러그인 안에 미러한 폴백 수단. 원본 라이선스 준수. 2026-05-12 {이름} 수석 옵션 B 결재 신설._
