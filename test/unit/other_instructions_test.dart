import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/ai/smart_fill_service.dart';
import 'package:mhad/domain/model/other_instructions.dart';
import 'package:mhad/ui/export/pdf/pdf_section_builders.dart';

/// One format for the tagged sections in the `other` column — the
/// Anything-else step, the PDF, autofill and smart-fill all use it.
void main() {
  group('OtherInstructions', () {
    test('a multi-line section survives a round trip', () {
      const o = OtherInstructions(
        deescalation: 'Speak slowly.\nOffer a quiet room.',
        triggers: 'Being grabbed.\nShouting.',
        reproductive: 'If I may be pregnant, ask before any medication.',
        other: 'Water my plants.\nGet my mail.',
      );
      final back = OtherInstructions.parse(o.serialize());
      expect(back.deescalation, o.deescalation);
      expect(back.triggers, o.triggers);
      expect(back.reproductive, o.reproductive);
      expect(back.other, o.other,
          reason: 'only the first line used to stay in its section');
    });

    test('a legacy one-line section still reads the same way', () {
      final o = OtherInstructions.parse(
          '[DE-ESCALATION] deep breathing\n[TRIGGERS] loud rooms\nmy note');
      expect(o.deescalation, 'deep breathing');
      expect(o.triggers, 'loud rooms');
      expect(o.other, 'my note');
      expect(o.serialize(),
          '[DE-ESCALATION] deep breathing\n[TRIGGERS] loud rooms\nmy note');
    });

    test('append adds on a new line and leaves other sections alone', () {
      final o = const OtherInstructions(triggers: 'Shouting.')
          .append(triggers: 'Crowds.', deescalation: '  ', other: 'Mail.');
      expect(o.triggers, 'Shouting.\nCrowds.');
      expect(o.deescalation, '');
      expect(o.other, 'Mail.');
    });
  });

  test('the PDF reads every line of a section, plus the legacy guidance tags', () {
    final serialized = const OtherInstructions(
      deescalation: 'Line one.\nLine two.',
      other: 'Plain note.',
    ).serialize();
    final p = parseOtherField('$serialized\n[ECT GUIDANCE] legacy note');
    expect(p.deEscalation, 'Line one.\nLine two.');
    expect(p.otherText, 'Plain note.');
    expect(p.ectGuidance, 'legacy note');
  });

  test('autofill can fill reproductive health care (POA leaves it out)', () {
    expect(DocumentExtractor.promptFor('combined'),
        contains('reproductive_health\n'));
    expect(DocumentExtractor.promptFor('poa'),
        contains('children_custody, reproductive_health, other. Ignore'));
  });

  test('smart-fill sees the person\'s own de-escalation and triggers', () {
    final prompt = SmartFillService.buildPrompt(const SmartFillInput(
      conditions: [],
      currentMedications: [],
      medicationsToAvoid: [],
      formType: 'combined',
      existingDeescalation: 'Dim the lights.',
      existingTriggers: 'Being touched without warning.',
    ).sanitized());
    expect(prompt, contains('De-escalation techniques: Dim the lights.'));
    expect(prompt, contains('Crisis triggers: Being touched without warning.'));
    expect(prompt, contains('never invent dates'),
        reason: 'health history uses only facts the person gave');
  });
}
