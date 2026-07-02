# 신규 모듈 컨텍스트 초기화 가이드

## 1단계: 디렉토리 생성

```bash
mkdir -p {모듈명}/context
```

## 2단계: module-overview.md 작성

아래 템플릿을 복사해 채운다.

```markdown
# {모듈명} 모듈 개요

## 목적
{모듈이 해결하는 문제와 주요 사용자}

## 라이선스 구분
- {라이선스 A}: {대상 사용자 및 제공 기능 범위}
- {라이선스 B}: {대상 사용자 및 제공 기능 범위}
※ 라이선스 구분이 없는 경우 이 섹션 삭제

## GNB 목록
- {GNB-1}: {한 줄 설명}
- {GNB-2}: {한 줄 설명}

## 기술스택
- Backend: {예: Java 17, Spring Boot 3.x}
- Frontend: {예: React 18, TypeScript}
- DB: {예: MariaDB 10.x}

## 현재 상태
- 버전: {예: v1.2.0}
- 단계: {예: 운영 중 / 개발 중 / 기획 중}
- 마지막 업데이트: {날짜}
```

## 3단계: conventions.md 작성

```markdown
# {모듈명} 컨벤션

## 기술스택 상세
{버전 포함 상세 스택}

## 코딩 컨벤션
- 패키지 구조: {예: com.douzone.amaranth.{모듈}.{레이어}}
- 서비스 네이밍: {예: {기능}Service.java}
- React 컴포넌트: {예: PascalCase, 기능별 폴더 구성}
- API 경로: {예: /api/v1/{모듈}/{리소스}}

## 라이선스별 기능 분기
{분기 방식 설명. 예: LicenseType enum으로 분기, @LicenseCheck 어노테이션 사용}

## 공통 컴포넌트
- {컴포넌트명}: {용도}
```

## 4단계: GNB별 디렉토리 및 파일 생성

각 GNB에 대해:

```bash
mkdir -p {모듈명}/context/{GNB명}
```

`_overview.md`와 각 LNB별 `.md` 파일을 생성한다.

## 5단계: 검증

모든 파일 작성 후 `/load-context {모듈명}` 커맨드로 정상 로드 확인.
