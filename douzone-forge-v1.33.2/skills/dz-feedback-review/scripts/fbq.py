#!/usr/bin/env python3
"""fbq.py — 피드백 검토판(dz-feedback-review) 질문 페이지 도구. 파이썬 표준 라이브러리만 쓴다(check --render 만 playwright 선택).

하위 명령
  new    --spec 질문.json --out 페이지.html [--force] [--ignore-check]
         질문 데이터(JSON)로 1회차 질문 페이지를 만든다. 틀은 ../assets/page.html. 정적 점검(check 와 같은 것)에 걸리면 저장하지 않는다
  serve  --page 페이지.html --out 답.json [--timeout 초] [--port N]
         수신 창구. 127.0.0.1 빈 포트 · 일회용 토큰 · 첫 줄에 접속 주소를 찍는다.
         GET /{페이지파일명}?t=토큰 · GET /{상대경로}(페이지 폴더 안 파일만 — 시안·그림) · GET /ping?t=토큰 · POST /answer
         답을 받으면 저장하고 종료 0, 시간 초과면 종료 2. 백그라운드 명령으로 띄우고 종료 알림으로 깨어난다.
  open   --url 주소 --match 페이지파일명 [--app "Google Chrome"]
         크롬에 같은 페이지 탭이 있으면 그 탭 주소만 바꾼다(새 탭 금지 · 크게 보기 탭 #full= 은 건너뜀), 없으면 연다. macOS 는 AppleScript, 그 밖은 webbrowser
  read   (--answer 답.json | --text 붙여넣은.txt | --text -) [--page 페이지.html]
         「답변 완료」 전송 JSON · 「결과 복사」 문장 · 앞뒤 잡음 섞인 붙여 넣기 → 구조화 JSON(표준 출력)
         --page 를 주면 그 페이지의 이번 회차 카드 번호로 읽는다. loss_risk 에 든 경고 = 답·메모가 빠졌을 수 있음
  append --page 페이지.html --spec 다음질문.json --answers 답.json [--reflected 반영.json]
         현재 회차를 「N회차 — 반영됨」 표로 접어 이전 회차 맨 위에 넣고, 새 회차 카드를 붙이고, 저장 키를 …-r{N+1} 로 바꾼다.
         원본은 같은 폴더 {이름}.bak-rN.html 로 남긴다. 답의 회차·저장 키가 페이지와 다르거나, 글로 받은 답(붙여 넣기 원문, 그 글을
         읽은 read 출력)에서 카드가 빠졌을 수 있거나(loss_risk·카드 수 불일치), 붙인 결과가 점검에 걸리면 바꾸지 않는다(--force 는 이 모두를 무시)
  check  페이지.html [--render] [--shots 폴더] [--json]
         정적 점검(+ --render: 실제 그려진 글꼴·대비·1280/375 넘침·콘솔 오류). 종료 0 통과 · 1 문제 있음 · 3 렌더 점검 못 함

질문 데이터(JSON) — 예시: ../assets/question-spec.example.json   (밑줄로 시작하는 키는 설명용, 무시한다)
  {
    "title":  "페이지 제목(글자)",            "fbKey": "YYYYMMDD-주제 (저장 키 접두 — -r1 은 붙여 준다)",
    "kicker": "분류 한 줄(글자)",             "h1": "머리 제목(글자, 없으면 title)",
    "lead":   "<p>결론 먼저 — 무엇을 정하는 회차인지</p>"  (HTML 또는 문단 목록),
    "questions": [{
      "id": "생략하면 R{회차}-{순번}",  "title": "카드 제목(글자)",
      "summary": "한 줄 요약 — 무엇을 고르는가(인라인 HTML)",
      "why": "<p>왜 묻는가 — 배경·걸려 있는 것</p>"  (HTML 또는 문단 목록),
      "visual": "카드 보기 칸(선택, HTML/SVG — 단계 흐름 .v-flow · 나란히 비교 .v-cols · 표 .v-table · 수치 막대 .v-bars)",
      "visual_label": "보기 칸 이름표(선택, 기본 「한눈에」)",
      "options": [{"name": "선택지(내용으로)", "desc": "설명", "then": "고르면 무엇이 달라지는지",
                   "visual": "선택지 보기 칸(선택)", "demo": "demo/poc-a.html (선택, 페이지 폴더 기준 상대 경로)",
                   "demo_height": 420}],
      "rec": 1,  "rec_text": "추천 이유",  "cost": "대가"      (rec 0 = 추천 없음 — rec_text·cost 생략)
    }]
  }
"""
import argparse
import hmac
import html
import json
import mimetypes
import os
import re
import secrets
import shutil
import subprocess
import sys
import threading
import time
import unicodedata
from datetime import datetime
from html.parser import HTMLParser
from urllib.parse import quote, unquote

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE = os.path.normpath(os.path.join(HERE, "..", "assets", "page.html"))
PLACEHOLDERS = ("PAGE_TITLE", "FB_KEY", "ROUND", "KICKER", "H1", "LEAD_HTML", "CARDS_HTML", "ROUNDS_HTML")
REGIONS = ("kicker", "h1", "lead", "cards", "rounds")
CIRC = "①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳"
DEFAULT_DEMO_H = 420
BLOCK_TAG = re.compile(r"<\s*(p|div|ol|ul|li|table|section|article|h[1-6]|blockquote|pre|figure|details|form|header|footer)\b", re.I)


# ───────────────────────── 공통 도우미 ─────────────────────────
def esc(s):
    return html.escape("" if s is None else str(s), quote=True)


def circ(n):
    return CIRC[n - 1] if 1 <= n <= 20 else "(%d)" % n


def nfc(s):
    return unicodedata.normalize("NFC", s or "")


def say(msg, err=False):
    print(msg, file=sys.stderr if err else sys.stdout, flush=True)


def die(msg, code=1):
    say("오류: " + msg, err=True)
    sys.exit(code)


def read_text(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def write_atomic(path, text):
    d = os.path.dirname(os.path.abspath(path))
    os.makedirs(d, exist_ok=True)
    tmp = os.path.join(d, ".%s.tmp-%d" % (os.path.basename(path), os.getpid()))
    try:
        with open(tmp, "w", encoding="utf-8") as f:
            f.write(text)
        os.replace(tmp, path)
    except BaseException:
        try:
            os.remove(tmp)      # 실패한 임시 파일을 남기지 않는다
        except OSError:
            pass
        raise


def load_json(path, what):
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        die("%s 파일이 없습니다: %s" % (what, path))
    except json.JSONDecodeError as e:
        die("%s 파일이 JSON 이 아닙니다(%s 줄 %d): %s" % (what, path, e.lineno, e.msg))


def strip_tags(s):
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]*>", " ", s or ""))).strip()


def bad_demo_path(src):
    """페이지 폴더 기준 상대 경로만 허용 — 주소(http: 등)·절대 경로·역슬래시·.. 는 거부(페이지 스크립트 badSrc 와 같은 규칙)."""
    if not src or not isinstance(src, str):
        return "비어 있음"
    if re.match(r"^[a-z][a-z0-9+.\-]*:", src, re.I):
        return "주소(http: 등)는 쓸 수 없습니다"
    if re.search(r"[\x00-\x20\x7f]", src) or re.search(r"[\x00-\x20\x7f]", unquote(src)):
        # 브라우저는 주소의 앞뒤 공백·탭·줄바꿈을 지우고 읽는다 — 페이지 스크립트(badSrc)도 같은 글자를 거부한다
        return "공백·탭·줄바꿈 같은 글자는 쓸 수 없습니다(파일 이름의 공백은 - 나 _ 로)"
    if src.startswith(("/", "\\")):
        return "절대 경로는 쓸 수 없습니다"
    if "\\" in src:
        return "역슬래시(\\)는 쓸 수 없습니다"
    segs = src.split("#", 1)[0].split("?", 1)[0].split("/")
    if any(seg == ".." or unquote(seg) == ".." for seg in segs):      # %2e%2e 처럼 인코딩한 것도
        return "상위 폴더(..)는 쓸 수 없습니다"
    if any(seg != "." and unquote(seg) == "." for seg in segs) or any(c in unquote(x) for x in segs for c in ("\x00", "\\")):
        return "인코딩한 점(%2e)·역슬래시(%5c) 같은 쓸 수 없는 글자가 있습니다"
    return ""


def demo_file(page_dir, src):
    """시안 data-src → 실제 파일 경로(쿼리·조각 떼고, %인코딩 풀고)."""
    p = src.split("#", 1)[0].split("?", 1)[0]
    return os.path.join(page_dir, *[unquote(x) for x in p.split("/") if x not in ("", ".")])


# 문단 목록 항목을 <p> 로 감싸지 않을 덩어리 HTML — 덩어리 태그가 들어 있거나 주석으로 시작하는 것.
# <b>·<code>·<a> 처럼 인라인 태그로 시작하는 문장은 감싼다(안 감싸면 앞뒤 문단이 한 줄로 붙는다 — 2026-10-01 실측)
PARA_KEEP = re.compile(r"<\s*(p|div|ol|ul|li|dl|table|section|article|h[1-6]|blockquote|pre|figure|details|form|header|footer|hr|nav|aside)\b"
                       r"|^\s*<!--", re.I)


def paras(v):
    """HTML 문자열 또는 문단 목록 → HTML. 덩어리 태그(<p>·<div>·<ul>…)가 없는 항목은 <p> 로 감싼다."""
    if v is None:
        return ""
    items = v if isinstance(v, list) else [v]
    out = []
    for it in items:
        s = str(it).strip()
        if not s:
            continue
        out.append(s if PARA_KEEP.search(s) else "<p>%s</p>" % s)
    return "\n".join(out)


# ───────────────────────── 질문 데이터 → 카드 ─────────────────────────
def validate_spec(spec, round_no, page_dir, for_append=False):
    """질문 데이터 점검. (errors, warnings, questions) — questions 는 id 를 채운 사본."""
    errs, warns = [], []
    if not isinstance(spec, dict):
        return ["질문 데이터 최상위는 객체({ … })여야 합니다"], warns, []
    if not for_append and not str(spec.get("title") or "").strip():
        errs.append("title(페이지 제목)이 없습니다")
    if not paras(spec.get("lead")):
        errs.append("lead(리드 — 무엇을 정하는 회차인지, 결론 먼저)가 없습니다")
    qs = spec.get("questions")
    if not isinstance(qs, list) or not qs:
        errs.append("questions(질문 목록)가 비었습니다")
        return errs, warns, []
    out, seen = [], set()
    for i, q in enumerate(qs, 1):
        where = "질문 %d" % i
        if not isinstance(q, dict):
            errs.append(where + ": 객체가 아닙니다")
            continue
        q = dict(q)
        qid = str(q.get("id") or "R%d-%d" % (round_no, i)).strip()
        if not re.match(r"^[A-Za-z0-9][A-Za-z0-9_.\-]*$", qid):
            errs.append(where + ": id 는 영문·숫자·-_. 만 됩니다: %r" % qid)
        if qid in seen:
            errs.append(where + ": id 가 겹칩니다: " + qid)
        seen.add(qid)
        q["id"] = qid
        where = "%s(%s)" % (where, qid)
        for k, nm in (("title", "카드 제목"), ("summary", "한 줄 요약"), ("why", "왜 묻는가")):
            v = q.get(k)
            if not (paras(v) if k == "why" else str(v or "").strip()):
                errs.append("%s: %s(%s)이 없습니다" % (where, k, nm))
        if q.get("title") and "<" in str(q["title"]):
            warns.append(where + ": title 은 글자로만 씁니다 — 꺾쇠(<)는 그대로 글자로 보입니다")
        for k in ("summary",):
            if BLOCK_TAG.search(str(q.get(k) or "")):
                errs.append("%s: %s 는 한 줄(인라인 HTML)이어야 합니다 — <p>·<div> 같은 덩어리 태그 금지" % (where, k))
        opts = q.get("options")
        if not isinstance(opts, list) or not opts:
            errs.append(where + ": options(선택지)가 없습니다")
            opts = []
        if len(opts) > 20:
            errs.append(where + ": 선택지는 20개까지입니다")
        for j, o in enumerate(opts, 1):
            ow = "%s 선택지 %d" % (where, j)
            if not isinstance(o, dict):
                errs.append(ow + ": 객체가 아닙니다")
                continue
            for k, nm in (("name", "이름"), ("desc", "설명"), ("then", "고르면")):
                if not str(o.get(k) or "").strip():
                    errs.append("%s: %s(%s)이 비었습니다 — 선택지는 이름만으로 대신하지 않고 무엇인지·고르면 무엇이 달라지는지 씁니다" % (ow, k, nm))
                elif BLOCK_TAG.search(str(o.get(k))):
                    errs.append("%s: %s 는 인라인 HTML 만 됩니다 — 그림·표는 visual 에" % (ow, k))
            d = o.get("demo")
            if isinstance(d, str):
                d = d.strip()     # 생성기(render_figure)도 앞뒤 공백을 떼고 쓴다
            if d:
                why = bad_demo_path(d)
                if why:
                    errs.append("%s: demo 경로 %r — %s(페이지 폴더 기준 상대 경로, 예: demo/poc-a.html)" % (ow, d, why))
                elif page_dir is not None and not os.path.isfile(demo_file(page_dir, d)):
                    warns.append("%s: 시안 파일이 아직 없습니다: %s — 페이지에 「찾을 수 없습니다」로 나옵니다(만든 뒤 다시 생성)" % (ow, d))
            h = o.get("demo_height")
            if h is not None and not (isinstance(h, int) and 120 <= h <= 3000):
                warns.append("%s: demo_height 는 120~3000 정수 — 기본 %d 로 둡니다" % (ow, DEFAULT_DEMO_H))
        rec = q.get("rec", 0)
        if rec in (None, ""):
            rec = 0
        if not isinstance(rec, int) or rec < 0 or rec > len(opts):
            errs.append("%s: rec 는 0(추천 없음) 또는 1~%d 입니다: %r" % (where, len(opts), rec))
            rec = 0
        q["rec"] = rec
        if rec:
            for k, nm in (("rec_text", "추천 이유"), ("cost", "대가")):
                if not str(q.get(k) or "").strip():
                    errs.append("%s: rec=%d 인데 %s(%s)가 없습니다" % (where, rec, k, nm))
                elif BLOCK_TAG.search(str(q.get(k))):
                    errs.append("%s: %s 는 인라인 HTML 만 됩니다" % (where, k))
        out.append(q)
    return errs, warns, out


def render_figure(o, n, page_dir):
    src = str(o["demo"]).strip()
    h = o.get("demo_height")
    attrs = 'class="demo" data-n="%d" data-src="%s"' % (n, esc(src))
    if isinstance(h, int) and 120 <= h <= 3000 and h != DEFAULT_DEMO_H:
        attrs += ' data-h="%d"' % h
    if page_dir is not None and not bad_demo_path(src) and not os.path.isfile(demo_file(page_dir, src)):
        attrs += ' data-missing="1"'
    return ('<figure %s><figcaption><span class="demo-n">%d</span><b class="demo-t">%s</b></figcaption></figure>'
            % (attrs, n, str(o["name"]).strip()))


def render_card(q, page_dir):
    qid, title, opts, rec = q["id"], str(q["title"]).strip(), q["options"], q["rec"]
    side_by_side = len(opts) >= 2 and all(o.get("demo") for o in opts)
    L = ['<article class="dec" id="dec-%s" data-id="%s" data-title="%s" data-options="%d" data-rec="%d">'
         % (esc(qid), esc(qid), esc(title), len(opts), rec),
         '  <header class="dec-h"><span class="dec-no">%s</span><h3 class="dec-t">%s</h3></header>' % (esc(qid), esc(title)),
         '  <div class="dec-body">',
         '    <p class="dec-sum">%s</p>' % str(q["summary"]).strip(),
         '    <div class="k">왜 묻는가</div>',
         '    <div class="dec-why">%s</div>' % paras(q["why"])]
    if str(q.get("visual") or "").strip():
        L.append('    <div class="k">%s</div>' % esc(q.get("visual_label") or "한눈에"))
        L.append('    <div class="dec-vis">%s</div>' % str(q["visual"]).strip())
    L.append('    <div class="k">선택지</div>')
    L.append('    <ol class="opts">')
    for n, o in enumerate(opts, 1):
        li = ['<li data-n="%d"><span class="opt-t">%s</span><p class="opt-d">%s</p>' % (n, str(o["name"]).strip(), str(o["desc"]).strip())]
        if str(o.get("visual") or "").strip():
            li.append('<div class="opt-vis">%s</div>' % str(o["visual"]).strip())
        if o.get("demo") and not side_by_side:
            li.append(render_figure(o, n, page_dir))
        li.append('<p class="then"><span class="then-k">고르면</span>%s</p></li>' % str(o["then"]).strip())
        L.append('      ' + "".join(li))
    L.append('    </ol>')
    if side_by_side:
        L.append('    <div class="k">직접 써 보기</div>')
        L.append('    <div class="demos">')
        for n, o in enumerate(opts, 1):
            L.append('      ' + render_figure(o, n, page_dir))
        L.append('    </div>')
    if rec:
        name = str(opts[rec - 1]["name"]).strip()
        dot = "" if re.search(r"[.。!?]$", strip_tags(name)) else "."
        L.append('    <div class="k">추천</div>')
        L.append('    <div class="rec"><p><b class="rec-t"><span class="ci">%s</span> %s%s</b> %s</p>'
                 '<p class="cost"><span class="cost-k">대가</span>%s</p></div>'
                 % (circ(rec), name, dot, str(q["rec_text"]).strip(), str(q["cost"]).strip()))
    L.append('  </div>')
    L.append('  <div class="decide"></div>')
    L.append('</article>')
    return "\n".join(L)


def key_prefix(spec_key, out_path):
    k = str(spec_key or "").strip() or os.path.splitext(os.path.basename(out_path))[0]
    k = re.sub(r"-r\d+$", "", nfc(k))
    k = re.sub(r"[\s\"'<>&]+", "-", k).strip("-")
    return k or "fbq"


def fill_template(vals):
    tpl = read_text(TEMPLATE)
    a = tpl.find("<!--fbq:template-header")
    if a >= 0:
        b = tpl.find("-->", a)
        tpl = tpl[:a] + tpl[b + 3:].lstrip("\n")
    missing = [p for p in PLACEHOLDERS if "{{%s}}" % p not in tpl]
    if missing:
        die("틀(%s)에 자리표시가 없습니다: %s" % (TEMPLATE, ", ".join(missing)))
    # 한 번에 치환 — 넣은 값 안에 {{…}} 글자가 있어도 다시 치환하지 않는다
    return re.sub(r"\{\{(%s)\}\}" % "|".join(PLACEHOLDERS), lambda m: vals[m.group(1)], tpl)


def cmd_new(a):
    spec = load_json(a.spec, "질문 데이터")
    out = os.path.abspath(a.out)
    if os.path.exists(out) and not a.force:
        die("이미 있는 페이지입니다: %s\n  이어지는 질문이면 append 를 쓰세요(이전 회차가 보존됩니다). 정말 새로 만들 때만 --force" % out)
    page_dir = os.path.dirname(out)
    errs, warns, qs = validate_spec(spec, 1, page_dir)
    for w in warns:
        say("경고: " + w, err=True)
    if errs:
        say("질문 데이터에 고칠 것이 있습니다 — 페이지를 만들지 않았습니다:", err=True)
        for e in errs:
            say("  - " + e, err=True)
        sys.exit(1)
    title = str(spec["title"]).strip()
    prefix = key_prefix(spec.get("fbKey"), out)
    vals = {
        "PAGE_TITLE": esc(title),
        "FB_KEY": esc(prefix + "-r1"),
        "ROUND": "1",
        "KICKER": esc(str(spec.get("kicker") or "").strip()),  # 기본 없음 — 회차는 상단 메뉴에 있다. 비면 CSS 가 줄을 숨긴다
        "H1": esc(str(spec.get("h1") or title).strip()),
        "LEAD_HTML": paras(spec.get("lead")),
        "CARDS_HTML": "\n".join(render_card(q, page_dir) for q in qs),
        "ROUNDS_HTML": "",
    }
    page_text = fill_template(vals)
    E, W, _ = static_check(out, page_text)
    if E and not a.ignore_check:
        say("만든 페이지가 점검을 통과하지 못해 저장하지 않았습니다(질문 데이터를 고치세요 — 무시하려면 --ignore-check):", err=True)
        for e in E:
            say("  - " + e, err=True)
        sys.exit(1)
    write_atomic(out, page_text)
    nd = sum(1 for q in qs for o in q["options"] if o.get("demo"))
    say(out)
    say("1회차 질문 %d건 · 시안 %d개 · 저장 키 dzfb:%s-r1%s" % (len(qs), nd, prefix, (" · 경고 %d건(위)" % len(warns)) if warns else ""))
    say("다음: python3 -B \"%s\" check \"%s\" --render" % (os.path.abspath(__file__), out))


# ───────────────────────── 페이지 읽기(구조) ─────────────────────────
VOID = {"area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"}
RES_ATTRS = {"script": ("src",), "link": ("href",), "img": ("src", "srcset"), "iframe": ("src",), "frame": ("src",),
             "video": ("src", "poster"), "audio": ("src",), "source": ("src", "srcset"), "track": ("src",), "embed": ("src",),
             "object": ("data",), "input": ("src",), "image": ("href", "xlink:href"), "use": ("href", "xlink:href"),
             "feimage": ("href", "xlink:href")}
EXT_URL = re.compile(r"^\s*(https?:)?//", re.I)


class PageParser(HTMLParser):
    """질문 페이지(또는 시안) 구조를 모은다 — 카드·선택지·시안·스크립트·스타일·외부 자원."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []
        self.cards = []
        self.card = None
        self.opt = None
        self.scripts = []
        self.styles = []
        self.style_attrs = []
        self.ext = []
        self.res = []        # 다른 파일을 불러오는 속성 전부 [(줄, 태그, 속성, 값)] — 시안 한 파일 점검용
        self.handlers = []
        self.rounds = []
        self.body = {}
        self._script = None
        self._style = None

    # 각 스택 칸: (태그, 클래스 집합, 속성, 이 칸에서 글을 모을 곳 목록, 닫힐 때 할 일)
    def handle_starttag(self, tag, attrs):
        self._start(tag, attrs, void=tag in VOID)

    def handle_startendtag(self, tag, attrs):
        self._start(tag, attrs, void=True)

    def _start(self, tag, attrs, void):
        at = {k: (v if v is not None else "") for k, v in attrs}
        cls = set((at.get("class") or "").split())
        line = self.getpos()[0]
        caps, on_close = [], None
        for k, v in at.items():
            if k.startswith("on"):
                self.handlers.append((line, tag, k))
            if k == "style" and v:
                self.style_attrs.append((line, v))
            if k == "font-family" and v:   # SVG 글자 속성
                self.style_attrs.append((line, "font-family:" + v))
            if k in ("src", "href", "data", "poster", "srcset", "xlink:href") and tag != "a" and EXT_URL.match(v or ""):
                self.ext.append((line, tag, k, v))
            if k in RES_ATTRS.get(tag, ()) and (v or "").strip():
                self.res.append((line, tag, k, v.strip()))
        if tag == "body":
            self.body = at
        elif tag == "script":
            self._script = {"line": line, "id": at.get("id", ""), "src": at.get("src", ""), "type": at.get("type", ""), "text": ""}
            self.scripts.append(self._script)
        elif tag == "style":
            self._style = {"line": line, "text": ""}
            self.styles.append(self._style)
        elif tag == "details" and "round-done" in cls and self.card is None:
            self.rounds.append({"line": line, "id": at.get("id", ""), "round": at.get("data-round", "")})
        c = self.card
        if tag == "article" and "dec" in cls and "data-id" in at:
            c = self.card = {"id": at.get("data-id", "").strip(), "title": at.get("data-title", ""), "options_attr": at.get("data-options"),
                             "rec_attr": at.get("data-rec"), "line": line, "h3": "", "sum": None, "why": None, "vis": False,
                             "opts": [], "details": 0, "rec": None, "cost": None, "figures": [], "iframes": 0, "decide": False}
            self.cards.append(c)
            on_close = "card"
        elif c is not None:
            parent = self.stack[-1] if self.stack else None
            if tag == "details":
                c["details"] += 1
            if tag == "iframe":
                c["iframes"] += 1
            if "dec-t" in cls:
                caps.append((c, "h3"))
            if "dec-sum" in cls:
                c["sum"] = c["sum"] or ""
                caps.append((c, "sum"))
            if "dec-why" in cls:
                c["why"] = c["why"] or ""
                caps.append((c, "why"))
            if "dec-vis" in cls:
                c["vis"] = True
            if "decide" in cls:
                c["decide"] = True
            if tag == "li" and parent and parent[0] == "ol" and "opts" in parent[1]:
                self.opt = {"n": at.get("data-n", ""), "t": None, "d": None, "then": None, "vis": False, "line": line}
                c["opts"].append(self.opt)
                on_close = "opt"
            if self.opt is not None:
                if "opt-t" in cls:
                    self.opt["t"] = self.opt["t"] or ""
                    caps.append((self.opt, "t"))
                if "opt-d" in cls:
                    self.opt["d"] = self.opt["d"] or ""
                    caps.append((self.opt, "d"))
                if "then" in cls:
                    self.opt["then"] = self.opt["then"] or ""
                    caps.append((self.opt, "then"))
                if "opt-vis" in cls:
                    self.opt["vis"] = True
            if "rec" in cls and tag == "div":
                c["rec"] = c["rec"] or ""
                caps.append((c, "rec"))
            if "cost" in cls:
                c["cost"] = c["cost"] or ""
                caps.append((c, "cost"))
            if tag == "figure" and "demo" in cls:
                c["figures"].append({"src": at.get("data-src", ""), "n": at.get("data-n", ""), "h": at.get("data-h", ""),
                                     "missing": at.get("data-missing", ""), "line": line, "in_opt": self.opt is not None})
        if not void:
            self.stack.append((tag, cls, at, caps, on_close))

    def handle_endtag(self, tag):
        if tag in VOID:
            return
        if not any(e[0] == tag for e in self.stack):
            return
        while self.stack:
            e = self.stack.pop()
            if e[4] == "card":
                self.card = None
                self.opt = None
            elif e[4] == "opt":
                self.opt = None
            if e[0] == "script":
                self._script = None
            if e[0] == "style":
                self._style = None
            if e[0] == tag:
                break

    def handle_data(self, data):
        if self._script is not None:
            self._script["text"] += data
            return
        if self._style is not None:
            self._style["text"] += data
            return
        for e in self.stack:
            for obj, key in e[3]:
                obj[key] = (obj[key] or "") + data


def parse_page(text):
    p = PageParser()
    p.feed(text)
    p.close()
    for c in p.cards:
        for k in ("h3", "sum", "why", "rec", "cost"):
            if c[k] is not None:
                c[k] = re.sub(r"\s+", " ", c[k]).strip()
        c["cost"] = re.sub(r"^대가\s*", "", c["cost"]) if c["cost"] is not None else None
        for o in c["opts"]:
            for k in ("t", "d", "then"):
                if o[k] is not None:
                    o[k] = re.sub(r"\s+", " ", o[k]).strip()
            if o["then"] is not None:
                o["then"] = re.sub(r"^고르면\s*", "", o["then"])
    return p


def region(text, name):
    """영역 표지 <!--fbq:이름--> … <!--/fbq:이름--> 의 (안쪽 시작, 안쪽 끝) — 없거나 겹치면 None."""
    a, b = "<!--fbq:%s-->" % name, "<!--/fbq:%s-->" % name
    if text.count(a) != 1 or text.count(b) != 1:
        return None
    i, j = text.index(a) + len(a), text.index(b)
    return (i, j) if i <= j else None


def card_infos(text):
    """현재 회차 카드 목록 [{id, title, rec, opts{n: 이름}}] — append·read 가 쓴다."""
    r = region(text, "cards")
    p = parse_page(text[r[0]:r[1]] if r else text)
    out = []
    for c in p.cards:
        try:
            rec = int(c["rec_attr"] or 0)
        except ValueError:
            rec = 0
        names = {}
        for i, o in enumerate(c["opts"], 1):
            try:
                n = int(o["n"] or i)
            except ValueError:
                n = i
            names[n] = o["t"] or ""
        out.append({"id": c["id"], "title": (c["title"] or c["h3"] or c["id"]).strip(), "rec": rec, "opts": names})
    return out


def page_round(text):
    r = region(text, "rounds")
    sub = text[r[0]:r[1]] if r else text
    return len(parse_page(sub).rounds) + 1


# ───────────────────────── check ─────────────────────────
FORBIDDEN = re.compile(r"박혔|박음|박힘|박아\s?두|본질|영속화")
SERIF = re.compile(r"(georgia|times|myungjo|myeongjo|batang|명조|바탕|궁서|gungsuh|garamond|baskerville|palatino|cambria|"
                   r"(?<![\w-])serif(?![\w-]))", re.I)
EMOJI = re.compile("[\U0001F000-\U0001FAFF\U0001F1E6-\U0001F1FF]|[⌚⌛⏩-⏬⏰⏳◽◾☔☕"
                   "♈-♓♿⚓⚡⚪⚫⚽⚾⛄⛅⛎⛔⛪⛲⛳⛵⛺"
                   "⛽✅✊✋✨❌❎❓-❕❗➕-➗➰➿⬛⬜⭐⭕]"
                   "|.️")
CSS_DECL = re.compile(r"(font-family|font|--[\w-]+)\s*:\s*([^;{}]+)", re.I)


def css_problems(css, where):
    out = []
    css = re.sub(r"/\*.*?\*/", " ", css, flags=re.S)
    for m in CSS_DECL.finditer(css):
        prop, val = m.group(1).lower(), m.group(2)
        v = re.sub(r"sans[\s-]+serif", " ", val, flags=re.I)
        hit = SERIF.search(v)
        if hit and (prop in ("font-family", "font") or "," in val or "'" in val or '"' in val or prop.startswith("--")):
            out.append("%s: 세리프(명조) 글꼴 선언 — %s: %s" % (where, m.group(1), val.strip()[:80]))
        if prop == "font" and re.search(r"\b(italic|oblique)\b", val, re.I):
            out.append("%s: 이탤릭 선언 — font: %s" % (where, val.strip()[:60]))
    for m in re.finditer(r"font-style\s*:\s*(italic|oblique)", css, re.I):
        out.append("%s: 이탤릭 선언 — %s" % (where, m.group(0)))
    for m in re.finditer(r"@import\b[^;]*|url\(\s*['\"]?\s*(?:https?:)?//[^)]*\)", css, re.I):
        out.append("%s: 외부 자원 — %s" % (where, m.group(0)[:80]))
    return out


def node_check(js):
    node = shutil.which("node")
    if not node:
        return None
    r = subprocess.run([node, "--check", "-"], input=js, capture_output=True, text=True, timeout=60)
    if r.returncode == 0:
        return ""
    lines = [x for x in (r.stderr or "").splitlines() if x.strip()]
    return " / ".join(lines[:4])


def around(line, word, n=12):
    t = strip_tags(line)
    k = t.find(word)
    return t[max(0, k - n):k + len(word) + n] if k >= 0 else t[:2 * n]


SANS_FAMILY = re.compile(r"sans-serif|pretendard|apple\s*sd\s*gothic|malgun|맑은\s*고딕|noto\s*sans|segoe\s*ui|system-ui|"
                         r"-apple-system|blinkmacsystemfont|helvetica|arial", re.I)
DEMO_NET = re.compile(r"\bfetch\s*\(|\bXMLHttpRequest\b|\bimport\s*\(|\bnew\s+(?:Shared)?Worker\s*\(|\bimportScripts\s*\(|\bEventSource\s*\(")
DEMO_STORE = re.compile(r"\b(?:localStorage|sessionStorage|indexedDB)\b|\bdocument\.cookie\b")
ONE_FILE = ("시안은 HTML 한 파일로 — CSS·JS 는 파일 안에, 그림은 인라인 SVG 나 data: 주소, 예시 자료는 스크립트 안 변수로. "
            "시안은 sandbox(출처 없음)라 파일로 열면 같은 폴더의 다른 파일도 막히고, 창구로 열어도 fetch·XHR·모듈은 막힌다")


def without_user_memos(text):
    """「반영됨」 표의 메모 칸(td.memo-src — 사용자 원문)을 같은 길이 공백으로 지운 글(줄 번호 유지)."""
    r = region(text, "rounds")
    if not r:
        return text
    inner = re.sub(r'(<td class="memo-src">)(.*?)(</td>)', lambda m: m.group(1) + re.sub(r"[^\n]", " ", m.group(2)) + m.group(3),
                   text[r[0]:r[1]], flags=re.S)
    return text[:r[0]] + inner + text[r[1]:]


def local_ref(v):
    """같은 폴더 등 로컬 파일을 가리키는 값인가(data:·blob:·#조각·about: 은 아님, 외부 주소는 외부 자원 점검이 따로 잡는다)."""
    v = (v or "").strip()
    if not v or v.startswith("#") or EXT_URL.match(v):
        return False
    return not re.match(r"^(data|blob|about|javascript|mailto|tel):", v, re.I)


def demo_problems(dt, where):
    """시안 HTML 한 파일 점검 → (문제, 경고)."""
    E, W, hits = [], [], []     # hits: 한 파일 규칙 위반(다른 파일·주소를 부름) — 한 줄로 모아 이유와 함께 낸다
    dp = parse_page(dt)
    for ln, tag, k, v in dp.ext:
        E.append("%s %d행: 외부 자원 <%s %s=\"%s\">" % (where, ln, tag, k, v[:80]))
    for ln, tag, k, v in dp.res:
        vals = [x.strip().split()[0] for x in v.split(",") if x.strip()] if k == "srcset" else [v]
        for x in vals:
            if local_ref(x):
                hits.append("%d행 <%s %s=\"%s\">" % (ln, tag, k, x[:60]))
    for st in dp.styles:
        E.extend(css_problems(st["text"], "%s %d행 <style>" % (where, st["line"])))
    for ln, v in dp.style_attrs:
        E.extend(css_problems("x{%s}" % v, "%s %d행 style 속성" % (where, ln)))
    css_all = [st["text"] for st in dp.styles] + ["x{%s}" % v for _, v in dp.style_attrs]
    for css in css_all:
        for m in re.finditer(r"url\(\s*['\"]?([^)'\"]*)", re.sub(r"/\*.*?\*/", " ", css, flags=re.S), re.I):
            if local_ref(m.group(1)):
                hits.append("CSS url(%s)" % m.group(1)[:60])
    for sc in dp.scripts:
        if (sc["type"] or "").strip().lower() == "module":
            hits.append("%d행 <script type=\"module\">(일반 <script> 로)" % sc["line"])
        code = re.sub(r"/\*.*?\*/|(?<![:\\'\"])//[^\n]*", " ", sc["text"], flags=re.S)
        for m in DEMO_NET.finditer(code):
            hits.append("%d행 %s" % (sc["line"] + code.count("\n", 0, m.start()), m.group(0).strip()))
        for m in DEMO_STORE.finditer(code):
            msg = ("%s %d행 스크립트: %s — 시안은 브라우저 저장소·쿠키를 쓰지 않습니다(sandbox 라 오류). 상태는 변수로"
                     % (where, sc["line"] + code.count("\n", 0, m.start()), m.group(0)))
            if msg not in W:
                W.append(msg)
    if hits:
        E.append("%s: 다른 파일·주소를 부릅니다 — %s. %s" % (where, " · ".join(hits), ONE_FILE))
    # 글꼴 — 아무것도 적지 않으면 맥 크롬 기본 글꼴(명조·Times)로 그려진다
    decl = [m.group(2) for css in css_all for m in CSS_DECL.finditer(re.sub(r"/\*.*?\*/", " ", css, flags=re.S))
            if m.group(1).lower() in ("font-family", "font") or m.group(1).startswith("--")]
    if not any(SANS_FAMILY.search(v) for v in decl):
        E.append("%s: 고딕(sans) 글꼴 선언이 없습니다 — 안 적으면 맥 크롬 기본인 명조·Times 로 그려집니다. "
                 "body 에 font-family:\"Pretendard\",-apple-system,BlinkMacSystemFont,\"Apple SD Gothic Neo\",\"Malgun Gothic\",sans-serif 를 적으세요" % where)
    for i, ln in enumerate(dt.split("\n"), 1):
        for m in EMOJI.finditer(ln):
            E.append("%s %d행: 이모지 %r" % (where, i, m.group(0)))
        for m in FORBIDDEN.finditer(ln):
            E.append("%s %d행: 금지 어휘 「%s」" % (where, i, m.group(0)))
    return E, W


def static_check(path, text=None):
    """(errors, warnings, info) — 질문 페이지 정적 점검. text 를 주면 그 글을 path 자리에 있는 것으로 보고 점검한다."""
    E, W = [], []
    text = read_text(path) if text is None else text
    page_dir = os.path.dirname(os.path.abspath(path))
    lines = text.split("\n")

    def lineno(i):
        return text.count("\n", 0, i) + 1

    # 틀 흔적·자리표시는 자비스가 쓴 글에서만 찾는다 — 「반영됨」 표의 메모(사용자 원문)에 그 이름이 글자로 있어도 문제가 아니다
    own = without_user_memos(text)
    if "fbq:template-header" in own:
        E.append("틀 머리 주석이 남아 있습니다 — 틀을 직접 쓰지 말고 fbq.py new 로 만드세요")
    left = re.findall(r"\{\{(%s)\}\}" % "|".join(PLACEHOLDERS), own)
    if left:
        E.append("채워지지 않은 자리표시: " + ", ".join(sorted(set(left))))
    for nm in REGIONS:
        if region(text, nm) is None:
            E.append("영역 표지 fbq:%s 가 없거나 여러 개입니다 — append 가 회차를 붙일 수 없습니다" % nm)
    p = parse_page(text)

    # 페이지 정보
    rounds = len(p.rounds)
    rno = rounds + 1
    key = (p.body.get("data-fb-key") or "").strip()
    if not key:
        E.append("body[data-fb-key](저장 키)가 비었습니다")
    else:
        m = re.search(r"-r(\d+)$", key)
        if not m:
            E.append("저장 키가 -r{회차} 로 끝나지 않습니다: " + key)
        elif int(m.group(1)) != rno:
            E.append("저장 키 회차(-r%s)와 페이지 회차(%d — 이전 회차 묶음 %d개 + 1)가 다릅니다" % (m.group(1), rno, rounds))
    if not (p.body.get("data-fb-title") or "").strip():
        E.append("body[data-fb-title](페이지 제목)이 비었습니다")
    if not any(s["id"] == "fbq-core-js" for s in p.scripts):
        E.append("공통 스크립트(script#fbq-core-js)가 없습니다")
    if 'id="fbq-core"' not in text:
        E.append("공통 스타일(style#fbq-core)이 없습니다")
    try:
        tpl = read_text(TEMPLATE)
    except OSError:
        tpl = ""
    old_core = [nm for tag, ident, nm in (("style", "fbq-core", "공통 스타일"), ("script", "fbq-core-js", "공통 스크립트"))
                if tpl and core_block(tpl, tag, ident) and core_block(text, tag, ident)
                and core_block(tpl, tag, ident).group(0) != core_block(text, tag, ident).group(0)]
    if old_core:
        W.append("옛 틀로 만든 페이지입니다 — %s 부분이 지금 틀(assets/page.html)과 다릅니다. 이 페이지로 시험하면 옛 동작을 보게 됩니다"
                 "(1회차면 new --force 로 다시 만들고, 회차가 이어진 페이지는 다음 append 때 틀의 최신본으로 바뀝니다)" % "·".join(old_core))

    # 카드
    if not p.cards:
        E.append("이번 회차 질문 카드(.dec[data-id])가 없습니다")
    seen = {}
    for c in p.cards:
        cid = c["id"] or "(번호 없음)"
        w = "카드 %s(%d행)" % (cid, c["line"])
        if not c["id"]:
            E.append(w + ": data-id 가 비었습니다")
        if cid in seen:
            E.append(w + ": 카드 번호가 겹칩니다(%d행과 같음)" % seen[cid])
        seen.setdefault(cid, c["line"])
        if not (c["title"] or c["h3"]):
            E.append(w + ": 제목이 없습니다")
        if not c["sum"]:
            E.append(w + ": 한 줄 요약(.dec-sum)이 비었습니다")
        if not c["why"]:
            E.append(w + ": 왜 묻는가(.dec-why)가 비었습니다")
        if c["details"]:
            E.append(w + ": 카드 안에 접는 요소(<details>) %d개 — 이번 회차 카드는 모두 펼칩니다" % c["details"])
        if c["iframes"]:
            E.append(w + ": 카드 안에 iframe 이 직접 들어 있습니다 — 시안은 figure.demo[data-src] 로만(스크립트가 sandbox 를 걸고 만든다)")
        if not c["decide"]:
            W.append(w + ": 결정 칸(.decide)이 없습니다 — 스크립트가 카드 끝에 만듭니다")
        if not c["opts"]:
            E.append(w + ": 선택지(ol.opts > li)가 없습니다")
        try:
            nopt = int(c["options_attr"]) if c["options_attr"] is not None else len(c["opts"])
        except ValueError:
            nopt = -1
        if nopt != len(c["opts"]):
            E.append(w + ": data-options=%s 인데 선택지는 %d개" % (c["options_attr"], len(c["opts"])))
        try:
            rec = int(c["rec_attr"] or 0)
        except ValueError:
            rec = -1
        if rec < 0 or rec > len(c["opts"]):
            E.append(w + ": data-rec=%s 가 선택지 범위(0~%d) 밖입니다" % (c["rec_attr"], len(c["opts"])))
        for i, o in enumerate(c["opts"], 1):
            ow = "%s 선택지 %s" % (w, o["n"] or i)
            if not o["t"]:
                E.append(ow + ": 이름(.opt-t)이 비었습니다")
            missing = [nm for k, nm in (("d", "설명(.opt-d)"), ("then", "「고르면」(.then)")) if not o[k]]
            if missing:
                E.append(ow + ": %s 이 비었습니다 — 이름만으로 대신하지 않습니다" % "·".join(missing))
        if rec > 0:
            if not c["rec"]:
                E.append(w + ": data-rec=%d 인데 추천 블록(.rec)이 없습니다" % rec)
            if not c["cost"]:
                E.append(w + ": data-rec=%d 인데 대가(.cost)가 비었습니다" % rec)
        elif rec == 0 and c["rec"]:
            W.append(w + ": data-rec=0(추천 없음)인데 추천 블록이 있습니다")
        for f in c["figures"]:
            fw = "%s 시안 %s(%d행)" % (w, f["src"] or "(경로 없음)", f["line"])
            why = bad_demo_path((f["src"] or "").strip())     # 페이지 스크립트도 앞뒤 공백을 떼고 판정한다
            if why:
                E.append(fw + ": 경로 — " + why)
                continue
            exists = os.path.isfile(demo_file(page_dir, f["src"]))
            if not exists and f["missing"] != "1":
                E.append(fw + ": 시안 파일이 없습니다(data-missing 표시도 없음)")
            elif not exists:
                W.append(fw + ": 시안 파일이 없어 페이지에 「찾을 수 없습니다」로 나옵니다")
            elif f["missing"] == "1":
                E.append(fw + ": 이제 파일이 있는데 data-missing=\"1\" 이 남아 있습니다 — new/append 로 다시 만드세요")
            if f["h"] and not (f["h"].isdigit() and 120 <= int(f["h"]) <= 3000):
                W.append(fw + ": data-h=%s — 120~3000 밖이라 기본 %d 로 그립니다" % (f["h"], DEFAULT_DEMO_H))

    # 스크립트 · 외부 자원 · 글꼴 · 이모지 · 금지 어휘
    for s in p.scripts:
        if s["src"]:
            continue
        if s["type"] and "javascript" not in s["type"] and s["type"] != "module":
            continue
        if s["id"] != "fbq-core-js":
            W.append("%d행: 공통 스크립트 밖의 <script> — 페이지 저장값에 손댈 수 있습니다. 움직이는 것은 시안(demo, sandbox)으로 옮기세요" % s["line"])
        res = node_check(s["text"])
        if res is None:
            W.append("node 가 없어 스크립트 문법 점검(node --check)을 건너뛰었습니다")
        elif res:
            E.append("%d행 스크립트 문법 오류(node --check): %s" % (s["line"], res))
        if s["id"] == "fbq-core-js":
            es6 = re.findall(r"=>|`|\blet\s|\bconst\s|\bclass\s+\w", s["text"])
            if es6:
                E.append("공통 스크립트에 ES5 밖 문법: " + ", ".join(sorted(set(es6))))
    for ln, tag, k, v in p.ext:
        E.append("%d행: 외부 자원 <%s %s=\"%s\">" % (ln, tag, k, v[:80]))
    for ln, tag, k in p.handlers:
        W.append("%d행: <%s %s=…> 인라인 이벤트 — 움직이는 것은 시안(demo)으로" % (ln, tag, k))
    for st in p.styles:
        E.extend(css_problems(st["text"], "%d행 <style>" % st["line"]))
    for ln, v in p.style_attrs:
        E.extend(css_problems("x{%s}" % v, "%d행 style 속성" % ln))
    # 이모지·금지 어휘는 자비스가 쓴 글만 본다 — 「반영됨」 표의 메모 칸은 사용자 원문이라 고치지 않는다(SKILL §7)
    for i, ln in enumerate(without_user_memos(text).split("\n"), 1):
        for m in EMOJI.finditer(ln):
            E.append("%d행: 이모지 %r" % (i, m.group(0)))
        for m in FORBIDDEN.finditer(ln):
            E.append("%d행: 금지 어휘 「%s」 — 평이한 말로(…%s…)" % (i, m.group(0), around(ln, m.group(0))))

    # 시안 파일 — 외부 자원·세리프·이모지·금지 어휘 + 한 파일 규칙(다른 파일·fetch 금지)·고딕 글꼴 선언
    demo_paths = sorted({f["src"] for c in p.cards for f in c["figures"]
                         if not bad_demo_path(f["src"]) and os.path.isfile(demo_file(page_dir, f["src"]))})
    for src in demo_paths:
        try:
            dt = read_text(demo_file(page_dir, src))
        except (OSError, UnicodeDecodeError) as e:
            W.append("시안 %s: 읽지 못했습니다(%s)" % (src, e))
            continue
        e2, w2 = demo_problems(dt, "시안 " + src)
        E.extend(e2)
        W.extend(w2)
    info = {"round": rno, "fbKey": key, "cards": len(p.cards), "rounds_done": rounds,
            "demos": sum(len(c["figures"]) for c in p.cards), "demo_files": demo_paths}
    return E, W, info


# ───────────────────────── check --render (playwright) ─────────────────────────
JS_CONTRAST = r"""
() => {
  function parse(c){ const m=c.match(/rgba?\(([^)]+)\)/); if(!m) return null;
    const p=m[1].split(',').map(s=>parseFloat(s)); return {r:p[0],g:p[1],b:p[2],a:p.length>3?p[3]:1}; }
  function lin(v){ v/=255; return v<=0.03928? v/12.92 : Math.pow((v+0.055)/1.055,2.4); }
  function L(c){ return 0.2126*lin(c.r)+0.7152*lin(c.g)+0.0722*lin(c.b); }
  function blend(fg,bg){ const a=fg.a; return {r:fg.r*a+bg.r*(1-a),g:fg.g*a+bg.g*(1-a),b:fg.b*a+bg.b*(1-a),a:1}; }
  function bgOf(el){ const stack=[]; let e=el;
    while(e && e.nodeType===1){ const c=parse(getComputedStyle(e).backgroundColor); if(c && c.a>0){ stack.push(c); if(c.a>=1) break; } e=e.parentElement; }
    let base={r:255,g:255,b:255,a:1}; for(let i=stack.length-1;i>=0;i--){ base=blend(stack[i],base); } return base; }
  const out=[]; const seen=new Set();
  for(const el of document.querySelectorAll('body *')){
    const cs=getComputedStyle(el);
    if(cs.display==='none'||cs.visibility==='hidden'||parseFloat(cs.opacity)===0) continue;
    let own=''; for(const n of el.childNodes){ if(n.nodeType===3) own+=n.textContent; }
    own=own.trim(); if(!own) continue;
    const r=el.getBoundingClientRect(); if(r.width===0||r.height===0) continue;
    let fg=parse(cs.color); if(!fg) continue; const bg=bgOf(el); fg=blend(fg,bg);
    const l1=L(fg), l2=L(bg); const ratio=(Math.max(l1,l2)+0.05)/(Math.min(l1,l2)+0.05);
    const size=parseFloat(cs.fontSize), bold=parseInt(cs.fontWeight)>=700;
    const need=(size>=24||(bold&&size>=18.66))?3:4.5;
    if(ratio+1e-6<need){ const key=el.tagName+'|'+cs.color+'|'+cs.backgroundColor+'|'+own.slice(0,20);
      if(!seen.has(key)){ seen.add(key); out.push({tag:el.tagName.toLowerCase(), cls:(el.className||'').toString().slice(0,60),
        text:own.slice(0,40), ratio:+ratio.toFixed(2), need}); } }
  }
  return out;
}
"""

JS_OVERFLOW = r"""
() => {
  const de=document.documentElement;
  const res={docScroll: de.scrollWidth>de.clientWidth+1, scrollWidth:de.scrollWidth, clientWidth:de.clientWidth, wide:[]};
  function inScroller(el){ let e=el.parentElement; while(e&&e!==document.body){ const o=getComputedStyle(e).overflowX;
    if(o==='auto'||o==='scroll'||o==='hidden') return true; e=e.parentElement; } return false; }
  for(const el of document.querySelectorAll('body *')){
    const r=el.getBoundingClientRect(); if(r.width===0) continue;
    if(r.right>de.clientWidth+1 && !inScroller(el) && getComputedStyle(el).position!=='fixed'){
      res.wide.push({tag:el.tagName.toLowerCase(), cls:(el.className||'').toString().slice(0,60), right:Math.round(r.right)});
      if(res.wide.length>=15) break; } }
  return res;
}
"""

JS_DEMOS = r"""
() => [...document.querySelectorAll('figure.demo')].map(f => {
  const i = f.querySelector('iframe');
  return {src: f.getAttribute('data-src'), missing: !!f.querySelector('.demo-missing'),
          iframe: !!i, sandbox: i ? i.getAttribute('sandbox') : null, h: i ? Math.round(i.getBoundingClientRect().height) : 0,
          w: i ? Math.round(i.getBoundingClientRect().width) : 0};
})
"""


JS_FRAME_FONTS = r"""
() => {
  const OK = /sans-serif|pretendard|apple sd gothic|malgun|맑은 고딕|noto sans|segoe ui|system-ui|-apple-system|blinkmacsystemfont|helvetica|arial|monospace/i;
  const bad = []; let n = 0;
  for (const el of document.querySelectorAll('body, body *')) {
    const cs = getComputedStyle(el);
    if (cs.display === 'none' || cs.visibility === 'hidden') continue;
    let own = ''; for (const c of el.childNodes) { if (c.nodeType === 3) own += c.textContent; }
    own = own.trim(); if (!own) continue;
    n++;
    if (!OK.test(cs.fontFamily)) { bad.push({tag: el.tagName.toLowerCase(), font: cs.fontFamily.slice(0, 60), text: own.slice(0, 30)}); if (bad.length >= 5) break; }
  }
  return {url: location.href, textEls: n, bad: bad};
}
"""


def frame_fonts(pg):
    """시안(iframe) 마다 글자 요소의 글꼴 목록에 고딕(sans) 계열이 있는지 — 없으면 맥 크롬 기본(명조·Times)으로 그려진다."""
    out = []
    for fr in pg.frames:
        if fr == pg.main_frame:
            continue
        try:
            r = fr.evaluate(JS_FRAME_FONTS)
        except Exception as e:   # 아직 안 열렸거나 닫힌 칸
            r = {"url": fr.url, "textEls": 0, "bad": [], "error": str(e)[:80]}
        out.append(r)
    return out


def launch_browser(p):
    """설치된 Google Chrome(사용자가 실제로 보는 브라우저)이 있으면 그것으로, 없으면 playwright 의 Chromium 으로."""
    try:
        return p.chromium.launch(channel="chrome"), "chrome"
    except Exception:
        return p.chromium.launch(), "chromium"


def demo_shots(pg, shots, w):
    """시안 칸마다 요소 캡처 — 전체 페이지 캡처에서는 시안 칸이 비어 보이기 때문에 따로 찍는다."""
    names = []
    for f in pg.query_selector_all("figure.demo"):
        try:
            cid = f.evaluate("e => { const c = e.closest('.dec'); return c ? c.getAttribute('data-id') : 'x'; }")
            n = f.get_attribute("data-n") or "0"
            f.scroll_into_view_if_needed()
            pg.wait_for_timeout(250)
            nm = "demo-%s-%s-w%d.png" % (re.sub(r"[^A-Za-z0-9_.\-]", "_", cid or "x"), n, w)
            f.screenshot(path=os.path.join(shots, nm))
            names.append(nm)
        except Exception:
            pass
    return names


def rendered_fonts(page):
    cdp = page.context.new_cdp_session(page)
    cdp.send("DOM.enable")
    cdp.send("CSS.enable")
    root = cdp.send("DOM.getDocument", {"depth": -1, "pierce": False})
    fonts, samples = {}, {}

    def walk(n):
        if n.get("nodeType") == 1 and n.get("nodeName") not in ("SCRIPT", "STYLE", "HEAD", "TITLE", "META", "LINK"):
            kids = n.get("children", []) or []
            if any(k.get("nodeType") == 3 and (k.get("nodeValue") or "").strip() for k in kids):
                try:
                    r = cdp.send("CSS.getPlatformFontsForNode", {"nodeId": n["nodeId"]})
                    for f in r.get("fonts", []):
                        k = f["familyName"]
                        fonts[k] = fonts.get(k, 0) + f["glyphCount"]
                        if k not in samples:
                            txt = "".join(c.get("nodeValue", "") for c in kids if c.get("nodeType") == 3).strip()
                            samples[k] = "%s: %s" % (n["nodeName"].lower(), txt[:40])
                except Exception:
                    pass
        for c in n.get("children", []) or []:
            walk(c)

    walk(root["root"])
    return fonts, samples


def render_check(path, shots=None):
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        return None
    url = "file://" + quote(os.path.abspath(path))
    rep = {}
    with sync_playwright() as p:
        b, rep["browser"] = launch_browser(p)
        try:
            for w, h in ((1280, 900), (375, 812)):
                ctx = b.new_context(viewport={"width": w, "height": h}, device_scale_factor=1)
                pg = ctx.new_page()
                errs = []
                pg.on("console", lambda m, errs=errs: errs.append(m.text) if m.type == "error" else None)
                pg.on("pageerror", lambda e, errs=errs: errs.append(str(e)))
                pg.goto(url)
                pg.wait_for_timeout(700)
                r = {"overflow": pg.evaluate(JS_OVERFLOW), "consoleErrors": list(errs), "demos": pg.evaluate(JS_DEMOS)}
                if w == 1280:
                    rep["demoFonts"] = frame_fonts(pg)
                    # 글꼴 측정(CDP CSS.enable)이 sandbox iframe 원본을 다시 읽으며 내는 「Not allowed to load local resource」는
                    # 개발자 도구 부산물이라, 콘솔 오류는 그 전에(위에서) 끊어 센다. 시안이 같은 폴더의 다른 파일을 부를 때도 같은
                    # 문구가 나오는데, 그것은 로드 때 나므로 위 consoleErrors 에 들어간다(정적 점검이 「다른 파일·주소를 부릅니다」로 함께 잡는다)
                    fonts, samples = rendered_fonts(pg)
                    rep["fonts"] = fonts
                    rep["serif"] = {k: v for k, v in fonts.items() if SERIF.search(re.sub(r"sans[\s-]+serif", " ", k, flags=re.I))}
                    rep["serifSamples"] = {k: samples.get(k) for k in rep["serif"]}
                    rep["contrastFails"] = pg.evaluate(JS_CONTRAST)
                if shots:
                    os.makedirs(shots, exist_ok=True)
                    pg.screenshot(path=os.path.join(shots, "w%d.png" % w), full_page=True)
                    rep.setdefault("demoShots", []).extend(demo_shots(pg, shots, w))
                rep["w%d" % w] = r
                ctx.close()
        finally:
            b.close()
    rep["summary"] = {
        "serifGlyphs": sum(rep["serif"].values()),
        "contrastFails": len(rep["contrastFails"]),
        "overflow1280": int(rep["w1280"]["overflow"]["docScroll"]) + len(rep["w1280"]["overflow"]["wide"]),
        "overflow375": int(rep["w375"]["overflow"]["docScroll"]) + len(rep["w375"]["overflow"]["wide"]),
        "consoleErrors": len(rep["w1280"]["consoleErrors"]) + len(rep["w375"]["consoleErrors"]),
        "demoNoSandbox": sum(1 for d in rep["w1280"]["demos"] if d["iframe"] and d["sandbox"] != "allow-scripts allow-forms allow-modals allow-popups"),
        "demoSerif": sum(1 for f in rep.get("demoFonts", []) if f["bad"]),
    }
    return rep


def cmd_check(a):
    if not os.path.isfile(a.page):
        die("페이지가 없습니다: " + a.page)
    E, W, info = static_check(a.page)
    rep = None
    render_skipped = False
    if a.render:
        rep = render_check(a.page, a.shots)
        if rep is None:
            render_skipped = True
        else:
            s = rep["summary"]
            if s["serifGlyphs"]:
                E.append("렌더: 세리프 글꼴로 그려진 글자 %d개 — %s" % (s["serifGlyphs"], json.dumps(rep["serifSamples"], ensure_ascii=False)))
            if s["contrastFails"]:
                E.append("렌더: 글자 대비 4.5 미달 %d곳 — %s" % (s["contrastFails"], json.dumps(rep["contrastFails"][:5], ensure_ascii=False)))
            for wd in (1280, 375):
                o = rep["w%d" % wd]["overflow"]
                if o["docScroll"] or o["wide"]:
                    E.append("렌더: %d 폭 가로 넘침 — 문서 %d/%d px, 넘친 요소 %s" % (wd, o["scrollWidth"], o["clientWidth"],
                                                                     json.dumps(o["wide"][:5], ensure_ascii=False)))
                if rep["w%d" % wd]["consoleErrors"]:
                    E.append("렌더: %d 폭 콘솔 오류 — %s" % (wd, " / ".join(rep["w%d" % wd]["consoleErrors"][:5])))
            if s["demoNoSandbox"]:
                E.append("렌더: sandbox 가 다른 시안 iframe %d개" % s["demoNoSandbox"])
            for f in rep.get("demoFonts", []):
                if f["bad"]:
                    E.append("렌더: 시안 %s 의 글자가 고딕(sans) 글꼴 없이 그려집니다(맥 크롬 기본 = 명조·Times) — %s"
                             % (f["url"].rsplit("/", 1)[-1], json.dumps(f["bad"][:3], ensure_ascii=False)))
    if a.json:
        print(json.dumps({"ok": not E and not render_skipped, "errors": E, "warnings": W, "info": info,
                          "render": rep and rep["summary"], "renderSkipped": render_skipped}, ensure_ascii=False, indent=1))
    else:
        say("점검: %s — %d회차 · 카드 %d · 시안 %d · 이전 회차 %d" % (a.page, info["round"], info["cards"], info["demos"], info["rounds_done"]))
        for e in E:
            say("  [문제] " + e)
        for w in W:
            say("  [경고] " + w)
        if rep:
            s = rep["summary"]
            say("  렌더(%s): 세리프 %d · 대비 미달 %d · 넘침 1280=%d 375=%d · 콘솔 오류 %d · 시안 iframe %d개 · 고딕 없는 시안 %d"
                % (rep.get("browser"), s["serifGlyphs"], s["contrastFails"], s["overflow1280"], s["overflow375"], s["consoleErrors"],
                   sum(1 for d in rep["w1280"]["demos"] if d["iframe"]), s["demoSerif"]))
            if rep.get("demoShots"):
                say("  시안 칸 캡처 %d장(전체 페이지 캡처에서는 시안 칸이 비어 보입니다): %s" % (len(rep["demoShots"]), ", ".join(rep["demoShots"][:6])))
        if render_skipped:
            say("  [렌더 점검 못 함] playwright 가 없습니다 — 글꼴·대비·넘침은 확인하지 못했습니다(pip install playwright && playwright install chromium)")
        say("결과: " + ("통과" if not E and not render_skipped else ("문제 %d건" % len(E) if E else "정적 점검만 통과")))
    if E:
        sys.exit(1)
    if render_skipped:
        sys.exit(3)


# ───────────────────────── serve ─────────────────────────
MAX_BODY = 2000000
DEMO_CSP = "sandbox allow-scripts allow-forms allow-modals allow-popups"   # 페이지 말고 내주는 파일(시안·그림) — 직접 열어도 출처 없음
LONE_SURROGATE = re.compile("[\ud800-\udfff]")


def token_ok(t, token):
    """일회용 토큰 비교 — 글자가 아니거나 ASCII 밖(짝 없는 대리 문자 등)이면 바로 거절(예외 없이)."""
    return isinstance(t, str) and t.isascii() and hmac.compare_digest(t.encode("ascii"), token.encode("ascii"))


def cmd_serve(a):
    from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
    from urllib.parse import parse_qs

    page = os.path.realpath(a.page)
    if not os.path.isfile(page):
        die("질문 페이지가 없습니다: " + a.page)
    root = os.path.dirname(page)
    name = os.path.basename(page)
    out = os.path.abspath(a.out)
    token = secrets.token_urlsafe(18)
    done = threading.Event()
    lock = threading.Lock()
    port_box = [0]
    closing = [False]       # 창구를 닫기 시작한 뒤 들어온 답은 받지 않는다(종료 코드와 답 파일이 늘 맞게)

    class H(BaseHTTPRequestHandler):
        server_version = "fbq"
        sys_version = ""

        def log_message(self, *args):
            pass

        def _send(self, code, body, ctype="application/json; charset=utf-8", head=False, csp=None):
            b = body if isinstance(body, bytes) else body.encode("utf-8")
            self.send_response(code)
            self.send_header("Content-Type", ctype)
            if csp:
                self.send_header("Content-Security-Policy", csp)
            self.send_header("Content-Length", str(len(b)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.send_header("Referrer-Policy", "no-referrer")
            self.end_headers()
            if not head:
                self.wfile.write(b)

        def _deny(self, code, why, head=False):
            return self._send(code, json.dumps({"ok": False, "error": why}), head=head)

        def _host_ok(self):
            # 다른 사이트가 이름을 127.0.0.1 로 돌려 들어오는 것(DNS 재바인딩)을 막는다
            h = (self.headers.get("Host") or "").strip().lower()
            return h in ("127.0.0.1:%d" % port_box[0], "localhost:%d" % port_box[0])

        def _split(self):
            raw = self.path
            if not raw.startswith("/"):
                return None, ""
            path, _, query = raw.partition("?")
            return path.split("#", 1)[0], query

        def do_HEAD(self):
            self._get(head=True)

        def do_GET(self):
            self._get(head=False)

        def _get(self, head):
            if not self._host_ok():
                return self._deny(403, "host", head)
            path, query = self._split()
            if path is None:
                return self._deny(400, "path", head)
            q = parse_qs(query)
            if path == "/ping":
                t = (q.get("t") or [""])[0]
                if t and token_ok(t, token):
                    return self._send(200, json.dumps({"ok": True, "waiting": not done.is_set()}), head=head)
                return self._deny(403, "token", head)
            rel = unquote(path)                       # %2e%2e 같은 인코딩을 먼저 푼 뒤 판정한다
            if "\x00" in rel or "\\" in rel:
                return self._deny(403, "outside", head)
            segs = [s for s in rel.split("/") if s not in ("", ".")]
            if any(s == ".." for s in segs):
                return self._deny(403, "outside", head)
            if not segs or (len(segs) == 1 and nfc(segs[0]) == nfc(name)):
                try:
                    with open(page, "rb") as f:
                        return self._send(200, f.read(), "text/html; charset=utf-8", head)
                except OSError:
                    return self._deny(404, "page", head)
            if any(s.startswith(".") for s in segs):
                return self._deny(403, "hidden", head)
            full = os.path.realpath(os.path.join(root, *segs))   # 심볼릭 링크를 풀어 실제 위치로 판정
            try:
                inside = os.path.commonpath([root, full]) == root and full != root
            except ValueError:
                inside = False
            if not inside:
                return self._deny(403, "outside", head)
            if not os.path.isfile(full):
                return self._deny(404, "not found", head)
            ctype = mimetypes.guess_type(full)[0] or "application/octet-stream"
            if ctype.startswith("text/") or ctype in ("application/javascript", "application/json", "image/svg+xml"):
                ctype += "; charset=utf-8"
            try:
                with open(full, "rb") as f:
                    data = f.read()
            except OSError:
                return self._deny(404, "unreadable", head)
            # 시안을 「새 창」이나 주소로 직접 열어도 sandbox(출처 없음) — 질문 페이지 저장값에 닿지 못한다
            return self._send(200, data, ctype, head, csp=DEMO_CSP)

        def do_POST(self):
            if not self._host_ok():
                return self._deny(403, "host")
            path, _ = self._split()
            if path != "/answer":
                return self._deny(404, "not found")
            if done.is_set():
                return self._deny(409, "already answered")
            try:
                n = int(self.headers.get("Content-Length") or "")
            except ValueError:
                return self._deny(411, "length")
            if n < 0 or n > MAX_BODY:
                return self._deny(413, "too large")
            try:
                data = json.loads(self.rfile.read(n).decode("utf-8"))
            except (UnicodeDecodeError, ValueError, RecursionError):   # 깨진 글자·JSON 아님·지나치게 깊은 중첩
                return self._deny(400, "bad json")
            except OSError:
                return
            if not isinstance(data, dict):
                return self._deny(400, "bad json")
            if not token_ok(data.get("token"), token):
                return self._deny(403, "token")
            if not isinstance(data.get("text"), str) and not isinstance(data.get("answers"), list):
                return self._deny(400, "no answer")
            with lock:
                if done.is_set():
                    return self._deny(409, "already answered")
                if closing[0]:
                    return self._deny(503, "closed")
                rec = {"received_at": datetime.now().isoformat(timespec="seconds"), "page": page,
                       "title": data.get("title"), "round": data.get("round"), "fbKey": data.get("fbKey"),
                       "counts": data.get("counts"), "text": data.get("text") if isinstance(data.get("text"), str) else "",
                       "answers": data.get("answers") if isinstance(data.get("answers"), list) else []}
                try:
                    # 짝 없는 대리 문자(이모지 반쪽 등)는 UTF-8 로 쓸 수 없어 U+FFFD 로 바꾼다(정상 짝은 json.loads 가 이미 한 글자로 합침)
                    s = LONE_SURROGATE.sub("\ufffd", json.dumps(rec, ensure_ascii=False, indent=1)) + "\n"
                    write_atomic(out, s)
                except Exception as e:   # 저장 실패 — 창구는 계속 기다린다(사용자는 다시 누르거나 결과 복사)
                    try:
                        return self._deny(500, "save failed: %s" % type(e).__name__)
                    except OSError:
                        return
                try:
                    self._send(200, json.dumps({"ok": True}))
                except OSError:
                    pass        # 응답 전에 연결이 끊겨도(RST) 답은 저장됐다 — 끝낸다
                finally:
                    done.set()

    try:
        srv = ThreadingHTTPServer(("127.0.0.1", a.port), H)
    except OSError as e:
        die("창구를 열지 못했습니다(127.0.0.1:%d): %s" % (a.port, e))
    srv.daemon_threads = True
    port_box[0] = srv.server_address[1]
    if os.path.isdir(out):
        srv.server_close()
        die("--out 이 폴더입니다: " + out)
    moved = None
    if os.path.lexists(out):
        # 같은 경로의 지난 답 파일 — 지우지 않고 옆으로 옮긴다. 창구가 끝난 뒤 이 경로의 답 파일은 언제나 이번 실행에서 받은 것이다
        # 옮기기는 주소를 찍기 전에 한다(실패해 멈출 때 죽은 주소가 찍히지 않게). 옮김 안내는 주소 다음 줄에 —
        # SKILL 은 stdout·stderr 를 한 로그로 합쳐 첫 줄을 접속 주소로 읽는다
        stem, ext = os.path.splitext(out)
        old = "%s.old-%s%s" % (stem, datetime.now().strftime("%Y%m%d%H%M%S"), ext or ".json")
        i = 1
        while os.path.lexists(old):
            i += 1
            old = "%s.old-%s-%d%s" % (stem, datetime.now().strftime("%Y%m%d%H%M%S"), i, ext or ".json")
        try:
            os.replace(out, old)
        except OSError as e:
            srv.server_close()
            die("이미 있는 답 파일을 옮기지 못했습니다(%s): %s — 다른 --out 경로로 띄우세요" % (out, e))
        moved = old
    print("http://127.0.0.1:%d/%s?t=%s" % (port_box[0], quote(nfc(name)), token), flush=True)
    if moved:
        say("이미 있던 답 파일을 옮겼습니다: %s → %s" % (out, moved), err=True)
    say("창구: 페이지 폴더 %s 안의 파일만 · 답 → %s · 시간 초과 %d초" % (root, out, a.timeout), err=True)
    th = threading.Thread(target=srv.serve_forever, daemon=True)
    th.start()
    try:
        ok = done.wait(a.timeout)
    except KeyboardInterrupt:
        ok = False
        say("중단했습니다", err=True)
        srv.shutdown()
        sys.exit(130)
    time.sleep(0.4)   # 응답이 브라우저에 닿을 시간
    srv.shutdown()
    srv.server_close()
    with lock:
        # 시간 초과 직후(위 0.4초·닫는 사이)에 저장된 답도 받은 것으로 본다. 처리기는 lock 을 잡은 채 저장하고 done 을 세우므로
        # 여기서 lock 을 잡으면 저장 중인 답을 놓치지 않고, closing 을 세운 뒤에는 새 답을 저장하지 않는다
        closing[0] = True
        ok = ok or done.is_set()
    if ok:
        print("ANSWER_RECEIVED " + out, flush=True)
        sys.exit(0)
    print("TIMEOUT", flush=True)
    sys.exit(2)


# ───────────────────────── open ─────────────────────────
AS_LIST = r'''
on run argv
  set appName to item 1 of argv
  if application appName is not running then return "NOT_RUNNING"
  set out to ""
  set TB to character id 9
  using terms from application "Google Chrome"
    tell application appName
      -- 창·탭 id 는 20억이 넘을 수 있다(AppleScript 정수 한도 약 5억 3천만) — 숫자로 다루지 않고 글자로 내보낸다.
      -- 도는 중에 탭이 닫히면 -1719(유효하지 않은 인덱스)가 나므로 창·탭마다 try 로 감싼다.
      repeat with w in (every window)
        try
          set wid to (id of w) as text
          set n to count of tabs of w
          repeat with i from 1 to n
            try
              set t to tab i of w
              set out to out & wid & TB & ((id of t) as text) & TB & (URL of t) & linefeed
            end try
          end repeat
        end try
      end repeat
    end tell
  end using terms from
  return out
end run
'''

AS_SET = r'''
on run argv
  set appName to item 1 of argv
  set newURL to item 2 of argv
  -- id 는 글자로 비교한다 — 「as integer」 로 바꾸면 20억이 넘는 id 가 실수(2.0E+9)가 되어 같은 탭인데도 다르다고 나온다
  -- (2026-10-01 실측: 맞는 탭을 못 찾았는데도 「OK」 를 돌려 「바꿨습니다」 거짓 보고)
  set widText to item 3 of argv
  set tidText to item 4 of argv
  using terms from application "Google Chrome"
    tell application appName
      repeat with w in (every window)
        try
          if ((id of w) as text) is widText then
            set n to count of tabs of w
            repeat with i from 1 to n
              try
                set t to tab i of w
                if ((id of t) as text) is tidText then
                  set URL of t to newURL
                  set active tab index of w to i
                  set index of w to 1
                  activate
                  return "OK " & i
                end if
              end try
            end repeat
          end if
        end try
      end repeat
    end tell
  end using terms from
  return "NOTFOUND"
end run
'''


def tab_key(url_or_name):
    """주소·파일 경로·파일명 → 비교용 파일명(퍼센트 인코딩 풀고 NFC — 맥은 한글 파일명을 자모 분리(NFD)로 줄 때가 있다)."""
    s = str(url_or_name or "").split("#", 1)[0].split("?", 1)[0].rstrip("/")
    return nfc(unquote(s.rsplit("/", 1)[-1])).lower()


def is_full_view(url):
    """「새 창으로 크게 보기」 탭(페이지.html#full=시안경로) — 질문 페이지와 파일명이 같지만 질문 탭이 아니다."""
    frag = str(url or "").split("#", 1)[1] if "#" in str(url or "") else ""
    return frag.startswith("full=")


def pick_tab(tabs, match):
    """tabs: [(창 id, 탭 id, 주소)] — 파일명이 같은 첫 탭(앞 창 우선). 크게 보기 탭(#full=)은 질문 탭이 없을 때만 고른다.
    없으면 None."""
    key = tab_key(match)
    if not key:
        return None
    same = [t for t in tabs if tab_key(t[2]) == key]
    for t in same:
        if not is_full_view(t[2]):
            return t
    return same[0] if same else None


def cmd_open(a):
    url = a.url.strip()
    if not re.match(r"^(https?|file)://", url, re.I):
        die("주소는 http:// · https:// · file:// 로 시작해야 합니다: " + url)
    if sys.platform != "darwin":
        import webbrowser
        if a.dry_run:
            say("(시험) webbrowser 로 열 예정: " + url)
            return
        webbrowser.open(url)
        say("열었습니다(webbrowser): " + url)
        return
    osa = shutil.which("osascript")
    tabs, why = None, ""
    if osa:
        try:
            r = subprocess.run([osa, "-e", AS_LIST, a.app], capture_output=True, text=True, timeout=30)
        except subprocess.TimeoutExpired:
            # 처음 쓰는 맥은 「크롬 제어 허용」 창이 뜨고 답할 때까지 osascript 가 기다린다 — 멈추지 말고 새로 연다
            r = None
            why = "크롬 탭을 읽지 못했습니다(30초 초과 — 화면에 자동화 권한 허용 창이 떠 있는지 확인)"
        if r is None:
            pass
        elif r.returncode == 0 and r.stdout.strip() != "NOT_RUNNING":
            tabs = []
            for ln in r.stdout.splitlines():
                parts = ln.split("\t", 2)
                if len(parts) == 3 and parts[0].strip().isdigit() and parts[1].strip().isdigit():
                    tabs.append((int(parts[0]), int(parts[1]), parts[2]))
        elif r.returncode != 0:
            why = (r.stderr or "").strip()[:200]
    hit = pick_tab(tabs or [], a.match) if tabs is not None else None
    if a.dry_run:
        if why:
            say("경고: " + why, err=True)
        say("(시험) 탭 %s개 · 맞는 탭: %s" % ("?" if tabs is None else len(tabs), hit or "없음 → 새로 엶"))
        return
    if hit:
        try:
            r = subprocess.run([osa, "-e", AS_SET, a.app, url, str(hit[0]), str(hit[1])], capture_output=True, text=True, timeout=30)
        except subprocess.TimeoutExpired:
            r = None
            why = "크롬 탭 주소를 바꾸지 못했습니다(30초 초과 — 화면에 자동화 권한 허용 창이 떠 있는지 확인)"
        if r is not None and r.returncode == 0 and r.stdout.strip().startswith("OK"):
            # 응답만 믿지 않고 그 탭의 주소를 다시 읽어 확인한다(거짓 「바꿨습니다」 방지). 페이지가 넘어가는 동안은 탭을
            # 읽지 못할 수 있어 0.5초 간격으로 최대 3초 다시 본다(2026-10-01 실측: 0.5초 뒤에는 못 읽고 1.5초 뒤에는 읽힘).
            want = url.split("#", 1)[0]
            seen = []
            for _ in range(6):
                time.sleep(0.5)
                try:
                    r2 = subprocess.run([osa, "-e", AS_LIST, a.app], capture_output=True, text=True, timeout=30)
                except subprocess.TimeoutExpired:
                    continue
                seen = [ln.split("\t", 2)[2] for ln in (r2.stdout or "").splitlines()
                        if len(ln.split("\t", 2)) == 3 and ln.split("\t", 2)[1].strip() == str(hit[1])]
                if seen and seen[0].split("#", 1)[0] == want:
                    say("같은 페이지 탭의 주소를 바꿨습니다(새 탭 없음 · 바뀐 주소 확인): " + url)
                    return
            if not seen:
                # 탭을 끝내 읽지 못함 — 교체 응답(OK)은 맞는 탭을 찾았을 때만 오므로 새 탭을 또 열지 않는다(탭이 둘로 늘어나는 것 방지)
                say("같은 페이지 탭의 주소를 바꿨습니다(새 탭 없음). 다만 바뀐 주소를 다시 읽어 확인하지는 못했습니다 — 탭을 확인해 주세요: " + url)
                return
            why = "탭 주소를 바꿨다는 응답은 왔지만 탭이 옛 주소 그대로입니다(지금 주소: %s)" % seen[0][:120]
        elif r is not None:
            why = ((r.stderr or "").strip() or "맞는 탭을 찾지 못했습니다(%s)" % (r.stdout or "").strip())[:200]
    if why:
        say("경고: 크롬 탭을 읽거나 바꾸지 못했습니다(자동화 권한 확인) — 새로 엽니다: " + why, err=True)
    r = subprocess.run(["open", "-a", a.app, url], capture_output=True, text=True)
    if r.returncode != 0:
        import webbrowser
        webbrowser.open(url)
        say("열었습니다(기본 브라우저 — %s 를 찾지 못함): %s" % (a.app, url))
        return
    say("열었습니다(%s): %s" % (a.app, url))


# ───────────────────────── read ─────────────────────────
LABEL = (r"(?:(?P<c>[①-⑳])|\(\s*(?P<p>\d{1,2})\s*\))\s*(?P<k>채택\s*\(\s*추천\s*\)|채택|선택)"
         r"|(?P<w>수정|보류|미결정)")
HEAD_RE = re.compile(r"\[\s*결정\s*결과\s*\]\s*(?P<title>.*?)\s*(?:(?:—|–|--?)\s*(?P<round>\d+)\s*회차\s*)?(?:—|–|--?)\s*결정\s*"
                     r"(?P<n>\d+)\s*/\s*(?P<N>\d+)\s*$")
# 카드 번호 모양 — 기본 번호(R1-1)와 validate_spec 이 받는 모든 번호(PoC-1·Q-3·R1.1·1 …)
ID_NARROW = r"[A-Za-z]{1,4}\d+(?:-\d+)?"
ID_WIDE = r"[A-Za-z0-9][A-Za-z0-9_.\-]*"
# 「… — 보류」·「… — ② 선택 / 메모: …」처럼 카드 줄 꼬리를 가진 줄(번호를 못 읽었어도 카드 줄로 보이는 것)
LABEL_TAIL = re.compile(r"(?:—|–|--?)\s*(?:" + LABEL + r")\s*(?:/\s*메모\s*:.*)?$")
QUOTE_PREFIX = re.compile(r"^[ \t]*(?:>[ \t]?)+")
QUOTE_ONE = re.compile(r"^[ \t]{0,3}>[ \t]?")        # 인용 표시 한 겹(「> 」)


def quote_depth(ln):
    """줄 앞 인용 표시(>)가 몇 겹인지."""
    m = QUOTE_PREFIX.match(ln or "")
    return m.group(0).count(">") if m else 0


def strip_quote(ln, depth):
    """인용 표시를 depth 겹만 뗀다 — 그 뒤의 들여쓰기(메모 둘째 줄의 공백 4칸)와 메모 안의 「>」는 남긴다."""
    for _ in range(depth):
        m = QUOTE_ONE.match(ln)
        if not m:
            break
        ln = ln[m.end():]
    return ln


def card_re(ids=None, wide=False):
    """카드 줄 정규식. ids(페이지의 이번 회차 카드 번호)를 주면 그 번호들만 카드로 본다 — 들여쓰기가 사라진 메모 줄을
    카드로 잘못 읽지 않으면서 사용자가 정한 번호(PoC-1 등)도 읽는다. 없으면 기본 모양(wide=True 면 넓은 모양)."""
    if ids:
        idp = "|".join(re.escape(i) for i in sorted(set(ids), key=len, reverse=True))
    else:
        idp = ID_WIDE if wide else ID_NARROW
    return re.compile(r"^(?P<id>" + idp + r")\s+(?P<title>.*?)\s*(?:—|–|--?)\s*(?P<label>" + LABEL + r")\s*"
                      r"(?:/\s*메모\s*:\s?(?P<memo>.*))?$")


CARD_RE = card_re()
CHOICE_KO = {"modify": "수정", "hold": "보류", "none": "미결정"}


def choice_label(choice, rec, adopted=None):
    if choice in CHOICE_KO:
        return CHOICE_KO[choice]
    n = int(choice)
    if adopted is None:
        adopted = (n == rec)
    return circ(n) + (" 채택(추천)" if adopted else " 선택")


def norm_answer(x):
    """전송 JSON 의 answers 한 칸 → 표준 모양."""
    ch = str(x.get("choice", "none") if x.get("choice") is not None else "none").strip().lower()
    m = re.match(r"^n?(\d+)$", ch)
    if m:
        ch = str(int(m.group(1)))
    elif ch in ("수정",):
        ch = "modify"
    elif ch in ("보류",):
        ch = "hold"
    elif ch not in ("modify", "hold"):
        ch = "none"
    rec = x.get("rec") if isinstance(x.get("rec"), int) else 0
    adopted = bool(x.get("adopted")) if "adopted" in x else (ch.isdigit() and int(ch) == rec)
    lab = str(x.get("choiceLabel") or "").strip() or choice_label(ch, rec, adopted if ch.isdigit() else None)
    return {"id": str(x.get("id") or "").strip(), "title": str(x.get("title") or "").strip(), "choice": ch,
            "choiceKo": (ch + "번") if ch.isdigit() else CHOICE_KO[ch], "choiceLabel": lab,
            "adopted": bool(ch.isdigit() and adopted), "memo": str(x.get("memo") or "").rstrip()}


def clean_paste(s):
    s = s.replace("\r\n", "\n").replace("\r", "\n")
    s = s.replace(" ", " ").replace("　", " ").replace(" ", " ").replace(" ", " ")
    s = re.sub("[​‌‍⁠﻿]", "", s)
    return s


def _scan_cards(lines, hi, base, total, cre, headed, qdepth=0):
    """머리 다음 줄부터 카드 줄을 읽는다 → (카드 목록, 경고, 답·메모가 빠졌을 수 있는 경고).
    qdepth: 붙여 넣은 글 전체에 붙은 인용 표시(>) 겹 수 — 먼저 떼고 나서 들여쓰기·빈 줄을 판단한다."""
    warns, risky = [], []

    def flag(msg):
        warns.append(msg)
        risky.append(msg)

    cards, blanks, pending, seen = [], 0, [], set()   # pending: 카드 줄로도 메모로도 못 읽은 줄 [(앞 빈 줄 수, 글)]
    for raw in lines[hi + 1:]:
        ln = strip_quote(raw.expandtabs(4), qdepth).rstrip()
        if not ln.strip():
            blanks += 1
            continue
        ind = len(ln) - len(ln.lstrip(" "))
        if cards and cards[-1]["_memo"] and ind >= base + 2 and not pending:
            # 메모 안 줄바꿈 — 페이지는 다음 줄 앞에 공백 4칸을 붙인다
            cards[-1]["memo"] += "\n" * (blanks + 1) + ln[min(ind, base + 4):]
            blanks = 0
            continue
        body = QUOTE_PREFIX.sub("", ln).strip()
        body = re.sub(r"^[-•·*]\s+(?=[A-Za-z0-9])", "", body)
        m = cre.match(body)
        if m:
            if total is not None and len(cards) >= total:
                flag("머리의 카드 수(%d)보다 카드 줄이 많아 뒤는 읽지 않았습니다: %s" % (total, body[:40]))
                pending = []
                break
            if m.group("id") in seen:
                flag("같은 번호(%s)의 카드 줄이 또 있어 읽지 않았습니다(메모 줄이 카드처럼 보이는지 확인): %s" % (m.group("id"), body[:40]))
                blanks = 0
                continue
            if pending:
                prev = cards[-1] if cards else None
                if prev is not None and prev["_memo"]:
                    # 메모 안 빈 줄 + 들여쓰기가 사라진 붙여 넣기 — 다음 카드 줄 앞까지는 앞 카드 메모로 잇는다
                    for nb, t in pending:
                        prev["memo"] += "\n" * (nb + 1) + t
                    flag("%s 메모 뒤(빈 줄 다음)에 들여쓰기 없는 줄이 있어 메모로 이었습니다(맞는지 확인): %s"
                         % (prev["id"], " / ".join(t for _, t in pending)[:60]))
                else:
                    for _, t in pending:
                        flag("읽지 않은 줄: %s" % t[:60])
                pending = []
            if m.group("c"):
                ch = str(CIRC.index(m.group("c")) + 1)
            elif m.group("p"):
                ch = str(int(m.group("p")))
            else:
                ch = {"수정": "modify", "보류": "hold", "미결정": "none"}[m.group("w")]
            k = re.sub(r"\s+", "", m.group("k") or "")
            seen.add(m.group("id"))
            cards.append({"id": m.group("id"), "title": m.group("title").strip(), "choice": ch,
                          "adopted": ch.isdigit() and k.startswith("채택"), "rec_hint": "추천" in k,
                          "memo": (m.group("memo") or "").strip(), "_memo": m.group("memo") is not None})
            blanks = 0
            continue
        looks_card = bool(LABEL_TAIL.search(body))
        if looks_card and (headed or cards):
            # 카드 줄 꼬리(— 보류 등)가 있는데 번호를 못 읽은 줄 — 메모로 잇지 않고 알린다
            flag("읽지 못한 카드 줄(번호가 이번 회차 카드와 맞지 않거나 줄이 꺾임): %s" % body[:60])
            blanks = 0
            continue
        if cards and cards[-1]["_memo"] and blanks == 0 and not pending:
            # 붙여 넣으며 들여쓰기가 사라진 메모 줄 — 빈 줄 없이 바로 이어지면 메모로 본다(확인하라고 경고)
            cards[-1]["memo"] += "\n" + body
            flag("%s 메모 다음 줄이 들여쓰기 없이 붙어 있어 메모로 이었습니다(맞는지 확인): %s" % (cards[-1]["id"], body[:30]))
            continue
        if headed or cards:
            pending.append((blanks, body))
        blanks = 0
    if pending and cards and cards[-1]["_memo"]:
        # 마지막 카드 뒤 줄 — 대개 인사말이지만, 메모 안 빈 줄 뒤 내용일 수도 있다
        warns.append("마지막 카드 %s 메모 뒤(빈 줄 다음) 줄은 읽지 않았습니다 — 메모의 일부라면 원문과 대조: %s"
                     % (cards[-1]["id"], " / ".join(t for _, t in pending)[:60]))
    return cards, warns, risky


def parse_text(s, ids=None):
    """결과 문장(복사·붙여 넣기) → (머리 정보, 답 목록, 경고, 답·메모가 빠졌을 수 있는 경고).
    ids: 페이지의 이번 회차 카드 번호 — 주면 그 번호만 카드 줄로 읽는다(사용자가 정한 번호도 정확히)."""
    warns, risky = [], []
    lines = clean_paste(s).split("\n")
    head, hi = None, -1
    for i, ln in enumerate(lines):
        m = HEAD_RE.search(QUOTE_PREFIX.sub("", ln).strip())
        if m:
            if head is None:
                head, hi = m, i
            else:
                msg = "「[결정 결과]」 머리가 두 번 이상 있습니다 — 첫 번째만 읽었습니다"
                warns.append(msg)
                risky.append(msg)
                lines = lines[:i]
                break
    if head is None:
        warns.append("「[결정 결과]」 머리 줄을 찾지 못했습니다 — 카드 줄만 읽습니다")
    base, qd = 0, 0
    if head is not None:
        # 「> 」 인용으로 붙여 넣은 글 — 머리 줄의 인용 겹 수만큼 모든 줄에서 떼고 들여쓰기를 잰다
        qd = quote_depth(lines[hi].expandtabs(4))
        hl = strip_quote(lines[hi].expandtabs(4), qd)
        base = len(hl) - len(hl.lstrip(" "))
    else:
        nb = [quote_depth(x.expandtabs(4)) for x in lines if x.strip() and QUOTE_PREFIX.sub("", x).strip()]
        qd = min(nb) if nb else 0
    total = int(head.group("N")) if head else None
    if ids:
        cards, w, r = _scan_cards(lines, hi, base, total, card_re(ids), head is not None, qd)
    else:
        # 페이지를 모를 때: 기본 번호 모양으로 먼저 읽고, 모자라면 validate_spec 이 받는 넓은 모양으로 다시 읽는다
        cards, w, r = _scan_cards(lines, hi, base, total, card_re(), head is not None, qd)
        if total is None or len(cards) < total:
            c2, w2, r2 = _scan_cards(lines, hi, base, total, card_re(wide=True), head is not None, qd)
            if len(c2) > len(cards):
                cards, w, r = c2, w2, r2
                w.append("카드 번호가 기본 모양(R1-1)이 아니라 넓게 읽었습니다 — 메모 줄이 카드로 읽히지 않았는지 원문과 대조"
                         "(--page 로 페이지를 주면 그 페이지의 카드 번호로 정확히 읽습니다)")
    warns += w
    risky += r
    out = []
    for c in cards:
        x = {"id": c["id"], "title": c["title"], "choice": c["choice"], "memo": c["memo"].rstrip(), "adopted": c["adopted"]}
        if c["choice"].isdigit():
            x["choiceLabel"] = choice_label(c["choice"], 0, c["adopted"])
        out.append(norm_answer(x))
    info = {}
    if head:
        info = {"title": head.group("title").strip(), "round": int(head.group("round")) if head.group("round") else None,
                "decided": int(head.group("n")), "total": total}
        if len(out) < total:
            msg = "머리에는 질문 %d건인데 카드 줄은 %d개만 읽었습니다" % (total, len(out))
            warns.append(msg)
            risky.append(msg)
    return info, out, warns, risky


def load_answers(path, ids=None):
    """전송 JSON(serve 가 저장) · read 출력 JSON · 결과 문장 글 파일 · '-'(표준 입력) → 표준 모양.
    ids: 페이지의 이번 회차 카드 번호(append 는 항상, read 는 --page 를 줄 때) — 글로 받은 답을 그 번호로 읽는다.
    source: answer-json(창구가 받은 답) · answer-json(text) · text(붙여 넣은 글) · read(…)(글을 읽은 read 출력 — 경고를 이어받음)."""
    raw = sys.stdin.read() if path == "-" else read_text(path)
    data = None
    try:
        data = json.loads(raw)
    except (ValueError, RecursionError):
        pass
    res = {"source": "", "title": None, "round": None, "fbKey": None, "received_at": None, "answers": [], "warnings": [],
           "loss_risk": [], "head_total": None}
    if isinstance(data, dict):
        for k in ("title", "round", "fbKey", "received_at"):
            res[k] = data.get(k)
        ans = data.get("answers")
        src = data.get("source")
        if isinstance(src, str) and src.startswith("read("):
            src = src[5:-1] if src.endswith(")") else src[5:]
        from_read = (isinstance(src, str) and src not in ("", "answer-json")) or (src is None and "loss_risk" in data)
        if isinstance(ans, list) and ans and all(isinstance(x, dict) for x in ans) and from_read:
            # fbq.py read 출력 — 붙여 넣은 글에서 읽은 답이다. 그 읽기의 경고·빠짐 의심·머리 질문 수를 이어받아,
            # append 가 붙여 넣기 원문을 받았을 때와 같은 기준(loss_risk·카드 수·머리 질문 수)으로 검사하게 한다
            res["source"] = "read(%s)" % (src or "text")
            res["answers"] = [norm_answer(x) for x in ans]
            for k in ("warnings", "loss_risk"):
                v = data.get(k)
                res[k] = [str(x) for x in v] if isinstance(v, list) else []
            ht = data.get("head_total")
            res["head_total"] = ht if isinstance(ht, int) and not isinstance(ht, bool) else None
        elif isinstance(ans, list) and ans and all(isinstance(x, dict) for x in ans):
            res["source"] = "answer-json"
            res["answers"] = [norm_answer(x) for x in ans]
            if res["round"] is None and isinstance(data.get("text"), str):
                info = parse_text(data["text"], ids)[0]
                res["round"] = info.get("round")
        elif isinstance(data.get("text"), str):
            res["source"] = "answer-json(text)"
            info, out, w, r = parse_text(data["text"], ids)
            res["answers"], res["warnings"], res["loss_risk"] = out, w, r
            res["head_total"] = info.get("total")
            res["title"] = res["title"] or info.get("title")
            res["round"] = res["round"] if res["round"] is not None else info.get("round")
        else:
            res["warnings"].append("JSON 안에 answers·text 가 없습니다")
    else:
        res["source"] = "text"
        info, out, w, r = parse_text(raw, ids)
        res["answers"], res["warnings"], res["loss_risk"] = out, w, r
        res["head_total"] = info.get("total")
        res["title"], res["round"] = info.get("title"), info.get("round")
    if isinstance(res["round"], str) and res["round"].isdigit():
        res["round"] = int(res["round"])
    ans = res["answers"]
    dec = sum(1 for x in ans if x["choice"] != "none")
    res["counts"] = {"total": len(ans), "decided": dec, "left": len(ans) - dec}
    return res


def cmd_read(a):
    src = a.answer or a.text
    if src != "-" and not os.path.isfile(src):
        die("파일이 없습니다: " + src)
    ids = None
    if a.page:
        if not os.path.isfile(a.page):
            die("페이지가 없습니다: " + a.page)
        ids = [c["id"] for c in card_infos(read_text(a.page))] or None
    res = load_answers(src, ids)
    if a.text and res["source"].startswith("answer-json"):
        res["warnings"].append("--text 로 받았지만 내용이 전송 JSON 이라 JSON 으로 읽었습니다")
    if ids and res["source"] != "answer-json":
        got = [x["id"] for x in res["answers"]]
        miss = [i for i in ids if i not in got]
        if miss:
            msg = "페이지의 이번 회차 카드 가운데 글에서 읽지 못한 것: " + ", ".join(miss)
            res["warnings"].append(msg)
            res["loss_risk"].append(msg)
    print(json.dumps(res, ensure_ascii=False, indent=1))
    if not res["answers"]:
        say("오류: 답을 하나도 읽지 못했습니다 — 「[결정 결과]」로 시작하는 문장이나 serve 가 저장한 JSON 인지 확인하세요", err=True)
        sys.exit(1)


# ───────────────────────── append ─────────────────────────
def replace_region(text, name, inner):
    r = region(text, name)
    return text[:r[0]] + inner + text[r[1]:]


def core_block(text, tag, ident):
    m = re.search(r"<%s id=\"%s\">.*?</%s>" % (tag, ident, tag), text, re.S)
    return m


def round_block(n, cards, amap, reflected, when):
    rows = []
    for c in cards:
        x = amap.get(c["id"])
        ch = x["choice"] if x else "none"
        lab = (x and x.get("choiceLabel")) or choice_label(ch, c["rec"])
        opt = c["opts"].get(int(ch), "") if ch.isdigit() else ""
        memo = x["memo"] if x else ""
        ref = reflected.get(c["id"], "")
        rows.append('<tr><td class="no">%s</td><td>%s</td><td>%s%s</td><td class="memo-src">%s</td><td>%s</td></tr>'
                    % (esc(c["id"]), esc(c["title"]), esc(lab), ('<span class="pick-opt">%s</span>' % esc(opt)) if opt else "",
                       esc(memo) if memo else "–", esc(ref) if ref else "–"))
    return ('<details class="round-done" id="round-%d" data-round="%d">\n'
            '  <summary>%d회차 — 반영됨 <span class="sub">질문 %d건 · %s 답변</span></summary>\n'
            '  <div class="tbl-wrap"><table class="round-tbl"><thead><tr><th>번호</th><th>질문</th><th>고르신 답</th><th>메모</th>'
            '<th>반영한 곳</th></tr></thead>\n  <tbody>%s</tbody></table></div>\n</details>'
            % (n, n, n, len(cards), esc(when), "\n  ".join(rows)))


def load_reflected(path):
    if not path:
        return {}
    d = load_json(path, "반영 기록")
    if isinstance(d, dict) and isinstance(d.get("reflected"), (dict, list)):
        d = d["reflected"]
    out = {}
    if isinstance(d, dict):
        for k, v in d.items():
            if not str(k).startswith("_"):
                out[str(k).strip()] = str(v if v is not None else "").strip()
    elif isinstance(d, list):
        for x in d:
            if isinstance(x, dict) and x.get("id"):
                out[str(x["id"]).strip()] = str(x.get("where") or x.get("reflected") or x.get("text") or "").strip()
    else:
        die("반영 기록은 {\"R1-1\": \"반영한 곳\"} 또는 [{\"id\":…,\"where\":…}] 모양이어야 합니다")
    return out


def cmd_append(a):
    page = os.path.abspath(a.page)
    if not os.path.isfile(page):
        die("페이지가 없습니다: " + a.page)
    page_dir = os.path.dirname(page)
    text = read_text(page)
    for nm in REGIONS:
        if region(text, nm) is None:
            die("영역 표지 fbq:%s 가 없거나 여러 개라 회차를 붙일 수 없습니다(fbq.py new 로 만든 페이지인지 확인)" % nm)
    n = page_round(text)
    km = re.search(r'(<body\b[^>]*?\bdata-fb-key=")([^"]*)(")', text)
    if not km:
        die("body[data-fb-key](저장 키)를 찾지 못했습니다")
    cur_key = html.unescape(km.group(2))
    if not cur_key.endswith("-r%d" % n) and not a.force:
        die("저장 키(%s)와 페이지 회차(%d)가 맞지 않습니다 — 페이지가 손으로 바뀌었는지 확인(무시하려면 --force)" % (cur_key, n))
    prefix = re.sub(r"-r\d+$", "", cur_key)
    cards = card_infos(text)
    if not cards:
        die("이번 회차 카드가 없습니다")
    if not os.path.isfile(a.answers):
        die("답 파일이 없습니다: " + a.answers)
    ans = load_answers(a.answers, [c["id"] for c in cards])
    for w in ans["warnings"]:
        say("경고(답): " + w, err=True)
    probs = []
    if ans["source"] != "answer-json":
        # 글로 받은 답(붙여 넣기 원문 · 그 글을 읽은 read 출력) — 읽으며 답·메모가 빠졌을 수 있으면 사용자 결정이 틀리게 남지 않게 멈춘다
        for w in ans["loss_risk"]:
            probs.append("붙여 넣은 글을 읽으며 답·메모가 빠졌을 수 있습니다 — " + w)
        if len(ans["answers"]) != len(cards):
            probs.append("글에서 읽은 카드 줄 %d개 ≠ 이번 회차 카드 %d개" % (len(ans["answers"]), len(cards)))
        if ans["head_total"] is not None and ans["head_total"] != len(cards):
            probs.append("글 머리의 질문 수(%d) ≠ 이번 회차 카드 %d개 — 다른 회차의 결과일 수 있습니다" % (ans["head_total"], len(cards)))
    if ans["round"] is not None and ans["round"] != n:
        probs.append("답은 %s회차인데 페이지는 %d회차입니다" % (ans["round"], n))
    if ans.get("fbKey") and ans["fbKey"] != cur_key:
        probs.append("답의 저장 키(%s)가 페이지 저장 키(%s)와 다릅니다 — 다른 페이지의 답입니다" % (ans["fbKey"], cur_key))
    ids = [c["id"] for c in cards]
    amap = {}
    for x in ans["answers"]:
        if x["id"] in ids:
            amap[x["id"]] = x
        else:
            say("경고: 답의 %s 는 이번 회차 카드에 없어 넣지 않았습니다" % x["id"], err=True)
    if not amap:
        probs.append("답 가운데 이번 회차 카드(%s)와 번호가 맞는 것이 없습니다" % ", ".join(ids))
    for c in cards:
        x = amap.get(c["id"])
        if x and x["title"] and c["title"] and nfc(x["title"]) != nfc(c["title"]):
            say("경고: %s 제목이 다릅니다 — 페이지 「%s」 / 답 「%s」(페이지 쪽으로 기록)" % (c["id"], c["title"], x["title"]), err=True)
        if x and x["choice"].isdigit() and int(x["choice"]) not in c["opts"]:
            probs.append("%s 답 「%s」가 선택지 범위 밖입니다" % (c["id"], x["choiceLabel"]))
    missing = [i for i in ids if i not in amap]
    if missing:
        say("경고: 답이 없는 카드는 「미결정」으로 기록합니다: " + ", ".join(missing), err=True)
    if probs and not a.force:
        say("답을 붙이지 않았습니다(페이지는 그대로):", err=True)
        for p_ in probs:
            say("  - " + p_, err=True)
        if ans["source"].startswith("read("):
            say("  → 답 파일(%s)이 read 출력입니다. read 출력을 고치지 말고, 붙여 넣기 원문(.txt)을 사용자 글과 대조해 고친 뒤"
                "(메모 둘째 줄부터는 앞에 공백 4칸, 끼워 쓴 말·인사말은 빼기) 그 원문을 --answers 로 다시 붙이세요."
                " 읽은 내용이 맞다고 확인했을 때만 --force" % a.answers, err=True)
        elif ans["source"] != "answer-json":
            say("  → 답 원문(%s)을 사용자 글과 대조해 고친 뒤(메모 둘째 줄부터는 앞에 공백 4칸, 끼워 쓴 말·인사말은 빼기) 다시 붙이세요."
                " 읽은 내용이 맞다고 확인했을 때만 --force" % a.answers, err=True)
        sys.exit(1)
    reflected = load_reflected(a.reflected)
    noref = [i for i in ids if not reflected.get(i)]
    if noref:
        say("경고: 「반영한 곳」이 비어 「–」로 남습니다: " + ", ".join(noref), err=True)

    spec = load_json(a.spec, "다음 질문 데이터")
    errs, warns, qs = validate_spec(spec, n + 1, page_dir, for_append=True)
    rr = region(text, "rounds")
    old_ids = set(ids) | set(re.findall(r'<td class="no">([^<]+)</td>', text[rr[0]:rr[1]]))
    for q in qs:
        if q["id"] in old_ids:
            errs.append("새 질문 id %s 가 이전 회차 번호와 겹칩니다" % q["id"])
    for w in warns:
        say("경고: " + w, err=True)
    if errs:
        say("다음 질문 데이터에 고칠 것이 있습니다 — 페이지를 바꾸지 않았습니다:", err=True)
        for e in errs:
            say("  - " + e, err=True)
        sys.exit(1)
    tm = re.search(r'data-fb-title="([^"]*)"', text)
    if spec.get("title") and tm and nfc(str(spec["title"]).strip()) != nfc(html.unescape(tm.group(1))):
        say("참고: 페이지 제목은 회차가 바뀌어도 그대로 둡니다(질문 데이터의 title 은 쓰지 않음)", err=True)

    when = ""
    if ans.get("received_at"):
        try:
            when = datetime.fromisoformat(str(ans["received_at"])).strftime("%Y-%m-%d %H:%M")
        except ValueError:
            when = str(ans["received_at"])[:16]
    when = when or datetime.now().strftime("%Y-%m-%d %H:%M")

    new = text
    new = replace_region(new, "cards", "\n" + "\n".join(render_card(q, page_dir) for q in qs) + "\n")
    new = replace_region(new, "lead", paras(spec.get("lead")))
    r = region(new, "kicker")
    kick = str(spec.get("kicker") or "").strip()
    new = replace_region(new, "kicker", esc(kick) if kick else re.sub(r"\d+(\s*)회차", lambda m: "%d%s회차" % (n + 1, m.group(1)),
                                                                  new[r[0]:r[1]]))
    if str(spec.get("h1") or "").strip():
        new = replace_region(new, "h1", esc(str(spec["h1"]).strip()))
    r = region(new, "rounds")
    old_rounds = new[r[0]:r[1]].strip()
    block = round_block(n, cards, amap, reflected, when)
    new = replace_region(new, "rounds", block + ("\n" + old_rounds if old_rounds else ""))
    new = re.sub(r'(<body\b[^>]*?\bdata-fb-key=")[^"]*(")', lambda m: m.group(1) + esc(prefix + "-r%d" % (n + 1)) + m.group(2), new, count=1)
    new = re.sub(r'(<span data-fb="round">)\d+(</span>)', lambda m: m.group(1) + str(n + 1) + m.group(2), new)
    # 공통 스타일·스크립트는 틀의 최신본으로 바꿔 끼운다
    tpl = read_text(TEMPLATE)
    for tag, ident in (("style", "fbq-core"), ("script", "fbq-core-js")):
        mt, mp = core_block(tpl, tag, ident), core_block(new, tag, ident)
        if mt and mp:
            new = new[:mp.start()] + mt.group(0) + new[mp.end():]
    E, W, info = static_check(page, new)
    if E and not a.force:
        say("붙인 결과가 점검을 통과하지 못해 저장하지 않았습니다:", err=True)
        for e in E:
            say("  - " + e, err=True)
        sys.exit(1)
    stem = os.path.splitext(os.path.basename(page))[0]
    bak = os.path.join(page_dir, "%s.bak-r%d.html" % (stem, n))
    if os.path.exists(bak):
        bak = os.path.join(page_dir, "%s.bak-r%d-%s.html" % (stem, n, datetime.now().strftime("%Y%m%d%H%M%S")))
    shutil.copy2(page, bak)
    write_atomic(page, new)
    say(page)
    say("%d회차 → 「%d회차 — 반영됨」 표로 접음(질문 %d건, 답 %d건) · %d회차 질문 %d건 · 저장 키 dzfb:%s-r%d · 백업 %s"
        % (n, n, len(cards), len(amap), n + 1, len(qs), prefix, n + 1, os.path.basename(bak)))
    for w in W:
        say("  [경고] " + w, err=True)


# ───────────────────────── 명령 ─────────────────────────
def main(argv=None):
    ap = argparse.ArgumentParser(prog="fbq.py", description="피드백 검토판(dz-feedback-review) 질문 페이지 도구",
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog="질문 데이터(JSON)" + __doc__.split("질문 데이터(JSON)", 1)[1])
    sp = ap.add_subparsers(dest="cmd", metavar="{new,serve,open,read,append,check}")
    sp.required = True

    p = sp.add_parser("new", help="질문 데이터(JSON)로 1회차 페이지 생성")
    p.add_argument("--spec", required=True, help="질문 데이터 JSON")
    p.add_argument("--out", required=True, help="만들 페이지(.html)")
    p.add_argument("--force", action="store_true", help="이미 있는 페이지를 덮어쓴다(이전 회차가 사라진다)")
    p.add_argument("--ignore-check", action="store_true", help="정적 점검에 걸려도 저장한다")
    p.set_defaults(fn=cmd_new)

    p = sp.add_parser("serve", help="수신 창구(127.0.0.1, 일회용 토큰) — 첫 줄에 접속 주소. 답 받으면 종료 0, 시간 초과 2")
    p.add_argument("--page", required=True)
    p.add_argument("--out", required=True, help="답 저장 경로(.json)")
    p.add_argument("--timeout", type=int, default=6 * 3600, help="초(기본 6시간)")
    p.add_argument("--port", type=int, default=0, help="기본 0 = 빈 포트")
    p.set_defaults(fn=cmd_serve)

    p = sp.add_parser("open", help="크롬의 같은 페이지 탭 주소만 교체(없으면 열기)")
    p.add_argument("--url", required=True)
    p.add_argument("--match", required=True, help="페이지 파일명(탭 주소의 마지막 경로와 비교)")
    p.add_argument("--app", default="Google Chrome", help="macOS 앱 이름(기본 Google Chrome)")
    p.add_argument("--dry-run", action="store_true", help="탭을 바꾸지 않고 판단만 출력")
    p.set_defaults(fn=cmd_open)

    p = sp.add_parser("read", help="전송 JSON·결과 문장 → 구조화 JSON")
    g = p.add_mutually_exclusive_group(required=True)
    g.add_argument("--answer", help="serve 가 저장한 답 JSON")
    g.add_argument("--text", help="붙여 넣은 결과 문장 파일('-' = 표준 입력)")
    p.add_argument("--page", help="질문 페이지 — 주면 그 페이지의 이번 회차 카드 번호로 글을 읽는다(사용자가 정한 번호도 정확히, 빠진 카드 경고)")
    p.set_defaults(fn=cmd_read)

    p = sp.add_parser("append", help="현재 회차를 「반영됨」 표로 접고 다음 회차 카드를 붙임")
    p.add_argument("--page", required=True)
    p.add_argument("--spec", required=True, help="다음 회차 질문 데이터 JSON")
    p.add_argument("--answers", required=True, help="이번 회차 답(serve 의 JSON · 결과 문장 파일 · read 출력 — 글을 읽은 read 출력은 결과 문장 파일과 같은 기준으로 검사)")
    p.add_argument("--reflected", help="반영한 곳 JSON {\"R1-1\": \"반영한 곳\"}")
    p.add_argument("--force", action="store_true", help="회차·저장 키 불일치, 글 답의 빠짐 의심(loss_risk·카드 수), 점검 실패를 모두 무시 — 확인한 뒤에만")
    p.set_defaults(fn=cmd_append)

    p = sp.add_parser("check", help="정적 점검(+ --render 렌더 실측)")
    p.add_argument("page")
    p.add_argument("--render", action="store_true", help="playwright 로 글꼴·대비·넘침·콘솔 오류 실측")
    p.add_argument("--shots", help="--render 때 1280·375 스크린샷 저장 폴더")
    p.add_argument("--json", action="store_true", help="결과를 JSON 으로")
    p.set_defaults(fn=cmd_check)

    a = ap.parse_args(argv)
    a.fn(a)


if __name__ == "__main__":
    main()
