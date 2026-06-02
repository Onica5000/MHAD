import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/reminders/reminder_sheets.dart';
import 'package:mhad/ui/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-app reminder scheduler.
///
/// Per user decision (2026-06-02): the renewal nudge and quarterly
/// check-in sheets fire on the next app launch when due — no OS
/// notifications plugin, no server. State is tracked per directive +
/// reminder type in SharedPreferences with simple "last-shown" timestamps
/// so each sheet fires at most once per due window.
///
/// Trigger policy:
///   - **Renewal**  — fires when `expirationDate - now ≤ 28 days`
///                    AND last shown ≥ 7 days ago.
///   - **Check-in** — fires when `now - updatedAt ≥ 90 days`
///                    AND last shown ≥ 90 days ago.
///
/// Priority: renewal beats check-in if both are due; we never show two
/// modals stacked on launch. The "lower" reminder rolls into the next
/// launch.
class ReminderScheduler {
  ReminderScheduler._();

  static const _kRenewLastShown = 'reminder_renew_last_shown_';
  static const _kCheckInLastShown = 'reminder_checkin_last_shown_';

  /// Window thresholds in days.
  static const _renewWindow = 28;
  static const _checkInWindow = 90;

  /// Re-show cooldowns (so we don't nag every single launch once due).
  static const _renewCooldown = Duration(days: 7);
  static const _checkInCooldown = Duration(days: 90);

  /// Walk every completed directive, find the most urgent due reminder,
  /// and present its sheet. Called from `HomeScreen.initState` after the
  /// onboarding / draft-recovery flow has cleared.
  ///
  /// Silent no-op when:
  ///   - there are no completed directives
  ///   - none of them have a renewal or check-in window open
  ///   - the relevant cooldown window has not elapsed since last shown
  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (!context.mounted) return;
    final repo = ref.read(directiveRepositoryProvider);
    final all = await repo.getAllDirectives();
    if (!context.mounted) return;
    final completed = all
        .where((d) => d.status == DirectiveStatus.complete.name)
        .toList();
    if (completed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    final now = DateTime.now();

    // Renewal first — sort by closest expiration so the most urgent
    // directive's sheet shows.
    final renewCandidates = completed.where((d) {
      final exp = d.expirationDate;
      if (exp == null) return false;
      final daysLeft = DateTime.fromMillisecondsSinceEpoch(exp)
          .difference(now)
          .inDays;
      return daysLeft <= _renewWindow;
    }).toList()
      ..sort((a, b) =>
          (a.expirationDate ?? 0).compareTo(b.expirationDate ?? 0));
    for (final d in renewCandidates) {
      if (_isCooledDown(
          prefs.getInt('$_kRenewLastShown${d.id}'), _renewCooldown, now)) {
        await prefs.setInt(
            '$_kRenewLastShown${d.id}', now.millisecondsSinceEpoch);
        if (!context.mounted) return;
        await showRenewalNudge(
          context,
          directive: d,
          onStartRenew: () {
            // Reuse the wizard route for now; a dedicated "quick renew"
            // pre-fill flow would be follow-up scope.
            context.go(AppRoutes.wizardRoute(d.id));
          },
        );
        return; // Only one modal per launch.
      }
    }

    // Check-in — sort by furthest-out updatedAt (the directive that
    // hasn't been touched longest gets the prompt).
    final checkInCandidates = completed.where((d) {
      final daysSinceEdit = now
          .difference(DateTime.fromMillisecondsSinceEpoch(d.updatedAt))
          .inDays;
      return daysSinceEdit >= _checkInWindow;
    }).toList()
      ..sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    for (final d in checkInCandidates) {
      if (_isCooledDown(prefs.getInt('$_kCheckInLastShown${d.id}'),
          _checkInCooldown, now)) {
        await prefs.setInt(
            '$_kCheckInLastShown${d.id}', now.millisecondsSinceEpoch);
        if (!context.mounted) return;
        await showQuarterlyCheckIn(
          context,
          directive: d,
          onEdit: () => context.push(AppRoutes.wizardRoute(d.id)),
        );
        return;
      }
    }
  }

  static bool _isCooledDown(int? lastShownMs, Duration cooldown, DateTime now) {
    if (lastShownMs == null) return true;
    final last = DateTime.fromMillisecondsSinceEpoch(lastShownMs);
    return now.difference(last) >= cooldown;
  }
}
