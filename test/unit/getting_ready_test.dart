import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/getting_ready_content.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/l10n/model_labels.dart';
import 'package:mhad/ui/export/pdf/getting_ready_pdf.dart';

/// The "Getting ready" checklist (user, 2026-11-22): validity first, then
/// what to gather in the wizard's order, then after signing.
void main() {
  setUpAll(() => AppData.instance = AppData.fromJson(const {}));
  final l = lookupAppLocalizations(const Locale('en'));

  test('validity states the canon facts', () {
    final text = GettingReadyChecklist(l)
        .items(GettingReadyTier.valid)
        .map((i) => i.text)
        .join('\n');
    expect(text, contains('18 or older, or an emancipated minor'));
    expect(text, contains('Two witnesses, each 18 or older, are physically present'));
    expect(text, contains('No notary is needed'));
    expect(text, contains('Neither witness is your agent or the person signing for you'));
    expect(text, contains('unless they are your relative'));
  });

  test('after signing keeps the two-year incapacity exception', () {
    final text = GettingReadyChecklist(l)
        .items(GettingReadyTier.after)
        .map((i) => i.text)
        .join('\n');
    expect(text, contains('valid for two years'));
    expect(text, contains('then it stays in effect until you can'));
    // Every form has someone to tell — never "your agent" here (Declaration).
    expect(text, contains('tell someone you trust where it is'));
  });

  for (final form in FormType.values) {
    test('${form.name}: gather items follow the wizard\'s own steps, in order', () {
      final c = GettingReadyChecklist(l, form: form);
      final steps = [
        for (final i in c.items(GettingReadyTier.gather))
          if (i.step != null) i.step!,
      ];
      // Every step named belongs to this form, in wizard order.
      final order = form.steps;
      expect(steps.every(order.contains), isTrue);
      for (var k = 1; k < steps.length; k++) {
        expect(order.indexOf(steps[k]), greaterThanOrEqualTo(order.indexOf(steps[k - 1])));
      }
      // The tag uses the wizard's own step title.
      final first = c.items(GettingReadyTier.gather).first;
      expect(c.stepTag(first), contains(first.step!.title(l)));
    });
  }

  test('a Declaration has no agent items; a POA has its own procedures item', () {
    final d = GettingReadyChecklist(l, form: FormType.declaration);
    expect(d.items(GettingReadyTier.valid).map((i) => i.id), isNot(contains('valid-agent')));
    expect(d.items(GettingReadyTier.gather).map((i) => i.id), isNot(contains('agent')));
    final p = GettingReadyChecklist(l, form: FormType.poa);
    final ids = p.items(GettingReadyTier.gather).map((i) => i.id).toList();
    expect(ids, contains('procedures-poa'));
    expect(ids, isNot(contains('meds')));
  });

  for (final locale in AppLocalizations.supportedLocales) {
    for (final form in [null, ...FormType.values]) {
      test('PDF builds in ${locale.languageCode} (${form?.name ?? 'every form'})', () async {
        final bytes =
            await buildGettingReadyPdf(lookupAppLocalizations(locale), form: form);
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      });
    }
  }
}
