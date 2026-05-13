# 예시 — 무인자 (default 프리셋) 실행

## 입력

```
/a10-jira
```

## 내부 동작

```bash
COLLECTOR_DIR="${JIRA_COLLECTOR_DIR:-$HOME/Workspace/amaranth10-workspace/_workspace/jira}"
cd "$COLLECTOR_DIR" && ./scripts/fetch-issues.sh
cat "$COLLECTOR_DIR/output/$(date +%F)/INDEX.md"
```

## 기대 출력

```markdown
## JIRA 수집 결과 — 2026-04-18

- **프리셋**: default
- **JQL**: `created >= -7d AND statusCategory != Done`
- **담당자 필터**: kykim, shshkim, doban7, dus3062, seonmyeong7047 (자동 주입)
- **서버 총 건수 / 수집 건수**: 47 / 47
- **복수 모듈 이슈**: 2건
- **미매핑 이슈**: 3건

### 모듈별 분포
| 모듈 | BE | FE | 건수 | 보기 |
|------|----|----|------|------|
| 업무관리 | 12 | 8 | 20 | `/a10-jira --read 2026-04-18/업무관리` |
| 게시판   | 5  | 4 | 9  | `/a10-jira --read 2026-04-18/게시판` |
| 법무관리 | 6  | 3 | 9  | `/a10-jira --read 2026-04-18/법무관리` |
| CRM      | 2  | 1 | 3  | `/a10-jira --read 2026-04-18/CRM` |
| 연락처   | 1  | 2 | 3  | `/a10-jira --read 2026-04-18/연락처` |
| _unmapped| 1  | 2 | 3  | `/a10-jira --read 2026-04-18/_unmapped` |

🟢 수집 완료. 복수 모듈 이슈 2건은 `_multi` 폴더에서 확인 가능.
```

## 오류 사례

- **수집기 미설치**: SKILL.md §설치 안내 메시지 출력
- **CAPTCHA 차단**: `🔴 JIRA 인증 실패 — CAPTCHA 해제 필요. 운영 가이드 §3 참조.`
- **미매핑 비율 50% 초과**:
  ```
  🟡 미매핑 이슈가 전체의 {N}% 입니다. JIRA 관리자가 '모듈' 필드를 재생성했을 수 있습니다.
     ./scripts/fetch-issues.sh --find-field 모듈 재실행 권장.
  ```
