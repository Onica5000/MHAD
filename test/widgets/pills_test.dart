import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/pills.dart';

/// The pills are real buttons: a screen reader hears a button with its name,
/// never a checkbox (see web_chip_semantics_rule_test).
void main() {
  Widget host(Widget child) => MaterialApp(
        theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('ActionPill: a button named by its tooltip', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(host(ActionPill(
      icon: Icons.menu_book_outlined,
      label: 'Agent',
      tooltip: 'What “Agent” means',
      onPressed: () => taps++,
    )));
    expect(
      tester.getSemantics(find.byType(TextButton)),
      isSemantics(
        label: 'What “Agent” means',
        isButton: true,
        hasTapAction: true,
        hasCheckedState: false,
      ),
    );
    await tester.tap(find.text('Agent'));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('RemovablePill: plain text plus a remove button naming the item',
      (tester) async {
    final handle = tester.ensureSemantics();
    var removed = 0;
    await tester.pumpWidget(
        host(RemovablePill(label: 'Racing thoughts', onRemove: () => removed++)));
    expect(
      tester.getSemantics(find.text('Racing thoughts')),
      isSemantics(label: 'Racing thoughts', isButton: false,
          hasCheckedState: false),
    );
    await tester.tap(find.byTooltip('Remove Racing thoughts'));
    expect(removed, 1);
    handle.dispose();
  });
}
