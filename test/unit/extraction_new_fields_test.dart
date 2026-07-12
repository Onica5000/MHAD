import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extraction_result.dart';

/// Locks the audit-added extraction fields (docs/AI_AUDIT_2026-07-08.md C1-C4):
/// medication consent + conditional values, statutory triggers, guardianship
/// conditions, room-preference chips + roommate match, and the structured
/// crisis plan — parse, merge, and shape.
void main() {
  test('parses the C1 fields: medication consent, conditional, triggers', () {
    final r = DocumentExtractionResult.fromJson({
      'medication_consent': 'conditional: oral medications only',
      'ect_consent': 'no',
      'trigger_two_professionals': true,
      'trigger_involuntary_commitment': false,
    });
    expect(r.medicationConsent, 'conditional: oral medications only');
    expect(r.ectConsent, 'no');
    expect(r.triggerTwoProfessionals, isTrue);
    expect(r.triggerCourtOrder, isNull);
    expect(r.triggerInvoluntaryCommitment, isFalse);
    expect(r.isEmpty, isFalse);
  });

  test('parses the C2/C3 fields: guardian conditions, chips, roommate match',
      () {
    final r = DocumentExtractionResult.fromJson({
      'guardian_can_revoke': false,
      'guardian_must_consult_agent': true,
      'guardian_must_consult_agent_note': 'unless unreachable for 48 hours',
      'room_preference_chips': ['singleRoom', 'quietFloor', ''],
      'same_gender_roommate': true,
      'roommate_gender_match': 'women',
    });
    expect(r.guardianCanRevoke, isFalse);
    expect(r.guardianCanChangeAgent, isNull);
    expect(r.guardianMustConsultAgent, isTrue);
    expect(r.guardianMustConsultAgentNote, 'unless unreachable for 48 hours');
    expect(r.roomPreferenceChips, ['singleRoom', 'quietFloor'],
        reason: 'empty entries dropped');
    expect(r.roommateGenderMatch, 'women');
  });

  test('parses and shapes the C4 crisis plan', () {
    final r = DocumentExtractionResult.fromJson({
      'crisis_plan': {
        'early_warning': ['stops sleeping'],
        'helps': ['dim lights', 'let me pace'],
        'dont_do': ["don't touch me"],
      },
    });
    final cp = r.crisisPlan!;
    expect(cp.isEmpty, isFalse);
    expect(cp.earlyWarning, ['stops sleeping']);
    expect(cp.triggers, isEmpty);
    expect(
      cp.toCrisisPlanMap().keys,
      ['earlyWarning', 'triggers', 'helps', 'sayToMe', 'dontDo'],
      reason: 'must match the crisis-plan screen json keys exactly',
    );
    expect(cp.display(), contains('What helps: dim lights; let me pace'));
  });

  test('multi-page merge: first non-null wins for scalars; lists union', () {
    final page1 = DocumentExtractionResult.fromJson({
      'medication_consent': 'yes',
      'room_preference_chips': ['singleRoom'],
      'crisis_plan': {
        'helps': ['music'],
      },
    });
    final page2 = DocumentExtractionResult.fromJson({
      'medication_consent': 'no', // conflicting later page must not override
      'trigger_court_order': true,
      'room_preference_chips': ['singleRoom', 'quietFloor'],
      'guardian_can_revoke': true,
      'crisis_plan': {
        'helps': ['music', 'weighted blanket'],
        'triggers': ['crowds'],
      },
    });
    final merged = page1.merge(page2);
    expect(merged.medicationConsent, 'yes');
    expect(merged.triggerCourtOrder, isTrue);
    expect(merged.roomPreferenceChips, ['singleRoom', 'quietFloor']);
    expect(merged.guardianCanRevoke, isTrue);
    expect(merged.crisisPlan!.helps, ['music', 'weighted blanket']);
    expect(merged.crisisPlan!.triggers, ['crowds']);
  });

  test('relevance scrub also drops all the new fields', () {
    final r = DocumentExtractionResult.fromJson({
      'document_relevant': false,
      'medication_consent': 'yes',
      'trigger_court_order': true,
      'guardian_can_revoke': true,
      'room_preference_chips': ['singleRoom'],
      'crisis_plan': {
        'helps': ['music'],
      },
    });
    expect(r.medicationConsent, isNull);
    expect(r.triggerCourtOrder, isNull);
    expect(r.guardianCanRevoke, isNull);
    expect(r.roomPreferenceChips, isEmpty);
    expect(r.crisisPlan, isNull);
    expect(r.isEmpty, isTrue);
  });
}
