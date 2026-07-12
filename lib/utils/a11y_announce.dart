import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Announces [message] to assistive technology (screen readers).
///
/// SnackBars are not reliably announced by screen readers on Flutter web and
/// they auto-dismiss, so outcome-critical confirmations (export finished,
/// autofill applied, data restored, draft saved) should call this alongside
/// their visual affordance (2026-07-11 UX audit A4).
void announce(BuildContext context, String message) {
  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
  );
}
