import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Source-text audit that asserts **every** `IconButton(...)` in `lib/`
/// carries an accessibility label.
///
/// "Has a label" means one of:
///   - the `IconButton` itself has a `tooltip:` parameter, OR
///   - the `IconButton` is wrapped (anywhere in the same chunk of code) by a
///     `Tooltip(message: ...)`, OR
///   - the `IconButton` is wrapped by a `Semantics(label: ...)`.
///
/// We scan source text rather than the rendered widget tree because several
/// screens (wizard, wizard-complete, export) mount native-only plugins
/// (NFC, biometric, speech_to_text, file_picker) that throw in the test
/// harness and prevent a full `pumpAndSettle`. This audit therefore covers
/// every screen — including those — without depending on rendering.
///
/// The Goal: keep "every button is clearly labelled" enforced for the whole
/// app, not just the screens we can render in tests.
void main() {
  // Sanity check — surface if the file-walk silently finds zero matches
  // (e.g. someone refactors lib/ away). A real codebase has many.
  test('audit walks lib/ and finds IconButtons', () {
    final lib = Directory('lib');
    final iconButtonRegex = RegExp(r'\bIconButton\s*\(');
    var count = 0;
    for (final file in lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      count += iconButtonRegex.allMatches(file.readAsStringSync()).length;
    }
    expect(count, greaterThan(15),
        reason: 'expected lib/ to contain a meaningful number of '
            'IconButtons; found $count — has the audit\'s file walk broken?');
  });

  test('every IconButton in lib/ has a label (tooltip or Tooltip/Semantics)',
      () {
    final lib = Directory('lib');
    expect(lib.existsSync(), isTrue, reason: 'lib/ must exist');

    final dartFiles = lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList(growable: false);

    final iconButtonRegex = RegExp(r'\bIconButton\s*\(');
    final tooltipParamRegex = RegExp(r'\btooltip\s*:');
    final tooltipWidgetRegex = RegExp(r'\bTooltip\s*\(');
    final semanticsRegex = RegExp(r'\bSemantics\s*\(');
    final labelParamRegex = RegExp(r'\blabel\s*:');

    final offenders = <String>[];

    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final match = iconButtonRegex.firstMatch(lines[i]);
        if (match == null) continue;

        // 1) Forward scan inside this IconButton's constructor for a
        //    `tooltip:` parameter. We track parenthesis balance starting
        //    from the IconButton's opening `(` so the scan terminates at
        //    the matching close paren. (Using indexOf('(') would catch a
        //    surrounding paren like `buildLeading(BuildContext context)`.)
        final openColumn = match.end - 1;
        var hasLabel = _hasTooltipParamInConstructor(
          lines,
          i,
          openColumn,
          tooltipParamRegex,
        );

        // 2) If not, look backwards a short distance for an enclosing
        //    Tooltip(...) widget or a Semantics(label: ...) ancestor in
        //    the same build expression.
        if (!hasLabel) {
          final start = (i - 12).clamp(0, lines.length);
          for (var k = start; k < i; k++) {
            if (tooltipWidgetRegex.hasMatch(lines[k])) {
              hasLabel = true;
              break;
            }
            if (semanticsRegex.hasMatch(lines[k])) {
              // confirm there's a label: within the next few lines of the
              // Semantics constructor
              final end = (k + 8).clamp(0, lines.length);
              for (var m = k; m < end; m++) {
                if (labelParamRegex.hasMatch(lines[m])) {
                  hasLabel = true;
                  break;
                }
              }
              if (hasLabel) break;
            }
          }
        }

        if (!hasLabel) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }

    expect(offenders, isEmpty,
        reason:
            'These IconButtons in lib/ are missing a tooltip / Tooltip / '
            'Semantics(label) wrapper:\n  ${offenders.join('\n  ')}');
  });

  test('every FloatingActionButton in lib/ has a tooltip', () {
    // FAB tooltips become the primary screen-reader label.
    final lib = Directory('lib');
    final dartFiles = lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList(growable: false);

    final fabRegex = RegExp(r'\bFloatingActionButton(\.[a-zA-Z]+)?\s*\(');
    final tooltipParamRegex = RegExp(r'\btooltip\s*:');

    final offenders = <String>[];
    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final match = fabRegex.firstMatch(lines[i]);
        if (match == null) continue;
        final openColumn = match.end - 1;
        final has = _hasTooltipParamInConstructor(
          lines,
          i,
          openColumn,
          tooltipParamRegex,
        );
        if (!has) offenders.add('${file.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty,
        reason: 'FloatingActionButtons missing tooltip:\n  '
            '${offenders.join('\n  ')}');
  });

  test('every PopupMenuButton in lib/ has a tooltip', () {
    // PopupMenuButton renders an icon-only trigger; without tooltip, screen
    // readers and hover-help see nothing.
    final lib = Directory('lib');
    final dartFiles = lib
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList(growable: false);

    final popupRegex = RegExp(r'\bPopupMenuButton(<[^>]+>)?\s*\(');
    final tooltipParamRegex = RegExp(r'\btooltip\s*:');

    final offenders = <String>[];
    for (final file in dartFiles) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final match = popupRegex.firstMatch(lines[i]);
        if (match == null) continue;
        final openColumn = match.end - 1;
        final has = _hasTooltipParamInConstructor(
          lines,
          i,
          openColumn,
          tooltipParamRegex,
        );
        if (!has) offenders.add('${file.path}:${i + 1}');
      }
    }
    expect(offenders, isEmpty,
        reason: 'PopupMenuButtons missing tooltip:\n  '
            '${offenders.join('\n  ')}');
  });
}

/// Scans forward from `(startLine, openColumn)` — which must point at the
/// constructor's own opening `(` — until the matching close paren, returning
/// true if [paramRegex] matches anywhere inside that constructor's argument
/// list.
bool _hasTooltipParamInConstructor(
  List<String> lines,
  int startLine,
  int openColumn,
  RegExp paramRegex,
) {
  if (openColumn < 0 || openColumn >= lines[startLine].length) return false;
  if (lines[startLine][openColumn] != '(') return false;

  var depth = 0;
  for (var i = startLine; i < lines.length; i++) {
    final line = lines[i];
    final start = (i == startLine) ? openColumn : 0;
    for (var c = start; c < line.length; c++) {
      final ch = line[c];
      if (ch == '(') depth++;
      if (ch == ')') {
        depth--;
        if (depth == 0) {
          // Reached the matching close paren without seeing the param.
          // Final check: maybe it's on this line up to position c.
          final upTo = line.substring(0, c);
          if (paramRegex.hasMatch(upTo)) return true;
          return false;
        }
      }
    }
    if (paramRegex.hasMatch(line)) return true;
  }
  // Unclosed — should not happen in valid Dart, treat as no label found.
  return false;
}
