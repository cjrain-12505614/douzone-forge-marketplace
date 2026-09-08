---
name: dz-unit-test
description: "A10 단위 테스트 작성 안내 — 사내 위키 JUnit 관례 기준 (구현 후 후행 검증)"
---

# /dz-unit-test — A10 단위 테스트 작성

A10에서 **DAO·서비스 단위 테스트를 어떻게 쓰는지**를 사내 관례대로 안내한다.

> **이름이 바뀐 이유** (2026-08-13) — 종전 `/dz-tdd` 는 RED→GREEN→REFACTOR 교과서, 즉 **테스트 선행**을 팔았다.
> 그런데 A10 사내 위키 정식 항목은 「테스트 케이스 작성할 DAO를 **선택하여** JUnit Test 를 만든다」 —
> **구현이 먼저 있고 뒤에 검증하는 방식**이다. 방향이 반대라 이름과 내용을 함께 바꿨다.

⛔ **이것은 통과 관문이 아니다.** 현재 forge 개발표준·코딩규칙에 단위 테스트 의무 조항이 없다(2026-08-13 실측 0건).
쓸 때 **어떻게 쓰는지**를 알려줄 뿐, 안 썼다고 막지 않는다.

## 사용법

```
/dz-unit-test {대상 클래스 또는 기능}
```

예: `/dz-unit-test EapBoxEmpDAO.insertEapBoxEmp`

## 0. 먼저 — 이 레포에서 테스트가 실제로 돌아가는가

⚠️ **테스트를 쓰기 전에 실행기 조합부터 확인한다.** 어긋나면 실패가 아니라 **조용히 실행되지 않는다.**

```bash
cd ~/dev/amaranth10-{모듈}          # 본인 클론 위치
grep -nE "springBootVersion|org.springframework.boot|junit|useJUnitPlatform" build.gradle
```

| 조합 | 결과 |
|---|---|
| `useJUnitPlatform()` (JUnit 5 실행기) + `junit:junit:4.x` 만 있고 **vintage 엔진 없음** | 🔴 **JUnit 4 테스트가 수집되지 않는다** — 0 tests 로 조용히 통과 |
| `useJUnitPlatform()` + `junit-jupiter` | ✅ JUnit 5로 쓴다 |
| `useJUnitPlatform()` 없음 (기본 JUnit 4 러너) | ✅ 위키대로 JUnit 4로 쓴다 |

- 실측(2026-08-13): `amaranth10-crm`·`amaranth10-lte` 두 레포가 첫 줄 조합이다. **SBUnit 담당 모듈이라 특히 주의.**
  _(확인 필요 2026-08-13 — Spring Boot 2.4부터 `spring-boot-starter-test` 에서 vintage 가 빠진다는 경계는 미실측. `./gradlew dependencies --configuration testRuntimeClasspath` 로 확정할 것.)_
- **빌드에서 테스트를 제외해 둔 레포도 있다** — `build.gradle` 의 `exclude '**/*Test.class'` 류 주석을 확인한다. 평시 제외하고 돌릴 때만 푸는 관례가 있다.

## 1. 작성 규약 (사내 위키 40470641 기준)

| 항목 | 규약 |
|---|---|
| 프레임워크 | **JUnit 4** |
| 위치 | **`src/test/java`** (위자드 기본값이 아니므로 소스 폴더를 바꿔 지정) |
| 메소드명 | **`test` + 대상 메소드명** — 예: `testInsertEapBoxEmp()` |
| 컨텍스트 | `@RunWith(SpringJUnit4ClassRunner.class)` + `@ContextConfiguration(locations={...})` |
| 설정 | `globals.properties` 의 경로를 본인 개발환경에 맞게. 테스트 전용 properties 를 따로 두는 것을 권장 |

⛔ `should_…_when_…` 형식은 **A10 소스에 0건**이다(2026-08-13 전수 실측). 위 `testXxx()` 를 쓴다.

## 2. ★ DB를 건드리는 테스트는 `@Transactional` 을 함께 붙인다

```java
// 입력·수정·삭제 테스트에 @Test 와 @Transactional 을 함께 붙이면
// JUnit이 자동으로 되돌림(RollBack)을 수행해 테스트 뒤 데이터가 남지 않는다.
@Test
@Transactional
public void testInsertEapBoxEmp() {
    Map params = new HashMap() {{ /* 입력 파라미터 */ }};
    int result = dao.insertEapBoxEmp(params);
    assertNotNull("리턴값에 널이 포함되어 있음", result);
}
```

**실제 결과를 DB에 남겨야 할 때만** `@Transactional` 을 뺀다. 빼면 개발 DB에 데이터가 쌓인다.

## 3. 자주 쓰는 어노테이션

```java
@Test(timeout = 5000)                     // 5초 이내 완료
@Test(expected = RuntimeException.class)  // 예외 발생 확인
@Ignore(value = "스킵 사유")               // 사유를 반드시 적는다
```

## 4. 멀티테넌트 격리 — 세션 스텁

A10은 고객사가 여럿이라 세션 정보(회사·사용자·그룹)가 없으면 조회가 비거나 남의 데이터가 섞인다.
SBUnit 계열 레포(`lte`·`crm`·`crmgw`)에는 `src/test/java/klago/common/TestCommon.java` 가 이 역할을 한다 —
`SessionInfo`·`ERPUserInfo`·`UCUserInfo` 를 세워 준다.

- **레포마다 내용이 갈라져 있다**(2026-08-13 실측 — 세 판본의 해시가 서로 다름). 본인 레포 것을 먼저 읽는다.
- 없는 레포에서 새로 만들 때는 다른 레포 것을 복사하지 말고 **그 모듈의 세션 구조에 맞춰** 세운다.

## 5. 실행·검증

```bash
./gradlew test                                    # 전체
./gradlew test --tests "*EapBoxEmpDAOTest*"       # 특정 클래스
```

- 결과가 `0 tests` 면 §0의 실행기 조합을 다시 본다. **통과가 아니라 미수집**일 수 있다.
- 빌드·린트까지 묶어 확인하려면 `/dz-verify-step`.

## 6. 검수(QA)와 구분

단위 테스트는 **개발자가 코드로 거는 검증**이다. 화면·시나리오 기반 검수는 층이 다르다 —
그쪽은 `규칙/프로세스/검수-표준.md`(forge) + `dz-trace`(시나리오 작성) · `dz-probe`(수행) 영역이다.

## 관련

- 사내 위키 정본: 「9. Amaranth 10 JUnit을 사용한 DAO 테스트」(pageId 40470641) — 미러 `Amaranth10/_소스분석/wiki/백엔드/40470641_수집.md`(forge)
- BE 개발표준가이드 §3.7 JUnit 테스트 패턴 — `Amaranth10/_소스분석/wiki/공통/20260328-BE개발표준가이드-1차.md`(forge)
- 위키 인덱스: `Amaranth10/_소스분석/wiki/_개발가이드-인덱스.md`(forge)
- 후속 검증: `/dz-verify-step`
