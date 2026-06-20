---
name: dz-module-devenv
description: 특정 Amaranth 10 모듈의 로컬 개발환경(백엔드+프런트)을 깨끗한 클론으로 세팅하고 VSCode로 구동·검증하는 스킬. 사용자가 "CRM 개발환경 띄워줘"·"법무관리 모듈 로컬 세팅"·"X 모듈 개발환경 구성해줘"·"모듈 풀스택 로컬 개발 세팅"·"새 모듈 클론해서 환경 만들어줘"·"여러 모듈 한 번에 띄워줘(멀티모듈 동시 기동)" 등을 요청할 때 활성. 입력=모듈명 + 그 모듈 개발자 application.yml. BE(amaranth10-{모듈})·FE(klago-ui-{모듈}-micro + 번들러 klago-ui-micro)를 iCloud 밖에 클론 → 설정(개발자 yml 170 통일·로컬 CORS·.vscode) → 미선언 의존 자동 해소·node-sass(Apple Silicon) dart-sass 폴백 → 빌드·구동·헬스·CORS 검증 → 모듈 가이드 산출. 멀티모듈은 a10-devenv.code-workspace 템플릿으로 BE 컴파운드 동시 F5 + setupProxy.js(:3000 하나가 /{모듈}→로컬 BE·/system→develop 자동 라우팅, 브라우저 CORS 불요). 로그인(비밀번호)·VSCode F5는 사람 핸드오프. 단일 출처(SSoT) = 규칙/프로세스/개발환경-구성-표준.md.
version: 0.3.1
---

# 모듈 로컬 개발환경 세팅 (dz-module-devenv)

> **의존 SSoT(단일 출처, Single Source of Truth)**: [`규칙/프로세스/개발환경-구성-표준.md`](../../../규칙/프로세스/개발환경-구성-표준.md) — 환경 5단계·스택·프로파일·FE 절차·트러블슈팅의 정본. 본 스킬은 그 표준을 **특정 모듈에 적용하는 실행 절차**다.
> **검증 근거**: CRM 모듈 풀스택 로컬 실증(2026-06-17, end-to-end 성공) + 법무관리(LTE) 실증(2026-06-16).

**용어 풀이**: BE(백엔드, 서버측) · FE(프런트엔드, 화면측) · SSoT(단일 출처) · 번들러(여러 화면 모듈을 묶어 구동하는 FE 작업공간 klago-ui-micro) · 워크스페이스(yarn이 여러 패키지를 함께 묶어 관리하는 단위) · 미선언 의존(소스가 import하지만 package.json에 안 적힌 패키지) · babelTargets(번들러가 소스를 변환할 대상 패키지 목록) · dart-sass(순수 JS로 된 Sass 컴파일러 `sass`, 네이티브 빌드 불필요) · node-sass(C++ 네이티브 Sass 컴파일러, Apple Silicon에서 빌드 난항) · 인증 Redis(로그인 세션을 저장하는 Redis의 13번 DB) · dev-login(개발 서버 계정으로 로그인) · 핸드오프(자비스가 못 하는 부분을 사람에게 넘김)

---

## 0. 한 줄 정의

모듈명과 그 모듈 개발자의 `application.yml` 하나를 받아, **백엔드와 프런트를 깨끗한 클론에 세팅하고 VSCode로 띄울 수 있는 상태까지 자동 구성·검증**한다. 로그인 비밀번호와 VSCode F5만 사람이 한다.

> **⚖️ 적용 범위(비강제, opt-in)**: 본 스킬은 **신규/추가 개발환경을 표준대로 세팅**하는 용도다. 이미 본인 개발환경을 갖춘 개발자의 구성을 바꾸지 않는다 — 표준은 지원·권고이지 강제가 아니다(표준 §0.2 적용 원칙). 발동은 사용자가 "구성해줘"라고 요청할 때만 — 기존 환경 보유자에게 마이그레이션을 권하지 않는다.

---

## 1. 트리거 / 발동

**사용자 호출**(한글):
- "{모듈} 개발환경 띄워줘" · "{모듈} 모듈 로컬 세팅" · "{모듈} 풀스택 로컬 개발 환경 구성"
- "새 모듈 클론해서 VSCode 환경 만들어줘" · "모듈 개발환경 표준대로 세팅"

**선행 확인**: 사내망(회사 WiFi/VPN) 접속 상태여야 함(개발 DB·Redis·GitLab·Nexus 도달 필요).

---

## 2. 입력과 모듈 메타 도출

### 2.1 입력(사람이 제공)
1. **모듈명** (예: `crm`, `lte`, `board`, `kiss`, `ab`)
2. **그 모듈 개발자의 `application.yml`** — 신규 개발 서버(현행 14.41.2.170 계열)를 가리키는 실제 설정. 비밀번호 포함 → **로컬 클론에만** 두고 forge 트리·git push 금지.

### 2.2 규칙으로 도출(자비스가 계산)
| 항목 | 규칙 | CRM 예시 |
|---|---|---|
| BE 레포 | `http://14.41.55.45:8089/dz-springboot/amaranth10-{모듈}.git` | amaranth10-crm |
| FE 모듈 레포 | `http://14.41.55.45:8089/microfront/klago-ui-{모듈}-micro.git` | klago-ui-crm-micro |
| FE 번들러(공유) | `http://14.41.55.45:8089/KLAGO/klago-ui-micro.git` | (모듈 공통, 1회 클론) |
| BE 포트·context | 개발자 yml `server.port` / `server.servlet.context-path` | 8020 / `/crm` |
| FE 모듈 코드 | FE 모듈 `package.json` `moduleCode` | `crm` |
| 클론 위치 | `~/devenv-poc/` (iCloud 밖, 삭제 예정) | |

> `module-overview.md`·소스 프로파일([`Amaranth10/_소스분석/profiles/`](../../../Amaranth10/_소스분석/profiles/))로 레포 그룹·이름을 교차 확인. 그룹이 다르면(예: gw 계열) 실측 후 보정.

---

## 3. 사전 점검 (1회)

```bash
# 도구
java -version            # JDK 21 (Homebrew openjdk@21)
node -v ; nvm ls         # FE는 Node 16 필요 (nvm use 16)
yarn -v                  # 1.22.x
# 사내망 도달성 (예: 170 신규 backing)
for p in 32000 32002 32031; do nc -z -G 3 14.41.2.170 $p && echo "✅170:$p"; done
nc -z -G 3 14.41.55.45 8089   # GitLab
nc -z -G 3 14.41.55.45 30000  # Nexus
curl -s -o /dev/null -w "%{http_code}\n" https://develop.amaranth10.co.kr  # 200
# FE 미러 우회(insteadOf) — 1회 (git.duzon.com·sbfigma 차단 우회). 표준 §6.2
git config --global url."http://14.41.55.45:8089/KLAGO/".insteadOf "http://git.duzon.com/uiux-busan/"
git config --global url."http://14.41.55.45:8089/".insteadOf "https://sbfigma.amaranth10.co.kr/"
```

⛔ **iCloud 함정**: `보관함(Local)`(iCloud 동기화) 안에서 빌드 금지 — `" 2.java"` 중복이 컴파일을 깬다. 반드시 `~/devenv-poc` 등 **iCloud 밖**에서 클론·빌드.

---

## 4. 백엔드(BE) 절차

```bash
cd ~/devenv-poc
git clone -b master http://14.41.55.45:8089/dz-springboot/amaranth10-{모듈}.git
cd amaranth10-{모듈}
```

1. **설정 교체** ⭐ — 레포 기본 `config/application.yml`은 옛 서버(189)를 가리킨다. **개발자 yml(170 통일)로 전면 교체**(원본은 `.repo-189.bak`로 백업). 이유: 인증 Redis가 `base` 설정을 따르므로 base를 로그인 서버로 통일해야 함(표준 §7, 함정 ③).
   - 교체 yml에 두 줄 추가: `spring.config.import: optional:classpath:/config/application.yml`(있으면 유지 — MCP 등 클래스패스 설정 로드) + `Klago.localCors: true`(아래 CORS 게이트)
2. **로컬 CORS 신설** — `src/main/java/klago/config/LocalDevCorsConfig.java`(모듈 무관 동일 코드, 본 스킬 `assets/LocalDevCorsConfig.java`). `WebMvcConfigurer.addCorsMappings`로 `localhost:3000` 허용, 게이트 `@ConditionalOnProperty(name="Klago.localCors", havingValue="true")` → 운영엔 키 없어 미발동. (앱에 Spring Security 없어 MVC가 프리플라이트 403 거절하므로 필요 — 함정 참조)
3. **`.vscode/`** — `launch.json`(mainClass=모듈 메인 클래스 FQN — 대개 `klago.{모듈대문자}Application`이나 모듈마다 다름. 예: 연락처(AB)=`co.duzon.AddressBookApplication`. cwd=`${workspaceFolder}`, env `Amaranth10_JSPT`=placeholder)·`settings.json`(JDK21 실경로 `/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home` + `boot-java.live-information.automatic-connection.on:false`)·`extensions.json`(Java pack). 본 스킬 `assets/be-vscode/` 템플릿 사용, `{{MAIN_CLASS}}`·`{{MODULE}}`만 모듈별 치환.
   - ⚠️ **`projectName`은 비운다**(함정 ⑦) — mainClass가 유일하면 단일·멀티루트 모두 해소. 지정하면 멀티루트에서 자바 언어서버 합성명(`{rootProject.name}-{폴더명}`)과 불일치해 `ConfigError: not a valid java project`.
   - config `name`은 템플릿이 `{{MODULE}} BE (로컬 develop 풀스택)`로 치환 — 멀티모듈 워크스페이스 컴파운드가 이 이름으로 참조한다(함정 ⑨).
4. **빌드·구동 검증**(CLI — VSCode F5와 동등):
   ```bash
   export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
   export Amaranth10_JSPT="localdev-no-enc"   # ENC() 없으면 무해
   ./gradlew clean compileJava                 # CORS 클래스 컴파일 확인
   ./gradlew bootRun --console=plain           # 백그라운드 → "Started ...Application"
   curl -s http://localhost:{포트}/{모듈}/actuator/health   # {"status":"UP"} = 170 DB 연결 OK
   # CORS: 실제 컨트롤러 경로로 검증 (actuator는 MVC addCorsMappings 비대상)
   curl -si -X OPTIONS http://localhost:{포트}/{모듈}/{컨트롤러경로} \
     -H "Origin: http://localhost:3000" -H "Access-Control-Request-Method: POST" | grep -i Access-Control-Allow-Origin
   ```
   - 컨트롤러 경로는 `grep -rhoE '@(Get|Post|Request)Mapping\("/[^"]+"' src/main/java/.../api | head` 로 하나 추출.

⛔ **가드레일**: `/{모듈}/sqlUpdate` (POST) **절대 호출 금지** — 부팅은 DB를 변경하지 않지만(DBPatchInit은 빈만 생성, start() 미호출), 이 엔드포인트만이 공유 DB에 DDL/DML을 실행한다.

---

## 5. 프런트엔드(FE) 절차

```bash
cd ~/devenv-poc
# 번들러는 모듈 공통 — 이미 있으면 재사용(2번째 모듈부터 빠름)
[ -d klago-ui-micro ] || git clone --recursive -b master http://14.41.55.45:8089/KLAGO/klago-ui-micro.git
cd klago-ui-micro && mkdir -p packages common
# 모듈 마이크로 추가
[ -d packages/klago-ui-{모듈}-micro ] || (cd packages && git clone -b master http://14.41.55.45:8089/microfront/klago-ui-{모듈}-micro.git)
source "$HOME/.nvm/nvm.sh" && nvm use 16
yarn autoClone                       # 선언된 * 공통 의존 재귀 자동 클론
bash {스킬}/scripts/resolve-undeclared-deps.sh   # ★ 미선언 의존 연쇄 자동 해소(클론+* 선언)
yarn install --ignore-engines
bash {스킬}/scripts/fix-node-sass.sh             # ★ node-sass 로드 실패 시 dart-sass 폴백
yarn packages                        # 모듈 등록(modules.js 갱신)
```

**`.env.local`** (`micro-common/bundler/.env.local`):
```
REACT_APP_DEPLOY_TYPE=subDev
REACT_APP_DEPLOY_API_URL=http://localhost:{포트}        # ★ 맨 호스트만 — context(/{모듈}) 붙이지 말 것
REACT_APP_DEPLOY_AUTH_URL=https://develop.amaranth10.co.kr   # 개발자 yml의 Klago.groupware.domain
```
> ⛔ **경로 중복 함정**: FE가 모듈 접두사(`/{모듈}`)를 스스로 붙인다. API_URL에도 붙이면 `/{모듈}/{모듈}/...` → 404. **API_URL은 호스트:포트까지만.**
>
> 🔀 **단일 vs 멀티모듈(API_URL 분기)**:
> - **단일 모듈** → API_URL=`http://localhost:{포트}`(BE 직결). LocalDevCorsConfig(함정 ⑤)가 브라우저 CORS를 처리.
> - **멀티모듈 공존**(법무·CRM 등 동시) → API_URL=`http://localhost:3000`(프록시 방식). `:3000` 하나가 `setupProxy.js`로 `/{모듈}→로컬 BE`·`/system→develop`을 서버측 전달 → **브라우저 CORS 자체가 안 생김**. 설치는 §5.5.

**구동·검증**:
```bash
nvm use 16 && yarn start            # webpack-dev-server :3000
# "Compiled with warnings"(실패 0) + :3000 HTTP 200 = 성공
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000
```

---

## 5.5 멀티모듈 동시 기동 (여러 BE 한 번에)

여러 모듈을 함께 띄울 땐 모듈마다 §4·§5를 끝낸 뒤, **하나의 작업 영역(`.code-workspace`)에서 BE들을 컴파운드로 동시 F5**한다. FE 번들러(`klago-ui-micro`) 하나가 **프록시(`setupProxy.js`)** 로 모든 모듈을 라우팅하므로 FE는 한 번만 띄운다.

**① FE 프록시 설치** — `assets/setupProxy.js`를 `klago-ui-micro/micro-common/bundler/src/setupProxy.js`로 복사. CRA dev-server가 자동 로드한다(수동 등록 불필요). 동작:
- `~/devenv-poc/amaranth10-*/config/application.yml`에서 context-path·port를 **자동 도출** → `/{모듈}/* → http://localhost:{포트}` 라우트 생성(모듈 추가 시 FE 재시작만으로 자동 반영, 프록시 수정 0).
- 공통 플랫폼 `/system/*`(luna-orbit OBTPageContainer의 `getGridSettingList`·`getRelativeProcess` 등) + 잘못 풀린 `/modules/bundler/system/*` → **develop**(로컬엔 공통 백엔드 부재, `/gw`와 동일 취지).
- `.env.local`의 `REACT_APP_DEPLOY_API_URL=http://localhost:3000`(동일 출처). 브라우저가 모두 :3000 호출 → 프록시가 서버측 전달 → **브라우저 CORS 자체가 안 생김**.
- ⚠️ 함정: 블록 주석에 슬래시-별표 종료 기호를 쓰면 주석이 조기 종료돼 `SyntaxError` — 자산은 이미 회피 작성됨. 변경 시 `node -c setupProxy.js`로 구문 확인.

**② BE 동시 F5** — 아래 작업 영역 컴파운드:

1. 템플릿 복사 — `assets/a10-devenv.code-workspace`를 `~/devenv-poc/a10-devenv.code-workspace`로 복사. 함께 띄울 모듈에 맞게 **세 곳을 함께** 고친다:
   - `folders` 배열 — `amaranth10-{모듈}` 항목 추가/삭제
   - `launch.compounds` "BE 전체 기동" — `"{모듈} BE (로컬 develop 풀스택)"` 추가/삭제
   - 각 모듈 `.vscode/launch.json`의 config `name`이 위와 글자까지 동일한지 확인(함정 ⑨)
2. VSCode에서 "파일 > 작업 영역 열기"로 `.code-workspace`를 연다 → 자바 임포트 완료 대기.
3. 실행 패널 → "BE 전체 기동 (CRM + LTE + AB)" 컴파운드 F5 → 모든 BE 기동(각 헬스 `UP`).
4. FE는 Run Task "FE 포털 기동 (yarn start :3000)"로 따로 띄운다(BE와 별개 프로세스).

> ⚠️ 멀티 동시 기동의 두 함정은 **템플릿에 이미 해결돼 있다** — `launch.json` `projectName` 비움(⑦) + 워크스페이스 `settings`의 `boot-java.live-information.automatic-connection.on:false`(⑧). 설정을 바꾼 뒤엔 Reload Window가 필요하고, 그게 FE 터미널을 종료시키므로 FE는 다시 Run Task로 시작한다.
> 모든 BE가 같은 인증 Redis(170:32031)를 공유하므로 **한 번 로그인으로 여러 모듈 세션 공유**된다(2026-06-18 CRM+LTE+AB 실측: 4포트 헬스 200·프록시 사슬·JMX 충돌 0).

---

## 6. 함정 카탈로그 (실증으로 확인 — 반드시 인지)

| # | 증상 | 원인 | 해법 |
|---|---|---|---|
| ① **미선언 의존** | 컴파일 `Module not found` 또는 `experimental syntax 'jsx'` | 모듈/공통이 import하나 package.json 미선언 → autoClone 누락 + babelTargets(선언 `*`만 재귀) 제외 | `resolve-undeclared-deps.sh`: 누락 패키지 common/에 클론(microfront→ui→KLAGO 순) + **import하는 패키지의 package.json에 `"*"` 선언 추가**(babelTargets 합집합 포함) |
| ② **node-sass 빌드 불가**(Apple Silicon) | `node-sass does not yet support ... arm64 ... runtime` | 4.14.1 arm64 prebuilt 없음(404) + 소스 컴파일 실패(Node16 V8헤더×최신 clang) + 번들 node-gyp 3.8.0이 python2 요구 | `fix-node-sass.sh`: node-sass를 옆으로 치워(`.broken`) sass-loader 8이 **dart-sass(이미 설치)** 자동 폴백 |
| ③ **인증 얼럿 재발/재로그인** | "인증 값을 레디스에서 찾을 수 없습니다" 반복 | 인증 Lettuce가 **base `Klago.redis`** 를 읽는데 그게 로그인 세션 서버와 다름(프로파일 override는 인증 init에 미도달) | **base application.yml의 `Klago.redis`를 로그인 서버(develop 뒷단 = 170:32031 db13)로 통일.** 개발자 yml이 이미 170 통일이면 OK |
| ④ **iCloud 컴파일 깨짐** | `ClassNotFound`·중복 빌드 | `보관함(Local)`(iCloud) `" 2.java"` 중복 | iCloud 밖(`~/devenv-poc`)에서 클론·빌드 |
| ⑤ **CORS 403** | 화면 빈 채 "네트워크 상태가…" / OPTIONS 403 | 앱에 Spring Security 없음 → MVC DefaultCorsProcessor가 프리플라이트 거절(앞단 프록시 부재) | `LocalDevCorsConfig`(devMode/localCors 게이트) |
| ⑥ **경로 /{모듈} 중복** | API 404 | FE 접두사 + API_URL 접두사 중복 | `.env.local` API_URL=맨 호스트 |
| ⑦ **F5 `ConfigError: not a valid java project`** (멀티모듈) | BE 미기동 | 멀티루트에서 자바 LS가 프로젝트를 `{rootProject.name}-{폴더명}` 합성명(예: `crm-amaranth10-crm`)으로 등록 → `launch.json`의 `projectName`이 폴더명·단순 gradle명을 가리켜 불일치(단일 폴더만 열면 프로젝트 1개라 통과해 안 드러남) | `launch.json` **`projectName` 제거**(mainClass 유일성으로 해소 — 템플릿 기본값). 굳이 명시 시 실측 등록명 확인: `…/redhat.java/jdt_ws/.metadata/.plugins/org.eclipse.core.resources/.projects/` |
| ⑧ **멀티 BE 동시 F5 `Port already in use: 10000 / BindException`** | 첫 BE만 뜨고 뒤 BE 종료 | Spring Boot 확장(`vmware.vscode-spring-boot`)이 라이브 데이터용 JMX 인자(`jmxremote.port=10000~`)를 각 앱에 주입, 동시 기동 시 포트를 못 나눔 | `settings.json`(폴더·워크스페이스)에 **`"boot-java.live-information.automatic-connection.on": false`**(JMX 주입 차단, 구동·디버그 무관) → Reload Window 후 재F5 |
| ⑨ **컴파운드가 일부 BE를 안 띄움** | code-workspace `BE 전체 기동` 실행 시 특정 모듈 누락 | 컴파운드 `configurations`의 참조명이 그 모듈 `launch.json` config `name`과 불일치(예: mainClass 접두사 `klago.` 유무 차이) | 둘을 똑같이 맞춤. 템플릿이 config `name`을 `{{MODULE}} BE (로컬 develop 풀스택)`로 통일 → 컴파운드도 동일 문자열 참조 |
| ⑩ **환경별 서명키(`Sign.Value`)·Mqtt 맹복사** | 로그인은 되는데 토큰 검증 실패/재로그인, 또는 일부 호출 401 | 레포 기본 yml의 `Klago.Sign.Value`(모듈 간 내부 인증 서명키)·Mqtt 값을 **그대로 복사**하면 환경이 어긋남 — 서명키는 환경별로 다르다(예: LTE 레포 기본 `4edec…`=189 / develop(170)은 `0bd9…`). 로그인이 develop 경유인데 서명키가 옛 환경 값이면 토큰 검증 실패 | 개발자 yml(170 통일)의 값을 쓴다. 개발자 yml이 없어 레포 기본으로 구성할 땐 **`Sign.Value`·Mqtt 등 환경 종속 값을 develop(170) 값으로 정정**(맹복사 금지). 같은 모듈의 다른 개발자 yml이나 develop yml로 교차 확인 |
| ⑪ **브랜치↔DB 스키마 드리프트**(특정 화면만 500) | 한 화면만 `resultCode 500`+네트워크 얼럿(다른 화면은 정상) | 클론 브랜치 코드가 참조하는 컬럼/테이블이 그 DB에 아직 없음. `master`(최신)는 신규 컬럼을 SELECT하는데 **170 backing은 develop 환경 DB**라 DBPatch 미반영 → `Unknown column`(SQL 1054) → 500. (실증: LTE 송무 `t_lte_incident.RESULT_TYPE_TEXT` — master 참조 2·develop 참조 0) | **클론 브랜치는 170 DB가 정합하는 `develop`을 기본 권고**(170=develop 환경). `master`는 DB도 master급(검수/운영 스키마)일 때만. 진단: VSCode 디버그 콘솔 SQL 예외 또는 `SHOW COLUMNS FROM {스키마}.{테이블}`로 누락 컬럼 확인. DB측 누락이면 담당 개발자에게 DBPatch 반영 요청(공유 DB 직접 변경 금지) |

> cosmetic(무해) 경고: `react-pdf/pdfjs Critical dependency`, `oneAI/*.types.d.ts Namespace not marked type-only`, `Browserslist outdated`, `DEP0148`(postcss exports) — 모두 빌드 무관.

---

## 7. 핸드오프 (사람만 가능)

- **개발자 yml 제공** — 비밀번호 포함, 매번 사람이 붙여줌(스킬은 트리에 저장 안 함)
- **브라우저 로그인** — `localhost:3000` → develop 계정(회사코드·ID·비밀번호). 자비스는 비밀번호 입력 불가(안전정책)
- **VSCode F5** — 자비스는 VSCode를 직접 조작 못 함(타이핑 차단). CLI로 동등 검증 후 `.vscode`를 만들어 넘긴다. 사용자가 BE 폴더 열고 F5, FE 폴더 열고 터미널 `nvm use 16 && yarn start`(또는 Run Task)

검증 정직성: 자비스는 **빌드·부팅·헬스·CORS·컴파일·서빙(:3000 200)까지** 확정한다. **로그인 후 화면 데이터 렌더**는 사람 로그인 결과로 확인.

---

## 8. 산출·기록

- **모듈 가이드**: `Amaranth10/{모듈}/개발환경-구성.md` — 본 모듈 고유값(포트·context·레포·실측 검증값·함정) + 표준 SSoT 참조. (LTE·CRM 가이드와 동형 — `dz-module-devenv/assets/module-guide-template.md` 기반)
- **세션 기록**: `_개인/sessions/{작업}/_current.md`에 단계별 실측·마커 누적(강제원칙 2 사실 기록)
- 표준에 새 함정 발견 시 → `개발환경-구성-표준.md` §6/§9 보강(본문 변경은 승인 후)

---

## 8.5 forge 맥락 브리지 (선택 — VSCode Claude Code)

VSCode의 Claude Code가 이 개발환경에서 douzone-forge 맥락(소스분석·모듈·프로젝트·조직·규칙)을 인지하도록 연결한다. (CoWork 앱은 forge를 직접 마운트하므로 불필요 — VSCode Claude Code 전용)

```bash
bash <forge>/규칙/프로세스/forge-bridge/setup-forge-bridge.sh [DEV_DIR] [--force]
```

- **개발자마다 다른 환경 지원**: forge 루트는 스크립트가 자기 위치로 자동 감지(클론 위치 무관). `DEV_DIR` 생략 시 자동 결정(현재 폴더에 모듈 레포 → 그곳 / `~/devenv-poc` → 그곳 / 아니면 경로 요구). **이미 구성된 개발환경에 추가로 얹는 시나리오 지원.**
- **기존 `CLAUDE.md` 보존**: 본인 소유 CLAUDE.md가 있으면 덮어쓰지 않고 사이드카 `_forge-bridge.md` 생성 + `@_forge-bridge.md` import 안내(`--force`로 덮어쓰기). 멱등.
- **결과**: 개발 폴더에 `_forge` 심링크 + `CLAUDE.md`(코딩 핵심 자동 로드 + forge 전 영역 지도) → 새 Claude Code 세션이 자동 로드(`/memory` 확인, 첫 세션 외부 import 승인 1회). dz-* 커맨드는 플러그인 설치 시.
- 단일 출처: `규칙/프로세스/forge-bridge/`(스크립트·`CLAUDE.md.tmpl`·README) · 표준 §11.

---

## 9. 서버 정리 (작업 종료 시)

```bash
lsof -ti:{포트} -sTCP:LISTEN | xargs kill   # BE
lsof -ti:3000  -sTCP:LISTEN | xargs kill    # FE
# 클론 삭제(재클론 복구 가능): rm -rf ~/devenv-poc/{...}
```

---

## 10. 의존·연계

- SSoT: [`개발환경-구성-표준.md`](../../../규칙/프로세스/개발환경-구성-표준.md) (§3 DB타게팅·§4 IDE·§5 BE셋업·§6 FE·§7 인증·§9 트러블슈팅·§10 온보딩·부록 A 샘플)
- 비밀정보: [`비밀정보-관리-표준.md`](../../../규칙/프로세스/비밀정보-관리-표준.md) — 자격증명 트리 밖 로컬만
- 브랜치: **기본 권고 `develop`**(170 backing=develop 환경이라 코드↔DB 스키마 정합 — 함정 ⑪). `master`(정상 소스)는 DB도 master급(검수/운영 스키마)일 때만. 화면별 500(스키마 드리프트) 시 함정 ⑪ 참조
- 헬퍼: `scripts/resolve-undeclared-deps.sh`(미선언 의존 해소) · `scripts/fix-node-sass.sh`(dart-sass 폴백) · `assets/`(LocalDevCorsConfig·`be-vscode/`(.vscode 템플릿)·`setupProxy.js`(멀티모듈 프록시 — :3000 하나가 /{모듈}→로컬 BE·/system→develop 자동 라우팅)·`a10-devenv.code-workspace`(멀티모듈 동시 기동)·가이드 템플릿)
- forge 맥락 브리지(VSCode Claude Code): `규칙/프로세스/forge-bridge/`(setup 스크립트·`CLAUDE.md.tmpl`·README) · 표준 §11 · 본 스킬 §8.5
