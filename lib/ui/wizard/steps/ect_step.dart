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

class EctStep extends ConsumerStatefulWidget {
  const EctStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<EctStep> createState() => _EctStepState();
}

class _EctStepState extends ConsumerState<EctStep> with WizardStepMixin {
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
        final raw = pref.ectConsent;
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
            ectConsent: Value(consentValue),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    const helpText =
        'ECT can be an effective treatment for severe depression and other '
        'conditions. Under PA law, you can consent in advance, refuse in '
        'advance, or set conditions.\n\n'
        'Important: Under PA Act 194, your agent is NOT allowed to consent '
        'to ECT on your behalf unless you specifically authorize it here. '
        'This authorization must be explicit in your directive.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const SectionLabel('TREATMENT CONSENT'),
          const SizedBox(height: 6),
          Text(
            'Electroconvulsive Therapy (ECT)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'ECT is a psychiatric treatment in which seizures are electrically '
            'induced. State your preferences below.',
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
            text: 'Under PA Act 194, your agent cannot consent to ECT unless '
                'you explicitly authorize it here.',
          ),
          const SizedBox(height: 8),
          WizardHelpButton(helpText: helpText, stepId: 'ect'),
          const SizedBox(height: 16),
          ConsentOptionTile(
            icon: Icons.check_circle_outline,
            title: 'I consent to ECT',
            description: 'My provider may perform ECT if indicated.',
            selected: _consent == ConsentOption.yes,
            onTap: () => setState(() => _consent = ConsentOption.yes),
          ),
          ConsentOptionTile(
            icon: Icons.block,
            title: 'I do not consent to ECT',
            description: 'ECT must not be performed on me.',
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
              title: 'My agent will decide about ECT',
              description:
                  'Authorize your agent to consent to or refuse ECT on your behalf.',
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
                    'e.g., only if other treatments have failed and my agent agrees',
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
