# Changelog

## v1.6.1 (2026-06-21) — 개발설계 위키 발행 위치·양식 정합 + draw.io 자동화

### 변경 — dz-devdesign-write ⑤ 발행 단계: 사내 위키 실측 위치·양식 + draw.io 워크플로우
- 발행 위치를 **모듈별 실측**으로(루트 40207049 → 모듈 → 1.개발 테이블/API/프로세스). 법무 실측 좌표 명시(45/245468987 …). 양식(테이블 Table Columns·API 기본정보/파라미터·프로세스 draw.io)을 D-08 §부록 B로 연결.
- **워크플로우 draw.io 자동 생성**: 평문 mxGraph → `wiki_upload_attachment`(JIRA-MCP v0.5.0) → drawio 매크로. PNG 미리보기만 수동(draw.io 1회 열어 저장).
- 연계: 개발설계 표준 D-08 **v1.0.7**(부록 B) · JIRA-MCP **v0.5.0**(wiki_upload_attachment, `.jira-mcp/dist` 0.4.0→0.5.0 wheel 전파).
- 실증: LTEWI019 4종 법무 1.개발 정확 위치 라이브 발행(테이블 360612207·API 360612208·프로세스 360612209+draw.io).


## v1.6.0 (2026-06-20) — 개발설계 산출물 파이프라인 (B2 BLUEPRINT 에이전트 + B3 dz-devdesign-write 스킬)

### 추가 — 개발 표준화 스트림 2: 화면설계↔코딩 사이 '개발설계' 계층 자동화

- **B2 dz-blueprint 에이전트 신설**: 개발설계 산출물 4종(로직/워크플로우·테이블 정의서·쿼리 정의·API 정의서)을 개발설계 표준(D-08)대로 작성하는 전담 서브에이전트. A10 정합(MyBatis·APIResult·멀티테넌트 groupSeq/compSeq·`${databaseNeos}`·dbPatch). 비강제(요청 시 작성). 워크스페이스 `.claude/agents/dz-blueprint.md` + 플러그인 `skills/dz-blueprint-agent/`. 업무별 서브에이전트 14 → **15** 정합(16개 에이전트 SKILL 카운트 갱신).
- **B3 dz-devdesign-write 스킬 신설**: 입력(화면설계 D-07·요구사항·앵커) → BLUEPRINT 디스패치 → 개발설계 md(4섹션) → AEGIS 검증 → 확정 → ⑤ wiki 발행(JIRA-MCP `wiki_create_page`, B5). 비강제 opt-in.
- **dz-progress-dashboard 자동 갱신 규칙**(SKILL §9): 대시보드 HTML에 자동 새로고침 스크립트(`visibilitychange`/`focus`→`location.reload()`) 필수 내장 → `open`은 **최초 1회만**, 단계 갱신은 **파일만 수정**(탭 누적 방지, 함정 ⑦). CLAUDE.md 「진행 대시보드 운영」 표시 규칙 동기 정합.
- **연계 표준(forge GitLab 별도 동기화)**: 개발설계 산출물 작성 표준 **D-08 v1.0.6**(적대적 검토 통과·LTEWI019 앵커·B4 검수 D-11 연계·B5 wiki 도구 연계) · JIRA-MCP **v0.4.0** 쓰기 도구 6종(wiki/jira 생성·수정·코멘트, `.jira-mcp/dist/` wheel 전파).
- 근거: 개발 표준화 스트림 2 B1~B6 — 멀티에이전트 조사·종합 + 적대적 검토 + LTEWI019 라이브 위키 발행 실증(2026-06-20).

## v1.5.2 (2026-06-20) — dz-module-devenv 적용 범위 비강제(opt-in) 명문화

### 변경 — 개발환경 표준은 강제가 아니라 "신규 구성 시 지원·권고"임을 명문화

- **배경**: 대부분 개발자는 이미 본인 개발환경을 보유. 표준/스킬이 "전원 통일 강제"로 오해되지 않도록 비강제 원칙을 명문화(차민수 수석 지시, 2026-06-20).
- **SKILL.md §0**: 「적용 범위(비강제, opt-in)」 추가 — 본 스킬은 신규/추가 개발환경 세팅 용도이며, 이미 본인 환경을 갖춘 개발자의 구성을 바꾸지 않는다(표준은 지원·권고이지 강제 아님). 발동은 사용자 요청 시에만, 기존 환경 보유자에 마이그레이션 권유 금지. 스킬 version 0.3.0→0.3.1.
- **표준 연계(douzone-forge 워크스페이스)**: `개발환경-구성-표준.md` v1.4.1 — §0.2 「적용 원칙(비강제)」 신설 + §0.1 목적 문장 "처음 꾸리는 개발자 누구나"로 완화. forge 맥락 동기화·플러그인 자동업데이트는 별개(맥락·도구 전파, 개발 소스 환경 아님)임을 명시.

## v1.5.1 (2026-06-20) — dz-module-devenv 멀티모듈 프록시 자산화 + 함정 ⑩⑪ (Phase 0 마감)

### 추가 — 멀티모듈 풀스택 실증(CRM·LTE·AB)의 검증 산물을 스킬 자산으로 내장

- **배경**: CRM·법무관리(LTE)·통합연락처(AB) 멀티모듈 풀스택 로컬 실증(2026-06-17~18)에서 검증된 산물 일부가 스킬·표준에 미반영이라, 다음 사람이 같은 함정을 다시 겪을 수 있었음. 이를 자산화해 마감.
- **멀티모듈 프록시 자산 신설** → `skills/dz-module-devenv/assets/setupProxy.js`. CRA dev-server가 자동 로드. `~/devenv-poc/amaranth10-*/config`에서 context-path·port를 **자동 도출** → `/{모듈}/* → 로컬 BE` 라우트 + 공통 플랫폼 `/system/*`·`/modules/bundler/system/*` → develop. `:3000` 하나가 모든 모듈을 서빙 → **브라우저 CORS 자체가 안 생김**. 모듈 추가 시 FE 재시작만(프록시 수정 0). 블록 주석 `*/` 조기종료 SyntaxError 회피 작성(`node -c` 검증).
- **SKILL.md 보강**: §5 FE 절차에 단일↔멀티모듈 API_URL 분기(`:포트` 직결 vs `:3000` 프록시) · §5.5에 프록시 설치 단계(① FE 프록시 → ② BE 동시 F5) · **함정 ⑩ 환경별 서명키(`Sign.Value`)·Mqtt 맹복사 금지**(레포 기본 ≠ develop 값, 로그인 develop 경유 시 토큰 검증 실패) · **함정 ⑪ 브랜치↔DB 스키마 드리프트**(LTE 송무 `t_lte_incident.RESULT_TYPE_TEXT` — master 참조·develop 0 → `develop` 브랜치 기본 권고: 170 backing=develop 환경) · §10 자산/브랜치 안내 갱신. 스킬 version 0.2.0→0.3.0.
- **표준 연계(douzone-forge 워크스페이스, plugin 외부)**: `개발환경-구성-표준.md` v1.4.0 — §6.14 멀티모듈 공존(프록시 방식 B) 신설 + §9 함정 6종 확충(CORS·인증Redis base통일·경로중복·공통 프록시·환경별 서명키·브랜치-DB 드리프트). `Amaranth10/CRM/개발환경-구성.md` 모듈 가이드 신설(LTE·AB와 동형).
- 근거: CRM/LTE/AB 멀티모듈 풀스택 로컬 end-to-end 실측(`:3000` 프록시 사슬·4포트 헬스 200·로그인 화면 데이터 렌더 성공). SSoT = `규칙/프로세스/개발환경-구성-표준.md` §6.14·§9.

## v1.5.0 (2026-06-19) — forge 맥락 브리지 (VSCode Claude Code가 dev 환경에서 douzone-forge 맥락 인지)

### 추가 — 소스 코딩용 VSCode Claude Code ↔ douzone-forge 맥락 연결

- **forge 맥락 브리지**: 소스 코딩용 VSCode Claude Code(`~/devenv-poc` 등 개발 폴더)가 별도 워크스페이스 douzone-forge의 맥락(소스분석·모듈·프로젝트·조직·규칙)을 인지하도록 연결. forge에 `규칙/프로세스/forge-bridge/`(setup 스크립트 + 전체맥락 `CLAUDE.md.tmpl` + README) 신설. 스크립트가 forge 루트를 자기 위치로 자동 감지(클론 위치 무관) → 개발 폴더에 `_forge` 심링크 + `CLAUDE.md`(코딩 핵심 자동 import: 소스분석 INDEX·브랜치흐름·모듈 INDEX + forge 전 영역 지도 on-demand) 생성. Claude Code가 작업 폴더에서 부모로 walk-up 자동 로드(공식 문서 근거).
- **개발자별 가변 환경 지원**: 개발 폴더 위치·forge 클론 위치가 달라도 동작(`DEV_DIR` 인자/자동감지 + 스크립트 자기위치 감지). **이미 구성된 개발환경에 추가로 얹기 지원** — 본인 소유 CLAUDE.md 보존 시 사이드카 `_forge-bridge.md` 생성 + `@_forge-bridge.md` import 안내(`--force` 덮어쓰기). 멱등.
- **dz-module-devenv SKILL.md §8.5 신설**(선택 단계 — forge-bridge 스크립트 호출) + §10 연계. SSoT = `개발환경-구성-표준.md` §11(신설) + README 온보딩 step 5(forge 측).
- dz-* 커맨드는 플러그인 설치 시 사용. 파일 "읽고 이해"는 브리지만으로 가능. 근거: Claude Code 메모리 로딩·@import(상대/절대·4hop) 공식 문서 확인.

## v1.4.3 (2026-06-19) — dz-module-devenv 멀티모듈 동시 기동 함정 3종 템플릿 반영

### 변경 — VSCode 멀티모듈 동시 기동 함정 해법을 스킬 템플릿에 내장 (다음 모듈/다음 사람 예방)

- **배경**: 법무관리(LTE)·CRM·연락처(AB) 3 BE를 한 워크스페이스에서 동시 F5하는 과정에서 VSCode 설정 함정 3종을 실측·진단(2026-06-18). 해법을 `dz-module-devenv` 템플릿에 반영해 다음 모듈/다음 사람은 안 겪도록 함.
- **함정 ⑦ `projectName` 불일치** → `assets/be-vscode/launch.json`에서 **`projectName` 제거**. 멀티루트(여러 BE 폴더 동시 열기)에서 자바 언어서버는 프로젝트를 `{rootProject.name}-{폴더명}` 합성명으로 등록 → 폴더명·단순 gradle명을 지정하면 `ConfigError: not a valid java project`로 실패(단일 폴더만 열면 안 드러남). mainClass 유일성으로 단일·멀티 모두 해소. config `name`도 `{{MODULE}} BE …`로 통일(컴파운드 참조 예측 가능).
- **함정 ⑧ 멀티 BE JMX 포트 충돌** → `assets/be-vscode/settings.json` + 워크스페이스 settings에 **`"boot-java.live-information.automatic-connection.on": false`**. Spring Boot 확장이 라이브 데이터용 JMX 포트(10000~)를 각 앱에 주입, 동시 기동 시 `Port already in use: 10000 / BindException`으로 뒤 앱 종료. JMX 주입 차단(구동·디버그 무관)으로 해소.
- **함정 ⑨ 컴파운드 참조명 불일치** → 신규 `assets/a10-devenv.code-workspace` 템플릿(folders·BE 컴파운드·FE Run Task·JMX-off 워크스페이스 settings). 컴파운드 `configurations`가 각 BE `launch.json` config `name`과 글자까지 일치해야 동시 기동.
- **SKILL.md**: §4 launch.json 안내 보강(projectName 비움·config name 규칙) · **§5.5 멀티모듈 동시 기동 절 신설**(템플릿 사용법·3곳 동기화·Reload Window 주의) · §6 함정 카탈로그 ⑦⑧⑨ 추가 · §10 자산 목록 갱신.
- 근거: CRM+LTE+AB 멀티모듈 풀스택 로컬 실증(2026-06-18, 4포트 헬스 200·프록시 사슬·JMX 충돌 0). SSoT = `규칙/프로세스/개발환경-구성-표준.md` §9.

## v1.4.2 (2026-06-17) — 플러그인 자동 업데이트 활성 (전 직원 상시 최신화)

### 추가 — dz-personal-init §8.6: 마켓플레이스 autoUpdate 멱등 설정

- **문제**: 커스텀 마켓플레이스(douzone-forge-marketplace)는 자동 업데이트 기본 OFF → 새 플러그인 버전이 나와도 각자 수동 업데이트해야 하고, 안 하면 신규 기능(예: v1.4.1 매 턴 동기화)이 전파되지 않음(맥락 동기화와 동일한 "수동 의존" 함정).
- **해결**: `dz-personal-init`에 **§8.6 단계 추가** — 사용자 설정(`~/.claude/settings.json`)의 `extraKnownMarketplaces["douzone-forge-marketplace"].autoUpdate = true`를 멱등 기록(source 병합). 온보딩·재실행 시 자동 적용 → 이후 플러그인 신버전이 **시작 시 자동 적용**(수동 없이 전 직원 전파). §9 자가진단에 autoUpdate ON/OFF 점검 1줄 추가.
- **부트스트랩**: §8.6 자체가 v1.4.2 산출이라, 각 직원은 **딱 한 번 수동 업데이트**(`/plugin marketplace update douzone-forge-marketplace` → `/reload-plugins`) 후 dz-personal-init 재실행 → 이후 전부 자동.
- 근거: Claude Code 플러그인 업데이트 모델(커스텀 마켓플 auto-update opt-in, `extraKnownMarketplaces[].autoUpdate`로 활성) 확인.

## v1.4.1 (2026-06-17) — GitLab 동기화 상시화 (매 턴 자동 pull·push)

### 변경 — 동기화 시점을 세션 이벤트 → 매 대화 턴으로 확대

- **문제**: 동기화가 SessionStart(pull)·SessionEnd(sync)에만 묶여, 세션을 깔끔히 끝내지 않거나 중간에 막 쓰는 일반 사용자는 push가 누락돼 맥락이 GitLab에 안 올라가는 드리프트 발생.
- **해결**: `dz-gitlab-sync.sh` 호출 훅을 2개 추가 — **`UserPromptSubmit` → pull**(매 입력 전 최신 받기) · **`Stop` → sync**(매 응답 후 커밋+push). SessionStart/End는 안전망으로 유지. → **세션 종료에 의존하지 않고 매 턴 자동으로 양방향 동기화**. 커밋 메시지는 기존대로 자동(`chore(sync): … 세션 동기화`, 개발식 변경요약 없음).
- 안전: 동기화 엔진의 기존 가드 그대로 적용 — origin이 douzone-forge가 아니면 건너뜀(다른 프로젝트 세션 무영향)·git 레포 아니면 건너뜀·망 밖이면 즉시 보존·항상 exit 0. 변경 없으면 커밋 스킵. 스로틀 없음(상시 동기화 우선, 추후 필요 시 추가 가능).
- SSoT: `규칙/프로세스/Forge-GitLab-운영가이드.md` §6.

## v1.4.0 (2026-06-17) — dz-module-devenv 신설 (모듈 로컬 개발환경 세팅)

### 추가 — dz-module-devenv 스킬

- 특정 Amaranth 10 모듈의 **로컬 개발환경(백엔드+프런트)을 깨끗한 클론으로 세팅·구동·검증**하는 스킬. 입력 = 모듈명 + 그 모듈 개발자 `application.yml` 둘뿐(레포·포트·모듈코드는 규칙으로 도출).
- **BE**: `amaranth10-{모듈}` 클론 → 개발자 yml(신규 개발 서버 통일)로 `config/application.yml` 교체 + `LocalDevCorsConfig`(`Klago.localCors` 게이트, 운영 무영향) + `.vscode` → `bootRun` 헬스·CORS 실측 검증.
- **FE**: 번들러 `klago-ui-micro` + `klago-ui-{모듈}-micro` → `autoClone` + **미선언 의존 연쇄 자동 해소**(`scripts/resolve-undeclared-deps.sh`) + **node-sass→dart-sass 폴백**(`scripts/fix-node-sass.sh`, Apple Silicon) + `.env.local`(API=맨호스트·AUTH=develop) → `yarn start` 컴파일·서빙 검증.
- **함정 6종 카탈로그**: 미선언 의존 · node-sass Apple Silicon 빌드불가 · 인증 Redis는 base 설정을 따름(로그인 서버로 통일) · iCloud 컴파일 깨짐 · CORS 403(Security 부재) · 경로 접두사 중복. 로그인(비밀번호)·VSCode F5는 사람 핸드오프.
- 자산: `LocalDevCorsConfig.java`(모듈 무관) · BE `.vscode` 템플릿 · 모듈 가이드 템플릿.
- 근거: **CRM 모듈 풀스택 로컬 실증(2026-06-17 end-to-end 성공)** + 법무관리(LTE) 실증. 헬퍼 스크립트는 CRM 클론 대상 멱등 검증(버그 2건 수정).
- 단일 출처(SSoT) = `규칙/프로세스/개발환경-구성-표준.md`.

## v1.3.8 (2026-06-11) — dz-personal-init a10 등록 + 쿠키 자동시드(S3)

### 추가 — a10-mcp 전직원 등록 (dz-personal-init v0.9.0)

- **8.4 a10 등록** — 워크스페이스 `.a10-mcp/bin/a10-launch.sh` 를 양쪽 설정(`~/.claude.json`·코워크)에 멱등 등록(`A10_ENV_FILE` = `_개인/.a10-mcp/.env`).
- **8.5 a10 자격증명 — 쿠키 자동시드(S3)** — a10 인증 14키는 수동 입력 불가라, `browser_cookie3` 로 크롬 A10(gwa.douzone.com) 로그인 쿠키에서 `oAuthToken`·`signKey` 자동 추출(`.a10-mcp/scripts/seed_from_cookie.py`). **값은 스크립트가 직접 `.env` 기록(Claude 미열람)**, URL 디코딩 포함(인코딩 raw 저장 시 HTTP 500 함정 해소).
- 9단계 자가진단에 a10 MCP 등록·자격증명(시드 여부) 점검 추가.

> a10 본체(`.a10-mcp/`)·시드 스크립트는 워크스페이스(GitLab) 관할. 플러그인은 jira 와 동일하게 등록·시드 안내 로직만 담당.

## v1.3.7 (2026-06-11) — MCP 본체 워크스페이스 내장 전환 (.jira-mcp)

### 변경 — jira-mcp 배포: 플러그인 동봉 → 워크스페이스 내장

- **"Could not attach" 결함 해소**: 구 방식은 launcher 를 플러그인 캐시 **버전 폴더**(`…/1.3.4/bin/…`)로 등록 → 플러그인 업데이트 시 그 폴더가 사라져 등록이 깨졌음(재기동 시 attach 실패). 본체를 워크스페이스 `.jira-mcp/`(GitLab 클론에 포함, **경로 고정**)로 옮겨 원천 해소.
- **플러그인 `vendor`·`bin` 동봉 제거** — wheel·launcher 동봉 폐지. `build.sh` EXTRAS 에서 bin·vendor 제외.
- **dz-personal-init v0.8.0**: 8단계 등록을 워크스페이스 경로(`$WS/.jira-mcp/bin/jira-launch.sh`)로, 자격증명을 `_개인/.jira-mcp/.env`로 전환(`git rev-parse` 로 워크스페이스 루트 견고 탐지). 9단계 자가진단 `.env` 경로도 동기화.
- 실증: launcher initialize·list_presets·**ping(실제 JIRA 로그인 cjrain)** ✅. hatchling 빌드백엔드로 소스 오염(build·egg-info) 제거.

> 워크스페이스 `.jira-mcp/` 소스 + `_개인/.jira-mcp/.env` 인증은 워크스페이스(GitLab) 관할. 본 플러그인은 dz-personal-init 등록 로직만 담당한다.

## v1.3.6 (2026-06-11) — dz-personal-init 멱등 자가진단 보강

### 보강 — dz-personal-init v0.7.0 환경 자가 진단 (멱등 체크리스트)

- **8.0 런타임 점검** — `uv`(uvx) 설치 여부 점검·안내(MCP 실행 전제).
- **9단계 자가 진단 요약** — 기존 "검증 출력"을 멱등 체크리스트로 확장: 본인 R&R·git 신원·런타임·플러그인 버전·MCP 등록·자격증명·사내망 접근을 ✅/⬜ 점검(미충족만 안내). 브라우저(Chrome)·코워크 MCP 연결은 Claude 가 세션 도구로 판정. **재실행 시 된 항목은 건너뛰기** → 직원 자가 진단으로 관리자 일괄 확인 불필요.
- R&R 점검 glob → `find` 수정(zsh nomatch 회피).

> 워크스페이스 README 온보딩에 **GitLab 클론 단계(ID/PW 인증)** 추가는 별도(워크스페이스 레포).

## v1.3.5 (2026-06-11) — 동봉 MCP 배포 (jira-mcp) + dz-personal-init MCP 등록

전직원 MCP(외부 도구 연동) 배포 인프라 신설 — 플러그인 동봉 + 개인 초기화 자동 등록.

### 신규 — jira-mcp 동봉 (조회 전용 JIRA MCP)

- `vendor/jira_mcp-0.1.0-py3-none-any.whl` — Amaranth 10 JIRA(`jira.duzon.com`) 조회 MCP(Python/FastMCP, 기존 `amaranth10-jira-collector`(Java) 포팅). 도구 5종(ping·list_presets·fetch_issues·find_field·get_issue), 프리셋 8종, 모듈 라우팅.
- `bin/jira-launch.sh` — 동봉 wheel 을 `uvx` 로 자립 실행(개발 venv 무관, uvx 위치 자동탐색·미설치 안내).
- 소스: `github.com/cjrain-12505614/jira-mcp` (비공개).

### 보강 — dz-personal-init v0.7.0 (8단계 MCP 등록 신설)

- **신규 8단계** — 플러그인 동봉 jira launcher 를 `~/.claude.json`(Claude Code) + `claude_desktop_config.json`(Cowork) **양쪽에 멱등 등록**. Cowork 가 플러그인 `.mcp.json` 자동로드를 안 하는 제약을 Claude Code 세션이 양쪽 설정을 직접 써서 우회.
- `.env` 자격증명은 **bash 로 생성**(Claude file-tracking 밖) + `open -e`(편집기 열기). **Claude 는 `.env` 미열람**, jira-mcp(프로그램)만 읽음. 비개발자도 편집기 빈칸 채우기로 입력(JIRA 7.9 = PAT 불가, ID/PW).

### 빌드 — build.sh vendor·bin 포함

- `build.sh` 패키징에 `bin`·`vendor` 디렉토리 추가(존재 시) — 동봉 MCP 가 `.plugin` 에 포함되도록.

## v1.3.4 (2026-06-02) — IA 작성 표준 신설 + dz-matrix 표준 11항목 반영

### 신규 — IA 작성 표준 (`규칙/프로세스/IA-작성-표준.md` v1.0.0, 워크스페이스)

IA(정보 구조) 설계서를 누구나 같은 항목으로 작성하도록 표준을 정식화. 내부 실작성 IA(업무관리 KISS 프로젝트 관리 확장 구글 시트 2종 — 손예진 웹·유지수 모바일) ↔ 우리 IA 6구성 ↔ 외부 권위(NN/g·한국 웹기획 실무) 3자 크로스 체크로 정립:

- **표준 11항목** — 필수 7(화면 목록 SCR ID·변경유형·GNB/LNB/Tab 계층·사이트맵·네비게이션 화면 흐름·정보 그룹핑/라벨링·라이선스 분기) + 권장 4(핵심 필드 인벤토리·출처 추적·권한 주체·검토 피드백 이력).
- **범위 경계 확정(★)** — IA는 구조까지. **필드 validation·형식·글자수·알림 문구는 IA가 아니라 화면설계서(#7) 영역**(NN/g "와이어프레임·화면 명세는 IA 산출물 아님" + 한국 실무 동일). 내부 사례가 필드를 담은 것은 IA+화면정의서 통합 변형으로 판정.
- **IA 표 양식 + 작성 절차 6단계 + 품질 게이트 9 체크리스트 + 외부 표준 근거** 수록.

### 보강 — dz-matrix(MATRIX, IA 설계 전담)에 표준 11항목 반영

- **`skills/dz-matrix-agent/SKILL.md`** — 전문 영역에 IA 작성 표준 11항목 + 범위 경계 추가. AC 검증 "메뉴 계층 깊이 3 이내" → **"3단 기본·가변 Depth 확장 허용"**(내부 사례 5단 참조) + "표준 11항목 충족·필드 validation 미기재(#7 분리)·_(확인 필요)_ 표기" 추가. 관련 자산에 IA 작성 표준 링크.
- **`.claude/agents/dz-matrix.md`**(워크스페이스 자동 위임 에이전트) — "작성 표준(필수 준수)" 절 신설: 11항목·범위 경계·가변 Depth·추측 금지.

### PoC 검증 — 법무관리(LTE) IA 설계서 v1.0

- IA 작성 표준 11항목 충족(§4.1 핵심 필드 인벤토리·권한 주체·출처 흡수) + **AEGIS(정합성 검증 전담) 독립 검증 통과(Pass)** — 11/11 충족·§2.2 범위 경계 준수·9 SCR 7개 표 전부 일관·품질 게이트 9개 통과. 정밀화 권고 3건 반영.
- 근거: IA작성표준-내부사례-크로스체크 리포트(2026-06-02) + AEGIS 검증 보고.

## v1.3.3 (2026-06-02) — 대시보드 일관 규칙 + 원피스 용지 함정 + 요구사항 표준 크로스·실측

### 규칙·스킬 보강 (법무관리 요구사항 정의서 PoC 산출)

법무관리(LTE) 고객 개선 요청을 요구사항 정의서 ⓐ방법론 → ⓑ입력 → 크로스 맥락 → 스테이징 실측 → ⓒ출력으로 만든 PoC(개념 검증)에서 도출한 교훈을 정식 반영:

- **`skills/dz-progress-dashboard/SKILL.md`** §1 — **상위 대시보드 우선** 규칙 추가: 상위(프로젝트·사이클) 대시보드가 있으면 하위 작업 대시보드 생성 금지, 상위 상태 변경으로 일관 (CLAUDE.md 「진행 대시보드 운영」 절 동기). + v1.3.0 신규 폴더 git 추적 누락분 정합.
- **`skills/dz-oneffice-writer/SKILL.md`** Step 3 — **용지 크기(A4↔A3) 함정** 추가: 용지 크기는 커스텀 콤보박스(좌표 클릭 권장)이며, `.container` width만 키우고 용지를 A4로 두면 컨텐츠가 용지 밖으로 삐진다. A3 폭(973) 쓰려면 용지도 A3 전환 필수 (실측 검증: padL 76 · 꺾쇠 == container · diff 0).
- **`규칙/프로세스/요구사항-접수-분석-표준.md`**(워크스페이스) §3.5 — **크로스 맥락 파악 + 스테이징 실측** 단계 추가 (정의서 ⓒ출력 전 추측 제거, 모든 기획·설계자 공통 적용).

## v1.3.2 (2026-06-02) — 요구사항 정의서 템플릿 보강 (목적·출처·작성 원칙)

### 보강 — D-03 요구사항 정의서 템플릿 + 접수 채널

법무관리 고객 개선 요청을 정의서 → 원피스로 만드는 실습 검증을 근거로 정식 반영:

- **`templates/요구사항-정의서.md`** — §0 목적(5: 합의 기준·범위 확정·추적성·의사소통·AC 근거) + 작성 원칙 5(명확성·완전성·일관성·추적성·검증 가능성) 절 신설. §2.1 출처 구분 명시. §3.1 기능 요구 매트릭스에 **출처 열** 추가(고객사 요청 / 지시 하달 / 실무자 개선 + 채널·문서 No.).
- **`규칙/프로세스/요구사항-접수-분석-표준.md`**(워크스페이스) — 접수 채널 6 → 7. "내부 요청"을 **지시 하달**(경영진·상급자, top-down)과 **실무자 개선**(현업 제안, bottom-up)으로 분리, 출처·책임자·기록 위치 명확화.
- 근거: 요구사항 문서 명칭 검토 리포트(2026-06-02) + CIPHER 작성 샘플 정의서 실습.

---

## v1.3.1 (2026-06-02) — 진행 대시보드 표시 방식 개선 (file:// 로컬 직접)

### 개선 — 진행 대시보드 표시

- **로컬 파일 직접(`open`) 기본** — 원본 HTML을 `open "경로"`로 기본 브라우저에 file://로 바로 띄운다. 서버(8765)·표시본(`/tmp` 복사)·캐시 우회(`?v=N`) 3단계가 불필요.
- **항상 최신** — 원본을 직접 보므로 표시본 동기화 0단계. 데스크탑·앱 재시작에도 무관(서버 프로세스 의존 X).
- **서버 폴백** — Chrome 확장 화면 캡처·DOM 검증이 필요할 때만 서버 방식 유지(확장 navigate는 `file://`을 `https://`로 강제 변환해 막음 — 2026-06-02 실측).
- 갱신 범위: SKILL.md §9·§10 + CLAUDE.md 「진행 대시보드 운영」 §원칙.

---

## v1.3.0 (2026-06-01) — dz-progress-dashboard 신규: 범용 진행 대시보드

### 신규 스킬 — dz-progress-dashboard

복잡·다단계 작업의 진행을 HTML 대시보드로 **자동 생성·갱신·표시**하는 범용 스킬. 특정 프로젝트 전용이 아니라 모든 다단계 작업의 기본.

- **작업 유형 카탈로그 6종** — 분석·산출물 파이프라인·설계·개발·표준화 다영역·일괄 마이그레이션. 자비스가 선택.
- **공통 코어 5요소** — 진행바·단계목록·현재위치·다음단계·갱신시점 (작업 목록 TaskList에서 도출).
- **판단 가이드** — 신호 3개 이상(단계 3개+·다영역·장시간·산출물 다수·"복잡" 언급)이면 자비스 자동 발동 + "대시보드로 추적하겠습니다" 고지.
- **진행률 순수 칸 비율** — 완료÷전체. 손어림·가중 없음. 인프라 성과는 별도 배지.
- **마커/셀렉터 부분 치환** — 미학(frontend-design 1차 인용) 보존, 정적 영역 불가침. inline style·title은 셀렉터로.
- **표시본 동기화 + 캐시 우회** — 원본 + /tmp + ?v=N 함께.
- **개인 세션 보관** — _개인/sessions/{작업}/.

### 3중 상시 인지 (검증된 강제원칙 패턴 재사용)

CLAUDE.md 「진행 대시보드 운영」 절 명문화 + UserPromptSubmit 훅 환기(.claude/진행대시보드-환기.md, settings.json 두 번째 cat) + 본 스킬 = 강제 작업 수행 원칙과 같은 3중 패턴.

### dz-status-show와 영역 분리

dz-status-show = 전사 4축 스냅샷 / dz-progress-dashboard = 개별 작업 단계 진행.

### 설계 근거

douzone-forge `참고자료/리포트/2026-06-01-dz-progress-dashboard-스킬설계안.md` §11 범용 재정의 (사용자 결정: 작업 유형별 맞춤 · 자비스 판단 자동 · 진행률 순수 칸 비율 · 완전 자동 · 개인 세션 보관 · 3중 상시 인지).

---

## v1.2.1 (2026-05-29) — build.sh 배포 로직 보강 (로컬 자동 격상 제거 + push 단일화)

### 배경

v1.2.0 배포(`build.sh --deploy`) 중 **마켓플레이스는 1.2.0인데 설치 포인터는 1.1.1에 고착**되어 CoWork 업데이트 버튼이 안 먹는 사고 발생. 원인 진단:

1. **순서 오류** — deploy 블록이 마켓플레이스 push 보다 **먼저** 로컬 격상(`claude plugin uninstall`→`install`)을 실행. 그 시점 마켓플레이스는 아직 구버전이라 1.1.1 로 설치됨.
2. **`set -e` 조기 중단** — 격상 직후 캐시 디렉토리 검증이 `exit 1` 을 발생시켜(`set -e`) 스크립트가 중단 → 뒤따르는 마켓플레이스 push 블록 미도달.
3. 결과: 마켓플레이스만 신버전, 설치 포인터 구버전 고착 + 이후 `install` 멱등("already installed")으로 격상 불가.

### 변경 — `build.sh` deploy 블록 재설계

- **로컬 자동 격상 제거** — `claude plugin marketplace update`/`uninstall`/`install` + 캐시 검증 블록(약 50줄) 전부 삭제. 배포는 **릴리즈(마켓플레이스 push)까지만**.
- **push 단일화** — `MARKETPLACE_DIR` == `PUBLIC_MARKETPLACE_DIR` 동일 경로 중복 전개 제거. 버전 디렉토리 전개 + marketplace.json 갱신 + commit + push 를 한 경로로 통합, deploy 의 마지막 단계로 배치.
- **push 실패 시 즉시 중단** — `git push` 실패 시 `exit 1`(기존 `|| echo` 무력화 패턴 제거).
- **수동 업데이트 안내 출력** — 배포 후 ① CoWork 앱 업데이트 버튼 ② CLI 멱등 우회 명령(`uninstall && marketplace update && install`) 두 경로 안내.

### 정책 변경

- **로컬 플러그인 업데이트는 사용자 수동** (자동 격상 안 함). 배포 = 원격 릴리즈, 적용 = 사용자 선택 시점.

### 검증

- `bash -n build.sh` 문법 통과 · deploy 블록 자동 격상 실행 라인 0건.

### 부가 — 플러그인 설명(description) 소개형 정리

- `plugin.json`(2,673자 누적 변천사)·`marketplace.json`(157자 기능 나열)의 description 불일치 → **소개형 1문단(227자)으로 통일**. 디렉토리에 두 카드처럼 보이던 표시 해소.
- **정체성 재정의** — 특정 영역(기획·설계)·제품(Amaranth 10)에 국한되지 않는, 전 업무(기획·설계·디자인·퍼블리싱·개발·구축·영업 등) **맥락 기반 통합 업무 프레임워크**. Amaranth 10 은 활용 도구(원피스 문서 생성·분석·업무보고 등).
- 기존 description 의 버전 변천사는 본 CHANGELOG 가 정본(description 에서 이관, 손실 없음).
- 버전 무변경(1.2.1) — 기능 변화 없는 메타 정리. 디렉토리 표시는 marketplace.json 기준이라 push 로 반영.

---

## v1.2.0 (2026-05-29) — dz-deck-builder 신규 (편집 가능 PPTX 발표자료 생성)

### 배경

업무관리(KISS) 모듈 프로젝트 관리 기능 고도화 대상 시장조사 사이클(2026-05-28~29)에서 분석형 산출물을 처음 조사 → 심층 조사 → 마크다운 → HTML → 원피스 → **PPTX** 6 단계 전 과정으로 완성. PPTX 생성 중 pptxgenjs 함정 다수(불릿 `[object Object]` 깨짐·배경 의사요소 높이 초과·다크 저대비)를 겪고 해결. 이 노하우를 다른 임직원·세션이 재현하도록 스킬화. 워크스페이스 SSoT 4종(발표자료-PPTX-작성-표준·산출물-스타일-표준·분석형-산출물-파이프라인·디자인도구-MCP-운영가이드) + 규칙/폰트/_README 신설 동반.

### 변경 — `skills/dz-deck-builder/` 신규 (Skills 54 → 55)

- **SKILL.md 신설** — HTML 발표자료 또는 본문 구조를 편집 가능 PowerPoint(.pptx)로 생성. 배경 광선·그라데이션 칩만 이미지, 텍스트·표·카드·도형은 PowerPoint 네이티브(편집 가능).
- **함정 C1~C7 회피 내장** — ① 배경 의사요소 슬라이드 범위 가두기 ② 불릿 run 단위 펼치기(첫 run bullet·끝 run breakLine, `[object Object]` 방지) ③ 다크 저대비 방지(#C2C8D6 이상) ④ 그라데이션 이미지화·나머지 네이티브 ⑤ 좌표 변환 px/96=inch·pt=px*0.75 ⑥ 옵션 객체 매번 새로 생성 ⑦ 시각 QA 서브에이전트 2회+.
- **더존 EQT 다크 스타일 기본값** — 미드나잇 네이비 #0C0E1A + 블루 #5B7CFF·퍼플 #A78BFA 그라데이션 광선. 사용자 지정 스타일 우선.
- **더존 폰트 매칭** — `'DOUZONE Title'`·`'DOUZONE Text'` 정확 매칭 + 미설치 안내.
- **검증된 templates 동봉** — `build.js`(KISS 시장조사 13장 빌드 정본, 함정 회피 적용)·`gen_bg.py`(배경 3종 PIL+numpy 생성).

### 검증

- 본 스킬 templates/build.js 는 실제 13장 PPTX 생성 + 시각 QA 서브에이전트 2회 통과 산물(불릿 깨짐·저대비 수정 완료, 잔류 오류 0건).
- 워크스페이스 동기화 커밋 `613576e` 에 표준 문서 5건·산출물·더존 폰트 포함 완료.

### 후속

- 다음 "PPTX 만들어줘"·"발표자료 파워포인트로" 요청 시 본 스킬 자동 적용.
- 스타일·절차는 워크스페이스 SSoT(`규칙/프로세스/발표자료-PPTX-작성-표준.md` 등)가 정본, 본 스킬은 실행 절차.

---

## v1.1.1 (2026-05-27) — dz-oneffice-writer v0.4.0 보강 (모드 C 평면 주입 + blur 패턴)

### 배경

v1.1.0 release(`307544b`) 직후 진행된 자비스 보고용 회의록 사이클(2026-05-27 AWS-더존 미팅) 에서 dz-oneffice-writer v0.3.0 표준 절차(모드 B 컨테이너 보존)로 ONEFFICE 문서에 보고용 HTML 주입 결과, 편집 화면은 정상이나 **인쇄·PDF 변환·줌 변경 시 사이즈가 깨지는 사이즈 문제** 발견. 두 문서(자비스 모드 B vs 사용자가 ONEFFICE 안에서 직접 복사·붙여넣기로 만든 평면 패턴) 정밀 비교 진단 → 모드 C 평면 주입 신설 + Step 9 blur 패턴 보강.

### 변경 — `skills/dz-oneffice-writer/SKILL.md` v0.3.0 → v0.4.0

- **모드 C 평면 주입 신설** (Step 6, 모드 A 다음 배치) — `<style>` 태그·`.container` 래퍼·`width` 픽셀 고정·`!important`·`@media print` 전부 제거하고 본문 요소(H1·TABLE·OL·DL 등)를 `main` 직계 자식으로 평탄화. 사용자가 ONEFFICE 안에서 직접 복사·붙여넣기로 만든 문서 패턴과 동일. 인쇄·PDF·줌 정상.
- **모드 B vs 모드 C 검증 차이 표 신설** — `main.children.length`·style 태그·container·width·!important·@media print·인쇄 결과 비교.
- **Step 7 헤더 보강** — "(모드 B 한정, 모드 C 는 생략)" 명시. width 픽셀 고정 자체가 사이즈 문제의 원인이라 모드 C 는 정렬 단계 생략.
- **Step 9 blur 패턴 보강** — native setter + Enter keydown 만으로는 ONEFFICE React 내부 상태에 commit 되지 않아 저장 시 문서명 원복 패턴 발견. `inp.blur()` 호출 + `blur` 이벤트 명시 dispatch + keypress·keyup 추가 dispatch + `defaultView.HTMLInputElement.prototype` 사용으로 commit 트리거.
- **검증된 상수 요약 보강** — 주입 모드 B/C 행 추가, 모드별 스타일 위치 명시 (모드 B = main.innerHTML 내부 `<style>` / 모드 C = 인라인 `style` 속성만).
- **🎯 기본 워크플로우 보강** — 주입 모드 선택 가이드 표 추가 (인쇄·PDF·외부 공유 = **모드 C 기본** / 편집 화면 미관 한정 = 모드 B).
- **디버깅 체크리스트 보강** — "저장 후 인쇄·PDF·줌 변경 시 사이즈 깨짐" 신규 항목 + "제목이 저장 후 원복" 항목에 blur 누락 사유 추가.

### v1.1.0 release 후 git 정합

- v1.1.0 release zip 에는 포함되었으나 git 에 add 되지 않은 파일 정합:
  - `commands/dz-form-write.md` (v1.1.0 신규 커맨드)
  - `skills/dz-oneffice-form-writer/` (v1.1.0 신규 스킬 디렉토리)

### 검증

- SKILL.md 본문 grep 검증 7건 통과 (version·v0.4.0 변천사·모드 C·blur·사이즈 문제·주입 모드 행).
- 본문 줄 수 718 → 862 (144 줄 증가 = 모드 C 본문 + Step 9 blur 보강 + 디버깅 항목).
- 본 보강 사이클 task 추적 — 자비스 회의록 사이클 #11 (`dz-oneffice-writer 스킬 v0.4.0 보강`).

### 후속

- 다음 원피스 작성 요청 시 새 SKILL.md 자동 적용 — 사이즈 문제·제목 원복 두 패턴 자동 회피.
- 본 패턴 학습 사이클은 v0.4.0 SKILL.md 본문 v0.4.0 변천사 노트(L20)·디버깅 체크리스트(L826~)에 영구 보존.

---

## v1.1.0 (2026-05-27) — dz-oneffice-form-writer 스킬 신설 (rc 단계 종료 + 정식 minor 진입)

### 배경

2026-05-26 PoC 결과 — 원피스 표준 양식 5종 셀 단위 데이터 주입 흐름이 SSoT(`규칙/프로세스/원피스-작성방식-선택-자동화-표준.md`)로 정착 완료 (1,599행). 단 실행 도구(스킬)가 부재해 매번 자비스가 §6 SCHEMA 코드를 수동 실행 중. 전 임직원 적용을 위해 스킬 자산화 진행. 본 신규 스킬은 의미 있는 기능 추가이므로 rc 단계를 종료하고 정식 minor 단계 `1.1.0`으로 진입 (사용자 결정, 2026-05-27).

### 변경

- 신규 스킬 `dz-oneffice-form-writer` 신설 — 원피스 양식 5종(일일보고 Unit장/Cell리더/멤버 + 프로젝트 상세 신규개발/유지보수 + 주간보고 SBUnit)에 양식 정합(폰트·블릿·아마링크) 데이터 주입.
- SSoT 인용 — §5(양식 매핑) · §6(SCHEMA + 헬퍼 함수 7종) · §7(표별 운영 룰 14개 영역 — 일일보고 6 + 프로젝트 상세 8) · §9(한계 + 해법 후보 4종) 전 영역.
- 헬퍼 함수 7종 — `wrapTextCell` · `wrapBulletCell` · `wrapHierarchyBulletCell` · `wrapAmaLinkCell` · `injectRow` · `addRow` · `setStatus`.
- 자동 선택 매트릭스 — 방식 2 적용 영역에서 본 스킬 자동 호출. 방식 1(HTML 강제 주입)은 기존 `dz-oneffice-writer` 영역 유지.
- 신규 커맨드 `/dz-form-write` 신설 — 본 스킬 호출 단축.

### 검증

- AC-1 ~ AC-11 통과 (지시서 `_개인/지시서/2026-05-27-Claude코드지시서-dz-oneffice-form-writer.md` §4 검증 기준).
- `bash build.sh --deploy` 종료 코드 0 + 마켓플레이스 캐시 신버전 진입 (`~/.claude/plugins/cache/douzone-forge-marketplace/douzone-forge/1.1.0/`).
- 새 세션 시작 시 자비스가 `dz-oneffice-form-writer` 진입 신호 인식 검증.

### 후속 사이클

- §9 한계 #3 해법 4종 검증 (dirty 표식 강제·키 입력 흉내·이벤트 발생·`save()` API 직접 호출) — 자동 저장 흐름 완비 목표.
- 양식 4종 실측 PoC (Cell리더·멤버·프로젝트상세·주간보고 SBUnit 각 1회 시범 주입).
- 다른 Unit 주간보고 양식 변종 등재 (UCUnit·DOC Unit·ONE AI Unit 등).
- 본 스킬 호출 진입 신호 정밀화 (모호한 입력에서 양식 자동 판별).

## v1.0.0-rc.23 (2026-05-26) — 경로 비종속 운영 정합 (commands·skills·build.sh)

### 배경
워크스페이스 cascade로 신설된 `규칙/프로세스/경로-비종속-운영-표준.md`(자동 발견 4 패턴 + 금지 + grep 자가 점검)와 정합. 플러그인 자산이 차민수 환경 절대경로(`~/Workspace/_plugin/douzone-forge/...`)·옛 폴더명(`_CLAUDE/`)을 가정해, 다른 임직원이 임의 폴더에 클론·설치할 때 헷갈리는 문서가 잔존하던 문제 해소. iCloud → 로컬 이전 직후 진행한 사이클의 일부.

### 변경
- `build.sh`: `PUBLIC_MARKETPLACE_DIR` 환경변수 fallback (`${DOUZONE_FORGE_MARKETPLACE_DIR:-$HOME/Workspace/_plugin/douzone-forge-marketplace}`) — 이관 시 env 한 줄로 위치 변경 가능. 차민수 단독 운영 백워드 호환 유지.
- `commands/` 4건 — dz-jira·dz-personal-init·dz-git-daily·dz-plugin-save 변수 표기 + 예시 부기.
- `skills/` 6건 — dz-jira-query·dz-git-daily·dz-people-index·dz-agent-dispatch·dz-residual-audit·dz-launch-agent 변수 표기. dz-people-index는 옛 `_CLAUDE/` → `규칙/` 정정 동반. dz-residual-audit Python 스크립트는 `$CLAUDE_PROJECT_DIR` 환경변수 우선(`os.environ.get` fallback 패턴).

### 검증
- 플러그인 안 `/Users/chaminsu` 박힌 위치 0건 (CHANGELOG 변천사 예외).
- build.sh env fallback: env 미설정 시 차민수 기본값(`/Users/chaminsu/Workspace/_plugin/douzone-forge-marketplace`) / 설정 시 새 위치(`/tmp/test-marketplace`) — 양쪽 동작 검증.
- 워크스페이스 `규칙/프로세스/경로-비종속-운영-표준.md` 신설본(commit `9ae5d86`)과 일관.

## v1.0.0-rc.21 (2026-05-26) — 동기화 엔진 차단 파일 격리·부분 커밋·사용자 안내

### 배경
rc.20 까지는 비밀스캔이 한 파일이라도 차단하면 전체 sync(커밋·push)가 중단되고, 사용자에게 무엇이·왜 막혔는지·어떻게 처리할지 안내가 없었다. 한 번의 오탐 또는 진탐으로 누적 본업 변경 전체가 보류되는 운영 결함을 해소.

### 변경
- `hooks/dz-gitlab-sync.sh` `commit_local()` 재설계:
  1. `git add -A` 후 `.githooks/pre-commit` 을 사전 호출해 staged 파일 비밀 스캔.
  2. 차단된 파일은 `git restore --staged` 로 격리 (working tree 파일은 그대로 보존).
  3. 사용자 화면에 한국어로 안내 — 차단 파일 목록 + 오탐/진탐별 처리 방안(.gitignore 또는 *.example, 트리 밖 이동) + 정책 SSoT 경로.
  4. `_개인/sync-log.md` 에 격리 이력 영구 기록 (개별 파일명 포함).
  5. 남은 staged 가 있으면 정상 커밋·pull·push, 0이면 중단(로컬 보존).
- 결과: 차단 1건이 정상 N건의 sync 를 막지 않는다. 사용자는 매 sync 마다 격리 안내를 받아 인지·결정 가능.

### 검증
- 시나리오 A (비밀 1 + 정상 2 → 비밀만 격리, 정상 2 push)
- 시나리오 B (비밀 + 비밀 아닌 삭제 → 비밀 격리, 삭제 push)
- 시나리오 C (비밀 없음 → 평소대로 통과)
- 시나리오 D (dry-run → 사전 스캔 생략, 시늉만)
- sync-log 격리 이력 정상 누적 확인.

## v1.0.0-rc.20 (2026-05-26) — 비밀스캔 정규식 보정 (AKIA case-sensitive)

### 배경
워크스페이스 `.githooks/pre-commit`의 AWS Access Key ID 패턴 `AKIA[0-9A-Z]{16}`이 case-insensitive(`-Ei`)로 매칭돼, HTML 보고서 내 base64 인코딩 데이터에서 우연 매칭(예: `AkIA...`)으로 오탐 차단 발생. 실제 AWS 키는 항상 대문자 `AKIA` 시작이므로 case-sensitive 검사가 정합.

### 변경
- `.githooks/pre-commit` (워크스페이스 자산): 패턴 분리 — 키워드 비밀(`refresh_token`·`client_secret`·`private_key`·PEM)은 case-insensitive 유지, AWS Access Key(`AKIA[0-9A-Z]{16}`)는 case-sensitive로 분리. base64 데이터 오탐 차단.
- `plugin.json`·`CHANGELOG.md`·`CLAUDE.md`: rc.20 정합 표기 (플러그인 자체 자산 변경은 없음, 버전 표기는 워크스페이스 보정과 정합).

### 검증
- 진짜 AWS 키 형식(`AKIAIOSFODNN7EXAMPLE` 등) 매칭 유지 / base64 우연 시퀀스(`AkIAYpjPeZ8HWz8FUM6g`) 비매칭 확인.

## v1.0.0-rc.19 (2026-05-26) — 동기화 엔진 http origin 지원 + GitLab 주소 정합

### 배경
워크스페이스 GitLab 주소를 임직원 현행 표준인 구주소(http://14.41.55.45:8089)로 통일. rc.18 엔진의 도달성 선점검이 origin 프로토콜과 무관하게 항상 `https`로 시도해, http origin에서 SSL 핸드셰이크 실패로 매번 "오프라인" 오판하던 버그 수정.

### 변경
- `hooks/dz-gitlab-sync.sh` `remote_reachable()`: origin 프로토콜(http/https)에 맞춰 curl 점검. http origin은 http로 점검(SSL 시도 없음).
- `CLAUDE.md` GitLab 베이스 표기: 임직원 현행 사용 = `http://14.41.55.45:8089`. 신주소 `sbfigma.amaranth10.co.kr`은 도달 이슈로 표기 정합.

### 검증
- 샌드박스: http origin + https origin 양쪽 회귀, 가드·dry-run·오프라인 빠른 보존 통과.

## v1.0.0-rc.18 (2026-05-26) — 동기화 연결 타임아웃 + 플러그인 설치 능동 안내

### 변경
- `hooks/dz-gitlab-sync.sh`: 원격 도달성 선점검 추가 — 망 밖이면 짧은 연결 점검(기본 5초, `DZ_SYNC_CONNECT_TIMEOUT`)으로 빠르게 판정해 git 네트워크 명령을 건너뛰고 즉시 보존. 세션 시작이 75초씩 멈추던 문제 해소. git 명령에 `http.lowSpeedTime`(기본 15초, `DZ_SYNC_GIT_TIMEOUT`) 보조 타임아웃 추가.
- `CLAUDE.md`: "플러그인 설치 확인" 섹션 신설 — 플러그인 없이 git만 클론한 경우 Claude가 `dz-*` 부재를 근거로 사용자에게 설치를 능동 안내. (`.claude/`가 git 제외라 hook 자동 안내 불가 → CLAUDE.md 기반)

### 검증
- 오프라인 sync/pull 5초 내 보존, 온라인 회귀·가드(origin 불일치)·dry-run 통과.

## v1.0.0-rc.17 (2026-05-26) — 세션 GitLab 동기화 엔진 (자동 최신화)

### 배경
비개발자를 포함한 전 사용자가 작업 후 자동 커밋 누락·GitLab 변경 미수신으로 로컬과 중앙 저장소가 어긋나는 문제를 방지. 세션 시작/종료 시점에 동기화를 자동화한다.

### 변경
- `hooks/dz-gitlab-sync.sh` 신설: 안전 동기화 엔진 (pull/sync 모드). 자동 커밋 → pull(rebase+autostash) → push. 충돌 시 자동 병합하지 않고 `backup/sync-시각` 브랜치에 보관 + 관리자 문의 안내(데이터 보존). origin이 douzone-forge가 아니면 무동작(가드). 항상 exit 0(세션 비차단).
- `.claude-plugin/plugin.json`: `SessionStart`(pull)·`SessionEnd`(sync) hook 등록.
- `commands/dz-end-session.md`·`dz-save-session.md`: 동기화 호출 + 결과 보고 단계 추가.
- `commands/dz-personal-init.md` v0.5.0: §7에 `pull.rebase`·`rebase.autoStash`·`credential.helper` 기본값 설정 추가.

### 정책
- 전 사용자 적용 (douzone-forge는 소스 코드 공간이 아닌 맥락 공간 — 공용 맥락 전원 동기화). 개인 영역 `_개인/`은 `.gitignore`로 동기화 제외.
- SSoT: `규칙/프로세스/Forge-GitLab-운영가이드.md` §6 (워크스페이스 레포).

### 검증
- 9개 시나리오 통과: 가드(git 아님·origin 불일치), 정상(변경없음·있음), dry-run, 다중사용자 pull, 충돌(백업+멈춤), 원격끊김(보존).

## v1.0.0-rc.16 (2026-05-22) — dz-personal-init 온보딩 자동화 (git 신원 + 비밀 스캔 훅)

### 배경
워크스페이스 GitLab 배포 후 신규 사용자 온보딩 단순화 — 플러그인 설치 후 `dz-personal-init` 한 번으로 신원·비밀훅·개인영역 정착.

### 변경
- `commands/dz-personal-init.md` v0.4.1 → v0.5.0: §7 신설 — §5.1 lookup(이름·Amaranth 10 ID·본부) 기반 git `user.name`(본부→`[UC]`/`[ERP]`+이름)·`user.email`(`{Amaranth10ID}@douzone.com`, **사번 아님**)·`core.hooksPath .githooks`(비밀 스캔 훅)·`core.precomposeunicode` 자동 설정.

### 비고
- 플러그인 설치 자체는 dz-personal-init이 수행 불가(닭-달걀) → 온보딩 문서 선행 단계 유지. 본 변경은 설치 *이후* 단계 자동화. 이메일/ID 표기는 Amaranth 10 ID(xlsx 13번 사원명) 기준 — 사번 아님.

## v1.0.0-rc.15 (2026-05-22) — 워크스페이스 배포 정합 연계 (folder hook + 폴더 표준 정본화)

### 배경
douzone-forge 워크스페이스의 GitLab 배포 전 정합(Phase A 보안 게이트 + Phase B 정합성)과 연계. 폴더 표준 실측 정본화에 맞춰 hook 허용목록을 정합.

### 변경
- `hooks/folder-structure-check.sh`: 루트 허용목록 정본화 — `AI` 제거, `_분석요청문서`·`_운영` 추가 (공용 7 + `_` 영역 3). 안내문 동기화.
- (워크스페이스 측) 폴더 표준에서 `AI/`·`meta/` 제거, `GitCheck/` 정본 반영.

### 비고
- rc.10~14는 리브랜딩(amaranth10-claude-forge→douzone-forge, a10-→dz-) 전후 누적 빌드. 상세 CHANGELOG 미기록분 포함하며 rc.15부터 douzone-forge 단일 표기로 정합.

## v1.0.0-rc.9 (2026-05-13) — S-06 규칙 폴더 운영 권한 표준 정착 (W-1 잔여 네 번째, v3)

### 배경

PRJ-2026-014 W-1 사이클 잔여 네 번째 항목 — Q110 A 채택. 운영 주체 2 분리 (Forge 사용자 vs Forge 관리자) 표준 정착 + Enterprise 정책 활용 매트릭스 + 강제 메커니즘 3 본문 (Enterprise + hook + 자가 점검). **v3 본질 정정**: Forge 배포 모델 = Claude Enterprise 단독 (GitLab 미적용). 다른 SSoT GitLab 본문 정합화는 별도 사이클 인계.

### 신설/갱신 자산 (9건)

- **`규칙/프로세스/규칙폴더-운영권한-표준.md`** (~360줄) — SSoT 신설 (11번째 누적 신설본)
  - frontmatter + 메타블록 + 8 절 (본 SSoT 범위 · 운영 주체 2 분리 · 자산 영역 매트릭스 15건 · Enterprise 정책 활용 3건 · 강제 메커니즘 3 본문 · 자가 점검 절차 · 기존 자산 cross-ref · 변천사)
  - §3.1 plugin.json 등록 vs 디렉토리 차이 영역 인지 본문 (보강 1 적용)
  - §8.1 후속 인계 4건 (Enterprise Plugin 실 설정 · Cowork Projects 권한 실 설정 · 다른 SSoT GitLab 본문 정합화 · plugin.json 등록 미진 4건)
- **`_plugin/douzone-forge/hooks/rules-protection-check.sh`** (~90줄) — PostToolUse Write|Edit hook
  - prj-code-naming + answer-tone + folder-structure 패턴 일관 (stdin JSON + jq + case)
  - 관리자 영역 9 패턴 검출 (워크스페이스 SSoT · 플러그인 자산 5종 · CLAUDE.md · 모듈 메타 · 작업항목 INDEX)
  - WARNING 만 + 협업 표준 §3 6 단계 흐름 cross-ref 안내
- **자비스 운영 룰 §2 학습 #26 신설** — 규칙 폴더 운영 권한 자가 점검
  - §2 헤더 갱신: `#1~#25` → `#1~#26`
- `_plugin/douzone-forge/.claude-plugin/plugin.json` PostToolUse 매트릭스 — `rules-protection-check.sh` 등록 (folder-structure-check 다음·link-integrity-check 직전, **자비스 의제 ❺ B 채택** — folder-* + protection-* 그룹 일관 분리)
- `_plugin/CLAUDE.md` 파일 끝 새 섹션 `## 관련 워크스페이스 SSoT (rc.9 신설)` — 본 SSoT + 협업 표준 + 답변 톤 + 폴더 구조 4건 cross-ref
- `douzone-forge/CLAUDE.md` "폴더 구조 규칙" 영역 cross-ref — 본 SSoT 한 줄 (rc.7 cross-ref 본문 다음)
- **작업항목 INDEX 명명 갱신** (3 위치 L73·L132·L150) — "규칙·템플릿 보호 메커니즘" → "규칙 폴더 운영 권한 표준" (Pre-fix 4 정정, 보강 4 광역 grep 정찰 결과 기반)

### 카운트 변화

| 자산 | 직전 (rc.8) | 본 패치 후 (rc.9) |
|------|-----------|---------------|
| Skills | 54 | 54 (변동 없음) |
| commands | 46 | 46 |
| **hooks** | **16** | **17** (+1 rules-protection-check.sh) |
| rules | 12 | 12 |
| **SSoT (규칙/프로세스/ 신설본 누적)** | **10** | **11** (+1 규칙폴더-운영권한-표준.md) |

→ plugin.json 등록 hooks 12 → 13 (PreToolUse 2 + PostToolUse 11). 등록 미진 4건 잔존 (별도 정합화 사이클 인계).

### 자비스 ⑥ 결재 반영 (의제 7건 + 보강 5건)

| 의제 | 결재 | 적용 |
|------|------|------|
| ❶ hook 본문 패턴 | **A** | prj-code-naming + answer-tone + folder-structure 패턴 일관 |
| ❷ 학습 #26 본문 분량 | **A** | 짧게 — 학습 #20~#25 패턴 일관 |
| ❸ SSoT 본문 분량 | **A** | 작업지시서 §2 그대로 + frontmatter + 메타블록 + 변천사 |
| ❹ rc.9 description 카운트 | **A** | hooks 16 → 17 + SSoT 10 → 11 (실측 선행) |
| ❺ hook PostToolUse 위치 | **B** | folder-structure-check 다음·link-integrity-check 직전 (관리자 영역 보호 hook 그룹 시작 본문, 향후 확장 영역) |
| ❻ _plugin/CLAUDE.md cross-ref 위치 | **A** | 파일 끝 새 섹션 (4 SSoT cross-ref 통합) |
| ❼ 다른 SSoT GitLab 본문 정합화 별도 사이클 | 수용 | §8.1 후속 인계 명시 |
| 보강 1 SSoT §3 등록 vs 디렉토리 차이 영역 | 적용 | §3.1 본문 명시 (디렉토리 17 vs 등록 13, 미진 4건) |
| 보강 2 plugin.json 카운트 실측 선행 | 적용 | `ls hooks/*.sh \| wc -l` = 16 (rc.8) → 17 (본 신설) + skills 실측 54 (작업지시서 §2.2 "53건" 정정) |
| 보강 3 의제 ❺ B 위치 본질 | 적용 | 관리자 영역 보호 hook 그룹 시작 본문, 향후 확장 영역 |
| 보강 4 Pre-fix 4 광역 grep 정찰 | 적용 | 작업항목 INDEX 3 위치 명명 갱신 (replace_all=true) |
| 보강 5 라운드 1 6 도구 병렬 Write | 적용 | rc.6~rc.8 패턴 일관 |

### AC 검증 결과 (5/5 PASS)

| AC | 검증 | 결과 |
|----|------|------|
| AC-1 | SSoT 신설 `^## ` 헤더 ≥ 6 + §3 매트릭스 15 영역 | ✅ 8 절 + 15 영역 (작업지시서 14 + INDEX 추가 1) |
| AC-2 | hook 신설 + 실행 권한 + plugin.json 등록 + bash -n | ✅ `[[ -x ]]` + Exit 0 + PostToolUse 2 매칭 |
| AC-3 | 자비스 운영 룰 §2 학습 #26 + 헤더 갱신 | ✅ L22 `#1~#26` + 학습 #26 본문 |
| AC-4 | 기존 자산 cross-ref (CLAUDE.md 2건) | ✅ _plugin/CLAUDE.md 파일 끝 새 섹션 + douzone-forge/CLAUDE.md 한 줄 |
| AC-5 | 플러그인 빌드·배포 (v1.0.0-rc.9) | ✅ build.sh --deploy + GitHub push + 캐시 v1.0.0-rc.9 본문 |

### Pre-fix 자가 정정 (정찰 단계 4건 + 관찰 1건)

| # | 단계 | 본문 | 자가 정정 |
|---|------|------|---------|
| 1 | ② 정찰 | plugin.json 등록 vs 디렉토리 차이 4건 (rc.7 인계) | 보강 1 적용 — SSoT §3.1 본문 명시 + §8.1 후속 인계 |
| 2 | ② 정찰 | SSoT §3 매트릭스 14 영역 실측 — 작업지시서 §2.2 skills "53" → 실측 54 | 보강 2 적용 — 본 SSoT §3 본문 정합 (skills 54) |
| 3 | ② 정찰 | _plugin/CLAUDE.md cross-ref 위치 의제 ❻ A 채택 | 파일 끝 새 섹션 `## 관련 워크스페이스 SSoT (rc.9 신설)` 신설 |
| 4 | ② 정찰 | 인덱스 §4.2 S-06 행 명명 갱신 — 광역 grep 정찰 시 3 위치 잔존 | 보강 4 적용 — 작업항목 INDEX 3 위치 replace_all=true 갱신 |
| 관찰 | ② 정찰 | hook case 매칭 — `*/규칙/프로세스/*.md` 패턴 sub-디렉토리 검출 가능 | 정합 범위 본 SSoT §3 매트릭스 본문 명시 |

→ Pre-fix 4건 + 관찰 1건. 실행 단계 ⑤ 추가 Pre-fix 0건.

### R8 실측

- ② 플랜모드 (정찰 + 계획서) — ~12분
- ⑤ 실행 (9 자산 + AC 검증 + 결과서) — 추정 ~55분 (rc.6~rc.8 패턴 일관)
- 누적 R8 추정 ~67분 (자비스 ③ 시간 제외)

### 다음 사이클

- W-1 사이클 잔여 3 항목 (D-13 · G-02 · G-03) — 마감 2026-05-19
- Enterprise 실 설정 (Plugin Marketplace `Required` · Cowork Projects 권한 · Custom Roles) — Beta 진입 사이클
- **다른 SSoT GitLab 본문 정합화** — 별도 사이클 (v3 신규 인계)
- plugin.json hooks 매트릭스 등록 미진 4건 — 별도 정합화 사이클

---

## v1.0.0-rc.8 (2026-05-13) — S-05 코워크 ↔ 클로드 코드 협업 표준 보강 (W-1 잔여 세 번째)

### 배경

PRJ-2026-014 W-1 사이클 잔여 세 번째 항목 — Q109 A 채택. 자기 참조 사이클 본질 — 본 SSoT (코워크-클로드코드-협업-표준.md) v1.x 자체 보강 + 4 사이클 학습 누적 흡수 (S-09·rc.4·rc.5·C-01·S-01). 미러 스킬 실 신설은 별도 정찰 사이클 인계 (식별만 본 사이클).

### 신설/갱신 자산 (7건)

- **SSoT v1.x 보강** — `규칙/프로세스/코워크-클로드코드-협업-표준.md` (5 영역 신설, ~130줄 추가)
  - **§3.4 사이클별 R8 매트릭스 신설** — 5 사이클 누적 R8 -28% 효율 검증 본문
  - **§5.3 미러 스킬 신설 절차 신설** — 5 단계 절차 박음
  - **§6 사례 인덱스 확장** — 사례 #3·#4·#5 추가 (S-09·C-01·S-01)
  - **§10 검증된 사실 매트릭스 신설** — 5 사이클 누적 20건 본문
  - **§11 학습 누적 신설** — 자비스 운영 룰 §2 학습 #20~#25 cross-ref 매트릭스
- **자비스 운영 룰 §2 학습 #25 신설** — 결재 단계 C 옵션 신설 패턴 (S-01 의제 ❺ 학습 흡수)
  - §2 헤더 갱신: `#1~#24` → `#1~#25`
- **미러 스킬 후보 식별 산출물 신설** — `프로젝트/PRJ-2026-014_*/05_산출물/20260513-미러스킬-후보식별.md` (~80줄, 4 절)
  - 현 매트릭스 (dz-frontend-design 1건) + 후보 의제 + 신설 절차 + 변천사

### 카운트 변화 (변동 없음 — 보강 사이클 본질)

| 자산 | 직전 (rc.7) | 본 패치 후 (rc.8) |
|------|-----------|---------------|
| Skills | 54 | 54 (변동 없음) |
| commands | 46 | 46 |
| hooks | 16 | 16 |
| rules | 12 | 12 |
| SSoT (규칙/프로세스/ 신설본 누적) | 10 | 10 (보강만, 신규 신설 0) |

→ 본 사이클 신설 자산 0건 (보강 사이클 본질). description 끝 본문만 갱신.

### 자비스 ⑥ 결재 반영 (의제 5건 + 보강 4건)

| 의제 | 결재 | 적용 |
|------|------|------|
| ❶ SSoT §3.4·§5.3·§6·§10·§11 신설 본문 분량 | **A** | 작업지시서 §2 그대로 |
| ❷ 학습 #25 본문 분량 | **A** | 짧게 — 학습 #20~#24 패턴 일관 |
| ❸ 미러 스킬 후보 식별 산출물 분량 | **A** | 작업지시서 §2.7 그대로 (간단 본문 + 변천사) |
| ❹ rc.8 description 카운트 | **A** | 변동 없음 + 끝 본문 추가 |
| ❺ §6 사례 인덱스 — 5 사이클 vs 작업지시서 3건만 | **A** | 작업지시서 §2.3 명시 3건만 (S-09·C-01·S-01) |
| 보강 1 라운드 단순화 | 적용 | 라운드 1 (병렬 4 도구) + 라운드 2 (한 메시지 6 Edit, 동일 파일 시스템 순차) + 라운드 3 (검증) + 라운드 4 (결과서) |
| 보강 2 SSoT 5 Edit old_string 유니크화 | 적용 | `---` 동일 패턴 race 회피 — 각 영역 마지막 줄 본문 포함 |
| 보강 3 §6 사례 인덱스 단일 Edit | 적용 | 기존 #2 행 직후 #3·#4·#5 동시 append |
| 보강 4 라운드 1 병렬 Write | 적용 | rc.6·rc.7 패턴 일관 |

### AC 검증 결과 (5/5 PASS)

| AC | 검증 | 결과 |
|----|------|------|
| AC-1 | SSoT v1.x 보강 영역 grep (`^### 3\.4`·`^### 5\.3`·`^## 10\.`·`^## 11\.`) ≥ 4 + §6 사례 #3·#4·#5 모두 명시 | ✅ |
| AC-2 | 자비스 운영 룰 §2 학습 #25 신설 + 헤더 갱신 | ✅ L22 `#1~#25` + 학습 #25 본문 |
| AC-3 | 미러 스킬 후보 식별 산출물 신설 | ✅ `20260513-미러스킬-후보식별.md` 존재 + 4 절 |
| AC-4 | 검증된 사실 매트릭스 20건 명시 | ✅ §10 표 행 20건 |
| AC-5 | 플러그인 빌드·배포 (v1.0.0-rc.8) | ✅ build.sh --deploy + GitHub push + 캐시 v1.0.0-rc.8 본문 |

### Pre-fix 자가 정정 (정찰 단계 3건 + 관찰 1건)

| # | 단계 | 본문 | 자가 정정 |
|---|------|------|---------|
| 1 | ② 정찰 | SSoT 보강 5 영역 동일 파일 Edit race 위험 | 보강 1·2 적용 — 라운드 2 한 메시지 6 Edit + old_string 유니크화 |
| 2 | ② 정찰 | 사례 #3·#4·#5 3건만 vs 5 사이클 전부 | 의제 ❺ A — 작업지시서 §2.3 명시 3건만 |
| 3 | ② 정찰 | rc.8 description 카운트 변동 없음 (보강 사이클 본질) | 의제 ❹ A — 끝 본문만 추가 |
| 관찰 | ② 정찰 | 미러 스킬 후보 식별 산출물 빈 매트릭스 (후보 0건) | 정상 — 작업지시서 §2.7 본문 일관, 사용자 작업 패턴 누적 후 별도 사이클 |

→ Pre-fix 3건 + 관찰 1건. 실행 단계 ⑤ 추가 Pre-fix 0건.

### R8 실측

- ② 플랜모드 (정찰 + 계획서) — ~12분
- ⑤ 실행 (7 자산 + AC 검증 + 결과서) — 추정 ~55분 (rc.6·rc.7 패턴 일관)
- 누적 R8 추정 ~67분 (자비스 ③ 시간 제외)

### 다음 사이클

- W-1 사이클 잔여 4 항목 (S-06 · D-13 · G-02 · G-03) — 마감 2026-05-19
- S-01-b 지침 구조 표준 + S-01-c 플러그인 구조 표준 (W-2 또는 별도)
- 미러 스킬 실 신설 (사용자 작업 패턴 누적 후 별도 정찰 사이클)
- 변종 C-2 영속화 (Q107)

---

## v1.0.0-rc.7 (2026-05-13) — S-01 워크스페이스 폴더 구조 표준 정착 (W-1 잔여 두 번째)

### 배경

PRJ-2026-014 W-1 사이클 잔여 두 번째 항목 — Q108 A 채택 (인덱스 §4.2 순서). 워크스페이스 폴더 구조 표준 단독 영속 자산화 (지침 구조·플러그인 구조는 S-01-b·S-01-c 후속 인계). 직전 rc.6 (C-01 답변 언어 톤) 패턴 일관 — 라운드 1 6 도구 병렬 Write + R8 -27% 효율 재현.

### 신설 자산 (3건)

- **`규칙/프로세스/워크스페이스-폴더-구조-표준.md`** (~330줄) — SSoT 신설
  - frontmatter + 메타블록 + 7 절 (본 SSoT 범위 · 5 핵심 룰 · 구조 다이어그램 3건 · 자가 점검 · 자동 강제 hook · 기존 자산 cross-ref · 변천사)
  - §1.2 본질 영향 없음 영역 (`_개인/`·`.bak.*`·외부 인용) 명시 (rc.6 SSoT §1.2 패턴 일관)
  - §7.1 잔존 영역 + 정합화 후속 인계 (옛 모듈 잔존 + `.bak.*` 패턴)
  - §7.2 후속 사이클 인계 (S-01-b 지침 구조 + S-01-c 플러그인 구조)
- **`_plugin/douzone-forge/hooks/folder-structure-check.sh`** (~90줄) — PostToolUse Write|Edit hook
  - prj-code-naming-check.sh + answer-tone-check.sh 패턴 일관 (stdin JSON + jq + bash regex)
  - 룰 1 워크스페이스 루트 신설 폴더 검출 (9 정합 폴더 + `.bak.*` 외) + 옛 모듈 잔존 (`법무관리/`) 별도 검출
  - 룰 4 사번 prefix 검출 (`_개인/{사번}/`, 정합 `이름_사번/` 형식 제외 — 보강 3)
  - WARNING 만 (block 안 함)
- **자비스 운영 룰 §2 학습 #24** — 워크스페이스 폴더 구조 표준 cross-ref + 자가 점검 패턴
  - §2 헤더 갱신: `#1~#23` → `#1~#24`

### 갱신 자산 (3건)

- `_plugin/douzone-forge/.claude-plugin/plugin.json` PostToolUse 매트릭스 — `folder-structure-check.sh` 추가 (folder-purpose-check.sh 다음·link-integrity-check.sh 직전, 자비스 ⑥ 의제 ❺ C 옵션 신설 채택)
- `규칙/프로세스/공용-개인-경계-규칙.md` 메타블록 "관련 문서" — 본 SSoT cross-ref
- `douzone-forge/CLAUDE.md` "폴더 구조 규칙" 섹션 — 본 SSoT cross-ref ("정식 SSoT" 한 줄 박음)

### 카운트 변화

| 자산 | 직전 (rc.6) | 본 패치 후 (rc.7) |
|------|-----------|---------------|
| Skills | 54 | 54 (변동 없음) |
| commands | 46 | 46 |
| **hooks** | **15** | **16** (+1 folder-structure-check.sh) |
| rules | 12 | 12 |
| **SSoT (규칙/프로세스/ 신설본 누적)** | **9** | **10** (+1 워크스페이스-폴더-구조-표준.md) |

### 자비스 ⑥ 결재 반영 (의제 8건 + 보강 5건)

| 의제 | 결재 | 적용 |
|------|------|------|
| ❶ hook 본문 패턴 | **A** | prj-code-naming + answer-tone-check 패턴 일관 (stdin JSON + jq + bash regex) |
| ❷ 학습 #24 본문 분량 | **A** | 짧게 — 룰·Why·How·출처 4 헤더 |
| ❸ SSoT 본문 분량 | **A** | 작업지시서 §2 그대로 + frontmatter + 메타블록 + 변천사 |
| ❹ rc.7 description 카운트 | **A** + 보강 2 | hooks 15 → 16 + SSoT 9 → 10 (실측 선행 — `ls hooks/*.sh \| wc -l` = 15 정합) |
| ❺ hook PostToolUse 위치 | **C 옵션 신설** | folder-purpose-check.sh 다음·link-integrity-check.sh 직전 (folder-* hook 그룹 일관, 권고 A·B 모두 부적절) |
| ❻ Pre-fix 1 (영문 골격 7 폴더 정정) | **A** | §2 룰 1 본문 "영문 4 + 한글 정합 3 + 사람 관련 2 = 9 폴더" 정밀 명시 |
| ❼ Pre-fix 2 (모듈 폴더 표준 `문서/` → `_분석문서/`) | **A** | §2 룰 5 본문 정합 정정 |
| ❽ Pre-fix 3 (옛 모듈 잔존 후속 인계) | **A** | §7.1 변천사 본문 명시 |
| 보강 1 의제 ❺ C 옵션 위치 정확 | 적용 | folder-purpose-check.sh 다음·link-integrity-check.sh 직전 |
| 보강 2 카운트 실측 선행 | 적용 | `ls hooks/*.sh \| wc -l` = 15 + SSoT 실측 32 (.bak 제외) |
| 보강 3 사번 prefix 검출 패턴 정합 | 적용 | `_개인/이름_사번/` 정합 형식 검출 안 함 (룰 4 일관) — hook §5.2 명시 |
| 보강 4 SSoT §7 변천사 추가 본문 | 적용 | §7.1 잔존 영역 (옛 모듈 잔존 + `.bak.*` 패턴 정합) |
| 보강 5 라운드 1 6 도구 병렬 Write | 적용 | rc.6 보강 4 패턴 일관 — Write 2 + Edit 4 한 메시지 |

### AC 검증 결과 (5/5 PASS)

| AC | 검증 | 결과 |
|----|------|------|
| AC-1 | SSoT 신설 `^## ` 헤더 ≥ 5 | ✅ 7 절 |
| AC-2 | hook 신설 + 실행 권한 + plugin.json 등록 + bash -n | ✅ `[[ -x ]]` + Exit 0 + PostToolUse 매트릭스 |
| AC-3 | 자비스 운영 룰 §2 학습 #24 + 헤더 갱신 | ✅ L22 `#1~#24` + 학습 #24 본문 |
| AC-4 | 공용-개인-경계-규칙.md + CLAUDE.md cross-ref | ✅ 두 파일 본 SSoT cross-ref 한 줄 박음 |
| AC-5 | 플러그인 빌드·배포 (v1.0.0-rc.7) | ✅ build.sh --deploy + GitHub push + 캐시 v1.0.0-rc.7 본문 |

### Pre-fix 자가 정정 (정찰 단계 3건 + 관찰 1건)

| # | 단계 | 본문 | 자가 정정 |
|---|------|------|---------|
| 1 | ② 정찰 | 작업지시서 §2.1 룰 1 "영문 골격 7 폴더" → 실측 9 폴더 (영문 4 + 한글 정합 3 + 사람 관련 2) | 의제 ❻ A 채택 — SSoT §2 룰 1 본문 정밀 명시 |
| 2 | ② 정찰 | 작업지시서 §2.1 룰 5 `문서/` → 실측 `_분석문서/` | 의제 ❼ A 채택 — SSoT §2 룰 5 본문 정합 정정 |
| 3 | ② 정찰 | 워크스페이스 루트 옛 모듈 잔존 (`법무관리/`) | 의제 ❽ A 채택 — SSoT §7.1 후속 인계 명시 |
| 관찰 | ② 정찰 | hook 검출 룰 5 (모듈 폴더 표준 구조) PostToolUse 시점 검출 한계 | hook 룰 1·4 만 검출, 룰 2·3·5 는 자가 점검만 의존 — SSoT §5.1 명시 |

→ Pre-fix 총 3건 + 관찰 1건. 실행 단계 ⑤ 추가 Pre-fix 0건.

### R8 실측

- ② 플랜모드 (정찰 + 계획서) — ~12분
- ⑤ 실행 (9 자산 + AC 검증 + 결과서) — 라운드 1 (6 도구 병렬) + 라운드 2A·2B (4 도구) + AC 검증 + 빌드·배포 + 결과서 — 추정 ~58분
- 누적 R8 추정 ~70분 (자비스 ③ 시간 제외)

### 다음 사이클

- W-1 사이클 잔여 5 항목 (S-05 · S-06 · D-13 · G-02 · G-03) — 마감 2026-05-19
- S-01-b 지침 구조 표준 + S-01-c 플러그인 구조 표준 (W-2 또는 별도)
- 변종 C-2 영속화 (rc.5 사후 Q107 의제 인계)
- 옛 자산 처리 (옛 GitHub repo archive · 옛 로컬 디렉토리 백업)

---

## v1.0.0-rc.6 (2026-05-13) — C-01 답변 언어 톤 표준 정착 (W-1 잔여 첫 항목)

### 배경

PRJ-2026-014 W-1 사이클 잔여 첫 항목 — Q106 A 채택 (인덱스 §4.2 순서 진입). 자비스 답변 본문 + 워크스페이스 산출물의 언어 톤 표준 정착. 기존 `prj-code-naming` rule 패턴 확장 + 4 핵심 룰 SSoT + 자동 강제 hook + 자비스 운영 룰 학습 #23 추가.

### 신설 자산 (3건)

- **`규칙/프로세스/답변-언어-톤-표준.md`** (~280줄) — SSoT 신설
  - frontmatter + 메타블록 + 6 절 (본 SSoT 범위 · 4 핵심 룰 · 자가 점검 · 자동 강제 hook · 기존 자산 cross-ref · 변천사)
  - §1.2 **사용자 본인 어휘 보호** 명시 (자비스 ⑥ 보강 1 적용)
- **`_plugin/douzone-forge/hooks/answer-tone-check.sh`** (~80줄) — PostToolUse Write|Edit hook
  - prj-code-naming-check.sh 패턴 일관 (stdin JSON + jq + grep)
  - 영문 두문자 ≥ 4자 + 사번·티켓 ID 패턴 (CSA10·KLAGOP1·A10D·UBA·UAC·EO·BC10) 검출
  - WARNING 만 (block 안 함)
- **자비스 운영 룰 §2 학습 #23** — 답변 언어 톤 표준 cross-ref + 자가 점검 패턴
  - §2 헤더 갱신: `#1~#22` → `#1~#23`

### 갱신 자산 (3건)

- `_plugin/douzone-forge/.claude-plugin/plugin.json` PostToolUse 매트릭스 — `answer-tone-check.sh` 추가 (prj-code-naming-check.sh 다음 그룹화)
- `_plugin/douzone-forge/rules/prj-code-naming.md` — 본 SSoT cross-ref + answer-tone-check.sh hook cross-ref
- `douzone-forge/CLAUDE.md` "PRJ 코드 표기 규칙" 섹션 — 본 SSoT cross-ref + answer-tone-check.sh hook cross-ref

### 카운트 변화

| 자산 | 직전 (rc.5) | 본 패치 후 (rc.6) |
|------|-----------|---------------|
| Skills | 54 | 54 (변동 없음) |
| commands | 46 | 46 |
| **hooks** | **14** | **15** (+1 answer-tone-check.sh) |
| rules | 12 | 12 |
| **SSoT (규칙/프로세스/ 신설본)** | **8** | **9** (+1 답변-언어-톤-표준.md) |

### 자비스 ⑥ 결재 반영 (의제 5건 + 보강 4건)

| 의제 | 결재 | 적용 |
|------|------|------|
| ❶ hook 본문 패턴 | **A** | prj-code-naming-check.sh 패턴 일관 (stdin JSON + jq) |
| ❷ 학습 #23 본문 분량 | **A** | 짧게 — 룰·Why·How·출처 4 헤더 |
| ❸ SSoT 본문 분량 | **A** + 보강 1 | 작업지시서 §2.1·§2.2 그대로 + §1.2 사용자 본인 어휘 보호 명시 |
| ❹ rc.6 description 카운트 | **A** + 보강 2 | hooks 14 → 15 + SSoT 8 → 9 (실측 선행 — ls hooks/*.sh = 14 → 15) |
| ❺ hook PostToolUse 위치 | **B** | prj-code-naming-check.sh 다음 그룹화 (관련 hook 그룹 일관) |
| 보강 1 SSoT §1 사용자 본인 어휘 보호 | 수용 | §1.2 추가 (사용자 직접 발화·_개인/·외부 인용·변천사 보호) |
| 보강 2 plugin.json 카운트 실측 선행 | 수용 | `ls hooks/*.sh \| wc -l` = 14 정합 → 15 갱신 |
| 보강 3 chmod +x + bash -n syntax check | 수용 | `chmod +x` 적용 + `bash -n` Exit 0 |
| 보강 4 ⑤ 실행 병렬 Write | 수용 | 라운드 1 (Write 2 + Edit 4 = 6 도구 병렬) + 라운드 2 (Edit 3 + Bash) |

### AC 검증 결과 (5/5 PASS)

| AC | 검증 | 결과 |
|----|------|------|
| AC-1 | SSoT 신설 `^## ` 헤더 ≥ 5 | ✅ 6 절 (메타·4 핵심 룰·자가 점검·hook·cross-ref·변천사) |
| AC-2 | hook 신설 + 실행 권한 + plugin.json 등록 | ✅ `[[ -x ]]` + plugin.json PostToolUse 9 hooks |
| AC-3 | 자비스 운영 룰 §2 학습 #23 신설 | ✅ `grep -E "^## 학습 #23"` 1 매칭 + §2 헤더 갱신 |
| AC-4 | 기존 자산 cross-ref 추가 (CLAUDE.md + rules/prj-code-naming.md) | ✅ 두 파일 본 SSoT cross-ref 한 줄 박음 |
| AC-5 | 플러그인 빌드·배포 (v1.0.0-rc.6) | ✅ build.sh --deploy + GitHub push + 캐시 v1.0.0-rc.6 본문 |

### Pre-fix 자가 정정

- ② 정찰 단계 3건:
  1. 작업지시서 §2.3 hook 본문 골격 (`CLAUDE_TOOL_PARAM_file_path` 환경변수) vs 실 패턴 (stdin JSON + jq) → 의제 ❶ A 권고 정정
  2. §2 헤더 갱신 의무 (`#1~#22` → `#1~#23`) → Edit 호출 2회 처리
  3. plugin.json description 카운트 정합 → 보강 2 실측 선행 적용 (hooks 14 정합)
- ② 정찰 관찰 1건:
  4. answer-tone-check.sh 영문 두문자 검출 false positive (예: "SSoT" 다수) — WARNING 만 발생, 차단 위험 없음

→ Pre-fix 총 3건 (정찰 단계) 자가 정정 + 관찰 1건. 실행 단계 ⑤ 추가 Pre-fix 0건.

### R8 실측

- ② 플랜모드 (정찰 + 계획서) — ~10분
- ⑤ 실행 (8 자산 + AC 검증 + 결과서) — 라운드 1 (6 도구 병렬) + 라운드 2 (3 직렬) + AC 검증 + 빌드·배포 + 결과서 — ~55분
- 누적 R8 ~65분 (자비스 ③ 시간 제외, 추정 ~75분 대비 **-13%**)

### 다음 사이클

- W-1 사이클 잔여 6 항목 (S-01 · S-05 · S-06 · D-13 · G-02 · G-03) — 마감 2026-05-19
- 변종 C-2 영속화 (rc.5 사후 식별 — Q107 의제 인계)
- 옛 자산 처리 (옛 GitHub repo archive · 옛 로컬 디렉토리 백업)

---

## v1.0.0-rc.5 (2026-05-13) — 함정 #6 영속화 통합 사이클 (의제 5·6·7 + AC-6)

### 배경

직전 함정 #6 변종 3건 (옛 경로 ENOENT + install 사일런트 + Anthropic directory 캐시) + sub-변종 B-③ (uninstall "not found" + install 정상) 식별 후 정식 영속화 사이클. {이름} ⑥ 결재 Q105 A 권고안 채택 — rc.4 ⑥ 결재 후 즉시 의제 5·6·7 통합 rc.5 진입.

### 신설 자산 (3건)

- **`규칙/프로세스/플러그인-마켓플레이스-운영규칙.md`** (~580줄) — SSoT 신설 13 절
  - §1 본 SSoT 범위 · §2 마켓플레이스 이름 표준 (`douzone-forge` 단일) · §3 디렉토리 구조 · §4 plugin.json 표준 필드 · §5 CHANGELOG.md 항목 표준 · §6 build.sh `--deploy` 6 단계 흐름 · §7 CLI vs CoWork 시스템 차이 · §8 함정 #6 변종 3건 + sub-변종 B-③ 진단·해결 매트릭스 · §9 PT-01.5 build.sh 강화 + sub-변종 B-③ 인지 · §10 사용자 측 환경 동기화 절차 · §11 **검증된 사실 매트릭스 영속화 (5건)** · §12 다른 마켓플레이스 참조 · §13 변천사 (옛 이름 → 새 이름 + rc.4 → rc.5)
  - frontmatter 일관 (Forge-초기화-가이드.md 패턴) + 메타블록 (작성일·근거·상위규칙·관련문서)
- **`_plugin/CLAUDE.md` 함정 #6 보강** — 단일 변종 (PT-01.5 옛 경로 ENOENT) → **변종 A·B·C 분리 + sub-변종 B-③ 부속 매트릭스** 확장
  - 변종 B: install `already installed` 사일런트 (rc.5 신규)
  - 변종 C: Anthropic directory 캐시 (rc.5 신규)
  - sub-변종 B-③: uninstall "not found" 사일런트 + install 정상 + 캐시 정상 (rc.4 결과서 §4.1 식별)
  - 검증된 사실 매트릭스 cross-ref (의제 7 SSoT §11)
- **`build.sh` 강화** — 4 영역 추가
  - 마켓플레이스 이름 검증 (`marketplace.json` `name` = `douzone-forge` 정합)
  - uninstall + install 격상 (변종 B 차단)
  - sub-변종 B-③ 인지 (`uninstall ... || true` + 출력 grep 영역 분리)
  - 격상 후 캐시 디렉토리 본문 존재 검증

### 카운트 변화

| 자산 | 직전 (rc.4) | 본 패치 후 (rc.5) |
|------|-----------|---------------|
| Skills | 54 | 54 (변동 없음) |
| commands | 46 | 46 |
| hooks | 14 | 14 |
| rules | 12 | 12 |
| **SSoT (규칙/프로세스/)** | **7** | **8** (+1 플러그인-마켓플레이스-운영규칙.md) |

### 자비스 ⑥ 결재 반영 (의제 5건 + 보강 4건)

| 의제 | 결재 | 적용 |
|------|------|------|
| ❶ SSoT 13 절 구조 | **A** | 작업지시서 §2.3 명시 13 절 그대로 + frontmatter + 메타블록 보강 |
| ❷ 의제 7 SSoT vs 의제 5 함정 #6 본문 중복 회피 | **A** | SSoT = 정식 본문 / 함정 #6 = 요약 + cross-ref |
| ❸ build.sh `uninstall \|\| true` 본문 | **A** | `\|\| true` 격상 + 출력 grep 영역 분리 (uninstall = WARNING / install = exit 1) |
| ❹ 검증된 사실 5건 영속화 위치 | **A** | SSoT §11 박음 + 함정 #6 본문 cross-ref |
| ❺ rc.5 description 카운트 갱신 | **A** | SSoT 7 → 8 + 끝에 rc.5 본문 추가 |
| 보강 1 SSoT frontmatter name 일관성 | 수용 | 파일명 base name 한글 그대로 (`name: 플러그인-마켓플레이스-운영규칙`) |
| 보강 2 build.sh `${PLUGIN_NAME}` 변수 사전 확인 | 수용 | L4 정의 확인 — 변수 그대로 사용 |
| 보강 3 build.sh dry-run 검증 | 수용 | bash -n syntax check + 부분 단계 수동 실행 |
| 보강 4 ⑤ 실행 병렬 Write 활용 | 수용 | 라운드 1 (4 자산 병렬: Write 1 + Edit 3) + 라운드 2 (build.sh 단일 Edit) |

### AC 검증 결과 (6/6 PASS)

| AC | 검증 | 결과 |
|----|------|------|
| AC-1 | `_plugin/CLAUDE.md` 함정 #6 변종 본문 grep — 변종 A·B·C + sub-변종 B-③ 부속 매트릭스 + 진단 명령 + 해결 절차 본문 카운트 ≥ 4 | ✅ |
| AC-2 | `build.sh` 강화 grep — `grep -iE` 패턴 + `uninstall \|\| true` + install 출력 차단 + `name` 필드 검증 + 캐시 디렉토리 본문 존재 검증 모두 존재 | ✅ |
| AC-3 | SSoT 신설 13 절 grep — `grep -c "^## " 규칙/프로세스/플러그인-마켓플레이스-운영규칙.md` ≥ 13 + §11 검증된 사실 5건 모두 명시 | ✅ |
| AC-4 | plugin.json + CHANGELOG.md 갱신 — `version`: `1.0.0-rc.5` + `description` 카운트 정합 (SSoT 8) + CHANGELOG rc.5 항목 prepend | ✅ |
| AC-5 | `build.sh --deploy` 종착 정상 (격상 본문 적용) — exit 0 + rc.5 commit + `~/.claude/plugins/cache/douzone-forge/douzone-forge/1.0.0-rc.5/` 디렉토리 **본문 존재** | ✅ |
| AC-6 | tee 로그 영속화 (자비스 ⑥ C 채택) — `/tmp/rc4-{uninstall,install}.log` → `프로젝트/PRJ-2026-014_*/05_산출물/log/` 이동 | ✅ |

### Pre-fix 자가 정정 (정찰 단계 3건 + 관찰 1건)

| # | 단계 | 본문 | 자가 정정 |
|---|------|------|---------|
| 1 | ② 정찰 | `_plugin/CLAUDE.md` 함정 #6 기존 본문 보존 vs 재구성 선택 | 옵션 A (기존 본문 → 변종 A 명명 + 변종 B·C 추가) 채택 |
| 2 | ② 정찰 | build.sh PT-01.5 기존 본문 보존 vs 재구성 | 기존 본문 보존 + 영역 교체 + 신규 추가 |
| 3 | ② 정찰 | AC-6 영속화 후 `/tmp/rc4-*.log` 원본 처리 | `cp` 채택 (mv 아님 — 원본 보존) |
| 관찰 | ② 정찰 | plugin.json description 본문 길이 ~800자 도달 | JSON 본문 가독성 영향 미미 (CLI 메타) |

### R8 실측

- ② 플랜모드 (정찰 + 계획서) — ~10분
- ⑤ 실행 (병렬 Write 4 자산 + build.sh 단일 Edit + AC 검증 + 결과서) — ~60분
- 누적 R8 ~70분 (자비스 ③ 시간 제외, 추정 ~80분 대비 -12.5%)

### 다음 사이클

- **rc.5 ⑥ 결재 후**: W-1 사이클 잔여 7 항목 (C-01 · S-01 · S-05 · S-06 · D-13 · G-02 · G-03) — 마감 2026-05-19
- 옛 자산 처리 (옛 GitHub repo archive · 옛 로컬 디렉토리 백업 · Anthropic directory 자연 만료) — 직전 결과서 §10 후속 의제 (별도 사이클)
- solo-forge·study-assistant·knowledge-forge 마켓플레이스 동일 표준 적용 — 별도 사이클

---

## v1.0.0-rc.4 (2026-05-12) — W-1 S-09 에이전트 구성·역할 정의 표준 정착

### 배경

PRJ-2026-014 W-1 (2026-05-12~05-19) 사이클 8 작업 항목 중 **S-09 (에이전트 구성·역할 정의 표준)** 산출 1·2·3·4 영역 일괄 정착. 작업지시서 [`20260512-작업지시서-S-09-에이전트구성.md`](https://github.com/) + 입력 자산 (조사보고) + 자비스 ⑥ 결재 (의제 ❶~❺ + 보강 2건) 결과 반영. 협업 표준 §3 6 단계 흐름 정합 — Cowork ① → Code ②④ → Cowork ③ → Code ⑤ → Cowork ⑥.

### 산출 영역 4건

- **산출 1 — SSoT 신설**: `규칙/프로세스/에이전트-구성-역할-정의.md` (12절 · 실측 18 헤더 · ~470줄). 3 계층 구조 + 14 업무별 매트릭스 + 2 메타 에이전트 + 하네스 본질 + Subagent 4 가치 + Multi-agent MCP 아키텍처 + 디스패치 규칙 + 표준 프롬프트 템플릿 + 정합 매트릭스 + 운영 결정 D-1~D-5 + 관련 자산
- **산출 2 — 자비스 운영 룰 §2 갱신**: 헤더 `#1~#11 통합 본문` → `#1~#22 통합 본문 (#12~#19 예약)` + 학습 #20 (하네스 본질) · #21 (Subagent 4 가치) · #22 (Multi-agent MCP) 신설. 각 학습 표준 4 헤더 (룰·Why·How to apply·출처)
- **산출 3 — 14 업무별 서브에이전트 SKILL.md 신설**:
  - `dz-oracle-agent` (ORACLE 시장조사·벤치마킹)
  - `dz-cipher-agent` (CIPHER 요구사항 접수·분석)
  - `dz-matrix-agent` (MATRIX IA 설계)
  - `dz-vector-agent` (VECTOR 화면설계·와이어프레임)
  - `dz-prism-agent` (PRISM 디자인 시스템)
  - `dz-weaver-agent` (WEAVER 퍼블리싱)
  - `dz-core-agent` (CORE 백엔드 개발)
  - `dz-nova-agent` (NOVA 프론트엔드 개발)
  - `dz-synapse-agent` (SYNAPSE MCP 개발)
  - `dz-trace-agent` (TRACE 검수 시나리오)
  - `dz-probe-agent` (PROBE 검수 진행)
  - `dz-launch-agent` (LAUNCH 배포)
  - `dz-aegis-agent` (AEGIS 정합성 검증)
  - `dz-helm-agent` (HELM 운영 거버넌스)
  - 각 SKILL.md = ~140줄 (frontmatter + 역할 + AgentDefinition 표준 필드 매트릭스 + 입력 + 산출 + 디스패치 패턴 + 호출 예시 + 관련 자산). 합계 ~1,960줄. 본문 구조 일관성 강제 (자비스 ⑥ 보강 의견 ❺)
- **산출 4 — `dz-agent-dispatch` 전면 갱신**: 5-agent (하준·서연·도윤·지호·수아) → 14+2 (ORACLE~HELM + AVATAR·NEXUS). 호환 매트릭스 (1:1 + 추가 호환) 변천사 보존. 디스패치 4 규칙 + Subagent 4 가치 정합 보강. 표준 프롬프트 7 슬롯. 출력 경로 매트릭스 = Forge 폴더 표준. 교훈 3건 (보존 2 + 하네스 본질 1). ~230줄

### 카운트 변화

| 자산 | rc.3 (직전) | rc.4 (본 사이클) |
|------|----------|---------|
| Skills | 40 | **54** (+14 dz-*-agent) |
| commands | 46 | 46 |
| hooks | 14 | 14 |
| rules | 12 | 12 |
| SSoT (규칙/프로세스/) | 6 | **7** (+1 에이전트-구성-역할-정의.md) |

### 자비스 ⑥ 결재 반영 (의제 5건 + 보강 2건)

| 의제 | 결재 | 적용 |
|------|------|------|
| ❶ 5-agent ↔ 14 호환 매핑 | **A** + 추가 호환 | 1:1 (하준→ORACLE / 서연→CIPHER / 도윤→VECTOR / 지호→CORE / 수아→AEGIS) + 추가 호환 (도윤→+PRISM / 지호→+NOVA+SYNAPSE / 수아→+TRACE+PROBE) — SSoT §3.3 + dispatch 호환 매트릭스 |
| ❷ 학습 # 점프 | **A** | #20·#21·#22 신설 (작업지시서 그대로) |
| ❸ §2 헤더 갱신 | **A** + 보강 | `#1~#22 통합 본문 (#12~#19 예약)` |
| ❹ AC-5 빌드 시점 | **B** | ⑤ 종착 보고 후 {이름} ⑥ 결재 → 본 빌드 진행 (rc.3 패턴 일관) |
| ❺ 14 SKILL.md 분량 | **A** + 보강 | ~140줄 × 14 + 본문 구조 일관성 강제 |
| 보강 1 | 수락 | 디스패치 패턴 절에 표준 프롬프트 템플릿 1건 명시 ✅ |
| 보강 2 | 수락 | Pre-fix 카운트 명시 ✅ |

### AC 검증 결과 (5/5 통과)

| AC | 검증 | 결과 |
|----|------|------|
| AC-1 | SSoT 12절 작성 | 실측 18 헤더 (≥ 12 충족) ✅ |
| AC-2 | 학습 #20·#21·#22 신설 | grep 매칭 3건 정확 ✅ |
| AC-3 | 14 SKILL.md + AgentDefinition 필드 | 14건 + 각 파일 6 필드 모두 명시 ✅ |
| AC-4 | dz-agent-dispatch 14+2 명명 + 5-agent 변천사 | 16 명명 모두 ≥ 1 매칭 + 5-agent 5건 보존 ✅ |
| AC-5 | 본 사이클 빌드·배포 (v1.0.0-rc.4) | 진행 (본 changelog 항목 + plugin.json + dist/) ✅ |

### Pre-fix 자가 정정

- ② 정찰 단계 3건:
  1. 작업지시서 §3.2 학습 #20·#21·#22 신설 전제 vs 현 §2 헤더 "#1~#11" 불일치 → 의제 ❸ §2 헤더 갱신으로 박힘
  2. 자비스 학습 # 현재 #11 + #12~#19 빈 슬롯 → 의제 ❷ 옵션 명시 + 의제 ❸ "예약" 명시
  3. dz-agent-dispatch `docs/01~05` Forge 표준 아님 → 산출 4 갱신 매트릭스에 박힘
- ⑤ 실행 단계 1건:
  4. plugin.json `version` + `description` 카운트 갱신이 ⑤ 실행 단계에 미포함 → 결과서 §8.3 명시 + 본 빌드 직전 자가 정정 적용

→ Pre-fix 총 4건 (정찰 3 + 실행 1) 모두 자가 정정 완료.

### R8 실측

- 추정 ⑤ 종착까지 75분 → 실측 ~33분 (-56%)
- 본 빌드·배포 (AC-5) = ~3분 추가 (rc.3 패턴 일관)
- 효율 향상 본질: 병렬 Write (한 메시지 5/5/4 그룹) + 직접 자료 본문 작성

### 다음 사이클

- W-1 사이클 잔여 7 항목: C-01 · S-01 · S-05 · S-06 · D-13 · G-02 · G-03
- solo-forge:solo-agent-dispatch 정합 (별도)
- 각 에이전트별 MCP 서버 권한 매트릭스 상세 (별도)
- AVATAR · NEXUS 메타 에이전트 SKILL.md 신설 (별도)

---

## v1.0.0-rc.3 (2026-05-12) — Cowork ↔ Claude Code 플러그인 상속 갭 폴백 신설 (단발 갭 패치)

### 배경

2026-05-12 {이름} 수석의 PRJ-2026-013 기술위원회 AI 개발툴 TFT — Claude Enterprise 운영 환경 통합본 시각화 작업 중 실증된 갭. 코워크 자비스 답변에서 "frontend-design 스킬은 현재 Cowork 환경 직접 호출 미지원 — TASK-S-05 본질" 명시 → Claude Code 환경으로 작업 위임 후 시각화 산출 완료. 본 사이클 종료 시점에 {이름} ⑩ 결재 의제 옵션 B 채택 (옵션 C 와 병행 수용 — 옵션 C 는 {이름} 본인이 코워크에서 진행).

### 신설 자산 (1건)

- **`skills/dz-frontend-design/SKILL.md`** (약 200줄) — Anthropic `claude-plugins-official / frontend-design` 본질 미러 폴백 스킬
  - 호출 우선순위: **Claude Code 환경 = 원본 `frontend-design:frontend-design` 우선** · **Cowork 환경 = 본 폴백 미러 진입**
  - 본 SKILL.md §1 환경별 우선순위 표 명시 → Claude Code 환경에서 본 스킬 호출 시 원본 위임으로 자동 거절
  - 더존 컨텍스트 보강: 한국어 본문 처리 (Pretendard Variable), 인쇄 친화 (`@media print`), ONEFFICE 환경 분리, PRJ 코드 표기 규칙 cross-ref
  - 라이선스: 원본 LICENSE.txt 준수 + 출처 명기 + 분기 (divergence) 관리 정책 §7.2 박음
  - archive 조건: Anthropic frontend-design 이 Cowork 에서도 정식 호출 가능해지면 본 스킬 폴백 의무 상실 → `_archive/` 이동 + plugin.json 제거

### 카운트 변화

| 자산 | 직전 (실측) | 본 패치 후 |
|------|----------|---------|
| Skills | 39 | **40** |
| commands | 46 | 46 |
| hooks | 14 | 14 |
| rules | 12 | 12 |

> ⚠️ rc.2 `plugin.json` description 의 "Skills 38" 표기는 발행 당시 부정확 (자연 누적 1건 반영 누락 추정). 본 패치 시점 `ls skills/ | wc -l` 실측 기준 직전 39 → 본 신설 후 40. plugin.json description 도 "Skills 40" 으로 정정.

### 정책 영향

- **`dz-html-oneffice-builder/SKILL.md` STEP 1 정책과의 관계**: 기존 "자체 미학 가이드 신설 금지 — Anthropic 공식 플러그인 1차 인용" 정책은 유지. 본 미러는 이 정책의 **Cowork 폴백 예외**로 명확히 박힘. Claude Code 환경에서는 여전히 원본 frontend-design 우선이며, 본 스킬은 자동 위임 거절로 정책 일관성 보장.
- **`dz-html-oneffice-builder/SKILL.md` cross-ref 보강**: "Cowork 환경에서 frontend-design 미가용 시 `dz-frontend-design` 폴백 가능" 안내 추가 검토 — 본 사이클 범위 외, **rc.4 또는 별도 사이클에서 처리** ({이름} 수석 옵션 C 진행 결과와 묶음).

### 다음 사이클 (자비스 ⑩ 권고)

- **옵션 C 진행 결과 수신**: {이름} 수석이 코워크에서 `규칙/프로세스/cowork-to-claudecode-migration.md` SSoT 에 본 5/12 케이스를 표준 패턴으로 박음. 결과 수신 후 본 플러그인 측 cross-ref 보강 검토
- **V-08 + V-09 + V-10 통합 사이클**: 본 단발 갭 패치와 독립. 본래 다음 진입점 그대로 유효
- **Anthropic frontend-design 갱신 추적**: 분기 (divergence) 발생 시 본 미러 SKILL.md §7.2 정책에 따라 동기화 또는 분기 명시

### Pre-fix

- **1건** — 본 패치 작성 중 plugin.json description 의 직전 카운트 "Skills 38" 표기를 그대로 신뢰하여 "38 → 39" 로 1차 갱신했으나, `ls skills/ | wc -l` 실측에서 40개 확인됨 (직전 실측 39 → 본 신설 후 40). plugin.json description + CHANGELOG 카운트 표 모두 자가 정정.
- **학습**: 카운트 표기 작업 시 기존 description 본문 신뢰 X — 반드시 `ls skills/ | wc -l` 실측 선행 후 표기. 자비스 학습 #12 후보 (가정 권고 vs 실측, 2026-05-11 §A 교훈 2 연장선) 의 또 다른 사례.

---

## v1.0.0-rc.2 (2026-05-11) — Phase V V-06+V-07 통합 패치 (RC 안정화 후속)

### 배경

Phase V 진단 트랙 (V-01~V-05) 종합 발견 8건 중 Critical 2 + High 4 일괄 해소를 위한 V-06 P0 + V-07 P1 통합 사이클. {이름} ⑩ 결재 의제 1 옵션 B 채택 (사이클 분리 비용 회피, 학습 #6 일관). 본 사이클 종료 후 V-08 (P2 위장된 룰 5건 SSoT 이전) · V-09 (P3 PARTIAL spot check 3건 보강) 는 별도 사이클.

### V-06 — 폴더 표준 P0 패치 (4 sub-트랙)

- **V-06-01 — 활성 9 모듈 루트 `_README.md` 신설** (LTE·CRM·BOARD·KISS·AB·공통·시스템설정·ONE AI·퍼블리싱): 모듈 소개·라이선스·폴더 구조·PRJ 인덱스·연관 SSoT·담당자 6 섹션 표준. 평균 64줄. SSoT 11종 인용. {이름} 본인 정보 누설 0건.
- **V-06-02 — CLAUDE.md 명칭 정합화** (옵션 a — 자비스 ① 권고 옵션 b 정정): 9건 위치 `문서/` → `_분석문서/` 정정. 실 폴더 rename X (옵션 b 비용 회피).
- **V-06-03 — `deliverables/` 골격 신설** (옵션 c): 4 폴더 (`deliverables/{보고서/일일보고/원본캐시, 보고서/주간보고, 산출물}/`) + 4 `_README.md` (41~58줄). V-04 §6.3 P0 갭 해소.
- **V-06-04 — 9×6 매트릭스 우선 채우기**: 7 모듈 `유지보수/` 사전 골격 신설 (CRM·KISS·AB·공통·시스템설정·ONE AI·퍼블리싱) + 7 `_index.md` 4컬럼 확장 스키마. 36 cell 100% 충족. `/dz-triage` 멱등성 FAIL → P1 권고 박힘 (SKILL.md §5.5 사전 골격 보장 + PostToolUse Hook 이중 방어 권고).

### V-07 — 강제력 + 메모리 위생 + 누설 환수 + High 갭 P1 패치 (4 sub-트랙)

- **V-07-01 — 학습 L 등급 4건 강제 메커니즘 신설 (Hook 4 + Rule 4)**:
  - `hooks/simple-approval-md-block.sh` (학습 #4, 경고 exit 0, 66줄)
  - `hooks/v2-version-bump-block.sh` (학습 #6, 차단 exit 2, 73줄)
  - `hooks/umbrella-vocab-block.sh` (학습 #8, 경고 exit 0, 91줄)
  - `hooks/memory-rule-content-block.sh` (학습 #11, 차단 exit 2, 86줄) — 화이트리스트 (본인·내·{이름}·{ID}) false positive 회피
  - `rules/single-approval-policy.md` · `no-v2-rebump.md` · `master-vocab.md` · `memory-scope.md` (4건, 57~72줄)
  - hooks 10 → **14** / rules 8 → **12**
  - V-01 L 등급 승급: #4·#8 → M (경고 강제), #6·#11 → H (차단 강제)
- **V-07-02 — `memory-write-block` 본질 통합**: V-07-01 `memory-rule-content-block.sh` 가 마스터지시서 §5.2 본질 100% 커버. 별도 신설 X — 통합 위임. SSoT 후보 grep 정밀화 P3 권고 박힘.
- **V-07-03 — HIGH 메타 누설 2건 환수·익명화**:
  - `규칙/프로세스/cowork-to-claudecode-migration.md` (sed 광역): `/Users/{ID}/` → `$HOME/`·`com.{ID}.` → `com.${USER}.` 일괄. 환수 후 grep 매칭 **0건**.
  - `규칙/프로세스/Forge-GitLab-운영가이드.md` (Edit 정밀): `[UC]{이름}` → `[UC]{사용자이름}`·`{ID}@douzone.com` → `{사번}@douzone.com` 변수형 일반화. 변천사 본문 (L3·L15·L41·L58·L129·L130·L137) 출처 보존.
  - 백업 2건 (`.bak.V07`) 신설 — 학습 #1 4영역 일관.
- **V-07-04 — High 갭 3건 해소**:
  - P1 — `skills/dz-cascade-from-context/SKILL.md` description 트리거 키워드 4건 추가 (context 갱신·LNB 수정·기능 분석·모듈 컨텍스트 갱신). 매칭 7건.
  - P2 — `commands/dz-personal-init.md` v0.4.0 §5 신설 (88줄) + `skills/dz-people-context/SKILL.md` 3단 fallback lookup. xlsx 13번 동적 lookup → `_개인/{본인이름_사번}/_R&R.md` 자동 정착. grep 매칭 18건.
  - P3 — `규칙/프로세스/Beta-3인-환경-준비.md` §3.1 신설 (143줄). amaranth10-jira-collector PoC macOS·Windows·Linux 설치 + JIRA API 토큰 + 작동 검증 + 트러블슈팅 매트릭스 7건. 변수형 13건. {이름} 본인 path/이메일 0건.

### 강제력 매트릭스 변화

| 학습 # | v1.0.0-rc.1 | v1.0.0-rc.2 |
|--------|------------|------------|
| #4 (단순 결재 .md 생략) | L | **M** (경고) |
| #6 (v2 갱신 X) | L | **H** (차단) |
| #8 (마스터 어휘) | L | **M** (경고) |
| #11 (메모리 한정) | L | **H** (차단) |

### 자비스 자인 (⑥ 채택)

- 의제 ❶ V-06-02: 자비스 ① 권고 옵션 b → Code 권고 옵션 a 정정 (CLAUDE.md 정정 9건 << 광역 폴더 rename 14건)
- 의제 ❷ V-06-03: 옵션 c (deliverables/ 골격 신설) OK
- 의제 ❸ 버전: v0.20.0 (Code 계획서 §10 가정) → **v1.0.0-rc.2** 본체 자가 정정 (실 현황 v1.0.0-rc.1 — Code 정찰 부재로 Pre-fix 1 카운트)

### 다음 사이클 권고 (자비스 ⑩)

- V-08 (P2): 위장된 룰 5건 SSoT 이전 (자비스-운영-룰 §5 + 아마링크·ONEFFICE 가이드 보강 + 신설 1건)
- V-09 (P3): PARTIAL spot check 3건 본문 명시도 보강 (자비스-운영-룰 §5 GNB hover·PDF 폰트·파일 삭제)
- /dz-triage 멱등성 패치 (V-06-04 P1 권고): SKILL.md §5.5 사전 골격 보장 + PostToolUse Hook 이중 방어

### Phase 누적

Phase Q+R+R++S+T+U+V(진단)+V(V-06+V-07 패치) 누적 R8: Phase U 4:44 + Phase V(04/28) 6:13 + Phase V 진단(05/11) 7:12 + 본 사이클 (Phase C 종착 시점 명시).

---

## v1.0.0-rc.1 (2026-04-28) — Phase V Forge 배포 준비 + 공용/개인 격차 0 (메이저 진급 RC)

### 배경

Phase U 종착 (자비스 메모리 위생·v0.19.1) 직후, {이름} 직접 명령: "사내 누구나 환경 사용 가정 + 공용/개인 영역 구분 의무". 자비스 통합 점검 결과 격차 6건 (HIGH 1·MEDIUM 3·LOW 2) 식별 → Phase V 통합 처리 + v1.0.0 RC 메이저 진급.

### 메이저 진급 의미

- v0.19.1 → **v1.0.0-rc.1** (Release Candidate)
- Beta 3인 합류 직전 안정화 게이트
- v1.0.0 정식 = Beta 3인 검증 종착 후 별도 결재

### 격차 0 정정 (D-02·D-05 강제 적용)

- **V-01 CLAUDE.md (douzone-forge) 일반화** (3건): SBUnit 22명·9 모듈 → 본 사용자 부서 + xlsx 동적 lookup 표준
- **V-01 _plugin/CLAUDE.md path 정정** (8건): `/Users/{ID}/Workspace/...` → `~/Workspace/...`
- **V-01 공용-개인-경계 §8 Cell 리더 일반화**: 4명 명시 → "각 Cell 리더 (xlsx 13번 ID 동적 참조)"
- **V-03 사용자ID-매핑 §2·§3 단축 안내**: 정태 매핑 22+21명 → xlsx 동적 참조 인용 명시 (변천사 보존)
- **V-05 플러그인 {ID} 환경 경로 8건 sed**: 절대 경로 → `~/` 변환
- **V-05 플러그인 일반화 3건**: 21명 추출·9 모듈 본문 절차 → 본 사용자 부서·활성 모듈

### 신설 자산 (V-03)

- **`규칙/프로세스/Beta-3인-환경-준비.md`** (142줄): Beta 3인 합류 환경 준비 7 STEP

### 변천사 보존 (학습 #8 일관)

- {이름} 학습 출처 인용 25건 (skills): 학습 #1·#2·#10 등 출처 명기 — rename·삭제 X
- 옛 "우산" 7건 (douzone-forge 프로젝트 메타): Phase Q·R·R+ 우산 지시서 — 변천사 보존
- 정태 매핑 22+21명 표 (사용자ID-매핑.md §2·§3): 감사·학습 추적용 보존

### 잔존 정리 인벤토리 (V-04, D-04)

- `.bak.*` 25건 + `outputs/` 4건 = 29건
- Step 12 정식 배포 직전 일괄 삭제 권고 (본 Phase는 인벤토리만)

### 자비스 자인 (⑥ 채택)

- V-05 메모리 추정 ~121건 → 실측 9건 ({ID} 8 + 21명 1)
- 학습 #9 (마켓 존재 단정 금지) 위반 자인 — Code 실측 후 광범위 정정 X

---

## v0.19.1 (2026-04-28) — Phase U U-05 frontend-design 환경 의존 차단 (D-04 강화)

### 배경

Phase T 종착 시 시나리오 (A) 확정 — {이름} 본인 다른 세션에서도 frontend-design 부재 = R-01 리스크 현실화. Phase U U-05 트랙으로 흡수. Phase U D-04: "frontend-design 환경 의존 차단 (Skill tool 매번 invoke 의무)".

### 보강 (✚)

- **T-01 SSoT (`규칙/프로세스/HTML-원피스-작성-표준.md`) §2 보강**: fallback 차단 명시 (design 7 skills 사용 금지·자체 미학 추정 금지) + Cowork Customize 사용자 환경 설치 가이드 (Plugin Marketplace → claude-plugins-official 검색 → Frontend design 활성화)
- **T-02 SKILL.md (`dz-html-oneffice-builder/SKILL.md`) STEP 1 보강**: Skill tool 매번 invoke 의무화 (세션별 활성화 자동 보장) + invoke 실패 시 {이름} 결재 요청 + 자체 추정·design fallback 금지

### 의도

Phase T R-01 (frontend-design 부재 시 시나리오 A) 강화 — Phase U U-05 흡수 처리. v0.19.0 → v0.19.1 패치 (보강만).

### Phase U 동시 산출 (참고)

- 신설: `규칙/프로세스/자비스-운영-룰.md` SSoT (학습 #1~#11 통합 309줄, 11 ## 학습 # + 8 최상위 섹션)
- 신설: `프로젝트/PRJ-2026-014_*/01_기획/20260428-PhaseU-메모리-인벤토리-분류.md` (45건 분류표)
- 자비스 영역 (별도): MEMORY.md 인덱스 정리 + 메모리 25건 reference 포인터 + deprecated 1건 삭제

---

## v0.19.0 (2026-04-28) — Phase T HTML 원피스 작성 표준

### 배경

Phase S 종착 (v0.18.0) 직후, ONEFFICE HTML 원피스 작성 표준 부재 발견. {이름} 직접 관찰 (2026-04-28): "샘플은 다양성을 죽이는 수렴 장치" → 자비스 학습 #10·#11 신규 채택. frontend-design 플러그인 (claude-plugins-official 마켓) 설치 완료 → 자체 미학 가이드 신설은 중복·열위 → 1차 인용 의무 표준화.

### 추가 (✚)

| 자산 | 유형 | 설명 |
|---|---|---|
| `skills/dz-html-oneffice-builder/SKILL.md` (T-02) | Skill | ONEFFICE 원피스 HTML 작성 표준. frontend-design 1차 인용 의무 + ONEFFICE 환경 제약 5축 (dzeditor·단일페이지·꺾쇠·localStorage·5줄 헤더). 4 STEP (frontend-design Read → 제약 검토 → 작성 → 주입). 99 라인 |
| `규칙/프로세스/HTML-원피스-작성-표준.md` (T-01, douzone-forge SSoT) | SSoT | 8 섹션 (목적·의존·환경 제약·필수 CSS·HTML 가공 원칙·작성 절차 4 STEP·CDN 제약·금지·자연 점검·변경 이력). 197 라인 |

### 표준화

- **D-01 (학습 #10)**: SKILL.md 결과물 샘플 박지 말 것 — `<sample>·예시 결과·sample output` grep == 0 의무
- **D-02**: frontend-design 플러그인 1차 인용 의무 — Anthropic 공식 production-grade 미학 가이드 위임
- **D-03**: ONEFFICE 환경 제약만 본 Skill에 박음 (미학·구조는 frontend-design)
- **D-04 (학습 #11)**: SKILL.md 메모리 학습 인용 금지 — 사내 전사 배포 사용자 부재 격차 차단. SSoT .md 인용으로 대체

### 흡수 (T-03)

- `skills/dz-oneffice-writer/SKILL.md` L70~143 "HTML 가공 원칙 + ONEFFICE 전용 필수 CSS" → SSoT (`규칙/프로세스/HTML-원피스-작성-표준.md` §4·§5) 이전
- writer/SKILL.md 잔존: 주입 절차만, 5축 환경 제약은 SSoT 인용 (자비스 ⑥ 정정 채택)
- 줄수: 751 → 717 (34줄 감소, 풀 텍스트 복제 X — 학습 #4)

### 자연 점검 (T-05)

- `참고자료/리포트/PhaseT-skill-sample-audit-20260428.md` 산출
- skills 39건 + commands 46건 = 전수 85건 grep 결과 결과물 샘플 박힘 **0건**
- 자비스 학습 #10 사전 적용 효과 — 강제 변환 불요
- 향후: Phase V 결재 사이클에서 R-07 6축 확장 후보 (식별만)

---

## v0.15.0 (2026-04-27) — Phase Q-2 자동화 인프라

### 배경

Phase Q-1 종착 (구조 SSoT 정착) 직후 자비스 우산 지시서로 진입한 자동화 인프라 5 트랙. Q-1이 정착시킨 폴더 골격·ID 표준 위에 산출물 파일명 강제·폴더 README 표준·명령 4종·deliverables 폐기·트래킹 재설계를 얹어 Beta 사용자 즉시 운영 가능 상태 도달.

### 추가 (✚)

| 자산 | 유형 | 설명 |
|---|---|---|
| `rules/prj-filename-policy.md` (Q-10) | Rule | 산출물 파일명 표준 `YYYYMMDD-{주제}.md` (8자리 강제). 메타 화이트리스트 8종. 32 라인 |
| `hooks/prj-filename-policy.sh` (Q-10) | Hook | PostToolUse Write/Edit. 적용 범위 한정(프로젝트/PRJ-*/01~06_*, Amaranth10/*/history·tasks). 위배 stderr 경고. 38 라인 |
| `hooks/folder-purpose-check.sh` (Q-11) | Hook | PostToolUse. 신규 폴더 _README.md 부재 시 stderr 경고 + dz-folder-audit 안내. 24 라인 |
| `skills/dz-folder-audit/SKILL.md` (Q-11) | Skill | 워크스페이스 폴더 표준 검증 + 부재·placeholder _README 식별 + 5섹션 충족 검사. 정기 점검 리포트 생성. 87 라인 |
| `commands/dz-org-bootstrap.md` (Q-12) | Command | admin 첫 도입 시 1회 — Beta 사용자 부서 + 직속 상위 부서 폴더 신설 (사내 일괄 금지, 멱등성). 75 라인 |
| `commands/dz-org-sync.md` (Q-12) | Command | xlsx 갱신 후 admin 동기화 — 변경 행만 검출, 자동 archive 안 함, {이름} 재확인 의무. 68 라인 |
| `commands/dz-org-archive.md` (Q-12) | Command | 퇴사 인원 처리 — 조직/{...}/{이름_ID}/ → 조직/archived/{이름_ID}/ 이동 (재확인 2회, 민감 정보 분리). 87 라인 |
| `skills/dz-personal-tracking/SKILL.md` (Q-14) | Skill | PT-02 G9 dz-team-tracking 폐기 후 재설계. 본인이 부하 직원 트래킹 노트 작성 (`_개인/팀트래킹/`). 직급 매칭 (xlsx 부서 계층 분석). 109 라인 |

### 변경 (Δ)

| 자산 | 변경 |
|---|---|
| `commands/dz-personal-init.md` (v0.2.0 → v0.3.0) | 4계층 lookup + _index.md 자동 채움 + 직책 체크 시 팀트래킹 자동 신설 (dz-people-index 호출 의존) |

### 폐기 (✗)

| 자산 | 처리 |
|---|---|
| `skills/dz-team-tracking/` (PT-02 G9) | `_archive/skills-dz-team-tracking-Q14/`로 이동. PT-02 G9 12 게이트 무효화. D6 결정 — dz-personal-tracking으로 재설계 |

### 워크스페이스 영향

- `deliverables/` 폐기 (Q-13) — 91 파일 → 1차 골격 분배 (AI전략·보고서 Q-3 이연 임시 보관)
- `team-tracking/` → `_개인/팀트래킹/` (Q-14) — 6 관리자 폴더 이동
- 인용 정정 sed 86 hits (메타 보호 4영역 표준)

### 자비스 학습 #1 적용

- 광역 sed 보호 표준 4영역 — `_archive/`·`*/99_archive/`·진행 중 사이클 메타·`*.bak.*`

## v0.14.0 (2026-04-26) — 공용/개인 경계 신규 영역 (PT-02 ALL PASS)

### 배경

ST Step 1.5 + Step 02-Bfix + Step 3.5 + Step 7 결과를 플러그인 자산으로 내재화.

douzone-forge 워크스페이스 재편으로 다음 결정이 확립됨:
- **공용/개인 경계** (Step 1.5): GitLab 동기 영역(공용) vs 로컬 only 영역(`_개인/`) 명확 구분
- **4계층 조직** (Step 02-Bfix D9): `조직/{본부}/{Unit}/{Cell}/{이름_사번}/` 폴더명 형식
- **활성 9 모듈 sessions** (Step 3.5): `_개인/sessions/{모듈}/` 평탄화 (분류 폴더 common·publishing·sites 제거)
- **team-tracking 6 관리자 폴더** (Step 7 J3): 본부장-{이름} / Unit장-{이름} / Cell리더 4명 ({이름}·{이름}·{이름}·{이름})

PT-02는 위 ST 결과를 **플러그인 자산 4건으로 신규 내재화** — Step 11 Beta(3인) 진입을 위한 사실상 필수 트랙.

PT-00 갭분석 §3.2 v0.14.0 분담 그대로 (G7~G10 4건).

### 추가 (✚)

| 자산 | 유형 | 설명 |
|---|---|---|
| `rules/personal-area-guard.md` (G7) | Rule | `_개인/` 영역 GitLab 동기화 차단 + 사용자 안내 + `.gitignore` 자동 등록 권고. 73 라인 + Hook 강화 후보 메모 (F-PT-Nx12) |
| `skills/dz-people-index/SKILL.md` (G8) | Skill | douzone-forge `_CLAUDE/프로세스/사용자ID-매핑.md` SSoT **참조만** (R5 일관, 데이터 미보유). SBUnit 22명 + 협업 21명 사번/이름/소속/R&R 즉시 조회. 104 라인 |
| `skills/dz-team-tracking/SKILL.md` (G9) | Skill | Step 7 6 관리자 폴더에 부하 직원 트래킹 노트 표준 골격 작성. 2계층 구조 `{관리자}/{대상}/{YYYYMMDD}-{주제}.md` (Q3 (B)). G8 연계로 사번/이름 자동 채움. 143 라인 |
| `commands/dz-personal-init.md` (G10) | Command | 신규 사용자(Beta 3인 후) 첫 도입 시 `_개인/` 골격 1회 자동 생성. 활성 9 모듈 `_개인/sessions/{모듈}/` 빈 폴더 (`_current.md`는 자연 신설, Q4 (A)) + `.gitignore` 자동 등록. 멱등성 보장. 125 라인 |

### 사용 사례

- **TASK 담당자 자동 채움** (G8): 사번 `{사번}` → `{이름} ({사번}) — 대리 / SB설계Cell 리더`
- **PRJ PM 자동 조회** (G8 + module-Cell 매핑): 모듈 `법무관리(LTE)` → PM `{이름} ({사번})`
- **검토안 작성자 메타** (G8): `/dz-triage` 산출물 frontmatter 자동 채움
- **Cell 리더 주간 트래킹** (G9): `team-tracking/Cell리더-{이름}_{사번}/{이름}_{사번}/20260429-주간트래킹.md` 자동 생성
- **Unit장의 4 Cell 리더 점검** (G9): `team-tracking/Unit장-{이름}_{사번}/{이름}_{사번}/20260430-1on1.md`
- **신규 사용자 환경 셋업** (G10): `/dz-personal-init` 1회 명령 → `_개인/` 골격 + 9 모듈 sessions/ + .gitignore
- **개인영역 git 가드** (G7): `_개인/` 하위 파일을 git add 시도 시 차단 + 사용자 안내

### 호환성

- 기존 commands·skills·hooks·rules 변경 0 — 본 PT-02는 신규 자산 4건만 추가
- v0.13.x 사용자 → v0.14.0 무중단 승격 가능
- **사번 SSoT는 douzone-forge 측** — 플러그인은 참조만 (R5 일관). 다른 워크스페이스에서 G8/G9 호출 시 동일 워크스페이스 마운트 필요
- Hook 5종·Rule 5종(기존) 변경 0 — Rule 1종 (`personal-area-guard`) 신규로 6종으로 확장
- v0.13.0 (forge-체계 정합화) + v0.13.1 (마켓플레이스 정합) 변천사 보존

### 마이그레이션

**v0.13.1 → v0.14.0 ⑤단계 사용자 2줄** (PT-01.5와 차이 — name 변경 없음, 첫 정상 운영):

```bash
# 1) 마켓플레이스 인덱스 갱신 (이름 변경 없음, update만)
claude plugin marketplace update douzone-forge-marketplace

# 2) v0.14.0 install
claude plugin install douzone-forge@douzone-forge-marketplace

# 검증
ls ~/.claude/plugins/cache/douzone-forge-marketplace/douzone-forge/
# v0.14.0 디렉토리 확인
```

PT-01·PT-01.5 대비 **`marketplace remove + add` 단계 불요** — PT-01.5 정합화 후 첫 정상 운영.

### PT 누적 게이트

PT-00 (1) + PT-01 (10) + PT-01.5 (9) + **PT-02 (12)** = **32/32**. ST 누적 112/112 유지.

### 자산 카운트 (PT-02 후)

| 자산종류 | PT-01.5 후 | PT-02 후 |
|----------|----------|---------|
| commands | 42 | **43** (+1 dz-personal-init) |
| skills | 29 | **31** (+2 dz-people-index, dz-team-tracking) |
| hooks | 5 | 5 (변경 0) |
| rules | 5 | **6** (+1 personal-area-guard) |
| **총** | 81 | **85** (+4) |

### Step 11 Beta 진입 의미

본 v0.14.0은 **Step 11 Beta(3인) 진입을 위한 사실상 필수 트랙**. 4 신규 자산이 누락되면 다음 시나리오 미작동:
- 신규 사용자가 `_개인/` 골격을 수동으로 만들어야 함 (G10 부재)
- 사번 → 이름 자동 변환 부재 (G8 부재) → TASK·PRJ 담당자 메타 수동 입력
- 관리자 트래킹 노트 표준 골격 부재 (G9 부재) → 일관성 ↓
- `_개인/` 영역 git 누출 위험 (G7 부재)

PT-03 (정합 검증)에서 RT-7~RT-10 4 시나리오 회귀 후 ST Step 11.5 (통합 정합성 검토) 진입 권고.

---

## v0.13.1 (2026-04-26) — 마켓플레이스 정합화 patch (PT-01.5 ALL PASS)

### 배경

PT-01 ⑤단계 사용자 환경 동기화에서 다음 5건의 마켓플레이스 트랜잭션 결함 발견:
- **F-PT-Nx5**: 옛 경로(`douzone-forge/_플러그인/`, 2026-04-20 제거) 마켓플레이스 등록 잔존 → `claude plugin marketplace update` 시 ENOENT
- **F-PT-Nx6**: `build.sh` `||` 핸들링이 `claude plugin ...` 비-0 종료를 무력화 (set -e 우회) → 사일런트 실패
- **F-PT-Nx7**: CHANGELOG v0.13.0 마이그레이션 섹션이 옛 경로 정정 절차 누락
- **F-PT-Nx8**: `marketplace.json` `name` = `amaranth10-forge-marketplace` ↔ 가이드 다수가 `douzone-forge-marketplace` 가정 → install 시 "Plugin not found"
- **F-PT-Nx9**: 두 이름 중 통일 방향 미결정 → Cowork 권고 `douzone-forge-marketplace` 채택

본 v0.13.1 patch는 기능 변경 0 + 트랜잭션 정합화만. PT-02(v0.14.0 신규) 진입 전 마켓플레이스를 깨끗하게 정렬.

### 변경 (✎)

| 자산 | 변경 전 | 변경 후 |
|---|---|---|
| `marketplace.json` `name` | `amaranth10-forge-marketplace` | **`douzone-forge-marketplace`** |
| `build.sh` ENOENT 검증 | `claude plugin ... \|\| echo "..."` (set -e 무력화) | `OUTPUT=$(...)` + grep `Failed\|not found\|ENOENT\|error:\|✘` + `exit 1` |
| `build.sh` SKIP_INSTALL | (없음) | `SKIP_INSTALL=1` 환경변수 — marketplace update/install 단계 건너뛰기 |
| `_plugin/CLAUDE.md` 함정 #6 | (없음) | 신규 — 옛 경로 ENOENT 진단·복구 절차 (≥ 30 라인) |
| `_plugin/CLAUDE.md` 함정 #7 | 진단 위치 (구 #6) | 진단 위치 (이름만 변경 — #6 → #7) |

### 영향 파일

- `_plugin/amaranth10-forge-marketplace/.claude-plugin/marketplace.json` — `name` 필드 1줄
- `_plugin/douzone-forge/build.sh` — ENOENT 검증 + SKIP_INSTALL 환경변수 (~25 라인 추가/수정)
- `_plugin/CLAUDE.md` — 함정 #6 신규 (37 라인) + 기존 #6 → #7 (2 라인)
- `_plugin/douzone-forge/.claude-plugin/plugin.json` — `version` 0.13.0 → 0.13.1
- 동시 PR `douzone-forge/CLAUDE.md` L25 — `v0.13.0` → `v0.13.1`

### 마이그레이션

**옛 경로/이름 마켓플레이스 등록 잔존 사용자용 4줄 절차** (PT-01 ⑤단계 학습 + R1 정밀화):

```bash
# 1) 옛 등록 제거 — PT-01 ⑤단계에서 사용자가 등록한 이름
claude plugin marketplace remove amaranth10-forge-marketplace

# 2) 새 이름으로 재등록 — marketplace.json `name` 변경됨 (PT-01.5 AC-1)
claude plugin marketplace add /Users/{ID}/Workspace/_plugin/amaranth10-forge-marketplace
# (디렉토리 경로는 그대로지만 marketplace.json `name`이 douzone-forge-marketplace로 변경됨 → 자동 새 이름으로 등록)

# 3) 정합된 이름으로 install
claude plugin install douzone-forge@douzone-forge-marketplace

# 4) 검증
ls ~/.claude/plugins/cache/douzone-forge-marketplace/douzone-forge/
# v0.13.1 디렉토리 확인
```

> ⚠️ **R1 핵심**: `marketplace remove`의 이름은 **현재 사용자 측에 등록된 이름** (`amaranth10-forge-marketplace`, PT-01 ⑤단계 add 결과). marketplace.json `name` 변경 후 add 시 자동으로 새 이름(`douzone-forge-marketplace`)으로 등록.

### 호환성

- 플러그인 자산(commands·skills·hooks·rules) 변경 0 — 기능 동작 무영향
- v0.13.0 디렉토리(`_plugin/amaranth10-forge-marketplace/douzone-forge-v0.13.0/`) 보존 (변천사 패턴)
- GitHub repo 이름(`amaranth10-forge-marketplace`) + 로컬 디렉토리(`_plugin/amaranth10-forge-marketplace/`) 그대로 (외부 명명, 본 PT 무관)
- v0.13.0 이미 사용자에게 배포된 환경 → 위 4줄 마이그레이션 1회 실행 필요

### PT-01.5 검증 게이트 (G1~G9)

- G1 marketplace.json name 정합 ✅ / G2 가이드 cascading ✅ / G3 함정 #6 ≥ 15 라인 ✅ (37 라인) / G4 build.sh ENOENT 검증 로직 ✅ / G5 plugin.json 0.13.1 ✅ / G6 CHANGELOG v0.13.1 ≥ 30 + 마이그레이션 ≥ 8 ✅ / G7 SKIP_INSTALL=1 build.sh --deploy 종료 0 ✅ / G8 dist v0.13.1.plugin ✅ / **G9 사용자 환경 동기화 → ⑤단계 이연**

---

## v0.13.0 (2026-04-26) — 경로·용어 정합화 + Step 10 영문 골격 (PT-01 ALL PASS)

### 배경

douzone-forge 워크스페이스 재편 ST Step 1~10 (2026-04-23~26) 으로 한글 폴더가 영문 골격으로 일괄 이관됨:
- `_projects/` → `projects/` (Step 4·5)
- `_참조자료/` → `reference/` (Step 10b)
- `_업무산출물/` → `deliverables/` (Step 10b, forge-체계는 Step 10a 별도)
- `_reports/` + `_repo-check/` → `meta/{reports,repo-check}/` (Step 10b)
- 모듈 한글 폴더 → `modules/{한글}({모듈코드})/` (Step 3)
- `{모듈}/sessions/` → `_개인/sessions/{모듈}/` (Step 3.5)
- `modules/총무관리(GA)/` → `modules/_archive/총무관리(GA)/` (Step 10c 운영 종료)

플러그인 v0.12.2 자산 (commands 42 + skills 29 + hooks 5 + rules 5 + 메타 2 = 83 자산) 의 한글 경로 참조를 영문 골격에 일괄 정합화한다. PT-01 (Plugin Track 1단계) 첫 ④단계 빌드+배포.

PT-00 갭분석표 결과: 정합화 48건 + archive 1건 + no-change 35건 (Hook 5종 + Rule 3종 + commands 21 + skills 5 + 메타 1 영향 0).

### 변경 (✎)

| 자산종류 | 자산 수 | 변경 전 | 변경 후 |
|---|---|---|---|
| commands | 21 정합화 | `_projects/`·`_참조자료/`·`_업무산출물/`·`_reports/`·`_repo-check/`·`{모듈}/`·`{모듈}/sessions/` | `projects/`·`reference/`·`deliverables/`·`meta/{reports,repo-check}/`·`modules/{한글}({모듈코드})/`·`_개인/sessions/{모듈}/` |
| skills | 24 정합화 (대형 4건: dz-project-tracker 18 / dz-git-daily 15 / dz-session-protocol 15 / dz-jira-query 12) | 동일 | 동일 |
| rules (2종) | `markdown-link-policy.md` (6) + `prj-code-naming.md` (3) | 정책 본문 의도 보존 + 예시 라인 한글 | 본문 의도 보존 + 예시 라인 영문 (P9) |
| 메타 | `README.md` (7) | `{모듈}/sessions/` 등 한글 | 영문 |
| archive | `plugin-upgrade-plan.md` (v0.5 잔존) | `_plugin/douzone-forge/` | `_plugin/douzone-forge/_archive/plugin-upgrade-plan-v0.5.md` |

### 영향 파일

- `commands/` 21 자산 (dz-add-project, dz-confirm, dz-decision, dz-projects, dz-status, dz-load-context, dz-init-project 등)
- `skills/` 24 자산 (dz-project-tracker·dz-git-daily·dz-session-protocol·dz-jira-query [대형 4건] + dz-context-manager·dz-status-reporter 등)
- `rules/markdown-link-policy.md` + `rules/prj-code-naming.md` (의도 보존)
- `README.md` (PLUGIN_ROOT)
- `_archive/plugin-upgrade-plan-v0.5.md` (신규 archive)

### 마이그레이션

기존 v0.12.x 환경 → v0.13.0 무중단 승격 가능:
- 한글 폴더 참조는 본 v0.13.0부터 영문 골격으로 단일 매핑 (Q1 (A) alias 미도입)
- `_개인/`은 GitLab 미동기 영역 — 사용자 로컬에 없으면 자연 신설
- `modules/총무관리(GA)/` 이전 사용자는 `modules/_archive/총무관리(GA)/` 참조 (Step 10c 운영 종료, ARCHIVED.md 4섹션 참조)
- douzone-forge `CLAUDE.md` L25·L917 v0.13.0 표기 갱신 동시 PR

### 호환성

- Hook 5종 본체 변경 0 (한글 의존 0 사전 검증 — PT-00 R3 해소)
- Rule 3종 (`coding-standards`·`enum-consistency`·`verification`) 본체 변경 0
- v0.12.0 추가 자산 (`.forge/` 브리지·3-way 크로스 체크·유지보수 4컬럼) 변천사 보존
- 한글 alias 미도입 — Beta 3인은 본 PT 완료 후 새 환경 시작 (영향 0)

### PT-00·PT-01 연계

- PT-00 갭분석표 §2 84 자산 매트릭스 SSoT
- PT-01.G1~G10 게이트 ALL PASS (정합화 48 / archive 1 / Rule 의도 보존 / version 0.13.0 / CHANGELOG ≥ 50라인 / build.sh 종료 0 / dist zip / CLI 캐시 / douzone CLAUDE.md / RT-1~RT-6 6/6)
- ④단계 §X 빌드 검증 행 첫 발화 (PT 신규 표준)

---

## v0.12.2 (2026-04-22) — PRJ 코드 표기 규칙 내재화 (Rule + Hook)

### 배경
개인 메모리(`feedback_project_code_display.md`)에 "PRJ 코드 단독 표기 금지" 규칙이
기록되어 있었으나 새 세션마다 인덱스 제목만 로드되어 엄격성이 희석됨.
2026-04-22 기술위원회 3트랙 재편 작업(PRJ-2026-013/014/020/021) 중 단독 표기가
대시보드·PRJ 헤더·채팅 답변에 반복 누출되어 사용자 지적을 받음. 플러그인
레이어로 근본 보강한다.

### 추가 (+)

| 자산 | 유형 | 설명 |
|---|---|---|
| `rules/prj-code-naming.md` | Rule | PRJ 코드 단독 표기 금지 규정 · 허용 패턴 3종 · 판정 기준 · 예외 없음(채팅 포함) |
| `hooks/prj-code-naming-check.sh` | Hook (PostToolUse Write/Edit) | 마크다운 편집 후 PRJ 코드 등장 라인에 한글 프로젝트명 미동반 시 stderr 경고 (block 안 함) |

### 변경 (✎)

| 자산 | 변경 |
|---|---|
| `.claude-plugin/plugin.json` | PostToolUse 에 `prj-code-naming-check.sh` 등록 (4번째 Hook) |

### 판정 로직 (perl 정밀 매치)

PRJ 코드 패턴: `PRJ-\d{4}(-[A-Z]+)?-\d+`

각 출현 위치별 판정:
- ✅ 직전 문자가 `(` → `프로젝트명(PRJ-...)` 형태 (PASS)
- ✅ 링크 URL 내부(`](` ~ `)`) → 경로/파일명 (PASS)
- ✅ 마크다운 링크 표시텍스트에 한글 또는 영문 단어 3자+ 포함 → `[Douzone AI Radar](...)` (PASS)
- ✅ 코드블록 내부 → 무시
- ❌ 그 외 단독 출현 → ⚠️ 경고

예시:
- ✅ `Douzone AI Radar(PRJ-2026-020)` — 괄호 앞 프로젝트명
- ✅ `[Douzone AI Radar(PRJ-2026-020)](PRJ-2026-020_Douzone-AI-Radar.md)` — 링크 표시텍스트 + URL
- ✅ `가온(PRJ-2025-001) 진행 중` — 괄호 앞 한글
- ❌ `PRJ-2026-013 연계 포인트` — 단독 출현
- ❌ `참고: PRJ-2026-LTE-001 을 확인` — 단독 출현

### 호환성
- 기존 Hook/Rule 4개 유지 · 신규 추가만
- block 하지 않고 경고만 출력 → 기존 워크플로우 무영향

### 3중 방어 체계
1. **CLAUDE.md** (douzone-forge) — 세션 시작 강제 로드, 채팅 답변까지 커버
2. **Rule** (plugin) — Claude 작업 시 규정 참조
3. **Hook** (plugin) — 파일 편집 직후 자동 스캔 경고

### 마이그레이션
- `build.sh --deploy` 재배포 → CoWork 앱에서 플러그인 업데이트 클릭
- 재배포 없이도 소스 경로에서 바로 동작

---

## v0.12.1 (2026-04-20) — 일일보고 캐시 경로 정정

### 배경
v0.12.0 는 일일보고 원본캐시를 `douzone-forge/업무관리/일일보고/YYYY-MM/` 에
저장했으나, `업무관리/` 는 Amaranth 10 **KISS 모듈 폴더**이고 SBUnit 전사 자산은
`_` 프리픽스 폴더(`_업무산출물/`, `_참조자료/`, `_projects/` 등)를 사용하는
규칙과 충돌했다. 모듈 폴더 오염을 제거하고 SBUnit 보고서 자산으로 정상화한다.

### 변경 (✎)

| 자산 | 변경 전 | 변경 후 |
|---|---|---|
| 일일보고 원본캐시 경로 | `douzone-forge/업무관리/일일보고/YYYY-MM/` | `douzone-forge/_업무산출물/보고서/일일보고/원본캐시/YYYY-MM/` |
| PM 분석 경로 | _(암묵적, 없음)_ | `douzone-forge/_업무산출물/보고서/일일보고/YYYYMMDD-SBUnit-일일보고-분석.md` |
| 주간보고 구조 | `주간업무정리/` + `주간회의/` (2축 혼재) | `주간보고/` 단일 (파일명 `YYYYMMDD-주간보고-W##[-W##]-{주제}.{ext}`) |

### 영향 파일

- `skills/dz-daily-digest/SKILL.md` — 캐시 경로 · tree 다이어그램 재작성
- `skills/dz-git-daily/SKILL.md` — frontmatter 역검색 경로
- `commands/dz-daily-digest.md` — 저장 경로 · 디렉토리 권한 안내
- `commands/dz-triage-sync.md` — 일일보고 역검색 경로
- `commands/dz-triage-status.md` — 3-way 조인 소스 경로

### 마이그레이션
기존 `douzone-forge/업무관리/일일보고/YYYY-MM/` 아래 파일은 수동으로
`_업무산출물/보고서/일일보고/원본캐시/YYYY-MM/` 으로 이동한 뒤 빈 상위 폴더
(`업무관리/일일보고/`)를 제거한다. v0.12.1 부터 스킬 출력은 신규 경로 기준.

### 호환성
- Hook/Rule/Permission 변경 없음 — 경로 문자열만 정정
- v0.12.0 이미 배포 환경은 `/plugin install` 로 무중단 승격 가능

---

## v0.12.0 (2026-04-20) — 3-way 크로스 체크 + `.forge/` 브리지

### 배경
v0.11.0 에서 유지보수 검토안 표준이 수립되었으나 검토안·소스 커밋·일일보고 3자가
분리 운용되어 "수용 후 실제 개발 진행 여부"·"무허가 커밋"·"지연된 건" 추적이
PM 수동 감사에 의존했다. 본 릴리즈로 3-way 크로스 체크 + 자동 상태 전이 +
소스 레포 `.forge/` 경량 복제를 도입한다.

### 추가 (+) — 스킬 3

| 스킬 | 설명 |
|---|---|
| `dz-jira-classifier` | JIRA 프리픽스 → 트랙(유지보수/고도화/검수/미분류) 단일 원천 라우팅 |
| `dz-forge-bridge` | 진행 중 검토안·고도화를 소스 레포 `.forge/` 에 경량 복제 + `.gitignore` 가드 |
| `dz-daily-digest` | ONEFFICE 일일보고 → `douzone-forge/_업무산출물/보고서/일일보고/원본캐시/YYYY-MM/` 로컬 캐싱 |

### 추가 (+) — 커맨드 4

| 커맨드 | 설명 |
|---|---|
| `/dz-daily-digest` | 일일보고 수집 실행 |
| `/dz-triage-status` | 3-way 크로스 체크 리포트 + 자동 상태 전이 + `.forge/` 주입 |
| `/dz-triage-sync` | 수동 동기화 (브랜치 재스캔으로 상태·진행 로그 재작성) |
| `/dz-triage-close` | 처리완료/기각/복구 수동 전이 |

### 변경 (✎)

| 자산 | 변경 |
|---|---|
| `dz-git-daily` SKILL (v0.2.0) | STEP 4~8 확장: JIRA 키 추출·3-way 조인·자동 전이·이상 리포트·`.forge/` 주입 |
| `/dz-git-daily` 커맨드 | `--no-triage`, `--no-bridge` 옵션 추가 |
| `/dz-triage` 커맨드 | `--auto-draft` 옵션 (케이스 6 자동 초안용) |
| `dz-maintenance-triage` SKILL (v0.2.0) | 상태 머신·브랜치 매핑·`.forge` 연계 섹션 추가 |
| `triage-review.md` 템플릿 | frontmatter(`status`/`jira_key`/`module`) + `## 📊 진행 로그` 테이블 |
| `lite-review.md` 템플릿 (신규) | `.forge/` 경량 복제본 (~50줄) |
| `.claude-plugin/plugin.json` | version 0.11.0 → 0.12.0 |

### 핵심 설계

**8케이스 매트릭스** — 검토안·커밋·일일보고 3축 조합별 진단·자동 액션 정의.

**상태 머신**
```
수용 → 개발중 → 설계검수 → QA → 배포완료 → 처리완료
        (자동·브랜치 기반)           (수동)
```
- develop/devqa/sqa/master 도달 기준 자동 전이
- 배포완료→처리완료는 고객사 회신 필요 → 수동만 (`/dz-triage-close`)

**자동 액션 규칙** (승인된 7가지 결정)
1. 상태 전이: 수용→개발중→설계검수→QA→배포완료 자동, 처리완료 수동
2. 지연 경고: 수용 후 7일 무커밋
3. 케이스 6(커밋만 있음)만 자동 초안, 케이스 5(커밋+보고)는 알림만
4. 일일보고 ONEFFICE 유지 + 로컬 캐싱
5. `.forge/` 주입 범위: 진행 중만 (완료·기각 제외)
6. JIRA 분류 실패 시 경고만, 자동 라우팅 금지
7. 고도화 자동 스텁 생성하되 `_dashboard.md` 등록은 사용자 승인

### `.forge/` 브리지

소스 레포 루트에 경량 복제 주입:
```
{레포}/.forge/
├── maintenance/   ← 진행 중 검토안 ~50줄 복제
└── enhancements/  ← 진행 중 고도화 스펙
```
- `.gitignore` 에 `.forge/` 자동 추가 (커밋 방지)
- 완료·기각 건은 자동 삭제 (원본은 douzone-forge 에 보존)

### 라우팅 테이블 (dz-jira-classifier 단일 원천)

| 프리픽스 | 트랙 | 저장 위치 |
|---|---|---|
| CSA10/UBA/UAC/EO | 유지보수 | `{모듈}/유지보수/YYYYMMDD-{KEY}-검토안.md` |
| KLAGOP1/A10D/UCAIMP | 고도화 | `{모듈}/tasks/enhancements/` + `_projects/PRJ-*.md` |
| BC10 | 검수 | `{모듈}/tasks/검수/` |
| 기타 | 미분류 | `_reports/unclassified-jira.md` |

### 연계

- `dz-git-daily` 가 3-way 조인의 커밋 축
- `dz-daily-digest` 가 일일보고 축
- `dz-maintenance-triage` 가 검토안 축
- `dz-forge-bridge` 가 3축 교차 결과를 소스 레포에 전파

---

## v0.11.0 (2026-04-20) — 유지보수 접수 검토 표준화

### 배경
CSA10-44921/44945 분석 중 "접수 수용여부 판단"과 "수정안 검토"가 PM 재량에만 의존
되어 표준 없이 진행되던 문제 확인. 유지보수 6개 프로젝트(CSA10/UBA/UAC/EO/BC10 +
고도화 이관처 A10D/UCAIMP/KLAGOP1) 간 라우팅 규칙도 문서화 부재.

### 추가 (+)

| 자산 | 설명 |
|------|------|
| 스킬 `dz-maintenance-triage` | 오류/개선 판정 체크리스트 + 2~3단계 검토 워크플로우 + 이관 규칙 |
| 템플릿 `triage-review.md` | 접수개요 / 수용여부 판단 / 수정안 / 이관 판단 / 고객사 회신 / 검토 서명 6섹션 |
| 커맨드 `/dz-triage` | JIRA 키 입력 → `dz-jira` 조회 + 소스 연계 분석 + 검토안 저장 + 인덱스 갱신 |

### 핵심 설계

**오류 4요소 체크리스트**: 오류 명백성 / 재현성 / 타 고객 영향 / 유사 이력 → 판정 매트릭스

**개선 5요소 체크리스트**: 전 고객 유익성 / 패키지 수용성 / 접수 빈도 / 패키지 영향도 / 대체 수단 → 판정 매트릭스

**이관 규칙**
- CSA10 (A10) → **A10D** (고도화) 또는 **KLAGOP1** (신규·대규모)
- UBA/UAC (Alpha) → **UCAIMP** (Alpha 고도화), 단 Alpha 2017 단종 예정으로 이관 지양
- EO (OmniEsol) → 미정, 사내 합의 후 처리

### 산출물 저장 경로

- 검토안: `{모듈}/유지보수/{YYYYMMDD}-{JIRA키}-검토안.md`
- 인덱스: `{모듈}/유지보수/_index.md`

### 안전 장치

- JIRA 상태·댓글·티켓 생성 **자동 금지** — 검토안은 의사결정 지원 산출물에 한정
- 원인 단정 금지 — 신뢰도 표기 필수 (매우 높음/높음/중간/낮음)
- 고객사 회신은 초안만 생성, 발송은 운영Unit 수동

### 연계

- `dz-jira-query` — JIRA 조회 위임
- `dz-git-daily` — 과거 해결 커밋 검색
- `dz-task-manager` — `{모듈}/tasks/` 계층 관리

---

## v0.10.0 (2026-04-20) — 하네스 4계층 복원: Rules + Hooks

### 배경
2026-04-20 YouTube 짐코딩 영상 계기 심층조사
([`_참조자료/프로세스/20260420-claudecode-하네스4계층-심층조사.md`](../../douzone-forge/_참조자료/프로세스/20260420-claudecode-하네스4계층-심층조사.md))
결과, 하네스는 **3계층이 아닌 4계층**(CLAUDE.md·Rules·Permissions·Hooks)이며 v0.4.0 이후 Rules·Hooks가
실수로 번들에서 누락되어 있었음을 확인. 본 릴리즈로 복원 + 현대화 + 신규 Rule 1종 추가.

### 복원된 Rules (+4)
| Rule | paths scope | 설명 |
|------|-------------|------|
| `verification` | Java/TS/Gradle/SQL | 검증 없이 완료 선언 금지 (fresh evidence 필수) |
| `coding-standards` | Java/TS/JS | Surgical Changes, Small Functions, Immutability, A10 기술스택 |
| `enum-consistency` | Java/TS + Flyway SQL + OpenAPI YAML | DDL↔Entity↔DTO↔FE↔OpenAPI 5레이어 Enum 동일 |
| `markdown-link-policy` (신규) | **/*.md | douzone-forge 상대링크 + URL 인코딩 필수 |

v0.4.0 대비 개선: 각 Rule에 `paths:` 프런트매터 추가 → 해당 파일 작업 시에만 로드되어
CLAUDE.md 토큰 절약(맥락 오염 감소).

### 복원된 Hooks (+4)
| Hook | Event | Matcher | 정책 |
|------|-------|---------|------|
| `db-migration-guard` | **PreToolUse** | Write/Edit/Bash | **차단** (exit 2 + JSON decision=block) |
| `code-quality-reminder` | PostToolUse | Write/Edit | 알림 (Java/TS 체크리스트) |
| `security-auto-trigger` | PostToolUse | Write/Edit | 알림 (Security/JWT/Auth 파일 감지) |
| `build-verify-reminder` | PostToolUse | Write/Edit | 알림 (5회마다) |

v0.4.0 대비 개선:
- `db-migration-guard` 현대화 — 환경변수(`CLAUDE_BASH_COMMAND`) 대신 **stdin JSON** + **exit 2 + JSON stdout**
  으로 Claude Code 현행 hook 프로토콜 반영. `Bash`뿐 아니라 `Write`/`Edit`까지 커버.
- Flyway 경로 패턴 확장 (`db/migration`, `src/main/resources/db/migration`, `flyway`)
- 단위 동작 검증 완료 (DROP TABLE → block / 안전 ALTER → pass / Bash TRUNCATE → block)

### plugin.json 변경
- `hooks` 필드 복원 (`${CLAUDE_PLUGIN_ROOT}` 변수 사용)
- 설명 업데이트: "하네스 4계층 자가진화 체계" 명시

### build.sh 변경
- 번들 zip에 `hooks/`, `rules/` 디렉토리 조건부 포함 (v0.5.0 회귀 방지)

### v0.5.0 회귀 원인 (후행 기록)
v0.4.0 → v0.5.0 릴리즈 시 프로젝트 포트폴리오 기능 추가에 집중하며 `hooks/`, `rules/` 디렉토리를
`build.sh`에서 명시하지 않아 번들에서 탈락. 2026-04-20 심층조사 전까지 문서(`CLAUDE.md`)에는 활성
상태로 남아 있어 **문서-현실 갭**이 5개월간 유지됨. 금번 릴리즈로 해소.

### 후속 로드맵 (v0.11.0~)
- **v0.11.0** Forge 전용 hooks 5종 (`session-checkpoint`, `context-cascade-checker`, `markdown-link-validator`, `prj-progress-sync`, `jira-key-reminder`)
- **v0.12.0** CLAUDE.md 다이어트 (700 → 400줄), compliance 측정 대시보드
- **v0.13.0** `dz-harness-evolver` 스킬 + `/dz-evolve*` 커맨드 (자가진화 엔진)
- **v1.0.0** 자동 생성 Rules/Skills 성과 리포트 + 외부 릴리즈

### 상세 계획
- [`_참조자료/프로세스/20260420-하네스-3계층-적용계획.md`](../../douzone-forge/_참조자료/프로세스/20260420-하네스-3계층-적용계획.md)
- [`_참조자료/프로세스/20260420-claudecode-하네스4계층-심층조사.md`](../../douzone-forge/_참조자료/프로세스/20260420-claudecode-하네스4계층-심층조사.md)
- [`PRJ-2026-014_Amaranth10-Claude-Forge-구축.md`](../../douzone-forge/_projects/PRJ-2026-014_Amaranth10-Claude-Forge-구축.md)

---

## v0.9.0 (2026-04-19) — 비대칭 매핑 + 스코어링 엔진 실구현

### 배경
"PRJ 코드는 douzone-forge에서만 관리되며 개발자는 유지보수 JIRA 키만 남기고 프로젝트 커밋은 프리픽스를 남기지 않는다"는 현실 반영. v0.8.x의 prefix 기반 결정적 매칭은 유지보수에만 유효했으며, 프로젝트 커밋은 **추론 기반 매칭**이 필요함.

### 1) 비대칭 매핑 체계
- 커밋 규약 v2 (`깃-커밋-메시지-규약.md` §2): 유지보수(JIRA 필수) / 프로젝트(prefix 권장이되 강제 아님) 비대칭 분리
- **JIRA 프로젝트 코드 체계 확정 (2026-04-19)**:
  - 유지보수 4종: `CSA10`(A10) / `UBA`(Alpha) / `UAC`(Alpha Cloud) / `EO`(OmniEsol) → 결정적 분기
  - 프로젝트 3종: `KLAGOP1`(A10 통합) / `UCAIMP`(Alpha 고도화) / `A10D`(A10 고도화) → +50점 강신호
- PRJ 12건에 `01.E 연계 키` 섹션 추가

### 2) 스코어링 엔진 실구현 (dz-git-daily SKILL.md)
- **STEP 1** 결정적 매칭 → **STEP 2** 6신호 스코어링 → **STEP 3** 임계 분류(≥70 자동 / 40~69 큐 / <40 미태깅)
- 6신호: JIRA키(+50) · 경로(+40/+20) · 담당자+기간(+30/+10) · 주간보고(+30, v0.9.1) · 키워드(+20) · 브랜치(+10)
- 승인 큐 파일: `_projects/_mapping-queue.md` (매 실행 덮어쓰기)
- 학습 이력: `_projects/_mapping-history.md` (결정값 `auto`/`confirm`/`confirm-override`/`reject`/`reject-maint` 누적)

### 3) PM 승인 큐 커맨드 (신규)
- `/dz-confirm N [PRJ-ID]` — 추정 승인 or 다른 PRJ 수동 귀속
- `/dz-confirm all-high` — 60점 이상 일괄 승인
- `/dz-reject N [--maint [JIRA키]]` — 기각(유지보수 이동 or 미태깅 유지)

### 4) JIRA 스킬 보강 (dz-jira-query)
- 프로젝트 코드 체계 표 반영
- 담당자 JIRA ID: **조직구조.md 단일 원천 참조 방식** 채택 (중복 표 제거)
- 기존 추정 정정: `{ID}`={이름}(not {이름}), `{ID}`={이름}

### 드라이런 검증
- `skills/dz-git-daily/DRYRUN-20260417.md` — 게시판 샘플 4건
- v0.8.1 미태깅 75% → **v0.9.0 미태깅 0%** (자동 25% / 유지보수 25% / 승인 대기 50%)

### 마이그레이션
- 기존 사용자: 조치 불필요. `/dz-git-daily` 실행 시 자동 적용
- 개발자: 유지보수 커밋에 JIRA 키(CSA10 등) 필수. 프로젝트 커밋은 자유
- PM: 실행 후 `_mapping-queue.md` → `/dz-confirm`/`/dz-reject` 처리

### 후속 로드맵
- **v0.9.1** 주간보고 자가신고 파서 (+30 신호 활성화)
- **v0.9.2** 학습 피드백 루프 (3회 override → 연계 키 자동 제안, 2회 reject → 감점)
- **v1.0.0** GitLab webhook 실시간 분석

---

## v0.8.1 (2026-04-18)

### `dz-git-daily` 규약 보강 — 유지보수 분기 룰

초기 dry-run 결과 미태깅 100% + {이름} `2682f550` 건(JIRA CSA10-40261)을
계기로 "유지보수 vs 프로젝트" 분류 룰을 명문화.

- `[MAINT]` / `[MAINT/CSA번호]` 프리픽스 추가 → 모듈 `history/_timeline.md` "유지보수 로그" 누적 테이블에 기록, PRJ 파일 미건드림
- 휴리스틱: JIRA CSA 티켓·운영성 키워드·유지보수 라인 담당자 → ⚠️ 유지보수 후보 라벨
- 규약 문서 보강: `_참조자료/프로세스/깃-커밋-메시지-규약.md` 3.4 "유지보수 vs 프로젝트 판단 기준"
- 스킬 파싱·출력 로직에 유지보수 분기 추가

---

## v0.8.0 (2026-04-18)

### `dz-git-daily` 스킬 + `/dz-git-daily` 커맨드 추가

Workspace_a10(소스) ↔ douzone-forge(기획·설계) 맥락 연계 자동화 스킬.
공통 식별자 `[PRJ-NNNN/TASK-CODE]`를 축으로 일일 git 커밋을 수집하여
PRJ 포트폴리오 `03. 상세 진행현황`과 모듈 `history/_timeline.md`에 자동 반영.
미태깅 커밋은 경고 리스트로 분리 보고(멱등성 보장, 추측 반영 금지).

- 스킬: `skills/dz-git-daily/SKILL.md`
- 커맨드: `commands/dz-git-daily.md`
- 지원 옵션: `--since`, `--weekly`, `--module`, `--repos`, `--dry-run`, `--include-personal`
- 보조 문서(douzone-forge): `_참조자료/프로세스/깃-커밋-메시지-규약.md` (팀 공지용)

**배경**: 2026-04-18 연계 체계 감사 결과 25칸 매트릭스 중 "TASK↔git" 고리가
5/5 전면 미구축으로 드러남. 이 스킬이 해당 고리를 자동화하고, 검수시나리오 ↔ 소스,
실시간 history 반영 등 후속 연계의 기초가 됨.

---

## v0.7.0 (2026-04-18)

### `dz-jira-query` 스킬 + `/dz-jira` 커맨드 추가

PRJ-2026-012 JIRA 연동 PoC (`amaranth10-jira-collector`, {이름} 책임 배포 2026-04-17)
를 래핑한 조회 전용 스킬. Claude 세션 중 애드혹 JQL, 8종 프리셋, 일일 배치 결과
로드를 지원한다. 정식 JIRA MCP 전환(05/08 기획-15 이후) 전까지의 실증 단계.

- 스킬: `skills/dz-jira-query/` (SKILL.md + examples 3종 + lib/jira-wrapper.sh)
- 커맨드: `commands/dz-jira.md`
- 6가지 모드: default / 프리셋 / `--list` / `--jql` / `--read` / `--module` / `--ping`
- 조회 전용 (이슈 생성·수정·코멘트 금지), `.env` 비공개, 한글 JQL 필드 쌍따옴표 선검증

---

## v0.6.2 (2026-04-17)

### `dz-oneffice-comment` 스킬 + `/dz-post-comment` 커맨드 추가

ONEFFICE 문서에 멘션(@이름) 포함 댓글을 자동 게시하는 스킬. 멘션 자동완성 팝업이
신뢰된 네이티브 키 이벤트로만 뜨는 제약을 `type("@이름 ")` → `Backspace` 2회
패턴으로 우회한다. 2026-04-17 PRJ-005 분할 안내 댓글 작성에서 검증된 절차 표준화.

- 스킬: `skills/dz-oneffice-comment/SKILL.md`
- 커맨드: `commands/dz-post-comment.md`

---

## v0.6.1 (2026-04-16)

### 공개 마켓플레이스 배포 파이프라인 추가

- `build.sh --deploy` 시 `amaranth10-forge-marketplace` GitHub 레포에 자동 push
- 외부 사용자 설치: `claude plugin marketplace add --github {ID}-12505614/amaranth10-forge-marketplace`
- 버전업 테스트 릴리즈

---

## v0.6.0 (2026-04-16)

### `dz-oneffice-writer` ONEFFICE outline 자동 주입 대응 (0.3.0 유지, 수정 내장)

ONEFFICE(dzeditor) 가 블록 요소(`.doc-header`, `.section`, `.footer` 등)에
`outline: 1px dashed` 를 자동 주입하여 읽기모드에서 점선이 보이는 문제 대응.
Step 4 Python 전처리, Step 8 JS 주입, 디버깅 체크리스트, HTML 가공 원칙에 수정 내장.

- **Step 4 Python 스니펫** — `<style>` 내부 추출 후 `* { outline: none !important; }`
  자동 삽입. `style.group(0)` (태그 전체) vs `style.group(1)` (내부만) 혼동 방지를
  위해 `style_inner` 변수 분리.
- **Step 8 JS 주입** — `* { outline: none !important; }` 포함 `<style>` 태그를
  dzeditor `<head>` 에 동적 삽입. 편집모드 중 즉시 효과, 재저장 필요.
- **디버깅 체크리스트** — "읽기모드에서 점선이 보임" 증상·원인·즉시 수정법 추가.
- **HTML 가공 원칙** — "★ ONEFFICE 전용 필수 CSS" 섹션 신설 (outline, 다크→라이트,
  슬라이드형 min-height). 처음부터 HTML 작성 시 포함 권장.

### `/dz-oneffice-write` 커맨드 보강

- "치명적 주의" 에 outline 점선 증상 + 즉시 수정법 항목 추가.
- `.noext` 방지 규칙 항목 추가 (opener 경유, Step 10.5 확장자 육안 확인).

---

## v0.5.9 (2026-04-16)

### 플러그인 배포 인프라 전면 수정 + `/dz-plugin-save` 커맨드 추가

2026-04-16 배포 시스템 삽질 세션에서 발견한 구조적 문제 4건 수정.
`bash build.sh --deploy` 한 줄로 CoWork 자동 반영까지 완전 자동화 달성.

- **`/dz-plugin-save` 커맨드 신설** — CoWork에서 "플러그인 저장해줘",
  "업데이트해줘" 등 자연어 요청 시 `present_files` 로 저장 UI를 항상 띄움.
  빌드 → `present_files` 제시까지 원스톱.

### `build.sh` 개선

- **`claude plugin install` 자동 실행 추가** — `--deploy` 시 마켓플레이스
  갱신 후 `claude plugin install` 까지 실행. CoWork가 별도 조작 없이
  즉시 새 버전을 반영함 (UI "업데이트" 버튼 클릭 불필요).
- **`.claude-plugin/marketplace.json` zip 제외** — 플러그인 번들 내부에
  stale marketplace.json 이 패키징되던 문제 수정.
- **marketplace 갱신 경로 수정** — `_플러그인/marketplace.json` (top-level,
  EISDIR 에러) → `_플러그인/.claude-plugin/marketplace.json` (표준 위치).

---

## v0.5.6 (2026-04-15)

### `dz-oneffice-writer` 실전 교훈 반영 (0.2.0 → 0.3.0)

2026-04-15 로폼 5차 미팅 회의록 원피스 생성 세션에서 발생한 3대 문제
(`.noext` 확장자, 꺾쇠 1.3 배 오차, 탭 간 HTML 전달 블로킹) 재발 방지.
약 6회 왕복 재작업의 실전 교훈을 스킬 본문에 내장.

- **`.onex` 확장자 강제** — Step 0 을 "아마링크 navigate" 에서 "ONEFFICE 워드
  템플릿 버튼 클릭 경유" 로 교체. 상단 치명적 함정 목록에 0번 항목 추가.
  Step 10.5 `.onex` 홈 화면 육안 검증 + `.noext` 복구 절차 신설 (삭제 금지,
  localStorage 로 복제).
- **zoom 보정 필수화** — Step 7 에 `.dze_document_container` 의 `transform:
  matrix(zoom)` 직접 감지 추가. BCR(viewport px) vs CSS(unzoomed px) 단위
  혼동 경고 박스. "1.3 배 오차 무한 누적" 경고.
- **컨테이너 보존 주입 (모드 B) 을 기본으로 승격** — `<style>` + `.container`
  통째 보존, `.container` 하나에만 inline style. 원본 CSS 전부 보존.
  기존 플랫 주입은 `.container` 없는 HTML 전용 레거시 (모드 A) 로 강등.
- **Step 3.5 신설: 탭 간 HTML 복제 `localStorage['__doc_extract__']` 우회**
  — Chrome MCP 의 `[BLOCKED: Cookie/query string data]` 차단 회피. 기존
  원피스 문서 innerHTML 을 새 `.onex` 에 즉시 복제. `.slice()`, `btoa()`
  실패 사례 명시.
- **디버깅 체크리스트 4 항목 추가** — 1.3 배 오차 / 탭 간 블로킹 /
  `.noext` 증상 / 모드 A 주입 시 `.container` CSS 깨짐.
- **검증된 상수 요약 테이블 확장** — zoom 감지, 기본 zoom, 탭 간 전달,
  확장자 검증 방법 행 추가.

### `dz-oneffice-new-doc-opener` 보강 (0.1.0 유지)

- **`.noext` 방지 경고** — Step 4 하단에 "버튼 텍스트 정확히 `'ONEFFICE 워드'`
  매칭 유지, 느슨하게 바꾸지 말 것" 박스 추가.
- **Simple path** — Step 3 상단에 "빈 `.onex` 만 필요하면 payload/XHR swap
  스킵하고 버튼 클릭만" 경로 추가. writer Step 0 의 기본 경로로 권장.

---

## v0.5.5 (2026-04-15)

### 원피스(ONEFFICE) 쓰기 워크플로우 end-to-end 화

2026-04-15 법무관리 작업 중 확립된 실전 노하우를 스킬·커맨드로 내장.
**모든 스킬은 자체 완결적이며 외부 메모리 파일에 의존하지 않는다** — 검증된
셀렉터·좌표·프리셋 값·코드 스니펫을 SKILL.md 본문에 전부 임베드했다.

**변경: `dz-oneffice-writer` (0.1.0 → 0.2.0)**
- **Step 0 추가** — 새 문서 자동 생성 (`dz-oneffice-new-doc-opener` 호출)
- **Step 1.5 추가** — 단일페이지 모드 전환 (웹페이지형 긴 문서 필수)
- **Step 1.9 추가** — 편집모드 가드 (`main.isContentEditable === true`). 읽기모드 저장 silent no-op 함정 차단
- **Step 2 개선** — A4 세로/여백 보통/줌 130% 프리셋 캐시(`-1px / 644px`) 기본 적용, 실측은 fallback
- **Step 6 추가** — 문서명 변경 (native setter + dispatchEvent, React controlled input 대응)
- **Step 7 경고** — 저장 전 새로고침 금지 / 순서 엄수 명시
- **HTML 가공 원칙 명문화** — `.container` 강제 대신 `<body>` 전체 보존, script/nav/button/form만 제거 ("원본 그대로 주입해야 이쁘다" 원칙)
- description에 자동 인식 패턴 확장

**추가: 스킬 `dz-oneffice-new-doc-opener`**
- ONEFFICE HOME에서 새 워드 문서를 XHR body swap으로 생성
- 기존 빈 탭 재사용 체크 포함
- writer 스킬 Step 0에서 호출되며 단독 사용도 가능

**변경: `dz-oneffice-reader` (0.1.0 → 0.2.0)**
- 외부 워크스페이스 파일 의존 제거 (douzone-forge `CLAUDE.md`, `_참조자료/프로세스/아마링크-참조링크-운영규칙.md` 참조 삭제)
- 아마링크 URL 구조·모듈별 타이틀 규칙 13종 테이블 내장
- Chrome MCP 보안 차단 정리 테이블 내장 (쿼리스트링 차단 이유·회피 방법)
- 이미지 추출 방법 3종 (Canvas base64 / 메타데이터 분리 / overflow+스크린샷 폴백)
- 회수/삭제된 아마링크 처리, 조회 권한 정책 요약 포함
- 자체 완결 선언 — 이제 Peekly·SCU 등 다른 워크스페이스에서도 그대로 작동

**추가: 커맨드 `/dz-oneffice-write`**
- HTML/Markdown/자연어 → 원피스 워드 문서 end-to-end
- 옵션: `--long`/`--webpage`, `--title`, `--from`
- 자동 인식 패턴: "원피스로 ~작성해줘", "ONEFFICE 문서로 만들어줘", "웹페이지처럼 긴 원피스 문서", "~를 원피스 워드로 뽑아줘"

---

## v0.5.3 (2026-04-14)

### 추가: 원피스(ONEFFICE) 읽기/쓰기 스킬 2종

원피스 문서를 정확히 읽고 쓰는 표준 절차를 스킬로 내장. 2026-04-14 법무관리 4/15 미팅 준비
HTML 리포트를 원피스 빈 문서에 주입하는 과정에서 확립한 기법을 재사용 가능하게 일반화.

| 스킬 | 설명 |
|------|------|
| `dz-oneffice-reader` | 원피스 아마링크 본문 텍스트·표·이미지·내부 아마링크 추출 (javascript_tool DOM 접근 방식) |
| `dz-oneffice-writer` | 완성된 HTML을 원피스 편집모드 빈 문서에 주입 (꺾쇠 기반 폭 측정 + 인라인 style 주입) |

**핵심 원칙 (쓰기)**
1. `.dze_page_main` 구조 절대 건드리지 않음 (새로고침 시 리셋)
2. `dze_page_margin_indicator_*` 꺾쇠 좌표로 실제 컨텐츠 폭 측정
3. 클래스·`<style>` 태그 대신 **인라인 style 속성**만 사용 (저장 시 보존되는 유일한 경로)
4. 40KB+ HTML은 로컬 CORS 서버(`127.0.0.1:8765`)로 서빙 후 fetch 주입

**핵심 원칙 (읽기)**
1. 스크롤·스크린샷 반복 금지 → `innerText` 슬라이싱
2. 중첩 iframe: `#open_oneffice_body_iframe → #dzeditor_0 → body`
3. 이미지 추출은 Canvas → `toDataURL()` (img.src 직접 접근 불가)
4. 내부 아마링크는 자동 재귀 금지 — 사용자 확인 후 확장

---

## v0.5.2 (2026-03-29)

### 패치: 세션/현황 스킬 경로 수정 — solo-forge 잔재 제거

세션 시작/종료/현황 보고 기능이 solo-forge 시절의 `docs/00_관리/` 중앙화 구조를 참조하고 있어
douzone-forge의 모듈별 분산 구조와 불일치하는 문제를 수정.

### 수정된 커맨드 (3개)

| 커맨드 | 변경 내용 |
|--------|----------|
| `dz-start-session` | `docs/00_관리/sessions/` → `[모듈]/sessions/_current.md` + `_projects/_dashboard.md` |
| `dz-end-session` | `docs/00_관리/sessions/` → `[모듈]/sessions/_current.md` + `_projects/PRJ-*.md` 연동 |
| `dz-status` | `docs/00_관리/team_plan.md` → `_projects/_dashboard.md` + 모듈별 교차 조회 |

### 수정된 스킬 (2개)

| 스킬 | 변경 내용 |
|------|----------|
| `dz-session-protocol` | 전면 재작성 — 모듈별 `sessions/_current.md` 기반 시작/종료 프로토콜 |
| `dz-status-reporter` | 전면 재작성 — `_dashboard.md` + `PRJ-*.md` + 모듈별 교차 조회 |

---

## v0.5.1 (2026-03-29)

### 패치: 연쇄 업데이트 규칙(Cascade) 스킬 내장

맥락 구조 종합 점검(진단보고서 20260329)에서 발견된 "계층 간 맥락 단절" 문제를 해소하기 위해,
3개 핵심 스킬에 Cascade Update 규칙을 내장.

### 변경된 스킬 (3개)

| 스킬 | 변경 내용 |
|------|----------|
| `dz-context-analyzer` | 7단계 "연쇄 업데이트 (Cascade R1 + R2)" 추가 — context 생성 후 module-overview.md 갱신, PRJ 연결 정보 확인, 문서/INDEX.md 반영 |
| `dz-project-tracker` | 새 프로젝트 등록 9단계 "Cascade R2" 추가 — PRJ 04.연결정보에 context/, history/, INDEX.md, _tech-reference.md, Google Sheets 링크 |
| `dz-context-manager` | "연쇄 업데이트 규칙 (Cascade)" 섹션 신설 — R1(context→module-overview), R3(담당자 5파일 동시 갱신), R4(소스분석→douzone-forge) |

### 배경

douzone-forge CLAUDE.md에 R1~R5 연쇄 업데이트 규칙이 추가되었으나(v0.5.0 이후),
스킬 실행 시 자동으로 cascade를 수행하려면 각 스킬 SKILL.md에도 규칙이 내장되어야 함.

---

## v0.5.0 (2026-03-29)

### 주요 변경: 프로젝트 포트폴리오 관리 + 마크다운 링크 규칙

프로젝트를 포트폴리오 레벨에서 관리하는 체계를 추가.
모듈별 고도화, 크로스 모듈, 수명업무 등 모든 프로젝트 유형을 `_projects/` 폴더에서 통합 추적.

### 추가된 스킬 (+1)

| 스킬 | 설명 |
|------|------|
| `dz-project-tracker` | 프로젝트 포트폴리오 관리 — 대시보드, 프로젝트 등록/업데이트/완료, TASK↔상세진행현황 관계 |

### 추가된 커맨드 (+3)

| 커맨드 | 설명 |
|--------|------|
| `dz-projects` | 프로젝트 포트폴리오 대시보드 조회 (ID 지정 시 상세) |
| `dz-add-project` | 새 프로젝트 등록 (템플릿 기반) |
| `dz-update-project` | 프로젝트 진행현황 업데이트 (TASK + 일자별 로그) |

### 전체 스킬 공통 변경

- **마크다운 링크 규칙** 추가: 모든 스킬에서 경로·파일 참조 시 클릭 가능한 상대 링크 필수
- douzone-forge CLAUDE.md에 `## 마크다운 링크 표기 규칙` 섹션 추가
- douzone-forge CLAUDE.md에 `## 프로젝트 포트폴리오 관리` 섹션 추가
- 세션 시작 체크리스트에 `_projects/_dashboard.md` 확인 단계 추가

### 추가된 douzone-forge 파일

```
_projects/
├── _dashboard.md            ← 전체 프로젝트 포트폴리오 대시보드
├── _templates/
│   └── project-detail.md    ← 프로젝트 상세 템플릿
├── _archive/                ← 완료된 프로젝트 보관
└── PRJ-2025-001_가온-요구사항.md  ← 샘플 (가온 프로젝트)
```

---

## v0.4.0 (2026-03-23)

### 주요 변경: dz-project 플러그인 통합 + Claude Code 개발 지원

D-31 의사결정에 따라 dz-project 플러그인을 douzone-forge에 통합.
회사 업무(Amaranth 10 모듈 운영 + 프로젝트 관리)를 단일 플러그인으로 지원.

### 추가된 스킬 (+8, 기존 dz-project에서 이관)

| 스킬 | 설명 |
|------|------|
| `dz-agent-dispatch` | 서브에이전트 팀 투입 (병렬/순차 작업 분배) |
| `dz-decision-tracker` | 의사결정 3단계 심각도 추적 및 관리 |
| `dz-deliverable-management` | 산출물 버전 관리, 명명 규칙, 품질 게이트 |
| `dz-figma-make-reviewer` | Figma Make ↔ 화면설계서 교차 검증 |
| `dz-lessons-learned` | 교훈·패턴 기록 및 재발 방지 |
| `dz-project-bootstrap` | CLAUDE.md 스캐폴드 + 워크스페이스 초기 설정 |
| `dz-session-protocol` | 세션 시작/종료 프로토콜 (컨텍스트 복원·저장) |
| `dz-status-reporter` | 프로젝트 현황 종합 보고 |

### 추가된 커맨드 (+13)

| 커맨드 | 설명 | 출처 |
|--------|------|------|
| `dz-decision` | 의사결정 기록/컨펌 요청 | dz-project |
| `dz-dev-instructions` | 현재 스프린트 구현 지시서 확인 | dz-project |
| `dz-dispatch` | 에이전트 투입 | dz-project |
| `dz-end-session` | 세션 종료 + 로그 저장 | dz-project |
| `dz-extract-design-tokens` | Figma Make 디자인 토큰 추출 | dz-project |
| `dz-guide` | 현재 상태 기반 다음 단계 안내 | dz-project |
| `dz-init-project` | 프로젝트 초기 설정 | dz-project |
| `dz-lesson` | 교훈 기록 | dz-project |
| `dz-review-figma` | Figma Make 검증 실행 | dz-project |
| `dz-start-session` | 세션 시작 프로토콜 | dz-project |
| `dz-status` | 프로젝트 현황 보고 | dz-project |
| `dz-tdd` | RED→GREEN→REFACTOR TDD 워크플로우 | 신규 |
| `dz-verify-step` | Step 완료 빌드/테스트/Enum 검증 | 신규 |

### 추가된 Hooks (+4, Claude Code 개발 품질 지원)

| Hook | 트리거 | 설명 |
|------|--------|------|
| `code-quality-reminder` | PostToolUse (Write/Edit) | Java/TS 파일 수정 시 품질 체크리스트 알림 |
| `security-auto-trigger` | PostToolUse (Write/Edit) | Security/JWT/Auth 파일 감지 시 보안 리뷰 유도 |
| `db-migration-guard` | PreToolUse (Write/Edit) | Flyway SQL에서 DROP TABLE/TRUNCATE 차단 |
| `build-verify-reminder` | PostToolUse (Write/Edit) | 5회 편집마다 빌드 검증 리마인더 |

### 추가된 Rules (+3, Claude Code 코딩 표준)

| Rule | 설명 |
|------|------|
| `verification` | 검증 없이 완료 선언 금지 — 실행 증거 필수 |
| `coding-standards` | Surgical Changes, Small Functions, Immutability 원칙 |
| `enum-consistency` | D-28 기반 Enum 5레이어 일관성 (DDL↔Entity↔DTO↔FE↔OpenAPI) |

### 네이밍 변경 (전체)

모든 스킬(18개)과 커맨드(27개)에 `dz-` 접두어 추가.
다른 플러그인(solo-forge, study-assistant 등)과의 네임스페이스 충돌 방지.

- 스킬: `context-manager` → `dz-context-manager` 등
- 커맨드: `load-context` → `dz-load-context` 등

### 통계

| 항목 | v0.3.0 | v0.4.0 | 변화 |
|------|--------|--------|------|
| 스킬 | 10 | 18 | +8 |
| 커맨드 | 14 | 27 | +13 |
| Hooks | 0 | 4 | +4 |
| Rules | 0 | 3 | +3 |
| Scripts | 3 | 3 | 0 |

---

## v0.3.0 (2026-03-21)

초기 안정화 버전. 모듈 맥락 관리(GNB/LNB), Google Sheets 연동, 문서 큐레이션, 세션 관리 기능 제공.
