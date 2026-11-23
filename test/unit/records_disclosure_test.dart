import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/domain/model/records_disclosure.dart';

/// One format for the three records answers (who may, who must not, other
/// limits). Autofill used to return one untagged text, which always landed
/// in "Other limitations" — or ran on inside the last filled block.
void main() {
  test('three blocks survive a round trip', () {
    const r = RecordsDisclosure(
      authorized: 'My agent.\nMy therapist.',
      notAuthorized: 'My employer.',
      otherLimits: 'Only the last two years.',
    );
    final back = RecordsDisclosure.parse(r.serialize());
    expect(back.authorized, r.authorized);
    expect(back.notAuthorized, r.notAuthorized);
    expect(back.otherLimits, r.otherLimits);
  });

  test('the saved text is unchanged from before (PDF, FHIR, review read it)', () {
    expect(
        const RecordsDisclosure(authorized: 'my agent', notAuthorized: 'my ex')
            .serialize(),
        'Authorized to receive my records: my agent\n\n'
        'Not authorized to receive my records: my ex');
  });

  test('text without a label is kept as other limits, never dropped', () {
    expect(RecordsDisclosure.parse('Share nothing.').otherLimits,
        'Share nothing.');
    final r = RecordsDisclosure.parse(
        'Old free text.\n\nAuthorized to receive my records: my agent');
    expect(r.authorized, 'my agent');
    expect(r.otherLimits, 'Old free text.',
        reason: 'text before the first label used to be lost on save');
  });

  test('append adds to the right block', () {
    final r = RecordsDisclosure.parse(
            'Authorized to receive my records: my agent')
        .append(notAuthorized: 'my employer', authorized: 'my sister');
    expect(r.authorized, 'my agent\nmy sister');
    expect(r.notAuthorized, 'my employer');
  });

  test('autofill asks for who may / who must not separately', () {
    final prompt = DocumentExtractor.promptFor('combined');
    expect(prompt, contains('records_authorized\n'));
    expect(prompt, contains('records_not_authorized\n'));
  });
}
