import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

/// "Make it legal — with a pen." — the prototype `ScrSign` print-and-sign
/// instructions screen (mobile.jsx::ScrSign L884-980), adopted per user
/// decision (2026-06-02) as the canonical sign step.
///
/// **Behavioral change from the prior witness-entry form.** This step no
/// longer captures witness names / phones / addresses in the app. Under
/// PA Act 194 the directive is only valid when the principal and two
/// qualified witnesses sign the *same paper document*, together — so the
/// signing happens on paper, not in the app. The witnesses' names get
/// written by the witnesses themselves on the printed copy.
///
/// What this step does:
///   1. Renders editorial step-by-step instructions for how to sign on
///      paper (print packet → gather two qualified witnesses → everyone
///      signs together).
///   2. On `validateAndSave`, stamps the directive's `executionDate` to
///      today if not already set, so downstream views (Done screen,
///      "Signed in effect" status pills) flip from draft to complete.
///   3. Offers a "Download signing packet (PDF)" CTA that jumps to the
///      Export screen so the user can print.
///
/// The underlying `Witnesses` table stays in the schema for backward
/// compatibility with PDF generation paths that still reference it; any
/// rows previously created stay on disk untouched.
class ExecutionStep extends ConsumerStatefulWidget {
  final int directiveId;
  final FormType formType;
  final bool embedded;
  const ExecutionStep({
    required this.directiveId,
    required this.formType,
    this.embedded = false,
    super.key,
  });

  @override
  ConsumerState<ExecutionStep> createState() => _ExecutionStepState();
}

class _ExecutionStepState extends ConsumerState<ExecutionStep>
    with WizardStepMixin {
  @override
  Future<bool> validateAndSave() async {
    // Stamp execution date (today) if not yet set. No witness fields to
    // validate — those are captured on the printed paper, not in-app.
    final repo = ref.read(directiveRepositoryProvider);
    final directive = await repo.getDirectiveById(widget.directiveId);
    if (directive == null) return true;
    if (directive.executionDate == null) {
      await repo.setExecutionDate(
          widget.directiveId, DateTime.now().millisecondsSinceEpoch);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final warnBg =
        dark ? SemanticColors.warningBgDark : SemanticColors.warningBgLight;
    final warnBorder = dark
        ? SemanticColors.warningBorderDark
        : SemanticColors.warningBorderLight;
    final warnText = dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight;

    return ListView(
      padding: widget.embedded
          ? const EdgeInsets.symmetric(horizontal: 4)
          : const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        const WizardHelpButton(
          helpText:
              'Per 20 Pa.C.S. § 5821 / § 5832, a Mental Health Advance '
              'Directive must be signed on paper by you and two qualified '
              'witnesses, all present at the same time. The app cannot '
              "witness it for you — this step walks you through what to do.",
          stepId: 'execution',
        ),
        const SizedBox(height: 8),
        const SectionLabel('Final step · on paper'),
        const EditorialHeading(
          text: 'Make it legal — with a pen.',
          size: 32,
        ),
        const SizedBox(height: 6),
        Text(
          "Pennsylvania law requires a real signature on paper. We can't "
          "witness it for you — but here's exactly what to do.",
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            color: p.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        // Why not sign in the app — info pill.
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: p.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: p.textMuted,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: 'Why not sign in the app? ',
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                          text:
                              'Under Act 194 the directive is only valid '
                              'when you and two qualified witnesses sign '
                              'the '),
                      TextSpan(
                        text: 'same paper document',
                        style: TextStyle(
                          color: p.text,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const TextSpan(
                          text:
                              ", together. A tap-to-sign wouldn't hold up."),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // A3 / F19: reassure that any correctly-executed document is valid —
        // the PA forms are recommended, not mandatory; content controls.
        Text(
          'You don’t have to use a specific form. Pennsylvania’s '
          'official forms are recommended, not required — what makes your '
          'directive valid is its content and being signed and witnessed '
          'correctly. If a facility hands you a different form, this one '
          'still counts.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            color: p.textMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 22),
        const _SignStep(
          n: 1,
          title: 'Print the packet',
          body: 'Print the PDF we just made. It already has signature '
              'lines for you and two witnesses.',
        ),
        const _SignStep(
          n: 2,
          title: 'Gather two qualified witnesses',
          body: 'Both must be 18 or older and in the room with you when '
              'you sign. (Who can’t witness is below.)',
        ),
        const _SignStep(
          n: 3,
          title: 'Everyone signs, same place, same time',
          body: 'Sign and date the witness page in front of both '
              'witnesses. They sign right after you, while you watch.',
          last: true,
        ),
        const SizedBox(height: 8),
        // Witness eligibility warning.
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: warnBg,
            border: Border.all(color: warnBorder),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 16, color: warnText),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      color: warnText,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(text: 'A witness '),
                      const TextSpan(
                        text: 'cannot',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(
                        text: ' be your agent or alternate agent, your mental '
                            'health care provider, or an employee of the '
                            'facility where you receive treatment — unless '
                            'they are related to you by blood, marriage, or '
                            'adoption.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionLabel('In your packet'),
        const SizedBox(height: 8),
        const _PacketRow(
          icon: Icons.description_outlined,
          title: 'Your completed MHAD',
          sub: 'PDF · PA Act 194 format',
        ),
        const SizedBox(height: 8),
        const _PacketRow(
          icon: Icons.draw_outlined,
          title: 'Signature & witness page',
          sub: 'Pre-filled with your name and the date lines',
        ),
        const SizedBox(height: 8),
        const _PacketRow(
          icon: Icons.people_outlined,
          title: 'Witness eligibility guide',
          sub: "One page — who can and can't sign",
        ),
        const SizedBox(height: 8),
        const _PacketRow(
          icon: Icons.checklist_outlined,
          title: 'What to do after signing',
          sub: 'Who to give copies to, how to distribute',
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.exportRoute(widget.directiveId)),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Preview signing packet'),
            style: FilledButton.styleFrom(
              minimumSize:
                  const Size.fromHeight(DesignTokens.buttonHeightLg),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(DesignTokens.buttonRadius),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Validity status (artboard WebSign) — the generated PDF is NOT a
        // legal document until it's printed and wet-signed by the principal
        // plus two qualified witnesses.
        Center(
          child: Text(
            'NOT YET VALID · BECOMES LEGAL ONCE SIGNED ON PAPER '
            'BY YOU + 2 WITNESSES',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontFamilyFallback: const [
                'Consolas',
                'Menlo',
                'Courier New',
                'monospace',
              ],
              fontSize: 9.5,
              letterSpacing: 0.6,
              height: 1.4,
              color: p.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

/// One row of the numbered "how to sign" timeline. Italic serif numeral
/// in a primary-filled circle + bold step title + body. Connector line
/// painted on all but the last row, matching prototype `ScrSign` L887-902.
class _SignStep extends StatelessWidget {
  final int n;
  final String title;
  final String body;
  final bool last;
  const _SignStep({
    required this.n,
    required this.title,
    required this.body,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numeral circle + connector
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: p.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontFamilyFallback: const ['Georgia', 'serif'],
                    fontStyle: FontStyle.italic,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: p.onPrimary,
                  ),
                ),
              ),
              if (!last)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: p.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    body,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      color: p.textMuted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PacketRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  const _PacketRow({
    required this.icon,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: p.primary),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
