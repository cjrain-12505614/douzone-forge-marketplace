---
name: dz-mcp-inventory
description: '"MCP 도구 인벤토리"·"MCP 활성화"·"MCP 도구 확인" 트리거. Forge 활성 MCP 도구 영역 보고 + 추가 도구 활성화 안내. S-04 작업 항목 본문 영역.'
version: 0.1.0
---

# MCP 도구 인벤토리 (dz-mcp-inventory) — S-04 작업 항목

본 스킬은 Forge 활성 MCP 도구 영역 보고 + 추가 도구 활성화 안내. `MCP-도구-배포-범위.md` SSoT §2 매트릭스 영구 참조.

---

## 1. 트리거

description 매칭 (한글 키워드):
- "MCP 도구 인벤토리"
- "MCP 활성화"
- "MCP 도구 확인"

---

## 2. 보고 절차

### 단계 1 — SSoT §2 매트릭스 영구 참조

`MCP-도구-배포-범위.md` §2 본문 직접 인용:
- 12 도구 매트릭스 (Filesystem·Chrome·Workspace·Google Sheets·PowerPoint·Word·Apple Calendar·Figma·Apple Notes·Whisper·Korean Law·kordoc)
- 범주 분기 (✅ 의무·🔵 권한·🟡 선택)

### 단계 2 — 현재 세션 활성 MCP 보고

- 본 세션 활성 MCP 인벤토리 (`mcp__*` 도구 영역)
- 미활성 영역 명시 (✅·🔵·🟡 분기)

### 단계 3 — 추가 활성화 영역 안내

- 사용자 요청 영역 (`/dz-request` 명령어 진입)
- 5 단계 활성화 절차 cross-ref (SSoT §3 인용)

---

## 3. 보고 본문 골격

```
## MCP 도구 인벤토리 보고

### 현재 세션 활성 MCP (N건)
- Filesystem ✅
- Chrome MCP ✅
- ... (분기별)

### 미활성 영역 (사용자 요청 영역)
- 도구명 / 영역 / 활성화 절차

### 추가 활성화 안내
→ `/dz-request` 명령어 진입 (요청 분류: "운영")
```

---

## 4. 관련 자산 cross-ref

- [`MCP-도구-배포-범위.md`](../../../douzone-forge/규칙/프로세스/MCP-도구-배포-범위.md) (S-04 SSoT) — 본 스킬 본문 정의 영역
- [`MCP-Tool-설계-가이드.md`](../../../douzone-forge/규칙/프로세스/MCP-Tool-설계-가이드.md) — 이론·원칙 영역 (영역 분리)
- `_plugin/douzone-forge/skills/dz-user-request/SKILL.md` — 추가 활성화 요청 진입

---

End of dz-mcp-inventory
