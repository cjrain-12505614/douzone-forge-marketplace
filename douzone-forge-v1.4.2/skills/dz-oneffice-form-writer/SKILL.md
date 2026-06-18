---
name: dz-oneffice-form-writer
description: 사용자가 "일일업무보고 작성", "프로젝트 상세 진행현황 추가", "양식 셀 주입", "원피스 양식 데이터 채워줘" 같은 요청을 할 때 사용. 사내 표준 양식 5종(일일보고 Unit장/Cell리더/멤버, 프로젝트 상세 신규개발/유지보수, 주간보고)의 셀에 자바스크립트 문서 객체 모델(DOM, 문서 객체 모델) 프로그램 간 연동 창구(API, 프로그램 간 연동 창구)로 양식 정합(폰트·블릿·아마링크 자동 적용) 데이터를 주입한다. 단일 출처(SSoT, 단일 출처) — `규칙/프로세스/원피스-작성방식-선택-자동화-표준.md`. 방식 1(웹 문서 마크업 언어(HTML, 웹 문서 마크업 언어) 강제 주입)은 `dz-oneffice-writer` 별도 스킬 영역.
---

# dz-oneffice-form-writer — 원피스 양식 정합 데이터 주입

## 1. 진입 신호

본 스킬은 다음 사용자 입력에서 자동 호출된다:

- "일일업무보고 작성", "오늘 보고 채워줘"
- "프로젝트 상세 진행현황 N건 추가"
- "양식 셀 주입", "원피스 양식 데이터 채워줘"
- 사용자가 사내 표준 양식(일일·주간·프로젝트 상세) 원피스 URL 공유 + 데이터 입력 요청

## 2. 단일 출처 인용 의무

본 스킬 실행 전 다음 단일 출처를 반드시 읽는다:

- `규칙/프로세스/원피스-작성방식-선택-자동화-표준.md` (1,599행) — §5(양식 매핑) · §6(SCHEMA + 헬퍼 함수 7종) · §7(표별 운영 룰 14개 영역) · §9(한계 + 해법 후보)

§6 헬퍼 함수 7종을 본문 그대로 사용:

| # | 함수 | 시그니처 | 용도 |
|---|---|---|---|
| 1 | `wrapTextCell` | `(cell, text, align, lineHeight)` | 일반 텍스트 셀 `<p>` wrap (정렬·줄 간격 자동) |
| 2 | `wrapBulletCell` | `(cell, sections)` | 2단계 블릿 `<ul>/<li>` wrap (업무내용 등) |
| 3 | `wrapHierarchyBulletCell` | `(cell, units)` | 3단계 계층 종합 보고 wrap (표 8 Unit/Cell 업무 실적 요약) |
| 4 | `wrapAmaLinkCell` | `(cell, data, align)` | 아마링크 `<a>` wrap (프로젝트명·산출물·참조 등) |
| 5 | `injectRow` | `(formKey, sectionKey, rowIdx, data)` | 행 단위 데이터 주입 — 입력 데이터 형식 자동 감지로 위 4종 wrap 자동 분기 |
| 6 | `addRow` | `(formKey, sectionKey)` | 마지막 데이터 행 복제 + 셀 초기화로 행 동적 추가 |
| 7 | `setStatus` | `(cell, status)` | 상태 셀 컬러 자동 적용 (정상·지연·계획·완료·보류) |

## 3. 실행 흐름 (6 Step)

### Step 1 — 양식 URL 확인

- 사용자 입력 원피스 URL 또는 현재 활성 탭의 양식 확인
- 양식 종류 판별 (제목 패턴 매칭) — Unit장·Cell리더·멤버·프로젝트상세 유지보수/신규개발·주간보고

### Step 2 — 편집 모드 진입

- Chrome 확장 프로그램(MCP, 도구 연동 창구) `mcp__Claude_in_Chrome__computer` 사용
- 우측 상단 "편집" 버튼 좌표 클릭 (대략 1414, 17 — 화면 해상도에 따라 변동 가능)
- `body.classList.contains('readmode') === false` 검증

### Step 3 — SCHEMA 조회

- §6 `SCHEMA[formKey][sectionKey]` 조회
- 양식 키 6종 — `일일보고_Unit장` · `일일보고_Cell리더` · `일일보고_멤버` · `프로젝트상세_유지보수` · `프로젝트상세_신규개발` · `주간보고_SBUnit`

### Step 4 — 데이터 주입

- `injectRow(formKey, sectionKey, rowIdx, data)` 호출
- 입력 데이터 형식 자동 감지:
  - 문자열 → `wrapTextCell` (정렬·줄 바꿈 자동)
  - 객체 배열 `[{title, items}]` → `wrapBulletCell` (2단계 블릿)
  - 객체 배열 `[{name, items:[{label, details:[{text, notes}]}]}]` → `wrapHierarchyBulletCell` (3단계 계층)
  - 객체 `{text, href}` → `wrapAmaLinkCell` (아마링크)

### Step 5 — 화면 검증

- `tables[N].scrollIntoView()` + 화면 캡처(스크린샷)
- 사용자 확인 받기

### Step 6 — 저장 안내

- 문서 객체 모델 직접 수정은 변경 감지(dirty) 표식을 올리지 못해 자동 저장이 진행되지 않음 (§9 한계 #3)
- 사용자에게 "임의 셀에 한 글자 입력 + Ctrl+S로 저장" 안내
- 또는 §9 한계 #3 해법 후보 4종 시도 (검증되면 자동 저장 흐름 가능)

## 4. 표별 운영 룰 (SSoT §7 인용, 14개 영역)

본 스킬은 일일보고·프로젝트 상세의 표별 입력 룰을 모두 따른다. 본 §4는 핵심 요약이며, 상세 운영 룰은 SSoT §7.1~§7.7 본문 그대로 따른다.

### 4.1 일일업무보고 6개 영역 (§7.1~§7.6)

| 영역 | 표 | 운영 룰 핵심 |
|---|---|---|
| §7.1 | 표 2 — 2026년 프로젝트 업무 목표 | 프로젝트 상세 원피스 우선 존재 + 구분 3분류 + 상태 5분류 + 일정 SSoT 동기 |
| §7.2 | 표 4 — 업무별 이슈 | 당일 발생 한정, 누적 금지, 상급자 가시성 우선 |
| §7.3 | 표 6 — 개인 업무 총 시간 합계 | 표 12·14·16·18 합산 자동, 0도 표기 |
| §7.4 | 표 8 — Unit/Cell 업무 실적 요약 | 3단계 보고 흐름 — 멤버 → Cell리더 → Unit장 압축 누적, 겸직 Unit 분리 표기 |
| §7.5 | 표 10 — Unit/Cell 업무보고 취합 | 2026년 업무 현황 원피스 인덱스 lookup, 인원 변동 동기 |
| §7.6 | 표 12·14·16·18 — 본인 업무 현황 4종 공통 | **프로젝트 상세 SSoT → 일일보고 복붙** 원칙, 진행률 = Task 누적(해당일 진행률 아님) |

### 4.2 프로젝트 상세 문서 8개 하위 영역 (§7.7.0~§7.7.7)

| 영역 | 위치 | 운영 룰 핵심 |
|---|---|---|
| §7.7.0 | 프로젝트 유형 3종 | 신규개발 · 기능개선 · 유지보수 — 양식 구조 분기 |
| §7.7.1 | 원피스 제목 패턴 | `[구분명] Amaranth 10 프로젝트 상세 - 프로젝트명` |
| §7.7.2 | 표 1 — 업데이트 일자 | 마지막 수정 날짜 동기 |
| §7.7.3 | 표 2 — 01. A. 프로젝트 정보 | 5행 — 구분·기간·내용·관련 이미지·관련 문서 + 기간 변경 히스토리 보존 룰 |
| §7.7.4 | 표 3 — 01. B. 담당자 정보 | 직군 구분(PM·기획/설계·퍼블·디자인·개발) + 프로필 아마링크 + 휴대폰 + 담당 업무 |
| §7.7.5 | 표 4 — 01. C. 진행률 (신규개발·기능개선만) | 3개 영역 복합 — 집계 영역 + 프로젝트 구축 진행률 + 개별 Task 영역, 원피스 함수 3종 |
| §7.7.6 | 표 5/4 — 02. A. 프로젝트 주요 진행현황 | **일일보고 §7.6 신규개발·기능개선·유지보수 SSoT**, 본 표 작성 후 일일보고 복붙 |
| §7.7.7 | 표 6/5 — 03. 이슈사항 | 이슈·장애·기간변경, 책갈피 기반 §7.7.3 기간 셀 ↔ 본 표 jump 룰 |

본 스킬은 위 운영 룰을 함수 호출 시점에 자동 검증한다(예: 프로젝트 상세 미존재 시 신규개발·기능개선·유지보수 표 주입 거부).

## 5. 자동 선택 매트릭스 (방식 1 vs 방식 2)

SSoT §3 자동 선택 매트릭스 인용:

| 상황 | 선택 | 처리 스킬 |
|---|---|---|
| 사내 표준 양식 보고 (일일·주간·월간·결재) | 방식 2 | **본 스킬** (`dz-oneffice-form-writer`) |
| 차트·복잡 시각화·대시보드 | 방식 1 | `dz-oneffice-writer` |
| 1회성 발표·외부 공유 | 방식 1 | `dz-oneffice-writer` |
| 텍스트 위주 + 시각 강조 1~2건 | 방식 2 + 이미지 별도 삽입 | 본 스킬 + 이미지 수동 삽입 |

두 방식 모두 적격이면 **방식 2 우선** (편집 용이성 우선, SSoT §3 결정 절차 일관).

## 6. 한계 (SSoT §9 인용)

| # | 한계 | 본 스킬 운영 권고 |
|---|---|---|
| 1 | Chrome 확장 프로그램 `outerHTML` 추출 차단 | 문서 객체 모델 프로그램 간 연동 창구 직접 사용으로 우회 (본 스킬 기본 동작) |
| 2 | 상태 컬러 4종(지연·계획·완료·보류) 미실측 | 추후 실측 후 SSoT §5.8 + 본 스킬 갱신 |
| 3 | 서버 저장 자동화 미완 | 사용자 직접 입력 + Ctrl+S 안내 의무, 해법 후보 4종 미검증 (§9 #3) |
| 4 | 폰트 `[더존] 본문체` 사내 의존 | 외부 공유 시 방식 1 권고 |
| 5 | 양식 변경 시 SCHEMA 동시 갱신 | 본 스킬이 SSoT 인용 구조이므로 SSoT 갱신만으로 자동 동작 갱신 |
| 6 | 아마링크 발행 형태 변동성 (3종 패턴) | 본 스킬은 3종 모두 인식 가능, 신규 패턴 발견 시 SSoT §5.9.2 갱신 |

### 6.1 §9 한계 #3 해법 후보 4종 (미검증 — 후속 사이클)

SSoT §9 #3 본문 인용:

1. ONEFFICE 내부 변경 감지 표식(dirty) 강제 설정 — `dzeditor` 객체의 setDirty 또는 modify 류 함수 탐색 필요
2. 셀 안에 한 글자 키 입력 + 삭제로 변경 감지 신호 발생 → Ctrl+S
3. `input` · `keyup` · `blur` 이벤트 발생으로 키 입력 흉내
4. dzeditor 자체 `save()` 프로그램 간 연동 창구 직접 호출 — 전역 객체 탐색 결과 `ID_RES_CONST_STRING_SAVE_REMOTE` 상수 발견, 함수 미파악

## 7. 운영 예 (SSoT §6 사용 예 그대로 인용)

```javascript
// 일일업무보고 Unit장용 — 신규 개발 업무 현황의 첫 데이터 행 주입
injectRow('일일보고_Unit장', '신규개발_업무', 0, {
  프로젝트명: {text:'[AI] Douzone-Forge', href:'https://gwa.douzone.com/ecm/oneffice/...'},
  업무: 'GitLab 배포 및 테스트',
  기간: '05.17\n~\n05.26',
  상세기간: '05.26',
  업무내용: [
    {
      title: '사내 GitLab 자동 동기화 기능 5단계 점진 개선',
      items: ['플러그인 v1.0.0-rc.17 — 자동 동기화 신설', '...']
    }
  ],
  담당자: '차민수',
  시간: '3.0',
  진행율: '100%'
});

// 행 추가 후 두 번째 행 주입
addRow('일일보고_Unit장', '신규개발_업무');
injectRow('일일보고_Unit장', '신규개발_업무', 1, { /* ... */ });

// 프로젝트 상세 신규개발형 — 상세 진행현황 신규 행
injectRow('프로젝트상세_신규개발', '상세_진행현황', 0, { /* ... */ });

// 주간보고 SBUnit — 게시판 모듈 첫 프로젝트 행
injectRow('주간보고_SBUnit', '게시판_모듈', 0, { /* ... */ });
```

## 8. SCHEMA 본문 (SSoT §6 직접 포함, 즉시 사용 가능)

```javascript
// === 사내 표준 양식 SCHEMA (2026-05-26 실측) ===
const SCHEMA = {};

// 5.1 일일업무보고 (Unit장용) — 19표
SCHEMA['일일보고_Unit장'] = {
  '프로젝트_업무_목표': {tableIdx: 2, startRow: 2, cols: ['구분','프로젝트명','담당자','시작일','완료일','상태','비고']},
  '이슈사항':         {tableIdx: 4, startRow: 1, cols: ['프로젝트/모듈','요청일자','요청자','이슈내용','처리자','처리내용','완료일자']},
  '개인_시간_합계':    {tableIdx: 6, startRow: 1, cols: ['신규개발','기능개선','유지보수','운영관리']},
  'Unit_실적_요약':   {tableIdx: 8, startRow: 1, cols: ['구분','내용']},
  'Unit_보고_취합':   {tableIdx: 10, startRow: 1, cols: ['Cell명','담당자명','업무보고링크']},
  '운영관리_업무':     {tableIdx: 12, startRow: 1, cols: ['업무','기간','상세기간','업무내용','담당자','시간','진행율']},
  '신규개발_업무':     {tableIdx: 14, startRow: 1, cols: ['프로젝트명','업무','기간','상세기간','업무내용','담당자','시간','진행율']},
  '기능개선_업무':     {tableIdx: 16, startRow: 1, cols: ['프로젝트명','업무','기간','상세기간','업무내용','담당자','시간','진행율']},
  '유지보수_업무':     {tableIdx: 18, startRow: 1, cols: ['업무','기간','상세기간','업무내용','담당자','시간','진행율']}
};

// 5.2 일일업무보고 (Cell리더용) — 19표, Unit장과 동일 SCHEMA (Unit→Cell 표현만 안내문에서 차이)
SCHEMA['일일보고_Cell리더'] = {...SCHEMA['일일보고_Unit장']};
SCHEMA['일일보고_Cell리더']['Cell_실적_요약'] = SCHEMA['일일보고_Cell리더']['Unit_실적_요약'];
SCHEMA['일일보고_Cell리더']['Cell_보고_취합'] = SCHEMA['일일보고_Cell리더']['Unit_보고_취합'];
delete SCHEMA['일일보고_Cell리더']['Unit_실적_요약'];
delete SCHEMA['일일보고_Cell리더']['Unit_보고_취합'];

// 5.3 일일업무보고 (멤버용) — 15표, Cell/Unit 종합 4표 제거
SCHEMA['일일보고_멤버'] = {
  '프로젝트_업무_목표': {tableIdx: 2, startRow: 2, cols: ['구분','프로젝트명','담당자','시작일','완료일','상태','비고']},
  '이슈사항':         {tableIdx: 4, startRow: 1, cols: ['프로젝트/모듈','요청일자','요청자','이슈내용','처리자','처리내용','완료일자']},
  '개인_시간_합계':    {tableIdx: 6, startRow: 1, cols: ['신규개발','기능개선','유지보수','운영관리']},
  '운영관리_업무':     {tableIdx: 8,  startRow: 1, cols: ['업무','기간','상세기간','업무내용','담당자','시간','진행율']},
  '신규개발_업무':     {tableIdx: 10, startRow: 1, cols: ['프로젝트명','업무','기간','상세기간','업무내용','담당자','시간','진행율']},
  '기능개선_업무':     {tableIdx: 12, startRow: 1, cols: ['프로젝트명','업무','기간','상세기간','업무내용','담당자','시간','진행율']},
  '유지보수_업무':     {tableIdx: 14, startRow: 1, cols: ['업무','기간','상세기간','업무내용','담당자','시간','진행율']}
};

// 5.4 프로젝트 상세 (유지보수형) — 6표
SCHEMA['프로젝트상세_유지보수'] = {
  '업데이트':         {tableIdx: 1, startRow: 0, cols: ['라벨','일자']},
  '프로젝트_정보':     {tableIdx: 2, startRow: 0, cols: ['구분명','구분값']},
  '담당자':           {tableIdx: 3, startRow: 1, cols: ['구분','담당자','담당업무']},
  '상세_진행현황':     {tableIdx: 4, startRow: 1, cols: ['구분','업무','기간','상세기간','업무내용','담당자','시간(H)','진행율']},
  '이슈사항':         {tableIdx: 5, startRow: 1, cols: ['요청일자','요청자','이슈내용','처리자','처리내용','완료일자']}
};

// 5.4b 프로젝트 상세 (신규개발형) — 7표 (진행률 표 추가, 상세 진행현황 7열로 축소)
SCHEMA['프로젝트상세_신규개발'] = {
  '업데이트':         {tableIdx: 1, startRow: 0, cols: ['라벨','일자']},
  '프로젝트_정보':     {tableIdx: 2, startRow: 0, cols: ['구분명','구분값']},
  '담당자':           {tableIdx: 3, startRow: 1, cols: ['구분','담당자','담당업무']},
  '진행률':           {tableIdx: 4, startRow: 1, cols: ['구분','계획진행률','실제진행률','진행상황']},
  '상세_진행현황':     {tableIdx: 5, startRow: 1, cols: ['업무','기간','상세기간','업무내용','담당자','시간(H)','진행율']},
  '이슈사항':         {tableIdx: 6, startRow: 1, cols: ['요청일자','요청자','이슈내용','처리자','처리내용','완료일자']}
};

// 5.5 주간업무보고 (SBUnit 한정) — 13표
// ⚠️ Unit별 모듈 조합 다름. 다른 Unit 적용 시 SCHEMA['주간보고_UCUnit'] 등 별도 키 정의 필수.
SCHEMA['주간보고_SBUnit'] = {
  '주간_통합_진행현황': {tableIdx: 3,  startRow: 1, cols: ['모듈','PM','프로젝트명','내용','결과']},
  'CRM_모듈':         {tableIdx: 4,  startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']},
  '법무관리_모듈':     {tableIdx: 5,  startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']},
  '게시판_모듈':       {tableIdx: 6,  startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']},
  '연락처_모듈':       {tableIdx: 7,  startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']},
  '업무관리_모듈':     {tableIdx: 8,  startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']},
  '퍼블리싱_모듈':     {tableIdx: 9,  startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']},
  '사이트_모듈':       {tableIdx: 10, startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']},
  'Forge':           {tableIdx: 11, startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']},
  '수명업무':         {tableIdx: 12, startRow: 2, cols: ['프로젝트명','내용','PM','계획일정','실적일정','진행률','비고']}
};
```

## 9. 헬퍼 함수 본문 (SSoT §6 직접 포함, 즉시 사용 가능)

```javascript
// === 컬럼별 정렬 매핑 ===
const ALIGN_MAP = {
  '프로젝트명':'left', '업무':'left', '기간':'center', '상세기간':'center',
  '담당자':'center', '시간':'center', '시간(H)':'center', '진행율':'center',
  '구분':'center', '상태':'center', '비고':'left',
  '요청일자':'center', '요청자':'center', '이슈내용':'left', '처리자':'center',
  '처리내용':'left', '완료일자':'center',
  '신규개발':'center', '기능개선':'center', '유지보수':'center', '운영관리':'center',
  'Cell명':'center', '담당자명':'center', '업무보고링크':'left', '내용':'left'
};

// 1. 아마링크 셀 wrap (프로젝트명·산출물·참조 등)
function wrapAmaLinkCell(cell, data, align) {
  const ed = cell.ownerDocument;
  while (cell.firstChild) cell.removeChild(cell.firstChild);
  const p = ed.createElement('p');
  p.setAttribute('style', `text-align:${align||'left'};font-family:'[더존] 본문체';font-size:9pt;`);
  const a = ed.createElement('a');
  a.setAttribute('href', data.href);
  a.setAttribute('target', 'onepopup_' + Date.now() + '000');
  a.setAttribute('style', 'color:rgb(0,0,238);');
  a.textContent = data.text;
  p.appendChild(a);
  cell.appendChild(p);
}

// 2. 일반 텍스트 셀 wrap (양식 정합)
function wrapTextCell(cell, text, align, lineHeight) {
  const ed = cell.ownerDocument;
  while (cell.firstChild) cell.removeChild(cell.firstChild);
  const p = ed.createElement('p');
  let style = `text-align:${align};font-family:'[더존] 본문체';font-size:9pt;`;
  if (lineHeight) style += `line-height:${lineHeight};`;
  p.setAttribute('style', style);
  if (text && text.includes('\n')) {
    const parts = text.split('\n');
    parts.forEach((part, idx) => {
      p.appendChild(ed.createTextNode(part));
      if (idx < parts.length - 1) p.appendChild(ed.createElement('br'));
    });
  } else {
    p.textContent = text || '';
  }
  cell.appendChild(p);
}

// 3. 3단계 계층 종합 보고 wrap (표 8 Unit 업무 실적 요약 등)
function wrapHierarchyBulletCell(cell, units) {
  const ed = cell.ownerDocument;
  while (cell.firstChild) cell.removeChild(cell.firstChild);
  units.forEach(unit => {
    const unitHeader = ed.createElement('p');
    unitHeader.setAttribute('style', 'text-align:left;font-family:본고딕;font-size:10pt;font-weight:bold;');
    unitHeader.textContent = unit.name;
    cell.appendChild(unitHeader);
    const topUl = ed.createElement('ul');
    topUl.setAttribute('style', 'padding-left:20px;');
    unit.items.forEach(item => {
      const topLi = ed.createElement('li');
      topLi.setAttribute('style', 'text-decoration:none;font-family:본고딕;font-size:10pt;font-weight:bold;color:rgb(0,0,238);');
      topLi.textContent = item.label;
      topUl.appendChild(topLi);
      if (item.details && item.details.length) {
        const subUl = ed.createElement('ul');
        subUl.setAttribute('style', 'padding-left:20px;list-style-type:circle;');
        item.details.forEach(detail => {
          const subLi = ed.createElement('li');
          subLi.setAttribute('style', 'text-decoration:none;font-family:본고딕;font-size:10pt;');
          const span = ed.createElement('span');
          span.setAttribute('style', 'font-size:10pt;letter-spacing:0pt;font-family:본고딕;font-weight:normal;font-style:normal;text-decoration:none;color:rgb(0,0,0);background-color:rgba(0,0,0,0);');
          span.textContent = detail.text;
          subLi.appendChild(span);
          subUl.appendChild(subLi);
          if (detail.notes && detail.notes.length) {
            const noteUl = ed.createElement('ul');
            noteUl.setAttribute('style', 'padding-left:20px;list-style-type:square;');
            detail.notes.forEach(note => {
              const noteLi = ed.createElement('li');
              noteLi.setAttribute('style', 'text-decoration:none;font-family:본고딕;font-size:10pt;');
              const noteSpan = ed.createElement('span');
              noteSpan.setAttribute('style', 'font-size:10pt;letter-spacing:0pt;font-family:본고딕;font-weight:normal;font-style:normal;text-decoration:none;color:rgb(0,0,0);background-color:rgba(0,0,0,0);');
              noteSpan.textContent = note;
              noteLi.appendChild(noteSpan);
              noteUl.appendChild(noteLi);
            });
            subUl.appendChild(noteUl);
          }
        });
        topUl.appendChild(subUl);
      }
    });
    cell.appendChild(topUl);
  });
}

// 4. 블릿 구조 셀 wrap (업무내용 등)
function wrapBulletCell(cell, sections) {
  const ed = cell.ownerDocument;
  while (cell.firstChild) cell.removeChild(cell.firstChild);
  const rootUl = ed.createElement('ul');
  rootUl.setAttribute('style', 'padding-left:20px;');
  sections.forEach(section => {
    const titleLi = ed.createElement('li');
    titleLi.setAttribute('style', 'text-decoration:none;font-family:본고딕;font-size:10pt;font-weight:bold;');
    titleLi.textContent = section.title;
    rootUl.appendChild(titleLi);
    if (section.items && section.items.length) {
      const subUl = ed.createElement('ul');
      subUl.setAttribute('style', 'padding-left:20px;list-style-type:circle;');
      section.items.forEach(item => {
        const subLi = ed.createElement('li');
        subLi.setAttribute('style', 'text-decoration:none;font-family:본고딕;font-size:10pt;');
        const span = ed.createElement('span');
        span.setAttribute('style', 'font-size:10pt;letter-spacing:0pt;font-family:본고딕;font-weight:normal;font-style:normal;text-decoration:none;color:rgb(0,0,0);background-color:rgba(0,0,0,0);');
        span.textContent = item;
        subLi.appendChild(span);
        subUl.appendChild(subLi);
      });
      rootUl.appendChild(subUl);
    }
  });
  cell.appendChild(rootUl);
}

// 다중 줄 텍스트 자동 감지
function isMultiLine(text) {
  return typeof text === 'string' && text.includes('\n');
}

// 5. 데이터 주입 (다형화 + 양식 wrap 자동 적용)
function injectRow(formKey, sectionKey, rowIdx, data) {
  const ed = document.getElementById('open_oneffice_body_iframe').contentDocument
    .getElementById('dzeditor_0').contentDocument;
  const s = SCHEMA[formKey][sectionKey];
  const row = ed.querySelectorAll('table')[s.tableIdx].querySelectorAll('tr')[s.startRow + rowIdx];
  const cells = row.querySelectorAll('td');
  s.cols.forEach((colName, idx) => {
    const value = data[colName];
    if (value === undefined) return;
    const cell = cells[idx];
    if (!cell) return;
    if (Array.isArray(value) && value[0] && typeof value[0] === 'object' && value[0].title !== undefined) {
      wrapBulletCell(cell, value);
    } else if (Array.isArray(value) && value[0] && typeof value[0] === 'object' && value[0].name !== undefined && value[0].items !== undefined) {
      wrapHierarchyBulletCell(cell, value);
    } else if (typeof value === 'object' && value !== null && value.href !== undefined) {
      const align = ALIGN_MAP[colName] || 'left';
      wrapAmaLinkCell(cell, value, align);
    } else {
      const align = ALIGN_MAP[colName] || 'left';
      const lineHeight = (colName === '기간' && isMultiLine(value)) ? '1' : null;
      wrapTextCell(cell, value, align, lineHeight);
    }
  });
}

// 6. 상태 셀에 컬러 자동 적용
const STATUS_STYLE = {
  '정상': 'background-color:rgb(169, 209, 142);width:80px;height:38px;border:1px solid rgb(191, 191, 191);text-align:center;',
  '지연': 'background-color:rgb(248, 203, 173);width:80px;height:38px;border:1px solid rgb(191, 191, 191);text-align:center;',
  '계획': 'background-color:rgb(189, 215, 238);width:80px;height:38px;border:1px solid rgb(191, 191, 191);text-align:center;',
  '완료': 'background-color:rgb(217, 217, 217);width:80px;height:38px;border:1px solid rgb(191, 191, 191);text-align:center;',
  '보류': 'background-color:rgb(127, 127, 127);width:80px;height:38px;border:1px solid rgb(191, 191, 191);text-align:center;color:rgb(255, 255, 255);'
};
// 주의: 지연·계획·완료·보류 RGB 값은 사내 표준 색상이며 실측 미완. 다른 양식에서 확인 후 SSoT §5.8 갱신.

function setStatus(cell, status) {
  cell.innerText = status;
  if (STATUS_STYLE[status]) cell.setAttribute('style', STATUS_STYLE[status]);
}

// 7. 행 동적 추가 (마지막 데이터 행 복제 후 셀 초기화)
function addRow(formKey, sectionKey) {
  const ed = document.getElementById('open_oneffice_body_iframe').contentDocument
    .getElementById('dzeditor_0').contentDocument;
  const s = SCHEMA[formKey][sectionKey];
  const table = ed.querySelectorAll('table')[s.tableIdx];
  const rows = table.querySelectorAll('tr');
  const lastRow = rows[rows.length - 1];
  const newRow = lastRow.cloneNode(true);
  newRow.querySelectorAll('td').forEach(cell => { cell.innerText = ''; });
  lastRow.parentNode.appendChild(newRow);
  return newRow;
}
```

## 10. 변천사

| 일자 | 변경 |
|---|---|
| 2026-05-27 | 신설 — SSoT §5·§6·§7·§9 기반 (douzone-forge plugin.json v1.1.0, rc 단계 종료 + 정식 minor 진입) |

---

_본 스킬은 Cowork ↔ Claude Code 협업 표준에 따라 신설되었다. 단일 출처 우선 — `규칙/프로세스/원피스-작성방식-선택-자동화-표준.md`._
