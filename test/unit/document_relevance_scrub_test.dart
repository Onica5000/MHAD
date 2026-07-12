import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extraction_result.dart';

/// Locks the code-level STEP-0 relevance contract: when the model marks a
/// document irrelevant, everything else in its response is discarded — even
/// if the model (wrongly) extracted fields anyway. Previously this was
/// enforced only by the prompt, so a mixed upload batch could merge an
/// irrelevant document's data.
void main() {
  test('document_relevant=false scrubs every extracted field', () {
    final r = DocumentExtractionResult.fromJson({
      'document_relevant': false,
      'document_kind': 'residential lease',
      // A misbehaving model returning data anyway — all of it must drop:
      'personal_info': {
        'full_name': 'Leaked Name',
        'phone': '(215) 555-0000',
        'agent': {'name': 'Leaked Agent'},
      },
      'medications_current': [
        {'name': 'lamotrigine', 'dosage': '200 mg'},
      ],
      'diagnoses': [
        {'name': 'Bipolar disorder', 'icd_code': 'F31.9'},
      ],
      'health_history': 'should be dropped',
      'ect_consent': 'yes',
      'self_binding_ulysses': true,
      'other': 'should be dropped too',
    });

    expect(r.documentRelevant, isFalse);
    expect(r.documentKind, 'residential lease',
        reason: 'the kind survives so the UI can explain the rejection');
    expect(r.personalInfo.fullName, isNull);
    expect(r.personalInfo.phone, isNull);
    expect(r.personalInfo.agent, isNull);
    expect(r.medicationsCurrent, isEmpty);
    expect(r.diagnoses, isEmpty);
    expect(r.healthHistory, isNull);
    expect(r.ectConsent, isNull);
    expect(r.selfBindingUlysses, isNull);
    expect(r.other, isNull);
    expect(r.isEmpty, isTrue);
  });

  test('a missing relevance flag still extracts (back-compat)', () {
    final r = DocumentExtractionResult.fromJson({
      'health_history': 'kept',
    });
    expect(r.documentRelevant, isTrue);
    expect(r.healthHistory, 'kept');
  });

  test('document_relevant=true extracts normally', () {
    final r = DocumentExtractionResult.fromJson({
      'document_relevant': true,
      'personal_info': {'full_name': 'Jane Q. Declarant'},
    });
    expect(r.documentRelevant, isTrue);
    expect(r.personalInfo.fullName, 'Jane Q. Declarant');
  });
}
