import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/export/pdf/questionnaire_pdf.dart';

void main() {
  // Guards that the printable questionnaire renders — catches missing-glyph
  // exceptions (§, em-dashes, curly quotes) and layout errors that only surface
  // at doc.save().
  test('audio questionnaire PDF builds to valid, non-empty bytes', () async {
    final bytes = await buildAudioQuestionnairePdf();
    expect(bytes.lengthInBytes, greaterThan(1000));
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });
}
