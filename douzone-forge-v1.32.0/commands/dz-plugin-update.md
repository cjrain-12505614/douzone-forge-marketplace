---
name: dz-plugin-update
description: 이 PC에 설치된 douzone-forge 플러그인을 마켓플레이스 최신 판으로 바로 갱신한다 — 앱의 「업데이트」 버튼이 켜지기를 기다리지 않는다. 갱신 전후 판과 그 사이에 바뀐 내용(변경 이력 제목)을 보고한다. "플러그인 업데이트해줘", "플러그인 최신으로", "새 판 받아줘", "플러그인 갱신해줘" 같은 갱신 요청에 사용(「업데이트 버튼이 안 켜져」 같은 하소연만 있으면 먼저 지금 받을지 한 줄로 묻는다). 플러그인을 고쳐 마켓플레이스에 올리는 관리자용 dz-plugin-save 와 다른 명령이다.
---

# 플러그인 바로 갱신 (이 PC)

> **용어 풀이**: 마켓플레이스(플러그인을 내려받는 저장소 — douzone-forge 는 `douzone-forge-marketplace`) · 마켓 사본(이 PC에 내려받아 둔 마켓플레이스 복사본 — 이것이 새로 받아져야 새 판이 보인다) · 설치 범위(scope — `user` 는 이 PC 사용자 전체, `project`·`local` 은 특정 폴더에만)

## 왜 이 명령이 있나

관리자가 새 판을 배포해도 각 PC의 설치본은 그대로다. 앱의 플러그인 화면 「업데이트」 버튼은 **그 PC가 마켓을 다시 확인한 뒤에야** 켜지는데, 앱에서 바로 확인하는 기능이 없어 언제 켜질지 알 수 없다(2026-10-01 차민수 수석 확인). 자동 갱신 설정(`autoUpdate`, `/dz-personal-init` §8.6)도 Claude Code 가 시작할 때 도는 것이라 배포 직후에는 반영되지 않는다. 이 명령은 그 확인과 갱신을 **지금** 한다.

## 원칙

- 이 명령을 사용자가 부른 것(또는 「플러그인 업데이트해줘」처럼 갱신을 직접 요청한 것)이 **이 PC 로컬 갱신의 명시 요청**이다. 사용자가 갱신을 요청하지 않았는데 자비스가 필요하다고 판단했으면 실행하지 말고 「지금 새 판을 받을까요?」 한 줄로 먼저 묻는다 — 갱신하면 앱이 열린 세션 전부를 다시 불러온다. 갱신 대상은 **douzone-forge 하나**와 **그 마켓 하나**뿐 — 다른 플러그인·다른 마켓은 받지도 갱신하지도 않는다.
- 실행 파일은 **지금 이 세션을 돌리는 Claude Code**(`CLAUDE_CODE_EXECPATH`)를 쓴다. 앱만 쓰는 PC에는 명령줄 `claude` 가 없을 수 있고, 있어도 판이 다를 수 있다. 환경변수가 없거나 그 파일이 없으면(앱이 Claude Code 를 새 판으로 바꾸며 옛 판 폴더가 지워진 경우) PATH 의 `claude` 로 대신한다.
- ⛔ `-y` 를 붙이지 않는다. 갱신 명령이 「마켓이 선언한 명령을 실행해도 되는지」 확인을 요구하면 그대로 멈추고 사용자에게 그 내용을 보인다(douzone-forge 마켓은 그런 명령을 선언하지 않는다 — 요구가 나오면 마켓이 바뀌었다는 신호다).
- ⛔ `claude plugin install` · `uninstall` 을 하지 않는다. 지우고 다시 까는 것은 실패하면 플러그인이 빠진 채(동기화·강제원칙 훅이 멈춘 채) 남는다. 명령줄 설치 기록에 없을 때 `install` 을 하면 **두 번째 설치본**이 생겨 훅이 두 번씩 돈다.
- ⛔ `~/.claude/plugins/**` 파일을 직접 고치지 않는다.

## 실행

아래 블록을 그대로 실행한다(한 번에 끝난다 — 이미 최신이면 아무것도 바꾸지 않는다). `python3` 명령이 없다는 오류가 나면(Windows 등) 첫 줄의 `python3` 를 `python` 으로 바꿔 다시 실행한다.

```bash
python3 - <<'PYEOF'
import json, os, re, shutil, subprocess, sys, time
NAME = "douzone-forge"
PREF_MK = "douzone-forge-marketplace"
# 후보를 차례로 — 세션 실행 파일이 앱 자동 갱신으로 지워졌으면 PATH 의 claude 로 넘어간다
CANDS = [os.environ.get("CLAUDE_CODE_EXECPATH") or "", shutil.which("claude") or ""]
C = next((c for c in CANDS if c and os.path.exists(c)), "")
if not C:
    print("결과=실행파일없음 — Claude Code 실행 파일을 찾지 못했습니다(후보: %s)." % (", ".join(c for c in CANDS if c) or "없음")); sys.exit(2)

def run(args, timeout=300, split=False):
    # 출력은 UTF-8 로 읽는다(한국어 Windows 기본 cp949 로 읽으면 글자가 깨진다)
    try:
        r = subprocess.run([C] + args, capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=timeout)
    except subprocess.TimeoutExpired:
        return (124, "", "시간 초과(%d초)" % timeout) if split else (124, "시간 초과(%d초)" % timeout)
    if split:
        return r.returncode, r.stdout or "", r.stderr or ""
    return r.returncode, ((r.stdout or "") + (r.stderr or "")).strip()

def ver(v):
    m = re.match(r"^(\d+)\.(\d+)\.(\d+)$", str(v or ""))
    return tuple(int(x) for x in m.groups()) if m else None

def find_entries():
    # JSON 은 표준 출력에서만 읽는다 — 경고가 표준 오류로 섞여도 깨지지 않게
    rc, so, se = run(["plugin", "list", "--json"], timeout=60, split=True)
    if rc != 0:
        return None, (so + se).strip()
    try:
        items, _ = json.JSONDecoder().raw_decode(so[so.index("["):])
    except Exception as ex:
        return None, "목록 JSON 을 읽지 못함: %s · 출력 앞부분: %s" % (ex, (so + se)[:200])
    return [p for p in items if str(p.get("id", "")).split("@")[0] == NAME], ""

print("실행 파일:", C)
ents, err = find_entries()
if ents is None:
    print("결과=목록실패 —", err[-600:]); sys.exit(6)
if not ents:
    print("결과=명령줄설치없음 — 이 PC의 명령줄 설치 기록(~/.claude/plugins)에 douzone-forge 가 없습니다. 앱(CoWork 모드)에서 설치한 환경이면 명령줄로는 갱신할 수 없습니다."); sys.exit(3)
if len(ents) > 1:
    print("주의: douzone-forge 설치가 %d개입니다 —" % len(ents), ", ".join("%s(%s·%s)" % (e["id"], e.get("version"), e.get("scope")) for e in ents))
e = next((x for x in ents if x["id"].endswith("@" + PREF_MK)), ents[0])
pid, mk, scope, before = e["id"], e["id"].split("@", 1)[1], e.get("scope") or "user", e.get("version")
print("대상: %s · 설치 범위 %s · 활성 %s · 지금 판 %s" % (pid, scope, e.get("enabled"), before))

rc, out = run(["plugin", "marketplace", "update", mk])
if rc != 0:
    print("결과=마켓받기실패 —", out[-600:]); sys.exit(4)

t0 = time.strftime("%Y-%m-%d %H:%M:%S")
args = ["plugin", "update", pid] + (["--scope", scope] if scope != "user" else [])
rc, out = run(args)
print(out[-400:])
if rc != 0:
    print("결과=갱신실패 (종료 %d)" % rc); sys.exit(5)

# 판 변화는 갱신 명령 출력이 1순위(「updated from A to B」 · 「already at the latest version (X)」), 목록 다시 읽기는 보조
m_up = re.search(r"updated from (\S+) to (\S+)", out)
m_lt = re.search(r"already at the latest version \(([^)]+)\)", out)
ents2, _ = find_entries()
e2 = next((x for x in (ents2 or []) if x["id"] == pid), {})
if m_up:
    before, after = m_up.group(1).rstrip("."), m_up.group(2).rstrip(".")
else:
    after = (m_lt.group(1) if m_lt else None) or e2.get("version") or before
updated = bool(m_up) or (ver(after) and ver(before) and ver(after) > ver(before))
if updated:
    print("결과=갱신됨 %s → %s" % (before, after))
    cl = os.path.join(e2.get("installPath", ""), "CHANGELOG.md")
    heads = []
    if os.path.isfile(cl):
        for line in open(cl, encoding="utf-8", errors="replace"):
            m = re.match(r"^## v(\d+\.\d+\.\d+)\b(.*)", line.rstrip())
            if m and ver(m.group(1)) and ver(before) and ver(after) and ver(before) < ver(m.group(1)) <= ver(after):
                heads.append("v%s%s" % (m.group(1), m.group(2)))
    print("바뀐 판 %d개:" % len(heads))
    for h in heads[:10]:
        print("  -", h[:160])
    if len(heads) > 10:
        print("  … 외 %d개(변경 이력 %s)" % (len(heads) - 10, cl))
    log = os.path.expanduser("~/Library/Logs/Claude/main.log")
    if os.path.isfile(log):
        time.sleep(5)
        hits = [l.rstrip() for l in open(log, encoding="utf-8", errors="replace") if "reload_plugins" in l and l[:19] >= t0]
        print("앱 다시 불러오기 기록 %d줄 (이 시각 이후)" % len(hits))
        for l in hits[:3]:
            print("  ", l[:170])
else:
    print("결과=이미최신 %s" % after)
PYEOF
```

## 결과별로 할 일

| 출력 `결과=` | 뜻 | 사용자에게 |
|---|---|---|
| `갱신됨 A → B` | 새 판을 받았다 | 판 변화와 「바뀐 판」 제목을 그대로 보인다. **적용 시점**: 데스크톱 앱은 열린 세션에 새 판을 스스로 다시 불러온다 — 쉬는 세션은 바로, 이 대화처럼 돌고 있는 세션은 **이번 답변이 끝난 뒤**(2026-09-11 세 기기 실측). 명령줄 「Restart to apply」 문구는 명령줄 터미널 세션 기준이며, 터미널에서 쓰는 사람은 새 세션을 열거나 `/reload-plugins` 한다. 맥이면 「앱 다시 불러오기 기록」 줄 수로 반영을 확인할 수 있다(0줄이면 몇 초 뒤 앱 기록 `~/Library/Logs/Claude/main.log` 끝의 `reload_plugins` 줄을 다시 본다) |
| `이미최신 X` | 마켓의 최신 판이 이미 깔려 있다 | 「이미 최신(X)」. 배포됐다고 들었는데 판이 그대로면 아직 마켓에 올라가지 않은 것이다 — 관리자(차민수 수석)에게 판 번호를 확인한다 |
| `명령줄설치없음` (종료 3) | 앱(CoWork 모드)에서 설치한 환경 — 설치본이 앱 폴더에 따로 있다 | 앱의 플러그인 화면에서 douzone-forge 「업데이트」를 누르도록 안내한다(앱이 마켓 정보를 다시 받아야 켜지므로 시점은 앱에 달려 있다). ⛔ 여기서 `claude plugin install` 로 대신 깔지 않는다 — 설치본이 둘이 된다 |
| `마켓받기실패` (종료 4) | 마켓(GitHub)을 받지 못했다 | 오류 끝부분을 그대로 보인다. 네트워크·GitHub 접속(사내망 차단 등)을 확인하고 잠시 뒤 다시 부른다 |
| `갱신실패` (종료 5) | 갱신 명령이 실패했다 | 오류 원문을 보인다. 「not installed」류면 명령줄 설치 기록이 어긋난 것이다 — 지우고 다시 깔기는 위험하므로 **자동으로 하지 않고** 관리자에게 원문을 전달한다. `-y` 확인 요구가 나오면 그 내용을 보이고 멈춘다 |
| `실행파일없음` (종료 2) · `목록실패` (종료 6) | 명령을 돌릴 수 없었다 | 원문을 보이고, 앱 플러그인 화면의 「업데이트」 버튼 경로를 안내한다 |
| `주의: 설치가 N개` | 같은 플러그인이 여러 마켓·범위로 깔려 있다 | `douzone-forge-marketplace` 쪽만 갱신했음을 알리고, 나머지 정리는 관리자와 상의하도록 안내한다(지우지 않는다) |

보고는 세 줄 안팎으로 한다 — ① 판 변화(또는 이미 최신) ② 바뀐 판 제목 ③ 적용 시점. 실패면 ① 무엇이 실패했는지 ② 오류 원문 ③ 다음에 할 일.

## 하지 않는 것

- 플러그인을 고치거나 마켓플레이스에 올리는 일 — 관리자 명령 `dz-plugin-save` 의 몫이다.
- 다른 플러그인(solo-forge 등)·다른 마켓 갱신 — 사용자가 따로 부탁하면 그때 그 하나만 한다.
- 워크스페이스(douzone-forge 저장소) 받기 — 자동 동기화 훅의 몫이다.
