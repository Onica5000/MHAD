import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/services/locked_progress/key_value_store.dart';
import 'package:mhad/services/locked_progress/lock_crypto.dart';
import 'package:mhad/services/locked_progress/locked_progress_store.dart';
import 'package:mhad/services/locked_progress/progress_autosave.dart';
import 'package:mhad/services/passphrase/passphrase_lists.dart';
import 'package:mhad/ui/progress/progress_screens.dart';

/// The saved-progress pages lay out without overflow in English and Spanish,
/// on a phone and on a desktop (sized views, per the widget-test rule).
void main() {
  final listsJson =
      File('assets/data/passphrase_lists.json').readAsStringSync();

  /// A store with a locked copy waiting (as after a reload): the resume page.
  Future<LockedProgressStore> waitingCopy(WidgetTester tester) async {
    final device = MemoryKeyValueStore();
    final tab = MemoryKeyValueStore();
    LockedProgressStore make(String id) => LockedProgressStore(
          device: device,
          tab: tab,
          crypto: createLockCrypto(),
          window: () => const Duration(minutes: 30),
          iterations: 1000,
          tabId: id,
        );
    await tester.runAsync(() async {
      final first = make('a');
      await first.startLocked('Blue horse tea!');
      await first.save({'directives': []});
    });
    return make('b');
  }

  for (final locale in const [Locale('en'), Locale('es')]) {
    for (final size in const [Size(390, 844), Size(1280, 900)]) {
      final label = '${locale.languageCode} ${size.width.toInt()}';

      Future<void> pump(WidgetTester tester, Widget page,
          {LockedProgressStore? store}) async {
        // Inside the test's zone, so the form's load completes on pump().
        PassphraseLists.debugUseLists(PassphraseLists.fromJson(listsJson));
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(ProviderScope(
          overrides: [
            if (store != null) lockedProgressProvider.overrideWithValue(store),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: page,
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      }

      testWidgets('start choice lays out ($label)', (tester) async {
        await pump(tester, const ProgressChoiceScreen());
        expect(tester.takeException(), isNull);
        expect(find.byType(Card), findsNWidgets(2));
      });

      testWidgets('passphrase page lays out ($label)', (tester) async {
        await pump(tester,
            const PassphraseSetupScreen(actionLabel: 'Lock my progress'));
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byType(TextField).first, 'Blue horse tea!');
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'with the gauge shown');
      });

      testWidgets('resume page lays out ($label)', (tester) async {
        final store = await waitingCopy(tester);
        await pump(tester, const ResumeProgressScreen(), store: store);
        expect(tester.takeException(), isNull);
        expect(find.byType(TextField), findsOneWidget);
      });
    }
  }
}
