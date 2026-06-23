// Shared date / age / relative-time helpers. Single source of truth for date
// display so labels stay consistent across the app (previously each screen
// hand-rolled its own DateFormat patterns and age math).
import 'package:intl/intl.dart';

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
String relativeTime(DateTime t, {DateTime? asOf}) {
  final diff = (asOf ?? DateTime.now()).difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
  return formatMonthDay(t);
}

// ── Named display formatters ───────────────────────────────────────────────
String formatMonthDay(DateTime t) => DateFormat('MMM d').format(t); // Jun 23
String formatShortDate(DateTime t) =>
    DateFormat('MMM d, y').format(t); // Jun 23, 2026
String formatLongDate(DateTime t) =>
    DateFormat('MMMM d, y').format(t); // June 23, 2026
String formatMonthYear(DateTime t) =>
    DateFormat('MMMM y').format(t); // June 2026
String formatTimeOfDay(DateTime t) =>
    DateFormat('h:mm a').format(t); // 3:05 PM
String formatWeekdayMonthDay(DateTime t) =>
    DateFormat('EEEE · MMMM d').format(t); // Tuesday · June 23
