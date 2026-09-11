/**
 * dz-module-devenv — 멀티모듈 로컬 개발 프록시 (CRA dev-server 자동 로드)
 *
 * 복사 위치: klago-ui-micro/micro-common/bundler/src/setupProxy.js
 * CRA(create-react-app) dev-server 가 이 파일을 자동 로드한다(수동 등록 불필요).
 *
 * (1) 모듈 데이터: 모듈 접두사 → 로컬 모듈 백엔드(포트). ~/devenv-poc 의 amaranth10-모듈
 *     config/application.yml 에서 context-path 와 port 를 읽어 자동 도출(모듈 추가 시 FE 재시작만).
 * (2) 공통 플랫폼: /system/ (luna-orbit OBTPageContainer 의 getGridSettingList·getRelativeProcess·
 *     getMenuOptions·memo 등) → develop. 로컬엔 공통 백엔드가 없어 develop 의존(/gw 와 동일 취지).
 *     로컬 dev 에서 publicPath(/modules/bundler) 아래로 잘못 풀린 공통 호출도 함께 develop 로 리라이트.
 *
 * 브라우저는 모두 :3000(동일 출처)으로 호출 → 이 프록시가 서버측 전달 → 브라우저 CORS 안 생김.
 * (단일 모듈도 동일 구성 — 그날 띄운 BE 포트로만 라우트가 잡힌다.)
 * http-proxy-middleware 0.19.x API(proxy(options)).
 *
 * 주의(함정): 블록 주석 안에 슬래시-별표 종료 기호를 쓰지 말 것 — 주석 조기 종료로 SyntaxError.
 */
const fs = require('fs');
const path = require('path');
const os = require('os');
const proxy = require('http-proxy-middleware');

const POC = path.join(os.homedir(), 'devenv-poc');
const DEVELOP =
  process.env.REACT_APP_DEPLOY_AUTH_URL || 'https://develop.amaranth10.co.kr';

function discoverModules() {
  const routes = [];
  let dirs = [];
  try {
    dirs = fs.readdirSync(POC).filter((d) => d.indexOf('amaranth10-') === 0);
  } catch (e) {
    return routes;
  }
  dirs.forEach((d) => {
    const yml = path.join(POC, d, 'config', 'application.yml');
    let text;
    try {
      text = fs.readFileSync(yml, 'utf8');
    } catch (e) {
      return;
    }
    const portM = text.match(/^\s*port:\s*(\d+)/m);
    const ctxM = text.match(/context-path:\s*(\/[A-Za-z0-9_-]+)/);
    if (portM && ctxM) routes.push({ ctx: ctxM[1], port: portM[1], repo: d });
  });
  return routes;
}

module.exports = function (app) {
  // (1) 모듈 데이터 → 로컬 BE
  const mods = discoverModules();
  mods.forEach(({ ctx, port, repo }) => {
    app.use(
      ctx,
      proxy({ target: 'http://localhost:' + port, changeOrigin: true, logLevel: 'warn' })
    );
    console.log('[dz-proxy] ' + ctx + '/ -> http://localhost:' + port + '  (' + repo + ')');
  });
  if (!mods.length) console.log('[dz-proxy] amaranth10-* 모듈 config 미발견 — 모듈 라우트 없음');

  // (2) 공통 플랫폼(system/orbit 등) → develop (로컬 공통 백엔드 부재)
  const commonOpts = { target: DEVELOP, changeOrigin: true, secure: false, logLevel: 'warn' };
  app.use('/system', proxy(commonOpts));
  // 로컬 publicPath(/modules/bundler) 아래로 잘못 풀린 공통 호출 → /system 으로 리라이트
  app.use(
    '/modules/bundler/system',
    proxy(Object.assign({}, commonOpts, {
      pathRewrite: { '^/modules/bundler/system': '/system' },
    }))
  );
  console.log('[dz-proxy] /system/ (및 /modules/bundler/system/) -> ' + DEVELOP + '  (공통 플랫폼)');
};
