import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Export page's PDF preview (printing's web plugin) runs pdf.js. The app
/// ships its own copy in web/pdfjs/ (index.html sets `dartPdfJsBaseUrl`), so
/// no code is fetched from another site (unpkg.com) at runtime. The copy must
/// be the pdf.js version the locked printing package expects; upgrading
/// printing without updating web/pdfjs/ fails here.
void main() {
  const expected = {'5.14.3': '3.2.146'}; // printing → pdfjs-dist

  test('index.html points printing at the bundled pdf.js', () {
    final html = File('web/index.html').readAsStringSync();
    expect(html, contains("window.dartPdfJsBaseUrl = 'pdfjs/'"));
    expect(html.indexOf('dartPdfJsBaseUrl'),
        lessThan(html.indexOf('<script src="flutter_bootstrap.js"')),
        reason: 'set before the app (and printing) loads');
  });

  test('the bundled pdf.js matches the printing version', () {
    final lines = File('pubspec.lock').readAsLinesSync();
    final start = lines.indexOf('  printing:');
    expect(start, isNot(-1), reason: 'printing not found in pubspec.lock');
    final versionLine = lines
        .skip(start + 1)
        .takeWhile((l) => l.startsWith('    '))
        .firstWhere((l) => l.trimLeft().startsWith('version:'));
    final printing = versionLine.split('"')[1];
    final pdfjs = expected[printing];
    expect(pdfjs, isNotNull,
        reason: 'printing is now $printing: put the pdf.js version it expects '
            '(its _pdfJsVersion) in web/pdfjs/ and in this map');
    for (final f in ['pdf.min.js', 'pdf.worker.min.js']) {
      final js = File('web/pdfjs/$f').readAsStringSync();
      expect(js, contains('"$pdfjs"'), reason: 'web/pdfjs/$f is not $pdfjs');
    }
    expect(File('web/pdfjs/LICENSE').existsSync(), isTrue,
        reason: 'Apache-2.0 requires the license to travel with the files');
  });
}
