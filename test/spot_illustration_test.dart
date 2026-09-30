import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/illustrated_intro.dart';
import 'package:mhad/ui/widgets/design/spot_illustration.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('every SpotArt paints ($brightness)', (tester) async {
      final palette = ThemePalette.values.first;
      await tester.pumpWidget(MaterialApp(
        theme: buildMhadTheme(palette, brightness),
        home: Scaffold(
          body: Wrap(children: [
            for (final a in SpotArt.values) SpotIllustration(art: a, size: 120),
          ]),
        ),
      ));
      expect(tester.takeException(), isNull);
      expect(find.byType(SpotIllustration), findsNWidgets(SpotArt.values.length));
    });
  }

  testWidgets('IllustratedIntro: art beside the whole intro when wide, '
      'beside the label only when narrow', (tester) async {
    Future<void> pumpAt(double width) => tester.pumpWidget(MaterialApp(
          theme: buildMhadTheme(ThemePalette.values.first, Brightness.light),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: const IllustratedIntro(
                  art: SpotArt.book,
                  label: Text('LABEL'),
                  body: Text('Heading and body'),
                ),
              ),
            ),
          ),
        ));
    await pumpAt(800);
    var art = tester.getSize(find.byType(SpotIllustration));
    expect(art.width, 112);
    await pumpAt(360);
    art = tester.getSize(find.byType(SpotIllustration));
    expect(art.width, 56);
    // Narrow: the body gets the full width, below the art row.
    expect(tester.getSize(find.text('Heading and body')).width,
        lessThanOrEqualTo(360));
    expect(tester.getTopLeft(find.text('Heading and body')).dy,
        greaterThan(tester.getBottomLeft(find.byType(SpotIllustration)).dy - 1));
  });
}
