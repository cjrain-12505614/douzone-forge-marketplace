---
name: dz-html-oneffice-builder
description: ONEFFICE 원피스 HTML 작성 표준 — dz-frontend-design 미학 가이드(Anthropic frontend-design 원문 동봉) + ONEFFICE 환경 제약 보강. "원피스 HTML로 작성", "고품질 원피스 문서", "프론트 디자인 적용 원피스 작성" 트리거.
version: 0.3.0
---

<!-- 변천사
 - v0.1.0 신설 — frontend-design 미학 + ONEFFICE 환경 제약 4STEP
 - v0.2.0 dz-oneffice-kit OF 인용 전환(2026-07-14, T4 마이그레이션) — 셀렉터·프리셋을 OF.SEL/OF.PRESET 정본 인용으로 전환, 인라인 수치는 폴백 사본으로 병행, 배관 실행은 opener+writer 위임 명시
 - v0.3.0 미학 근거를 dz-frontend-design 단일 진입으로 전환(2026-10-02) — 원본 호출 의무·「invoke 실패 시 결재 요청 후 중단」·Cowork 설치 안내 삭제(원본이 플러그인에 동봉됨), light/dark 변주 의무 삭제(원피스 흰 바탕 고정과 충돌), 설계안·자가 비평 단계 추가
-->


# dz-html-oneffice-builder

ONEFFICE 원피스 HTML을 `dz-frontend-design` 미학 가이드(Anthropic frontend-design 원문 동봉) + ONEFFICE 환경 제약으로 작성하는 표준 절차.

## OF 라이브러리 인용 (원피스 DOM 배관 정본 = dz-oneffice-kit)

이 스킬의 원피스 DOM 조작(중첩 iframe 접근·편집모드 판정/전환·주입·꺾쇠 정렬·저장 등 배관)은 정본 `dz-oneffice-kit`의 **OF 라이브러리**(`window.OF`)를 단일 출처로 사용한다. 실행 시 그 SKILL.md의 OF 코드블록을 `javascript_tool`로 원피스 탭에 1회 주입(`window.OF` 상주)하고 이후 `OF.*`를 호출한다. **셀렉터·좌표·프리셋은 `OF.SEL`/`OF.COORD`/`OF.PRESET` 단일 정의**를 따르며, 이 스킬이 값을 별도로 베껴 두지 않는다(드리프트 방지).

**이 스킬의 위치 — 배관은 위임, 참조만 직접**: 이 스킬은 HTML 작성·미학 적용이 고유 몫이고, 실제 DOM 주입·저장 배관은 `dz-oneffice-new-doc-opener`(빈 문서 확보)와 `dz-oneffice-writer`(주입·정렬·저장)에 **위임**한다. OF 라이브러리를 탭에 주입하고 `OF.*`를 호출하는 주체는 그 두 스킬이다. 이 스킬이 OF에서 **직접 참조**하는 것은 아래 두 가지뿐이다.

- **`OF.PRESET`** — 꺾쇠 폭·shift 프리셋(`A4-normal`={width:644, shift:-1, padL:76, zoom:1.3} 등). STEP 2·Constraints의 폭/shift 값은 이 프리셋을 정본으로 인용한다.
- **`OF.SEL`** — 환경 제약(중첩 iframe·단일페이지 모드·문서설정 등)에서 쓰는 셀렉터 상수. dzeditor 컨테이너 체인(`OF.SEL.outerIframe → OF.SEL.editorIframe → OF.SEL.main`)·단일페이지·여백 셀렉터를 참조한다.

주입·저장의 실행 함수(`OF.injectHTML`·`OF.alignBracket`·`OF.pageSetup`·`OF.save` 2단계 등)는 위임처인 writer가 호출한다 — 상세는 `dz-oneffice-writer`·`dz-oneffice-kit` 참조.

## When (트리거)

- "원피스 HTML로 작성해줘"
- "원피스로 ~를 디자인해줘"
- "고품질 ONEFFICE 문서로 만들어줘"
- "frontend-design 적용해서 원피스에 넣어줘"
- "프론트엔드 가이드 따라 원피스 작성"
- "원피스 보고서 디자인"
- "ONEFFICE 미학 작성"

## Process — 4 STEP

### STEP 1. dz-frontend-design 먼저 로드 (의무)

- Skill tool로 `dz-frontend-design` 을 불러 그 안내대로 동봉된 `upstream/frontend-design-SKILL.md`(Anthropic 원문)까지 읽는다. 이 플러그인에 들어 있으므로 Claude Code·Cowork·Codex 어디서나 같은 사본을 쓴다. 별도 설치나 결재 대기는 없다.
- **자체 미학 가이드 신설 금지** — 미학 판단은 원본과 `dz-frontend-design` 보강 문서만 근거로 한다.
- design 계열 스킬(accessibility-review·design-critique 등)을 미학 근거로 쓰지 않는다.

### STEP 2. ONEFFICE 환경 제약 검토

SSoT Read: `규칙/프로세스/HTML-원피스-작성-표준.md`

5축 인지 (셀렉터·프리셋은 `OF.SEL`/`OF.PRESET` 정본 인용 — 아래 인라인 값은 폴백 사본, 1 마이너 버전 병행):
1. dzeditor 컨테이너 보존 (`OF.SEL.outerIframe → OF.SEL.editorIframe → OF.SEL.main` = `#open_oneffice_body_iframe → #dzeditor_0 → .dze_page_main`)
2. 단일페이지 모드 전환 (`OF.SEL.splitOn`)
3. 꺾쇠 정렬 (zoom 보정 — 정본 `OF.PRESET['A4-normal']`={width:644, shift:-1, padL:76, zoom:1.3}. 인라인 폴백: `cssShiftLeft = -1`, `cssTargetWidth = 644px`)
4. localStorage 탭 간 복제 (`OF.stashMain`/`OF.applyStash`)
5. 5줄 헤더 의무

### STEP 3. 본문 HTML 작성

- `dz-frontend-design` 설계안 절차를 따른다 — 주제·독자·용도 확인 → 설계안(색 4~6개·서체와 역할·배치·원칙 + 근거·제약 칸) → 피할 기본값(§4) 대조 → 작성
- ONEFFICE 환경 제약 준수 (필수 CSS **4건**: `<style>` outline 제거 + **인라인 `outline:none`** + 라이트 테마 + min-height 해제)
- ⛔ **표 셀(`td`·`th`) 안 블록은 `p style="margin:0"`·`span style="display:block"` 우선** — 편집기가
  셀의 직계 자식 `div`·`pre` 에 회색 점선을 얹고 **읽기모드에도 남는다**(실측 2026-08-14). 셀 안에 여러 단계
  구조가 필요해 `div` 를 쓸 때는 인라인 `outline:none` 을 함께 넣는다(`OF.outlineGuard(html)` 로 일괄 처리).
- **방향은 주제에서, 바탕은 흰색 고정** — 문서의 주제·독자·용도에서 방향을 끌어낸다. 양식·템플릿·브랜드가 방향을 정했으면 그대로 따른다. 원피스는 흰 바탕이 고정이므로 어두운 테마로 바꾸지 않는다. 같은 결과가 반복되는 것은 설계안 기록(`_개인/sessions/{작업}/`)과 대조해 막는다
- **작성 후 화면으로 확인한다** — 주입 전 HTML 미리보기나 주입 후 편집기 화면을 스크린샷으로 보고 `dz-frontend-design` §8 마무리 점검을 거친다(원본의 자가 비평·「장신구 하나 빼기」)

### STEP 4. ONEFFICE 주입 (배관 위임)

- `dz-oneffice-new-doc-opener`로 빈 문서 확보 (XHR body swap 경로)
- `dz-oneffice-writer`로 HTML 주입 (컨테이너 보존 + 꺾쇠 정렬 + 단일페이지 전환)
- 주입·저장 배관은 위임처(writer)가 OF로 실행한다: `OF.injectHTML` → `OF.alignBracket({preset:'A4-normal'})` → `OF.pageSetup` → **`OF.save()` 2단계**(읽기모드면 내부에서 `OF.enterEdit()` 편집 전환 폴링 → 저장버튼 click → 탭 제목 판정, 실패 시 `needsPhysicalClick` 신호). 실제 마우스 폴백은 writer의 호출부 `computer`가 수행한다 — 이 스킬은 배관을 직접 다루지 않는다.

## Constraints

ONEFFICE 환경 제약 5축 — 상세는 SSoT(`규칙/프로세스/HTML-원피스-작성-표준.md`) 인용.

> 셀렉터·프리셋 값은 `OF.SEL`/`OF.PRESET`(dz-oneffice-kit 정본) 인용. 아래 인라인 수치는 폴백 사본이며 정본과 어긋나면 정본 우선.

- dzeditor `main.innerHTML`(`OF.SEL.main`)에 `<style>` + 루트 컨테이너 통째로 주입
- 단일페이지 모드 (다중페이지 시 A4 한 장씩 잘림 — `OF.SEL.splitOn`)
- 꺾쇠 정렬 zoom 1.3배 보정 (BCR ÷ zoom = CSS px 환산 의무. 폭·shift는 `OF.PRESET` 정본, 인라인 폴백 `644/-1`)
- localStorage 동일 오리진 탭 간 복제 (`OF.stashMain`/`OF.applyStash` — 기존 문서 → 새 문서 콘텐츠 이전)
- 5줄 frontmatter 의무 (Phase S 룰 2)
- 서체: 외부 CDN(외부 서버에서 불러오는 방식) 서체 금지. 원피스 편집기 서체 메뉴의 표시명을 그대로 쓴다 — 메뉴에 없는 이름(Pretendard·Georgia 등)은 무시되어 본고딕으로 보였다(2026-06-30 실측). 고르는 원칙은 `dz-frontend-design` §5, 상세는 SSoT §7

## Never

### 결과물 샘플 넣기 금지 (D-01)

본 SKILL.md 자체에 결과물 샘플 X — 절차·제약·인용만. 샘플은 다양성을 죽이는 수렴 장치.

**예외**: 절차 코드블록(설치 명령·DOM 셀렉터 등 — 결과물 샘플 아닌 절차)은 허용.

### 메모리 인용 금지 (D-04)

본 Skill은 사내 전사 배포 대상. 자비스 메모리는 {이름} 로컬에만 존재 → 배포 사용자에게는 부재.

**금지 어구**: 사람별 메모리 영역의 학습 번호·인덱스·개인 메모 파일 참조 — 대신 SSoT .md 인용으로 대체. 상세 금지 패턴은 SSoT(`규칙/프로세스/HTML-원피스-작성-표준.md` §8) 인용.

### 같은 미학으로 수렴하지 않기 — 단, 바탕색은 바꾸지 않는다

설계안의 근거 칸(주제·브랜드)에서 방향을 정하고, 지난 설계안 기록과 겹치면 바꾼다. 변주를 위해 어두운 테마를 쓰지 않는다(원피스 흰 바탕 고정).

## SSoT

- `규칙/프로세스/HTML-원피스-작성-표준.md` (Phase T 신설 SSoT — 5축 환경 제약 + 작성 절차)
- `규칙/프로세스/업무보고-체크-운영규칙.md` 룰 2 (5줄 헤더 의무)

## 의존 Skill

- `dz-oneffice-kit` (원피스 DOM 배관 정본 — `OF.PRESET`·`OF.SEL` 등 셀렉터·좌표·프리셋 단일 출처. 이 스킬은 PRESET·환경 제약만 직접 참조, 실행 배관은 opener+writer 위임)
- `dz-oneffice-new-doc-opener` (빈 문서 확보)
- `dz-oneffice-writer` (HTML 주입·저장 — OF 배관 실행 주체. 5축 환경 제약은 본 SSoT 인용)

## 미학 근거

- `dz-frontend-design` (이 플러그인 동봉 — Anthropic frontend-design 원문 `upstream/frontend-design-SKILL.md` + 더존 보강). 공식 `frontend-design` 플러그인을 따로 설치할 필요는 없다
