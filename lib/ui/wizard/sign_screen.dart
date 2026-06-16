import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/ui/wizard/steps/execution_step.dart';

/// Post-wizard, pre-summary sign-on-paper instructions screen.
///
/// Matches prototype `ScrSign` (mobile.jsx L884-981). The prototype splits
/// the original combined Review-and-Sign flow into three discrete screens:
/// ScrReview (the wizard's last step) → ScrSign (this) → ScrDone (the
/// summary celebration). This sits at route `/sign/:directiveId`.
///
/// Landing on this screen stamps the directive's executionDate so the
/// status flips from `draft` to `complete` — the user has committed to
/// the printed-and-signed workflow even if they haven't generated the PDF
/// yet. The visible content is delegated to [ExecutionStep] (which already
/// renders the prototype's 3-step timeline, witness eligibility banner,
/// and packet checklist). [ExecutionStep]'s single CTA — **Preview & download
/// packet** → `/export/:id` — opens the export screen ("Your directive, on
/// paper") to preview, download, and print the PDF packet (and grab the wallet
/// card). The old "One pen away" summary screen was removed; export is the end
/// of the flow.
///
/// "Back to review" at the top returns the user to the wizard.
class SignScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const SignScreen({required this.directiveId, super.key});

  @override
  ConsumerState<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends ConsumerState<SignScreen> {
  FormType? _formType;
  bool _stamping = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(directiveRepositoryProvider);
    final d = await repo.getDirectiveById(widget.directiveId);
    if (d == null || !mounted) return;
    // Stamp executionDate on first landing — arriving at Sign means the
    // user has accepted the "print + sign + 2 witnesses" path. Idempotent
    // when the field already carries a value.
    if (d.executionDate == null) {
      await repo.setExecutionDate(
          widget.directiveId, DateTime.now().millisecondsSinceEpoch);
    }
    if (!mounted) return;
    setState(() {
      _formType = FormType.values.firstWhere(
        (e) => e.name == d.formType,
        orElse: () => FormType.combined,
      );
      _stamping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    if (_stamping || _formType == null) {
      return Scaffold(
        backgroundColor: p.scaffoldBackground,
        body: Center(
          child: Semantics(
            label: 'Preparing signing packet',
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: Column(
        children: [
          const CrisisTopBar(compact: true),
          WizardHeader(
            backLabel: 'Back to review',
            onBack: () =>
                context.go(AppRoutes.wizardRoute(widget.directiveId)),
            // Sign isn't a wizard step — no "Save & exit" here. The empty
            // action label hides the right side of the header row.
            actionLabel: '',
          ),
          Expanded(
            child: ExecutionStep(
              directiveId: widget.directiveId,
              formType: _formType!,
            ),
          ),
        ],
      ),
    );
  }
}
