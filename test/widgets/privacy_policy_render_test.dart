import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/settings/privacy_policy_screen.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// The privacy policy is rendered, not shown as source: no raw `**` markers
/// (the consumer-health-data section used to print them), and its "  - "
/// lists are real bullets.
void main() {
  testWidgets('no raw markup on the privacy policy', (tester) async {
    tester.view.physicalSize = const Size(1000, 12000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PrivacyPolicyScreen(),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('**', findRichText: true), findsNothing);
    expect(find.textContaining('do not sell', findRichText: true),
        findsOneWidget);
    expect(find.text('•'), findsWidgets);
  });
}
