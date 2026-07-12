import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/labeled_spinner.dart';
import 'package:mhad/ui/widgets/design/step_dots.dart';

/// Locks the 2026-07-11 UX-audit accessibility/QoL behaviors:
/// A1 (tappable DesignCards are buttons and keyboard-activatable),
/// B7 (StepDots become tappable jump targets when wired),
/// A5 (LabeledSpinner exposes its label), and the B3 retry plumbing
/// (ConversationNotifier.removeLast).
void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
        home: Scaffold(body: Center(child: child)),
      );

  group('DesignCard (A1)', () {
    testWidgets('tappable card exposes button semantics and activates '
        'via keyboard', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(wrap(
        DesignCard(onTap: () => tapped++, child: const Text('Open thing')),
      ));

      // Button role present.
      expect(
        tester.getSemantics(find.text('Open thing')),
        matchesSemantics(
          isButton: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
          label: 'Open thing',
        ),
      );

      // Keyboard: focus the InkWell and activate with Enter.
      final ink = find.byType(InkWell);
      expect(ink, findsOneWidget);
      final node = Focus.of(tester.element(find.text('Open thing')));
      node.requestFocus();
      await tester.pump();
      expect(node.hasFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(tapped, 1);
    });

    testWidgets('non-tappable card has no button semantics', (tester) async {
      await tester.pumpWidget(wrap(
        const DesignCard(child: Text('Static')),
      ));
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('StepDots (B7)', () {
    testWidgets('bars are tappable jump targets when onStepTap is set',
        (tester) async {
      int? jumped;
      await tester.pumpWidget(wrap(
        SizedBox(
          width: 400,
          child: StepDots(
            current: 1,
            total: 5,
            onStepTap: (i) => jumped = i,
          ),
        ),
      ));
      // One focusable button per step.
      expect(find.byType(InkWell), findsNWidgets(5));
      await tester.tap(find.byType(InkWell).at(3));
      expect(jumped, 3);
      // Per-bar semantics label announces the destination.
      expect(
          find.bySemanticsLabel('Go to step 4 of 5'), findsOneWidget);
    });

    testWidgets('remains purely decorative without onStepTap',
        (tester) async {
      await tester.pumpWidget(wrap(
        const SizedBox(
          width: 400,
          child: StepDots(current: 2, total: 5),
        ),
      ));
      expect(find.byType(InkWell), findsNothing);
      expect(find.bySemanticsLabel('Step 2 of 5'), findsOneWidget);
    });
  });

  group('LabeledSpinner (A5)', () {
    testWidgets('exposes its label to assistive tech', (tester) async {
      await tester.pumpWidget(wrap(
        const LabeledSpinner(label: 'Searching medications', size: 16),
      ));
      expect(
          find.bySemanticsLabel('Searching medications'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('ConversationNotifier.removeLast (B3 retry plumbing)', () {
    test('pops the trailing turn pair; clamps at empty', () {
      final n = ConversationNotifier();
      n.add(ChatMessage(role: MessageRole.user, content: 'hi'));
      n.add(ChatMessage(role: MessageRole.assistant, content: 'error'));
      n.removeLast(2);
      expect(n.state, isEmpty);

      n.add(ChatMessage(role: MessageRole.user, content: 'a'));
      n.removeLast(5); // more than exists — clamps, no throw
      expect(n.state, isEmpty);

      n.add(ChatMessage(role: MessageRole.user, content: 'a'));
      n.add(ChatMessage(role: MessageRole.assistant, content: 'b'));
      n.removeLast(0); // no-op
      expect(n.state.length, 2);
    });
  });
}
