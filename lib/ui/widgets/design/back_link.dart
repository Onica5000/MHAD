import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/utils/nav_utils.dart';

/// The ONE back affordance for pages below the top level (2026-11 overhaul:
/// pages used four — a Material app bar on 11 screens, "‹ Back", "‹ Wizard",
/// "← Back"). A primary "‹ Back" link (or "‹ Back to …" a named page) pinned above
/// the page, with a 48px tap target.
///
/// Never a dead end: it pops when there is a page to pop to, otherwise it
/// goes Home ([safeBack]) — pages opened from the sidebar, the More sheet or
/// a shared link have nothing to pop.
class BackLink extends StatelessWidget {
  /// Visible label; defaults to "Back".
  final String? label;

  /// Overrides the default [safeBack] (e.g. a flow that saves first).
  final VoidCallback? onTap;

  /// Optional widget on the right (a status pill, an action).
  final Widget? trailing;

  /// False while going back isn't possible (e.g. mid-processing): the link
  /// shows but can't be activated.
  final bool enabled;

  const BackLink({
    this.label,
    this.onTap,
    this.trailing,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return WizardHeader(
      backLabel: label,
      onBack: !enabled ? null : onTap ?? () => safeBack(context),
      actionLabel: '',
      right: trailing,
    );
  }
}
