#!/usr/bin/env bash
# Trigger: Stop
# Tools: — (응답 종료 이벤트 — 도구 매처 없음)
# Purpose: 자비스가 답변을 끝내려는 순간, 그 답변에 「고르라는 질문」이 채팅으로 늘어놓여 있으면
#          그때만 되돌려 보내 질문 페이지(dz-feedback-review)로 다시 묻게 한다 — 「필요한 시점에」 발동
# SSoT: skills/dz-feedback-review/SKILL.md · 되돌려 보낼 때의 안내 문구 정본 = 워크스페이스 규칙/프로세스/질문페이지-환기.md
#
# 배경(2026-10-01 — 차민수 수석 결정, 질문 페이지 4회차 R4-1 ③):
#   「필요한 사람이 아니라 필요한 시점에 불러 쓰는 형태가 되어야 해」. 매 입력마다 안내를 붙이는 방식(②)은
#   결정과 무관한 입력에도 매번 붙으므로, 결정할 거리가 실제로 생긴 답변에서만 동작하게 한다.
#
# 판정(글 모양 기준 — 완벽하지 않음):
#   이번 턴 답변 글(코드 블록·인라인 코드 제외)에
#     (선택을 뜻하는 강한 말(고르시면·골라 주·선택해 주·어느 쪽·중 하나 …)이 있고 줄 맨 앞 선택지 표시(목록의 ①②③…·1. · 표 첫 칸)가 2개 이상)
#       — 한국어 요청은 물음표 없이 끝나는 경우가 많아 이 경우 물음표를 요구하지 않는다
#     이거나 (물음표 질문 2개 이상 + 요청어(강한 말 + 정해 주·결정해 주·승인해 주·여쭙 등) 2번 이상)
#   이면 되돌려 보낸다.
#   건너뜀: 이미 질문 페이지를 띄운 답변(「답변 완료」·「질문 페이지」 안내 포함) · 같은 응답에서 이미 한 번
#          되돌려 보낸 경우(stop_hook_active) · 파이썬 없음 · 오류 — 모두 통과(exit 0, 아무것도 막지 않음).
#
# 안전: 읽기 전용 · 항상 exit 0 · 되돌려 보낼 때만 {"decision":"block","reason":…} 를 출력한다.
set -uo pipefail

command -v python3 >/dev/null 2>&1 || exit 0
DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
SYNCED="$DIR/규칙/프로세스/질문페이지-환기.md"

INPUT="$(cat 2>/dev/null || true)"
[ -z "$INPUT" ] && exit 0

FRM_SYNCED="$SYNCED" FRM_INPUT="$INPUT" python3 - <<'PYEOF' 2>/dev/null || true
import json, os, re, sys

def main():
    try:
        data = json.loads(os.environ.get("FRM_INPUT", "") or "{}")
    except Exception:
        return
    if data.get("stop_hook_active"):
        return
    tp = data.get("transcript_path") or ""
    if not tp or not os.path.isfile(tp):
        return
    rows = []
    with open(tp, encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except Exception:
                continue
    # 이번 턴 = 마지막 「진짜 사용자 입력」(도구 결과가 아닌 user) 뒤의 assistant 글
    def is_real_user(r):
        if r.get("type") != "user":
            return False
        c = (r.get("message") or {}).get("content")
        if isinstance(c, str):
            return bool(c.strip())
        if isinstance(c, list):
            return any(isinstance(b, dict) and b.get("type") == "text" for b in c) and not any(
                isinstance(b, dict) and b.get("type") == "tool_result" for b in c)
        return False
    last = -1
    for i, r in enumerate(rows):
        if is_real_user(r):
            last = i
    texts = []
    for r in rows[last + 1:]:
        if r.get("type") != "assistant":
            continue
        c = (r.get("message") or {}).get("content")
        if isinstance(c, list):
            for b in c:
                if isinstance(b, dict) and b.get("type") == "text" and b.get("text"):
                    texts.append(b["text"])
        elif isinstance(c, str):
            texts.append(c)
    if not texts:
        return
    # 최종 답변 = 이번 턴 마지막 글 묶음(도구 호출 사이의 중간 안내 문장은 빼고 마지막 글만 본다)
    reply = texts[-1]
    body = re.sub(r"```.*?```", " ", reply, flags=re.S)
    body = re.sub(r"`[^`\n]*`", " ", body)
    if re.search(r"답변 완료|질문 페이지(를|로)? ?(띄|열|만들|갱신|바꿨|붙였)", body):
        return
    # 선택을 뜻하는 강한 말 / 일반 요청어 — 일반 요청어(「정해 주시면」 등)는 선택을 묻지 않을 때도 흔해 따로 센다
    strong = re.findall(r"(고르시면|고르시겠|골라 ?주|선택해 ?주|선택하시|어느 쪽|어떤 (?:것|걸)으로|어느 (?:안|방식|것)|중 (?:하나|어느))", body)
    weak = re.findall(r"(정해 ?주|결정해 ?주|승인해 ?주|여쭙|어떻게 할까)", body)
    q = len(re.findall(r"\?", body))
    # 선택지 표시는 줄 맨 앞(목록의 ①·1. · 표 첫 칸)만 센다 — 문장 중간의 ①② 는 항목을 짚는 말일 때가 많다
    opts = len(re.findall(r"(?m)^\s*(?:[-*]\s*|\|\s*)?(?:\*\*)?(?:[1-9][.)]|[①②③④⑤⑥⑦⑧⑨⑩])\s*\S", body))
    trig = (bool(strong) and opts >= 2) or (q >= 2 and len(strong) + len(weak) >= 2)
    if not trig:
        return
    guide = ""
    sp = os.environ.get("FRM_SYNCED", "")
    if sp and os.path.isfile(sp):
        try:
            guide = open(sp, encoding="utf-8").read().strip()
        except Exception:
            guide = ""
    if not guide:
        guide = ("[질문 페이지 환기] 결정받을 질문이 2개 이상이거나 선택지마다 결과를 비교해야 하면 채팅에 늘어놓지 말고 "
                 "dz-feedback-review 로 질문 페이지를 띄울 것 — 카드는 모두 펼치고 선택지는 내용으로, "
                 "답은 「답변 완료」 또는 붙여 넣기로 받는다.")
    reason = (f"[질문 페이지 알림] 방금 답변이 채팅으로 선택을 묻고 있습니다(줄 맨 앞 선택지 {opts}개 · 물음표 질문 {q}개). "
              "결정받을 질문이 2개 이상이거나 선택지마다 결과를 비교해야 하면 dz-feedback-review 로 질문 페이지를 띄워 다시 물으세요. "
              "예·아니오 확인 하나뿐이면 이 알림을 무시하고 그대로 끝내도 됩니다.\n\n" + guide)
    print(json.dumps({"decision": "block", "reason": reason}, ensure_ascii=False))

try:
    main()
except Exception:
    pass
PYEOF
exit 0
