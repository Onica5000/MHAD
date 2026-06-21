import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Prototype `ScrHome` active-directive hero card. Shows the most-recent
/// draft directive with form type, last-edited stamp, progress bar, and a
/// "Continue where you left off" CTA pointing at the wizard route.
///
/// Pure visual addition — does not replace the per-directive cards below.
class ActiveDirectiveHero extends StatelessWidget {
  final Directive directive;
  const ActiveDirectiveHero({required this.directive, super.key});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final formType = FormType.values.firstWhere(
      (e) => e.name == directive.formType,
      orElse: () => FormType.combined,
    );
    final totalSteps = formType.steps.length;
    final currentStep =
        (directive.lastStepIndex + 1).clamp(1, totalSteps);
    final pct = (currentStep / totalSteps).clamp(0.0, 1.0);
    final pctLabel = '${(pct * 100).round()}% complete';
    final remaining = totalSteps - currentStep;
    final remainingLabel = remaining <= 0
        ? 'Ready to review & sign'
        : '~ $remaining more step${remaining == 1 ? '' : 's'}';
    final updated = DateTime.fromMillisecondsSinceEpoch(directive.updatedAt);
    final lastEdited = _humanRelative(updated);
    final formLabel = switch (formType) {
      FormType.combined => 'Combined form',
      FormType.declaration => 'Declaration only',
      FormType.poa => 'Power of Attorney',
    };
    final headline = directive.fullName.trim().isNotEmpty
        ? '${directive.fullName.split(' ').first}’s MHAD'
        : 'Your MHAD';

    return Semantics(
      button: true,
      label:
          'Continue your $formLabel — $pctLabel, last edited $lastEdited',
      child: Material(
        color: p.primary,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              context.go(AppRoutes.wizardRoute(directive.id)),
          child: Stack(
            children: [
              // Decorative oversized italic numeral matching the prototype.
              Positioned(
                right: -10,
                top: -28,
                child: Text(
                  '$currentStep',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontFamilyFallback: const ['Georgia', 'serif'],
                    fontStyle: FontStyle.italic,
                    fontSize: 180,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    color: p.onPrimary.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: p.onPrimary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '● Draft',
                            style: TextStyle(
                              fontFamily: kSansFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: p.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Step $currentStep of $totalSteps',
                          style: TextStyle(
                            fontFamily: kMonoFamily,
                            fontFamilyFallback: const [
                              'Consolas',
                              'monospace'
                            ],
                            fontSize: 11.5,
                            color: p.onPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      headline,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: p.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$formLabel · last edited $lastEdited',
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 13,
                        height: 1.4,
                        color: p.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: pct,
                          backgroundColor:
                              p.onPrimary.withValues(alpha: 0.20),
                          valueColor:
                              AlwaysStoppedAnimation(p.onPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pctLabel,
                            style: TextStyle(
                              fontFamily: kSansFamily,
                              fontSize: 12,
                              color:
                                  p.onPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                        Text(
                          remainingLabel,
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: p.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 40,
                      child: FilledButton.icon(
                        onPressed: () => context
                            .go(AppRoutes.wizardRoute(directive.id)),
                        icon: Icon(Icons.arrow_forward,
                            size: 16, color: p.primaryDark),
                        label: Text(
                          'Continue where you left off',
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontWeight: FontWeight.w600,
                            color: p.primaryDark,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          iconAlignment: IconAlignment.end,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _humanRelative(DateTime t) {
    final diff = DateTime.now().difference(t);
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
    return DateFormat('MMM d').format(t);
  }
}
