import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/education/education_article_detail.dart';
import 'package:mhad/ui/education/learn_links.dart';
import 'package:mhad/ui/theme/app_theme.dart';

import '../support/real_fonts.dart';

/// With the Spanish articles loaded, a Spanish reader's article says it is a
/// translation and links to the Spanish glossary and the Spanish neighbours,
/// on a desktop and on a phone (real fonts: the longer Spanish header must
/// wrap, not overflow).
void main() {
  setUpAll(loadRealFonts);
  tearDown(EducationalContent.debugClearTranslations);

  for (final width in [1000.0, 390.0]) {
    testWidgets('a Spanish article at ${width.toInt()}px: translated, Spanish '
        'glossary words and related reading', (tester) async {
      tester.view.physicalSize = Size(width, 4000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.runAsync(() => EducationalContent.loadLanguage('es'));
      final spanish = EducationalContent.sectionsFor('es');
      final article = spanish.firstWhere((s) =>
          s.category != EducationCategory.glossary &&
          glossaryTermsIn(s, all: spanish).isNotEmpty &&
          relatedSections(s, all: spanish).isNotEmpty);

      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          locale: const Locale('es'),
          theme: buildMhadTheme(ThemePalette.navy, Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ArticleDetailScreen(section: article),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('TRADUCIDO DEL INGLÉS'), findsOneWidget,
          reason: 'a translated article says so');
      expect(find.text('Palabras que se usan aquí'), findsOneWidget);
      final term = glossaryTermsIn(article, all: spanish).first;
      expect(find.text(glossaryMatchTerms(term.title).first), findsOneWidget);
      for (final r in relatedSections(article, all: spanish)) {
        expect(find.text(r.title), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
