---
name: a10-init-project
description: "새 프로젝트 초기 설정 (CLAUDE.md + 폴더 구조 생성)"
---

# /a10-init-project 커맨드

douzone-forge에 새 모듈 또는 새 프로젝트를 초기화합니다.

## 실행 절차

1. **현재 워크스페이스 확인**
   - douzone-forge CLAUDE.md를 읽어 기존 구조를 파악한다.

2. **초기화 유형 결정** (AskUserQuestion 활용)
   - **새 모듈 초기화**: 기존에 없는 모듈 폴더를 생성
   - **새 프로젝트 등록**: `projects/`에 새 PRJ 파일을 생성

### 새 모듈 초기화

3. 기본 정보 수집:
   - 모듈명
   - 라이선스 구분 여부
   - 주요 GNB 목록 (초안)
   - 담당 개발자/설계자

4. 폴더 구조 생성:
   ```
   [모듈명]/
   ├── module-overview.md
   ├── context/
   ├── history/
   │   ├── phases/
   │   ├── requests/
   │   ├── plans/
   │   ├── meetings/
   │   └── reports/
   ├── tasks/
   │   ├── _current.md
   │   └── enhancements/
   ├── sessions/
   │   └── archive/
   └── 문서/
       ├── INDEX.md
       ├── 01_신규/
       ├── 02_삭제가능/
       └── 03_장기참조/
   ```

5. 초기 파일 생성:
   - `module-overview.md` — 기본 정보, 라이선스 구분, GNB 목록 (초안)
   - `문서/INDEX.md` — 빈 인덱스
   - `history/_timeline.md` — 빈 타임라인
   - `tasks/_current.md` — 빈 업무 목록
   - `_개인/sessions/{모듈}/_current.md` — 초기 세션

6. 온보딩 안내:
   - 다음 단계로 설계서 PDF 분석(`a10-context-analyzer`) 또는 스크린샷 분석을 권장

### 새 프로젝트 등록

3. `projects/_dashboard.md`에서 최신 PRJ ID를 확인하고 다음 순번을 채번한다.
   - 단일 모듈 귀속: `PRJ-{YYYY}-{모듈코드}-{NNN}` (신규 규칙)
   - 수명업무·크로스모듈: `PRJ-{YYYY}-{NNN}` (구규칙)
4. `projects/_templates/project-detail.md`를 복사하여 규칙에 맞는 파일명으로 생성한다 (`PRJ-{YYYY}-{모듈코드}-{NNN}_{프로젝트명}.md` 또는 `PRJ-YYYY-NNN_{프로젝트명}.md`).
5. 사용자에게 필수 정보를 확인한다:
   - 프로젝트명, 유형, 모듈, 기간, PM, 담당자
6. 01. 프로젝트 개요를 작성한다.
7. 02. TASK 목록 초안을 작성한다.
8. `_dashboard.md`에 행을 추가한다.
9. 해당 모듈 `tasks/_current.md`에 프로젝트 참조를 추가한다.
10. **Cascade R2**: PRJ `04. 연결 정보`에 관련 모듈 context/, history/, 문서/INDEX.md, _tech-reference.md 링크를 추가한다.
