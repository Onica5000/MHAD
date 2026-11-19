import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/back_link.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/wizard/steps/execution_step.dart';

/// Post-wizard, pre-summary sign-on-paper instructions screen.
///
/// Matches prototype `ScrSign` (mobile.jsx L884-981). The prototype splits
/// the original combined Review-and-Sign flow into three discrete screens:
/// ScrReview (the wizard's last step) → ScrSign (this) → ScrDone (the
/// summary celebration). This sits at route `/sign/:directiveId`.
///
/// Nothing is stamped here: the person dates the printed form when they sign
/// it (user decision 2026-11-18), so the signing date stays blank in the
/// app. The visible content is delegated to [ExecutionStep] (which already
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
    // No signing date is stamped here: the person dates the printed form
    // when they sign it (the official date line stays blank — reaching this
    // page is not signing). The calendar reminder asks for the day instead.
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
            label: context.l10n.signScreenPreparing,
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: Column(
        children: [
          // "Back to review" returns to the wizard (Review is its last step);
          // Sign is not a wizard step, so there is no "Save & exit" here.
          BackLink(
            label: context.l10n.signScreenBackToReview,
            onTap: () => context.go(AppRoutes.wizardRoute(widget.directiveId)),
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
