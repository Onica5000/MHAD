// Shared date / age / relative-time helpers. Single source of truth for date
// display so labels stay consistent across the app (previously each screen
// hand-rolled its own DateFormat patterns and age math).
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mhad/l10n/l10n.dart';

/// English fallback when a caller passes no [AppLocalizations].
final _en = lookupAppLocalizations(const Locale('en'));

/// Whole years between [dob] and [asOf] (default: now).
int ageInYears(DateTime dob, {DateTime? asOf}) {
  final now = asOf ?? DateTime.now();
  var age = now.year - dob.year;
  if (now.month < dob.month ||
      (now.month == dob.month && now.day < dob.day)) {
    age--;
  }
  return age;
}

/// True when [dob] is at least 18 years before [asOf] (default: now).
bool isAdult(DateTime dob, {DateTime? asOf}) =>
    ageInYears(dob, asOf: asOf) >= 18;

/// Human "time ago" for recent timestamps; after a week falls back to a short
/// "MMM d" date. e.g. "just now", "5 mins ago", "3 hours ago", "2 days ago".
String relativeTime(DateTime t, {DateTime? asOf, AppLocalizations? l10n}) {
  final l = l10n ?? _en;
  final diff = (asOf ?? DateTime.now()).difference(t);
  if (diff.inSeconds < 60) return l.relativeJustNow;
  if (diff.inMinutes < 60) return l.relativeMinsAgo(diff.inMinutes);
  if (diff.inHours < 24) return l.relativeHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l.relativeDaysAgo(diff.inDays);
  return formatMonthDay(t);
}

// ── Named display formatters ───────────────────────────────────────────────
// Locale-aware skeletons: they follow Intl.defaultLocale (set from the app
// language in main.dart), so Spanish shows "23 de junio de 2026". Examples
// below are en_US, which matches the former fixed English patterns.
String formatMonthDay(DateTime t) => DateFormat.MMMd().format(t); // Jun 23
String formatShortDate(DateTime t) =>
    DateFormat.yMMMd().format(t); // Jun 23, 2026
String formatLongDate(DateTime t) =>
    DateFormat.yMMMMd().format(t); // June 23, 2026
String formatMonthYear(DateTime t) =>
    DateFormat.yMMMM().format(t); // June 2026
String formatTimeOfDay(DateTime t) =>
    DateFormat.jm().format(t); // 3:05 PM
String formatWeekdayMonthDay(DateTime t) =>
    '${DateFormat.EEEE().format(t)} · ${DateFormat.MMMMd().format(t)}'; // Tuesday · June 23
