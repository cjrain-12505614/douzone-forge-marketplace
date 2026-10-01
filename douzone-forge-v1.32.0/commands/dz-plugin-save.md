---
name: dz-plugin-save
description: (관리자용) 플러그인을 빌드하고 git 마켓플레이스 레포에 릴리스(push)한다. 각 PC 반영은 그 PC 사용자가 /dz-plugin-update 로 받는다. "플러그인 저장해줘", "플러그인 배포해줘", "플러그인 릴리스", "새 판 올려줘" 같은 요청에 사용. 이 PC에 최신 판을 받는 「플러그인 업데이트해줘」는 /dz-plugin-update.
---

# 플러그인 빌드 & git 릴리스

> ⛔ **자가 배포 금지 규칙 (2026-07-12 PM 확정, 전 플러그인 공통)**: 플러그인 반영은 **git push까지만**. `.plugin` 파일을 CoWork "플러그인 저장" UI로 로컬에 직접 설치시키는 **자가 배포는 금지** — 마켓플레이스 기반 업데이트와 충돌해 문제가 반복됨(PM 실증). 각 PC 반영은 **그 PC 사용자가 마켓플레이스 기준으로** 받는다(`/dz-plugin-update` — 사용자가 부를 때만 그 PC를 갱신). 릴리스 흐름의 Claude는 git push에서 멈춘다.

## 대상 플러그인 결정

`$ARGUMENTS` 가 있으면 해당 플러그인명 사용. 없으면 현재 워크스페이스 기준으로 판단:

| 워크스페이스 | 플러그인 | 소스 경로 |
|---|---|---|
| `_plugin/` (기본) | douzone-forge | `<플러그인 루트>` (예: `~/Workspace/_plugin/douzone-forge`) |
| `Peekly/` | solo-forge | `<solo-forge 루트>` (예: `~/Workspace/Peekly`) |
| `SCU/` | study-forge | iCloud SCU 경로 |
| `AI-Hub/` | knowledge-forge | `<knowledge-forge 루트>` (예: `~/Workspace/AI-Hub`) |

## Step 1. 빌드 & git 마켓플레이스 배포 (push)

```bash
cd ~/Workspace/_plugin/douzone-forge && bash build.sh --deploy   # 소스 클론 위치로 바꾼다
```

`build.sh --deploy` = 마켓플레이스 레포에 **버전 폴더 전개 + marketplace.json 갱신 + commit + push** (v1.2.1부터 로컬 자동 격상 블록 제거됨 — git push 단일 경로). **로컬 설치는 건드리지 않는다.**

## Step 2. 각 PC 갱신 안내 (⛔ present_files 금지)

빌드 로그 끝의 안내를 사용자에게 그대로 전달한다. 요지:

- 앱 플러그인 화면의 「업데이트」 버튼은 **그 PC가 마켓을 다시 확인한 뒤에야** 켜진다. 앱에 「바로 확인」 기능이 없어 언제 켜질지 알 수 없다(2026-10-01 차민수 수석 확인).
- 바로 받으려면 각 PC의 Claude 대화창에서 **`/dz-plugin-update`** — 마켓 받기와 갱신을 한 번에 하고, 전후 판·바뀐 내용을 보고한다.
- 명령줄로는 `claude plugin marketplace update douzone-forge-marketplace && claude plugin update douzone-forge@douzone-forge-marketplace`.
- 데스크톱 앱은 열린 세션에 새 판을 바로 다시 불러온다(쉬는 세션은 즉시, 도는 세션은 그 턴 뒤 — 재시작 불필요, 워크스페이스 `참고자료/리포트/2026-09-11-플러그인-갱신-적용시점-실측.md`). 명령줄 터미널 세션은 새로 열거나 `/reload-plugins`.
- 지웠다 다시 깔기(`uninstall` → `install`)는 기본 안내에서 뺐다 — 실패하면 플러그인이 빠진 채(동기화·강제원칙 훅이 멈춘 채) 남는다.

⛔ **`present_files` 로 `.plugin` 저장 버튼을 띄우지 않는다.** 그 로컬 저장 경로가 마켓 업데이트와 충돌하는 금지된 자가 배포다. 각 PC 반영은 위 경로로 **그 PC 사용자가** 한다.

## 주의

- **Claude가 하는 일은 git push까지.** 각 PC 설치 반영은 그 PC 사용자 몫이다(`/dz-plugin-update` 를 사용자가 부르면 그 PC만 갱신).
- `build.sh` 실패 시 에러 내용 그대로 보고하고 중단 (push 되지 않았음을 명시).
- `--deploy` 없이 `build.sh` 만 돌리면 `dist/<plugin>.plugin` 로컬 빌드만 되고 push 안 됨 — 릴리스하려면 반드시 `--deploy`.
