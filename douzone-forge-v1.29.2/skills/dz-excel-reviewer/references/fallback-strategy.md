# 파싱 실패 대응 규칙

## 1차 경로

- `openpyxl`로 워크북 로드
- 시트별 값, 병합셀, 숨김 행/열, 데이터 검증 확인

## 실패 시

다음 중 하나면 fallback을 쓴다.
- XML parse error
- workbook load failure
- 특정 시트만 손상

## 2차 경로: zip/xml fallback

워크북은 zip 구조이므로 아래는 보통 직접 복원 가능하다.
- `xl/workbook.xml`
  - 시트 목록
  - 숨김 여부
- `xl/_rels/workbook.xml.rels`
  - 시트와 worksheet XML 연결
- `xl/worksheets/sheet*.xml`
  - 병합셀
  - 데이터 검증
  - 원시 셀 구조 일부

## fallback에서 확보할 최소 정보

1. 시트명 목록
2. 숨김 시트 목록
3. 시트별 병합셀/데이터검증 존재 여부
4. 손상된 시트 이름
5. 필요한 추가 자료

## fallback 이후 요청 기준

- 값 해석까지 꼭 필요하면:
  - 해당 시트를 `csv`로 다시 내보내 달라고 요청
- 색상/서식 의미가 중요하면:
  - 캡처 또는 PDF 요청
- 숨김 시트 내용까지 실제로 읽어야 하면:
  - 문제 시트만 재저장한 새 `xlsx` 요청
