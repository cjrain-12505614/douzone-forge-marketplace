---
name: a10-daily-digest
description: "ONEFFICE 일일보고 수집·파싱하여 douzone-forge 로컬 캐시로 복제"
---

`a10-daily-digest` 스킬을 실행하여 SBUnit 일일보고를
`douzone-forge/deliverables/보고서/일일보고/원본캐시/YYYY-MM/YYYYMMDD-{사번}.md` 로 캐싱한다.

## 인수 (`$ARGUMENTS`)

| 인수 | 설명 | 예시 |
|---|---|---|
| (없음) | 어제 1일치 | `/a10-daily-digest` |
| `--date YYYY-MM-DD` | 지정일 | `/a10-daily-digest --date 2026-04-18` |
| `--since YYYY-MM-DD` | 지정일부터 어제까지 | `/a10-daily-digest --since 2026-04-15` |
| `--employee {사번}` | 특정 사원만 | `/a10-daily-digest --employee 2505614` |
| `--refresh` | 기존 캐시 덮어쓰기 강제 | `/a10-daily-digest --refresh` |

## 실행 결과

1. ONEFFICE 문서 본문 추출 (읽기 전용)
2. JIRA 키 / PRJ 참조 정규식 추출 → frontmatter 생성
3. `douzone-forge/deliverables/보고서/일일보고/원본캐시/YYYY-MM/YYYYMMDD-{사번}.md` 저장
4. `_index.md` 월별 집계 갱신
5. 요약 보고 (수집 성공/미보고/추출된 JIRA·PRJ 키 건수)

## 선행 조건

- `SBUnit-업무현황-아마링크.md` 에 대상 사원·날짜의 문서 URL이 등록되어 있어야 함
- Chrome MCP 접근 가능
- `douzone-forge/deliverables/보고서/일일보고/원본캐시/` 디렉토리 쓰기 권한

## 주의

- ONEFFICE 원본은 절대 수정하지 않음 — 읽기만
- 권한 없는 문서는 스킵 + 경고
- 미보고 사원은 경고 리스트로만 보고 (자동 독촉 안 함)

## 관련

- 스킬: [`a10-daily-digest`](../skills/a10-daily-digest/SKILL.md)
- 원본 열람: [`a10-oneffice-reader`](../skills/a10-oneffice-reader/SKILL.md)
- 3-way 크로스 체크: [`/a10-triage-status`](a10-triage-status.md)
