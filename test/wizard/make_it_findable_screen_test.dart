import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/crisis_findability/make_it_findable_screen.dart';

/// M1 — "Make it findable in a crisis" checklist renders its actionable steps
/// and the PA-specific guidance. Pure UI (no DB), so a bare ProviderScope is
/// enough.
void main() {
  testWidgets('shows the crisis-findability checklist', (tester) async {
    tester.view.physicalSize = const Size(1000, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MakeItFindableScreen(directiveId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Make it findable in a crisis.'), findsOneWidget);
    expect(find.textContaining('Share it with your agent'), findsOneWidget);
    expect(find.textContaining('Give a copy to your care team'), findsOneWidget);
    expect(find.textContaining('carry the wallet card'), findsOneWidget);
    // PA-specific guidance about the lack of a statewide registry.
    expect(find.textContaining('no statewide directive registry'),
        findsOneWidget);
  });
}
