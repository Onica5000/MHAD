import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/audio_questionnaire_content.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/l10n/model_labels.dart';

/// The voice questionnaire runs alongside the app (user, 2026-11-22): same
/// steps, same order, same titles, and every autofill key is asked for.
void main() {
  setUpAll(() => AppData.instance = AppData.fromJson(const {}));

  for (final locale in AppLocalizations.supportedLocales) {
    final l = lookupAppLocalizations(locale);

    test('${locale.languageCode}: every autofill key is asked for somewhere', () {
      final covered = AudioQuestionnaire(l).coveredKeys;
      const notAsked = {'document_relevant', 'document_kind', 'check_notes'};
      final missing = [
        for (final k in DocumentExtractor.answerKeys)
          if (!notAsked.contains(k) && !covered.contains(k)) k,
      ];
      expect(missing, isEmpty);
    });

    for (final form in FormType.values) {
      test('${locale.languageCode}/${form.name}: sections follow the wizard\'s steps and titles', () {
        final q = AudioQuestionnaire(l, form: form);
        final steps = [for (final s in q.sections) if (s.step != null) s.step!];
        final wizard = [
          for (final s in form.steps)
            if (s != WizardStep.reviewAndSign) s,
        ];
        expect(steps, wizard, reason: 'same steps, same order');
        for (final s in q.sections.where((s) => s.step != null)) {
          expect(s.title, s.step!.title(l), reason: 'the step\'s own title');
          expect(q.stepLabel(s),
              l.stepDotsStepOf(form.steps.indexOf(s.step!) + 1, form.steps.length));
        }
      });
    }

    test('${locale.languageCode}: a Declaration never offers "my agent decides"', () {
      final q = AudioQuestionnaire(l, form: FormType.declaration);
      final text = q.sections.expand((s) => s.prompts).map((p) => p.text).join('\n');
      expect(text, isNot(contains(l.consentChoiceAgentDecidesTitle)));
      expect(text, isNot(contains(l.medsStepAgentDecides)));
      expect(text, isNot(contains(l.guardianNomSameAsPrimary)));
    });

    test('${locale.languageCode}: a POA needs only part 1', () {
      expect(AudioQuestionnaire(l, form: FormType.poa).parts, [AudioQPart.you]);
    });
  }

  test('prompts quote the screen\'s own labels', () {
    final l = lookupAppLocalizations(const Locale('en'));
    final text = AudioQuestionnaire(l).allSections
        .expand((s) => s.prompts)
        .map((p) => p.text)
        .join('\n');
    for (final label in [
      l.effCondTriggerTwoTitle,
      l.facilityRoomLowStimulation,
      l.medsStepNeverTitle,
      l.addlInstrReproTitle,
      l.addlInstrRecordsWithholdLabel,
      l.crisisPlanDonTDoThese,
    ]) {
      expect(text, contains('“$label”'), reason: label);
    }
  });
}
