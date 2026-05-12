---
name: a10-html-oneffice-builder
description: ONEFFICE 원피스 HTML 작성 표준 — frontend-design 미학 가이드 1차 인용 + ONEFFICE 환경 제약 보강. "원피스 HTML로 작성", "고품질 원피스 문서", "프론트 디자인 적용 원피스 작성" 트리거.
version: 0.1.0
---

# a10-html-oneffice-builder

ONEFFICE 원피스 HTML을 frontend-design 미학 가이드 + ONEFFICE 환경 제약으로 작성하는 표준 절차.

## When (트리거)

- "원피스 HTML로 작성해줘"
- "원피스로 ~를 디자인해줘"
- "고품질 ONEFFICE 문서로 만들어줘"
- "frontend-design 적용해서 원피스에 넣어줘"
- "프론트엔드 가이드 따라 원피스 작성"
- "원피스 보고서 디자인"
- "ONEFFICE 미학 작성"

## Process — 4 STEP

### STEP 1. frontend-design 먼저 로드 (의무, D-02 + Phase U U-05 D-04 강화)

미학 가이드(타이포그래피·색·모션·레이아웃) 인지 후 다음 STEP 진입. **자체 미학 가이드 신설 금지** — Anthropic 공식 플러그인 1차 인용.

**Skill tool 매번 invoke 의무** (Phase U U-05 D-04 강화, 2026-04-28):
- Skill tool로 `frontend-design:frontend-design` 매번 invoke (세션별 활성화 자동 보장)
- invoke 실패 시 즉시 차민수 결재 요청 — **자체 추정·design fallback 금지**
- design 7 skills (accessibility-review·design-critique 등) 사용 금지

또는 직접 Read: `~/.claude/plugins/cache/claude-plugins-official/.../frontend-design/SKILL.md`

**미설치 사용자**: 아래 Cowork Customize 가이드 안내 후 작업 중단.

#### Cowork Customize 사용자 환경 설치 가이드

1. Cowork 좌상단 **Customize** 진입
2. **Plugin Marketplace** 탭 선택
3. 검색: **"claude-plugins-official"**
4. **Frontend design** 플러그인 선택 → **활성화** 토글 ON

상세 SSoT: `규칙/프로세스/HTML-원피스-작성-표준.md` §2 "Cowork Customize 사용자 환경 설치 가이드".

### STEP 2. ONEFFICE 환경 제약 검토

SSoT Read: `규칙/프로세스/HTML-원피스-작성-표준.md`

5축 인지:
1. dzeditor 컨테이너 보존 (`#open_oneffice_body_iframe → #dzeditor_0` → `main`)
2. 단일페이지 모드 전환
3. 꺾쇠 정렬 (zoom 보정 — `cssShiftLeft = -1`, `cssTargetWidth = 644px` 프리셋)
4. localStorage 탭 간 복제
5. 5줄 헤더 의무

### STEP 3. 본문 HTML 작성

- frontend-design 미학 가이드 기준 (타이포그래피·색·레이아웃·모션)
- ONEFFICE 환경 제약 준수 (필수 CSS 3건: outline 제거 + 라이트 테마 + min-height 해제)
- **매 산출 다른 미학** — light/dark·typography·layout 변주 의무

### STEP 4. ONEFFICE 주입

- `a10-oneffice-new-doc-opener`로 빈 문서 확보 (XHR body swap 경로)
- `a10-oneffice-writer`로 HTML 주입 (컨테이너 보존 + 꺾쇠 정렬 + 단일페이지 전환)

## Constraints

ONEFFICE 환경 제약 5축 — 상세는 SSoT(`규칙/프로세스/HTML-원피스-작성-표준.md`) 인용.

- dzeditor `main.innerHTML`에 `<style>` + 루트 컨테이너 통째로 주입
- 단일페이지 모드 (다중페이지 시 A4 한 장씩 잘림)
- 꺾쇠 정렬 zoom 1.3배 보정 (BCR ÷ zoom = CSS px 환산 의무)
- localStorage 동일 오리진 탭 간 복제 (기존 문서 → 새 문서 콘텐츠 이전)
- 5줄 frontmatter 의무 (Phase S 룰 2)
- 외부 CDN 폰트: 시스템 폰트(`-apple-system`·`Pretendard`) 우선 권고

## Never

### 결과물 샘플 박기 금지 (D-01)

본 SKILL.md 자체에 결과물 샘플 X — 절차·제약·인용만. 샘플은 다양성을 죽이는 수렴 장치.

**예외**: 절차 코드블록(설치 명령·DOM 셀렉터 등 — 결과물 샘플 아닌 절차)은 허용.

### 메모리 인용 금지 (D-04)

본 Skill은 사내 전사 배포 대상. 자비스 메모리는 차민수 로컬에만 존재 → 배포 사용자에게는 부재.

**금지 어구**: 사람별 메모리 영역의 학습 번호·인덱스·개인 메모 파일 참조 — 대신 SSoT .md 인용으로 대체. 상세 금지 패턴은 SSoT(`규칙/프로세스/HTML-원피스-작성-표준.md` §8) 인용.

### 동일 미학 재현 회피

매 산출 새로운 aesthetic direction — frontend-design 미학 가이드 기준에 따라 light/dark·typography·layout 다양화.

## SSoT

- `규칙/프로세스/HTML-원피스-작성-표준.md` (Phase T 신설 SSoT — 5축 환경 제약 + 작성 절차)
- `규칙/프로세스/업무보고-체크-운영규칙.md` 룰 2 (5줄 헤더 의무)

## 의존 Skill

- `a10-oneffice-new-doc-opener` (빈 문서 확보)
- `a10-oneffice-writer` (HTML 주입 — 5축 환경 제약은 본 SSoT 인용)

## 의존 플러그인

- `frontend-design` (claude-plugins-official 마켓 — 미학 가이드 1차 인용)
