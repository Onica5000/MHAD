import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Quarterly check-in and 2-year renewal nudge sheets.
///
/// Both surface a soft modal bottom sheet over a dimmed backdrop, mirroring
/// the prototypes `ScrCheckIn` (mobile-extra.jsx L412-493) and `ScrRenew`
/// (L324-407). They are intentionally informational — neither blocks the
/// user nor mutates state. The CTA callbacks belong to the caller (so this
/// file stays free of routing concerns).
///
/// Trigger policy lives in `services/reminder_scheduler.dart`, which fires
/// these on app launch: `showRenewalNudge` when a directive is ≤28 days from
/// `expirationDate` (7-day cooldown), and `showQuarterlyCheckIn` when ≥90 days
/// since `updatedAt` (90-day cooldown); renewal takes priority and at most one
/// fires per launch. They are also reachable from the directive card overflow
/// menu. (In-app on launch only — no OS notification scheduling, per the
/// 2026-06-02 decision in PROTOTYPE_AUDIT.)

/// Renewal nudge — "Time to renew, [Name]. / Expires in N days."
/// Mirrors prototype `ScrRenew`.
Future<void> showRenewalNudge(
  BuildContext context, {
  required Directive directive,
  required VoidCallback onStartRenew,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _RenewSheet(
      directive: directive,
      onStartRenew: onStartRenew,
    ),
  );
}

/// Quarterly check-in — "Anything changed?" Soft prompt with no renewal
/// pressure. Mirrors prototype `ScrCheckIn`.
Future<void> showQuarterlyCheckIn(
  BuildContext context, {
  required Directive directive,
  required VoidCallback onEdit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _CheckInSheet(
      directive: directive,
      onEdit: onEdit,
    ),
  );
}

// ─── Renew sheet ─────────────────────────────────────────────────────────

class _RenewSheet extends StatelessWidget {
  final Directive directive;
  final VoidCallback onStartRenew;
  const _RenewSheet({
    required this.directive,
    required this.onStartRenew,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final warnBg = dark
        ? SemanticColors.warningBgDark
        : SemanticColors.warningBgLight;
    final warnText = dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight;

    final firstName = directive.fullName.trim().isEmpty
        ? null
        : directive.fullName.trim().split(RegExp(r'\s+')).first;
    final exp = directive.expirationDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!);
    final daysLeft = exp?.difference(DateTime.now()).inDays;
    final dayLabel = daysLeft == null
        ? 'soon'
        : (daysLeft <= 0
            ? 'today'
            : 'in $daysLeft ${daysLeft == 1 ? 'day' : 'days'}');
    final expDateLabel = exp == null ? '—' : DateFormat('MMMM d, y').format(exp);

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.sheetRadius)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: warnBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child:
                        Icon(Icons.event_outlined, size: 26, color: warnText),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(
                          '● Expires $dayLabel',
                          style: TextStyle(color: warnText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          firstName == null
                              ? 'Time to renew.'
                              : 'Time to renew, $firstName.',
                          style: TextStyle(
                            fontFamily: 'Instrument Serif',
                            fontFamilyFallback: const ['Georgia', 'serif'],
                            fontStyle: FontStyle.italic,
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.5,
                            height: 1.05,
                            color: p.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              height: 1.5,
                              color: p.textMuted,
                            ),
                            children: [
                              const TextSpan(
                                  text:
                                      'PA directives expire after 2 years. Yours runs out on '),
                              TextSpan(
                                text: expDateLabel,
                                style: TextStyle(
                                  color: p.text,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  border: Border.all(
                      color: p.primary.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: p.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Quick renew · ~5 min',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Most people keep the same answers. We'll pre-fill all "
                      '11 sections from your current directive — tap any card '
                      'to change it, then print and sign the new copy in ink '
                      'with two witnesses.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        height: 1.5,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _RenewMetric(num: '11', label: 'sections'),
                        const SizedBox(width: 14),
                        Text('·',
                            style: TextStyle(color: p.textMuted)),
                        const SizedBox(width: 14),
                        _RenewMetric(num: 'wet-ink', label: 'signing'),
                        const SizedBox(width: 14),
                        Text('·',
                            style: TextStyle(color: p.textMuted)),
                        const SizedBox(width: 14),
                        _RenewMetric(num: '~5', label: 'min'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onStartRenew();
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Start quick renew'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                        DesignTokens.buttonHeightLg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          DesignTokens.buttonRadius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Remind me next week',
                    style: TextStyle(color: p.textMuted),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "We'll remind you again 7 days before expiration.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10.5,
                  height: 1.5,
                  color: p.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RenewMetric extends StatelessWidget {
  final String num;
  final String label;
  const _RenewMetric({required this.num, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: num,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Check-in sheet ──────────────────────────────────────────────────────

class _CheckInSheet extends StatelessWidget {
  final Directive directive;
  final VoidCallback onEdit;
  const _CheckInSheet({
    required this.directive,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    final exp = directive.expirationDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!);
    final expLabel = exp == null ? 'your renewal date' : DateFormat('MMMM y').format(exp);

    // Form-aware "common changes" prompts — agents only for forms that have
    // them; medications + facility for any clinical-preference form.
    final formType = FormType.values.firstWhere(
      (e) => e.name == directive.formType,
      orElse: () => FormType.combined,
    );

    final rows = <_CheckInRow>[];
    if (formType.hasAgentSections) {
      rows.add(const _CheckInRow(
        icon: Icons.people_alt_outlined,
        title: 'Still the right people?',
        sub: 'Agents — primary and alternate',
        stepLabel: 'Step 3',
      ));
    }
    if (formType != FormType.poa) {
      rows.add(const _CheckInRow(
        icon: Icons.medication_outlined,
        title: 'Medications up to date?',
        sub: "Current meds, ones you don't want, allergies",
        stepLabel: 'Step 7',
      ));
      rows.add(const _CheckInRow(
        icon: Icons.location_on_outlined,
        title: 'Care preferences still right?',
        sub: 'Preferred facility, room environment',
        stepLabel: 'Step 5',
      ));
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.sheetRadius)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: p.primaryTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.favorite_outline,
                        size: 26, color: p.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel(
                          '● 3-month check-in',
                          style: TextStyle(color: p.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Anything changed?',
                          style: TextStyle(
                            fontFamily: 'Instrument Serif',
                            fontFamilyFallback: const ['Georgia', 'serif'],
                            fontStyle: FontStyle.italic,
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.5,
                            height: 1.05,
                            color: p.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              height: 1.5,
                              color: p.textMuted,
                            ),
                            children: [
                              const TextSpan(
                                  text:
                                      'Your directive is still valid through '),
                              TextSpan(
                                text: expLabel,
                                style: TextStyle(
                                  color: p.text,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const TextSpan(
                                text: ' — no signing needed. Just a quick '
                                    'gut-check that it still fits your life.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (rows.isNotEmpty) ...[
                const SizedBox(height: 16),
                const SectionLabel('Common things that change'),
                ...rows,
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check, size: 17),
                  label: const Text('Still accurate — all good'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                        DesignTokens.buttonHeightLg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          DesignTokens.buttonRadius),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                  child: const Text('Edit my directive'),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "If you edit anything, you'll re-print and sign that updated "
                'copy in ink. Small changes can wait for your 2-year renewal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10.5,
                  height: 1.5,
                  color: p.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final String stepLabel;
  const _CheckInRow({
    required this.icon,
    required this.title,
    required this.sub,
    required this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: p.surface,
          border: Border.all(color: p.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: p.primaryTint,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 15, color: p.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      color: p.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$stepLabel ›',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: p.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
