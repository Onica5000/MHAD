import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/l10n/model_labels.dart';
import 'package:mhad/utils/date_format.dart';

/// Spanish mode must not leak English through dates or the English step names
/// that AssistantContext carries for the AI prompt.
void main() {
  final es = lookupAppLocalizations(const Locale('es'));
  final en = lookupAppLocalizations(const Locale('en'));
  final d = DateTime(2026, 6, 23, 15, 5);

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });
  tearDown(() => Intl.defaultLocale = null);

  test('English date output is unchanged', () {
    Intl.defaultLocale = 'en';
    expect(formatMonthDay(d), 'Jun 23');
    expect(formatShortDate(d), 'Jun 23, 2026');
    expect(formatLongDate(d), 'June 23, 2026');
    expect(formatMonthYear(d), 'June 2026');
    expect(formatWeekdayMonthDay(d), 'Tuesday · June 23');
  });

  test('Spanish dates use Spanish month names', () {
    Intl.defaultLocale = 'es';
    expect(formatLongDate(d), '23 de junio de 2026');
    expect(formatMonthYear(d), contains('junio'));
    expect(formatWeekdayMonthDay(d), 'martes · 23 de junio');
  });

  test('English step names in AssistantContext map to the UI language', () {
    expect(localizedStepName(WizardStep.medications.displayName, es),
        'Medicamentos');
    expect(localizedStepName('Learning', es), 'Aprendizaje');
    expect(localizedStepName('Something else', es), 'Something else');
    expect(localizedStepName(WizardStep.medications.displayName, en),
        'Medications');
  });

  test('every education category has a Spanish label', () {
    for (final c in EducationCategory.values) {
      expect(c.label(es), isNotEmpty);
    }
    expect(EducationCategory.faq.label(es), 'Preguntas frecuentes');
  });
}
