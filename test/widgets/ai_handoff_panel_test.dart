import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/handoff/handoff_prompt.dart';
import 'package:mhad/ai/handoff/handoff_task.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/ai/ai_handoff_panel.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The copy-and-paste handoff card end to end: copy (privacy notice on the
/// first copy of a session only) → the instructions land on the clipboard →
/// paste the AI's answer → it is applied and the clipboard is cleared; a bad
/// answer shows the problem, the fix-it button and the fresh-attempt note.
void main() {
  String? clipboard;

  setUp(() {
    clipboard = null;
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = (call.arguments as Map)['text'] as String?;
        return null;
      }
      if (call.method == 'Clipboard.getData') {
        return clipboard == null ? null : {'text': clipboard};
      }
      return null;
    });
  });

  Future<List<Map<String, dynamic>>> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final applied = <Map<String, dynamic>>[];
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: AiHandoffPanel(
              kind: HandoffTaskKind.autofill,
              title: 'Autofill',
              attachment: HandoffAttachment.document,
              buildTask: (_) => const HandoffTask(
                kind: HandoffTaskKind.autofill,
                instructions: 'READ THE DOCUMENT',
                ref: 'd1',
                attachment: HandoffAttachment.document,
              ),
              onAnswer: (json) async {
                applied.add(json);
                return true;
              },
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return applied;
  }

  testWidgets('copy shows the privacy notice once, then pastes and applies',
      (tester) async {
    final applied = await pump(tester);

    await tester.tap(find.text('Copy instructions'));
    await tester.pumpAndSettle();
    expect(find.text('Before you use an outside AI'), findsOneWidget);
    await tester.tap(find.text('I understand, continue'));
    await tester.pumpAndSettle();

    expect(clipboard, startsWith(kHandoffMarker));
    expect(clipboard, contains('READ THE DOCUMENT'));
    expect(find.textContaining('attach your document'), findsOneWidget);

    // A second copy in the same session: no notice.
    await tester.tap(find.text('Copy instructions'));
    await tester.pumpAndSettle();
    expect(find.text('Before you use an outside AI'), findsNothing);

    clipboard = '```json\n{"mhad_task": "mhad-autofill", "mhad_ref": "d1", '
        '"name": "Ada"}\n```';
    await tester.tap(find.text('Paste the answer').last);
    await tester.pumpAndSettle();

    expect(applied.single['name'], 'Ada');
    expect(clipboard, '', reason: 'the used answer is cleared');
    expect(find.textContaining('Review what was filled in'), findsOneWidget);
  });

  testWidgets('a bad answer explains the problem and offers a fix-it message',
      (tester) async {
    final applied = await pump(tester);
    await tester.tap(find.text('Copy instructions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I understand, continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField),
        '{"mhad_task": "mhad-autofill", "mhad_ref": "d9"}');
    await tester.tap(find.text('Use this answer'));
    await tester.pumpAndSettle();

    expect(applied, isEmpty);
    expect(find.textContaining('for a different directive'), findsOneWidget);
    expect(find.textContaining('Start a fresh attempt'), findsOneWidget);

    await tester.tap(find.text('Copy a fix-it message'));
    await tester.pumpAndSettle();
    expect(clipboard, contains('"mhad_task": "mhad-autofill"'));
  });
}
