import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/utils/date_format.dart';
import 'package:mhad/utils/debouncer.dart';

void main() {
  group('ageInYears / isAdult', () {
    final asOf = DateTime(2026, 6, 23);
    test('exact 18th birthday today is adult', () {
      expect(ageInYears(DateTime(2008, 6, 23), asOf: asOf), 18);
      expect(isAdult(DateTime(2008, 6, 23), asOf: asOf), isTrue);
    });
    test('day before 18th birthday is not adult', () {
      expect(ageInYears(DateTime(2008, 6, 24), asOf: asOf), 17);
      expect(isAdult(DateTime(2008, 6, 24), asOf: asOf), isFalse);
    });
    test('clearly adult', () {
      expect(isAdult(DateTime(1980, 1, 1), asOf: asOf), isTrue);
    });
  });

  group('relativeTime', () {
    final now = DateTime(2026, 6, 23, 12, 0, 0);
    test('just now', () {
      expect(relativeTime(now.subtract(const Duration(seconds: 5)), asOf: now),
          'just now');
    });
    test('minutes (plural)', () {
      expect(relativeTime(now.subtract(const Duration(minutes: 5)), asOf: now),
          '5 mins ago');
    });
    test('minute (singular)', () {
      expect(relativeTime(now.subtract(const Duration(minutes: 1)), asOf: now),
          '1 min ago');
    });
    test('hours', () {
      expect(relativeTime(now.subtract(const Duration(hours: 3)), asOf: now),
          '3 hours ago');
    });
    test('days', () {
      expect(relativeTime(now.subtract(const Duration(days: 2)), asOf: now),
          '2 days ago');
    });
    test('older than a week falls back to a short date', () {
      expect(relativeTime(DateTime(2026, 1, 5), asOf: now), 'Jan 5');
    });
  });

  group('consentLabel', () {
    test('known values', () {
      expect(consentLabel(consentYes), 'consented');
      expect(consentLabel(consentNo), 'refused');
      expect(consentLabel(consentAgentDecides), 'agent decides');
      expect(consentLabel('conditional:only if X'), 'conditional (see form)');
    });
    test('unset and unknown never echo raw value', () {
      expect(consentLabel(null), 'not set');
      expect(consentLabel(''), 'not set');
      expect(consentLabel('weird raw PII value'), 'set (see form)');
    });
    test('consentLabelOrNull returns null for unset/unknown', () {
      expect(consentLabelOrNull(null), isNull);
      expect(consentLabelOrNull('weird'), isNull);
      expect(consentLabelOrNull(consentYes), 'consented');
    });
  });

  group('isLikelyGeminiKey', () {
    test('accepts a plausible AIza key', () {
      expect(isLikelyGeminiKey('AIza${'a' * 35}'), isTrue);
    });
    test('rejects wrong prefix, too short, or whitespace', () {
      expect(isLikelyGeminiKey('sk-${'a' * 40}'), isFalse);
      expect(isLikelyGeminiKey('AIza123'), isFalse);
      expect(isLikelyGeminiKey('AIza ${'a' * 40}'), isFalse);
    });
  });

  group('Debouncer', () {
    test('coalesces rapid calls into one', () async {
      final d = Debouncer(delay: const Duration(milliseconds: 30));
      var count = 0;
      d.run(() => count++);
      d.run(() => count++);
      d.run(() => count++);
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(count, 1);
    });
    test('cancel prevents the pending action', () async {
      final d = Debouncer(delay: const Duration(milliseconds: 30));
      var fired = false;
      d.run(() => fired = true);
      d.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(fired, isFalse);
    });
  });
}
