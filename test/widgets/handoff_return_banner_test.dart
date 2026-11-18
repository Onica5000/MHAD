import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/handoff/pending_handoff.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/ai/handoff_return_banner.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Fixed extends PendingHandoffNotifier {
  _Fixed(this.p);
  final PendingHandoff? p;
  @override
  PendingHandoff? build() => p;
}

/// "Back to paste your AI answer": shown on other pages while an answer is
/// pending; hidden on the waiting page, while a card that can take the
/// answer is on screen, and for a wait that can't be resumed.
void main() {
  const label = 'Back to paste your AI answer';
  setUp(() => SharedPreferences.setMockInitialValues({}));

  PendingHandoff wait({String route = '/upload/1'}) => PendingHandoff(
        taskTag: 'mhad-autofill',
        ref: 'd1',
        route: route,
        deadline: DateTime.now().add(const Duration(minutes: 10)),
      );

  Future<void> pump(
    WidgetTester tester, {
    required PendingHandoff? pending,
    required String at,
    Map<String, int> live = const {},
  }) async {
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(ProviderScope(
      overrides: [
        pendingHandoffProvider.overrideWith(() => _Fixed(pending)),
        liveHandoffCardsProvider.overrideWith((ref) => live),
      ],
      child: MaterialApp(
        theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: HandoffReturnBanner(current: Uri.parse(at))),
      ),
    ));
    await tester.pump();
  }

  testWidgets('shows on another page while an answer is pending',
      (tester) async {
    await pump(tester, pending: wait(), at: '/education');
    expect(find.text(label), findsOneWidget);
  });

  testWidgets('hidden on the waiting page', (tester) async {
    await pump(tester, pending: wait(), at: '/upload/1');
    expect(find.text(label), findsNothing);
  });

  testWidgets('hidden with nothing pending', (tester) async {
    await pump(tester, pending: null, at: '/education');
    expect(find.text(label), findsNothing);
  });

  testWidgets('hidden while a card that can take the answer is on screen',
      (tester) async {
    await pump(tester,
        pending: wait(),
        at: '/wizard/1?step=3',
        live: const {'mhad-autofill': 1});
    expect(find.text(label), findsNothing);
  });

  testWidgets("hidden for a wait that can't be resumed", (tester) async {
    await pump(tester, pending: wait(route: ''), at: '/education');
    expect(find.text(label), findsNothing);
  });

  test('a page is its path AND query (wizard steps differ)', () {
    expect(
        HandoffReturnBanner.isSamePage(
            '/wizard/1?step=5', Uri.parse('/wizard/1?step=5')),
        isTrue);
    expect(
        HandoffReturnBanner.isSamePage(
            '/wizard/1?step=5', Uri.parse('/wizard/1?step=6')),
        isFalse);
  });
}
