# Douzone Forge Marketplace

`douzone-forge` 플러그인 배포용 Claude Code 마켓플레이스.

## 포함 플러그인

| 플러그인 | 최신 버전 | 설명 |
|---|---|---|
| `douzone-forge` | `.claude-plugin/marketplace.json` 의 `version` | Amaranth 10 통합 업무 프레임워크 (판 번호는 여기 적지 않는다 — 표기 표류 방지) |

## 설치 방법

### 1. 마켓플레이스 등록

```bash
claude plugin marketplace add cjrain-12505614/douzone-forge-marketplace
```

### 2. 플러그인 설치

```bash
claude plugin install douzone-forge@douzone-forge-marketplace
```

(옛 이름 `amaranth10-forge-marketplace` 는 2026-05-13 에 `douzone-forge-marketplace` 로 바뀌었다.)

CoWork 데스크탑 앱을 재시작하면 자동 반영됩니다.

## 업데이트 방법

Claude 대화창에서 `/dz-plugin-update` — 마켓을 바로 새로 받아 최신 판으로 갱신하고 전후 판을 알려 줍니다(앱 플러그인 화면의 「업데이트」 버튼은 그 PC가 마켓을 다시 확인해야 켜집니다).

명령줄로는:

```bash
claude plugin marketplace update douzone-forge-marketplace
claude plugin update douzone-forge@douzone-forge-marketplace
```

데스크톱 앱은 열린 세션에 새 판을 바로 다시 불러옵니다. 명령줄 터미널 세션은 새로 열거나 `/reload-plugins`.

## 소스 레포

- 플러그인 소스: [douzone-forge](https://github.com/cjrain-12505614/douzone-forge)
