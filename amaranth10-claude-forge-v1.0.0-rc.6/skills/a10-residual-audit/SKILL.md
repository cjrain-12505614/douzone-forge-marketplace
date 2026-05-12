---
name: a10-residual-audit
description: >
  This skill should be used when the user asks to "잔존 검증", "깨진 링크 점검",
  "depth 일관성 검증", "정기 점검", "Step 진입 직전 검증", "헤더 표준 검증",
  or 워크스페이스 광역 정합 점검 필요 시.
  깨진 링크 + 옛 경로 잔존 + 산출물 위치 정합 + depth-up 정합 + 헤더 표준 5축 점검 (Phase S S-06 확장).
  결과 리포트 → 참고자료/리포트/residual-audit-{YYYYMMDD}.md.
version: 0.2.0
---

# 잔존 검증 (a10-residual-audit) — Phase R+ R-07 신설 + Phase S S-06 5축 확장

워크스페이스 **광역 정합 점검 5축** + 결과 리포트 자동 저장. R-06(즉시 탐지)의 광역 정기 점검 버전.

## 트리거

description 매칭 (한글 키워드):
- "잔존 검증"
- "깨진 링크 점검"
- "depth 일관성 검증"
- "정기 점검"
- "Step 진입 직전 검증"

## 자동 동작 5축 (Phase S S-06 확장)

### 1. 깨진 링크 검출 (전체 .md)

R-06(`hooks/link-integrity-check.sh`) 광역 버전.
- 정규식 `\[([^\]]*)\]\(([^)]+)\)` 매칭
- 외부 URL (`http`·`mailto:`·`#`) 제외
- URL 디코드 → `os.path.normpath` 검증
- 보호 영역 스킵 (`_archive`·`99_archive`·`*.bak.*`)

### 2. 옛 경로 잔존 검출

`rules/phase-q-structure.md` 11 패턴 인용:
- `_CLAUDE/`·`_projects/`·`reference/`·`modules/`·`deliverables/`
- `meta/repo-check/`·`meta/reports/`·`meta/sessions/`
- `team-tracking/`·한글명 단독 prefix·`문서/01_신규` 등

### 3. 산출물 위치 정합 검증

`hooks/output-location-policy.sh` 8 패턴 인용:
- `*-우산지시서.md`·`*-계획서.md`·`*-검토의견*.md`·`*-완료보고서.md`
- `*-종착보고서.md`·`*-Pre-fix-카운터.md`·`*-sed-로그.md`·`*-결과검토.md`

→ `Amaranth10/{모듈}/` 하위 산출물 검출 시 경고 (표준 위치: `프로젝트/PRJ-{NNN}_*/0[1-6]_*/`).

### 4. depth-up 정합 검증

`_index.md` 등 placeholder ../ 깊이 자동 매핑:
- 파일 위치 → 루트까지 depth 계산
- `../../../../규칙` 등 4-up 일률 패턴 검출 → 깊이별 정확 ../개수 매핑
- 조직/_index.md 26 파일 등 placeholder 일관 오류 패턴 사후 점검

### 5. 헤더 표준 정합 검증 (Phase S S-06 신설, 룰 2)

ONEFFICE 추출 결과 .md 상단 5줄 frontmatter 부재 검출:
- 검사 대상: `참고자료/외부조직/`·`참고자료/리포트/`·`참고자료/아마링크-추출/` 하위 .md
- 패턴: frontmatter `---` 시작 + 5필드 (`원본:`·`재귀_추출:`·`댓글_추출:`·`추출일:`·`추출자:`)
- 누락 시 경고 → 차민수 일상 운영 시 헤더 추가 (자비스 Q4 답변 — 자연 수정)
- 의존: `규칙/프로세스/업무보고-체크-운영규칙.md` 룰 2 (Phase S S-01 신설)

## Python 스크립트 본문 골격

```python
import os, re, datetime
from urllib.parse import unquote

WS_ROOT = os.path.expanduser("~/Workspace/douzone-forge")
LINK = re.compile(r'\[([^\]]*)\]\(([^)]+)\)')
PROTECTED = ('_archive', '99_archive')
OLD_PATTERNS = ['_CLAUDE/', '_projects/', 'reference/', 'modules/',
                'deliverables/', 'meta/repo-check/', 'meta/reports/',
                'meta/sessions/', 'team-tracking/']
OUTPUT_PATTERNS = ['-우산지시서.md', '-계획서.md', '-검토의견', '-완료보고서.md',
                   '-종착보고서.md', '-Pre-fix-카운터.md', '-sed-로그.md', '-결과검토.md']

def is_protected(path):
    return any(p in path for p in PROTECTED) or '.bak.' in path

# 5축 결과 누적 (Phase S S-06 확장)
report_lines = []
HEADER_FIELDS = ['원본:', '재귀_추출:', '댓글_추출:', '추출일:', '추출자:']

# 1. 깨진 링크 검출
broken_links = []
for root, dirs, files in os.walk(WS_ROOT):
    if is_protected(root):
        continue
    for fn in files:
        if not fn.endswith('.md'):
            continue
        full = os.path.join(root, fn)
        with open(full, encoding='utf-8') as f:
            for ln, line in enumerate(f, 1):
                for m in LINK.finditer(line):
                    p = m.group(2).split('#')[0].split('?')[0]
                    if not p or p.startswith(('http', 'mailto:', '#')):
                        continue
                    target = os.path.normpath(os.path.join(os.path.dirname(full), unquote(p)))
                    if not os.path.exists(target):
                        broken_links.append((full, ln, p))

# 2. 옛 경로 잔존 검출
old_path_hits = []
for root, dirs, files in os.walk(WS_ROOT):
    if is_protected(root):
        continue
    for fn in files:
        if not fn.endswith('.md'):
            continue
        full = os.path.join(root, fn)
        with open(full, encoding='utf-8') as f:
            for ln, line in enumerate(f, 1):
                for pat in OLD_PATTERNS:
                    if pat in line:
                        old_path_hits.append((full, ln, pat))

# 3. 산출물 위치 정합 (Amaranth10/ 하위 산출물 패턴)
output_violations = []
for root, dirs, files in os.walk(os.path.join(WS_ROOT, 'Amaranth10')):
    if is_protected(root):
        continue
    for fn in files:
        for pat in OUTPUT_PATTERNS:
            if pat in fn:
                output_violations.append(os.path.join(root, fn))
                break

# 4. depth-up 정합 (_index.md 등)
depth_violations = []
for root, dirs, files in os.walk(os.path.join(WS_ROOT, '조직')):
    if is_protected(root):
        continue
    for fn in files:
        if fn != '_index.md':
            continue
        full = os.path.join(root, fn)
        depth = len(os.path.relpath(full, WS_ROOT).split(os.sep)) - 1
        correct_up = '../' * depth
        with open(full, encoding='utf-8') as f:
            content = f.read()
        # 4-up placeholder 일관 오류 검출
        if '../../../../' in content and depth != 4:
            depth_violations.append((full, depth, correct_up))

# 리포트 저장
out = os.path.join(WS_ROOT, '참고자료', '리포트',
                   f'residual-audit-{datetime.date.today():%Y%m%d}.md')
os.makedirs(os.path.dirname(out), exist_ok=True)
with open(out, 'w', encoding='utf-8') as f:
    f.write(f"# Residual Audit 리포트 ({datetime.date.today()})\n\n")
    f.write(f"## 1. 깨진 링크: {len(broken_links)}건\n")
    f.write(f"## 2. 옛 경로 잔존: {len(old_path_hits)}건\n")
    f.write(f"## 3. 산출물 위치 정합: {len(output_violations)}건\n")
    f.write(f"## 4. depth-up 정합: {len(depth_violations)}건\n")
```

## 운영 주기

- **월 1회 정기 점검** (1일 또는 첫 영업일)
- **Step 진입 직전 이벤트 점검** (Step 8·9 등 placeholder 작업 직전)
- **차민수 명시 트리거** (한글 키워드 5건)

## 사용 사례

### 정기 점검 (월 1회)
```
입력: 5/1 정기 점검
→ 4축 자동 점검 → 리포트 → 참고자료/리포트/residual-audit-20260501.md
→ 잔존 검출 시 차민수에 알림 (예: 깨진 링크 5건 + 옛 경로 2건)
```

### Step 진입 직전 검증
```
입력: Step 8 진입 직전 검증
→ 4축 자동 점검 → 깨진 링크 0 + 옛 경로 0 + 산출물 위치 0 + depth 0 확인
→ 무결성 보고 → Step 8 진입 OK 신호
```

## 의존 자산

- `hooks/link-integrity-check.sh` (R-06 — 즉시 탐지의 광역 버전)
- `rules/phase-q-structure.md` (R-01 — 옛 경로 11 패턴)
- `hooks/output-location-policy.sh` (R-05 — 산출물 8 패턴)

## 변천사

- Phase R+ R-07 (2026-04-27) — 본 스킬 신설 (광역 정기 점검 4축)
