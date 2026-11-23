import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/audio_questionnaire_content.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/export/pdf/questionnaire_pdf.dart';

void main() {
  setUpAll(() => AppData.instance = AppData.fromJson(const {}));

  // Guards that the printable questionnaire renders in every language —
  // catches missing-glyph exceptions (§, em-dashes, curly quotes, Spanish
  // accents and ¿ ¡) and layout errors that only surface at doc.save().
  for (final locale in AppLocalizations.supportedLocales) {
    for (final form in [null, ...FormType.values]) {
      test('audio questionnaire PDF builds in ${locale.languageCode} '
          '(${form?.name ?? 'every form'})', () async {
        final bytes = await buildAudioQuestionnairePdf(
            lookupAppLocalizations(locale),
            form: form);
        expect(bytes.lengthInBytes, greaterThan(1000));
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      });
    }
  }

  test('the questionnaire follows the app language', () {
    final en = AudioQuestionnaire(lookupAppLocalizations(const Locale('en')));
    final es = AudioQuestionnaire(lookupAppLocalizations(const Locale('es')));
    expect(es.sections, hasLength(en.sections.length));
    for (var i = 0; i < en.sections.length; i++) {
      expect(es.sections[i].prompts, hasLength(en.sections[i].prompts.length));
      expect(es.sections[i].title, isNot(en.sections[i].title),
          reason: 'section “${en.sections[i].title}” has no Spanish title');
    }
    expect(es.intro, isNot(en.intro));
  });
}
