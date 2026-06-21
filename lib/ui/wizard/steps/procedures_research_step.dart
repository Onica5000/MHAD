import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/steps/consent_choice_step.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// Merged wizard step that combines the three [ConsentChoiceStep] decisions
/// (ECT, experimental studies, drug trials). Matches the prototype's step 07
/// "Procedures & research" — the three treatments PA Act 194 calls out
/// as requiring explicit, documented consent.
class ProceduresResearchStep extends ConsumerStatefulWidget {
  final int directiveId;
  const ProceduresResearchStep({required this.directiveId, super.key});

  @override
  ConsumerState<ProceduresResearchStep> createState() =>
      _ProceduresResearchStepState();
}

class _ProceduresResearchStepState
    extends ConsumerState<ProceduresResearchStep> with WizardStepMixin {
  final _ectKey = GlobalKey<State<ConsentChoiceStep>>();
  final _experimentalKey = GlobalKey<State<ConsentChoiceStep>>();
  final _drugTrialsKey = GlobalKey<State<ConsentChoiceStep>>();

  @override
  Future<bool> validateAndSave() async {
    bool ok = true;
    for (final k in [_ectKey, _experimentalKey, _drugTrialsKey]) {
      final s = k.currentState;
      if (s is WizardStepMixin) {
        ok = await (s as WizardStepMixin).validateAndSave() && ok;
      }
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionLabel('Electroconvulsive therapy (ECT)'),
        const SizedBox(height: 4),
        ConsentChoiceStep(
          key: _ectKey,
          directiveId: widget.directiveId,
          config: ConsentChoiceConfig.ect,
          embedded: true,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const SectionLabel('Experimental studies'),
        const SizedBox(height: 4),
        ConsentChoiceStep(
          key: _experimentalKey,
          directiveId: widget.directiveId,
          config: ConsentChoiceConfig.experimental,
          embedded: true,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const SectionLabel('Drug trials'),
        const SizedBox(height: 4),
        ConsentChoiceStep(
          key: _drugTrialsKey,
          directiveId: widget.directiveId,
          config: ConsentChoiceConfig.drugTrials,
          embedded: true,
        ),
        const SizedBox(height: 24),
        InfoBanner(
          icon: Icons.info_outline,
          text:
              'Why these three? PA Act 194 specifically calls out ECT, '
              'experimental studies, and drug trials as requiring documented '
              'consent. Other treatments fall under your general preferences.',
          variant: InfoBannerVariant.info,
        ),
        const SizedBox(height: 12),
        // FACTUAL_ANALYSIS C4 / F8 + F9 — Per § 5808 / § 5836(c), an agent
        // CANNOT consent to ECT, experimental studies, or drug trials unless
        // you expressly grant that power in the directive. Without an
        // express grant, only YOU can consent (or refuse).
        InfoBanner(
          icon: Icons.warning_amber_rounded,
          text:
              'Agent authority for these three: your agent cannot consent to '
              'ECT, experimental studies, or drug trials on your behalf '
              'unless you expressly grant that power below. Without an '
              'express grant, only you can consent — or these will not be '
              'available during incapacity.',
          variant: InfoBannerVariant.warning,
        ),
        const SizedBox(height: 12),
        // FACTUAL_ANALYSIS C4 / F10 — Hard statutory exclusions per § 5804
        // (and § 5808): "Mental health care does not include psychosurgery
        // or termination of parental rights." An agent may NEVER consent to
        // these. Rendered as read-only so users understand the limit.
        _NeverAuthorizedCard(),
        SizedBox(height: 4, child: Container(color: p.scaffoldBackground)),
      ],
    );
  }
}

/// Read-only "Never authorized under PA Act 194" card. Surfaces the two
/// statutory hard exclusions (§ 5804) so users understand that no clause
/// they write — and no agent decision — can authorize them.
class _NeverAuthorizedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark
        ? SemanticColors.errorBgDark
        : SemanticColors.errorBgLight;
    final border = dark
        ? SemanticColors.errorBorderDark
        : SemanticColors.errorBorderLight;
    final fg = dark
        ? SemanticColors.errorAccentDark
        : SemanticColors.errorAccentLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.block, size: 18, color: fg),
              const SizedBox(width: 8),
              Text(
                'Never authorized under PA Act 194',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'By statute (20 Pa.C.S. § 5804), mental health care under this '
            'directive does NOT include the following — no clause in this '
            'document and no decision by your agent can authorize them:',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 12.5,
              color: fg,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 8),
          _NeverItem(
              text: 'Psychosurgery (brain surgery meant to change mood or '
                  'behavior)',
              fg: fg,
              palette: p),
          _NeverItem(text: 'Termination of parental rights', fg: fg, palette: p),
        ],
      ),
    );
  }
}

class _NeverItem extends StatelessWidget {
  final String text;
  final Color fg;
  final MhadPalette palette;
  const _NeverItem({required this.text, required this.fg, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
