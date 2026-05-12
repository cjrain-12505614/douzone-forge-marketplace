---
name: a10-plugin-save
description: 플러그인을 빌드·배포하고 CoWork "플러그인 저장" UI를 띄운다. "플러그인 저장해줘", "플러그인 열어줘", "플러그인 띄워줘", "플러그인 업데이트해줘" 같은 요청에 사용.
---

# 플러그인 빌드 & 저장 UI

## 대상 플러그인 결정

`$ARGUMENTS` 가 있으면 해당 플러그인명 사용. 없으면 현재 워크스페이스 기준으로 판단:

| 워크스페이스 | 플러그인 | 소스 경로 |
|---|---|---|
| `_plugin/` (기본) | amaranth10-claude-forge | `~/Workspace/_plugin/amaranth10-claude-forge` |
| `Peekly/` | solo-forge | `~/Workspace/Peekly` (solo-forge 경로) |
| `SCU/` | study-assistant | iCloud SCU 경로 |
| `AI-Hub/` | knowledge-forge | `~/Workspace/AI-Hub` |

## Step 1. 빌드 & 배포

```bash
cd <소스 경로> && bash build.sh --deploy
```

빌드 성공 시 `dist/<plugin-name>.plugin` 생성됨.

## Step 2. 플러그인 파일 제시 (필수)

**반드시** `present_files` 도구로 `.plugin` 파일을 제시한다.
절대 이 단계를 생략하거나 파일 경로만 텍스트로 출력하는 것으로 대체하지 말 것.

```
present_files(["<소스 경로>/dist/<plugin-name>.plugin"])
```

CoWork가 `.plugin` 파일을 감지해 **"플러그인 저장" 버튼**을 자동으로 붙여준다.

## Step 3. 안내

저장 버튼 클릭 후:
- CoWork → 플러그인 → 해당 플러그인 → "업데이트" 버튼 클릭 (아직 활성화 안 됐을 경우)
- 또는 저장 버튼만으로 즉시 반영될 수 있음

## 주의

- `present_files` 없이 파일 경로만 링크로 제공하면 CoWork가 raw 바이너리로 열어버림 → 저장 UI 안 뜸
- build.sh 실패 시 에러 내용 그대로 보고하고 중단
