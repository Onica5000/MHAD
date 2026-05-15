import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/steps/drug_trials_step.dart';
import 'package:mhad/ui/wizard/steps/ect_step.dart';
import 'package:mhad/ui/wizard/steps/experimental_studies_step.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

/// Merged wizard step that combines [EctStep], [ExperimentalStudiesStep],
/// and [DrugTrialsStep]. Matches the prototype's step 07
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
  final _ectKey = GlobalKey<State<EctStep>>();
  final _experimentalKey = GlobalKey<State<ExperimentalStudiesStep>>();
  final _drugTrialsKey = GlobalKey<State<DrugTrialsStep>>();

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
        EctStep(
          key: _ectKey,
          directiveId: widget.directiveId,
          embedded: true,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const SectionLabel('Experimental studies'),
        const SizedBox(height: 4),
        ExperimentalStudiesStep(
          key: _experimentalKey,
          directiveId: widget.directiveId,
          embedded: true,
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        const SectionLabel('Drug trials'),
        const SizedBox(height: 4),
        DrugTrialsStep(
          key: _drugTrialsKey,
          directiveId: widget.directiveId,
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
        SizedBox(height: 4, child: Container(color: p.scaffoldBackground)),
      ],
    );
  }
}
