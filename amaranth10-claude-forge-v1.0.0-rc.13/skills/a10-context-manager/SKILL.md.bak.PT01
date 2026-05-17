---
name: a10-context-manager
description: >
  This skill should be used when the user asks to "컨텍스트 로드해줘", "이 모듈 맥락 알려줘",
  "GNB/LNB 구조로 정리해줘", "모듈 컨텍스트 파일 만들어줘", "context 파일 업데이트해줘",
  또는 특정 Amaranth 10 모듈의 메뉴·기능에 대해 작업을 시작하기 전 맥락을 파악하려 할 때.
  GNB/LNB 기반 컨텍스트 분할 구조를 설명하고, 파일 로드 및 관리 방법을 안내합니다.
version: 0.2.0
---

# 컨텍스트 관리자 (Context Manager)

Amaranth 10 모듈의 맥락을 GNB/LNB 메뉴 계층 구조로 분할해 관리하는 방법론.
모듈 전체가 크더라도 작업하는 메뉴 단위로만 로드해 효율적인 컨텍스트 관리를 가능하게 한다.

## 컨텍스트 파일 계층 구조

모든 모듈은 아래 구조를 따른다. 실제 파일은 사용자가 채우며, 이 스킬은 패턴만 정의한다.

```
{모듈명}/
├── module-overview.md        # 항상 로드 — 모듈 전체 요약 (1페이지 이내)
├── conventions.md            # 항상 로드 — 기술스택, 코딩 컨벤션, 라이선스 규칙
└── context/
    ├── {GNB-1}/
    │   ├── _overview.md      # GNB 전체 요약 (해당 GNB 작업 시 로드)
    │   ├── {LNB-1}.md        # LNB별 기능 상세 컨텍스트
    │   └── {LNB-2}.md
    └── {GNB-2}/
        ├── _overview.md
        └── {LNB-1}.md
```

## 로드 순서 (Loading Sequence)

아래 9단계 순서를 반드시 따른다. 전체 맥락을 효율적으로 확보하면서 세션 연속성을 유지할 수 있다.

1. **module-overview.md** — 모듈 전체 개요, 라이선스, GNB 목록
2. **conventions.md** — 기술스택, 코딩 컨벤션, 라이선스 규칙
3. **sessions/_current.md** — **세션 체크** (진행 중인 작업 확인 필수!)
4. **관련 진행 세션 파일** — 같은 주제의 진행 중 세션이 있으면 먼저 로드
5. **tasks/_current.md** — 현재 진행 중인 업무 목록
6. **문서/INDEX.md** — 어떤 설계서/문서가 있는지 파악
7. **context/{GNB명}/_overview.md** — 작업 대상 GNB 개요
8. **context/{GNB명}/{LNB명}.md** — 작업 대상 LNB 상세
9. **history/_timeline.md** — 개발 이력 흐름 파악

3단계(세션 체크)는 **필수**이다. 진행 중인 세션이 있으면 중복 작업을 피하고 이전 맥락을 이어받을 수 있다.

## 컨텍스트 로드 원칙

**항상 로드:** 1-6번 (module-overview, conventions, 세션, tasks, INDEX)
**GNB 작업 시 추가 로드:** 7번 (해당 GNB의 `_overview.md`)
**LNB 작업 시 추가 로드:** 8번 (해당 LNB의 상세 파일)
**히스토리 필요 시:** 9번 (`history/_timeline.md`)

이 순서를 따르면 현재 작업에 필요한 맥락이 충분히 확보되고, 세션 간 연속성도 유지된다.
전체 모듈 파일을 한꺼번에 로드하지 않는다.

## 세션 인식 (Session Awareness)

**원칙**: 같은 주제의 진행 중인 세션이 있으면 새 분석을 시작하기 전에 그 세션의 완료 항목과 남은 작업을 먼저 확인한다.

예시:
```
1. sessions/_current.md 읽기
2. 진행 중: "상담관리 LNB 분석" 작업
3. 완료된 것: 상담 목록, 상담 등록
4. 남은 것: 상담 수정, 상담 삭제
→ 새 분석 대신 남은 작업부터 이어받기
```

## 누락 진단 (Missing File Diagnosis)

컨텍스트 로드 중 파일이 없으면 아래 형식으로 진단하고 제안한다:

```markdown
누락 파일 목록:
- `module-overview.md` → {모듈명}/module-overview.md 생성 필요
- `context/상담관리/_overview.md` → {모듈명}/context/상담관리/_overview.md 생성 필요
```

해당 파일이 없어도 진행은 가능하지만, "향후 작성 필요" 항목으로 기록한다.

## 요약 출력 표준 (Summary Format)

로드 완료 후 사용자에게 전달하는 요약은 **4줄 이내**로 정리한다:

```
[모듈명] 컨텍스트 로드 완료

목적: {GNB/LNB 역할 한 줄}
라이선스: {구분이 있으면 명시}
구현상태: {진행 중/완료/기획 중}
리스크: {확인 필요 항목이 있으면 명시}
```

## 컨텍스트 파일 작성 기준

### module-overview.md
- 모듈 목적과 사용 대상 (1-2문장)
- 라이선스 구분이 있는 경우 명시 (예: 법무법인용 / 기업법무팀용)
- 주요 GNB 목록
- 기술스택 한 줄 요약
- 현재 개발 단계 및 버전

### conventions.md
- 기술스택 (프레임워크, DB, 프론트엔드)
- 코딩 컨벤션 핵심 규칙
- 라이선스별 기능 분기 규칙 (있는 경우)
- API 명명 규칙
- 주요 공통 컴포넌트 목록

### {GNB}/_overview.md
- 이 GNB의 역할과 포함 LNB 목록
- 해당 GNB에서 자주 발생하는 이슈나 주의사항
- 라이선스별 접근 권한 차이 (있는 경우)

### {GNB}/{LNB}.md
- 기능 목적 (1-2문장)
- 주요 기능 목록 (현재 구현 상태 포함)
- 관련 테이블/엔티티
- 알려진 이슈 또는 제약사항
- 최근 변경 이력 (날짜 포함)

## 컨텍스트 파일 업데이트 시점

작업이 끝나면 반드시 해당 LNB 파일을 업데이트한다. `/update-context` 커맨드를 사용하면
방금 완료한 작업을 요약해 자동으로 반영할 수 있다.

## 연쇄 업데이트 규칙 (Cascade)

context 파일을 변경할 때 관련 파일도 함께 업데이트해야 맥락이 끊기지 않는다.
상세 규칙은 douzone-forge `CLAUDE.md`의 "연쇄 업데이트 규칙 (Cascade Update Rules)" 섹션에 정의되어 있다.

### R1 — context 변경 → module-overview.md 반영

context/ 파일(GNB _overview.md 또는 LNB.md)을 신규 생성하거나 대폭 변경하면:
1. `module-overview.md`의 **GNB 목록** 테이블에 상태·LNB 수 갱신
2. `module-overview.md`의 **context 파일 인덱스** 테이블에 새 파일 추가/갱신
3. `module-overview.md` 상단 **최종 업데이트** 날짜 갱신

### R3 — 담당자 변경 → 5개 파일 동시 갱신

조직 변경이나 담당자 재배치가 발생하면 아래 5곳을 **모두** 업데이트:
1. `_참조자료/조직/더존비즈온-조직구조.md`
2. 해당 모듈 `module-overview.md` 조직 구성 섹션
3. 해당 모듈 `context/_tech-reference.md` 개발 담당자 매핑
4. `Workspace_a10/CLAUDE.md` 조직 구성 섹션
5. 관련 `_projects/PRJ-*.md` 01.B 담당자 섹션

### R4 — 소스 분석 완료 → douzone-forge 반영

Workspace_a10에서 소스 분석이 완료되면:
1. 해당 모듈 `context/_tech-reference.md`에 분석 결과 요약 추가/갱신
2. `_tech-reference.md`에 `Workspace_a10/_doc/analysis/[모듈]/` 경로 링크 추가
3. 기술적 발견사항이 기획에 영향을 주면 관련 `context/[GNB]/_overview.md`에도 반영
4. Workspace_a10의 `architecture.md` 말미에 douzone-forge 반영 상태 기록

## 신규 모듈 컨텍스트 초기화

새 모듈에 처음 적용할 때는 `templates/context/` 아래 템플릿 파일을 복사해
모듈 디렉토리를 만들고 내용을 채운다. 자세한 내용은 `references/setup-guide.md` 참고.


## 마크다운 링크 규칙 (필수)

마크다운 파일 작성·업데이트 시 **모든 경로·파일 참조는 클릭 가능한 상대 링크**로 작성한다.

```markdown
# 나쁜 예 (클릭 불가)
법무관리/tasks/_current.md에서 확인

# 좋은 예 (클릭 가능)
[법무관리/tasks/_current.md](../법무관리/tasks/_current.md)에서 확인
```

- 상대 경로는 현재 파일 위치 기준
- 코드블록 안의 폴더 구조 다이어그램은 예외 (링크 불필요)
- 상세 규칙은 douzone-forge CLAUDE.md의 "마크다운 링크 표기 규칙" 섹션 참조
