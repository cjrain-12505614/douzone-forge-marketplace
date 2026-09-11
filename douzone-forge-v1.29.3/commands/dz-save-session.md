---
name: dz-save-session
description: "세션 중간 체크포인트 저장"
---

# /save-session

현재 세션 진행 상황을 체크포인트로 저장한다.

1. `_개인/sessions/{대상}/_current.md` 업데이트
2. 완료된 작업 체크, 남은 작업 갱신
3. 현재 시점·재개 방법 명시
4. **GitLab 동기화** — 중간 정리분을 중앙 저장소(GitLab, 사내 원격 저장소)에 반영하고 결과를 보고한다:
   ```bash
   SYNC="$(python3 -c "
import json,os,glob
p=os.path.expanduser('~/.claude/plugins/installed_plugins.json')
try:
    d=json.load(open(p,encoding='utf-8')).get('plugins',{})
    k=next((x for x in d if x.startswith('douzone-forge@')),None)
    if k:
        c=os.path.join(d[k][0]['installPath'],'hooks','dz-gitlab-sync.sh')
        if os.path.exists(c): print(c); raise SystemExit
except Exception: pass
g=glob.glob(os.path.expanduser('~/.claude/plugins/cache/*/douzone-forge/*/hooks/dz-gitlab-sync.sh'))
g.sort(key=lambda s:[int(n) if n.isdigit() else n for n in s.split('/douzone-forge/')[1].split('/')[0].replace('-','.').split('.')])
print(g[-1] if g else '')
")"; [ -n "$SYNC" ] && bash "$SYNC" sync || echo "⛔ 동기화 엔진을 찾지 못했습니다 — 플러그인 설치 상태를 확인하세요"
   ```
   충돌 시 자동 병합하지 않고 `backup/sync-시각` 브랜치에 보관 + 관리자 문의 안내 (데이터 보존). 정책 SSoT: `규칙/프로세스/Forge-GitLab-운영가이드.md`(forge) §6

**사용 예시:**
- `/dz-save-session`
