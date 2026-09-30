import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/facilitator/facilitator_screen.dart';
import 'package:mhad/ui/router.dart';

/// V4-L12 — the Get Help screen's guided-session entries open the assistant
/// with the right session flags and an opening message.
void main() {
  setUpAll(() => AppData.instance = AppData.fromJson(const {}));

  Future<AssistantContext?> tapAndCapture(
    WidgetTester tester,
    String button,
  ) async {
    AssistantContext? captured;
    final router = GoRouter(
      initialLocation: '/help',
      routes: [
        GoRoute(path: '/help', builder: (_, _) => const FacilitatorScreen()),
        GoRoute(
          path: AppRoutes.assistant,
          builder: (_, state) {
            captured = state.extra as AssistantContext?;
            return const Scaffold(body: Text('ASSISTANT'));
          },
        ),
      ],
    );
    await tester.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(button));
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
    expect(find.text('ASSISTANT'), findsOneWidget);
    return captured;
  }

  testWidgets('Start a guided session', (tester) async {
    final ctx = await tapAndCapture(tester, 'Start a guided session');
    expect(ctx?.guidedSession, isTrue);
    expect(ctx?.facilitatorMode, isFalse);
    expect(ctx?.openingPrompt, contains('what a crisis looks like for me'));
  });

  testWidgets("I'm helping someone", (tester) async {
    final ctx = await tapAndCapture(tester, "I'm helping someone");
    expect(ctx?.guidedSession, isTrue);
    expect(ctx?.facilitatorMode, isTrue);
    expect(ctx?.openingPrompt, contains('for them'));
  });
}
