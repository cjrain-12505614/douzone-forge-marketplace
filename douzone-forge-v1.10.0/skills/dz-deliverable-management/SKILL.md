---
name: deliverable-management
description: >
  This skill should be used when the user asks "산출물 버전 올려줘",
  "v1.0으로 승격", "문서 버전 관리", "산출물 목록 알려줘",
  "이 문서 검증해줘", "v1.0 준비",
  or when creating, versioning, or quality-checking project deliverables.
  Manages deliverable versioning, naming conventions, and quality gates.
version: 0.1.0
---

# Deliverable Management

프로젝트 산출물의 버전 관리, 명명 규칙, 품질 게이트를 관리한다.

## 워크스페이스 구조

```
{프로젝트}/
├── docs/
│   ├── 00_관리/          # 팀 플랜, 계획서, 세션 로그, 의사결정 로그
│   ├── 01_참고자료/      # 벤치마킹, 경쟁사분석, 기술조사 (읽기 전용 성격)
│   ├── 02_기획/          # SRS, 요구사항(AC), 사용자스토리
│   ├── 03_설계/          # 화면설계, API, DB, 아키텍처
│   ├── 04_PoC/           # 기술 검증 코드·결과
│   ├── 05_검증/          # 교차 검증 리포트, 리스크 대장
│   └── 06_산출물/        # 최종 배포용 (킥오프 패키지)
└── CLAUDE.md             # 프로젝트 마스터 지침
```

## 파일 명명 규칙

- 버전 관리 문서: `파일명_v{버전}.{확장자}` (예: `srs_v1.0.docx`)
- 연구/조사 자료: `research_{주제}.md` (예: `research_gantt_comparison.md`)
- PoC 코드: `poc_{주제}.{확장자}` (예: `poc_cpm_algorithm.py`)
- 검증 보고서: `validation_report.md` 또는 `validation_{대상}.md`
- 세션 로그: `session_YYYY-MM-DD_N.md`

## 버전 규칙

| 버전 범위 | 의미 | 승격 조건 |
|-----------|------|----------|
| v0.x | 초안(Draft) | 자유 갱신 |
| v1.0 | 리뷰 완료본 | Agent 5(수아) 교차 검증 통과 + PM 리뷰 |
| v1.x | 마이너 수정 | PL 판단으로 갱신 |
| v2.0 | 메이저 변경 | 범위 변경 시 PM 컨펌 후 |

## v1.0 승격 절차

1. PL이 산출물 완성도를 자체 점검한다.
2. Agent 5(수아)에게 교차 검증을 요청한다.
   - 검증 항목: 문서 간 일관성, 요구사항 추적성, 누락·모순 체크
3. 검증 결과 Critical 0건이면 PM에게 리뷰 요청한다.
4. PM 승인 후 v1.0으로 버전을 올리고 파일명을 변경한다.
5. 이전 버전은 삭제하지 않고 `_v0.x` 접미사 그대로 보존한다.

## 산출물 품질 기준

모든 산출물은 **"실제 개발팀이 바로 사용할 수 있는 수준"**을 목표로 한다.

검증 체크리스트:
- [ ] 요구사항 ID(TM-XXX, GC-XXX 등)가 정확히 참조되어 있는가
- [ ] 다른 산출물과 용어·수치가 일관되는가
- [ ] 누락된 섹션이나 TODO/TBD 마크가 남아있지 않은가
- [ ] 최신 의사결정 사항이 반영되어 있는가


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
