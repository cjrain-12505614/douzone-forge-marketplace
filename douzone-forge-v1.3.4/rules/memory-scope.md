---
name: memory-scope
description: 자비스 메모리는 {이름} 개인 사람 기준만. 범용 룰·운영 워크플로우는 SSoT 이전.
paths: ["**/.claude/projects/**/memory/**/*.md"]
---

# Memory Scope Rule

> 학습 #11 — 메모리 한정 (사람 기준만)
> 발효: 2026-05-11 (Phase V V-07-01)
> SSoT: [`규칙/프로세스/자비스-운영-룰.md`](../../../Workspace/douzone-forge/규칙/프로세스/자비스-운영-룰.md) §2 학습 #11 + §6.2

## 룰 본문

자비스 메모리는 {이름} 개인 사람 기준만 잔존한다. 범용 룰·운영 워크플로우·도구 사용법·범용 매핑·자비스 학습 룰은 douzone-forge SSoT (`규칙/프로세스/`) 로 이전한다.

### 메모리 허용·금지 (자비스-운영-룰 §6.2 인용)

**허용**:
- {이름} 본인 역할·호칭 (SBUnit장, {ID})
- {이름} 부서 사람 매핑 (SBUnit 21명 ID·R&R)
- {이름} 직접 진행 PRJ 비전·결정·KPI
- {이름} 본인 일일보고 메타

**금지**:
- 범용 워크플로우 (자비스 ⑴~⑽ 운영)
- 운영 룰 (학습 #1~#11 본문)
- 도구 사용법 (Chrome MCP·ONEFFICE 추출 패턴)
- 범용 매핑 (모듈 코드·레포 매핑·조직 변천사)
- 자비스 학습 룰 (Phase Q~T 자산)

## 적용 시점·범위

- 시점: 자비스 메모리 신규 Write
- 범위: `*/.claude/projects/*/memory/*.md` 패턴 (MEMORY.md 인덱스 제외)
- 예외: 본문에 "본인·내 ~·{이름}·{ID}·본인 R&R·본인 KPI·본인 일일보고" 매칭 시 통과

## Why

Forge 는 사내 전사 배포 플랫폼 (Beta 3인 → SBUnit 21명 → 사내 4,157명). 자비스 메모리는 {이름} 로컬에만 존재하므로 배포 사용자에게 부재. 범용 룰을 메모리에 두면 격차 발생 → 배포 사용자에게 부재할 본문은 SSoT 인용으로 대체.

## 위반 시 처리

PreToolUse Write Hook (`hooks/memory-rule-content-block.sh`) 이 메모리 경로 + 룰성 본문 키워드 ("전 사용자·범용 룰·운영 워크플로우·매번·의무·표준·일관·강제·배포 사용자") 검출 시 차단 (exit 2).

```
🚫 [memory-rule-content-block] 메모리에 룰성 본문 감지 — Write 차단
    학습 #11 — 메모리 한정 (사람 기준만)
    → 룰성 본문은 douzone-forge/규칙/프로세스/ SSoT 로 이전.
    메모리에는 포인터 스텁만 잔존.
```

### 화이트리스트 (false positive 회피)

- "본인·내 ~·{이름}·{ID}·본인 R&R·본인 KPI·본인 일일보고·내 역할·내 호칭·내 부서·내 상사" 매칭 시 통과
- `MEMORY.md` 인덱스 자체 → 통과 (인덱스는 사람 기준 목록)

## Hook 연계

- `hooks/memory-rule-content-block.sh` — PreToolUse Write, exit code 2 차단

## 관련 자산

- 자비스-운영-룰 §6.2 — 메모리 vs SSoT 분리표
- Phase U 본질 — 메모리 = {이름} 사람 기준만 ({이름} 직접 룰 확정)
- 사람 기준 메모리 19건 (Phase U U-01 분류표 §3)

## 변천사

- 자비스 학습 #11 — Phase T D-04 채택 (2026-04-28)
- Phase U U-02 (2026-04-28) — 자비스-운영-룰 SSoT §6.2 본문 통합
- Phase V V-07-01 (2026-05-11) — 본 Rule 신설로 정책 강제
