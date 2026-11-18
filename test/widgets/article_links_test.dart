import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/education/education_article_detail.dart';
import 'package:mhad/ui/education/learn_links.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/pills.dart';

/// A Learn article shows the glossary words it uses (tap → the meaning) and
/// the nearest articles to keep reading.
void main() {
  testWidgets('glossary words open their meaning; related articles listed',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    // The first article that uses a glossary word and has neighbors.
    final article = EducationalContent.sections.firstWhere((s) =>
        s.category != EducationCategory.glossary &&
        glossaryTermsIn(s).isNotEmpty &&
        relatedSections(s).isNotEmpty);
    final term = glossaryTermsIn(article).first;

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ArticleDetailScreen(section: article),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('TRANSLATED'), findsNothing,
        reason: 'the English booklet text is not a translation');
    expect(find.text('Words used here'), findsOneWidget);
    expect(find.text('Related reading'), findsOneWidget);
    for (final r in relatedSections(article)) {
      expect(find.text(r.title), findsOneWidget);
    }

    final chip = find.widgetWithText(ActionPill, glossaryMatchTerms(term.title).first);
    await tester.ensureVisible(chip);
    await tester.tap(chip);
    await tester.pumpAndSettle();
    expect(find.text('Open in the glossary'), findsOneWidget);
  });
}
