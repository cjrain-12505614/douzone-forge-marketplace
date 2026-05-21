# Amaranth10 Forge Marketplace

`douzone-forge` 플러그인 배포용 Claude Code 마켓플레이스.

## 포함 플러그인

| 플러그인 | 최신 버전 | 설명 |
|---|---|---|
| `douzone-forge` | v0.6.0 | Amaranth 10 통합 업무 프레임워크 |

## 설치 방법

### 1. 마켓플레이스 등록

`~/.claude/settings.json` 의 `extraKnownMarketplaces` 에 추가:

```json
"amaranth10-forge-marketplace": {
  "source": {
    "source": "github",
    "repo": "cjrain-12505614/amaranth10-forge-marketplace"
  }
}
```

또는 CLI:

```bash
claude plugin marketplace add amaranth10-forge-marketplace --github cjrain-12505614/amaranth10-forge-marketplace
```

### 2. 플러그인 설치

```bash
claude plugin install douzone-forge@amaranth10-forge-marketplace
```

CoWork 데스크탑 앱을 재시작하면 자동 반영됩니다.

## 업데이트 방법

```bash
claude plugin marketplace update amaranth10-forge-marketplace
claude plugin install douzone-forge@amaranth10-forge-marketplace
```

## 소스 레포

- 플러그인 소스: [douzone-forge](https://github.com/cjrain-12505614/douzone-forge)
