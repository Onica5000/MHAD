import 'dart:convert';

/// Builds an iCalendar (.ics, RFC 5545) file that puts the directive's
/// renewal dates on the user's own calendar.
///
/// Why this exists: the in-app renewal nudge (`reminder_scheduler.dart`) only
/// fires when the app is opened, and on the web (Public Mode, memory-only)
/// the directive is gone once the tab closes, so a web user gets no warning
/// that the 2-year directive is about to lapse. A calendar file is the
/// local-first way to fix that: it is generated on the device, handed to the
/// OS share sheet / download, and nothing is sent anywhere.
///
/// The file holds two all-day events, each with a 9 AM alarm:
///   1. "renew soon": [renewWindowDays] before expiry (same window as the
///      in-app nudge), and
///   2. "expires today": on the expiry date itself.
///
/// No name or other personal detail goes into the file: the caller passes
/// the (localized) titles and description, which should stay generic,
/// because calendars are often shared or synced to work accounts.
class CalendarReminderService {
  CalendarReminderService._();

  /// Returns the .ics text (CRLF line endings, lines folded at 75 octets).
  ///
  /// [expiration] is the directive's expiry; only its calendar date is used.
  /// [now] stamps DTSTAMP. [uidSeed] should be stable per directive (e.g.
  /// its id) so re-importing updates the same events instead of duplicating.
  static String buildRenewalIcs({
    required DateTime expiration,
    required DateTime now,
    required String uidSeed,
    required int renewWindowDays,
    required String renewSoonTitle,
    required String expiresTodayTitle,
    required String description,
  }) {
    final expiryDay =
        DateTime.utc(expiration.year, expiration.month, expiration.day);
    final renewDay = expiryDay.subtract(Duration(days: renewWindowDays));
    final stamp = _utcStamp(now.toUtc());

    final lines = <String>[
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//MHAD//PA Mental Health Advance Directive//EN',
      'CALSCALE:GREGORIAN',
      'METHOD:PUBLISH',
      ..._event(
        uid: 'mhad-renew-$uidSeed@onica5000.github.io',
        stamp: stamp,
        day: renewDay,
        title: renewSoonTitle,
        description: description,
      ),
      ..._event(
        uid: 'mhad-expires-$uidSeed@onica5000.github.io',
        stamp: stamp,
        day: expiryDay,
        title: expiresTodayTitle,
        description: description,
      ),
      'END:VCALENDAR',
    ];
    return '${lines.map(_fold).join('\r\n')}\r\n';
  }

  static List<String> _event({
    required String uid,
    required String stamp,
    required DateTime day,
    required String title,
    required String description,
  }) =>
      [
        'BEGIN:VEVENT',
        'UID:$uid',
        'DTSTAMP:$stamp',
        'DTSTART;VALUE=DATE:${_date(day)}',
        'DTEND;VALUE=DATE:${_date(day.add(const Duration(days: 1)))}',
        'SUMMARY:${escapeText(title)}',
        'DESCRIPTION:${escapeText(description)}',
        'TRANSP:TRANSPARENT',
        'BEGIN:VALARM',
        'ACTION:DISPLAY',
        'DESCRIPTION:${escapeText(title)}',
        // All-day events start at local midnight; +9h = 9 AM that day.
        'TRIGGER:PT9H',
        'END:VALARM',
        'END:VEVENT',
      ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}${_two(d.month)}${_two(d.day)}';

  static String _utcStamp(DateTime u) =>
      '${_date(u)}T${_two(u.hour)}${_two(u.minute)}${_two(u.second)}Z';

  /// RFC 5545 §3.3.11 TEXT escaping.
  static String escapeText(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\r\n', r'\n')
      .replaceAll('\n', r'\n');

  /// RFC 5545 §3.1 line folding: at most 75 octets per line, continuation
  /// lines start with a single space. Never splits a UTF-8 character.
  static String _fold(String line) {
    if (utf8.encode(line).length <= 75) return line;
    final out = StringBuffer();
    var count = 0;
    var limit = 75;
    for (final rune in line.runes) {
      final ch = String.fromCharCode(rune);
      final len = utf8.encode(ch).length;
      if (count + len > limit) {
        out.write('\r\n ');
        count = 0;
        limit = 74; // the leading space counts toward the 75
      }
      out.write(ch);
      count += len;
    }
    return out.toString();
  }
}
