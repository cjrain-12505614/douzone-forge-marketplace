---
name: dz-plugin-save
description: 플러그인을 빌드하고 git 마켓플레이스 레포에 릴리스(push)한다. 로컬/Claude 반영은 사용자가 마켓플레이스 기준으로 수동. "플러그인 저장해줘", "플러그인 배포해줘", "플러그인 릴리스", "플러그인 업데이트해줘" 같은 요청에 사용.
---

# 플러그인 빌드 & git 릴리스

> ⛔ **자가 배포 금지 규칙 (2026-07-12 PM 확정, 전 플러그인 공통)**: 플러그인 반영은 **git push까지만**. `.plugin` 파일을 CoWork "플러그인 저장" UI로 로컬에 직접 설치시키는 **자가 배포는 금지** — 마켓플레이스 기반 업데이트와 충돌해 문제가 반복됨(PM 실증). 로컬/Claude 반영은 **사용자가 마켓플레이스 기준으로 수동** 진행한다. Claude는 git push에서 멈춘다.

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
cd <소스 경로> && bash build.sh --deploy
```

`build.sh --deploy` = 마켓플레이스 레포에 **버전 폴더 전개 + marketplace.json 갱신 + commit + push** (v1.2.1부터 로컬 자동 격상 블록 제거됨 — git push 단일 경로). **로컬 설치는 건드리지 않는다.**

## Step 2. 사용자 수동 업데이트 안내 (⛔ present_files 금지)

빌드 로그가 마지막에 출력하는 **수동 업데이트 명령을 사용자에게 그대로 전달**한다:

```
claude plugin uninstall <plugin>@douzone-forge-marketplace \
  && claude plugin marketplace update douzone-forge-marketplace \
  && claude plugin install <plugin>@douzone-forge-marketplace
```

(또는 `claude plugin update <plugin>@douzone-forge-marketplace`) + CoWork/Claude 재시작.

⛔ **`present_files` 로 `.plugin` 저장 버튼을 띄우지 않는다.** 그 로컬 저장 경로가 마켓 업데이트와 충돌하는 금지된 자가 배포다. 로컬 반영은 위 명령으로 **사용자가 직접** 한다.

## 주의

- **Claude가 하는 일은 git push까지.** 로컬/Claude 설치 반영은 항상 사용자 몫이다.
- `build.sh` 실패 시 에러 내용 그대로 보고하고 중단 (push 되지 않았음을 명시).
- `--deploy` 없이 `build.sh` 만 돌리면 `dist/<plugin>.plugin` 로컬 빌드만 되고 push 안 됨 — 릴리스하려면 반드시 `--deploy`.
