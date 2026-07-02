---
name: lessons-learned
description: >
  This skill should be used when the user says "교훈 기록해",
  "이거 기억해둬", "다음에 이런 실수 하지 마",
  "패턴 추가해", "lessons learned",
  or when recording corrections, feedback, or process improvements.
  Records lessons learned and process patterns to prevent recurring mistakes.
version: 0.1.0
---

# Lessons Learned

프로젝트 진행 중 발생한 교훈과 패턴을 기록·활용한다.

## 교훈 기록 위치

- **CLAUDE.md Section 10** (교훈 및 패턴): 프로젝트 수준의 영구 교훈
- **세션 로그**: 해당 세션에서 배운 것 (일회성 맥락 포함)

## 교훈 기록 시점

1. **PM이 수정/피드백을 주었을 때** — 즉시 기록
2. **에이전트가 잘못된 결과를 냈을 때** — 원인 분석 후 기록
3. **예상보다 잘 된 패턴을 발견했을 때** — 재활용을 위해 기록
4. **세션 종료 시** — 해당 세션의 교훈을 정리

## 기록 형식

```markdown
### YYYY-MM-DD
- {교훈 내용} → {방지/활용 규칙}
```

예시:
```markdown
### 2026-03-21
- 에이전트에게 "계획 세워서 확인 받아라" 하면 불필요한 대기 발생 → 프롬프트에 "바로 실행" 명시
- 기존 모듈 연동을 당연시 가정함 → 비즈니스 맥락은 반드시 PM에게 확인 후 진행
```

## 교훈 활용

- 에이전트 디스패치 시 관련 교훈을 프롬프트에 반영
- 새 세션 시작 시 CLAUDE.md Section 10을 읽어 반복 실수 방지
- 유사한 작업을 할 때 이전 교훈을 참고하여 접근 방식 조정


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
