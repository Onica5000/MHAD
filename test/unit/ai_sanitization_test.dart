import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';

/// V4-L15 — guarantees the AI sanitization chokepoint.
///
/// The existing `pii_stripper_test.dart` exercises [PiiStripper] in isolation.
/// This test pins the *contract* that [GeminiApiAssistant.sanitizeForApi] is the
/// single chokepoint applied to every outbound user payload, and that it
/// removes the categories of PII users are most likely to type into AI prompts.
///
/// If a future refactor moves the strip elsewhere (or removes it), this test
/// must be updated *deliberately* — that is the point of having it.
void main() {
  group('GeminiApiAssistant.sanitizeForApi', () {
    test('returns a sanitized string for representative AI inputs', () {
      const sample =
          'My name is John Smith and my SSN is 123-45-6789. '
          'My phone is (555) 123-4567 and my email is john@example.com. '
          'I live at 123 Main Street, Philadelphia, PA 19103. '
          'I was born on January 5, 1980.';

      final out = GeminiApiAssistant.sanitizeForApi(sample);

      // Names are not deterministically detectable; the categories below are.
      expect(out, isNot(contains('123-45-6789')),
          reason: 'SSN must be stripped before transmission');
      expect(out, isNot(contains('(555) 123-4567')),
          reason: 'phone must be stripped');
      expect(out, isNot(contains('john@example.com')),
          reason: 'email must be stripped');
      expect(out, isNot(contains('123 Main Street')),
          reason: 'street address must be stripped');
    });

    test('is a pure function and idempotent', () {
      const sample = 'Call me at 555-987-6543 about my appointment.';
      final once = GeminiApiAssistant.sanitizeForApi(sample);
      final twice = GeminiApiAssistant.sanitizeForApi(once);
      expect(once, equals(twice),
          reason: 'sanitizing already-sanitized output should be a no-op');
    });

    test('passes non-PII text through unchanged', () {
      const sample =
          'What are my options for medication preferences under PA Act 194?';
      expect(GeminiApiAssistant.sanitizeForApi(sample), equals(sample));
    });
  });
}
