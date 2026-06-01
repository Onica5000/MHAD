import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/steps/execution_step.dart';
import 'package:mhad/ui/wizard/steps/review_step.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

/// Merged step 09: "Almost there." Review the summary, then sign and date.
///
/// Renders [ReviewStep] and [ExecutionStep] as two tabs. validateAndSave
/// forwards to both — the review step is a no-op save, the execution step
/// stamps the execution date and saves witnesses.
class ReviewAndSignStep extends ConsumerStatefulWidget {
  final int directiveId;
  final FormType formType;
  const ReviewAndSignStep({
    required this.directiveId,
    required this.formType,
    super.key,
  });

  @override
  ConsumerState<ReviewAndSignStep> createState() => _ReviewAndSignStepState();
}

class _ReviewAndSignStepState extends ConsumerState<ReviewAndSignStep>
    with WizardStepMixin, SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  final _reviewKey = GlobalKey<State<ReviewStep>>();
  final _executionKey = GlobalKey<State<ExecutionStep>>();

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Future<bool> validateAndSave() async {
    bool ok = true;
    for (final k in [_reviewKey, _executionKey]) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Derived from FormType.steps so the count stays accurate as
              // the wizard structure evolves (Phase 3 → 11 / 9 / 6 steps).
              SectionLabel(
                'Step ${widget.formType.steps.length} of '
                '${widget.formType.steps.length} · finalize',
              ),
              const EditorialHeading(text: 'Almost there.', size: 36),
              const SizedBox(height: 4),
              Text(
                'Look over the summary, then sign in front of two witnesses.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: p.textMuted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabs,
          labelColor: p.primary,
          unselectedLabelColor: p.textMuted,
          indicatorColor: p.primary,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
          tabs: const [
            Tab(text: 'Review'),
            Tab(text: 'Sign & witnesses'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              ReviewStep(
                key: _reviewKey,
                directiveId: widget.directiveId,
                formType: widget.formType,
              ),
              ExecutionStep(
                key: _executionKey,
                directiveId: widget.directiveId,
                formType: widget.formType,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
