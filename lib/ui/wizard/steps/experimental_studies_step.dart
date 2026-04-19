import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/widgets/consent_option_tile.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class ExperimentalStudiesStep extends ConsumerStatefulWidget {
  const ExperimentalStudiesStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<ExperimentalStudiesStep> createState() =>
      _ExperimentalStudiesStepState();
}

class _ExperimentalStudiesStepState
    extends ConsumerState<ExperimentalStudiesStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();
  ConsentOption _consent = ConsentOption.no;
  final _conditionsCtrl = TextEditingController();
  bool _hasAgentSections = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _conditionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final directive = await repo.getDirectiveById(widget.directiveId);
    final pref = await repo.getPreferences(widget.directiveId);

    if (!mounted) return;
    setState(() {
      if (directive != null) {
        final formType = FormType.values.firstWhere(
          (e) => e.name == directive.formType,
          orElse: () => FormType.declaration,
        );
        _hasAgentSections = formType.hasAgentSections;
      }

      if (pref != null) {
        final raw = pref.experimentalConsent;
        if (raw.startsWith('conditional:')) {
          _consent = ConsentOption.conditional;
          _conditionsCtrl.text = raw.substring('conditional:'.length);
        } else {
          _consent = ConsentOption.values.firstWhere(
            (e) => e.name == raw,
            orElse: () => ConsentOption.no,
          );
        }
      }
    });
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();

    final String consentValue;
    if (_consent == ConsentOption.conditional) {
      consentValue = 'conditional:${_conditionsCtrl.text.trim()}';
    } else {
      consentValue = _consent.name;
    }

    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            experimentalConsent: Value(consentValue),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    const helpText =
        'You have the right to consent to or refuse participation in '
        'experimental research. Your preferences here will guide your care '
        'team and agent.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const SectionLabel('RESEARCH CONSENT'),
          const SizedBox(height: 6),
          Text(
            'Experimental Studies',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'State your preferences regarding participation in experimental '
            'research during mental health treatment.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: p.textMuted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          const InfoBanner(
            icon: Icons.gavel_outlined,
            variant: InfoBannerVariant.warning,
            text: 'Under PA Act 194, your agent cannot consent to '
                'experimental research unless you explicitly authorize it here.',
          ),
          const SizedBox(height: 8),
          WizardHelpButton(helpText: helpText, stepId: 'experimentalStudies'),
          const SizedBox(height: 16),
          ConsentOptionTile(
            icon: Icons.check_circle_outline,
            title: 'I consent to experimental studies',
            description:
                'I am willing to participate in research studies during treatment.',
            selected: _consent == ConsentOption.yes,
            onTap: () => setState(() => _consent = ConsentOption.yes),
          ),
          ConsentOptionTile(
            icon: Icons.block,
            title: 'I do not consent',
            description: 'I refuse participation in experimental studies.',
            selected: _consent == ConsentOption.no,
            onTap: () => setState(() => _consent = ConsentOption.no),
          ),
          ConsentOptionTile(
            icon: Icons.rule,
            title: 'I consent under specific conditions',
            description: 'Describe the conditions in the box below.',
            selected: _consent == ConsentOption.conditional,
            onTap: () =>
                setState(() => _consent = ConsentOption.conditional),
          ),
          if (_hasAgentSections)
            ConsentOptionTile(
              icon: Icons.person_outline,
              title: 'My agent will decide',
              description:
                  'Authorize your agent to consent or refuse on your behalf.',
              selected: _consent == ConsentOption.agentDecides,
              onTap: () =>
                  setState(() => _consent = ConsentOption.agentDecides),
            ),
          if (_consent == ConsentOption.conditional) ...[
            const SizedBox(height: 6),
            TextFormField(
              controller: _conditionsCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Conditions',
                hintText:
                    'e.g., only non-invasive studies approved by my agent',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ],
        ],
      ),
    );
  }
}
