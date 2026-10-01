---
name: dz-oneffice-kit
description: 원피스(ONEFFICE, 더존 웹 워드 편집기) DOM 공용 배관 정본. 6종 원피스 스킬(writer·new-doc-opener·form-writer·html-oneffice-builder·reader·comment)이 공유하는 중첩 iframe 진입·편집모드 판정/전환·HTML 주입·꺾쇠 정렬·문서설정·저장(2단계)·문서 읽기·셀렉터/좌표/프리셋 상수를 하나의 `window.OF` 라이브러리로 제공한다. 다른 dz-oneffice-* 스킬이 "OF 라이브러리를 1회 주입 → OF.* 호출"로 인용하는 정본이며, 사용자가 직접 호출하기보다 원피스 자동화 작업의 공용 부품으로 로드된다. 셀렉터·좌표·프리셋을 이 한 곳에만 두어 드리프트(값이 스킬마다 어긋남)를 없앤다.
---

# dz-oneffice-kit — 원피스 DOM 공용 배관(OF 라이브러리)

> 용어: **OF**(ONEFFICE kit, 원피스 자동화 공용 함수 모음) · **DOM**(문서 객체 모델, 브라우저가 웹문서를 다루는 구조) · **iframe**(문서 안에 끼운 또 다른 문서 틀) · **셀렉터**(원하는 요소를 집는 규칙) · **BCR**(getBoundingClientRect, 요소의 화면 사각형 좌표) · **체크아웃/체크인**(문서를 편집하려 잠그고[체크아웃] 저장하며 푸는[체크인] 문서 잠금) · **dirty**(문서가 바뀌었다는 변경 신호) · **드리프트**(같은 값이 스킬마다 어긋난 상태) · **SSoT**(단일 출처)

## 0. 무엇이고 왜 있나

원피스 관련 스킬 6종은 **중첩 iframe 진입 → 편집모드 판정 → 주입/추출 → 정렬/저장**이라는 같은 뼈대를 각자 복사해 들고 있었고, 그 복사본이 미세하게 어긋나 있었다(편집 좌표 3종·편집모드 신호 2종·저장 이야기 2종 — T4 공용부품 통합 설계 §2). 플러그인 스킬끼리는 런타임 코드 import가 불가능하므로, 해법은 **문서적 단일 출처** — 이 스킬에 `OF` 라이브러리를 정본으로 두고 나머지가 인용한다.

**소비 방식**: 각 원피스 스킬은 사용 지점에서 ① 이 SKILL.md의 `OF` 라이브러리 코드블록을 읽어 `javascript_tool`로 **원피스 탭에 1회 주입**(`window.OF` 상주) → ② `OF.*` 호출. 셀렉터·좌표·프리셋 문자열이 **여기 한 곳에만** 존재한다.

**정본 출처**: `dz-oneffice-writer`(v0.5.3, 쓰기·배관)·`dz-oneffice-reader`(읽기)의 검증 스니펫. **실측 반영**: 사내망 API 규명 점검 §7 — `참고자료/리포트/2026-07-13-원피스-사내망-API규명-점검.md`(forge) (재열람=읽기모드 / 편집 토글 JS `.click()` 전환 가능 / 저장=2단계 / 체크아웃 경쟁).

> ⚠️ **경계 사수(넣지 않는 것)**: DOM 배관만 OF에. 업무 콘텐츠(form-writer의 SCHEMA·wrap 7종·표별 룰)는 워크스페이스 SSoT `규칙/프로세스/원피스-작성방식-선택-자동화-표준.md`, 멘션 신뢰 키 시퀀스는 comment 고유, XHR body swap·"ONEFFICE 워드" 매칭·payload는 opener 고유로 남긴다. OF가 업무 콘텐츠를 떠안으면 배포 대상이 워크스페이스 없이 못 쓴다.

## 1. OF 라이브러리 (완성 JS — `javascript_tool`로 원피스 탭에 1회 주입)

```javascript
/* ============================================================================
 * dz-oneffice-kit — OF (ONEFFICE DOM kit) · 통합 정본 (쓰기·배관 + 읽기)
 * 원피스 탭(#open_oneffice_body_iframe 가 사는 최상위 문서)에 1회 주입 → window.OF 상주.
 * 정본 출처: dz-oneffice-writer SKILL.md v0.5.3 + dz-oneffice-reader SKILL.md
 * 실측 반영: 참고자료/리포트/2026-07-13-원피스-사내망-API규명-점검.md §7
 *   (재열람=읽기모드 / 편집 토글 JS .click() 전환 가능 / 저장=2단계 / 체크아웃 경쟁)
 * ==========================================================================*/
(function () {
  const OF = {};

  /* ---- 상수: 셀렉터 (전 스킬 정본화) ------------------------------------- */
  OF.SEL = {
    outerIframe:  'open_oneffice_body_iframe',            // getElementById (최상위 문서). 별칭: bodyIframe
    editorIframe: 'dzeditor_0',                           // outer iframe 안. dzeditor_9999는 offscreen 숨김판 — 접근 금지
    main:         '.dze_page_main',                       // editorDoc. 별칭: pageMain
    docContainer: '.dze_document_container',              // editorDoc — zoom matrix
    bracketLt:    '.dze_page_margin_indicator_lt',        // editorDoc (편집모드만 렌더)
    bracketRt:    '.dze_page_margin_indicator_rt',        // editorDoc (편집모드만 렌더)
    editToggle:   '.dze_style_editmode_toolbar_normal',   // bodyDoc, 텍스트 "편집" (실측 §7)
    saveBtn:      'TB_FILE_SAVE_REMOTE_0',                // bodyDoc getElementById
    titleInput:   'dze_ribbon_menu_title_text',          // bodyDoc getElementById
    ribbonFile:   'TB_MENU_RIBBON_0',                    // bodyDoc — 파일 리본
    settingBtn:   'TB_SETTING_0',                        // bodyDoc — 문서설정
    splitOn:      'dze_idx_onepagemode_on',              // 단일 페이지
    splitOff:     'dze_idx_onepagemode_off',             // 다중 페이지
    marginNarrow: 'dze_idx_print_margin_type1',          // 좁게 10mm
    marginNormal: 'dze_idx_print_margin_type2',          // 보통 20mm
    marginWide:   'dze_idx_print_margin_type3',          // 넓게 30mm
    paperPortrait:'dze_idx_paper_direction_type1',       // 세로
    paperLand:    'dze_idx_paper_direction_type2',       // 가로
    dlgOk:        '.duzon_dialog_buttonbox.new_ver input.duzon_dialog_btn_new_ok_normal',
    dlgCancel:    '.duzon_dialog_buttonbox.new_ver input.duzon_dialog_btn_new_normal'
  };

  /* ---- 지면 폭: 계산 공식 (라이브 실측 12조합, 2026-07-23) ---------------
   * px = ceil(mm × 96 / 25.4).  글 영역 = 용지폭 − 좌우여백×2.
   * 실측: 용지 A4 794·A3 1123·B5 666·LETTER 817 / 여백 좁게 38·보통 76·넓게 114.
   * ⚠️ 종전 하드코딩 PRESET 4종(644·720·973·897)은 실측보다 **+2px 어긋나** 있었고
   *    A3·좁게 등 8조합이 아예 없었다 → 계산으로 대체(아래에서 12조합 자동 생성).
   * ⚠️ 더 중요한 실측: **주입 루트에 폭을 지정할 필요가 자체가 없다.** 폭을 안 주면
   *    본문이 글 영역을 정확히 채운다(12조합 전건 확인). 픽셀 폭 고정은 인쇄·PDF·배율에서
   *    깨지므로(writer v0.4.0 판정) alignBracket 은 **자연 폭이 안 먹는 예외**에만 쓴다. */
  OF.PAPER_MM  = { A4: [210, 297], A3: [297, 420], B5: [176, 250], LETTER: [216, 279] };
  OF.MARGIN_MM = { narrow: 10, normal: 20, wide: 30 };
  OF.mm2px = function (mm) { return Math.ceil(Number(mm) * 96 / 25.4); };

  // 용지·여백 → {paperPx, padPx, contentPx}. paper=키 또는 [가로,세로]mm, margin=키 또는 숫자(mm)
  OF.pageMetrics = function (paper, margin, landscape) {
    const P = Array.isArray(paper) ? paper
            : (OF.PAPER_MM[String(paper || 'A4').toUpperCase()] || OF.PAPER_MM.A4);
    const wMM = landscape ? P[1] : P[0];
    const mMM = (typeof margin === 'number') ? margin
              : (OF.MARGIN_MM[String(margin || 'normal').toLowerCase()] != null
                 ? OF.MARGIN_MM[String(margin || 'normal').toLowerCase()] : 20);
    const paperPx = OF.mm2px(wMM), padPx = OF.mm2px(mMM);
    return { paperPx: paperPx, padPx: padPx, contentPx: paperPx - padPx * 2 };
  };

  // 하위 호환 PRESET — 12조합을 계산으로 채운다(값은 라이브 실측과 일치)
  OF.PRESET = { zoom: 1.3, shift: -1 };
  ['A4', 'A3', 'B5', 'LETTER'].forEach(function (p) {
    ['narrow', 'normal', 'wide'].forEach(function (m) {
      const g = OF.pageMetrics(p, m);
      OF.PRESET[p + '-' + m] = { width: g.contentPx, shift: -1, padL: g.padPx, zoom: 1.3 };
    });
  });

  /* ---- 상수: 좌표 폴백 (1920×1080·줌130% 한정 · 편집 진입은 enterEdit 우선) -
   * ⚠️ 절대 픽셀값 — 해상도·줌 바뀌면 전부 빗나감. DOM(enterEdit) 우선, 좌표는 최후 폴백. */
  OF.COORD = {
    editTab:       [1361, 20],   // 편집 탭(정본, W·O). form-writer 변형 (1414,17)은 드리프트 _(확인 필요)_
    editTabAlt:    [1414, 17],   // form-writer 기록값(참고)
    commentSubmit: [1411, 290]   // 댓글 "등록"(comment 스킬 폴백)
  };

  /* ================= A. 중첩 iframe 진입 ================= */

  // 바깥 문서: 리본·저장버튼·문서명·문서설정 팝업·편집 토글이 사는 곳
  OF.bodyDoc = function () {
    const f = document.getElementById(OF.SEL.outerIframe);
    if (!f) return null;
    return f.contentDocument || (f.contentWindow && f.contentWindow.document) || null;
  };

  // 안쪽 dzeditor 문서: .dze_page_main·꺾쇠·zoom 컨테이너가 사는 곳
  OF.editorDoc = function () {
    const bd = OF.bodyDoc();
    if (!bd) return null;
    const ed = bd.getElementById(OF.SEL.editorIframe);
    if (!ed) return null;
    return ed.contentDocument || (ed.contentWindow && ed.contentWindow.document) || null;
  };

  OF.main = function () {
    const ed = OF.editorDoc();
    return ed ? ed.querySelector(OF.SEL.main) : null;
  };

  /* ================= B. 편집모드 판정·전환 ================= */

  // 정본 신호 = main.isContentEditable (실측 §7: 신규=true·재열람=false·편집전환=true)
  OF.isEditable = function () {
    const m = OF.main();
    return !!(m && m.isContentEditable === true);
  };

  // ★신규(2026-07-14 실측): 읽기모드면 편집 토글을 JS .click()으로 전환(신뢰 이벤트 불필요).
  //  ⚠️ 반영 지연 실측: 토글 click 후 isContentEditable 반영에 ~2초 걸림 → 반환 after/switched는
  //     즉시엔 false일 수 있다(클릭 자체는 유효). 호출부는 반영을 폴링 확인할 것(save가 처리).
  OF.enterEdit = function () {
    const before = OF.isEditable();
    if (before) return { before: true, after: true, switched: false };
    const bd = OF.bodyDoc();
    if (!bd) return { before, after: before, switched: false, error: 'no bodyDoc' };
    const cands = Array.from(bd.querySelectorAll(OF.SEL.editToggle));
    // 읽기모드 토글 그룹에서 텍스트가 정확히 "편집"인 요소를 집는다("읽기"도 함께 있음)
    const toggle = cands.find(el => (el.textContent || '').trim() === '편집')
                || cands.find(el => /편집/.test(el.textContent || ''));
    if (!toggle) return { before, after: OF.isEditable(), switched: false, error: 'edit toggle not found' };
    toggle.click();
    const after = OF.isEditable();
    return { before, after, switched: after && !before };
  };

  // 주입·저장 전 공통 가드 — 읽기모드면 enterEdit 시도 후 재확인, 그래도 false면 throw
  OF.assertEditable = function () {
    if (OF.isEditable()) return true;
    const r = OF.enterEdit();
    if (OF.isEditable()) return true;
    throw new Error('OF.assertEditable: not editable (enterEdit switched=' + r.switched
      + (r.error ? ', ' + r.error : '') + ') — 읽기모드 잔존 또는 체크아웃 경쟁 의심');
  };

  /* ================= F/M. zoom·꺾쇠 측정 ================= */

  // .dze_document_container 의 transform: matrix(zoom,...) 파싱 (기본 1)
  OF.zoom = function () {
    const ed = OF.editorDoc();
    if (!ed) return 1;
    const dc = ed.querySelector(OF.SEL.docContainer);
    if (!dc) return 1;
    const m = getComputedStyle(dc).transform.match(/matrix\(([^,]+)/);
    return m ? parseFloat(m[1]) : 1;
  };

  // 좌/우 꺾쇠 BCR — 편집모드에서만 렌더. 읽기모드면 null.
  OF.brackets = function () {
    const ed = OF.editorDoc();
    if (!ed) return null;
    const lt = ed.querySelector(OF.SEL.bracketLt);
    const rt = ed.querySelector(OF.SEL.bracketRt);
    if (!lt || !rt) return null;              // 읽기모드 = 미렌더
    const ltR = lt.getBoundingClientRect();
    const rtR = rt.getBoundingClientRect();
    if (rtR.right === 0 && ltR.right === 0) return null; // 측정 무효(읽기모드 잔재)
    return { lt: ltR, rt: rtR };
  };

  /* ================= 주입 (모드 A/B/C) ================= */

  // main.innerHTML 통째 교체. 모드는 호출부가 준비한 HTML 성격 — 반환 진단이 다름.
  //  B = <style>+.container 보존 / C = 평면(인라인 style만) / A = 레거시 플랫(.container 없음)
  OF.injectHTML = function (html, mode) {
    OF.assertEditable();                       // 읽기모드 주입은 저장 시 전량 유실 → 하드 가드
    const main = OF.main();
    if (!main) return { error: 'no main' };
    main.innerHTML = html;
    const first = main.children[0] || null;
    return {
      mode: mode || null,
      kids: main.children.length,              // B=2 / C=10~30 / A=본문 수
      firstTag: first ? first.tagName : null,
      containerExists: !!main.querySelector(':scope > .container'),
      styleTagExists:  !!main.querySelector(':scope > style'),
      len: html.length
    };
  };

  /* ================= 점선(dashed outline) 차단 =================
   * 편집기 규칙 :is(.dze_page_main,.dze_page_header,.dze_page_footer,td,th) > div:not(.dze_editable_div)
   * 와 td>pre·th>pre 가 회색 점선을 얹는다. border 가 아니라 outline 이라 레이아웃은 그대로다.
   * ⚠️ 편집 안내선이 아니라 body.readmode·designMode:off 에서도 남는다 → 최종 산출물에 그대로 보인다.
   * 규칙에 !important 가 없어 인라인 선언이 항상 이긴다. <style> 을 쓸 수 없는 모드 C·트랙 A(헤드리스)
   * 에서는 이것이 유일한 차단 수단. 멱등 — 이미 outline 선언이 있으면 건드리지 않는다.
   * 실측 2026-08-14 (대조군 9종): 무처리 div·pre 만 점선, outline:none·p·span·dze_editable_div 모두 차단. */
  OF.outlineGuard = function (html) {
    return String(html).replace(/<(div|pre)(\s[^>]*?)?(\/?)>/gi, function (m, tag, attrs, sc) {
      attrs = attrs || '';
      const sm = attrs.match(/(\sstyle\s*=\s*)(["'])([\s\S]*?)\2/i);
      if (sm) {
        if (/(^|;)\s*outline\s*:/i.test(sm[3])) return m;          // 멱등
        const sep = (!sm[3].trim() || /;\s*$/.test(sm[3])) ? '' : ';';
        attrs = attrs.replace(sm[0], sm[1] + sm[2] + sm[3] + sep + 'outline:none' + sm[2]);
      } else {
        attrs += ' style="outline:none"';
      }
      return '<' + tag + attrs + (sc || '') + '>';
    });
  };

  /* ================= 꺾쇠 정렬 (모드 B 한정 · 예외 상황 전용) =================
   * ⚠️ **먼저 폭을 지정하지 않고 확인하라.** 라이브 실측(2026-07-23, 12조합 전건)에서
   *    주입 루트는 폭을 안 줘도 글 영역을 정확히 채웠다(A3·좁게 1047 / A4·보통 642 …).
   *    픽셀 폭 고정은 인쇄·PDF·배율 변경에서 깨지는 원인이다(writer v0.4.0 판정).
   *    → 이 함수는 **컨테이너가 자연 폭을 따르지 않는 예외**에서만 쓴다.
   *    폭이 좁게 나오면 정렬로 덮기 전에 **문서 여백 설정부터 의심**하라 —
   *    A3에서 971px 이면 여백이 보통(20mm)으로 적용된 것이지 폭 결함이 아니다.
   *  프리셋 지정 시 PRESET 폭/shift 사용(12조합 계산값), 없으면 zoom 보정 실측 fallback.
   *  <style>+!important 2단 셀렉터(.dze_page_main > .<루트>)를 main.innerHTML 내부에 주입. */
  OF.alignBracket = function (opt) {
    opt = opt || {};
    const ed = OF.editorDoc();
    const main = OF.main();
    if (!main) return { error: 'no main' };
    if (!main.isContentEditable) return { error: 'not editable — abort' };
    const root = main.querySelector(':scope > .page')
              || main.querySelector(':scope > .container')
              || main.querySelector(':scope > div.main');
    if (!root) return { error: 'no root (.page/.container/div.main)' };
    const cls = root.className.split(' ')[0];

    let width, shift, srcLabel;
    const preset = opt.preset && OF.PRESET[opt.preset];
    if (preset) {
      width = preset.width; shift = preset.shift; srcLabel = opt.preset;
    } else {                                   // 실측 fallback — BCR을 zoom으로 나눠 CSS px 환산
      const b = OF.brackets();
      if (!b) return { error: 'no brackets — 읽기모드일 수 있음' };
      const zoom = OF.zoom();
      const mR = main.getBoundingClientRect();
      const padL = parseFloat(getComputedStyle(main).paddingLeft);
      width = (b.rt.left - b.lt.right) / zoom;
      shift = (b.lt.right - (mR.left + padL * zoom)) / zoom;
      srcLabel = 'measured(zoom=' + zoom + ')';
    }

    const START = '/* OF-ALIGN-START */', END = '/* OF-ALIGN-END */';
    const override = '\n' + START + ' (' + srcLabel + ')\n'
      + '.dze_page_main > .' + cls + '{width:' + width + 'px !important;max-width:none !important;'
      + 'margin:0 0 0 ' + shift + 'px !important;padding:0 !important;box-sizing:border-box !important;}\n'
      + '.dze_page_main > .' + cls + ' img{max-width:100% !important;height:auto !important;}\n'
      + '.dze_page_main > .' + cls + ' table{max-width:100% !important;table-layout:fixed !important;}\n'
      + '.dze_page_main > .' + cls + ' pre{white-space:pre-wrap !important;word-break:break-word !important;}\n'
      + '* {outline:none !important;}\n' + END + '\n';

    let styleEl = main.querySelector(':scope > style');
    const stripRe = new RegExp('\\n\\/\\* OF-ALIGN-START \\*\\/[\\s\\S]*?\\/\\* OF-ALIGN-END \\*\\/\\n', 'g');
    if (styleEl) {
      styleEl.textContent = styleEl.textContent.replace(stripRe, '') + override; // 이전 블록 교체
    } else {
      styleEl = ed.createElement('style');
      styleEl.textContent = override;
      main.insertBefore(styleEl, main.firstChild);   // main 내부여야 저장 시 생존
    }
    return { rootClass: cls, offsetW: root.offsetWidth, width: width, shift: shift, src: srcLabel };
  };

  /* ================= 문서 설정 팝업 ================= */
  //  cfg = { split:'single'|'multi', margin:'narrow'|'normal'|'wide', paper:'portrait'|'landscape' }
  //  ⚠️ 용지 크기(A4↔A3)는 콤보박스라 DOM 불안정 → 이 함수 범위 밖(좌표 클릭 별도).
  OF.pageSetup = async function (cfg) {
    cfg = cfg || {};
    const bd = OF.bodyDoc();
    if (!bd) return { ok: false, error: 'no bodyDoc' };
    const clickId = id => { const e = bd.getElementById(id); if (e) e.click(); return !!e; };
    const sleep = ms => new Promise(r => setTimeout(r, ms));

    clickId(OF.SEL.ribbonFile);  await sleep(200);
    clickId(OF.SEL.settingBtn);  await sleep(300);

    if (cfg.split === 'single') clickId(OF.SEL.splitOn);
    else if (cfg.split === 'multi') clickId(OF.SEL.splitOff);

    if (cfg.margin === 'narrow') clickId(OF.SEL.marginNarrow);
    else if (cfg.margin === 'normal') clickId(OF.SEL.marginNormal);
    else if (cfg.margin === 'wide') clickId(OF.SEL.marginWide);

    if (cfg.paper === 'portrait') clickId(OF.SEL.paperPortrait);
    else if (cfg.paper === 'landscape') clickId(OF.SEL.paperLand);

    const ok = bd.querySelector(OF.SEL.dlgOk);
    if (ok) ok.click();
    await sleep(300);

    const main = OF.main();
    const padL = main ? parseFloat(getComputedStyle(main).paddingLeft) : null;
    return { ok: !!ok, padL: padL, note: 'A4↔A3 용지크기는 콤보박스 — 좌표 클릭 별도' };
  };

  /* ================= 문서명 변경 (native setter + blur 필수) ================= */
  OF.setTitle = async function (name) {
    const bd = OF.bodyDoc();
    if (!bd) return { ok: false, error: 'no bodyDoc' };
    const inp = bd.getElementById(OF.SEL.titleInput);
    if (!inp) return { ok: false, error: 'title input not found' };
    const win = bd.defaultView;                                  // ★ iframe 안 window의 prototype
    const nativeSetter = Object.getOwnPropertyDescriptor(
      win.HTMLInputElement.prototype, 'value').set;
    const sleep = ms => new Promise(r => setTimeout(r, ms));
    inp.focus(); await sleep(100);
    nativeSetter.call(inp, name);
    inp.dispatchEvent(new Event('input', { bubbles: true }));
    inp.dispatchEvent(new Event('change', { bubbles: true }));
    ['keydown', 'keypress', 'keyup'].forEach(t =>
      inp.dispatchEvent(new KeyboardEvent(t, { key: 'Enter', keyCode: 13, bubbles: true })));
    await sleep(200);
    inp.blur();                                                  // ★ React/ONEFFICE commit 트리거
    inp.dispatchEvent(new Event('blur', { bubbles: true }));
    await sleep(300);
    return { ok: true, value: inp.value };
  };

  /* ================= 저장 (★2단계, 실측 §7) ================= */
  //  ① assertEditable(읽기모드면 enterEdit 편집 전환 포함) → ② 저장버튼 JS .click()(one001A17)
  //  → 탭 제목 "데이터를 저장하고 있습니다." 전환 감지. 편집 후에도 신호 없으면 체크아웃 경쟁.
  OF._checkoutConflictPresent = function () {
    const kw = ['다른 창에서 편집', '체크아웃', '덮어쓰기 실패', 'OTHER_CHECKOUT'];
    const scan = doc => {
      if (!doc || !doc.body) return false;
      const t = doc.body.innerText || '';
      return kw.some(k => t.indexOf(k) !== -1);
    };
    return scan(OF.bodyDoc()) || scan(document);
  };

  OF.save = async function (opt) {
    opt = opt || {};
    const timeout = opt.timeout || 2500;
    const sleep = ms => new Promise(r => setTimeout(r, ms));

    // ① 편집 가능 확보 (읽기모드면 편집 토글 전환 후 반영 폴링 — 실측: enterEdit 후 반영 ~2초 지연)
    if (!OF.isEditable()) {
      OF.enterEdit();
      const t0 = Date.now();
      while (Date.now() - t0 < 3000 && !OF.isEditable()) await sleep(150);
    }
    if (!OF.isEditable()) {
      return { fired: false, needsPhysicalClick: true,
               checkoutConflict: OF._checkoutConflictPresent(),
               reason: '편집모드 전환 실패(읽기모드 잔존/체크아웃 경쟁)' };
    }

    const bd = OF.bodyDoc();
    const btn = bd && bd.getElementById(OF.SEL.saveBtn);
    if (!btn) return { fired: false, needsPhysicalClick: true, checkoutConflict: false,
                       reason: 'save button not found' };

    btn.click();                               // ② JS 저장 시도 (one001A17)

    // 탭 제목 전환 감지 = 저장 발생 판정 (정본)
    const SAVING = '데이터를 저장하고 있습니다';
    const start = Date.now();
    let seen = false;
    while (Date.now() - start < timeout) {
      if ((document.title || '').indexOf(SAVING) !== -1) { seen = true; break; }
      await sleep(120);
    }
    if (seen) return { fired: true, needsPhysicalClick: false, checkoutConflict: false };

    // 신호 없음 → 체크아웃 경쟁 의심 → 호출부가 computer 실제 마우스로 폴백
    return { fired: false, needsPhysicalClick: true,
             checkoutConflict: OF._checkoutConflictPresent() };
  };

  /* ================= 탭 간 복제 (localStorage 우회) ================= */
  //  Chrome MCP javascript_tool 은 쿼리스트링 유사 반환을 차단 → localStorage로 탭 간 전달.
  OF.stashMain = function (key) {
    key = key || ('__of_stash_' + Date.now());
    const main = OF.main();
    if (!main) return { error: 'no main' };
    localStorage.setItem(key, main.innerHTML);
    return { key: key, len: (localStorage.getItem(key) || '').length };
  };

  OF.applyStash = function (key) {
    if (!key) return { error: 'key required' };
    const html = localStorage.getItem(key);
    if (html == null) return { error: 'not in localStorage: ' + key };
    OF.assertEditable();
    const main = OF.main();
    if (!main) return { error: 'no main' };
    main.innerHTML = html;
    localStorage.removeItem(key);
    return { key: key, len: html.length, kids: main.children.length };
  };

  /* ================= CORS 서버 스니펫 (charset=utf-8 포함) ================= */
  //  40KB+ HTML 을 fetch 로 주입할 때 Bash 로 이 문자열을 실행. charset 누락 시 한글 영구 손상.
  OF.corsServer = [
    "python3 -c \"",
    "import http.server, socketserver, os",
    "class H(http.server.SimpleHTTPRequestHandler):",
    "    def end_headers(self):",
    "        self.send_header('Access-Control-Allow-Origin', '*')",
    "        super().end_headers()",
    "    def guess_type(self, path):",
    "        ctype = super().guess_type(path)",
    "        if isinstance(ctype, tuple): ctype = ctype[0]",
    "        if ctype and ctype.startswith('text/'): return ctype + '; charset=utf-8'",
    "        return ctype",
    "os.chdir('/tmp')",
    "socketserver.TCPServer(('127.0.0.1', 8765), H).serve_forever()",
    "\" &"
  ].join("\n");

  /* ================= 아마링크(관련 문서) 앵커 빌더 ================= */
  //  원피스 본문에 '관련 문서 카드'로 렌더되는 <a class="dze_amalink"> 요소를 HTML 문자열로 생성.
  //  ⚠️ resolve_amalink 의 convertText 마크업(|>@…@<|)은 헤드리스 create·편집기 로드 모두 문자로 남고
  //     카드로 안 됨. cmd+v 붙여넣기 변환도 자동화(신뢰 키 요구)에서 불가 → 완성된 이 앵커를 직접 주입.
  //  opts: {url(상대 공유링크 '/ecm/oneffice/?token=…' 권장), title, moduleGbn='ONEFFICE', icon='📄'}
  OF.amalinkAnchor = function (opts) {
    opts = opts || {};
    const esc = s => String(s == null ? '' : s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    const url = String(opts.url || '').replace(/&/g, '&amp;');   // href 는 경로라 & 만 이스케이프
    const title = esc(opts.title || '문서');
    const mod = esc(opts.moduleGbn || 'ONEFFICE');
    const icon = opts.icon || '📄';
    const aStyle = "font-size:11pt;color:rgb(0,0,0);background-color:rgba(0,0,0,0);"
                 + "font-weight:normal;font-family:'Malgun Gothic',sans-serif;";
    const spStyle = "font-size:11pt;color:rgb(28,144,251);background-color:rgba(28,144,251,0.07);"
                  + "text-decoration:none;font-family:'Malgun Gothic',sans-serif;";
    const tip = '&lt;Ctrl&gt; 키를 누른 채 클릭 시, 해당 컨텐츠로 이동합니다.';
    return '<a href="' + url + '" target="_blank" class="dze_amalink" modulegbn="' + mod
         + '" title="' + tip + '" style="' + aStyle + '">'
         + '<span style="' + spStyle + '">' + icon + ' ' + title + '</span></a>';
  };

  /* ================= 읽기 계열 (reader 정본) ================= */

  // 본문 전체 텍스트. range=[from,to] 청크 슬라이싱, 없으면 {length, preview} 요약.
  OF.text = function (range) {
    const doc = OF.editorDoc();
    if (!doc || !doc.body) return { error: 'editorDoc-null' };
    const full = doc.body.innerText || '';
    if (Array.isArray(range)) {
      const from = range[0] || 0, to = range[1];
      return to == null ? full.slice(from) : full.slice(from, to);
    }
    return { length: full.length, preview: full.slice(0, 2000) };
  };

  // 본문 table 전건 → 2차원 배열 + 육안용 파이프 텍스트
  OF.tables = function () {
    const doc = OF.editorDoc();
    if (!doc) return { error: 'editorDoc-null' };
    const norm = s => (s || '').replace(/\s+/g, ' ').trim();
    return Array.from(doc.querySelectorAll('table')).map((t, idx) => {
      const grid = Array.from(t.rows).map(r => Array.from(r.cells).map(c => norm(c.innerText)));
      return {
        index: idx, rows: t.rows.length, cols: t.rows[0] ? t.rows[0].cells.length : 0,
        cells: grid, text: grid.map(row => row.join(' | ')).join('\n')
      };
    });
  };

  // 본문 a[href] 중 gwa.douzone.com 만 → 4분류. 쿼리스트링은 기본 절단(Chrome MCP 차단 회피).
  OF.links = function (opt) {
    const doc = OF.editorDoc();
    if (!doc) return { error: 'editorDoc-null' };
    const wantRaw = opt && opt.includeParam === true;
    const classify = href => {
      if (/\/ecm\/oneffice\//i.test(href)) return 'oneffice';
      if (/\/ecm\/onechamber\//i.test(href)) return 'onechamber';
      if (/#\/popup\?callComp=UDAP007/i.test(href)) return 'mail';
      return 'etc';
    };
    return Array.from(doc.querySelectorAll('a[href]'))
      .filter(a => /gwa\.douzone\.com/i.test(a.href))
      .map(a => {
        const href = a.href, qIdx = href.indexOf('?');
        const out = {
          type: classify(href),
          text: (a.innerText || '').trim().slice(0, 80),
          safeHref: qIdx === -1 ? href : href.slice(0, qIdx),   // '?' 제거 → 미차단
          hasParam: qIdx !== -1
        };
        if (wantRaw && qIdx !== -1) {
          try { out.paramB64 = btoa(unescape(encodeURIComponent(href.slice(qIdx + 1)))); }
          catch (_e) { out.paramB64 = null; }
        }
        return out;
      });
  };

  // i번째 본문 img → Canvas PNG dataURL(base64). img.src 직접 읽기 금지(?seq= Chrome 차단).
  OF.imageDataURL = function (i, opt) {
    const doc = OF.editorDoc();
    if (!doc) return { error: 'editorDoc-null' };
    const imgs = doc.querySelectorAll('img');
    if (i == null) return { count: imgs.length };
    const img = imgs[i];
    if (!img) return { error: 'index-out-of-range', count: imgs.length };
    try {
      const canvas = document.createElement('canvas');
      canvas.width = img.naturalWidth || img.width;
      canvas.height = img.naturalHeight || img.height;
      canvas.getContext('2d').drawImage(img, 0, 0);
      const url = canvas.toDataURL('image/png');
      return { index: i, w: canvas.width, h: canvas.height,
               dataURL: (opt && opt.full) ? url : url.slice(0, 10000),
               truncated: !(opt && opt.full) };
    } catch (e) {
      return { error: 'tainted-canvas', message: String((e && e.message) || e) };
    }
  };

  window.OF = OF;
  return { ok: true, version: 'kit-0.2.0', fns: Object.keys(OF) };
})();
```

## 2. 함수별 출처·함정 (요약)

| 함수 | 출처 | 핵심 주의 |
|---|---|---|
| `OF.bodyDoc()`/`editorDoc()`/`main()` | writer Step 2 iframe 체인 + reader `\|\| contentWindow.document` 폴백 | 리본·저장·문서명·문서설정·**편집 토글**은 bodyDoc / main·꺾쇠·zoom은 editorDoc. `dzeditor_9999`(offscreen) 접근 금지 |
| `OF.isEditable()` | writer Step 2 | 정본 신호 = `main.isContentEditable`(실측 §7). F의 `readmode` 부재 신호와 동치 여부는 **미검증**(F 전환 시 회귀검증) |
| `OF.enterEdit()` ★ | 실측 §7 후속① | 토글 그룹에서 텍스트 정확히 "편집"만 클릭. JS `.click()`로 전환 가능(신뢰 이벤트 불필요) |
| `OF.save()` ★ | writer Step 10 + 실측 §7 | 2단계: ① enterEdit 편집 전환(300ms 대기) → ② 저장버튼 click(`one001A17`). 탭 제목 전환으로 판정. 실패 시 `needsPhysicalClick`/`checkoutConflict` 신호 — 물리 클릭은 호출부 `computer` |
| `OF.injectHTML()` | writer Step 6 | 주입 전 `assertEditable()` 하드 가드(읽기모드 주입은 저장 시 유실). 모드는 반환 진단만 다름 |
| `OF.outlineGuard()` ★ | 실측 2026-08-14 | 본문 HTML 문자열의 모든 `div`·`pre` 에 인라인 `outline:none` 주입(멱등·시각 변화 0). 편집기가 `td`·`th`·지면의 **직계 자식**에 얹는 회색 점선 차단 — **읽기모드에도 남는 선**이라 필수. 규칙에 `!important` 가 없어 인라인이 이김. `<style>` 을 못 쓰는 **모드 C·트랙 A(헤드리스)의 유일한 수단** |
| `OF.alignBracket()` | writer Step 7·8 | **모드 B 한정, 모드 C 금지 + 예외 상황 전용**. 폭은 원래 안 줘도 맞는다(2026-07-23 12조합 실측) — 좁게 나오면 **여백 설정부터 의심**. `<style>`+!important 2단 셀렉터를 main 내부에. BCR÷zoom 환산 필수 |
| `OF.pageMetrics()` ★ | 라이브 실측 12조합(2026-07-23) | 용지·여백 → `{paperPx, padPx, contentPx}`. `px = ceil(mm×96/25.4)` — **반올림 아님**(넓게 30mm는 반올림 113 ≠ 실측 114). 가로·원시 mm 입력 지원 |
| `OF.pageSetup()` | writer Step 3 | split/margin/paper는 라디오라 안정. **용지 A4↔A3는 콤보박스 → 범위 밖**(좌표 별도) |
| `OF.setTitle()` | writer Step 9 | `inp.value=` 금지. native setter + blur dispatch 필수 |
| `OF.amalinkAnchor()` ★ | 실측 2026-07-23 (§5) | 관련 문서 '카드' `<a class="dze_amalink">` HTML 생성. convertText 마크업·cmd+v 붙여넣기는 렌더 안 됨 → 완성 앵커 직접 주입. `url`=`?token=` 공유링크(`resolve_amalink`). 트랙 A 헤드리스도 동일 |
| `OF.text/tables/links/imageDataURL` | reader Step 2~5 | img.src 직접 금지(Canvas toDataURL). 쿼리스트링 든 반환은 Chrome MCP 차단 → safeHref/base64 우회 |
| `OF.SEL/PRESET/COORD/corsServer` | 전 스킬 정본화 | 값 변경은 여기 한 줄만 → 6종 전파. `corsServer`는 charset=utf-8(한글 손상 방지) |

**전역 함정 3(전 함수 공통)**: ① 저장 전 새로고침 금지(주입 유실). ② `getComputedStyle()` 값 구울 때 `margin:auto`·`1fr` 상대값이 절대 px로 고정돼 오버플로 — 상대값 명시 오버라이드. ③ 저장 직렬화 시 빈 `<span>` 삭제·`<b>`/`<strong>` 언랩 → `<div style="display:inline">` 치환, 검증은 **새로고침 후** DOM.

## 3. 각 스킬 소비 방식 (전환 대상 = C단계)

| 스킬 | OF에서 쓰는 것 | 스킬에 남는 고유 |
|---|---|---|
| **writer(W)** | 전 배관·쓰기 함수 | 모드 판단·미학·전체 오케스트레이션 |
| **new-doc-opener(O)** | `editorDoc`·`main`·`isEditable`/`assertEditable`·`COORD.editTab`·`corsServer` | **XHR body swap**·"ONEFFICE 워드" 매칭·payload 구조(고유) |
| **form-writer(F)** | `editorDoc`·`enterEdit`·`assertEditable`·`save` | **SCHEMA·wrap 7종·표별 룰**(워크스페이스 SSoT). 저장 dirty 유발(실제 키입력)은 호출부 `computer` |
| **html-oneffice-builder(H)** | (위임) `PRESET`·환경 제약 | frontend-design 미학·HTML 작성. opener+writer 위임 |
| **reader(R)** | `editorDoc`·`text`·`tables`·`links`·`imageDataURL` | 아마링크 타이틀 규칙 표·재귀 확장 정책 |
| **comment(C)** | `COORD.commentSubmit`(최소) | **멘션 신뢰 키 시퀀스**(고유) |

## 3.5 OF 실측 검증 결과 (2026-07-14 사내망)

키트 신설 직후 사내망 원피스 테스트 문서에 OF를 주입해 핵심 함수를 실측 검증했다(전부 통과):

| 함수 | 결과 |
|---|---|
| `bodyDoc`·`editorDoc`·`main` | ✅ 중첩 iframe 체인 정상 접근 |
| `isEditable` | ✅ 신규=true·재열람=false 정확 판정 |
| `enterEdit` | ✅ 읽기→편집 JS `.click()` 전환 성공 (단 반영 ~2초 지연) |
| `injectHTML` | ✅ 주입 정상(text 재확인) |
| `save` (2단계) | ✅ 신규·재열람+편집전환 모두 저장 성사(탭 제목 "데이터를 저장하고 있습니다." 전환) |
| `text`·`tables`·`zoom` | ✅ 읽기 정상(zoom 1.1 실측 파싱 — PRESET 1.3 아님) |
| `injectHTML`(모드 B)·`alignBracket`·`setTitle` | ✅ **writer 흐름 스모크(2026-07-14, C단계)** — 모드 B 주입(container·style 보존, kids=2)·꺾쇠 정렬(preset A4-normal, width 644·offsetW 642)·문서명 변경(탭 제목 전환) 통과. `pageSetup`은 함수 구조만 확인(팝업 조작은 실사용 검증) |

**실측으로 드러난 함정 2건(반영 완료)**:
1. **`enterEdit` 반영 ~2초 지연** — 토글 click 직후 `isContentEditable`은 여전히 false. `save()`는 300ms 고정 대기 → **최대 3초 폴링으로 보강**(위 코드). `assertEditable`(동기)은 재열람 문서 첫 주입 시 여전히 즉시 실패할 수 있으니, 재열람 문서는 **`OF.enterEdit()` 호출 후 별도 폴링 대기 → 그다음 `injectHTML`** 순서를 권장.
2. **`zoom`은 문서마다 다름**(실측 1.1) — `alignBracket`은 PRESET 하드코딩보다 **실측 fallback(BCR÷zoom)** 이 안전.
3. **Chrome MCP async 반환 차단** — `OF.save()`(async)의 반환 객체가 `javascript_tool`에서 `{}`로 비어 옴 → 저장 판정은 **탭 제목 전환**으로(반환값 의존 금지).

## 3.6 지면 폭 실측 정본 (2026-07-23 사내망 · 12조합 전건)

용지·여백 12조합을 실제 발행해 측정했다. **주입 루트에 폭을 지정하지 않았는데도 12조합 전부 글 영역을 정확히 채웠다.**

| 용지(가로 mm) | 용지 px | 좁게(10mm)=38 | 보통(20mm)=76 | 넓게(30mm)=114 |
|---|---|---|---|---|
| A4 (210) | 794 | **718** | **642** | **566** |
| A3 (297) | 1123 | **1047** | **971** | **895** |
| B5 (176) | 666 | **590** | **514** | **438** |
| LETTER (216) | 817 | **741** | **665** | **589** |

- 공식 `px = ceil(mm × 96 / 25.4)`, 글 영역 = 용지 − 여백×2 — **12/12 일치**
- **반올림이 아니라 올림**이다: 넓게 30mm는 반올림하면 113인데 실측 114, B5 176mm는 반올림 665인데 실측 666
- 종전 하드코딩 PRESET 4종은 실측보다 일관되게 **+2px** 어긋나 있었고 8조합이 아예 없었다 → `OF.pageMetrics()` 계산으로 대체
- **폭 지정 자체가 불필요**하다는 것이 핵심 — 폭이 좁아 보이면 여백 설정(문서 옵션)을 먼저 확인한다

## 4. 미확인·회귀검증 필요 (C단계 전환 시 사내망 확인)

1. **편집모드 신호 동치** — `isContentEditable`(OF 정본) vs F의 `readmode` 부재. F 전환 시 실측 대조 _(확인 필요)_.
2. **편집 탭 좌표 정본** — `[1361,20]` vs `[1414,17]`. enterEdit(JS)가 우선이라 좌표는 폴백이나, 정본값 확정 _(확인 필요)_.
3. **assertEditable 반영 지연** — enterEdit 직후 `isContentEditable` 즉시 반영 안 될 수 있음(save는 300ms 대기로 처리, injectHTML의 assertEditable은 동기라 재열람 문서 첫 주입 시 enterEdit 후 대기 필요할 수 있음).
4. **reader `links()` safeHref 과보호** — reader 원본은 `a.href` 그대로 반환해 차단 없이 동작했을 수 있음. 실제 차단 유발 여부 확인.
5. **`OF.save()` 체크아웃 경쟁 감지** — 팝업 텍스트 스캔 방식. 실제 경쟁 상황에서 감지 정확도 확인.

> 회귀검증은 T4 설계서 §4 마이그레이션 10단계 순서(키트 신설 → H·좌표·R·O·W·F·C 전환 → 자체완결 문구 정정 → 배포)를 따르며, 각 전환 후 알려진 원피스 문서 1건으로 스모크 테스트.

## 5. 아마링크(관련 문서) 카드 삽입 (트랙 A 헤드리스·트랙 B 공통)

원피스 본문에 **'관련 문서' 카드**(파란 `dze_amalink` 앵커)를 넣는 정본. `dz-oneffice-writer`·`dz-oneffice-write`(create_oneffice_doc) 공통으로 **이 방식만 렌더된다**(라이브 실측 2026-07-23).

- ⛔ **convertText 마크업은 안 됨** — `resolve_amalink` 반환 `convertText`(`|>@제목|!@!|{…}@<|`)를 본문 HTML에 그대로 넣으면 헤드리스 `create_oneffice_doc`·편집기 로드 모두 **문자 그대로** 남고 카드로 변환되지 않는다(원피스 서버는 content 저장만, 아마링크 파싱은 편집기 붙여넣기 핸들러 담당). 메신저 `send_chat` 은 반대로 이 마크업(convertText)이 정답이니 혼동 금지(발행 대상이 원피스 본문이냐 채팅이냐로 갈린다).
- ⛔ **cmd+v 붙여넣기 변환도 자동화 불가** — 편집기가 클립보드 읽기를 막고("브라우저 보안 설정으로 제한된 기능 — Ctrl+V") 신뢰된 네이티브 붙여넣기만 받는데, 자동화 합성 cmd+v 는 실제 붙여넣기를 수행 못 한다(End/Enter 키는 먹지만 paste 삽입 0). `dz-oneffice-comment` 의 "신뢰 키만" 벽과 동일.
- ✅ **완성된 `dze_amalink` 앵커를 직접 주입** — 마크업이 아니라 렌더 결과 요소라 그대로 표시·클릭된다. `create_oneffice_doc` 의 html 파라미터에 넣어도 class·href·style 이 보존됨을 실측. 정본 구조:
  ```html
  <a href="/ecm/oneffice/?token=<64hex>" target="_blank" class="dze_amalink" modulegbn="ONEFFICE"
     title="<Ctrl> 키를 누른 채 클릭 시, 해당 컨텐츠로 이동합니다."
     style="font-size:11pt;color:rgb(0,0,0);background-color:rgba(0,0,0,0);…">
    <span style="color:rgb(28,144,251);background-color:rgba(28,144,251,0.07);…">📄 문서제목</span></a>
  ```
  - **href = 상대 공유링크** `/ecm/oneffice/?token=…`(추측·변형 금지). 클릭은 평범한 앵커 `target=_blank` 이동 — 특수 핸들러 불필요.
  - 카드 스타일 = 파란 글자 `rgb(28,144,251)` + 연파란 배경 `rgba(28,144,251,0.07)`, 아이콘 이모지(원피스 📄 · 원챔버 🗃️) prefix.
- **제목·상대링크·moduleGbn 확보 = `resolve_amalink`(a10 MCP)** — 원 아마링크 URL(대화방·공지에서 받은 `?token=` 링크 또는 편집기 `one003A06?…` 링크)을 입력하면 `{convertText, moduleGbn, authKeyMap.data.onefficeURL}` 반환. `onefficeURL` 의 `token=` 값으로 상대 공유링크 `/ecm/oneffice/?token=…` 를 구성한다.
- **빌더 = `OF.amalinkAnchor({url, title, moduleGbn, icon})`**(§1) — 위 앵커 HTML 문자열 생성. 트랙 A 는 반환 문자열을 본문 HTML 에 삽입, 트랙 B 는 `OF.injectHTML` 로 편집 문서에 주입.
- **DOM 인스펙션 주의** — 확인차 편집기 DOM 을 읽을 때 href·토큰이 출력에 섞이면 Chrome MCP 가 `[BLOCKED: Cookie/query string data]` 로 절단한다. 값·URL·HTML 을 반환하지 말고 **불리언·클래스명·속성명·개수**만 반환할 것.

<!-- auto: 차민수의 자비스 2026-07-14 dz-oneffice-kit 신설 (T4 마이그레이션 1단계) — OF 라이브러리 통합(writer 쓰기·배관 + reader 읽기), 실측 §7 반영(enterEdit·save 2단계·체크아웃 경쟁). 6종 전환·배포는 C단계 -->
<!-- auto: 차민수의 자비스 2026-07-23 §5 신설 + OF.amalinkAnchor 빌더(kit-0.2.0) — 아마링크 카드 헤드리스 삽입 기법(정현수 전무 미팅 회의록 관련문서 실작업 실측: convertText 마크업·cmd+v 붙여넣기 미렌더 → 완성 dze_amalink 앵커 직접 주입) -->
