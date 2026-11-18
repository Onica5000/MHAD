import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/wizard_bottom_bar.dart';

import '../support/real_fonts.dart';

/// The phone wizard has ONE bottom bar: Back · ✦ Ask · Continue. Ask keeps
/// its label when the three fit, measured at the real width and text size;
/// otherwise it shrinks to the ✦ icon (still named) instead of overflowing.
void main() {
  setUpAll(loadRealFonts);

  Future<void> pumpBar(
    WidgetTester tester, {
    required double width,
    String back = 'Back',
    String ask = 'Ask',
    String next = 'Continue',
    double textScale = 1.2, // the app's default text size
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(
      theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 800),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          bottomNavigationBar: WizardBottomBar(
            primaryLabel: next,
            onPrimary: () {},
            secondaryLabel: back,
            onSecondary: () {},
            showGradient: false,
            assistLabel: ask,
            assistTooltip: 'Ask AI about this step',
            onAssist: () {},
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('phone, English, default text size: labelled Ask',
      (tester) async {
    await pumpBar(tester, width: 390);
    expect(find.text('Ask'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Spanish labels that would not fit: the ✦ icon, still named',
      (tester) async {
    await pumpBar(tester,
        width: 390, back: 'Atrás', ask: 'Preguntar', next: 'Continuar');
    expect(find.text('Preguntar'), findsNothing);
    expect(find.byTooltip('Ask AI about this step'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('larger text on a phone: the icon, no overflow',
      (tester) async {
    await pumpBar(tester, width: 390, textScale: 1.4);
    expect(find.text('Ask'), findsNothing);
    expect(find.byTooltip('Ask AI about this step'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('largest text on the smallest phone: Ask steps aside, '
      'Back and Continue still fit', (tester) async {
    await pumpBar(tester, width: 340, textScale: 1.65);
    expect(find.byTooltip('Ask AI about this step'), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
