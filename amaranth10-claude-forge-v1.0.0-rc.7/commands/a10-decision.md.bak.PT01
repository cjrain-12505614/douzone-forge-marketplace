---
name: a10-decision
description: "의사결정 기록 또는 컨펌 요청"
---

의사결정을 관리한다.

사용법:
- `/a10-decision add 항목: 결정 내용` — 확정된 결정 기록
- `/a10-decision request 항목` — PM에게 컨펌 요청 생성
- `/a10-decision list` — 확정·미결 전체 목록 표시

douzone-forge에서 의사결정은 **프로젝트 파일(`_projects/PRJ-*.md`)** 내 기록한다.
모듈 공통 또는 크로스 모듈 의사결정은 CLAUDE.md에 기록한다.

**add**:
1. 관련 프로젝트 파일 `_projects/PRJ-*.md`의 `01. D. 이슈 & 리스크` 또는 `03. 상세 진행현황`에서 맥락을 파악한다.
2. 해당 프로젝트 파일에 의사결정 기록을 추가한다.
3. 모듈 공통 결정이면 douzone-forge CLAUDE.md에도 기록한다.

**request**:
1. PM에게 아래 형식으로 컨펌을 요청한다:
```
PM, 의사결정이 필요한 사항이 있습니다.
**{항목}**
- 배경: {왜 필요한지}
- 선택지: A) ... / B) ...
- 의견: {추천안}
- 관련 프로젝트: PRJ-YYYY-NNN
```

**list**:
1. `_projects/_dashboard.md`에서 진행 중 프로젝트 목록을 확인한다.
2. 각 PRJ 파일의 이슈·리스크 섹션을 조회하여 미결 사항을 종합한다.
