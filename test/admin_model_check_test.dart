import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/ai_prefs.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/admin/admin_update_screen.dart';

/// Drives the admin "Check models — all providers" action end to end with no
/// keys saved: every provider must be reported as skipped (no crash, no
/// network), and cancelling leaves the draft form in place.
void main() {
  testWidgets('all-provider model check reports each provider', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await AppData.load();
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        aiPrefsProvider.overrideWithValue(const AsyncData(AiPrefs.initial)),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AdminUpdateScreen(),
      ),
    ));
    await tester.enterText(find.byType(TextField), AdminUpdateScreen.passphrase);
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Check models — all providers'));
    await tester.pumpAndSettle();

    expect(find.text('Model check — all providers'), findsOneWidget);
    for (final label in [
      'Google Gemini',
      'Anthropic Claude',
      'OpenAI GPT',
      'xAI Grok',
    ]) {
      expect(find.text('No $label key saved — skipped.'), findsOneWidget);
    }

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Model check — all providers'), findsNothing);
    expect(find.text('Check models — all providers'), findsOneWidget);
  });
}
