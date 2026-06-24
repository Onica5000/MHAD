import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/ui/onboarding/onboarding_screen.dart';
import 'package:mhad/ui/theme/app_theme.dart';

void main() {
  testWidgets('Onboarding scrolls on a short viewport (no overflow)',
      (tester) async {
    await AppData.load();
    // A short mobile viewport — where the fixed Column previously clipped.
    tester.view.physicalSize = const Size(360, 460);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildMhadTheme(ThemePalette.teal, Brightness.light),
        home:
            OnboardingScreen(notifier: OnboardingNotifier(initialValue: false)),
      ),
    ));
    await tester.pump();

    // No RenderFlex overflow on the short screen.
    expect(tester.takeException(), isNull);
    // The content is scrollable.
    expect(find.byType(Scrollable), findsWidgets);

    // Scroll down to the bottom CTAs and confirm they're reachable.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Get started'), findsOneWidget);
  });
}
