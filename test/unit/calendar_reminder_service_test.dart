import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/calendar_reminder_service.dart';

void main() {
  String build({
    String renewTitle = 'Renew your advance directive',
    String expiresTitle = 'Your advance directive expires today',
    String description = 'Open the app to start a new directive.',
  }) =>
      CalendarReminderService.buildRenewalIcs(
        expiration: DateTime(2028, 3, 15, 18, 30),
        now: DateTime.utc(2026, 11, 8, 12, 0, 5),
        uidSeed: '42',
        renewWindowDays: 28,
        renewSoonTitle: renewTitle,
        expiresTodayTitle: expiresTitle,
        description: description,
      );

  /// Undo RFC 5545 folding so assertions can look at logical lines.
  List<String> unfold(String ics) =>
      ics.replaceAll('\r\n ', '').split('\r\n');

  group('CalendarReminderService.buildRenewalIcs', () {
    test('is a well-formed calendar with two all-day events', () {
      final ics = build();
      expect(ics.startsWith('BEGIN:VCALENDAR\r\n'), isTrue);
      expect(ics.endsWith('END:VCALENDAR\r\n'), isTrue);
      // CRLF only: no bare LF anywhere.
      expect(ics.replaceAll('\r\n', '').contains('\n'), isFalse);
      final lines = unfold(ics);
      expect(lines, contains('VERSION:2.0'));
      expect(lines.where((l) => l == 'BEGIN:VEVENT').length, 2);
      expect(lines.where((l) => l == 'BEGIN:VALARM').length, 2);
      expect(lines.where((l) => l == 'DTSTAMP:20261108T120005Z').length, 2);
    });

    test('renew-soon event is the renewal window before expiry', () {
      final lines = unfold(build());
      // 2028-03-15 minus 28 days = 2028-02-16 (2028 is a leap year).
      expect(lines, contains('DTSTART;VALUE=DATE:20280216'));
      expect(lines, contains('DTEND;VALUE=DATE:20280217'));
      expect(lines, contains('DTSTART;VALUE=DATE:20280315'));
      expect(lines, contains('DTEND;VALUE=DATE:20280316'));
    });

    test('UIDs are stable per directive so a re-import updates', () {
      final a = unfold(build()).where((l) => l.startsWith('UID:')).toList();
      final b = unfold(build()).where((l) => l.startsWith('UID:')).toList();
      expect(a, b);
      expect(a.toSet().length, 2);
    });

    test('escapes TEXT special characters', () {
      final lines = unfold(build(description: 'a, b; c\\d\nnext'));
      expect(lines, contains(r'DESCRIPTION:a\, b\; c\\d\nnext'));
    });

    test('folds long lines at 75 octets without splitting characters', () {
      // Multi-byte characters straddle the fold points.
      final long = 'Renovación pendiente año ñandú ' * 6;
      final ics = build(renewTitle: '$longñ');
      for (final physical in ics.split('\r\n')) {
        expect(utf8.encode(physical).length, lessThanOrEqualTo(75));
      }
      expect(unfold(ics), contains('SUMMARY:$longñ'));
    });
  });
}
