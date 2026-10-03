// PDF 쪽마다 PNG 그림을 만든다 — pdftoppm 이 없는 맥에서 시각 QA 용 (macOS PDFKit, JXA)
// 사용: osascript -l JavaScript pdf_pages.js <입력.pdf> <출력 폴더> [가로 px, 기본 1280]
// 출력: <출력 폴더>/p01.png, p02.png … 를 만들고 「N쪽」을 출력한다. PDF 를 열지 못하면 오류로 끝난다(종료 코드 1).
// 색: 그림은 sRGB 로 저장한다 — 변환 없이 저장하면 화면 색 프로필이 붙고, 그런 그림의 픽셀 값을 sRGB 로 읽으면 색·대비가 틀린다
//     (2026-10-02 사고: sips 로 그린 Display P3 그림을 sRGB 로 읽어 EQT 원본 칩 색을 #9A46F6·4.5:1 로 잘못 적음.
//      원본 정의는 #A041FF→#B339FF, 칩 안 흰 글자 대비 4.26~4.46:1)
// 확인(2026-10-03): Keynote 로 뽑은 13쪽 PDF → 1280×720 그림 13장. 배율 1 화면에서만 확인했고 레티나(배율 2) 화면은 확인하지 못했다.
ObjC.import('PDFKit'); ObjC.import('AppKit'); ObjC.import('Foundation');
function run(argv){
  var doc=$.PDFDocument.alloc.initWithURL($.NSURL.fileURLWithPath(argv[0]));
  if (!doc || doc.isNil() || doc.pageCount < 1) throw new Error('PDF 를 열지 못했습니다: '+argv[0]);
  var out=argv[1]; var width=argv.length>2 ? parseInt(argv[2],10) : 1280; var n=doc.pageCount;
  $.NSFileManager.defaultManager.createDirectoryAtPathWithIntermediateDirectoriesAttributesError(out, true, $(), $());
  for (var i=0;i<n;i++){
    var pg=doc.pageAtIndex(i); var b=pg.boundsForBox($.kPDFDisplayBoxMediaBox);
    // 세로를 올림해 상자를 넉넉히 준다 — 내림하면 비율을 지키려고 가로가 1px 줄어든다
    var h=Math.ceil(width*b.size.height/b.size.width);
    var img=pg.thumbnailOfSizeForBox($.NSMakeSize(width, h), $.kPDFDisplayBoxMediaBox);
    var rep0=$.NSBitmapImageRep.imageRepWithData(img.TIFFRepresentation);
    var rep=rep0.bitmapImageRepByConvertingToColorSpaceRenderingIntent($.NSColorSpace.sRGBColorSpace, $.NSColorRenderingIntentDefault);
    var png=rep.representationUsingTypeProperties($.NSBitmapImageFileTypePNG, $());
    png.writeToFileAtomically(out+'/p'+(i+1<10?'0':'')+(i+1)+'.png', true);
  }
  return n+'쪽';
}
