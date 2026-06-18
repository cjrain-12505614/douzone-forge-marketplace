---
name: {{MODULE_KR}}-개발환경-구성
description: {{MODULE_KR}}({{MODULE}}) 모듈 로컬 개발환경 구성 가이드 — 표준(개발환경-구성-표준.md)의 본 모듈 적용 구체 레시피·고유값·실측 검증값·함정.
version: 0.1.0
---

# {{MODULE_KR}}({{MODULE}}) 개발환경 구성 가이드

> dz-module-devenv 스킬 산출. SSoT = [`개발환경-구성-표준.md`](../../규칙/프로세스/개발환경-구성-표준.md). 본 문서는 **{{MODULE}} 고유값**만.
> 클론 위치: `~/devenv-poc/` (iCloud 밖, 삭제 예정). 자격증명은 로컬 클론에만 — forge 미반영.

## 1. {{MODULE}} 환경 한눈에

| 항목 | 값 |
|---|---|
| BE 레포 | `dz-springboot/amaranth10-{{MODULE}}` (master) |
| BE 포트 / context | `{{BE_PORT}}` / `/{{MODULE}}` |
| FE 모듈 레포 | `microfront/klago-ui-{{MODULE}}-micro` (master), 모듈 코드 `{{MODULE_CODE}}` |
| FE 번들러 | `KLAGO/klago-ui-micro` (모듈 공통) |
| 인증 | develop.amaranth10.co.kr (세션 Redis = 신규 backing db13) |
| DB·Redis | 개발자 yml 기준(신규 개발 서버 14.41.2.170 계열) |

## 2. 통합 구동 검증 ({{DATE}} 실측)

- BE: `bootRun` → `Started {{MAIN_CLASS}}` · `:{{BE_PORT}}/{{MODULE}}` · `actuator/health` UP(개발 DB 연결)
- FE: `yarn start` → Compiled · `:3000` 포털 200
- CORS: 컨트롤러 OPTIONS(Origin :3000) → Allow-Origin :3000 / 미허용 Origin → 403
- 로그인 후 화면 데이터: {{LOGIN_RESULT}}

## 3. BE 셋업 (표준 §4·§5 적용)

```bash
cd ~/devenv-poc && git clone -b master http://14.41.55.45:8089/dz-springboot/amaranth10-{{MODULE}}.git
cd amaranth10-{{MODULE}}
# 1) config/application.yml ← {{MODULE}} 개발자 yml(170 통일) 교체(원본 .repo-189.bak 백업)
#    + spring.config.import 유지 + Klago.localCors: true
# 2) src/main/java/klago/config/LocalDevCorsConfig.java 신설(스킬 assets)
# 3) .vscode (launch=klago.{{MAIN_CLASS_SHORT}}Application, JDK21)
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export Amaranth10_JSPT="localdev-no-enc"
./gradlew bootRun --console=plain   # 또는 VSCode F5
```

## 4. FE 셋업 (표준 §6 적용)

```bash
cd ~/devenv-poc
[ -d klago-ui-micro ] || git clone --recursive -b master http://14.41.55.45:8089/KLAGO/klago-ui-micro.git
cd klago-ui-micro && mkdir -p packages common
(cd packages && git clone -b master http://14.41.55.45:8089/microfront/klago-ui-{{MODULE}}-micro.git)
source "$HOME/.nvm/nvm.sh" && nvm use 16
yarn autoClone
bash <스킬>/scripts/resolve-undeclared-deps.sh   # 미선언 의존 자동 해소
yarn install --ignore-engines
bash <스킬>/scripts/fix-node-sass.sh             # node-sass→dart-sass(Apple Silicon)
yarn packages
# micro-common/bundler/.env.local:
#   REACT_APP_DEPLOY_TYPE=subDev
#   REACT_APP_DEPLOY_API_URL=http://localhost:{{BE_PORT}}      (맨 호스트만!)
#   REACT_APP_DEPLOY_AUTH_URL=https://develop.amaranth10.co.kr
nvm use 16 && yarn start   # :3000
```

## 5. {{MODULE}} 고유 함정·메모

- {{MODULE_NOTES}}
- 공통 함정 6종은 표준 §9 + dz-module-devenv SKILL.md §6 참조.

## 6. 가드레일

- `/{{MODULE}}/sqlUpdate` (POST) 호출 금지 — 유일한 공유 DB 변경 경로(부팅은 무변경).
