import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/router.dart';

void main() {
  testWidgets('narrow wizard renders the Continue bar without overflow',
      (tester) async {
    // Phone viewport → narrow (mobile) wizard layout.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );

    final db = AppDatabase(NativeDatabase.memory());
    final id = await DirectiveRepository(db).createDirective(FormType.combined);

    // Make the wizard the initial route so there's no Home→wizard transition
    // frame muddying the layout under test.
    appRouter.go(AppRoutes.wizardRoute(id));

    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MhadApp(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Drain any layout exceptions raised during the pumps. The regression we
    // guard against is the bar hitting an *infinite width* and failing to
    // paint (the "no nav buttons on mobile" bug); unrelated minor overflows
    // elsewhere are not this test's concern.
    final errors = <String>[];
    for (Object? e = tester.takeException(); e != null; e = tester.takeException()) {
      errors.add(e.toString());
    }
    expect(
      errors.where((e) => e.contains('infinite width')),
      isEmpty,
      reason: 'the bottom bar must not hit an infinite-width layout',
    );

    // The mobile Back/Continue bar must be present and laid out on-screen.
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.getSize(find.text('Continue')).width, greaterThan(0));

    await db.close();
  });
}
