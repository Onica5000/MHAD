import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/ai/ask_ai_screen.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The facilitator page's "Start a guided session" opens Ask AI with the
/// session's opening request already typed in, so the person only copies it
/// (with the guided-session instructions) into their own AI.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a guided session opens with its request filled in',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    const request = 'Please walk me through it one question at a time.';
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AskAiScreen(
          assistantContext: AssistantContext(
            guidedSession: true,
            openingPrompt: request,
          ),
        ),
      ),
    ));
    await tester.pump();
    final field = tester.widgetList<TextField>(find.byType(TextField)).firstWhere(
        (f) => f.controller?.text == request,
        orElse: () => throw TestFailure('the request is not in a text box'));
    expect(field.controller!.text, request);
  });
}
