---
name: dz-devdesign-write
description: >
  개발설계 산출물(D-08) 작성 스킬. "개발설계 작성해줘" · "{모듈} 개발설계 만들어줘" ·
  "로직/워크플로우·테이블·쿼리·API 정의서 작성" · "BLUEPRINT로 개발설계" · "화면설계를 개발설계로 번역" 트리거.
  화면설계(D-07)·요구사항·IA를 입력받아 개발설계 4종(로직/워크플로우·테이블 정의서·쿼리 정의·API 정의서)을
  개발설계-산출물-작성-표준.md(D-08)대로 한 파일 4섹션으로 생성하고, BLUEPRINT 에이전트로 작성·AEGIS로 검증한다.
  비강제(요청 시 작성). A10 정합(MyBatis·APIResult·멀티테넌트 ${databaseNeos}·resultCode·dbPatch) MUST.
version: 0.1.0
---

# 개발설계 작성 스킬 (dz-devdesign-write)

> 용어: 개발설계(화면설계와 코딩 사이의 기술 설계) · BLUEPRINT(개발설계 작성 전담 서브에이전트) · AEGIS(정합성 검증 전담 에이전트, 읽기·검색만) · MyBatis(SQL을 XML/인터페이스로 다루는 데이터 접근 도구) · `${databaseNeos}`(쿼리에서 고객사별 스키마로 치환되는 변수) · 멀티테넌트(한 시스템이 여러 고객사 데이터를 분리 보관) · 비강제(opt-in, 작성 여부는 선택)
>
> **SSoT(단일 출처)**: [`규칙/프로세스/개발설계-산출물-작성-표준.md`](../../../../../Workspace/douzone-forge/규칙/프로세스/개발설계-산출물-작성-표준.md)(D-08). 본 스킬은 그 표준을 **실행**하는 절차다. 작성 주체 = BLUEPRINT(`.claude/agents/dz-blueprint.md`), 검증 = AEGIS.

## 0. 한 줄 정의

화면설계(D-07)·요구사항을 받아 **개발설계 4종**(로직/워크플로우 · 테이블 정의서 · 쿼리 정의 · API 정의서)을 D-08 표준대로 **한 파일 4섹션**으로 생성한다. 개발(하네스)이 추측 없이 코딩할 확정값을 만든다.

## 1. 발동 / 비강제

- 사용자가 "개발설계 작성"·"{모듈} {기능} 개발설계"·"4종 정의서 작성"을 요청할 때.
- **비강제(opt-in)**: 작성 여부는 본인 선택, 기존 산출물 소급 의무 없음. **단 작성하면 D-08 정합 형식은 MUST**(작성 여부 ≠ 작성 형식).

## 2. 작성 전 체크리스트

1. **선행 입력 존재** — 화면설계(D-07 디스크립션 7항목·SCR 화면코드) · 요구사항(AC/REQ) · IA(화면ID·라이선스 분기). 없으면 먼저 확보(VECTOR·CIPHER·MATRIX 산출).
2. **대상 모듈 스택 확인** — 해당 모듈 `build.gradle`로 Boot/Java 세대·패키지(klago.* 현행 / com.amaranth10.* 신규방침)·스키마(neos/erp) 확인.
3. **소스 앵커 확보** — 같은 모듈 실소스 한 세트(예 LTEWI019 4종, D-08 부록 A)를 복사·대조 기준으로.
4. **세션 체크** — `_개인/sessions/{모듈}/_current.md` 진행 중 건이 있으면 이어받기.

## 3. 절차

```
① 입력 수집·경계 확정
   - 화면설계·요구사항·IA + 모듈 build.gradle 스택·스키마 + 소스 앵커
② BLUEPRINT 에이전트 디스패치 (작성)
   - 4종 생성: 로직/워크플로우(허브) → 테이블 → 쿼리 → API (의존 순서)
   - A10 정합 MUST: MyBatis @Mapper+XML · APIResult 단일 응답 · 멀티테넌트 키 누락 금지
     · ${databaseNeos}/${databaseErp} 변수 · 모듈 범위 resultCode · dbPatch 경유 · KlagoLog
   - 추적 키 4종(REQ/AC·SCR·항목ID·구현매핑[개발 단계 채움]) 부착 · 미확정 _(확인 필요)_
③ AEGIS 검증 (정합성, 읽기·검색만)
   - 추적 키 4종 grep 조인: 4종 중 하나라도 비면 '설계 누락', 키 불일치면 '모순'
   - 품질 게이트(D-08 §9): MyBatis 쌍·멀티테넌트 키·APIResult·resultCode 범위·dbPatch·협업/ERP 미혼용
④ 사용자 최종 확정
   - 확정 항목만 하네스 코딩 입력·검수 대상 (미확정 추측 코딩 차단)
⑤ 발행 (선택)
   - md(정본) → 사내 wiki 등록: JIRA-MCP `wiki_create_page`(공간·제목·본문, body_format=text|storage) / 갱신 `wiki_update_page` (B5 신설, v0.4.0) (+ 필요 시 원피스·PDF)
```

## 4. 출력

| 산출 | 위치 |
|---|---|
| 개발설계 4종 (md 1파일 4섹션, 헤더 순서 로직→테이블→쿼리→API) | `Amaranth10/{모듈}/개발설계/{모듈}-{기능slug}-개발설계.md` |

작업 중엔 작업 폴더, 확정 시 위 경로로 편입(파일 명명 CLAUDE.md 규칙 정합).

## 5. 디스패치 예시

> 사용자: "법무 송무 사건비용 개발설계 작성해줘"

→ ① 화면설계(URA4100)·요구사항·LTEWI019 앵커 수집 → ② BLUEPRINT 디스패치 → `Amaranth10/법무관리(LTE)/개발설계/lte-사건비용-개발설계.md`(4섹션) → ③ AEGIS 검증 → ④ 사용자 확정 → ⑤ wiki 등록 안내.

## 6. 관련 자산

- 표준(SSoT, D-08): [`규칙/프로세스/개발설계-산출물-작성-표준.md`](../../../../../Workspace/douzone-forge/규칙/프로세스/개발설계-산출물-작성-표준.md) (부록 A LTEWI019 앵커)
- 작성 에이전트: BLUEPRINT [`dz-blueprint-agent`](../dz-blueprint-agent/SKILL.md) / `.claude/agents/dz-blueprint.md`
- 검증 에이전트: AEGIS [`dz-aegis-agent`](../dz-aegis-agent/SKILL.md) (Read·Grep 정합성)
- 선행: VECTOR(화면설계)·CIPHER(요구사항)·MATRIX(IA) / 후속: CORE(백엔드)·NOVA(프론트) 구현
- 검수 연계(B4 후속): 검수-표준(D-11) §2 입력 축
