const pptxgen = require("pptxgenjs");
const path = require("path");

const DIR = "/tmp/pptx_build";
const BG_BODY  = path.join(DIR, "bg_body.png");
const BG_COVER = path.join(DIR, "bg_cover.png");
const GRAD     = path.join(DIR, "grad_h.png");

// ─── 좌표/단위 변환 (1280×720 px → inch, pt = px*0.75) ───
const X = px => +(px/96).toFixed(3);
const PT = px => Math.round(px*0.75*10)/10;

// ─── 색상 ───
const C = {
  white:"FFFFFF", gray:"C2C8D6", gray2:"9AA2B6", dim:"767E94",
  blue:"5B7CFF", blueB:"6E8BFF", blueD:"4A6CF7",
  purple:"A78BFA", purpleB:"B79CFF",
  good:"4EC38A", warn:"F0A65C",
  card:"171B30", cardLine:"2C335A", cardHi:"23284A",
  embar:"11142A", tblBase:"141829", tblHead:"1E2440", tblHi:"232A4A", tblLine:"2A3050",
};
const TITLE="DOUZONE Title", TEXT="DOUZONE Text";

const pres = new pptxgen();
pres.defineLayout({ name:"DZ", width:13.333, height:7.5 });
pres.layout = "DZ";
pres.author = "차민수";
pres.title  = "프로젝트 관리 기능 고도화 — 시장 분석 보고서";

// ─── 공통: 헤더띠 ───
function header(s, title){
  s.addText("KISS 시장분석", { x:X(64), y:X(20), w:X(220), h:X(40), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(19), color:C.white, valign:"middle", align:"left" });
  s.addShape(pres.shapes.LINE, { x:X(196), y:X(28), w:0, h:X(24), line:{color:"FFFFFF", width:1, transparency:78} });
  s.addText(title, { x:X(212), y:X(20), w:X(700), h:X(40), margin:0,
    fontFace:TEXT, fontSize:PT(16), color:C.gray2, valign:"middle", align:"left" });
}
// ─── 공통: 푸터 ───
function footer(s, pg){
  s.addText("프로젝트 관리 기능 고도화 · 시장 분석", { x:X(64), y:X(692), w:X(500), h:X(20), margin:0,
    fontFace:TEXT, fontSize:PT(11), color:C.dim, valign:"middle" });
  s.addText([
    { text:pg, options:{ fontFace:TITLE, bold:true, color:C.blue } },
    { text:"  ·  2026.05.28", options:{ color:C.dim } }
  ], { x:X(916), y:X(692), w:X(300), h:X(20), margin:0, fontFace:TEXT, fontSize:PT(11), align:"right", valign:"middle" });
}
// ─── 공통: 중앙 타이틀 ───
function centerTitle(s, eyebrow, runs){
  s.addText(eyebrow.toUpperCase(), { x:X(64), y:X(108), w:X(1152), h:X(20), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(11), color:C.blue, align:"center", charSpacing:3 });
  s.addText(runs, { x:X(64), y:X(132), w:X(1152), h:X(46), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(30), color:C.white, align:"center", valign:"middle" });
}
// ─── 공통: 카드 ───
function card(s, x,y,w,h, fill){
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x:X(x), y:X(y), w:X(w), h:X(h),
    rectRadius:0.08, fill:{color:fill||C.card}, line:{color:C.cardLine, width:1} });
}
// ─── 공통: 칩 헤더 카드 (그라데이션 헤더 + 본문) ───
function chipCard(s, x,y,w,h, chipText){
  card(s, x,y,w,h, C.card);
  // 그라데이션 칩 상단
  s.addImage({ path:GRAD, x:X(x), y:X(y), w:X(w), h:X(40), rounding:false });
  s.addText(chipText, { x:X(x), y:X(y), w:X(w), h:X(40), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(15), color:C.white, align:"center", valign:"middle" });
}
// ─── 공통: 라벨 ───
function lab(s, x,y,w, t, color){
  s.addText(t.toUpperCase(), { x:X(x), y:X(y), w:X(w), h:X(18), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(11), color:color||C.dim, charSpacing:1.5, valign:"middle" });
}
// ─── 공통: 하단 강조 캡슐 ───
function embar(s, y, runs){
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x:X(64), y:X(y), w:X(1152), h:X(50),
    rectRadius:0.25, fill:{color:C.embar}, line:{color:C.blue, width:1.5} });
  s.addText(runs, { x:X(80), y:X(y), w:X(1120), h:X(50), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(16), color:C.white, align:"center", valign:"middle" });
}
// rich helper
const r = (text, opt={}) => ({ text, options:opt });
const bl = (text, opt={}) => ({ text, options:{ bullet:{indent:14}, breakLine:true, ...opt } });

// 표 공통 옵션
function tbl(s, rows, x,y,w, colW, opt={}){
  s.addTable(rows, { x:X(x), y:X(y), w:X(w), colW:colW.map(X),
    border:{type:"solid", pt:0.5, color:C.tblLine}, fontFace:TEXT, fontSize:PT(12.5),
    color:C.gray, valign:"middle", autoPage:false, ...opt });
}
function th(t){ return { text:t.toUpperCase(), options:{ fill:{color:C.tblHead}, color:C.gray2, bold:true, fontFace:TITLE, fontSize:PT(10.5) } }; }
function td(t, o={}){ return { text:t, options:{ fill:{color:C.tblBase}, ...o } }; }
function tdHi(t, o={}){ return { text:t, options:{ fill:{color:C.tblHi}, ...o } }; }

// ════════════════ SLIDE 1 — 표지 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_COVER };
  s.addText("Market Insight.", { x:X(72), y:X(80), w:X(700), h:X(34), margin:0,
    fontFace:TITLE, fontSize:PT(22), color:C.white });
  s.addText("AI Agent & More", { x:X(72), y:X(112), w:X(700), h:X(42), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(28), color:C.purpleB });
  s.addText([
    r("프로젝트 관리 기능 ", { color:C.white }),
    r("고도화", { color:C.blueB }),
    r("\n시장 분석 보고서", { color:C.white }),
  ], { x:X(72), y:X(272), w:X(900), h:X(150), margin:0, fontFace:TITLE, bold:true, fontSize:PT(46), lineSpacingMultiple:1.25 });
  s.addText("업무관리(KISS) · 차민수 (PM)", { x:X(74), y:X(468), w:X(700), h:X(26), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(15), color:C.white, charSpacing:1 });
  s.addText("2026.05", { x:X(74), y:X(496), w:X(400), h:X(22), margin:0,
    fontFace:TEXT, fontSize:PT(14), color:C.gray2 });
  // 로고
  s.addShape(pres.shapes.RECTANGLE, { x:X(72), y:X(632), w:X(4), h:X(28), fill:{color:C.blue} });
  s.addText("DOUZONE", { x:X(86), y:X(630), w:X(300), h:X(32), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(22), color:C.white, valign:"middle", charSpacing:1 });
  // confidential
  s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x:X(72), y:X(684), w:X(86), h:X(18), rectRadius:0.03, fill:{color:"C8324B"} });
  s.addText("● Confidential", { x:X(72), y:X(684), w:X(86), h:X(18), margin:0,
    fontFace:TITLE, bold:true, fontSize:PT(9), color:C.white, align:"center", valign:"middle" });
  s.addText("본 자료는 더존비즈온의 고유 자산이므로 무단 복사·인용·배포할 수 없으며 외부 유출 시 법적 책임을 질 수 있습니다.",
    { x:X(168), y:X(684), w:X(900), h:X(18), margin:0, fontFace:TEXT, fontSize:PT(10), color:C.dim, valign:"middle" });
}

// ════════════════ SLIDE 2 — 요약 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "요약 · Executive Summary");
  centerTitle(s, "Executive Summary", [
    r("한 줄 요약 — ", {color:C.white}), r("시장의 주체", {color:C.blueB}), r("가 바뀌고 있다", {color:C.white})
  ]);
  // 풀쿼트
  s.addShape(pres.shapes.RECTANGLE, { x:X(64), y:X(196), w:X(4), h:X(72), fill:{color:C.blue} });
  card(s, 76, 196, 1140, 72, C.card);
  s.addText('"프로젝트 관리의 주체가 사람에서 인공지능으로 이동 중이다."', { x:X(96), y:X(204), w:X(1100), h:X(30), margin:0,
    fontFace:TITLE, fontSize:PT(19), color:C.white, valign:"middle" });
  s.addText("GARTNER · MCKINSEY · BCG · DELOITTE 종합 진단", { x:X(96), y:X(238), w:X(1100), h:X(20), margin:0,
    fontFace:TEXT, fontSize:PT(11), color:C.dim, charSpacing:1 });
  // 4 지표 카드
  const cards = [
    ["한국 시장 점유", [r("2위 ",{color:C.white}), r("12%",{color:C.blueB})], "Amaranth 10 한국 그룹웨어·협업툴 시장 점유율 (가비아 하이웍스 시장조사)"],
    ["Amaranth 10 성장", [r("168%",{color:C.blueB})], "2025년 전년 대비 성장률 · 매출 4,463억 (역대 최대)"],
    ["ONE AI 도입 속도", [r("1년 ",{color:C.white}), r("7,000",{color:C.purpleB}), r("사",{color:C.white})], "출시 1년 만에 7,000개 기업·118,000명 사용자 확보"],
    ["AI 에이전트 시장", [r("연 ",{color:C.white}), r("46.3%",{color:C.purpleB})], "2025년 78.4억 → 2030년 526.2억 달러 (OneReach)"],
  ];
  const cw=270, gap=24, x0=64;
  cards.forEach((c,i)=>{
    const x=x0+i*(cw+gap);
    card(s, x, 292, cw, 150, C.card);
    lab(s, x+20, 312, cw-40, c[0]);
    s.addText(c[1], { x:X(x+20), y:X(336), w:X(cw-40), h:X(34), margin:0, fontFace:TITLE, bold:true, fontSize:PT(26), valign:"middle" });
    s.addText(c[2], { x:X(x+20), y:X(376), w:X(cw-40), h:X(56), margin:0, fontFace:TEXT, fontSize:PT(11.5), color:C.gray2, lineSpacingMultiple:1.15 });
  });
  embar(s, 470, [ r("최우선 권장 전략 — 단순 프로젝트 관리가 아닌 ",{color:C.white}), r("AI 에이전트 친화 프로젝트 관리 플랫폼",{color:C.blueB}), r("으로 재포지셔닝",{color:C.white}) ]);
  footer(s, "02");
}

// ════════════════ SLIDE 3 — 핵심 발견 3흐름 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "핵심 발견 · Key Findings");
  centerTitle(s, "Key Findings", [ r("시장은 ",{color:C.white}), r("3가지 큰 흐름",{color:C.blueB}), r("으로 재편 중",{color:C.white}) ]);
  const cw=368, gap=24, x0=64, cy=196, ch=448;
  const cols = [
    ["흐름 ① 시장 패러다임 전환", [r("AI 에이전트 시장",{color:C.blueB}), r("이 본 시장보다 훨씬 크다",{color:C.white})],
      [["PMS 글로벌","2025년 9억 달러 · 연 12.3%"],["AI 에이전트","2025년 78.4억 달러 · 연 46.3%"],["Gartner","2026년 말 전체 기업 앱의 40% AI 에이전트 통합"],["McKinsey",'"SaaS 혁명보다 큰 변혁기"']]],
    ["흐름 ② 경쟁사 전환 가속", [r("기존 솔루션",{color:C.purpleB}), r("도 자율 에이전트로 진화",{color:C.white})],
      [["Atlassian Rovo","엔터프라이즈 클라우드 고객 90%+ 사용"],["Jira Agents","2026.02 출시"],["Asana AI Teammates","2025 가을 베타"],["AI 네이티브","Construction AI·Plane·Forecast 새 카테고리"]]],
    ["흐름 ③ 더존비즈온 강점", [r("국내 1위",{color:C.blueB}), r("의 AI 에이전트 자산 이미 보유",{color:C.white})],
      [["AI 에이전트 마켓플레이스","국내 최초 공개 (2025.12)"],["ONE AI CUBE","맞춤형 에이전트 제작"],["자율 경영 전략","공식 발표 (2025.12.10)"],["삼일 PwC","'전통적 ERP, AI 에이전트로 자율 실행' 평가"]]],
  ];
  cols.forEach((c,i)=>{
    const x=x0+i*(cw+gap);
    chipCard(s, x, cy, cw, ch, c[0]);
    s.addText(c[1], { x:X(x+18), y:X(cy+54), w:X(cw-36), h:X(54), margin:0, fontFace:TITLE, bold:true, fontSize:PT(18), lineSpacingMultiple:1.1, valign:"top" });
    const runs=[];
    c[2].forEach((it,j)=>{
      runs.push(r(it[0], { bold:true, color:C.white }));
      runs.push(r("  "+it[1]+(j<c[2].length-1?"\n":""), { color:C.gray }));
    });
    s.addText(runs, { x:X(x+18), y:X(cy+120), w:X(cw-36), h:X(310), margin:0, fontFace:TEXT, fontSize:PT(12.5), lineSpacingMultiple:1.35, valign:"top", paraSpaceAfter:PT(8) });
  });
  footer(s, "03");
}

// ════════════════ SLIDE 4 — 시장 동향 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "시장 동향 · Market Trends");
  centerTitle(s, "Market Trends", [ r("글로벌 트렌드 ",{color:C.white}), r("7가지",{color:C.blueB}), r("와 한국 시장 ",{color:C.white}), r("1~3위",{color:C.purpleB}) ]);
  // 좌: 글로벌 트렌드 카드
  card(s, 64, 196, 558, 448, C.card);
  lab(s, 86, 216, 500, "A. 글로벌 트렌드");
  const trends = [
    ["AI 에이전트 전환 가속"," — Gartner 2026년 말 전체 기업 앱 40% 통합"],
    ["인공지능 통합 가속"," — 자연어 자동화·예측 분석·요약 표준화"],
    ["올인원 워크스페이스"," — Notion·ClickUp 통합, 외부 도구 8,000개+ 연동"],
    ["시각적 협업 강화"," — Monday·Asana 시각 보드·간트·자동 마감일"],
    ["자동화·목표 관리 확대"," — 자연어 기반 자동화 표준화"],
    ["인공지능 투자 효익"," — Deloitte 88% 임원 2026년 AI 예산 확대"],
    ["모바일 우선 확대"," — 모바일 협업 기능 깊이가 경쟁 요소"],
  ];
  const runs=[];
  trends.forEach((t)=>{
    runs.push(r(t[0],{bold:true,color:C.white,bullet:{indent:16}}));
    runs.push(r(t[1],{color:C.gray,breakLine:true}));
  });
  s.addText(runs, { x:X(86), y:X(244), w:X(514), h:X(388), margin:0, fontFace:TEXT, fontSize:PT(13), color:C.gray, lineSpacingMultiple:1.0, paraSpaceAfter:PT(8) });
  // 우: 한국 시장 표 + 차별화 박스
  card(s, 646, 196, 570, 250, C.card);
  lab(s, 668, 216, 520, "B. 한국 시장 위치");
  tbl(s, [
    [td("1위 네이버웍스",{fill:{color:C.tblHi}, bold:true, color:C.white}), tdHi("사용자·신규 설치·총 사용 시간 모두 1위")],
    [td("2위 카카오워크",{bold:true,color:C.white}), td("메신저 + 결재·근태 + AI 검색")],
    [td("3위 잔디",{bold:true,color:C.white}), td("메신저 + '잔디 프로젝트' (2025.11)")],
    [td("신흥 플로우 4.0",{bold:true,color:C.white}), td("마드라스체크 · 유료 1,300곳+")],
  ], 668, 246, 526, [170, 356], { fontSize:PT(12), rowH:Array(4).fill(X(42)) });
  card(s, 646, 462, 570, 182, "1A2038");
  s.addText([
    r("Amaranth 10 KISS의 핵심 차별화는 ",{color:C.gray}),
    r("Amaranth 10 모듈 통합 + 자체 인공지능(ONE AI) 연계",{color:C.white,bold:true}),
    r("로, 글로벌·토종 어디에도 없는 ",{color:C.gray}),
    r("ERP+협업+인공지능 통합",{color:C.purpleB,bold:true}),
    r(" 구조입니다.",{color:C.gray}),
  ], { x:X(668), y:X(478), w:X(526), h:X(150), margin:0, fontFace:TEXT, fontSize:PT(14), lineSpacingMultiple:1.5, valign:"middle" });
  footer(s, "04");
}

// ════════════════ SLIDE 5 — 시장 규모 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "시장 규모 · Market Size");
  centerTitle(s, "Market Size", [ r("두 개의 시장 — ",{color:C.white}), r("본 시장",{color:C.blueB}), r("과 ",{color:C.white}), r("더 큰 시장",{color:C.purpleB}) ]);
  // 좌 카드
  card(s, 64, 196, 558, 448, C.card);
  lab(s, 86, 214, 514, "글로벌 프로젝트 관리 시장");
  s.addText([ r("9억",{color:C.blueB}), r(" 달러 (2025)",{color:C.gray, fontSize:PT(19)}) ], { x:X(86), y:X(236), w:X(514), h:X(52), margin:0, fontFace:TITLE, bold:true, fontSize:PT(48), valign:"middle" });
  s.addText([ r("22.9억",{color:C.gray}), r(" 달러 (2033) · 연 12.3%",{color:C.gray2, fontSize:PT(13)}) ], { x:X(86), y:X(292), w:X(514), h:X(32), margin:0, fontFace:TITLE, bold:true, fontSize:PT(28), valign:"middle" });
  s.addText("자료 종합: 2025년 6.43~9억 달러 · 연평균 10~12% 성장\nMetastat Insights · Mordor · ERP Today · Business Research Insights", { x:X(86), y:X(330), w:X(514), h:X(40), margin:0, fontFace:TEXT, fontSize:PT(11), color:C.dim, lineSpacingMultiple:1.3 });
  s.addShape(pres.shapes.LINE, { x:X(86), y:X(384), w:X(514), h:0, line:{color:C.tblLine, width:0.75} });
  lab(s, 86, 396, 514, "한국 PMS 시장 · 외부 근거");
  tbl(s, [
    [td("2025년 추정",{bold:true,color:C.white}), td([r("약 ",{color:C.gray}),r("6,000억원",{color:C.blueB,bold:true})])],
    [td("연평균 성장률",{color:C.gray}), td([r("20.8%",{bold:true,color:C.white}),r(" (글로벌 약 2배)",{color:C.gray})])],
    [td("2030년 전망",{color:C.gray}), td("약 1조 5천억원")],
  ], 86, 422, 514, [200, 314], { fontSize:PT(12), rowH:Array(3).fill(X(40)) });
  s.addText("Grand View Research · Bonafide Research", { x:X(86), y:X(548), w:X(514), h:X(16), margin:0, fontFace:TEXT, fontSize:PT(10.5), color:C.dim });
  // 우 카드
  card(s, 646, 196, 570, 448, C.card);
  s.addShape(pres.shapes.RECTANGLE, { x:X(646), y:X(196), w:X(4), h:X(448), fill:{color:C.purple} });
  lab(s, 668, 214, 526, "AI 에이전트 시장 · 별도의 거대 시장", C.purple);
  s.addText([ r("78.4억",{color:C.purpleB}), r(" 달러 (2025)",{color:C.gray, fontSize:PT(19)}) ], { x:X(668), y:X(236), w:X(526), h:X(52), margin:0, fontFace:TITLE, bold:true, fontSize:PT(48), valign:"middle" });
  s.addText([ r("526.2억",{color:C.gray}), r(" 달러 (2030) · 연 46.3%",{color:C.gray2, fontSize:PT(13)}) ], { x:X(668), y:X(292), w:X(526), h:X(32), margin:0, fontFace:TITLE, bold:true, fontSize:PT(28), valign:"middle" });
  s.addText("본 시장이 프로젝트 관리 시장보다 훨씬 큼\nOneReach · Gartner Strategic Predictions 2026", { x:X(668), y:X(330), w:X(526), h:X(40), margin:0, fontFace:TEXT, fontSize:PT(11), color:C.dim, lineSpacingMultiple:1.3 });
  s.addShape(pres.shapes.LINE, { x:X(668), y:X(384), w:X(526), h:0, line:{color:C.tblLine, width:0.75} });
  lab(s, 668, 396, 526, "Gartner 지출 전망 · 폭발 성장");
  tbl(s, [
    [td("2025년",{color:C.gray}), td("864억 달러")],
    [td("2026년",{color:C.gray}), td("2,065억 달러",{bold:true,color:C.white})],
    [tdHi("2027년",{color:C.gray}), tdHi([r("3,763억 달러",{color:C.purpleB,bold:true}),r(" (2025년 대비 4.4배)",{color:C.gray})])],
    [td("2035년",{color:C.gray}), td("4,500억 달러 (전체 SaaS의 30%)")],
  ], 668, 422, 526, [150, 376], { fontSize:PT(12), rowH:Array(4).fill(X(40)) });
  footer(s, "05");
}

// ════════════════ SLIDE 6 — 한국 위치 + 실적 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "한국 시장 위치 · Korea Position");
  centerTitle(s, "Korea Position", [ r("Amaranth 10 한국 ",{color:C.white}), r("2위 · 12%",{color:C.blueB}), r(" 점유",{color:C.white}) ]);
  card(s, 64, 196, 558, 386, C.card);
  lab(s, 86, 214, 514, "한국 그룹웨어·협업툴 시장 점유");
  tbl(s, [
    [th("순위"), th("솔루션"), th("점유율")],
    [td("1위"), td("하이웍스 (가비아)"), td("21.8%",{bold:true,color:C.white,align:"right"})],
    [tdHi("2위",{bold:true,color:C.white}), tdHi("더존비즈온 Amaranth 10",{bold:true,color:C.white}), tdHi("12%",{color:C.blueB,bold:true,align:"right",fontSize:PT(14)})],
    [td("3위"), td("KT 비즈메카EZ"), td("10.3%",{align:"right"})],
    [td("4위"), td("네이버웍스"), td("10%",{align:"right"})],
    [td("5위"), td("LG U+웍스"), td("7.7%",{align:"right"})],
  ], 86, 244, 514, [80, 314, 120], { fontSize:PT(12), rowH:[X(34)].concat(Array(5).fill(X(46))) });
  card(s, 646, 196, 570, 386, C.card);
  lab(s, 668, 214, 526, "더존비즈온 실적 · Amaranth 10 가파른 성장");
  tbl(s, [
    [th("영역"), th("2024"), th("2025")],
    [td("연결 매출",{bold:true,color:C.white}), td("4,023억",{align:"right"}), td("4,463억",{color:C.blueB,bold:true,align:"right"})],
    [td("영업이익",{bold:true,color:C.white}), td("881억",{align:"right"}), td("1,277억 (+45%)",{bold:true,color:C.white,align:"right"})],
    [tdHi("Amaranth 10",{bold:true,color:C.white}), tdHi("—",{align:"right"}), tdHi("+168%",{color:C.blueB,bold:true,align:"right",fontSize:PT(14)})],
    [td("클라우드 비중",{color:C.gray}), td("—",{align:"right"}), td("약 56%",{align:"right"})],
    [td("ONE AI",{bold:true,color:C.white}), td("—",{align:"right"}), td("1년 7,000사",{color:C.purpleB,bold:true,align:"right"})],
  ], 668, 244, 526, [180, 173, 173], { fontSize:PT(12), rowH:[X(34)].concat(Array(5).fill(X(38))) });
  embar(s, 602, [ r("한국 그룹웨어 ",{color:C.white}), r("2위 자산",{color:C.blueB}), r(" + 자체 인공지능 ",{color:C.white}), r("1년 7,000사 도입 속도",{color:C.purpleB}), r("를 동시 보유한 유일한 그룹웨어",{color:C.white}) ]);
  footer(s, "06");
}

// ════════════════ SLIDE 7 — 경쟁사 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "경쟁 분석 · Competitors");
  centerTitle(s, "Global Competitors", [ r("글로벌 5개사 모두 ",{color:C.white}), r("AI 에이전트",{color:C.blueB}), r(" 본격 침투 중",{color:C.white}) ]);
  tbl(s, [
    [th("솔루션"), th("AI 에이전트"), th("도입 현황 · 출시 시점")],
    [tdHi([r("Jira (Atlassian)",{bold:true,color:C.blueB}),r("\n글로벌 1위",{color:C.dim,fontSize:PT(10)})]), tdHi("Rovo Agents",{bold:true,color:C.white}), tdHi([r("엔터프라이즈 클라우드 고객 90%+ 사용",{bold:true,color:C.white}),r(" · 월간 활성 500만 · 240만 AI 에이전트 사용 사례 · Jira Agents 2026.02 출시",{color:C.gray})])],
    [td([r("Monday.com",{bold:true,color:C.white}),r("\n시각 보드 강자",{color:C.dim,fontSize:PT(10)})]), td("Sidekick + Agents",{bold:true,color:C.white}), td([r("AI 성숙도 50점 중 36점 (1위 동률)",{bold:true,color:C.white}),r(" · 자연어로 작업·일정·회의록 생성 · 보드 자동 스캔 위험 감지",{color:C.gray})])],
    [td([r("Asana",{bold:true,color:C.white}),r("\n2025 Q4 1.88억$",{color:C.dim,fontSize:PT(10)})]), td("AI Studio + Teammates",{bold:true,color:C.white}), td([r("AI Studio",{bold:true,color:C.white}),r(" 무코드 워크플로 빌더 · ",{color:C.gray}),r("AI Teammates",{bold:true,color:C.white}),r(" 2025 가을 베타 · 양의 자유 현금 흐름 달성",{color:C.gray})])],
    [td([r("ClickUp",{bold:true,color:C.white}),r("\n외부 8,000개+",{color:C.dim,fontSize:PT(10)})]), td("Brain + Super Agents",{bold:true,color:C.white}), td([r("Autopilot",{bold:true,color:C.white}),r(" 룰 + 자동 작업 할당 + 하위 작업·종속성 자동 생성 · Brain2 AI $9/사용자/월",{color:C.gray})])],
    [td([r("Notion",{bold:true,color:C.white}),r("\n월 +0.6%p 성장",{color:C.dim,fontSize:PT(10)})]), td("Notion AI",{bold:true,color:C.white}), td("Q&A 검색 + Autofill + AI Meeting Notes · 2025.05 단독 상품 종료 후 Business·Enterprise 통합",{color:C.gray})],
  ], 64, 196, 1152, [200, 230, 722], { fontSize:PT(11.5), rowH:[X(32)].concat(Array(5).fill(X(64))) });
  embar(s, 596, [ r("함의",{color:C.blueB}), r(" — 글로벌 5개사 모두 자율 에이전트 단계 진입 중. KISS도 ",{color:C.white}), r("자체 AI 에이전트 출시 가속",{color:C.purpleB}), r(" 필요",{color:C.white}) ]);
  footer(s, "07");
}

// ════════════════ SLIDE 8 — AI 네이티브 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "신흥 카테고리 · AI-Native");
  centerTitle(s, "Emerging Category", [ r("처음부터 ",{color:C.white}), r("AI 중심으로 재설계",{color:C.purpleB}), r("된 신규 진입자",{color:C.white}) ]);
  lab(s, 64, 192, 600, "시장 진화 3단계");
  const gens = [
    ["1세대 · ~2023년","사람이 도구로 관리","Notion · Jira · Asana 등 기존 솔루션", false],
    ["2세대 · 2024~2025년","사람 + AI 보조","Asana Intelligence · ClickUp Brain · Jira Rovo · Notion AI", false],
    ["3세대 · 부상 중 · 2026년~","AI 에이전트가 수행 주체","Rovo (90%+) · Jira Agents (2026.02) · Construction AI (2026.03) · 사람은 감독·승인으로 전환", true],
  ];
  const cw=368, gap=24, x0=64, gy=216;
  gens.forEach((g,i)=>{
    const x=x0+i*(cw+gap);
    card(s, x, gy, cw, 130, g[3]?"1E2348":C.card);
    if(g[3]) s.addShape(pres.shapes.ROUNDED_RECTANGLE, { x:X(x), y:X(gy), w:X(cw), h:X(130), rectRadius:0.08, fill:{type:"none"}, line:{color:C.purple, width:1.5} });
    s.addText(g[0], { x:X(x+18), y:X(gy+14), w:X(cw-36), h:X(20), margin:0, fontFace:TITLE, bold:true, fontSize:PT(14), color:g[3]?C.purpleB:C.white });
    s.addText([ r(g[1],{bold:true,color:C.white}), r("\n"+g[2],{color:C.gray}) ], { x:X(x+18), y:X(gy+40), w:X(cw-36), h:X(82), margin:0, fontFace:TEXT, fontSize:PT(12), lineSpacingMultiple:1.35, valign:"top" });
  });
  lab(s, 64, 372, 800, "AI 네이티브 신규 진입자 — 새 시장 카테고리 형성");
  tbl(s, [
    [th("진입자"), th("포지셔닝"), th("주요 내용")],
    [td("Construction AI",{bold:true,color:C.white}), td("건설 산업 특화 · 영국"), td([r("2026.03 출시",{bold:true,color:C.white}),r(" · 처음부터 인공지능 중심 재설계된 ",{color:C.gray}),r("최초의 건설 PMS",{bold:true,color:C.white}),r(" · UK 1,700억 파운드 건설 시장 대상",{color:C.gray})])],
    [td("Plane",{bold:true,color:C.white}), td("일반 프로젝트 관리"), td("AI 네이티브 프로젝트 관리를 표방하는 신생 플랫폼")],
    [td("Forecast PSA",{bold:true,color:C.white}), td("프로젝트·자원 관리"), td("자동 추정 · 예측 일정 · AI 기반 예산 추적 · 단일 통합 뷰")],
  ], 64, 400, 1152, [200, 230, 722], { fontSize:PT(12), rowH:[X(32)].concat(Array(3).fill(X(52))) });
  footer(s, "08");
}

// ════════════════ SLIDE 9 — 차별화 6축 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "차별화 포지셔닝 · Positioning");
  centerTitle(s, "Differentiation", [ r("Amaranth 10 KISS의 ",{color:C.white}), r("차별화 6축",{color:C.blueB}) ]);
  const items = [
    ["① 가격 경쟁력", C.blueB, [r("Amaranth 10 라이선스 통합 — ",{color:C.gray}),r("별도 구매 없이 사용",{bold:true,color:C.white}),r(". 글로벌 7~28달러 대비 우위.",{color:C.gray})]],
    ["② 모듈 통합", C.blueB, [r("법무·고객관계관리·게시판·연락처 + ONE AI 통합. ",{color:C.gray}),r("어디에도 없는 ERP+협업+AI 통합",{bold:true,color:C.white}),r(".",{color:C.gray})]],
    ["③ 한국 시장 최적화", C.blueB, [r("한국어 지원 + 결재·근태·캘린더 표준 정합.",{color:C.gray})]],
    ["④ 자동 보고서", C.purpleB, [r("고도화 완료 목표 ",{color:C.gray}),r('"관리자 보고 100% 자동"',{bold:true,color:C.white}),r(". ERP 데이터 연계 자동 보고서 우위.",{color:C.gray})]],
    ["⑤ ERP 내장 통합", C.purpleB, [r("회계·인사·근태·결재 ",{color:C.gray}),r("동일 플랫폼 내장",{bold:true,color:C.white}),r(". 글로벌은 외부 ERP에 미들웨어 별도 연동 필요.",{color:C.gray})]],
    ["⑥ AI 에이전트 자율 운영", C.purpleB, [r("AI 에이전트 마켓플레이스 국내 최초(2025.12)",{bold:true,color:C.white}),r(" + 삼일 PwC 'ERP 자율 실행' 평가.",{color:C.gray})]],
  ];
  const cw=368, gap=24, ch=200, x0=64, y0=200, gapY=24;
  items.forEach((it,i)=>{
    const col=i%3, row=Math.floor(i/3);
    const x=x0+col*(cw+gap), y=y0+row*(ch+gapY);
    card(s, x, y, cw, ch, C.card);
    s.addText(it[0], { x:X(x+20), y:X(y+22), w:X(cw-40), h:X(26), margin:0, fontFace:TITLE, bold:true, fontSize:PT(15), color:it[1] });
    s.addText(it[2], { x:X(x+20), y:X(y+58), w:X(cw-40), h:X(120), margin:0, fontFace:TEXT, fontSize:PT(13.5), color:C.gray, lineSpacingMultiple:1.45, valign:"top" });
  });
  footer(s, "09");
}

// ════════════════ SLIDE 10 — SWOT ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "종합 분석 · SWOT");
  centerTitle(s, "SWOT Analysis", [ r("강점·약점·기회·위협 ",{color:C.white}), r("한눈 정리",{color:C.blueB}) ]);
  const Q = [
    ["강점 Strengths", C.good, ["한국 그룹웨어 2위 (12% 점유) · Amaranth 10 168% 성장","Amaranth 10 모듈 통합 + ERP 내장 통합","ONE AI 1년 7,000사·118K명 도입 속도","AI 에이전트 마켓플레이스 국내 최초 (2025.12)","자율 경영 전략 + 삼일 PwC 공식 평가"]],
    ["약점 Weaknesses", C.warn, ["프로젝트 관리 단독 기능 깊이 부족 (Notion·Jira·Asana 대비)","한국 중심 · 글로벌 인지도 격차","시각 협업 기능 (간트·칸반) 글로벌 대비 표준","외부 연동 제한적 (ClickUp 8,000개+ 대비)","글로벌 AI 에이전트 인지도 격차 — Rovo 90%+ 도입"]],
    ["기회 Opportunities", C.blueB, ["AI 주도 프로젝트 관리 시장 부상 — Gartner 2026년 말 40% 통합","McKinsey 'SaaS 혁명 이상의 변혁기'","자체 인공지능(ONE AI) 연계로 차별화 강화","한국 ERP·협업 통합 수요 확대","한국 중소기업 AI 도입률 5.3% 초기 단계 — 성장 여지 큼"]],
    ["위협 Threats", C.purpleB, ["AI 네이티브 신규 진입자 — Construction AI·Plane·Forecast","글로벌 솔루션 한국 진출 가속","한국 토종 솔루션 경쟁 심화","인공지능 영역 빠른 변화 (Rovo·AI Studio·Brain)","Gartner 경고 — 2027년 말 에이전틱 AI 40%+ 취소 예측"]],
  ];
  const cw=565, gap=22, ch=216, x0=64, y0=196, gapY=16;
  Q.forEach((q,i)=>{
    const col=i%2, row=Math.floor(i/2);
    const x=x0+col*(cw+gap), y=y0+row*(ch+gapY);
    card(s, x, y, cw, ch, C.card);
    s.addShape(pres.shapes.OVAL, { x:X(x+18), y:X(y+18), w:X(10), h:X(10), fill:{color:q[1]} });
    s.addText(q[0], { x:X(x+34), y:X(y+12), w:X(cw-50), h:X(22), margin:0, fontFace:TITLE, bold:true, fontSize:PT(15), color:q[1] });
    s.addShape(pres.shapes.LINE, { x:X(x+18), y:X(y+42), w:X(cw-36), h:0, line:{color:C.cardLine, width:0.75} });
    const runs = q[2].map(t=> r(t,{color:C.gray, bullet:{indent:14}, breakLine:true}));
    s.addText(runs, { x:X(x+18), y:X(y+50), w:X(cw-36), h:X(156), margin:0, fontFace:TEXT, fontSize:PT(11.5), color:C.gray, lineSpacingMultiple:1.05, paraSpaceAfter:PT(5) });
  });
  footer(s, "10");
}

// ════════════════ SLIDE 11 — 권장 전략 5순위 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "권장 전략 · Recommendations");
  centerTitle(s, "Recommendations", [ r("권장 전략 ",{color:C.white}), r("5순위",{color:C.blueB}) ]);
  const strat = [
    ["1","최우선","AI 에이전트 친화 프로젝트 관리 플랫폼으로 재포지셔닝", [r("단순 프로젝트 관리가 아닌 ",{color:C.gray2}),r("AI 에이전트가 잘 사용할 수 있도록 설계된 플랫폼",{bold:true,color:C.white}),r("으로 재포지셔닝. Gartner '2026년 말 전체 기업 앱 40% 통합' 예측 대응. 모듈 단일 라이선스 + 자체 ONE AI 연계라는 고유 강점 활용 — 외부 솔루션이 못 가진 ",{color:C.gray2}),r("데이터 주권·통합 접근 우위",{bold:true,color:C.purpleB}),r(" 강조.",{color:C.gray})]],
    ["2","","3단계 계층 + 자동 보고서 정착", [r("진행 중인 고도화 재설계 정착 — 프로젝트 → 업무 → 할 일 3단계 + 자동 보고서 누적. ",{color:C.gray2}),r("AI 에이전트가 작업 단위로 자율 수행 가능한 데이터 구조 토대",{bold:true,color:C.white}),r(".",{color:C.gray})]],
    ["3","","자체 AI 에이전트 출시 가속", [r("글로벌 솔루션이 이미 엔터프라이즈 본격 침투 중 (Rovo 90%+, Jira Agents 2026.02). 자체 ONE AI 연계 에이전트 출시 가속 없으면 ",{color:C.gray2}),r("시장 진입 격차 확대",{bold:true,color:C.white}),r(" 위험.",{color:C.gray})]],
    ["4","","한국 토종 협업툴 대상 차별화 마케팅", [r("네이버웍스·카카오워크·플로우·잔디에 없는 ",{color:C.gray2}),r("ERP 통합·자동 보고서·AI 에이전트 친화",{bold:true,color:C.white}),r(" 강점 마케팅.",{color:C.gray})]],
    ["5","","시각 협업 기능 보강 + 외부 연동 확대", [r("Monday·Asana 시각 보드·타임라인·간트 정합 검토 + 외부 도구 연동 확대 — 글로벌 대비 약점 보완.",{color:C.gray})]],
  ];
  card(s, 64, 196, 1152, 448, C.card);
  const rowH=[120, 78, 78, 78, 78]; let yy=210;
  strat.forEach((st,i)=>{
    s.addText([ r(st[0],{color:C.blueB}), ...(st[1]?[r("\n"+st[1],{color:C.dim, fontSize:PT(9), bold:true})]:[]) ],
      { x:X(86), y:X(yy), w:X(64), h:X(rowH[i]-14), margin:0, fontFace:TITLE, bold:true, fontSize:PT(30), align:"center", valign:"top" });
    s.addText(st[2], { x:X(166), y:X(yy), w:X(1030), h:X(24), margin:0, fontFace:TITLE, bold:true, fontSize:PT(14.5), color:C.white });
    s.addText(st[3], { x:X(166), y:X(yy+26), w:X(1030), h:X(rowH[i]-40), margin:0, fontFace:TEXT, fontSize:PT(12.5), lineSpacingMultiple:1.4, valign:"top" });
    if(i<strat.length-1) s.addShape(pres.shapes.LINE, { x:X(86), y:X(yy+rowH[i]-6), w:X(1110), h:0, line:{color:C.tblLine, width:0.5} });
    yy += rowH[i];
  });
  footer(s, "11");
}

// ════════════════ SLIDE 12 — 위험·한계 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "위험 요인 · Risks & Limits");
  centerTitle(s, "Risks & Limitations", [ r("기회와 함께 보는 ",{color:C.white}), r("위험과 미확인 영역",{color:C.purpleB}) ]);
  card(s, 64, 196, 558, 448, C.card);
  lab(s, 86, 214, 514, "A. 시장 진화 위험 요인 (Gartner 경고)");
  tbl(s, [
    [tdHi("2027년 말",{bold:true,color:C.white}), tdHi([r("에이전틱 AI 프로젝트 40%+ 취소 예측",{color:C.purpleB,bold:true}),r("\n비용 상승 · 불명확한 사업 가치 · 위험 통제 부족",{color:C.gray2,fontSize:PT(10.5)})])],
    [td("도입 실적",{color:C.gray}), td("17%만 실제 배포 · 60%+ 향후 2년 내 배포 예정")],
    [td("실행 현황",{color:C.gray}), td([r("30% 탐색 · 38% 시범 운영 · ",{color:C.gray}),r("11%만 실제 운영",{bold:true,color:C.white})])],
    [td("레거시 한계",{color:C.gray}), td("최신 AI 실행 요구 미지원 → 40%+ 실패 예측")],
  ], 86, 244, 514, [110, 404], { fontSize:PT(12), rowH:[X(58),X(40),X(40),X(40)] });
  s.addShape(pres.shapes.RECTANGLE, { x:X(86), y:X(450), w:X(4), h:X(80), fill:{color:C.blue} });
  card(s, 98, 450, 502, 80, "1A2038");
  s.addText([ r("의사결정 함의",{color:C.blueB,bold:true}), r(" — 시장 성장 기회와 함께 ",{color:C.gray}), r("투자 시점·범위·통제 체계",{bold:true,color:C.white}), r("를 균형 있게 설계해야 함.",{color:C.gray}) ],
    { x:X(116), y:X(458), w:X(470), h:X(64), margin:0, fontFace:TEXT, fontSize:PT(13), lineSpacingMultiple:1.35, valign:"middle" });
  card(s, 646, 196, 570, 448, C.card);
  lab(s, 668, 214, 526, "B. 본 보고서 한계 · 미확인 영역");
  const lims = [
    ["한국 시장 정밀 규모"," — Bonafide Research 본문 검증 필요"],
    ["글로벌 솔루션 한국 점유율"," — 한국 사용자 정밀 자료"],
    ["한국 토종 사용자 규모"," — 정확한 매출 자료"],
    ["AI 네이티브 정밀 비교"," — 기능·가격·도입 사례"],
    ["한국 AI 에이전트 PM 도입 사례"," — 실제 도입 사례"],
    ["진행 중인 고도화 원피스 자료"," — 벤치마킹·영향도·할 일 프로세스 정밀 정찰 보류"],
    ["KISS 코드값·원피스 동기화·일괄등록 양식"," 확인 필요"],
  ];
  const runs=[];
  lims.forEach(l=>{
    runs.push(r(l[0],{bold:true,color:C.white,bullet:{indent:16}}));
    runs.push(r(l[1],{color:C.gray,breakLine:true}));
  });
  s.addText(runs, { x:X(668), y:X(244), w:X(526), h:X(386), margin:0, fontFace:TEXT, fontSize:PT(12.5), color:C.gray, lineSpacingMultiple:1.1, paraSpaceAfter:PT(10) });
  footer(s, "12");
}

// ════════════════ SLIDE 13 — 다음 사이클 + 마무리 ════════════════
{
  const s = pres.addSlide();
  s.background = { path: BG_BODY };
  header(s, "다음 사이클 · Next Steps");
  centerTitle(s, "Next Steps", [ r("다음 단계 ",{color:C.white}), r("3개 사이클",{color:C.blueB}), r("로 이어집니다",{color:C.white}) ]);
  const cyc = [
    ["사이클 ① 벤치마킹 보고서","글로벌 주요 5개사 + 한국 토종 4개사 + AI 네이티브 신규 진입자 (Construction AI·Plane·Forecast) 정밀 비교 — 별도 사이클 진입."],
    ["사이클 ② 요구사항 정의서","본 시장 분석 + 더존비즈온 자산 (고도화 완료 목표·재설계) + AI 에이전트 친화 플랫폼 요구사항 종합 — 별도 사이클 진입."],
    ["사이클 ③ 본 보고서 보강","한국 시장 정밀 영역 + 한국 AI 에이전트 도입 정밀 사례 + 진행 중인 고도화 사업의 벤치마킹 원피스 자료 정밀 정찰."],
  ];
  const cw=368, gap=24, x0=64, cy=196, ch=176;
  cyc.forEach((c,i)=>{
    const x=x0+i*(cw+gap);
    chipCard(s, x, cy, cw, ch, c[0]);
    s.addText(c[1], { x:X(x+18), y:X(cy+54), w:X(cw-36), h:X(108), margin:0, fontFace:TEXT, fontSize:PT(12.5), color:C.gray, lineSpacingMultiple:1.5, valign:"top" });
  });
  // 풀쿼트
  s.addShape(pres.shapes.RECTANGLE, { x:X(64), y:X(408), w:X(4), h:X(120), fill:{color:C.blue} });
  card(s, 76, 408, 1140, 120, C.card);
  s.addText([
    r('"프로젝트 관리의 주체가 사람에서 인공지능으로 이동 중이다."\n',{color:C.white, fontSize:PT(20)}),
    r("Amaranth 10 KISS의 답은 — AI 에이전트 친화 프로젝트 관리 플랫폼.",{color:C.purpleB, bold:true, fontSize:PT(17)}),
  ], { x:X(98), y:X(420), w:X(1000), h:X(76), margin:0, fontFace:TITLE, lineSpacingMultiple:1.3, valign:"middle" });
  s.addText("2026.05.28 · 차민수 (PM)", { x:X(98), y:X(498), w:X(600), h:X(18), margin:0, fontFace:TEXT, fontSize:PT(11), color:C.dim, charSpacing:1 });
  // Thank You
  s.addText("Thank You", { x:X(816), y:X(556), w:X(400), h:X(40), margin:0, fontFace:TITLE, bold:true, fontSize:PT(30), color:C.purpleB, align:"right" });
  s.addText("Q & A", { x:X(816), y:X(598), w:X(400), h:X(20), margin:0, fontFace:TEXT, fontSize:PT(12), color:C.dim, align:"right" });
  footer(s, "13");
}

pres.writeFile({ fileName: path.join(DIR, "2026-05-28-프로젝트관리-시장분석-발표자료.pptx") })
  .then(fn => console.log("생성 완료:", fn))
  .catch(e => { console.error("ERROR:", e); process.exit(1); });
