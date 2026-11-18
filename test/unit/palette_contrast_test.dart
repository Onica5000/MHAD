import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Every text-on-background pair the design system uses must read in BOTH
/// light and dark (WCAG AA, 4.5:1), computed from the colors themselves —
/// deterministic, unlike sampling rendered pixels (antialiased 12px text
/// reads low there). Added after "some of the text can't be read in dark
/// mode" (user, 2026-11-17): the dark theme kept the light-mode amber for
/// `tertiary` (~3.4:1) and white text on the dark-mode red (~3.3:1).
double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final brightness in Brightness.values) {
    group('navy · ${brightness.name}', () {
      final theme = buildMhadTheme(ThemePalette.navy, brightness);
      final p = theme.mhadPalette;
      final cs = theme.colorScheme;
      final snack = theme.snackBarTheme;
      final pairs = <String, (Color, Color)>{
        'text on card': (p.text, p.card),
        'text on page': (p.text, p.scaffoldBackground),
        'muted text on card': (p.textMuted, p.card),
        'muted text on page': (p.textMuted, p.scaffoldBackground),
        'primary text on card': (p.primary, p.card),
        'primary text on page': (p.primary, p.scaffoldBackground),
        'button text on primary': (p.onPrimary, p.primary),
        'text on tinted (primaryLight)': (p.onPrimaryLight, p.primaryLight),
        'text on tint (primaryTint)': (p.onPrimaryLight, p.primaryTint),
        'active nav label on its pill': (p.primary, p.primaryLight),
        'secondary on card': (cs.secondary, p.card),
        'tertiary (amber) on card': (cs.tertiary, p.card),
        'text on tertiary': (cs.onTertiary, cs.tertiary),
        'text on error (red buttons)': (cs.onError, cs.error),
        'warning text on card': (SemanticColors.warningText(brightness), p.card),
        'warning text on its banner':
            (SemanticColors.warningText(brightness), SemanticColors.warningBg(brightness)),
        'error text on card': (SemanticColors.errorText(brightness), p.card),
        'success text on card': (SemanticColors.successText(brightness), p.card),
        'success text on its banner':
            (SemanticColors.successText(brightness), SemanticColors.successBg(brightness)),
        'snackbar text': (snack.contentTextStyle!.color!, snack.backgroundColor!),
        'snackbar action (Undo, Extend)': (cs.inversePrimary, snack.backgroundColor!),
      };
      for (final e in pairs.entries) {
        test(e.key, () {
          final ratio = _contrast(e.value.$1, e.value.$2);
          expect(ratio, greaterThanOrEqualTo(4.5),
              reason: '${e.key}: ${ratio.toStringAsFixed(2)}:1');
        });
      }
    });
  }
}
