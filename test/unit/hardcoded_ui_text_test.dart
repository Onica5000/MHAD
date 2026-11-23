import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// No hardcoded English on screens: text a person sees comes from the ARB
/// files (context.l10n), so Spanish readers get Spanish. Scans lib/ui for a
/// string literal with words passed to Text(...) or to a text parameter
/// (label:, hintText:, tooltip:, title: …). Interpolated values don't count.
///
/// Out of scope here: the official PDF form text (lib/ui/export/pdf/ — English
/// by design) and the owner-only admin screen (lib/ui/admin/). Text from data
/// files is covered by app_data_localized_text_test; a literal built in a
/// service or model and shown on a screen can't be seen by a scan like this
/// — the 2026-11-21 sweep found those with a Jev pass over every literal.
///
/// A deliberate exception goes in [_allowed] with its reason.
const _allowed = <String, String>{
  'lib/ui/theme/app_theme.dart|Warm Teal': 'palette name; no palette picker shows it',
  'lib/ui/theme/app_theme.dart|Deep Navy': 'palette name; no palette picker shows it',
  'lib/ui/theme/app_theme.dart|Sage Green': 'palette name; no palette picker shows it',
  'lib/ui/wizard/steps/personal_info_step.dart|PA': 'default state code (data)',
  'lib/ui/wizard/steps/diagnoses_step.dart|ICD-10':
      'code-system name, unchanged in Spanish (docs/SPANISH_STYLE.md)',
  'lib/ui/wizard/steps/people_i_trust_step.dart|20 Pa.C.S. § 5836':
      'statute citation, unchanged in Spanish (docs/SPANISH_STYLE.md)',
  'lib/ui/wizard/widgets/pipeline_apply_service.dart|Preferred facility type':
      'written into the person’s directive text, not shown as app UI',
  'lib/ui/wizard/widgets/pipeline_apply_service.dart|Facility settings to avoid':
      'written into the person’s directive text, not shown as app UI',
};

const _params = 'label|labelText|hintText|helperText|errorText|tooltip|message|'
    'semanticsLabel|semanticLabel|title|subtitle|text|hint';

void main() {
  test('screens take their words from the ARB files', () {
    final found = <String>[];
    final used = <String>{};
    for (final quote in const ["'", '"']) {
      final q = RegExp.escape(quote);
      final pattern = RegExp(
        '(?:\\bText\\(\\s*|\\b(?:$_params)\\s*:\\s*)(?:const\\s+)?r?$q'
        '([^$quote\\n]*)$q',
      );
      for (final f in Directory('lib/ui').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('.dart')) continue;
        final rel = f.path.replaceAll('\\', '/');
        if (rel.contains('/pdf/') || rel.startsWith('lib/ui/admin/')) continue;
        // Blank out // comments, keeping line numbers.
        final src = f
            .readAsLinesSync()
            .map((l) => l.trimLeft().startsWith('//') ? '' : l)
            .join('\n');
        for (final m in pattern.allMatches(src)) {
          final literal = m.group(1)!;
          // A quote inside an interpolation splits a literal into fragments
          // ('${dot ? "• " : ""}$label') — skip the unbalanced piece.
          if ('{'.allMatches(literal).length !=
              '}'.allMatches(literal).length) {
            continue;
          }
          final bare = literal.replaceAll(
              RegExp(r'\$\{[^}]*\}|\$[A-Za-z_]\w*'), '');
          if (!RegExp('[A-Za-z]{2,}').hasMatch(bare)) continue;
          final key = '$rel|$literal';
          if (_allowed.containsKey(key)) {
            used.add(key);
            continue;
          }
          final line = '\n'.allMatches(src.substring(0, m.start)).length + 1;
          found.add('$rel:$line  "$literal"');
        }
      }
    }
    expect(found, isEmpty,
        reason: 'Hardcoded English on a screen — add an ARB key (English + '
            'Spanish) and use context.l10n, or add it to _allowed with a '
            'reason:\n${found.join('\n')}');
    expect(_allowed.keys.toSet().difference(used), isEmpty,
        reason: 'stale _allowed entries (the literal is gone)');
  });
}
