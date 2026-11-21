import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Export page's PDF preview (printing's web plugin) runs pdf.js. The app
/// ships its own copy in web/pdfjs/ (index.html sets `dartPdfJsBaseUrl`), so
/// no code is fetched from another site (unpkg.com) at runtime. The copy must
/// be the pdf.js version the resolved printing package expects (its
/// `_pdfJsVersion`, read from the package source — no hand-kept map);
/// upgrading printing without updating web/pdfjs/ fails here.
///
/// printing 5.15+ loads pdf.js 4+ as ES modules (`import()` of pdf.min.mjs;
/// worker pdf.worker.min.mjs). That fixed CVE-2024-4367 (pdf.js 3.2.146 could
/// run script from a crafted PDF's fonts).
void main() {
  const files = ['pdf.min.mjs', 'pdf.worker.min.mjs'];

  test('index.html points printing at the bundled pdf.js by full URL', () {
    final html = File('web/index.html').readAsStringSync();
    // import() rejects a bare 'pdfjs/…' path ("Failed to resolve module
    // specifier"), so the base must be a full URL.
    expect(
        html,
        contains("window.dartPdfJsBaseUrl = "
            "new URL('pdfjs/', document.baseURI).href"));
    expect(html.indexOf('dartPdfJsBaseUrl'),
        lessThan(html.indexOf('<script src="flutter_bootstrap.js"')),
        reason: 'set before the app (and printing) loads');
  });

  test('the bundled pdf.js is the version printing expects', () {
    final pdfjs = _printingPdfJsVersion();
    for (final f in files) {
      final js = File('web/pdfjs/$f').readAsStringSync();
      expect(js, contains('"$pdfjs"'),
          reason: 'web/pdfjs/$f is not pdf.js $pdfjs, the version printing '
              'loads — put pdfjs-dist $pdfjs build/$f there');
    }
    expect(File('web/pdfjs/LICENSE').existsSync(), isTrue,
        reason: 'Apache-2.0 requires the license to travel with the files');
  });

  test('no leftover pdf.js files from an older version', () {
    final names = Directory('web/pdfjs')
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .toSet();
    expect(names, {...files, 'LICENSE'});
  });
}

/// `_pdfJsVersion` in the resolved printing package's web plugin.
String _printingPdfJsVersion() {
  final config = jsonDecode(
          File('.dart_tool/package_config.json').readAsStringSync())
      as Map<String, dynamic>;
  final pkg = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((p) => p['name'] == 'printing');
  var root = Uri.parse(pkg['rootUri'] as String);
  if (!root.path.endsWith('/')) root = root.replace(path: '${root.path}/');
  if (!root.isAbsolute) {
    root = Directory('.dart_tool').absolute.uri.resolveUri(root);
  }
  final src = File.fromUri(root.resolve('lib/printing_web.dart'))
      .readAsStringSync();
  final m = RegExp(r"_pdfJsVersion = '([^']+)'").firstMatch(src);
  expect(m, isNotNull, reason: 'printing no longer declares _pdfJsVersion');
  return m!.group(1)!;
}
